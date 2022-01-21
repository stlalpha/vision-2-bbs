{$I- V-}

Program FileFix;

Uses Dos, Crt, GenTypes, ConfigRt, General;

Type OldUDRec = Record
       Sentby,
       Password,
       Sendto : Mstr;
       When,
       Whenrated : Longint;
       Group,
       Filename : Sstr;
       Path : String[50];
       Points : Integer;
       Filesize : Longint;
       Descrip : Lstr;
       Downloaded : Integer;
       Crash,
       Newfile,
       Specialfile,
       Return : Boolean
     End;

     BigDescrip = Array[1..10] Of String[48];

     UDRec = record
       Sentby,
       Password,
       Sendto : Mstr;
       When,
       WhenRated : Longint;
       Group,
       Filename : Sstr;
       Path : String[50];
       Points : Integer;
       FileSize : Longint;
       Descrip : BigDescrip;
       DownLoaded : Integer;
       Crash,
       Newfile,
       SpecialFile,
       Return : Boolean
     End;

Var
  OldFile : File Of OldUDRec;
  NewFile : File Of UDRec;
  AFile : File of AreaRec;
  Area : AreaRec;
  Old : OldUDRec;
  New : UDRec;
  Index : SearchRec;
  U : UserRec;
  UFile : File of UserRec;
  X,Y : Byte;

  Procedure Convert_Area(Which,Conf : Byte);
  Var F : File;
      X : Byte;
      I : Word;
  Begin
    Writeln('Converting Area: ',Area.Name);
    If Not Exist(Cfg.DataDir + 'AREA' + Strr(Which) + '.' + Strr(Conf))
      Then Exit;
    Assign(F,Cfg.DataDir + 'AREA'+Strr(Which)+'.'+Strr(Conf));
    Rename(F,Cfg.DataDir + 'TEMP');
    I := IoResult;
    Close(OldFile);
    Assign(OldFile,Cfg.DataDir + 'TEMP');
    Reset(OldFile);
    I := IoResult;
    Assign(Newfile,Cfg.DataDir + 'AREA'+Strr(Which)+'.'+Strr(Conf));
    ReWrite(NewFile);
    I := IoREsult;
    For X := 1 to FileSize(OldFile)
    Do Begin
      Seek(OldFile,X-1);
      Read(OldFile,Old);
      FillChar(New,SizeOf(New),0);
      New.Filename := Old.Filename;
      New.Path := Old.Path;
      New.Password := Old.Password;
      New.SentBy := Old.SentBy;
      New.SendTo := Old.SendTo;
      New.When := Old.When;
      New.WhenRated := Old.WhenRated;
      New.Points := Old.Points;
      New.FileSize := Old.FileSize;
      FillChar(New.Descrip,SizeOf(New.Descrip),0);
      New.Descrip[1] := Old.Descrip;
      New.Downloaded := Old.Downloaded;
      New.Crash := Old.Crash;
      New.Return := Old.Return;
      New.SpecialFile := Old.SpecialFile;
      New.NewFile := Old.NewFile;
      Write(NewFile,New);
    End;
    Close(NewFile);
    Close(OldFile);
    Erase(OldFile);
    I := IoResult;
  End;

Var I : Word;
Begin
  ClrScr;
  ReadCfg;
  TextAttr := 9;
  Writeln('ViSiON/2 File Area Convertor - v69-70A to v70B (Add''s 10 Line Description)');
  Writeln('Only Run This Program ONCE!');
  Write('Hit Enter to Continue or Ctrl-Break Now: ');
  Readln;

  X := 1;
  Repeat
    If Exist(Cfg.DataDir + 'AREADIR.'+Strr(X))
    Then Begin
      Assign(AFile,Cfg.DataDir + 'AREADIR.'+Strr(X));
      Reset(AFile);
      For Y := 1 to FileSize(AFile)
      Do Begin
        Seek(AFile,Y-1);
        Read(AFile,Area);
        Convert_Area(Y,X);
      End;
      Close(AFile);
    End;
    Inc(X);
  Until (X > 20);

  ClrScr;
  Writeln('- Fixing User Configrable File Listings -');
  I := IoResult;
  Assign(UFile,Cfg.DataDir + 'USERS');
  Reset(UFile);
  If IoResult <> 0 Then Begin
    Writeln('Fatal Error: Unable to find USERS.');
    Exit;
  End;
  For X := 1 to ( FileSize(UFile) - 1) Do Begin
    Seek(UFile,X);
    Read(UFile,U);
    Writeln('Updateing: ',U.Handle);
    FillChar(U.FileList,SizeOf(U.FileList),0);
    For Y := 1 to 5
      Do U.FileList[y] := True;
    Seek(UFile,X);
    Write(UFile,U);
  End;
  Close(UFile);
  Writeln;
  Writeln('All Done.');
End.