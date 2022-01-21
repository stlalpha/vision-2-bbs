{$R-,S-,I-,D-,F-,V-,B-,N-,L+,O+}

unit NetStuff;

Interface

Uses Dos,MNeT,Crt,gentypes,statret,configrt,modem,gensubs,subs1,subs2,
     Textret,mailret,mainr1,overret1;

Procedure Get_Incomming;
Procedure Do_Net_Mail;

Implementation

Var
   { MsgFile : File Of AnyStr; }
   MsgFile : File Of Lstr;

  procedure get_incomming;
  var i,j,k,l,NumBase,NodeNumber:integer;
      done,sending,upgrade,email,bulletins:boolean;
      f:file;
      t:text;
      ID,Pass:String;
      Bases:Array[1..255] of Byte;
      NodeRec:NodeNetRec;
      NodeFile:File of NodeNetRec;

      Function ExecDsz:boolean;
      Var tries:integer;
           ken:boolean;
           ff:file;
      Begin
        Ken := False;
        Assign(ff,Cfg.visiondir+'NET.ZiP');
        If EXiST(Cfg.visiondir+'NET.ZiP')
          Then Erase(ff);
        close(ff);
        execdsz:=false;
        tries:=0;
        ClrScr;
        WriteLn(Usr,'Receiving NetMail.');
        Exec(GetEnv('COMSPEC'),'/C DSZ.EXE port '+strr(Cfg.usecom)+' speed '+strlong(baudrate)+' ha slow rz '+Cfg.visiondir);
        If dosexitcode = 0
          then ken:=true;
        Execdsz := Ken;
      End;             (* End ExecDsz *)

  Function FindBaseName(BaseId:Byte):SStr;
  Var Board:BoardRec;
      Fbd:File of BoardRec;
      Sek:Integer;
  Begin           (* Echo should equal baseId *)
      Assign(Fbd,Cfg.BoardDir+'BoardDir.'+Strr(NodeRec.Conference));
      Reset(Fbd);
      Sek:=0;
      FindBaseName:='';
      Repeat
        Seek(Fbd,Sek);
        nRead(Fbd,Board);
        Inc(Sek);
        If Board.Echo=BaseId then FindBaseName:=Board.ShortName;
      Until (Board.Echo=BaseId) or Eof(Fbd);
      Close(Fbd);
  End;             (* End FindBaseName *)


  Procedure SendOutGoing; (* This sends the outgoing netmail. *)
  Var Ct,Loper,NumMsgs:Integer;
      NetPost:NetPostRec;
      FNP:File of NetPostRec;
      Bul:BulRec;
      M:Message;
      Bfile:File of BulRec;
      BaseName:SStr;
      CurBase:Byte;
      Temp : String;
      s1,s2 : SStr;

      Procedure Package;
      Var X,Track : Byte;
          Temp : Sstr;
          Temp1 : LStr;
      Begin
      ClrScr;
      WriteLn(Usr,'Making NetMail Package as per request.');
      CurBase:=0;
      NumMsgs:=0;
      Assign(Fnp,Cfg.UploadDir+'NETMAiL.PKG');
      ReWrite(Fnp);
      Assign(MsgFile,Cfg.UploadDir+'TEXT.DAT');
      ReWrite(MsgFile);
      Loper:=0;
      While Loper<NumBase Do
       Begin
         Inc(Loper);
         BaseName:=FindBaseName(Bases[Loper]);
         If BaseName<>'' then Begin
         s1 := BaseName + '.T' + Strr(NodeRec.Conference);
         s2 := BaseName + '.M' + Strr(NodeRec.Conference);
         Assign(Bfile,Cfg.BoardDir+BaseName+'.'+Strr(NodeRec.Conference));
         Reset(Bfile);
         Temp := BaseName+'.'+strr(NodeRec.Conference);
         Ct:=0;
         While Not Eof(Bfile) Do
           Begin

             Seek(Bfile,Ct);
             NRead(Bfile,Bul);

             If Bul.When > NodeRec.LastDate Then
               Begin

                 Inc(NumMsgs);

                 NetPost.NetIdNum := Bases[Loper];
                 NetPost.BulletinRec := Bul;

                 ReloadText(s1,s2,Bul.Line,M);
                 NetPost.TotalLines := M.Numlines;

                 For Track := 1 to M.Numlines
                   Do nWrite(MsgFile,M.Text[Track]);

                 NetPost.TotalLines := Track;
                 Seek(Fnp,FileSize(Fnp));
                 nWrite(Fnp,NetPost);

               End;      (* If Bul.When > NodeRec.LastDate *)
             Inc(Ct);
           End;          (* End While Not Eof *)
         Close(Bfile);
         End;            (* End if basename<>'' *)
       End;              (* End Loper *)
       Close(Fnp);
       Close(MsgFile);
      End;               (* End Package *)

      Procedure ZipPackage;
      Var F:File;
      Begin
        ExecuteWithSwap('PKZIP.EXE ',Cfg.uploaddir+'NET.ZIP '+Cfg.uploaddir+'NETMAIL.PKG '+Cfg.UploadDir+'TEXT.DAT');
        Assign(F,Cfg.uploaddir+'NETMAIL.PKG');
        Erase(F);
        Close(F);
        Assign(F,Cfg.uploaddir+'TEXT.DAT');
        Erase(F);
        Close(F);
      End;          (* End ZipPackage *)

      Procedure SendDsz;
      Var F:File;
      Begin
        ClrScr;
        WriteLn(Usr,'Sending NetMail Packet.');
        Exec(GetEnv('COMSPEC'),'/C DSZ.EXE port '+Strr(Cfg.usecom)+' speed '+strlong(Baudrate)+' ha slow sz -m '+
             +Cfg.uploaddir+'NET.ZIP');
        Assign(F,Cfg.uploaddir+'Net.Zip');
        Erase(F);
      End;       (* End SendDsz *)

      Procedure UpdateStory;
      Begin
        Notice(Cfg.SysopName,Strr(NumMsgs)+' were sent to '+NodeRec.Name+'/'+NodeRec.Node);
      End;              (* End UpdateStory *)

      Begin
        Package;
        ZipPackage;
        SendDsz;
        NodeRec.LastDate:=Now;
        UpDateStory;
      End;                    (* End SendOutGoing *)

  Procedure UpdateNode;
  Begin
    Assign(Nodefile,Cfg.ViSiONDir+'NODELIST.BBS');
    Reset(NodeFile);
    Seek(NodeFile,NodeNumber);
    nWrite(NodeFile,NodeRec);
    Close(Nodefile);
  End;              (* End UpdateNode *)

  Procedure ProcessIncomming;
  Var Fnp:File of NetPostRec;
      NetPost:NetPostRec;
      M:Message;
      B:BulRec;
      NumMsgs:Integer;
      Bfile:File of BulRec;

      Procedure UpDateStory;
      Begin
        Notice(Cfg.SysopName,Strr(NumMsgs)+' messages were received from '+NodeRec.Name+'/'+NodeRec.Node);
        Status.NewPosts:=Status.NewPosts+NumMsgs;
        Status.TotalMsgs:=Status.TotalMsgs+NumMsgs;
        WriteStatus;
      End;              (* End UpDateStory *)

      Procedure UnZipNet;
      Var F:File;
      Begin
        SwapVectors;
        Exec(GetEnv('COMSPEC'),'/C PKUNZIP '+Cfg.visiondir+'NET.ZIP -o '+Cfg.visiondir);
        SwapVectors;
        If DosExitCode = 0 Then Begin
          Assign(F,Cfg.visiondir+'NET.ZIP');
          Erase(F);
          Close(F);
        End Else Begin
          Writeln(Usr,'Error Unzipping NET Package!!');
          Delay(1000);
        End
      End;          (* End UnZipNet *)

      Procedure PostMsgs;
      Var F:File;
          TId:Word;
          Current,X:Byte;
          BaseName:Sstr;
          { Line:AnyStr; }
          Line : LStr;
          Total:Word;
          Temp, Mess1, Mess2 : Sstr;
      Begin
        ClrScr;
        WriteLn(Usr,'Posting NetMail Messages.');
        If Exist(Cfg.visiondir+'NETMAIL.PKG') Then
        Begin
          Assign(Fnp,Cfg.visiondir+'NETMAIL.PKG');
          Reset(Fnp);
          Assign(MsgFile,Cfg.VisionDir+'TEXT.DAT');
          Reset(MsgFile);
          NumMsgs := 0;
          Current := 0;
          Total := 0;
          While Not Eof(Fnp) Do
          Begin
            Read(Fnp,NetPost);
            If Current<>NetPost.NetIdNum Then Begin
              BaseName:=FindBaseName(NetPost.NetIdNum);
              Close(Bfile);
              If BaseName<>'' Then Begin
                Assign(Bfile,Cfg.BoardDir+BaseName+'.'+Strr(NodeRec.Conference));
                Reset(Bfile);
                Temp := BaseName+'.'+Strr(NodeRec.Conference);
                Mess1 := BaseName+'.'+'T'+Strr(NodeRec.Conference);
                Mess2 := BaseName+'.'+'M'+Strr(NodeRec.Conference);
              End;   (* End if basename<>'' *)
            End; (* End if current<>netpost.netidnum *)
            If NetPost.BulletinRec.Origin1<>Strng^.Origin1 Then
            Begin
              Seek(Bfile,FileSize(BFile)-1);
              nRead(Bfile,B);
              If B.Id = 65535
                Then NetPost.BulletinRec.Id:=1
                Else NetPost.BulletinRec.Id:=B.Id+1;
              B:=NetPost.BulletinRec;
              FillChar(M.Text,SizeOf(M.Text),0);
              Seek(MsgFile,Total);
              Writeln(usr,'Posting Message #'+Strr(NumMsgs+1));
              For X := 1 To NetPost.TotalLines Do Begin
                Read(MsgFile,Line);
                M.Text[X]:=Line;
                Inc(Total);
              End;
              M.Numlines := NetPost.TotalLines;
              M.Title := B.Title;
              M.SendTo:= B.SentTo;
              M.Note := '';
              M.Anon:=B.Anon;
              Trimmessage(M);
              B.Line:=MakeText(Mess1,Mess2,M,'');
              B.When:=Now;
              Seek(Bfile,FileSize(Bfile));
              nWrite(Bfile,B);
              Inc(NumMsgs);
            End;           (* End if origin is here *)
          End;              (* End While Not Eof Do Begin *)
          Close(Fnp);
          Close(MsgFile);
          Assign(F,Cfg.visiondir+'NETMAiL.PKG');
          Erase(F);
          Assign(F,Cfg.VisionDir+'TEXT.DAT');
          Erase(F);
        End;  (* End If Exist Msgs *)
      End;  (* End PostMsgs *)


      Begin         (* Main ProcessIncomming *)
        UnZipNet;
        PostMsgs;
        UpDateStory;
        NodeRec.LastDate:=Now;
      End;           (* End ProcessIncomming *)

Var Rec : Boolean;
Begin
  WriteStr(^B'ID: *');
  Id := Inpt;
  WriteStr(^B'PASS: *');
  Pass := Inpt;
  FillChar(Bases,SizeOf(Bases),0);
  NumBase := 0;
  upgrade := False;
  Email := False;
  Bulletins := False;     (* Note EMAIL and Bulletins are NOT added yet *)
  Done := False;
  If Exist(Cfg.ViSiONDir+'NODELIST.BBS') Then Begin
    Assign(NodeFile,Cfg.ViSiONDir+'NodeList.BBS');
    Reset(NodeFile);
    NodeNumber := -1;
    Done := False;
    While Not Eof(NodeFile) and Not Done Do
    Begin
      nRead(NodeFile,NodeRec);
      Inc(NodeNumber);
      If (Match(Id,NodeRec.Node)) and (Match(Pass,NodeRec.Pass)) then Done:=True;
    End;
    Close(NodeFile);
  End;              (* End if exist loop *)
  If Not Done then Begin
    WriteLn('ID and/or Password not found in NODELIST.BBS! Aborting...');
    Delay(1500);
    HangUp;
    EnsureClosed;
    Halt(0);
  End;
  I:=1;
  Repeat
    WriteStr(^B'BASE: *');
    I := Valu(inpt);
    If I>0 then Begin
      Inc(NumBase);
      Bases[NumBase]:=I;
    End; (* End if then *)
  Until (I=0) or HungUpOn;
  WriteStr('SEND: *');
  Sending:=Yes;
  WriteStr('RECEIVE: *');
  Rec:=Yes;
  If Sending
    Then Sending:=ExecDsz;
  If Rec
    Then SendOutGoing;
  Delay(1500);
  HangUp;
  DontAnswer;
  If Sending
    Then ProcessIncomming;
  UpDateNode;
  EnsureClosed;
  Halt(0);
End;                   (* End Get_Incomming *)


Procedure Do_Net_Mail;        (* ViSiON NetMail Version 1.01 *)
Var
    NodeRec : NodeNetRec;
    CurrentNodeNumber,
    NumMsgs,
    Jo : Integer;
    Fnode : File of NodeNetRec;
    Chrr : Char;
    Simplex  : Boolean;
    Finished : Boolean;
    OKToSend : BooLean;

  Function FindBaseName(BaseId:Byte):SStr;
  Var Board : BoardRec;
      Fbd : File of BoardRec;
      Sek : Integer;
  Begin           (* Echo should equal baseId *)
    Assign(Fbd,Cfg.BoardDir+'BoardDir.'+Strr(NodeRec.Conference));
    Reset(Fbd);
    Sek := 0;
    FindBaseName := '';
    Repeat
      Seek(Fbd,Sek);
      nRead(Fbd,Board);
      Inc(Sek);
      If Board.Echo=BaseId
        Then FindBaseName:=Board.ShortName;
    Until (Board.Echo=BaseId) or Eof(Fbd);
    Close(Fbd);
  End;             (* End FindBaseName *)

  Procedure SendString(S:Lstr);
  Var I:Integer;
  Begin
    For I:=1 to Length(S) Do SendChar(S[I]);
  End;     (* End Send String *)

  procedure UpDateStory(Nums:Integer; Sent:Boolean);
  Var T:Sstr;
  Begin
    If Not Sent then T:='sent to' else T:='received from';
    Notice(Cfg.SysopName,Strr(Nums)+' Messages were '+T+' '+NodeRec.Name);
  End;      (* End UpdateStory *)

  Procedure GetItAll;
  Var C:Char;
  Begin
   While NumChars > 0 do
     WriteCon(GetChar);
     { Write(usr,getchar); }
  End;                    (* End GetItAll *)

  Procedure SetUpForNetMail;
  Begin
    TextMode(Co80);
    TextAttr:=15;
    ClrScr;
      TextAttr:=8;  Write(usr,'[');
      TextAttr:=15; WRite(usr,'ViSiON/2 Net Mail');
      TextAttr:=8;  Write(usr,']');
      TextAttr:=14; Write(usr,' - Version o.70 - Ruthless Enterprises 1992');
      Textattr:=9;
      Writeln(usr);
    If Not Exist(Cfg.ViSiONDir+'NodeList.BBS') then
    Begin
      WriteLn(Usr,'We WOULD send NetMail, BUT there seems to be no one to net with. MAKE');
      WriteLn(Usr,'your NODELIST.BBS file BEFORE trying to attempt netmail!');
      EnsureClosed;
      Delay(5000);
      Halt(0);
    End;      (* End If then Begin *)
    WriteLn(Usr,'Initializing Modem...');
    SendString('ATZ'+#13);
    Delay(1500);
    GetItAll;
    SendString('ATS0=0'+#13);
    Delay(500);
    GetItAll;
{    WriteLn(Usr,'Now we will go ahead and set the Extended Registers to recognize everything.');
    SendString('ATX6'+#13);
    Delay(500);
    GetItAll; }
    WriteLn(Usr,'Now we will open up the Node List file.');
    Assign(Fnode,Cfg.ViSiONDir+'NodeList.BBS');
    Reset(Fnode);
    CurrentNodeNumber:=0;
    WriteLn(Usr,'There. All done.');
  End;                  (* End SetUpForNetMail *)

  Procedure DialNodes;
  Var Packaged : Boolean;

    Function Connected : Boolean;
    Var C : Char;
        S : String;
    Begin
      Delay(9000);
      S:='';
      While NumChars > 0 Do
      Begin
        S := S + Getchar;
        If C = #13 then S:='';
        If Pos('[Enter]',S)>0 Then
        Begin
          WriteLn(Usr,'We MUST hit return!');
          SendString(#13+#13+#13+#13);
          S:='';
        End;    (* End If then *)
      End;      (* End Repeat Loop *)
      If Carrier
        Then Connected:=True;
    End;         (* End Connected *)

   Procedure DialNode;

       Procedure PrepNetMail;
       Var Ct,
           Loper : Integer;
           NetPost : NetPostRec;
           FNP : File of NetPostRec;
           Bul : BulRec;
           M : Message;
           BFile : File of BulRec;
           BaseName : SStr;
           CurBase : Byte;
           Temp : String[255];

       Procedure Package;
       Var X : Byte;
           Temp : Sstr;
           Track : Byte;
           s1,s2 : sstr;
       Begin
       TextAttr:=9;
       DontAnswer;

       Writeln(Usr,'Creating NETMAIL Pacakage...');
       
       CurBase:=0;
       NumMsgs:=0;

       Assign(Fnp,Cfg.uploaddir+'NetMail.Pkg');
       ReWrite(Fnp);

       Assign(MsgFile,Cfg.UploadDir+'TEXT.DAT');
       ReWrite(MsgFile);

       Loper:=0;

       While Loper < 255 Do
       Begin

         Inc(Loper);
         Writeln(usr,'Checking BASE ID: '+Strr(Loper));
         If NodeRec.BaseSelection[Loper] Then Begin
           BaseName:=FindBaseName(Loper);
           If BaseName<>'' then Begin
             s1 := BaseName + '.T' + Strr(NodeRec.Conference);
             s2 := BaseName + '.M' + Strr(NodeRec.Conference);
             Assign(Bfile,Cfg.BoardDir+BaseName+'.'+STrr(NodeRec.Conference));
             Reset(Bfile);
             Temp:=BaseName+'.'+Strr(NodeRec.Conference);
             Ct:=0;
           While Not Eof(Bfile) Do
           Begin

             Seek(Bfile,Ct);
             NRead(Bfile,Bul);

             If Bul.When > NodeRec.LastDate Then
             Begin
               Inc(NumMsgs);

               NetPost.NetIdNum := Loper;
               NetPost.BulletinRec := Bul;

               ReloadText(s1,s2,Bul.Line,M);
               NetPost.TotalLines := M.NumLines;

               For Track := 1 to M.Numlines Do
                 Write(MsgFile,M.Text[Track]);

               Seek(Fnp,FileSize(Fnp));
               Write(Fnp,NetPost);

               End; (* If Bul.When>NodeRec.LastDate *)
             Inc(Ct);
           End;  (* End While Not Eof *)
         Close(Bfile);
         End;         (* End if basename<>'' *)
         End;         (* End if basethingie *)
       End;           (* End Loper *)
       Close(Fnp);
       Close(MsgFile);
      End;            (* End Package *)

      Procedure ZipPackage;
      Var F:File;
      Begin
        ExecuteWithSwap('PKZIP.EXE ',Cfg.uploaddir+'Net.Zip '+Cfg.uploaddir+'NetMail.Pkg '+Cfg.UploadDir+'TEXT.DAT');
        If DosExitCode=0 then Begin
         Assign(F,Cfg.uploaddir+'NetMail.Pkg');
         Erase(F);
         Close(F);
         Assign(F,Cfg.UploadDir+'TEXT.DAT');
         Erase(F);
         Close(F);
        End;
      End;          (* End ZipPackage *)

      Begin
        Package;
        If Exist(Cfg.Uploaddir+'NETMAIL.PKG') Then Begin
        ZipPackage;
        Packaged:=True;
        End;
      End;                    (* End SendOutGoing *)

       Function Call(X:Lstr):Boolean;
       Var Pre,Suf:Lstr;
           Jo:Integer;
           Finished:Boolean;

           Function Busy:Boolean;
           Var K:String;
               C:Char;
           Begin
             K:='';
	     While NumChars > 0
               Do k:=k+getchar;
             Busy:=False;
             If Pos('BUSY',K) > 0
               Then Busy:=True;
             If Pos('NO CARRIER',K) > 0
               Then Busy:=True;
             If Pos('NO DIAL',K ) >0
               Then Busy:=True;
           End;    (* End Busy *)


       Begin
         ClrScr;
         WriteLn(Usr,'Dialing Number...');
         If X=''
           Then Exit;
         Dontanswer;
         Delay(1500);
         Pre:='';
         Suf:='';
         If KeyPressed
           Then Chrr:=ReadKey;
         DoAnswer;
         Delay(1200);
         SendString('     ');
         Delay(1600);
         GetItAll;
         SendString(Cfg.ModemDialPrefix+X+#13);
         Finished:=False;
         Delay(1500);
         GetItAll;
         Jo := 0;
         Repeat
           Inc(Jo);
           Delay(10);
           If Busy
             Then Finished:=True;
           If Finished then WriteLn(Usr,'Line was busy!'^M);
           If KeyPressed
             Then Finished:=True;
           If KeyPressed
             Then WriteLn(Usr,'User Abort!');
           If Carrier then Finished:=True;
         Until Finished or (Jo>15000);
         SendString(^M);
         Call := Carrier;
       End;         (* End Call *)


    Var C : Char;
    Begin
       PrepNetMail;
       TextMode(Co80);
       Window(1,1,80,25);
       ClrScr;
       TextAttr:=8;  Write(usr,'[');
       TextAttr:=15; WRite(usr,'ViSiON/2 Net Mail');
       TextAttr:=8;  Write(usr,']');
       TextAttr:=14; Write(usr,' - Version o.70 - Ruthless Enterprises 1992');
       textattr:=9;
       Writeln(usr);
       WriteLn(Usr,'Calling '+NodeRec.Name+' @'+NodeRec.Phone);
       Writeln(Usr,'Node ID: '+NodeRec.Node+'  Last Net Call: '+DateStr(NodeRec.LastDate)+' at '+TimeStr(NodeREc.LastDate));
       TextAttr:=8;
       WriteLn(Usr,'컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴� ESC Aborts 컴�');
       TextAttr:=7;
       Window(1,6,80,25);
       Repeat
        Delay(2500);
      {  C := #0;
        If KeyPressed Then
          C := ReadKey; }
       Until Call(NodeRec.Phone) or (Chrr = #27) or
         (Not WithinTime(Cfg.NetStc,Cfg.NetEnc));
    End; (* End DialNode *)

  Function SuccessfulNetMail : Boolean;
  Var T:Text;
      Received:Boolean;
      F:File;
      I:Integer;

  Procedure SendViaDSZ;
  Begin
    Delay(3000);
    SwapVectors;
    Exec(GetEnv('COMSPEC'),'/C DSZ.EXE port '+Strr(Cfg.usecom)+' speed '+strlong(baudrate)+' ha slow sz -m '+
         +Cfg.uploaddir+'Net.Zip');
    SwapVectors;
    Assign(F,Cfg.uploaddir+'Net.Zip');
    Erase(F);
    updatestory(NumMsgs,False);
    NumMsgs:=0;
  End;                   (* End SendViaDSZ *)

  Function ExecDsz : Boolean;
  Var ken : char;
  Begin
    If Exist(Cfg.visiondir+'Net.Zip') then
    Begin
      Assign(F,Cfg.visiondir+'Net.Zip');
      Erase(F);
    End;       (* End If Then *)
    Delay(500);
    GetItAll;
    Repeat
    Until (NumChars > 0) or (Not Carrier);
    SwapVectors;
    Exec(GetEnv('COMSPEC'),'/C DSZ.EXE port '+Strr(Cfg.usecom)+' speed '+strlong(baudrate)+' ha slow rz -m '+
         +Cfg.visiondir+'Net.Zip');
    SwapVectors;
    ExecDsz:=True;
  End;

  Procedure ProcessIncomming;
  Var Fnp:File of NetPostRec;
      NetPost:NetPostRec;
      M:Message;
      B:BulRec;
      Bfile:File of BulRec;
      Upgrade,oktosend:Boolean;

      Procedure UnZipNet;
      Var F:File;
      Begin
        SwapVectors;
        Exec(GetEnv('COMSPEC'),'/C Pkunzip '+Cfg.visiondir+'Net.Zip -o '+Cfg.visiondir);
        SwapVectors;
        Assign(F,Cfg.visiondir+'Net.Zip');
        Erase(F);
        Close(F);
      End;          (* End UnZipNet *)

      Procedure PostMsgs;
      Var F : File;
          TId : Word;
          Current,X : Byte;
          BaseName : Sstr;
          { Line : AnyStr; }
          Line : LStr;
          Total : Word;
          Temp,Mess1,Mess2 : Mstr;
      Begin
        ClrScr;
        WriteLn(Usr,'Posting NetMail Messages.');
        If Exist(Cfg.visiondir+'NetMail.Pkg') Then
        Begin
          Assign(Fnp,Cfg.visiondir+'NetMail.Pkg');
          Reset(Fnp);
          Assign(MsgFile,Cfg.ViSiONDiR+'TEXT.DAT');
          Reset(MsgFile);
          NumMsgs:=0;
          Current:=0;
          Total:=0;
          While Not Eof(Fnp) Do
          Begin
            nRead(Fnp,NetPost);
            If Current<>NetPost.NetIdNum Then Begin
              BaseName:=FindBaseName(NetPost.NetIdNum);
              Close(Bfile);
              If BaseName<>'' Then Begin
                Assign(Bfile,Cfg.BoardDir+BaseName+'.'+strr(NodeRec.Conference));
                Reset(Bfile);
                Temp:=BaseName+'.'+Strr(NodeRec.Conference);
                Mess1 := BaseName+'.'+'T'+Strr(NodeRec.Conference);
                Mess2 := BaseName+'.'+'M'+Strr(NodeRec.Conference);
              End;   (* End if basename<>'' *)
            End;   (* End if current<>netpost.netidnum *)
            If NetPost.BulletinRec.Origin1<>Strng^.Origin1 Then
            Begin
              Seek(Bfile,FileSize(BFile)-1);
              nRead(Bfile,B);
              If B.Id=65535
                Then NetPost.BulletinRec.Id:=1
                Else NetPost.BulletinRec.Id:=B.Id+1;
              B:=NetPost.BulletinRec;
              FillChar(M.Text,SizeOf(M.Text),0);
              Seek(MsgFile,Total);
              Writeln('Post Message #'+Strr(NumMsgs+1));

              For X:=1 to NetPost.TotalLines Do Begin
                Read(MsgFile,Line);
                M.Text[X]:=Line;
                Inc(Total);
              End;

              M.Numlines:=NetPost.TotalLines;
              M.Title:=B.Title;
              M.SendTo:=B.SentTo;
              M.Note:='';
              M.Anon:=B.Anon;
              Trimmessage(M);
              B.Line:=MakeText(Mess1,Mess2,M,'');
              B.When:=Now;
              Seek(Bfile,FileSize(Bfile));
              nWrite(Bfile,B);
              Inc(NumMsgs);
            End;            (* End if origin is here *)
          End;              (* End While Not Eof Do Begin *)
          Close(Fnp);
          Close(MsgFile);
          Assign(F,Cfg.visiondir+'NetMail.Pkg');
          Erase(F);
          Assign(F,Cfg.VisionDir+'Text.Dat');
          Erase(F);
        End;                (* End If Exist Msgs *)
      End;                  (* End PostMsgs *)


  Begin         (* Main ProcessIncomming *)
    UnZipNet;
    PostMsgs;
    UpDateStory(NumMsgs,True);
  End;           (* End ProcessIncomming *)

  Procedure UpDateNode;
  Begin
    NodeRec.LastDate:=Now;
    Seek(Fnode,CurrentNodeNumber);
    nWrite(Fnode,NodeRec);
  End;                      (* End UpDateNode *)

  Begin
   If (Carrier = False) And ( WithinTime(Cfg.NetStc,Cfg.NetEnc) = False) then
    Begin
      SuccessfulNetMail:=True;
      Exit;
    End;
    If Not Connected Then
    Begin
      SuccessfulNetMail:=False;
      WriteLn(Usr,'NetMail failed.. Why???');
      HangUp;
      Delay(1600);
      Exit;
    End;   (* End Delay *)
    SuccessfulNetMail:=False;
    Delay(2000);
    SendString(Cfg.NetPassword+#13);
    Delay(500);
    GetItAll;
    SendString(NodeRec.Node+#13);
    Delay(500);
    GetItAll;
    SendString(NodeRec.Pass+#13);
    Delay(500);
    GetItAll;
    Delay(1500);
    If Not Carrier then Begin
      Notice(Cfg.SysOpName,'NETMAIL Failed! Wrong Password / ID..');
      SuccessfulNetMail:=True;
    End;                      (* End if not carrier *)
(*  If Cfg.NetType1 then SendString('U'+#13); *)
    oktosend:=False;
    For I:=1 to 255 Do
    Begin
      If NodeRec.BaseSelection[I] Then SendString(Strr(I)+#13);
      If NodeRec.BaseSelection[I] then GetItAll;
      oktosend:=False;
    End;
    SendString('0'+#13);
    Delay(500);
    GetItAll;
    oktosend:=true;
    If Packaged then
    Begin
      SendString('Y'+#13);
      Delay(500);
      GetItAll;
      SendString('Y'+#13); (* This is the "Yes to receive" *)
      If oktosend then SendViaDSZ;
    End Else            (* End if packaged *)
    Begin
      SendString('N'+#13);
      Delay(500);
      GetItAll;
      SendString('Y'+#13); (* yes to receive *)
    End;
    Delay(1500);
    If Not Carrier then Begin
      SuccessfulNetMail:=False;
      Exit;
    End;    (* If Not Carrier *)
    Received:=ExecDsz;
    HangUp;
    If Received
      Then ProcessIncomming;
    UpDateNode;
    SuccessfulNetMail:=True;
  End;                         (* End SuccessfulNetMail *)


  Begin
    While Not Eof(Fnode) Do Begin
      Seek(Fnode,CurrentNodeNumber);
      nRead(Fnode,NodeRec);
      Repeat
        DialNode;
      Until SuccessfulNetMail;   (* End Loop *)
      Inc(CurrentNodeNumber);
    End      (* End While Not EofFnode *)
  End;      (* End DialNodes *)

  Procedure ExitNetMail;
  Begin
    ClrScr;
    WriteLn(Usr,'Now we''re done.. Setting back on Auto Answer.');
    DoAnswer;
    SendString('ATZ'+#13);
    Delay(2500);
    GetItAll;
    SendString('ATS0=1'+#13);
    Delay(700);
    GetItAll;
  End;

Begin
  SetUpForNetMail;
  DialNodes;
  ExitNetMail;
  EnsureClosed;
  Halt(0);
End;             (* End Do_Net_Mail *)

Begin
End.
