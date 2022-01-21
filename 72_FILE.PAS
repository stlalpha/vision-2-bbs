{$M $5555,0,0}
{$I- V-}

Program FileFix;

Uses Dos, Crt, GenTypes, ConfigRt, General;

Type OldUDRec = Record
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
  AFile   : File of AreaRec;
  IFile   : File of UDIndexREC;
  Area    : AreaRec;
  Old     : OldUDRec;
  New     : UDRec;
  Index   : UDIndexREC;
  X,Y     : Byte;

  Procedure Convert_Area(Which,Conf : Byte);
  Var F : File;
      X : WORD;
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
      FillChar(Index,SizeOf(Index),0);
      New.Filename      := Old.Filename;
      New.Path          := Old.Path;
      Index.Password    := Old.Password;
      Index.SentBy      := Old.SentBy;
      Index.SendTo      := Old.SendTo;
      New.When          := Old.When;
      New.WhenRated     := Old.WhenRated;
      Index.Points      := Old.Points;
      New.FileSize      := Old.FileSize;
      Index.Descrip     := Old.Descrip;
      Index.Downloaded  := Old.Downloaded;
      Index.Crash       := Old.Crash;
      Index.Return      := Old.Return;
      Index.SpecialFile := Old.SpecialFile;
      Index.NewFile     := Old.NewFile;
      NEW.INDEXPTR      := FILESIZE(IFile);
      Write(NewFile,New);
      Write(IFile,Index);
    End;
    Close(NewFile);
    Close(OldFile);
    Erase(OldFile);
    I := IoRESULT;
  End;

Var I : Word;
Begin
  ClrScr;
  ReadCfg;
  TextAttr := 9;
  Writeln('ViSiON/2 File Area Convertor - CONVERTS OLD 10 LINE VERSION TO NEW FORMAT!');
  Writeln('If you do not have ten line descriptions run FILEFIX.EXE FIRST.');
  Write('Hit Enter to Continue or Ctrl-Break Now: ');
  Readln;

  X := 1;
  Repeat
    If Exist(Cfg.DataDir + 'AREADIR.'+Strr(X))
    Then Begin
      Assign(IFile,Cfg.DataDir + 'AREAINDX.'+STRR(X));
      REWRITE(IFILE);
      Assign(AFile,Cfg.DataDir + 'AREADIR.'+Strr(X));
      RESET(AFILE);
      For Y := 1 to FileSize(AFile)
      Do Begin
        Seek(AFile,Y-1);
        Read(AFile,Area);
        Convert_Area(Y,X);
      End;
      Close(AFile);
      Close(IFile);
    End;
    Inc(X);
  Until (X > 20);

  ClrScr;
  Writeln;
  Writeln('All Done.');
End.