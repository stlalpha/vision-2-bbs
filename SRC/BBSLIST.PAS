{$R-,S-,I-,D-,F-,V-,B-,N-,L+,O+}

Unit BBSList;

Interface

Uses GenTypes;

Procedure ListBBS;
Procedure AddBBS;
Procedure ChangeBBS;
Procedure ViewAnsi;
Procedure Deletebbs;
Function Init_BBSList : Boolean;

Implementation

Uses Dos, MNET, ConfigRt, GenSubs, Subs1, Subs2, TextRet, Mainr2, OverRet1;

   Function NumBBSes : Integer;
   Begin
     NumBBSes := FileSize(BLFile)
   End;

   Procedure SeekBLFile (N : Integer);
   Begin
     Seek (blfile,N - 1);
   End;

   Function NumBBS : Integer;
   Begin
     NumBBS := Filesize (blfile);
   End;

   Procedure ListBBS;
   Var Cnt,
       b1,
       b2 : Integer;
       B : BBSRec;
   Begin
     Seek (BLFile,0);
     If FileSize(BLFile) < 1 Then Begin
      Writeln (^M^S'There are no entries! Add one!');
      Exit;
     End
     Else Begin
       ParseRange (NumBBS,b1,b2,'BBS Listing');
       Writeln;
       If B1 < 1 Then Exit;
       ListingFile(Cfg.TextFileDir + 'BBSLIST.TOP',True);
        For Cnt := b1 to b2 Do
        Begin
          If Break Then EXIT;
          SeekBLFile(cnt);
          NRead(blfile,b);
          Sr.C[1] := 'NA'; Sr.S[1] := B.Name; Sr.T[1] := 30;
          Sr.C[2] := 'PH'; Sr.S[2] := B.Phone; Sr.T[2] := 12;
          Sr.C[3] := 'BA'; Sr.S[3] := B.Baud; Sr.T[3] := 5;
          Sr.C[4] := 'WA'; Sr.S[4] := B.Ware; Sr.T[4] := 8;
          Sr.C[5] := 'EX'; Sr.S[5] := YesNo(B.Extended > 0); Sr.T[5] := 3;
          Sr.C[6] := 'NU'; Sr.S[6] := Strr(Cnt); Sr.T[6] := 2;
          ListingFile(Cfg.TextFileDir + 'BBSLIST.MID',False);
      End;
      ListingFile(Cfg.TextFileDir + 'BBSLIST.BOT',False);
      End
    End;

    Procedure AddBBS;
    Var M : Message;
        B : BBSRec;
    Begin
      WriteHdr('Adding to BBS List');
      Writeln;
      MultiColor(Strng^.AddBBS_Name);
      NoCRInput('Aborted!',30);
      If Inpt = ''
        Then Exit;
      Fillchar(b,sizeof(b),0);
      B.Name := Inpt;
      MultiColor(Strng^.AddBBS_Number);
      NoCRInput('Aborted!',12);
      If Inpt = ''
        Then Exit;
      B.Phone := Inpt;
      MultiColor(Strng^.AddBBS_Baud);
      NoCRInput('Dual',4);
      If Inpt = ''
        Then Inpt := 'Dual';
      B.Baud := Inpt;
      MultiColor(Strng^.AddBBS_Type);
      NoCRInput('ViSiON/2',8);
      If Inpt = ''
        Then Inpt := 'ViSiON/2';
      B.Ware := Inpt;
      B.LeftBy := Unam;
      DefYes := True;
      WriteStr(Strng^.AddBBS_Upload);
      If Yes Then Begin
        OkForTitle := False;
        Quoting.AllowQuote := False;
        FillChar(M,SizeOf(M),0);
        M.Add_AutoSig := False;
        B.Extended := Editor(M,False,True,'0','0','BBSANSI.TXT','BBSANSI.MAP');
        OkForTitle := True;
      End Else
        B.Extended := -1;
      If Not Exist (Cfg.DataDir + 'BBSLIST.DAT')
        Then Rewrite (blfile) ;
      SeekBLFile (NumBBSes + 1);
      NWrite (BLFile,b);
      Writeln;
      MultiColor (Strng^.BBS_Added);
    End;

   Procedure ChangeBBS;
   Var Q,
       Spock : Integer;
       K : Char;
       B : BBSRec;

     Procedure ShowBBS;
     Begin
       Writeln
       (^M^R'['^A'1'^R'] Name.....: '^S,B.Name,
        ^M^R'['^A'2'^R'] Number...: '^S,B.Phone,
        ^M^R'['^A'3'^R'] Max Baud.: '^S,B.Baud,
        ^M^R'['^A'4'^R'] Software.: '^S,B.Ware,
        ^M^R'['^A'5'^R'] Extended.: ',
        ^M^R'['^A'Q'^R'] Quit');
     End;

   Var M : Message;
   Begin
     Writehdr ('Change an Entry');
     Repeat
       Inpt := '';
       WriteStr (^M^R'Entry to Change ['^A'?'^R']/List: &');
       if inpt[1]='?' Then ListBBS Else
       Begin
         Spock:=valu(inpt);
         If (Spock < 1) Or (Spock > NumBBS)
           Then exit;
       End;
     Until (Spock > 0) Or (HungupOn);
     SeekBlfile (Spock);
     NRead (blfile,b);
     If (Not (Match (B.LeftBy,Unam))) And (IsSysop=False)
     Then Begin
       Writeln (^M'You didn''t make the entry!'^M);
       Exit;
     End;
     Repeat
       Showbbs ;
       WriteStr (^M^R'Edit Command ['^A'R'^R']eshow: *');
       K := Upcase(Inpt[1]);
       Case K of
         '1' : GetString ('Name',b.name);
         '2' : GetString ('Number',b.phone);
         '3' : GetString ('Max Baud',b.baud);
         '4' : GetString ('Software',b.ware);
         '5' : Begin
                 ReloadText ('BBSANSI.TXT','BBSANSI.MAP',B.Extended,M);
                 M.Title := '';
                 M.Anon := False;
                 M.SendTo := 'All';
                 If ReEdit (M,True) then begin
                   DeleteText ('BBSANSI.TXT','BBSANSI.MAP',B.Extended);
                   B.Extended := MakeText ('BBSANSI.TXT','BBSANSI.MAP',M,'');
                   If B.Extended < 1 Then
                   Writeln(^M^S'Extended description/file reset...');
                 End
               End;
         'Q' :;
       End;
     Until (K='Q') Or (HungUpOn);
     Seek (blfile,Spock - 1);
     NWrite (blfile,b);
   End;

   Procedure ViewAnsi;
   Var B : BBSRec;
       S,F : Integer;
       More : Boolean;
   Begin
     If NumBBSes < 1
       Then Begin
         Writeln('No listings...');
         Exit;
       End;
     WriteHdr('View Extended Info');
     ParseRange (NumBBS,S,F,'View Extended BBS Info');
     If S < 1
       Then Exit;
     More := S <> F;
     For S := S To F Do Begin
       SeekBLFile(S);
       NRead(BLFile,B);
       If B.Extended > 0
         Then PrintText('BBSANSI.TXT','BBSANSI.MAP',B.Extended)
         Else Writeln(^M^S'No extended description for '^P + B.Name);
       If More
       Then Begin
         DefYes := True;
         WriteStr(Strng^.View_Extended_BBS);
         If Not Yes
           Then Exit;
       End;
     End;
     Writeln;
   End;

    Procedure Deletebbs;
    Var Bud,
        Cnt,
        N : Integer;
        F : File;
        B : BBSRec;
    Begin
      Writehdr ('Delete a BBS');
      Repeat
       N:=0;
       Writestr (^S^R'BBS number to delete? ['^A'?'^R']/List: *');
       If Inpt=''
         Then Exit
         Else If Inpt = '?'
         Then ListBBS
         Else Begin
           Bud := Valu(inpt);
           If Bud > Numbbs
             Then exit;
           N := Bud;
           If N = 0
             Then Exit;
         End;
      Until (N>0) or (HungUpOn);
      Seek (blfile,n-1);
      NRead (blfile,B);
      If ((Match (Unam,B.LeftBy)) = False) and (IsSysop = False)
      Then Begin
        Writeln(^G^M^S'That was not entered by you!');
        Exit;
      End;

      Writestr('Delete '+^S+B.name+^P+'? !');
      If Not Yes
        Then Exit;

      DeleteText('BBSANSI.TXT','BBSANSI.MAP',B.Extended);

      For Cnt := N + 1 To NumBBS Do Begin
        SeekBLFile(cnt);
        nRead(BLFile,B);
        SeekBLFile(Cnt - 1);
        nWrite(BLFile,B)
      End;

      SeekBLFile(numbbs);
      Truncate(blfile);
      Close(BlFile);
      Assign(BLFile,Cfg.DataDir + 'BBSLIST.DAT');
      Reset(BLFile);
      Writeln(^M'Deleted.');
    End;

    Function Init_BBSList : Boolean;
    Begin
      Init_BBSList := True;
      If IsOpen(BLFile) Then Exit;
      Close_Them_All(BLFile);
      Assign(BLFile,Cfg.DataDir + 'BBSLIST.DAT');
      If Exist(Cfg.DataDir + 'BBSLIST.DAT')
        Then Reset(BLFile)
        Else Rewrite(BLFile);
    End;


Begin
End.

(*

Label Done;
Var Q : Integer;
Begin
    WriteHdr('BBS Listings...');
    Assign (blfile,Cfg.DataDir+'BBSLIST.DAT');
    If Exist(Cfg.DataDir + 'BBSLIST.DAT')
      Then Reset(BlFile)
      Else Rewrite(BLFile);

    Repeat
     Q := Menu ('','BBSLIST','LADC%QV');
     Case Q Of
      1 : listbbs;
      2 : addbbs;
      3 : deletebbs;
      4 : changebbs;
      5 : bbslistsysop;
      7 : viewansi;
     end;
     until (hungupon) or (q=6);

    Done:
    Close (blfile);
End;
*)