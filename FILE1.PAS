{$R-,S-,I-,D-,F+,V-,B-,N-,L+,O+ }

Unit File1;
                          {/ file area switching routines /}
Interface

Uses GenTypes;

Function PCRatio:Boolean;
Function Allowed_In_Area(N:Byte; CheckPW:Boolean; Where:Arearec) : Boolean;
Procedure SetArea(N:Integer; Showit:Boolean);
Procedure Getarea;
Procedure ScrollForward;
Procedure ScrollBackward;
Function Init_FileXfer(DefArea:Byte) : Boolean;

Var EnterPW : Set of Byte;
    NScan   : NewScanRec;

Implementation

Uses mnet, configrt, gensubs, subs1, flags, windows, file0, subsovr, subs2;

  Function PCRatio:Boolean;
  Var X3 : Integer;
      Temp : Boolean;
  Begin
    PCRatio := False;
    Temp := False;
    If Urec.Pcr = 0
      Then Temp := True
      Else Begin
        X3 := Ratio(Urec.Nbu,Urec.Numon);
        If (X3 >= Urec.Pcr)
          Then Temp := True
          Else Temp := False;
      End;
    If (SponsorON) Or (Ulvl >= Cfg.Exemptlevel)
      Then Temp := True;
    PCRatio := Temp;
  End;

  Function Allowed_In_Area(N:Byte; CheckPW:Boolean; Where:Arearec) : Boolean;
  Var C : Boolean;
  Begin
    C := False;
    C := CheckFlags(Urec.Flags,Where.Flag);
    C := C AND (WHERE.LEVEL<=UREC.UDLEVEL);
    if C Then Begin
      If (Where.password<>'') and (Not (N in EnterPW)) and (CheckPW)
      Then begin
        {Windows.Password('Entering File Area #'+strr(N)+' PW: '+Where.Password+' > ');}
        Sr.C[1] := 'NU'; Sr.S[1] := Strr(N);
        WriteStr(Strng^.Enter_Area_Password);
      {  CloseWindow;
        Bottom; }
        if Match (Where.Password,Inpt)
          Then EnterPw := EnterPW + [N]
        Else C:=False;
      end
    End;
    Allowed_In_Area:=c;
  End;

    Function GetAPath : Lstr;
    Var q,r:Integer;
      f:File;
      b:Boolean;
      p:lstr;
    Begin
      GetAPath := Area.XmodemDIR;
      If ulvl<cfg.sysoplevel Then exit;
      Repeat
        writestr('Upload Path [CR for '+^S+area.xmodemdir+^P+']: &');
        If hungupon Then exit;
        If Length(inpt)=0 Then inpt:=area.xmodemdir;
        p:=inpt;
        If inpt[Length(p)]<>'\' Then p:=p+'\';
        b:=True;
        Assign(f,p+'CON');
        Reset(f);
        q:=IOResult;
        Close(f);
        r:=IOResult;
        If q<>0 Then Begin
          writestr('Path doesn''t exist!  Create it? !');
          b:=yes;
          If b Then Begin
            MkDir(Copy(p,1,Length(p)-1));
            q:=IOResult;
            b:=q=0;
            If b
            Then writeln('Directory created')
            Else writeln('Unable to create directory')
          End
        End
      Until b;
      getapath:=p
    End;

  Procedure ListAreas;
  Var A : Arearec;
      Cnt,OldArea,X : Integer;
      Total : Word;
  Begin

    OldArea := CurArea;
    Total := 0;

    ListingFile(Cfg.TextFileDir + 'FILEAREA.TOP',False);

    For cnt:=1 To numareas Do Begin
      SeekAFile(Cnt);
      nRead(Afile,A);
      If Allowed_In_Area(Cnt,False,A)
      Then begin
        CurArea := Cnt;

        Sr.C[1] := 'NU'; Sr.S[1] := Strr(Cnt); Sr.T[1] := 3;
        Sr.C[2] := 'AN'; If (A.Password<>'') and (Not (CurArea in EnterPW))
                           Then Sr.S[2] := '[ Password Protected ]'
                           Else Sr.S[2] := A.Name; Sr.T[2] := 30;
        Sr.C[3] := 'NF'; Sr.S[3] := Strr(A.TotalUDs); Sr.T[3] := 4;
        Sr.C[4] := 'UL'; Sr.S[4] := YesNo(A.Uploads); Sr.T[4] := 3;
        Sr.C[5] := 'DL'; Sr.S[5] := YesNo(A.Downloads); Sr.T[5] := 3;
        Sr.C[6] := 'NS'; If Cnt IN NScan.FileNewScan
                           Then Sr.S[6] := #32
                           Else Sr.S[6] := 'û'; Sr.T[6] := 1;

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

  Function Makearea : Boolean;
  Var Num,N,Where : Integer;
      A,BackUp : AreaRec;
      F : File;
  Begin
    Makearea := False;
    Num := NumAreas + 1;
    N := NumAreas;
    WriteStr(^R'Create a new File Area? !');

    If Not Yes
      Then Exit;

    FillChar(A,SizeOf(A),0);

    Write(^R'Area name'^A': ');
    InputBox(30);

    If Length(inpt) = 0
      Then Exit;
    A.Name := Inpt;

    Write(^R'Access Flag(s)'^A': ');
    PromptFlag(A.Flag);

    write(^R'Access Level for area'^A': ');
    InputBox(6);
    a.level:=valu(inpt);

    writestr(^R'Upload Here'^O'? !');
    if Inpt = '' Then Inpt := 'Y';
    A.Uploads := YES;

    If A.Uploads
    Then Begin
      Write(^R'Area Upload Flag(s)'^A': ');
      PromptFlag(A.UpFlag);
    End;

    WriteStr(^R'Download here'^O'? !');
    A.Downloads := YES;

    If A.DownLoads then Begin
      Write(^R'Area Download Flag'^A': ');
      Promptflag(A.DownFlag);
    End;

    Write(^R'Entry Password '^R'['^S'Cr/None'^R'] '^A': ');
    InputBox(20);
    If Inpt = 'N'
      Then Inpt := '';
    If Length(inpt) = 0
      Then Inpt := ''
      Else Inpt := UpString(inpt);
    A.Password := Inpt;

    Write(^P'Moderator of this area '^O'['+^S+unam+^O+']'^A': ');
    InputBox(30);
    If Length(inpt) = 0
      Then inpt:=unam;
    A.Sponsor:=inpt;

    DefYes:=False;
    WriteStr(^P'Leech Area? ('^O'Yes/All files free'^P') !');
    a.leech:=yes;

    A.XmodemDir := Getapath;

    Where := 0;

    Repeat
      WriteStr(^R'Insert area where? ['^A'1-'+Strr(Num)+^R'] ['^A'Cr/'+Strr(Num)+^R']: *');
      If Inpt = '?'
        Then ListAreas;
      If Inpt = ''
        Then Where := Num
        Else Where := Valu(Inpt);
      If Where > Num
        Then Where := Num;
      If HungupOn
        Then Where := Num;
    Until (Where > 0) ;

    If Where < Num Then Begin
      BackUp := A;
      For N := Where To Num Do Begin
        SeekAFile(N);
        nRead(AFile,A);
        SeekAFile(N);
        nWrite(AFile,BackUp);
        BackUp := A;
      End;

      For N := Num DownTo Where Do Begin
        Assign(F,Cfg.DataDir + 'AREA' + Strr(N) + '.' + Strr(FileConf));
        Rename(F,Cfg.DataDir + 'AREA' + Strr(N+1) + '.' + Strr(FileConf));
      End;

    End Else Begin
      SeekAFile(Num);
      nWrite(AFile,A);
    End;

    Area := A;
    CurArea := Where;
    AssignUD(True);

    WriteLn('Area created!');
    MakeArea := True;

    WriteLog(15,4,a.name)
  End;

  Procedure SetArea(n:Integer; Showit:boolean);
  Var C : Boolean;
      Temp : Byte;

    Procedure nosucharea;
    Begin
      If showit then
        WriteLn(^B^R'Invalid Area'^A': '^S+Strr(N))
    End;

    Begin
      curarea:=n;
      If (n>numareas) Or (n<1) Then Begin
        nosucharea;
        If issysop
        Then If makearea
          Then setarea(curarea,true)
          Else  setarea(1,true)
        Else setarea(1,true);
      End;
      SeekAFile(n);
      nRead(afile,area);
      If Not(allowed_in_area(N,True,Area))
      Then If curarea=1
        Then error('User can''t access first area','','')
        Else
          Begin
            nosucharea;
            setarea(1,true);
            exit
          End;

     Assignud(True);

     If Area.TotalUDS <> NumUDs then Begin
       Area.TotalUDS := NumUDs;
       SeekAFile(CurArea);
       Write(AFile,Area);
     End;

     If Showit then Begin
       Writeln;
       Sr.C[1]:='CA';
       Sr.S[1]:=Area.Name;
       MultiColor(Strng^.CurfileArea);
       Writeln;
     End;
   End;

  Function getareanum:Integer;
    Var areastr:sstr;
      areanum:Integer;
    Begin
      getareanum:=0;
      If Length(inpt)>1
      Then areastr:=Copy(inpt,2,255)
      Else begin
      listareas;
        Repeat
          Write(^B);
          Writestr(Strng^.ChangeFileAreaStr);
          Writeln;
          If Inpt='?'
            Then Listareas
            Else Areastr:=inpt
        Until (inpt<>'?') Or hungupon;
      end;
      If Length(areastr)=0 Then exit;
      areanum:=valu(areastr);
      If (areanum>0) And (areanum<=numareas)
      Then getareanum:=areanum
      Else Begin
        writeln('(No such area!)');
        If issysop Then If makearea Then getareanum:=numareas
      End
    End;

  Procedure getarea;
  Var AreaNum : Integer;
  Begin
    AreaNum := Getareanum;
    If AreaNum <> 0
      Then SetArea(AreaNum,True)
  End;

  Procedure ScrollForward;
  Var A : Byte;
      Temp : AreaREC;
  Begin
    A := CurAREA;
    Repeat
      Inc(A);
      If A > NumAREAS Then
        Begin
          Writeln('This is the last area.');
          Exit;
        End;
      SeekAFile(A);
      NRead(AFile,Temp);
    Until Allowed_In_Area(A,False,Temp) or (HungUpOn);
    CurArea := A;
    SetArea(A,True);
  End;

  Procedure ScrollBackward;
  Var A : Byte;
      Temp : AreaREC;
  Begin
    A := CurAREA;
    Repeat
      Dec(A);
      If A < 1 Then
        Begin
          Writeln('This is the first area.');
          Exit;
        End;
      SeekAFile(A);
      NRead(AFile,Temp);
    Until Allowed_In_Area(A,False,Temp) or (HungUpOn);
    CurArea := A;
    SetArea(A,True);
  End;

  Function Init_FileXfer(DefArea:Byte) : Boolean;
  Label Okay, NotOkay;
  Var Tzz : Sstr; A:AreaRec; Check : Boolean; i : byte;
  Begin
    Init_FileXfer := TRUE;
    If (FileConf < 1) OR (FileConf > Cfg.MaxFileConf) Then
      FileConf := 1;
    IF LastFileConf <> FileConf
      Then If IsOpen(AFile) Then Begin
        Close(AFile);
        Close(UDFile);
        Close(UDIndex);
      End;
    If IsOpen(AFile) Then EXIT;
    Check:=False;
    for i := 1 to 9 Do
      if urec.filelist[i] then check := true;
    if not check
      then for i := 1 to 5 do urec.filelist[i] := true;
    Close_Them_All(AFile);
    LastFileConf := FileConf;
    UpdateNode('In File Area...');
    GetScanRec(NScan,FileConf);
    If FilesInBatch < 1
      Then Clear_BatchDown;
    Tzz := 'AREAINDX.'+Strr(FileConf);
    Assign(UDIndex,Cfg.DataDir + Tzz);
    If Exist(Cfg.DataDir + Tzz)
    Then
      Reset(UDIndex)
    Else
      Rewrite(UDIndex);
    Tzz := 'AREADIR.'+Strr(FileConf);
    Assign(AFile,Cfg.DataDir + Tzz);
    If Exist(Cfg.DataDir + Tzz)
    Then
      Begin
        Reset(afile);
        If FileSize(afile) > 0 Then GoTo Okay
      End
    Else Rewrite(AFile);
    If (DefArea < 1) Or (DefArea > FileSize(AFile))
      Then DefArea := 1;
    WriteHdr('No File Areas Exist!');
    Area.Xmodemdir := Cfg.ViSiONDir + 'UPLOADS\';
    If IsSysop
      Then If MakeArea
        Then GoTo okay;
      GoTo NotOkay;
    Okay :
      SeekAFile(DefArea);
      nRead(Afile,a);
      If Not(Allowed_in_Area(DefArea,True,A)) Then Begin
        If (DefArea = 1) And (IsSysOp = False)
        Then Begin
          WriteHDR('File access denied.');
          Goto NotOkay;
        End
        Else Begin
          SeekAfile(1);
          nRead(afile,a);
          If Not(allowed_in_area(1,True,A)) Then Begin
            WriteHDR('File access denied.');
            If Not IsSysOp Then
              GoTo NotOkay
        End
      End
   End;
   AssignUD(False);
   SetArea(DefArea,False);
   Exit;

   NotOkay:
     Close(AFile);
     Close(UDIndex);
     Init_FileXfer := FALSE;

  End;

Begin
End.
