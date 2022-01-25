{$R-,S-,I-,D-,F+,V-,B-,N-,L+,O+ }

Unit File0;
                          {/ low level file area routines /}
Interface

Uses GenTypes;

Procedure SeekAFile(n:Integer);
Function NumAreas : Integer;
Procedure SeekUDFile(N : Integer);
Function NumUDS : Integer;
Procedure LoadUDREC(X : Word);
Procedure AssignUD (Close_It:Boolean);
Function SponsorON : Boolean;
Function GetFName(Path : Lstr; Name : Mstr) : Lstr;
Procedure Getpathname(FName : Lstr; Var Path : Lstr; Var Name : Sstr);
Procedure Clear_Batchdown;
Procedure DoDescrip(VAR Descrip : BigDescrip; FileName : SStr);
Procedure AddFile(ud:udrec);

Const CurArea : Byte = 1;
      Def     : Integer = 0;

Var UD    : UDRec;
    Index : UDIndexRec;
    Area  : AreaREC;

Implementation

Uses Dos, Crt, MNET, ConfigRT, GenSubs, StatRet, Windows, Subs1, Subs2;

  Procedure SeekAFile(n:Integer);
  Begin
    Seek(AFile,N - 1)
  End;

  Function NumAreas : Integer;
  Begin
    NumAreas := FileSize(afile)
  End;

  Procedure SeekUDFile(N : Integer);
  Begin
    Seek(UDfile,N - 1)
  End;

  Function NumUDS : Integer;
  Begin
    NumUDs := FileSize(udfile)
  End;

  Procedure LoadUDREC(X : Word);
  Begin
    SeekUDFile(X);
    NRead(UDFile,UD);
    Seek(UDIndex,UD.IndexPTR);
    NRead(UDIndex,Index);
  End;

  Procedure AssignUD (Close_It:Boolean);
  Var M:Mstr;
  Begin
    If IsOpen(UDFile) Then
      Close(UDfile);
    M := Cfg.DataDir + 'AREA' + Strr(CurArea) + '.' + Strr(FileConf);
    Assign(UDFile,M);
    If Exist(M)
      Then Reset(UDFile)
      Else Rewrite(UDFile);
  End;

  Function SponsorON : Boolean;
  Begin
    SponsorON := Match(Area.Sponsor,Unam) OR ISSYSOP;
  End;

  Function GetFName(Path : Lstr; Name : Mstr) : Lstr;
  Var L : Lstr;
  Begin
    L := Path;
    If Length(l)<>0 Then
      If Not(l[Length(l)] In [':','\']) Then
    l := l + '\';
    l := l + name;
    GetFName:=l
  End;

  Procedure Getpathname(FName : Lstr; Var Path : Lstr; Var Name : Sstr);
  Var _Name: NameStr;
      _Ext : ExtStr ;
  Begin
    FSplit(fname,path,_name,_ext);
    Name := _name + _ext ;
  End;

  Procedure Clear_Batchdown;
  Begin
    FilesInBatch := 0;
    FillChar(BatchDown^,SizeOf(BatchDown^),0);
  End;

  Procedure DoDescrip(VAR Descrip : BigDescrip; FileName : SStr);
  Var K : Char;

    Procedure Clr;
    Begin
      Write(#27+'[K');
    End;

  Begin
    AnsiCls;
    Writeln(^R'File Description Of'^A': '^S+FileName+'  '^R'['^A'Q'^R']uits'^M);
    For K := ^A to ^J Do
      Writeln(^R'['^A+Char(Ord(K) + 64)+^R'] : '+Descrip[Ord(K)]);
    Repeat
      GoXy(1,1);
      K := Upcase(WaitForChar(False));
      If K In ['A'..'J'] Then Begin
        GoXy(1,14);
        BeginWithSpacesOk := True;
        WriteLn(^R'Old Description ('^S'Line '+Strr(Ord(K)-64)+^R'): '^S+Descrip[Ord(K)-64]);
        WriteStr(^R'New Description ('^S'Line '+Strr(Ord(K)-64)+^R'): *');
        If Inpt = '' Then Begin
          WriteStr('Set to Null? !');
          If Yes
            Then Descrip[Ord(K) - 64] := '';
        End Else Descrip[Ord(K) - 64] := Inpt;
        BeginWithSpacesOk := False;
        GoXy(1,14);
        Clr; Writeln; Clr; Writeln; Clr;
        GoXy(7,Ord(K) - 62);
        Clr;
        Write(Descrip[Ord(K) - 64]);
      End;
    Until (K = 'Q') or (HungUpOn);
  End;

  Procedure AddFile(ud:udrec);
  Var Lock : Boolean;
  Begin
    UD.IndexPtr := FileSize(UDIndex);
    Lock := LockFile(UDFile,MNLock);
    SeekUDFile(NumUds + 1);
    NWrite(UDFile,UD);
    Lock := LockFile(UDFile,MNUNLock);
    Lock := LockFile(UDIndex,MNLock);
    Seek(UDIndex,FileSize(UDIndex));
    NWrite(UDIndex,Index);
    Lock := LockFile(UDIndex,MNUNLock);
    Inc(Log.ULoads);
  End;

Begin
End.