{$R-,S-,I-,D-,F+,V-,B-,N-,L+,O+ }

Unit File3;
                          {/ file upload routines /}
Interface

Uses GenTypes;

Procedure Upload;

Implementation

Uses DOS, MNET, Gensubs, Windows, ConfigRt, StatRET, UserRET, Subs1,
     SubsOvr, Subs2, File0, Flags, MainR1, Protocol;

Procedure Upload;

Type Buff_Rec = Record
       FileName : String[12];
       Path     : String[50];
       Index    : UDIndexRec;
     End;

     Type DszRec = Record
       Code : Char;
       FileName : String[12];
       Path : String[50];
       CompleteByte, Size : Longint;
       Cps,Errors : String[4];
       Percent : Real;
     End;

     Buff      = Array[1..25] of Buff_Rec;

Var Bu : Buff;

  Procedure DeleteDSZLog;
  Var F : File;
  Begin
    If Exist(Cfg.DszLog) Then Begin
      Assign(F,Cfg.DSZLog);
      Erase(F);
    End;
  End;

  Function GetDescrip(Filename:Sstr):Byte;
  Var X:Byte;
  Begin
    GetDescrip:=0;
    For X:=1 to 50 Do Begin
      If Match(Bu[X].FileName,FileName) Then Begin
        GetDescrip:=X;
        Exit;
      End;
    End;
  End;

  Procedure AutoUploadGrant;
  Var Te : Integer;
  Begin
    If Cfg.KPerPoint < 1
      Then Exit;

    Sr.C[1] := 'FN'; Sr.S[1] := UpString(UD.FileName);
    MultiColor(Strng^.Auto_Validate_File);
    Writeln;

    Index.Points  := Round((Ud.FileSize Div Cfg.KPerPoint) Div 1000);
    Index.NewFile := False;
    Ud.WhenRated  := Now;

    Sr.C[1] := 'FS'; Sr.S[1] := Strlong(UD.FileSize);
    Sr.C[2] := 'FP'; Sr.S[2] := Strr(Index.Points);
    MultiColor(Strng^.Value_Of_File);
    Writeln;

    Te := Index.Points * Cfg.UploadFactor;

    If Te > 0 then Begin
      Sr.C[1] := 'FP';
      Sr.S[1] := Strr(TE);
      MultiColor(Strng^.Granting_You_FP);
      Writeln;
      Inc(Urec.UDPoints,TE);
    End;

    Writeln;

  End;

  Procedure AddFile;
  Var Lock : Boolean;
  Begin
    UD.IndexPtr := FileSize(UDIndex);
    Lock := LockFile(UDFile,MNLock);
    SeekUDFile(NumUds + 1);
    NWrite(UDFile,UD);
    Lock := LockFile(UDFile,MNUNLock);
    Lock := LockFile(UDIndex,MNLock);
    Seek(UDIndex,UD.IndexPTR);
    NWrite(UDIndex,Index);
    Lock := LockFile(UDIndex,MNUNLock);
    Inc(Log.ULoads);
  End;

  Procedure ProcessLine (S : String; VAR D : DszRec);
  Var Temp : String[50];
      X,A : Byte;
      F : File Of Byte;
      Size : Longint;
  Begin
    FillChar(D,SizeOf(D),0);
    If S[1] <> 'h'
      then D.Code := Upcase(S[1])
      else D.Code := S[1];
    Temp[0] := #0;
    If S[9] <> #32
      Then X := 1
      Else X := 0;
    Temp := Copy(S,3,6 + X);
    For A := 1 to Length(Temp)
      Do If Not (Temp[a] in ['0'..'9'])
        Then Delete(Temp,A,1);
    D.CompleteByte := LongValu(Temp);
    D.Cps := Copy(S,20 + X,4);
    While ( Length(D.Cps) > 0) and (D.Cps[1] = #32)
      Do Delete(D.Cps,1,1);
    D.Errors := Copy(S,29 + X,3);
    While ( Length(D.Errors) > 0) and (D.Errors[1] = #32)
      Do Delete(D.Errors,1,1);
    Temp[0] := #0;
    x := 51 + x;
    While S[x] <> #32 Do Begin
      Temp := Temp + S[x];
      Inc(x);
    End;
    For A := 1 to Length(Temp) Do
      If Temp[A] = '/' Then Temp[a] := '\';
    Temp := UpString(Temp);
    If Exist(Temp) Then Begin
      Assign(F,Temp);
      Reset(F);
      D.Size := FileSize(F);
      Close(F);
    End Else D.Size := -1;
    If (D.Size > 0) and (D.CompleteByte > 0)
      Then D.Percent := (D.CompleteByte / D.Size) * 100
      Else D.Percent := 0;
    GetPathName(Temp,D.Path,D.Filename);
  End;

  Function Add_Rec(D : DszRec) : Boolean;
  Var Crash : Boolean;
      F     : File;
      A     : Byte;
  Begin
    Crash := False;
    Add_Rec := True;
    FillChar(UD,SizeOf(UD),0);
    FillChar(Index,SizeOf(Index),0);
    UD.FileName := D.FileName;
    UD.Path     := D.Path;
    UD.FileSize := D.Size;
    If (Not (D.Code in ['Z','R','S','H']))
    And (Exist (GetFName(UD.Path,UD.FileName)))
      Then Begin
        If Not HungUpOn Then Begin
          Writeln;
          NoBreak := True;
          ClearBreak;
          DefYes := False;
          Writeln;
          WriteStr(Strng^.Crash_Save_File);
          Crash := Yes;
        End;
        If Not Crash Then Begin
          Assign(F,GetFName(UD.Path,UD.FileName));
          Erase(F);
        End
      End;

    If (D.Code in ['Z','R','S','H']) or (Crash) Then Begin

        if not crash then
          begin
            if exist('ZIPLAB.BAT') then
              executewithswap('ZIPLAB.BAT',getfname(ud.path,ud.filename),false);
            ansicls;
            inpt := '';
          end;

       if exist(getfname(ud.path,ud.filename)) then begin
 
        index.crash       := crash;
        index.sentby      := urec.handle;
        index.specialfile := false;
        index.newfile     := true;
        index.return      := false;
        ud.when           := now;

        A := GetDescrip(Ud.Filename);

        If A > 0 Then Begin
          Index.Descrip  := Bu[a].Index.Descrip;
          Index.Password := Bu[a].Index.Password;
          Index.SendTo   := Bu[a].Index.SendTo;
        End;

        AutoUploadGrant;

        AddFile;
        Inc(Urec.Uploads);

        If D.Size > 0
          Then Urec.Kup := Urec.Kup + (D.Size DIV 1024);

        Inc(Status.Newuploads);
        Inc(Status.TotalFiles);
        WriteLog(0,0,'Uploaded: '+D.FileName+' CPS: '+D.Cps);
        {AdDSZLog(D.Cps,D.FileName,False,D.Size);}
       End

    End Else Begin
      WriteLog(0,0,'Unsuccessful Upload: '+D.FileName);
      Add_Rec := False;
    End;
  End;

  Function File_Id (Var B : BigDescrip) : Boolean;
  Var T : Text;
      S : String;
      X : Byte;

     Procedure Kill;
     Var F : File;
     Begin
       If Not Exist('FILE_ID.DIZ')
         Then Exit;
       Assign(F,'FILE_ID.DIZ');
       Erase(F);
     End;

     Procedure UnArchive(Command : AnyStr);
     Begin
       SwapVectors;
       Exec(GetEnv('COMSPEC'),'/C '+Command);
       SwapVectors;
     End;

  Begin
    File_Id := False;

    If  (Pos('.ZIP',UpString(UD.Filename))<1)
    And (Pos('.ARJ',UpString(UD.FileName))<1)
    And (Pos('.LHA',UpString(UD.FileName))<1)
    And (Pos('.LHZ',UpString(UD.FileName))<1)
      Then Exit;

    Kill;

      If Pos('.ZIP',UpString(UD.FileName)) > 0
        Then UnArchive('PKUNZIP -o '+GetFName(UD.Path,UD.FileName)+
                      +' FILE_ID.DIZ ')
      Else
      If Pos('.ARJ',UpString(UD.FileName)) > 0
        Then UnArchive('ARJ x -y '+GetFName(UD.Path,UD.FileName)+
                       +' FILE_ID.DIZ ')
      Else UnArchive('LHA e '+GetFName(UD.Path,UD.FileName)+
                    +' FILE_ID.DIZ');

    If Not Exist('FILE_ID.DIZ')
      Then Exit;

    Writeln(^R'Transferring '^S'FILE_ID.DIZ'^R' to description..');

    Assign(T,'FILE_ID.DIZ');
    Reset(T);
    X := 1;
    While Not ( (Eof(T)) or (X > 10) ) Do Begin
      Readln(T,S);
      B[x] := S;
      Inc(x);
    End;
    TextClose(T);
    Kill;
    File_Id := True;
  End;

  Procedure EnterDescrip(Var B : BigDescrip; FN : Sstr; CheckId : Boolean);
  Var X : Byte;
  Const Push = #27'[14C';
  Begin
    X := 1;
    FillChar(B,SizeOf(B),0);
    If CheckID Then
      If File_Id(B)
        Then Exit;
    NoBreak := True;
    ClearBreak;
    Writeln(^M^R+Push+' Description of '^A+FN+^R'; <'^S'CR/Blank Line'^R'> Quits');
    If Not CheckId Then
      Writeln(Push+' Leave blank to do later or to use FILE_ID.DIZ');
    Write(Direct,Push);
    Write(^O);
    Writeln(Direct,'[-----------------------------------------------]');
    INPT[0] := #0;
    While (HungUpOn = False) and (X < 11) Do Begin
      BufLen := 47;
      BeginWithSpacesOk := True;
      WordWrap := True;
      NoBreak := True;
      NoChain := False;
      AnsiColor(Urec.Color1);
      Write(Direct,Push+#29,#32);
      GetStr(True);
      If Inpt <> ''
        Then B[x] := Inpt
        Else X := 10;
      Inc(X);
    End;
    WordWrap := False;
  End;

  Function CheckUploads : Byte;
  Var T : Text;
      S : String;
      D : DszRec;
      A,Z,X,Shit : Byte;
      Fuck : Array[1..50] of Lstr;
  Begin
    Assign(T,Cfg.DszLog);
    Reset(T);
    If IoResult <> 0 Then Begin
      TextClose(T);
      CheckUploads := 0;
      Exit;
    End;
    Z := 0;
    Shit := 0;
    FillChar(Fuck,SizeOf(Fuck),0);
    While Not Eof(T) Do Begin
      Inc(Shit);
      Readln(T,Fuck[Shit]);
    End;
    TextClose(T);
    For X := 1 to Shit Do
      If Fuck[X] <> '' Then Begin
        ProcessLine(Fuck[X],D);
        If Add_Rec(D)
          Then Inc(Z);
    End;
    CheckUploads := Z;
  End;

  Function SearchForFile(F : Sstr) : Integer;
  Var Ud : Udrec;
      Cnt : Integer;
  Begin
    For Cnt:=1 To filesize(udfile) Do Begin
      Seek (udfile,cnt - 1);
      nRead(udfile,ud);
      If match(ud.filename,f) Then Begin
        Searchforfile:=cnt;
        exit
      End
    End;
    Searchforfile:=0
  End;

  Function Get_Upload : Byte;
  Label Done,BackUp;
  Var {TempUD     : Buff_Rec;}
      Ic,Proto   : Integer;
      Ok,
      Continue,
      Go         : Boolean;
      Temp       : Byte;
      Fn,Tmp1    : AnyStr;
      K          : Char;
      X          : Byte;

  Begin

    Get_Upload := 0;

    If (Area.Uploads = False)
    Or (No_Ul In Urec.Config)
    Or (Not(CheckFlags(Urec.Flags,Area.UpFlag))) then Begin
      Writeln (^S'You can not upload to this area!');
      Exit
    End;

    If (TimeTillEvent < 20) Or (TimeTillNet < 20) Then Begin
      Writeln('Uploads are not allowed within 10 minutes of Events!');
      Exit
    End;

    Ok := False;
    Go := False;
    FillChar(Bu,SizeOf(Bu),0);

{    If Not EnoughFree(Area.XmodemDir) Then Begin
      Writeln('Not enough space to upload!');
      Exit;
    End; }

    PrintFile(Cfg.TextFileDir+'PRE-UP.ANS');

    x := 1;

    Repeat
      Repeat
        Backup:
        Sr.C[1] := 'NU';
        Sr.S[1] := Strr(X);
        MultiColor(Strng^.UploadFileStr);
        NoCrInput('Exit',12);
        If (Length(Inpt)=0) AND (X=1) Then exit;
        If (Inpt='+') Then Goto Done;
        If Length(inpt)=0 Then Begin
          Dec(X);
          Goto Done;
        End;
        If Not validfname(inpt) Then Begin
          MultiColor(Strng^.Invalid_Upload_Name);
          Writeln;
          Goto BackUp;
        End;
        Temp:=GetDescrip(inpt);
        If Temp > 0 Then Begin
          MultiColor(Strng^.You_Already_Entered_FN);
          Writeln;
          Goto BackUp;
        End;

        BU[X].FileName := UpString(inpt);
        BU[X].Path := Area.XmodemDir;
        Ud.FileName := Upstring(inpt);
        Ud.Path := Area.XmodemDir;

        Fn := Getfname(BU[X].Path,BU[X].Filename);
        If Hungupon Then exit;
        Continue := False;
        If exist(fn) Then Begin
          IC := SearchForFile(Ud.FileName);
          If IC > 0 Then Begin
            LoadUDREC(ic);
            If (Index.Crash) and (Match(Index.SentBy,Urec.Handle)) Then Begin
              WriteStr(^P'Do you wish to continue uploading '+
                      +^S+Ud.Filename+'? !');
              OK := Yes;
              Continue := OK;
          End Else Begin
            MultiColor(Strng^.File_Already_Online);
            Writeln;
            Goto BackUp;
            End;
        End Else Begin
            MultiColor(Strng^.File_Already_Online);
            Writeln;
            Goto BackUp;
          End;
        End
        Else ok:=True;
      Until ok;

      EnterDescrip(Bu[X].Index.Descrip,Bu[X].FileName,False);

      BU[X].Index.SendTo[0]   := #0;
      BU[X].Index.Password[0] := #0;

      Repeat
        MultiColor(Strng^.Extended_File_Setup);
        Buflen:=1;
        WriteStr('*');
        If inpt='' then inpt:='C';
        K:=Upcase(inpt[1]);
        Case K of
          'A':Begin
                Writeln(^P'Old File Password'^O': '^S+BU[X].Index.Password);
                Write(^P'File Password'^O': ');
                InputBox(20);
                Bu[X].Index.Password := Inpt;
                Writeln(^R'File Password changed to'^A': '^S+Bu[X].Index.Password);
              End;
          'P':Begin
                Write(^P'Now Private For'^O': '^S);
                If Bu[X].Index.SendTo <> ''
                  Then Writeln(Bu[X].Index.SendTo)
                  Else Writeln('Nobody');
                Write(^P'Private For'^O': ');
                InputBox(30);
                Tmp1 := Inpt;
                If Inpt<>'' Then Proto := LookUpUser(Inpt)
                Else Begin
                  WriteStr(^R'Set to Null? !');
                  If Yes Then Tmp1[0]:=#0;
                  Proto := -1;
               End;
               If Proto = 0 Then Begin
                 Writeln(^S+inpt+' is not found in the user database!');
                 WriteStr('Do you still wish to send file to '+inpt+'? !');
                 If Yes Then Bu[X].Index.SendTo := Tmp1;
               End Else Bu[X].Index.SendTo := Tmp1;
              Writeln(^R'Now private for'^A': '^S+Bu[X].Index.Sendto);
            End;
        {'D' : DoDescrip(Bu[X].Index.Descrip,Bu[X].FileName);}
      End;

    Until (Match(inpt,'C')) or (HungUpOn);

    Inc(X);
    Writeln;
    Until HungUpOn;
    Done:

    If Inpt = '+'
      Then X := 2;

    Get_Upload := X;
  End;

  Procedure ReDo(S,F : Integer);
  Var X : Word;
      Lock : Boolean;

      Function Blank_Descrip : Boolean;
      Var Y : Byte;
      Begin
        For Y := 1 To 10 Do
          If Index.Descrip[Y] <> '' Then Begin
            Blank_Descrip := False;
            Exit;
          End;
        Blank_Descrip := True;
      End;

  Begin
    If HungUpOn
      Then Exit;
    For X := S to F Do Begin
      LoadUDREC(X);
      If Blank_Descrip
        Then Begin
          Sr.C[1] := 'FN'; Sr.S[1] := UpString(UD.Filename);
          EnterDescrip(Index.Descrip,UD.FileName,True);
        End;
      DefYes := False;
      Writeln;
      Sr.C[1] := 'FN'; Sr.S[1] := UpString(UD.FileName);
      WriteStr(Strng^.Notify_Download);
      Index.Return := Yes;
      Lock := LockFile(UDFile,MNLock);
      SeekUDFile(X);
      NWrite(UDFile,UD);
      Lock := LockFile(UDFile,MNUNLock);
      Lock := LockFile(UDIndex,MNLock);
      Seek(UDIndex,UD.IndexPTR);
      NWrite(UDIndex,Index);
      Lock := LockFile(UDIndex,MNUNLock);
    End;
  End;

  Var X : Byte;
      P,S,F,Time : Integer;
  Begin
   DeleteDszLog;
   X := Get_Upload;
   If X = 0
     Then Exit;
   If X <> 1
     Then X := 3;
   Time := TimeLeft;
   UpdateNode('Uploading');
   P := ExecProto(x,Area.XmodemDir,Area.XmodemDir);
   SetTimeLeft(Time + (((Time - Timeleft) * Cfg.TimePercentBack) Div 100));
   UpdateNode('');
   If P < 0
     Then Exit;
   S := NumUds + 1;
   F := CheckUploads;
   WriteUrec;
   If F <= 0
     Then Exit;
   F := F + S - 1;
   ReDo(S,F);
  End;

begin
end.
