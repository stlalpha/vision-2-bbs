{$R-,S-,I-,D-,F+,V-,B-,N-,L+,O+ }

Unit FileSys0;
                          {/ low level file sysop routines /}
Interface

Uses GenTypes;

Type AskType = (AutoMatic,Leave,Ask);

Procedure ListAREAS;
Procedure RemoveFile(N       : Integer;    { # to Nuke }
                     Confirm : Boolean;    { Confim Each Delection }
                     Delete  : AskType;    { Delete, Yes/No/Ask }
                     Gock    : AskType);   { Ask to Remove User Credit }
Implementation

Uses Dos, MNET, GenSubs, ConfigRT, Subs1, Subs2, UserRet, File0, File1;

  Procedure ListAreas;
  Var A : Arearec;
      Cnt,OldArea,X : Integer;
      Total : Word;
  Begin
    OldArea := CurArea;
    Total   := 0;
    ListingFile(Cfg.TextFileDir + 'FILEAREA.TOP',False);
    For cnt:=1 To numareas Do Begin
      SeekAFile(Cnt);
      nRead(Afile,A);
      If Allowed_In_Area(Cnt,False,A)
      Then begin
        CurArea := Cnt;
        Sr.C[1] := 'NU'; Sr.S[1] := Strr(Cnt); Sr.T[1] := 3;
        Sr.C[2] := 'AN'; Sr.S[2] := A.Name; Sr.T[2] := 30;
        Sr.C[3] := 'NF'; Sr.S[3] := Strr(A.TotalUDs); Sr.T[3] := 4;
        Sr.C[4] := 'UL'; Sr.S[4] := YesNo(A.Uploads); Sr.T[4] := 3;
        Sr.C[5] := 'DL'; Sr.S[5] := YesNo(A.Downloads); Sr.T[5] := 3;
        Sr.C[6] := 'NS'; Sr.S[6] := #32; Sr.T[6] := 1;
        ListingFile(Cfg.TextFileDir + 'FILEAREA.MID',False);
      End;
      Total := Total + NumUds;
      If Break Then Begin
        SetArea(OldArea,False);
        Exit;
      End;
    End;
    Sr.C[1] := 'TF'; Sr.S[1] := Strlong(Total); Sr.T[1] := 6;
    ListingFile(Cfg.TextFileDir + 'FILEAREA.BOT',False);
    SetArea(OldArea,False);
  End;

  Procedure RemoveFile(N       : Integer;    { # to Nuke }
                       Confirm : Boolean;    { Confim Each Delection }
                       Delete  : AskType;    { Delete, Yes/No/Ask }
                       Gock    : AskType);   { Ask to Remove User Credit }

     Function Total_Lines (B : BigDescrip) : Byte;
     Var X : Byte;
     Begin
       For X := 10 DownTo 1 Do
         If B[x] <> '' Then Begin
           Total_Lines := X;
           Exit;
         End;
       Total_Lines := X;
     End;

  Var CNT,UN,X : Integer;
      U : UserRec;
      Nuke : Boolean;
      F : File;
      Orig : AnySTR;

    Procedure AskDeleteQuery;
    Begin
      If Gock = Leave
        Then Exit;
      If Gock = Ask Then Begin
        DefYes := True;
        WriteStr(^R'Take away '+Index.SentBy+'s Upload Credit? !');
        If Not Yes
          Then Exit;
      End;
      Un := LookUpUser(Index.SentBy);
      If Un = -1
        Then WriteLn(^M'User Disappeared!');
      If Un = -1
        Then Exit;
      Seek(Ufile,Un);
      NRead(Ufile,U);
      Dec(U.Uploads);
      Urec.UdPoints := Urec.UdPoints - (Index.Points * Cfg.UploadFactor);
      If UD.FileSize > 0 Then
        U.KUp := U.KUp - (UD.FileSize Div 1024);
      Seek(Ufile,Un);
      nWrite(Ufile,U);
    End;

  Begin
    If Confirm Then Begin
      WriteHDR('File Deletion');
      Writeln(^M^R'FILENAME'^A': '^S+UpString(UD.FileNAME));
      Writeln(^R'UPLOADER'^A': '^S+INDEX.SentBY);
      Writeln(^R'WHEN    '^A': '^S+DateStr(UD.WHEN)+' @ '+TimeStr(UD.WHEN)+^M^P);
      For X := 1 to Total_Lines(INDEX.Descrip)
        Do Writeln(INDEX.Descrip[x]);
      DefYES := TRUE;
      WriteStr(^M^R'Remove this File? !');
      If Not YES
        Then Exit;
    End;
    AskDeleteQuery;
    Orig := GetFName(UD.Path,UD.FileName);
    Write(^R'Removing File'^A': '^S+UpString(UD.FileNAME)+^R'...');
    For Cnt := N To NumUDs - 1
    Do Begin
      SeekUDFile(Cnt + 1);
      NRead(udfile,ud);
      SeekUDFile(Cnt);
      NWrite(udfile,ud)
    End;
    SeekUDFile(NumUDs);
    Truncate(udfile);
    Writeln('Done!');
    NUKE := FALSE;
    IF Delete = ASK Then Begin
      DefYES := TRUE;
      WriteSTR(^R'Erase Disk File ('^S+Orig+^R')? !');
      NUKE := YES;
    End;
    If (Nuke) OR (Delete=AutoMatic)
    Then BEGIN
      If Not EXIST(Orig)
        Then Exit;
      Assign(f,Orig);
      Erase(f);
      Close(F);
    End
  End;

Begin
End.