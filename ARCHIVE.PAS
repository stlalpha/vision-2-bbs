{$R-,S-,I-,D-,F+,V-,B-,N-,L+,O+}

Unit Archive;

Interface

Uses GenTypes; 

Procedure TypeFile(FN : Lstr);
Procedure ViewArchive(FName:Sstr; ArcPath:Lstr);

Implementation

Uses Dos,Crt,MDosIo,DosMem,MNET,ConfigRt,Gensubs,Modem,Subs1,Subs2;

Procedure TypeFile(FN : Lstr);
Type BufArray = Array[1..$3000] Of Char;
Var Buf : ^BufArray;
    Fd : File;
    C,K : Char;
    BufPos : Integer;
    EndBuf : Word;

    Procedure CheckBuf;
    Begin
      If BufPos > EndBuf Then Begin
        BufPos := 1;
        NBLockRead(FD,Buf^,$3000,EndBuf);
        If Buf^[EndBuf] = #26
        Then Begin
          Buf^[EndBuf] := #0;
          Dec(EndBuf);
        End
      End
    End;

Begin
  Assign(FD,FN);
  Reset(FD,1);
  If IoResult <> 0 then Begin
    Close(FD);
    Exit;
  End;
  DefYes := True;
  WriteStr(^R'Do you want screen pauses? !');
  If Yes Then
    Begin
      CheckPageLength := True;
      Force_Pause := True;
      Non_Stop    := False;
      LineCount   := 1;
    End;
  EndBuf := 0;
  BufPos := 1;
  Dos_GetMem(Buf,$3000);
  CheckBuf;
  Repeat
    C := Buf^[BufPos];
    Write(c);
    Inc(BufPos);
    CheckBuf;
  Until (EndBuf = 0) or (HungUpOn) or (Break);
  CheckPageLength := False;
  Force_Pause := False;
  Close(Fd);
  Dos_FreeMem(Buf);
  Writeln(^M);
  CurAttrib := 0;
End;


Procedure ViewArchive(FName:Sstr; ArcPath:Lstr);

Type
    ArcRec = Record
      FileName:String[30];
      Length,
      Size : Longint;
      Ratio: Real;
      When : Longint;
    End;

    AlotOfNames = Array[1..255] of ArcRec;

Var
    Names       : ^AlotOfNames;
    TotalFiles,
    StartLine,
    EndLine     : Integer;
    TempFile,
    ArcName     : Lstr;


  Function ZIPVIEW : Byte;

   Const
     SIG = $04034B50;                  { Signature }

   Type
     ZFHeader = Record                 { Zip File Header }
       Signature  : LongInt;
       Version,
       GPBFlag,
       Compress   : Word;
       When       : Longint;
       CRC32,
       CSize,
       USize      : LongInt;
       FNameLen,
       ExtraField : Word;
     End;

   Var
     Z       : Integer;
     Hdr     : ZFHeader;
     F       : File;
     S       : String;
     Where   : Longint;
     O       : Word;

  Begin
     ZipVIEW := 0;
     Z := 0;
     Assign(F,ArcName);
     Reset(F,1);
     If IOResult <> 0 Then Begin
       ZipVIEW := 1;
       Close(F);
       Exit;
     End;
     Dos_GetMem(Names,SizeOf(Names^));
     Repeat
       FillChar(S,SizeOf(S), #0);              { Pad with nulls }
       NBlockRead(F,Hdr,SizeOf(ZFHeader),O);     { Read File Header }
       NBlockRead(F,Mem[Seg(S) : Ofs(S) + 1], Hdr.FNameLen,O);
       S [0] := Chr(Hdr.FNameLen);
       If (Hdr.Signature = Sig) And (Z < 255) Then  { Is a header }
       Begin
         Inc(Z);
         Names^[Z].FileName := S;
         Names^[Z].Length   := Hdr.USize;
         Names^[Z].Size     := Hdr.CSize;
         If (Hdr.CSize > 0) And (Hdr.USize > 0)
           Then Names^[Z].Ratio := 100 - Hdr.CSize / Hdr.USize * 100
           Else Names^[Z].Ratio := 0;
         Names^[Z].When := Hdr.When;
       End;
       Where := FilePos(F) + Hdr.CSize + Hdr.ExtraField;
{       If (Where < 0) OR (HDR.CSize < 1) OR (HDR.ExtraField < 1)
         THEN BEGIN
           Close(F);
           Dos_FreeMem(Names);
           ZipVIEW := 1;
           Exit;
         END; }
       Seek(F,Where);
     Until Hdr.Signature <> SIG;                 { No more files }
     TotalFiles := Z;
     Close(F);
  End;
  (*

  FUNCTION ARJVIEW : BYTE;

    Type
       AFHeader = Record  { ArjFileHeader }
         HeadID,
         HdrSize : Word;
         HeadSize,VerNum,MinVerNum,HostOS,ArjFlag,Method,Ftype,Reserved : Byte;
         FileTime,PackSize,OrigSize,FileCRC : LongInt;
         FilePosF,FileAcc,HostData : Word;
       End;

  VAR FHDR : AFHeader;
      F    : FILE;
      Z,NR : INTEGER;
      S    : String;
      SL   : LongINT;
      B    : BYTE;
  BEGIN
     ARJVIEW := 0;
     Z := -1;
     Assign(F,ArcName);
     Reset(F,1);
     If IOResult <> 0 Then Begin
       ARJVIEW := 1;
       Close(F);
       Exit;
     End;
     Dos_GetMem(Names,SizeOf(Names^));
     SL := 0;
     REPEAT
       Seek(F,SL);
       S := '';
       NBlockRead(F,FHdr,SizeOf(AFHeader),NR);     { Read the header }
       If (NR = SizeOf(AFHeader)) Then
       BEGIN
         S := '';
         Repeat
           NBlockRead(F,B,1);              { Get Char for Compressed Filename }
           If B <> 0 Then S:=S+CHR(B);    { Put char in string }
         Until B = 0;                     { Until no more chars }
         Inc(Z);
         IF Z > 0 THEN BEGIN
           Names^[Z].FileName := S;
           Names^[Z].Length   := FHdr.OrigSize;
           Names^[Z].Size     := FHdr.PackSize;
           If (FHdr.OrigSize > 0) And (FHdr.PackSize > 0)
             Then Names^[Z].Ratio := 100 - FHdr.PackSize / FHdr.OrigSize * 100
             Else Names^[Z].Ratio := 0;
           Names^[Z].When := FHdr.FileTime;
         END
       END;
       Repeat
         NBlockRead(F,B,1);
       Until (B = 0) Or (Eof(F));
       NBlockRead(F,FHdr.FileCRC,4);        { Go past File CRC }
       NBlockRead(F,NR,2);
       If FHdr.PackSize < 1 THEN BEGIN
         Dos_FreeMem(Names);
         ARJVIEW := 1;
         Close(F);
         Exit;
       END;
       SL := FilePos(F) + FHdr.PackSize;   { Where are we in file? }
     UNTIL (FHDR.HDRSIZE = 0) OR (Z>254);
     TotalFiles := Z;
     CLOSE(F);
  END;

  *)

  FUNCTION ARJVIEW : BYTE;

  Const BSize = 4096;

  Type ARJHead = record
                   FHeadSize : Byte;
                   ArcVer1,
                   ArcVer2   : Byte;
                   HostOS,
                   ARJFlags,
                   Method    : Byte; {MethodType = (Stored, LZMost, LZFast);}
                   R1,R2     : Byte;
                   DOS_DT    : LongInt;
                   CompSize,
                   UCompSize,
                   CRC       : LongInt;
                   ENP, FM,
                   HostData  : Word;
                 end;

  Var ARJ1     : ARJHead;
      ARJId    : Word;            { 60000, if ARJ file}
      HSize    : Word;            { Header Size}
      F        : FILE;
      Z,O      : WORD;
      Buff     : Array[1..BSize] Of Byte;
      SName    : String;
      C,FSize  : Longint;
      I        : Integer;

  procedure GET_ARJ_ENTRY;
  BEGIN
  REPEAT
    FillChar(ARJ1,SizeOf(ARJHead),#0);
    FillChar(BUFF,BSize,#0);
    Seek (F,C-1);
    NBlockRead(F,BUFF,BSIZE,O);     { read header into buffer}
    Move (BUFF[1],ARJId,2);
    Move (BUFF[3],HSize,2);
    if HSize <= 0 THEN Inc(C)
      ELSE
      With ARJ1 do
        BEGIN
          Move (BUFF[5],ARJ1,SizeOf(ARJHead));
          I := FHeadSize+5; SNAME := ''; {B40;}
          While BUFF[I] > 0 do Inc (I);
          I := I-FHeadSize-5;
          Move (BUFF[FHeadSize+5],SNAME[1],I);
          SNAME[0] := Chr(I);
          FSize    := CompSize;
          Inc (C,HSIZE);
        END;
  UNTIL (HSize > 0) Or (Eof(F));
  END;  { GET_ARJ_ENTRY }

  BEGIN
    Assign (F,ArcName);
    Reset (F,1);
    If IoResult <> 0 Then Begin
      ArjView := 1;
      Close(F);
      Exit;
    End;
    C := 1;
    ARJVIEW := 0;
    Dos_GetMem(Names,SizeOf(Names^));
    GET_ARJ_ENTRY;                       { Process fileHeader }
    Z := 0;
    REPEAT
      Inc(C,FSize+10);
      GET_ARJ_ENTRY;
      if HSize > 0 then
        BEGIN
          Inc (Z);
          Names^[z].FileName := SName;
          Names^[z].Length   := Arj1.UCompSize;
          Names^[z].Size     := Arj1.CompSize;
          If (Arj1.UCompSize > 0) And (Arj1.CompSize > 0)
            Then Names^[z].Ratio := 100 - Arj1.CompSize / Arj1.UCompSize * 100
            Else Names^[z].Ratio := 0;
          Names^[z].When := Arj1.Dos_DT;
        END;
    UNTIL (HSize <= 0) OR (Z>253);
    TotalFiles := Z;
    Close (F);
  end;  { DO_ARJ }

  FUNCTION LHAVIEW : BYTE;
  TYPE
    Fileheadertype = Record                     { LZH file header }
      Headsize,Headchk : byte;
      HeadID : packed array[1..5] of char;
      Packsize,Origsize,Filetime : longint;
      Attr : word;
      filename : String[12];
      f32 : PathStr;
      dt : DateTime;
    End;


  VAR F  : FILE;
      FH : FileHeaderType;
      FHA : ARRAY[1..SizeOf(FileHeaderType)] Of BYTE ABSOLUTE FH;
      OldFilePos : LongINT;
      I,O  : WORD;
      Z  : BYTE;

      Function Mksum : byte;  {calculate check sum for file header }
      VAR
        i : integer;
        b : byte;
      BEGIN
        b := 0;
        for i := 3 to fh.headsize+2 do
          b := b+fha[i];
        mksum := b;
      END;

  BEGIN
     LHAVIEW := 0;
     Z := 0;
     OldFilePos := 0;
     Assign(F,ArcName);
     Reset(F,1);
     If IOResult <> 0 Then Begin
       LHAVIEW := 1;
       Close(F);
       Exit;
     End;
     Dos_GetMem(Names,SizeOf(Names^));
     REPEAT
       Seek(F,oldfilepos);
       NBlockread(F,FHA,Sizeof(FileHeaderType),O);
       Oldfilepos := oldfilepos+fh.headsize+2+fh.packsize;
       I := Mksum; { Get the checksum }
       IF Fh.HeadSize <> 0 Then
         BEGIN
           Inc(Z);
           if i <> fh.headchk then
             Begin
               Writeln('Error in file. Unable to read. Aborting...');
               Close(F);
               Dos_FreeMem(Names);
               LHAVIEW := 1;
               Exit;
             End;
           Names^[Z].FileName := FH.FileName;
           Names^[Z].Length   := FH.OrigSize;
           Names^[Z].Size     := FH.PackSize;
           If (FH.OrigSize > 0) And (FH.PackSize > 0)
             Then Names^[Z].Ratio := 100 - FH.PackSize / FH.OrigSize * 100
             Else Names^[Z].Ratio := 0;
           Names^[Z].When := FH.FileTime;
         END;
     UNTIL (FH.HeadSize=0) OR (Z>254);
     TotalFiles := Z;
     Close(F);
  END;

  Function RealFileName(fname:lstr):Sstr;
  Var _Name: NameStr;
      _Ext : ExtStr ;
      Path : Lstr;
      Name : Sstr;
      X    : Byte;
  Begin
    If Pos('/',Fname) <= 0
    Then Begin
      RealFileName := FName;
      Exit;
    End;
    For X:=1 to Length(FName) Do
      If FName[X] = '/' Then Fname[X] := '\';
    FSplit(FName,Path,_Name,_Ext);
    Name := _Name + _Ext ;
    RealFilename := Name;
  End;

  Procedure LookAtFiles;
  Var B,
      TotalPages,
      Page,
      TotalTag,
      Track : Byte;
      K     : Char;
      Pick  : Set Of Byte;
      Temp  : Integer;
      Last  : Array[1..15] of Integer;

      Procedure SetUpScreen;
      Var X : Byte;
      Begin
        NoBreak := True;
        Write(Direct,#27 + '[2J');
        Write(^R'Viewing File'^O': '^S);
        Tab(FName,15);
        Write(^R' Page'^O': '^S'1 of '+Strr(TotalPages)+'    ');
        Writeln(^R' Total Files'^O': '^S+Strr(TotalFiles));
        Write(^U'Cost for each extracted file'^A': '^S);
        If Cfg.ExtractCost<1
          Then Write('Free')
          Else Write(Strr(Cfg.ExtractCost)+'  ');
        Writeln(^R'     ['^A'-'^R'] PageUp ['^A'+'^R'] PageDn');
        Writeln(^R'Commands'^O': '^R'['^S'E'^R']xit ['^S'Space'^R'] Tags File'+
                 +' ['^S'R'^R']ead Text File ['^S'Q'^R']uit and Compress');
        Write(^O'ÍÍÍÍ['^Z'Zip Size  Real Size  %   Date      Time     Filename                  '^O']');
        Write('ÍÍÍÍ');
      End;

     Procedure Tabul (N : AnyStr; NP : Integer);
     Var Cnt : Integer;
     Begin
       AnsiColor(Urec.Color3);
       Write (Direct,n);
       AnsiColor(Urec.Color5);
       For Cnt := Length(n) To NP - 1
         Do Write ('ú');
    End;

      Procedure PlaceX(Remove:Boolean);
      Begin
        GoXy(2,Track+4);
        If Remove Then Begin
          Ansicolor(Urec.Color5);
          Write('ú')
        End Else Begin
          AnsiColor(Urec.Color6);
          Write('X');
        End;
      End;

      Function Actual : Integer;
      Begin
        Actual:=Track + ((Page-1) * 18);
      End;

      Procedure DisplayFiles;
      Var R,
          Y : Byte;
          Temp : Integer;
      Begin
        Y := 6;
        Temp := Last[Page];
        GoXy(1,5);
        For R := ((Page-1) * 18) + 1 to Temp Do Begin
          Write(^O'³ú³ ');
          If R in Pick
            Then Write(^A+'û')
            Else Write(' ');
          Tabul(Strlong(Names^[R].Size),10);
          Tabul(Strlong(Names^[R].Length),10);
          Tabul(Streal(Names^[R].Ratio),5);
          Tabul(DateStr(Names^[R].When),10);
          Tabul(TimeStr(Names^[R].When),10);
          Tabul(Names^[R].Filename,28);
          Writeln;
        End;
      End;

      Procedure ViewFile;
      Label Abort;
      Var Kill:File;
          Line:String;
      Begin
        If Pos('.ZIP',UpString(FName))>0 Then Begin
          GoXy(1,23);
          Write(^R'Demon Tasker'^A': '^S'Removing '^U+RealFileName(Names^[Actual].Filename)+
           +^S' for your viewing pleasure.');

          ExecuteWithSwap('PKUNZIP.EXE',' -o '+ArcName+' '+Names^[Actual].Filename+
                          +' '+Cfg.UploadDir+' > NUL',False);
        End;
        If Exist(Cfg.UploadDir+RealFileName(Names^[Actual].Filename)) Then Begin
          GoXy(1,23);
          Write(Direct,#27+'[K');
          AnsiColor(Urec.Color1);
          Write(Direct,#27+'[2J');
          TypeFile(Cfg.UploadDir + RealFileName(Names^[Actual].Filename));
          Assign(Kill,Cfg.UploadDir + RealFileName(Names^[Actual].Filename));
          Erase(Kill);
          Close(Kill);
          HoldScreen;
          Write(Direct,#27+'[2J');
          SetUpScreen;
          DisplayFiles;
          PlaceX(False);
        End
      End;

      Procedure ClearFiles;
      Var Y:Byte;
      Begin
        For Y := 22 DownTo 6 Do Begin
          GoXy(1,y);
          Write(Direct,#27+'[K');
        End
      End;

      Function HowManyPages : Byte;
      Var I,Total:Integer;
          S:Sstr;
      Begin
        Total:=1;
        FillChar(Last,SizeOf(Last),0);
        For I := 1 To TotalFiles Do Begin
          If (I Mod 18 = 0) Then Begin
            Last[Total] := I;
            Inc(Total);
          End
        End;
        If Last[Total]=0 Then
          Last[Total]:=TotalFiles;
        S := Strr(Total);
        HowManyPages := Valu(S);
      End;

      Procedure WritePage;
      Begin
        GoXy(37,1);
        AnsiColor(Urec.Color2);
        Write(Strr(Page) + ' of '+Strr(TotalPages) + #32);
      End;

      Procedure Message(M:Lstr);
      Begin
        GoXy(1,23);
        Write(Direct,#27+'[K');
        Write(M);
      End;

      Procedure PackFiles;
      Var X:Byte;
          Total:Integer;
          A,B:Lstr;
          T:Text;
          F:File;
          W:Word;

       Procedure DeleteFiles;
       VAR Index:SearchRec;
           Str:Lstr;
           F:File;
       Begin
         Str := Cfg.ExtractDir+'*.*';
         FindFirst(Str,$17,Index);
         If DosError<>0 Then Exit;
         While DosError=0 Do Begin
           If  (Index.Name <> 'EXTRACT.ZIP')
           Then Begin
             Assign(F,Cfg.ExtractDir+Index.Name);
             Erase(F);
             Close(F);
           End;
           FindNext(Index);
         End;
       End;

      Begin
        If TotalTag < 1
          Then Exit;
        If Pos('.ZIP',UpString(FName)) = 0
          Then Exit;
        Total:=0;
        GoXy(1,23);
        If Cfg.ExtractCost > 0
        Then Begin
          Total:=Cfg.ExtractCost * TotalTag;
          WriteStr('Extracting '+Strr(TotalTag)+' file(s) will cost '+
            +Strr(Total)+' points, continue? !');
          If Not Yes Then Exit;
        End Else Begin
          WriteStr(^R'Do you wish to extract marked file(s)? !');
          If Not Yes
            Then Exit;
        End;
        DeleteFiles;
        A := Cfg.VisionDir;
        B := Cfg.ExtractDir;
        If A[Length(A)] = '\' Then A [0] := Pred(A[0]);
        If B[Length(B)] = '\' Then B [0] := Pred(B[0]);
        Assign(T,Cfg.ExtractDir+'FILELIST.TXT');
        Rewrite(T);
        For X:=1 to TotalFiles Do Begin
          If X in Pick Then
            Writeln(T,Names^[x].Filename);
        End;

        TextClose(T);

        Dos_FreeMem(Names);
        TotalFiles := -1;

        Message(^A'Extracting selected file(s)... One Moment..');
        ChDir(B);

        ExecuteWithSwap('PKUNZIP.EXE','-o '+ArcName + #32 + '@FILELIST.TXT',False);

        Message(^P'Creating '^S'EXTRACT.ZIP'^P'... Please wait..');
        ChDir(B);

        ExecuteWithSwap('PKZIP.EXE','EXTRACT.ZIP *.*',False);

        Message(^A'Performing File Maintenance...');
        DeleteFiles;

        ChDir(A);

        If Total>0 Then Begin
          GoXy(1,23);
          Write(Direct,#27+'[K');
          Write(^S'This extraction cost you '^R+Strr(Total)+^S' point(s)!');
          Urec.UDpoints := Urec.UdPoints - Total;
        End;

      End;

  Begin
    B := 255;

    If Pos('.ZIP',UpString(FName)) > 0
      Then B := ZIPView ELSE
    If Pos('.ARJ',UpSTRING(FName)) > 0
      Then B := ARJView ELSE
    If (POS('.LHA',UpString(FName))>0) OR (POS('.LZH',UpString(FName))>0)
      Then B := LHAView;

    If B > 0
      Then Exit;

    TotalPages := HowManyPages;
    Track := 1;
    Page := 1;
    Pick := [];
    TotalTag := 0;
    SetUpScreen;
    DisplayFiles;
    PlaceX(False);

    Repeat
      K := Upcase(ArrowKey(False));
      Case Upcase(K) Of
        'R' : ViewFile;
        #32 : Begin
                If Actual In Pick Then Begin
                  Dec(TotalTag);
                  Pick:=Pick-[Actual];
                  Write(Direct,#27+'[2C');
                  Write(' ');
                  Write(Direct,#27+'[3D');
              End Else
                If TotalTag * Cfg.ExtractCost <= Urec.UDPoints Then Begin
                  Inc(TotalTag);
                  Pick:=Pick+[Actual];
                  Write(Direct,#27+'[2C');
                  Write(^S'û');
                  Write(Direct,#27+'[3D');
                End
              End;
        ^R,'9','-':If Page>1 Then Begin
          Dec(Page);
          ClearFiles;
          WritePage;
          DisplayFiles;
          PlaceX(False);
        End;
        ^C,'3','+':If Page<TotalPages Then Begin
          Inc(Page);
          ClearFiles;
          WritePage;
          If Actual >= Last[Page] Then
            Track:=Last[Page] Mod 18;
          DisplayFiles;
          PlaceX(False);
        End;
        ^X,^B,'B','P','2':Begin
          Temp:=Last[Page] Mod 18;
          If Temp=0
            Then Temp:=18;
          If ((Page<TotalPages) and (Track>17)) Then Begin
            Inc(Page);
            ClearFiles;
            WritePage;
            Track:=1;
            DisplayFiles;
            PlaceX(False);
          End Else
          If (Track<Temp) and (Actual < TotalFiles) Then Begin
            PlaceX(True);
            Inc(Track);
            PlaceX(False);
          End
        End;
        ^E,^A,'A','H','8':Begin
          If ((Page>1) and (Track<2)) Then Begin
            Dec(Page);
            ClearFiles;
            Track:=1;
            WritePage;
            DisplayFiles;
            Track:=18;
            PlaceX(False);
          End Else
          If Track>1 Then Begin
            PlaceX(True);
            Dec(Track);
            PlaceX(False);
          End
        End
      End;
    Until (K in ['Q','E']) or (HungUpOn);
    If K<>'E' Then PackFiles;
    If (TotalFiles > 0) And (Names <> Nil)
      Then Dos_FreeMem(Names);
    Write(Direct,#27+'[2J');
    Writeln;
  End;

Var F : File;
Begin
  Names := NiL;
  ArcName := ArcPath + FName;
  If Not Exist(Arcname) Then Begin
    WriteLn(^R+Fname+' is not found online!');
    Exit;
  End;
  If Dos_Exists(Cfg.ExtractDir + 'EXTRACT.ZIP')
  Then Begin
    Assign(F,Cfg.ExtractDir + 'EXTRACT.ZIP');
    Erase(F);
  End;
  AnsiEditInUse := True;
  LookAtFiles;
  AnsiEditInUse := False;
End;

Begin
End.
