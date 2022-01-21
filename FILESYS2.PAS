{$R-,S-,I-,D-,F+,V-,B-,N-,L+,O+ }

Unit FileSys2;
                          {/ local file adding /}
Interface

Uses GenTypes;

Procedure AddMultipleFiles;
Procedure SysopADD;
Procedure Directory(dir:lstr);

Implementation

Uses Dos, MNET, ConfigRT, GenSubs, Windows, StatRet, Subs1, Subs2, File0;

Procedure GetFSize(Var ud:udrec);
Var DF : File Of Byte;
Begin
  Ud.FileSize := -1;
  Assign(DF,GetFName(ud.path,ud.filename));
  Reset(DF);
  If IOResult <> 0
    Then Begin
      Close(DF);
      Exit;
    End;
  Ud.FileSize := FileSize(df);
  Close(DF)
End;

    Function File_Id (Var UD:UDRec) : Boolean;
    Var T : Text;
        S : String;
        X : Byte;

       Procedure Kill;
       Var F : File;
           I : Integer;
       Begin
         Assign(F,'FILE_ID.DIZ');
         Erase(F);
         I := IoResult;
       End;

       Procedure Unarchive(Command : AnyStr);
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
        Then Begin
          Writeln(^R'FILE_ID.DIZ '^S'not found...');
          Exit;
        End;

      Writeln(^R'Transferring '^S'FILE_ID.DIZ'^R' to description..');

      Assign(T,'FILE_ID.DIZ');
      Reset(T);
      X := 1;
      While Not ( (Eof(T)) or (X > 10) ) Do Begin
        Readln(T,S);
        Index.Descrip[x] := S;
        Inc(x);
      End;
      TextClose(T);

      Kill;

      File_Id := True;
    End;

    Procedure EnterDescrip(Var UD : UDRec; FN : Sstr);
    Label Bad_Programmer;
    Var X : Byte;
    Const Push = #27'[14C';
          Done : Boolean = True;
    Begin
      Bad_Programmer:
      X := 1;
      FillChar(Index.Descrip,SizeOf(Index.Descrip),0);
      NoBreak := True;
      ClearBreak;
      Writeln(^M^R+Push+' Description of '^A+FN+^R'; <'^S'CR/Blank Line'^R'> Quits');
      Writeln(Push+' Enter "+" on Line 1 to search for FILE_ID.DIZ');
      Write(Direct,Push);
      Write(^O);
      Writeln(Direct,'[-----------------------------------------------]');
      While (HungUpOn = False) and (X < 11) Do Begin
        BufLen := 47;
        BeginWithSpacesOk := True;
        WordWrap := True;
        NoBreak := True;
        NoChain := False;
        AnsiColor(Urec.Color1);
        Write(Direct,Push+#29,#32);
        GetStr(True);
        If Inpt = ''
          Then Done := True;
        If (Inpt = '+') And (X = 1)
          Then If File_Id(UD)
            Then Exit
            Else Begin
              Done := False;
              Writeln(^M);
              Writeln(^R'FILE_ID.DIZ was not found in '^S+FN+^R'!'^M);
              HoldScreen;
              Goto Bad_Programmer;
            End;
        If Inpt <> ''
          Then Index.Descrip[x] := Inpt
          Else X := 10;
        Inc(X);
        If X > 10
          Then Done := True;
      End;
      WordWrap := False;
    End;

  Procedure writefreespace(path:lstr);
  Var free,total:Real;
      Begin
      Free:=DiskSpace(Path,False);
      Total:=DiskSpace(Path,True);
        if free < 1024*1024 then
           Write (^S, free/1024:0:0 , ^R'KB out of ' )
        else
           Write (^S, free/(1024*1024):0:0 , ^R'MB out of ' ) ;
        if total < 1024*1024 then
           WriteLn (^S, total/1024:0:0 ,^R+'KB' )
        else
           WriteLn (^S, total/(1024*1024):0:0 , ^R'MB' ) ;
        If free/1024<100.0 Then WriteLn(^G^S'*** Danger! Limited file space left!');
      End;

  function enoughfree(path:lstr):boolean;
    var free:real;
        josh:boolean;
        temp2:longint;
    begin
    josh:=false;
    free:=DiskSpace(path,False);
    temp2:=trunc(free/1024);
    if temp2>Cfg.minfreespace then josh:=true;
    enoughfree:=josh;
    if not josh then begin
       writeln(^M^S'Sorry, there is not enough free space on the hard drive for this upload.');
       writeln(^S'Please notify the SysOp. Thank you.');
    end;
    end;

    Procedure displayfile(Var ffinfo:searchrec);
    Var i,a:Integer;
        S:String[16];
    Begin
      a:=ffinfo.attr;
      If (a And 8)=8 Then exit;
      AnsiColor(11);
      S:=ffinfo.name;
      i:=1;
      While i<= length(s) Do Begin
         Case S[i] of
         '.':Ansicolor(8);
         End;
         Write(s[i]);
         If S[i]='.' then AnsiColor(3);
         inc(i);
         End;
      tab('',13-Length(s));
      AnsiColor(13);
      If (a And 16)=16
      Then Write('Directory')
      Else Write(ffinfo.size);
      AnsiColor(5);
      If (a And 1)=1 Then Write(' [READ-ONLY]');
      If (a And 2)=2 Then Write(' [HIDDEN]');
      If (a And 4)=4 Then Write(' [SYSTEM]');
      WriteLn
    End;

    Procedure directory(dir:lstr);
    Var r:registers;
      ffinfo:searchrec;
      tpath:anystr;
      b:Byte;
      cnt:Integer;

      Function defaultdrive:Byte;
      Var R : Registers;
      Begin
        r.ah:=$19;
        Intr($21,r);
        defaultdrive:=r.al+1
      End;

    Begin
      tpath:=dir;
      If tpath[Length(tpath)]<>'\' Then tpath:=tpath+'\';
      tpath:=tpath+'*.*';
      writestr(^R'Path/wildcard [CR for '+^S+tpath+^R+']: *');
      WriteLn(^M);
      If Length(inpt)<>0 Then tpath:=inpt;
      writelog(16,10,tpath);
      findfirst(Chr(defaultdrive+64)+':\*.*',8,ffinfo);
      If doserror<>0
      Then WriteLn(^R'No volume label'^M)
      Else WriteLn(^P'Volume label'^O': '^S+ffinfo.name+^M);
      findfirst(tpath,$17,ffinfo);
      If doserror<>0 Then WriteLn(^R'No files found.') Else Begin
        cnt:=0;
        While doserror=0 Do Begin
          inc(cnt);
          If Not break Then displayfile(ffinfo);
          findnext(ffinfo)
        End;
        WriteLn(^B^M^P'Total files '^O'- '^R'('^S+strr(cnt)+^R')')
      End;
      Write(^P'Free Space'^O': ');
      writefreespace(tpath)
    End;

  Procedure AddResidentFile(fname:lstr);
  Var UD    : UDRec;
      Two,
      Times : Lstr;
      X,IC,I:integer;
      Okay  : Boolean;
  Begin
    GetPathName(FName,UD.Path,UD.Filename);
    Two   := UpString(UD.Path);
    Times := 'VISION';

    If (Match('USERS',UD.FileName))
    OR (Match('USERS.',UD.FileName))
    OR (Match('VISION.EXE',ud.filename))
    OR (Match('VISION.OVR',ud.filename))
    OR (Match('CONFIG.BBS',ud.filename))
    Then Begin
      WriteLn(^R'Sorry, that file connect be added!');
      Exit;
    End;
    IF (Pos(Times,Two)>0) AND (Unum <> 1) AND (TempSysop = False)
    Then Begin
      Writeln ('Only User #1 can add V/2 related DIR''S online!');
      Exit;
    End;

    GetFSize(UD);

    If Ud.FileSize = -1 Then Begin
      Write('File could not be opened.  ');
      WriteSTR('Add it as offline anyways? !');
      If YES Then Else EXIT
    End;

    If Cfg.KPerPoint > 0 Then
      INDEX.Points := Round((Ud.FileSize Div cfg.KPerPoint) Div 1000)
      Else INDEX.Points := 0;

    Writestr(^R'Point Value '^R'('^S'CR/'+Strr(INDEX.Points)+^R'): *');

    If Length(inpt)>0
      Then INDEX.Points := Valu(inpt);
    EnterDescrip(UD,UD.FileName);
    INDEX.Crash := False;
    INDEX.Sendto := '';
    INDEX.Password := '';
    INDEX.SentBy := Unam;
    INDEX.SpecialFile := False;
    Repeat
      Buflen := 1;
      WriteStr(^O'S'^P'end to, '^O'P'^P'assword, '^O'U'^P'ploaded By,'+
        ' '^O'R'^P'equest Only, '^O'Z'^P'ibLab, '^O'N'^P'one ['^U'N'^P']'+B_(2)+'*');
      If Inpt='' Then Inpt := 'N';
      Case Upcase(inpt[1]) Of
        'S':Begin
              Writestr(^R'Send to ['^A'CR/Nobody'^R']: &');
              INDEX.SendTo := Inpt;
            End;
        'P':Begin
              Writestr(^R'File Password ['^A'CR/None'^R']: &');
              INDEX.Password := Inpt;
            End;
        'U':Begin
              Writestr(^R'Sent by [CR/'+^A+unam+^R+']: &');
              If Length(inpt)=0 Then Inpt := Unam;
              INDEX.SentBY := Inpt;
            End;
         'R':Begin
               WriteStr('Special Request Only? !');
               INDEX.SpecialFile := Yes;
             End;
         'Z':Begin
               if online then begin
                 if exist('ZIPLAB.BAT') then
                   executewithswap('ZIPLAB.BAT',getfname(ud.path,ud.filename),false);
               end else begin
                 if exist('LOCALZL.BAT') then
                   executewithswap('LOCALZL.BAT',getfname(ud.path,ud.filename),false);
               end;
               ansicls;
             End;
         End;
      Until Upcase(Inpt[1])='N';

      UD.When := Now;
      UD.WhenRated := Now;
      INDEX.Downloaded := 0;
      INDEX.NewFile := False;
      Inc(Status.TotalFiles);
      AddFile(UD);
      WriteLog(16,8,fname)
    End;

    Procedure SysopADD;
    Var FN : Lstr;
        Path,
        Name : Lstr;
    Begin
      If (Urec.Level <= Cfg.SysopLevel) And (TempSYSOP=False)
      Then Begin
        WriteLn ('Only TRUE SysOp''s can add files.');
        Exit
      End;
      Writehdr('Add a Single File');
      Writestr(^R'File to add ('^A'Defualt Path: '^S+UpString(Area.XmodemDIR)+^R'): *');
      GetPathName(Inpt,Path,Name);
      If Path = '' Then
        FN := Area.XmodemDIR + Name
      ELSE
        FN := Path + Name ;
      If (Exist(FN)) and (Not (FN='.') or (FN='..'))
      Then Begin
        DefYES := True;
        WriteSTR(^R'Confirm File: '^S+FN+'? !');
        If YES Then AddResidentFile(FN)
        End
      Else Begin
        WriteHDR('File cannot be opened.');
        Writestr('Still Add File? !');
        If YES Then AddResidentFile(fn);
        End
    End;

    Procedure AddMultipleFiles;
    Label Jump;
    Var SPath,
        PathPart : Lstr;
        TarShit  : Boolean;
        Dummy    : Sstr;
        F        : File;
        FFinfo   : SearchRec;
        N,A      : Integer;
        FArry    : Array [0..999] of SStr;
    Begin
      If Not iSSYSoP Then Begin
        WriteLn('Only TRUE SysOp''s can add files!');
        EXIT;
      End;
      WriteHDR ('Reading in file Names...');
      Seek(UDFile,0);
      For N := 0 to (NumUDS - 1) Do Begin
        Seek (UDFile,n);
        NRead (udfile,ud);
        FArry[N] := UD.FileName;
      End;
      WriteHDR('Add Multiple Files By Wildcard');
      WriteStr(^R'Search Path/Wildcard '^A'('^S'CR/'+UpSTRING(Area.XmodemDIR) + '*.*'^A'): &');
      If Length(Inpt) = 0
        Then Inpt := Area.XmodemDir + '*.*';
      SPath := Inpt;
      If SPath[Length(SPath)] = '\'
        Then Dec(SPath[0]);
      Assign(F,Spath+'\CON');
      Reset(F);
      If IOResult = 0 Then Begin
        Close(f);
        SPath := SPath + '\*.*'
      End;
      GetPathName(SPath,PathPart,Dummy);
      FindFirst(SPath,Dos.Archive,FFInfo);
      If DosERROR <> 0
      Then WriteLn('No files found!')
      Else
        While DosERROR = 0 Do Begin
          A := FFInfo.Attr;
          For N := 0 to (NumUDS - 1) do
            IF (Match(ffinfo.name,farry[n]))
             Then Goto Jump;
          DisplayFile(FFInfo);
          Buflen := 1;
          WriteSTR(^R'Add this file? '^S'Y'^R'es, '^S'N'^R'o, '^S'D'^R'elete, e'^S'X'^R'it: &');
          Tarshit := Yes;
          if Inpt = '' Then TarShit := True;
          If TarShit
            Then AddResidentFile(GetFName(PathPart,FFinfo.Name));
          If Upcase(inpt[1])='D' Then Begin
            WriteStr(^R'Delete '^O+ffinfo.name+^R'? !');
            If Yes Then Begin
              Assign(F,GetFname(PathPart,FFInfo.Name));
              Reset(F);
              Erase(F);
              Close(F);
             End
            End
          Else If (Length(inpt)>0) And (UpCase(inpt[1])='X')
            Then Exit;
          Writeln;
          Jump:
          FindNext(FFInfo)
        End
    End;

Begin
End.