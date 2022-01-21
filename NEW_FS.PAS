{$R-,S-,I-,D-,F+,V-,B-,N-,L+,O+}

Unit NEW_FS;

Interface

Procedure AddBatch(FN:Integer);
Procedure Delete_ALL;
Procedure Edit_All;
Procedure View_ALL;
Procedure MoveFiles;
Procedure Renamefile(Def:Integer);
Procedure NewFiles;
Procedure ListFiles (Extended,NewScan : Boolean; ScanFrom : Longint);

Implementation

Uses Dos, MNeT, Crt, GenTypes, Configrt, StatRet, GenSubs, Windows,
     Subs1, Flags, Subs2, Mainr1, Userret, Viewer, Overret1, MyComman,
     File0, File1, FileSys0, Archive;


Type FilesList = Record
       FileNum,
       SpacesDown,
       Where : Integer;
     End;

Const Redraw = 'REDRAW!';

VAR Files        : Array[1..20] of FilesLIST;
    InList       : Boolean;

Procedure GetFileNum(Prompt : Lstr;
                     T      : Mstr;
                     VAR F,L: Integer); Forward;


Function InBatch(Fn:Sstr):Boolean;
Var i:Byte;
Begin
  InBatch:=False;
  If FilesInBatch<1 then Exit;
  For i:=1 to FilesInBatch Do
    If Match(Fn,BatchDown^[i].Filename) Then Begin
      InBatch:=True;
      Exit;
    End;
End;

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

    Procedure Clr;
    Begin
      Write(#27+'[K');
    End;

  Procedure ChangeF(Which:Integer);
  Var N,Q,Cnt : Integer;
      K       : Char;
      Done    : Boolean;
      S,F     : Integer;

    Procedure ShowUDRec;
    Begin
      With UD Do Begin
        AnsiCLS;
        Writeln(^R'File Change '^O'['^P+UpString(ud.filename)+^O'] '^P'Received'^O': '^S+Datestr(when)+' / '+timestr(now));
        Writeln(^M^R'Change Which? [ ]   '^R'['^A'Q'^R']uits'^M);
        Writeln(^O'['^P'A'^O'] Filename'^R'....: '^S+upstring(ud.filename));
        Writeln(^O'['^P'B'^O'] Subdir Path'^R'.: '^S+ud.path);
        Writeln(^O'['^P'C'^O'] Bytes long'^R'..: '^S+strlong(ud.filesize));
        Writeln(^O'['^P'D'^O'] Description'^R' : '^S+'Edit Ten Line Description');
        Writeln(^O'['^P'E'^O'] Point Value'^R'.: '^S+Strr(INDEX.Points));
        Writeln(^O'['^P'F'^O'] Times DL''d'^R'..: '^S+strr(INDEX.downloaded));
        Writeln(^O'['^P'G'^O'] Password'^R'....: '^S+INDEX.password);
        Writeln(^O'['^P'H'^O'] Sending to'^R'..: '^S+INDEX.sendto);
        Writeln(^O'['^P'I'^O'] Uploaded by'^R'.: '^S+INDEX.sentby);
        Writeln(^O'['^P'J'^O'] New File'^R'....: '^S+YesNo(INDEX.NewFile));
        Writeln(^O'['^P'K'^O'] Special File'^R': '^S+YesNo(INDEX.SpecialFile));
      End
    End;

    Begin
      F := Which;
      S := Which;
      If Which < 1
        Then GetFileNum('|C1Filename/# to Edit (|C3Cr/|DE|C1): ','',S,F)
        Else S := Which;
      Done:=False;
      If S = 0 Then exit;
      For CNT := S to F Do Begin
        LoadUDREC(CNT);
        Writelog(16,4,ud.filename);
        ShowUDRec;
        Repeat
          Goxy(16,3);
          K := Upcase(WaitForChar(true));
          GoXy(1,18);
          Case K Of

            'A':If Ulvl >= Cfg.SysopLevel Then Begin
                  Getstring('Filename',ud.filename);
                  GoXy(19,5); Clr;
                  Write(^S+ud.filename);
                End;

            'B':If Ulvl >= Cfg.SysopLevel then Begin
                  GetString('Path',ud.path);
                  GoXy(19,6); Clr;
                  Write(^S+ud.path);
                End;

            'C':Begin
                  Writestr('Change File to OFFLINE? !');
                  If Yes Then Begin
                    ud.filesize:=-1;
                    GoXy(19,7); clr;Write('Offline');
                  end
                  else
                    GetFSize(ud);
                  If UD.FileSize = -1
                    Then Writeln('Notice! This file is OFFLINE!');
                End;

            'D':Begin
                  DoDescrip(Index.Descrip,UD.FileName);
                  ShowUDRec;
                End;

            'E':Begin
                 Getint('Point Value',INDEX.points);
                 GoXy(19,9); Clr;
                 Write(^S+strr(INDEX.points));
                End;

            'F':Begin
                 Getint('Times Downloaded',INDEX.downloaded);
                 GoXy(19,10); clr; Write(^S+strr(INDEX.downloaded));
                End;

            'G':Begin
                 Getstring('Password (N/None)',INDEX.password);
                 If Match(INDEX.password,'N') then INDEX.password:='';
                 goXy(19,11); clr; Write(^S+INDEX.password);
                End;

            'H':Begin
                 Getstring('Send to (N/None)',INDEX.sendto);
                 If match(INDEX.sendto,'N') then INDEX.sendto:='';
                 GoXy(19,12); clr; Write(^S+INDEX.sendto);
                End;

            'I':Begin
                 getstring('Uploader',INDEX.sentby);
                 GoXy(19,13); clr; Write(^S+INDEX.sentby);
                End;

            'J':Begin
                  Getboo('New File (unrated)',INDEX.newfile);
                  If Index.NewFile
                    Then UD.WhenRated := 0;
                  GoXy(19,14); Clr;
                  Write(^S+YesNo(INDEX.newfile));
                End;

            'K':Begin
                 GetBoo('Special Request only',INDEX.specialfile);
                 GoXy(19,15); Clr;
                 Write(^S+YesNo(INDEX.Specialfile));
                End;

            'Q':Done:=True;
          End;
          GoXy(1,18);
          Clr; Writeln; Clr;
        Until (Done) or Hungupon;
        WriteStr(^R'Save all changes to disk? ('^S'Y,n,x'^R'): &');
        AnsiCls;
        If Upcase(Inpt[1])='X' Then Exit;
        If (YES) OR (INPT='') Then Begin
          SeekUDFile(CNT);
          NWrite(UDFile,ud);
          Seek(UDIndex,UD.IndexPtr);
          NWrite(UDIndex,Index);
        End;
      End;
    End;

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

  Procedure Listfile(N : Integer; Extended : Boolean);
  Var Q      : Sstr;
      Path,
      Filez  : AnyStr;
      _Name  : Namestr;
      _Ext   : Extstr;
      Sze    : Longint;
      Ofline : Boolean;
      Total,
      All    : Byte;
  Begin
    NoBreak:=True;
    LoadUDRec(N);

      Filez := GetFName(Ud.Path,Ud.Filename);

      FSplit(ud.filename,path,_name,_ext);

      Write(^R);

      Tab(strr(N),3);

      Total := 4;

      If InBatch(Ud.FileName)
        Then Write('û')
        Else Write(' ');

      Path := Upcase(_Name[1]);
      _Name[1] := Path[1];

      If Urec.FileList[1] or (Extended) Then Begin
        Write(^P);
        Tab(upstring(_Name),8);
        Inc(Total,8);
      End;

      If Urec.Filelist[2] or (Extended) Then Begin
        Write(^O);
        Tab (Upstring(_Ext),5);
        Inc(Total,5);
      End;

      If Urec.FileList[3] or (extended) Then Begin
        Write(^S);
        Inc(Total,6);
        If (Index.SendTo = '') then
          If Index.NewFile
            Then Write(' New  ')
            Else If Index.Specialfile
              Then Write(' Ask  ')
              Else If (Index.Points>0) and (Not Area.Leech)
                Then Write(Index.Points:4,'  ')
                Else Write(' Free ')
        Else Begin
          Ansicolor(4);
          If Match(Index.Sendto,Urec.Handle)
            Then Write(' Take ')
            Else Write(' Priv ');
        End
      End;

      If Urec.FileList[4] And Not (Extended) Then Begin
         Write(^A);
         Inc(Total,7);
         If Ud.FileSize = -1
           Then Write('  ---- ')
           Else If Index.Crash
             Then Begin
               Ansicolor(4);
               Write(' Crash ');
             End Else
           Begin
             Sze := Ud.Filesize;
             If Sze < 1024
               Then Write(strr(sze)+'B':6,' ')
               Else Write(strlong(sze div 1024)+'K':6,' ');
           End
      End;

      If Urec.Filelist[6] or (Extended) then Begin
        Write(^P);
        Tab(DateStr(ud.when),10);
        Inc(Total,10);
      End;

      If Urec.filelist[7] or (Extended) then Begin
        Write(^P);
        Tab(strlong(Index.Downloaded),4);
        Inc(Total,4);
      End;

      If Urec.FileList[8] or (Extended) then Begin
        Write(^A);
        Tab(Copy(Index.Sentby,1,20),20);
        Inc(Total,20);
      End;

      If Urec.FileList[5] And Not (Extended) then Begin
        Write(^U);
        If (Index.Descrip[1] = '') And (Total_Lines(Index.Descrip) < 2)
          Then Index.Descrip[1] := 'No Description';
        Write(#32 + Index.Descrip[1]);
        For All := 2 To Total_Lines(Index.Descrip)
        Do Begin
          Writeln(Direct);
          Write(Direct,#27 + '['+Strr(Total)+'C');
          Write(Direct,#32 + Index.Descrip[All]);
        End;
      End;

     WriteLn;
     NoBreak:=False;
  End;

  Function NoFiles : Boolean;
  Begin
    If NumUDs = 0 Then Begin
      NoFiles:=True;
      Writeln(^M'Sorry, this area is empty!'^M)
    End Else Nofiles := False
  End;

  Procedure Listbatch;
  Var Cnt,A,B : Integer;
      Z : Sstr;
      Tempk,Totk : Longint;
  Begin
    If Filesinbatch<1 Then WriteLn(^S'No files in marked'^G);
    If Filesinbatch<1 Then exit;
    ansicls;
    totk:=0;
    Writehdr('SysOp''s Marked File List');
     Header(' #  File Name        Size      Area #  Uploader          Path ');
      For cnt:=1 To FilesInBatch Do begin
        Write (^P);
        Tab(Strr(Cnt)+':',5);
        WRite(^R);
        Tab(Upstring(BatchDown^[Cnt].FileName),17);
        TempK := BatchDown^[Cnt].Size Div 1024;
        TotK := Totk + TempK;
        Tab(StrLong(BatchDown^[Cnt].Size),10);
        Tab(Strr(BatchDown^[Cnt].Area),9);
        Tab(Copy(BatchDown^[Cnt].By,1,17),17);
        Writeln(Copy(BatchDown^[Cnt].Path,1,25));
        if Break then Exit;
      End;
    writeln(^M^R'Total KiloBytes in Marked List'^A': '^S,totk);
    Writeln;
   End;

  Procedure DoHeader(Extended : Boolean);
  Var S : String[80];
  Begin
    Ansicls;
    S[0] := #0;
    S:='#. ';
    With Urec Do Begin
     If FileList[1] then S:=S+'Name    ';
     If FileList[2] then S:=S+'Ext. ';
     If FileList[3] then S:=S+'Cost    ';
     If FileList[4] then S:=S+'Size  ';
     If FileList[6] then S:=S+'Received ';
     If FileList[7] then S:=S+'DL''d ';
     If FileList[8] then S:=S+'Sent By        ';
     If FileList[5] then S:=S+'Description';
    End;
    If Extended
      Then S := ' #.  Filename    Cost  U/L Date  X DLed   Sent By';
    While S[ Length(S) ] = #32
      Do S[0] := Pred(S[0]);
    Sr.C[1] := 'CF';
    Sr.S[1] := S;
    ListingFile(Cfg.TextFileDir + 'FILETOP.ANS',True);
    CheckPageLength := False;
    If WhereY <> 3
      Then GoXy(1,3);
    NoBreak := False;
    DontStop := False;
  End;

    Procedure RemoveFromBatch(Auto:Byte; FN:Mstr);
    VAR C,Where:Byte;
    Begin
      If FilesInBatch<1 then Exit;
      If (Auto<1) And (FN='') Then Begin
        listbatch;
        WriteStr(^P'Number of File to Remove '^O'['^S'1..'+strr(filesinbatch)+^O']: *');
        If (Valu(inpt)>0) and (Valu(inpt)<=FilesInBatch) Then
          Auto:=Valu(inpt) Else
          Exit;
        FN:=BatchDown^[Auto].filename;
      End;
      Where:=0;
      For C:=1 to FilesInBatch Do
        If Match(FN,BatchDown^[C].filename)
        Then Where:=C;
      If Where>0 then Begin
        If Where<FilesInBatch Then
          For C:=Where to FilesInBatch-1 Do
            BatchDown^[C] := BatchDown^[C + 1];
          FillChar(BatchDown^[FilesInBatch],SizeOf(BatchDown^[FilesInBatch]),0);
          Dec(FilesInBatch);
        End
      End;

  Procedure AddBatch(FN:Integer);
  VAR B:Byte;
      S,E,X : Integer;
  Begin
    If FilesinBatch > 99
      Then Exit;
    S := FN;
    E := FN;
    If S < 1 Then Begin
      GetFileNum('|C1Add to List (|C3Cr/|DE|C1): ','',S,E);
      If S < 1
        Then Exit;
    End;
    For X := S to E Do Begin
      LoadUDRec(X);
      B := FilesInBatch;
      Inc(B);
      FilesInBatch:=B;
      BatchDown^[b].FileName:=Ud.Filename;
      BatchDown^[b].By:=INDEX.Sentby;
      BatchDown^[b].area:=CurArea;
      BatchDown^[b].FileNum:=Fn;
      BatchDown^[b].Size:=Ud.FileSize;
      BatchDown^[b].Path:=Ud.Path;
      BatchDown^[b].Conf:=FileConf;
    End;
  End;

  Procedure MoveFile(Fn,                 { File Number }
                     An,                 { New Area # }
                     Conf    : Integer;  { New Conf # }
                     M       : AskType;  { Move File? }
                     DeleteOld,          { Delete Old Record? }
                     Confirm : Boolean); { Confirm Move? }

  Var Oldn : Integer;
      NewFileSam,
      SamBam,
      FileSam,
      WangBang : Anystr;
      Darn,New : File;
      OldConf,A: Byte;
  Begin

    If Confirm Then Begin
      DefYES := TRUE;
      WriteSTR('Move '+UpString(UD.FileName)+' now? !');
      If Not Yes Then Exit;
    End;

    Oldn    := Curarea;
    OldConf := FileConf;

    If Conf <> FileConf Then Begin
      FileConf := Conf;
      Close(AFile);
      Close(UDFile);
      Close(UDIndex);
      Assign(AFile,Cfg.DataDir+'AREADIR.'+Strr(Conf));
      Reset(Afile);
      Assign(UDIndex,Cfg.DataDir+'AREAINDX.'+Strr(Conf));
      Reset(UDIndex);
      SeekAFile(An);
      SetArea(An,False);
      FileConf := OldConf;
    End;

    Writeln(^R'Moving Record'^A': '^S+Ud.Filename);
    Writelog(16,5,ud.filename);

    Filesam := GetFName(UD.Path,UD.FileName);
    Sambam  := UD.Path;

    If Conf=FileConf Then SetArea(an,false);

    If (M = Ask) And (UpString(SamBAM) <> UpString(Area.XmodemDIR))
    Then Begin
      DefYES := TRUE;
      WriteStr('Move File to Correct Directory? !');
      If YES
        Then M := AutoMatic;
    End;

    If (SamBAM <> Area.XmodemDIR) and (M=AutoMatic) Then Begin
      UD.Path := Area.XmodemDir;
      NewFileSam:=GetFName(ud.Path,ud.FileName);
      Writeln(^R'Moving '^S+UpString(FileSam)+^R' to '^S+NewFileSam);
      Exec(GetEnv('COMSPEC'),'/C COPY '+filesam+' '+newfilesam+' > NUL' );
      WangBang := FileSAM;
      Assign(darn,wangbang);
      If Exist(newfilesam)
        Then Erase(darn)
        Else Begin
          UD.Path := Sambam;
          WriteLn('Unable to move file on disk...');
        End;
    End;

    Addfile(UD);

    If OldCONF <> FileConf Then Begin
      FileConf := OldConf;
      Close(Afile);
      Close(UDFile);
      Close(UDIndex);
      Assign(Afile,Cfg.DataDir+'AREADIR.'+Strr(FileConf));
      Reset(Afile);
      Assign(UDIndex,Cfg.DataDir+'AREAINDX.'+Strr(FileConf));
      Reset(UDIndex);
    End;

    SetArea(OldN,False);

    If DeleteOld
      Then RemoveFile(FN,False,Leave,Leave);

    WriteLn(^B'Done.')
  End;

  Function Get_New_Conf : Byte;
  Var Old_Conf,X : Byte;
  Begin
    Old_Conf := FILECONF;
    ChangeConf(FALSE,0);
    X := FileConf;
    FileConf := Old_Conf;
    If (X<1) OR (X>Cfg.MaxFileConf)
      Then X := Old_CONF;
    Get_New_Conf := X;
  End;

  Function GetConfArea(Conf:Byte) : Byte;
  Var A, OldC : Byte;
      OldArea : Byte;
  Begin
    If Not(Exist(Cfg.DataDir+'AREADIR.'+Strr(Conf)))
    Then Begin
      Writeln('Sorry, There is no File Conference #'+Strr(Conf)+'!');
      Exit;
    End;
    Close(AFile);
   { Close(UDFile); }
    OldC     := FileConf;
    OldArea  := CurArea;
    FileConf := Conf;
    Assign(AFile,Cfg.DataDir+'AREADIR.'+Strr(Conf));
    Reset(Afile);
    SeekAFile(1);
    nRead(Afile,Area);
    ListAreas;

    Repeat
      Buflen := 3;
      WriteStr(^M^R'('^A'Conf: '+Strr(Conf)+^R') Area to Move File(s) To? [   ]'+B_(4)+'*');
      A := Valu(inpt);
      If (A<1) or (A>NumAreas) Then Writeln('Invalid Area Number!'^G);
    Until ((A>0) And (A<=NumAreas)) or (HungUpOn);

    GetConfArea := A;
    FileConf := OldC;
    Close(AFile);
    {Close(UDFile);}
    Assign(AFile,Cfg.DataDir+'AREADIR.'+Strr(FileConf));
    Reset(Afile);
   { SeekAFile(OldArea);
    nRead(Afile,Area); }
    SetArea(OldArea,False);
  End;

  Procedure GetASKType(S:String; VAR A : AskTYPE);
  Begin
    A := ASK;
    WriteStr(S + ^S'Y'^R'es '^S'N'^R'o '^S'A'^R'sk Each Time: &');
    Case Upcase(Inpt[1]) Of
      'Y' : A := AutoMatic;
      'N' : A := Leave;
      'A' : A := ASK;
    End;
  End;

  Procedure Put_In_Order(ByArea:Boolean);
  Var
    I, J, Bottom, Top, Middle : Integer;
    Temp : BatchRec;
  Begin
    For i := 2 to FilesInBatch Do
    Begin
      Temp := BatchDown^[i];
      Bottom := 1;
      Top := i - 1;
      While Bottom <= Top Do
      Begin
        Middle := (Bottom + Top) Div 2;
        Case BYAREA Of
          FALSE : If Temp.FileNUM < BatchDown^[Middle].FileNUM
                    Then Top := Middle - 1
                    Else Bottom := Middle + 1;
          TRUE  : If Temp.AREA < BatchDown^[Middle].AREA
                    Then Top := Middle - 1
                    Else Bottom := Middle + 1;
        End
      End;
      For j := i - 1 DownTo Bottom
        Do BatchDown^[j + 1] := BatchDown^[j];
      BatchDown^[Bottom] := Temp;
    End
  End;

    Procedure DeleteFiles;
    Var Cnt : Integer;
        X  : Byte;
        Fn : Lstr;
        OK,Confirm : Boolean;
        Delete,De_Credit : AskType;
        S,F : Integer;
    Begin
      GetFileNum('|C1File(s) to Delete (|C3Cr/|DE|C1): ','',S,F);
      if s = 0 then exit;
      If S = F Then Begin
        Confirm := TRUE;
        Delete := ASK;
      End Else Begin
        DefYES := True;
        WriteStr(^R'Confirm each File Deletion? !');
        Confirm := YES;
        GetASKType('Erase all files from disk? ',Delete);
        GetASKType('Remove Uploader''s Credit? ',De_Credit);
      End;
      For CNT := F Downto S Do Begin
        LoadUDREC(CNT);
        FN := GetFName(UD.Path,UD.Filename);
        WriteLog(16,7,FN);
        RemoveFile(CNT,Confirm,Delete,De_Credit);
      End
    End;

    Procedure TypeFiles;
    Var Cnt : Integer;
        S,F : Integer;
    Begin
      GetFileNum('|C1File(s) to Type (|C3Cr/|DE|C1): ','',S,F);
      If S = 0 Then Exit;
      For CNT := S to F Do Begin
        LoadUDREC(CNT);
        Archive.TypeFile(GetFName(UD.Path,UD.FileName));
        HoldScreen;
      End
    End;

    Procedure BatchDel;
    Var Oldn,
        Fn,
        Cnt : Integer;
        Confirm : Boolean;
        Delete,De_CREDIT : AskTYPE;
    Begin
      OldN := CurArea;
      If FilesInBatch = 0 Then Exit;
      Put_In_Order(False);
      Put_In_Order(True);
      If FilesInBatch = 1 Then Begin
        Confirm := TRUE;
        Delete := ASK;
      End Else Begin
        DefYES := True;
        WriteStr(^R'Confirm each File Deletion? !');
        Confirm := YES;
        GetASKType('Erase all files from disk? ',Delete);
        GetASKType('Remove Uploader''s Credit? ',De_Credit);
      End;
      For Cnt := FilesInBatch DownTo 1 Do
	Begin
	  SetArea(BatchDown^[Cnt].Area,False);
          LoadUDRec(BatchDown^[Cnt].FileNUM);
	  RemoveFile(BatchDown^[Cnt].FileNUM,Confirm,Delete,De_Credit);
  	  WriteLog(16,7,Ud.FileName);
        End;
    Clear_BatchDown;
   End;

   Procedure Batch_EDIT;
   Var Cnt:Byte;
   Begin
     If FilesInBatch < 1
       Then Exit;
     Put_In_Order(False);
     Put_In_Order(True);
     For Cnt := FilesInBatch DownTo 1 Do
       Begin
         SetAREA(BatchDown^[Cnt].Area,False);
         LoadUDRec(BatchDown^[Cnt].FileNUM);
         ChangeF(BatchDown^[Cnt].FileNUM);
         If Upcase(Inpt[1]) = 'X'
           Then Begin Clear_BatchDown; Exit; End;
       End;
     Clear_BatchDown;
   End;

    Procedure MoveFiles;
    Var Cnt : Integer;
        X  : Byte;
        Fn : Lstr;
        OK,Confirm : Boolean;
        FileMove   : AskType;
        S,F,NewConf,NewAREA : Integer;
    Begin
      GetFileNum('|C1File(s) to Move (|C3Cr/|DE|C1): ','',S,F);
      If S = F Then Begin
        Confirm := TRUE;
        FileMove := ASK;
      End Else Begin
        DefYES := True;
        WriteStr(^R'Confirm each File Move? !');
        Confirm := YES;
        GetASKType(^R'Move File to New Directory? ',FileMove);
      End;
      Inpt := 'N';
      If Cfg.MaxFileConf > 1
        Then WriteStr(^R'Do you wish to jump to another conference? !');
      If Yes Then Begin
        NewCONF := Get_New_Conf;
        NewAREA := GetConfArea(NewConf);
      End Else Begin
        NewCONF := FileCONF;
        ListAREAS;
        WriteStr(^R'Area to move File(s) to? '^A': &');
        NewAREA := Valu(Inpt);
        If (NewAREA < 1) or (NewAREA > NumAREAS)
          Then Exit;
      End;
      For CNT := F Downto S Do Begin
        LoadUDREC(CNT);
        MoveFILE(CNT,NewAREA,NewCONF,FileMove,True,Confirm);
      End
    End;

    Procedure BatchMove;
    Var Cnt : Integer;
        X  : Byte;
        Fn : Lstr;
        OK,Confirm : Boolean;
        FileMove   : AskType;
        NewConf,NewAREA : Integer;
    Begin
      If FilesInBatch = 1 Then Begin
        Confirm := TRUE;
        FileMove := ASK;
      End Else Begin
        DefYES := True;
        WriteStr(^R'Confirm each File Move? !');
        Confirm := YES;
        GetASKType(^R'Move File to New Directory? ',FileMove);
      End;
      Put_In_Order(False);
      Put_In_Order(True);
      Inpt := 'N';
      If Cfg.MaxFileConf > 1
        Then WriteStr(^R'Do you wish to jump to another conference? !');
      If Yes Then Begin
        NewCONF := Get_New_Conf;
        NewAREA := GetConfArea(NewConf);
      End Else Begin
        NewCONF := FileCONF;
        ListAREAS;
        WriteStr(^R'Area to move File(s) to? '^A': &');
        NewAREA := Valu(Inpt);
        If (NewAREA < 1) or (NewAREA > NumAREAS)
          Then Exit;
      End;
      For CNT := FilesInBatch Downto 1 Do Begin
        LoadUDREC(BatchDown^[CNT].FileNUM);
        MoveFILE(BatchDown^[Cnt].FileNUM,NewAREA,NewCONF,FileMove,True,Confirm);
      End;
      Clear_BatchDown;
    End;

  Procedure BarMenu(Extended : Boolean);

  Label Complete;

  Const Names : Array[1..7] of String[11]=
   (' Next ',' Move ',' Edit ',' Delete ',' View ',' Type ',' Quit ');

  Var Cnt : Integer;
      K : Char;
      X,I,A,C,Backup,BarLine : Integer;
      D,Done : Boolean;

    Procedure NumBar(Hi:Boolean);
    Begin
      If Hi
        Then AnsiColor(Urec.Color7)
        Else AnsiColor(Urec.Color1);
      Goxy(1,Files[I].SpacesDown + 2);
      Write(Direct,Files[I].FileNum);
    End;

    Procedure PlaceBar(Hi:Boolean);
    Const Where : Array[1..7] Of Byte=(2,8,14,20,28,34,40);
    Var I : Byte;
    Begin
      If Hi
        Then Ansicolor(Urec.Color7)
        Else Ansicolor(Urec.Color3);
      I := WHERE[X];
      Goxy(I,BarLine);
      Write(Direct,Names[X]);
    End;

  Procedure ListGroup;
  Var I : Byte;
  Begin
    DoHeader(Extended);
    For i := 1 to BackUp Do Begin
      If Break then Begin
        Inpt := 'Q';
        Exit;
      End;
      ListFile(Files[i].FileNum,Extended);
    End;
    GoXy(1,BarLine);
    Write(^O+Cfg.BarChar[1]+' '^P'Next  Move  Edit  Delete  View  Type  Quit '^O+Cfg.BarChar[2]+
    +^R' ('^S'Space'^R') Toggles ('^S'?'^R') Help');
    NumBar(true);
    PlaceBar(True);
    Bottomline;
  End;

  Begin
    Def := 0;
    Done := False;
    BottomLine;
    C := 1;
    D := False;

    Repeat
      Inc(C);
      If Files[C].FileNum = 0
        Then D := True;
    Until (C > 20) or (D);

    Dec(C);

    If C > 20
      Then C := 20;

    BarLine := Files[C].Where + 3;

    I := 1;
    X := 1;
    BackUp := C;

    ListGroup;

    If Break
      Then Exit;

    Clearbreak;
    Repeat
      NoBreak := True;
      K := ArrowKey(True);

      Case Upcase(K) OF
        'N','T','V','Q','D','I' :
        Begin
          Def := Files[I].FileNum;
          Inpt := K;
          Done := True;
        End;

        #32 : Begin
              SeekUdFile(Files[i].FileNum);
              NRead(UdFile,UD);
              Numbar(False);
              If InBatch(Ud.Filename) then Begin
                RemoveFromBatch(0,Ud.FileName);
                If Files[i].FileNum < 10
                  Then Write(^R'   ') Else
                if Files[i].FileNum < 100
                  then Write(^R'  ') Else
                Write(^R' ');
              End Else Begin
                AddBatch(Files[i].FileNum);
                If InBatch(Ud.FileName)
                  Then If Files[i].FileNum < 10
                    then Write(^R'  û') else
                    If Files[i].FileNum < 100
                      then Write(^R' û') Else
                        Write(^R'û');
            End;
            Inc(I);
            If I > C
              Then I := 1;

            If Inpt = Redraw
              Then ListGroup;

            Inpt := '';
            NumBar(True);
         End;

         ^D,'4':
           Begin
            PlaceBar(False);
            Dec(x);
            If X < 1
              Then X := 7;
            PlaceBar(True);
           End;

         ^C,'6':
           Begin
            PlaceBar(False);
            Inc(x);
            If X > 7
              Then X := 1;
            PlaceBar(True);
           End;

          ^A,'8':
            Begin
             Numbar(FalsE);
             Dec(i);
             If I < 1
               Then I := C;
             NumBar(True);
            End;

          ^B,'2':
            Begin
              NumBar(False);
              inc(i);
              If I > C
                Then I := 1;
              NumBar(true);
            End;

          #13:Begin
               Def := Files[i].FileNum;
               Case X Of
                 1:Begin
                    Inpt := 'N';
                    If WhereY < 23 Then Begin
                      Goxy(1,BarLine);
                      Writeln;
                    End
                   End;
                 2 : Inpt := 'M';
                 3 : Inpt := 'E';
                 4 : Inpt := 'D';
                 5 : Inpt := 'V';
                 6 : inpt := 'T';
                 7 : inpt := 'Q';
               End;
               If X In [2..4] then Begin
                 GoXy(1,C + 4);
                 Write(^R);
                 Write(Direct,#27+'[K');
               End;
               Done := True;
              End;

         '?':Begin
              AnsiReset;
              ListHelp;
              ListGroup;
             End;

         'Q':Begin
               Done:=True;
               Inpt:='Q';
               Ansireset;
               AnsiCls;
             End
         End;

    Until (Done) Or (hungupon);

    Complete:
    If Upcase(Inpt[1]) in ['M','E','D','V','T','Q'] Then Begin
      Def := Files[i].FileNum;
      GoXy(1,BarLine);
      Write(^R);
      Write(Direct,#27+'[K');
    End;
    AnsiReset;
  End;

  Procedure Delete_All;
  Begin
    If FilesinBatch>0 then Begin
      WriteStr('Delete tagged File(s) now? !');
      If Yes then BatchDel Else
      Deletefiles;
    End Else DeleteFiles;
    Inpt := Redraw;
  End;

  Procedure Edit_All;
  Begin
    If FilesinBatch>0 then Begin
      WriteStr('Edit tagged File(s) now? !');
      If Yes then Batch_Edit Else
      ChangeF(0);
    End Else ChangeF(0);
    Inpt := Redraw;
  End;

  Procedure View_ALL;
  VAR S,F : Integer;
  BEGIN
    GetFILENum('|C1Archive View Which (|C3Cr/|DE|C1): ','',S,F);
    If S < 1
      Then Exit;
    LoadUDRec(S);
    ViewArchive(UD.FileName,UD.Path);
  END;

  Procedure Move;
  Begin
    If FilesInBatch > 0 Then Begin
      WriteStr('Move tagged File(s) now? !');
      If Yes Then BatchMove
      Else MoveFiles;
    End Else MoveFiles;
    Inpt := Redraw;
  End;

  Procedure ListFiles (Extended,NewScan : Boolean; ScanFrom : Longint);
  Var Cnt, Max, R1, R2, Kn, X : Integer;
      Total, NewTotal : Byte;
      T : Char;
      Start_List,Done : Boolean;

      Function Ok_To_List : Boolean;
      Begin
        Ok_To_List := True;
        If Not NewScan
          Then Exit;
        If (UD.Whenrated > ScanFrom) Or (UD.When > ScanFrom)
          Then Exit;
        Ok_To_List := False;
      End;

  Const BeenAborted : Boolean = False;

  Const ExtendedStr:Array[False..True] Of String[12]=('Configurable','Extended');
  Var Shown : Boolean;
  Begin

    Max := NumUds;

    If Max < 1
      Then Begin
        If Not NewScan
          Then Writeln(^S'This area is empty!');
        Exit;
      End;

    If Not NewScan
      Then WriteHdr(ExtendedStr[Extended] + ' File List');

    Shown := False;

    If NewScan Then Begin
      R1 := 1;
      R2 := Max;
    End Else
      Parserange(Max,R1,R2,'File Listing');

    If R1 = 0
      Then Exit;

    FillChar(Files,SizeOf(Files),0);

    KN := 0;

    NoBreak:=True;
    Done := False;

    Cnt := R1;

    Total := 0;
    NewTotal := 0;

    While (Not Done) And (HungUpOn = False) Do Begin

      Done := Cnt >= R2;

      SeekUDFile(Cnt);
      NRead(UDFile,UD);

      If Ok_To_List Then Begin

        LoadUDRec(CNT);

        If Not Shown Then Begin
          If Not (UseBars in urec.config)
            Then Doheader(Extended);
          Shown := True
        End;

        If Extended
          Then Inc(NewTotal)
          Else NewTotal := Total + Total_Lines(Index.Descrip);

        Start_List := (NewTotal > 20) Or (Done);

        If (Cnt = R2) And (NewTotal > 20)
          Then Done := False;

        If (Start_List = False) or (Done)
        Then Begin
          If Not (UseBars in Urec.Config)
            Then Listfile(Cnt,Extended);
          Inc(Kn);
          Files[Kn].FileNum := Cnt;
          Files[Kn].SpacesDown := Total + 1;
          Total := NewTotal;
          Files[Kn].Where := Total + 1;
        End;

        If Start_List Then
        Repeat
          Kn       := 0;
          Total    := 0;
          NewTotal := 0;
          Start_List := False;
          If UseBars in Urec.Config
            Then BarMenu(Extended)
            Else Begin
              Sr.C[1] := 'AN'; Sr.S[1] := Area.Name;
              Writeln;
              If NewScan Then
                WriteStr(Strng^.File_NewScan_Prompt) Else
                WriteStr(Strng^.File_List_Prompt);
            End;
          If Inpt = ''
            Then inpt := ^X;
          T := UpCase(inpt[1]);
          Case T of
            '+' : AddBatch(0);
            'D' : Begin
                    Delete_all;
                    Cnt := 0;
                    Inpt := ^X;
                    If R2 > (FileSize(UDFile)-1)
                      Then R2 := FileSize(UDFile)-1;
                  End;
            'E' : Edit_ALL;
            'M' : Begin
                    Move;
                    Cnt := 0;
                    Inpt := ^X;
                    If R2 > (FileSize(UDFile)-1)
                      Then R2 := FileSize(UDFile)-1;
                  End;
            'R' : RemoveFromBatch(0,'');
            'T' : TypeFiles;
            'V' : View_ALL;
            'Q' : Begin
                    If Not NewScan
                      Then Exit;
                    BeenAborted:=True;
                    Done:=True;
                    AnsiCls;
                    WriteHdr('Newscan Aborted!');
                    SetArea(1,true);
                    Exit;
                  End;
            'N' : Begin
                    If (Not(UseBars in Urec.Config)) and (Cnt < R2) Then
                      If Extended
                        Then DoHeader(Extended);
                    FillChar(Files,SizeOf(Files),0);
                    Inpt[1] := ^X;
                    Dec(Cnt);
                 End;
            '?' : Listhelp
          End;
        Until Match(Inpt,^X) or HungUpOn;
      End;
      Inc(Cnt);
    End;
    NoBreak := False;
  End;

  Function SearchForFile(F : Sstr) : Integer;
  Var Ud : Udrec;
      Cnt : Integer;
  Begin
    For Cnt:=1 To filesize(udfile) Do Begin
      Seek (udfile,cnt - 1);
      nRead(udfile,ud);
      If match(ud.filename,f) Then Begin
        Searchforfile := CNT;
        exit
      End
    End;
    Searchforfile := 0
  End;

Procedure GetFileNum(Prompt : Lstr;
                     T      : Mstr;
                     VAR F,L: Integer);
Var Rf,Rl   : Mstr;
    P,V1,V2 : Integer;
    NumENTS : Integer;
    Remove  : Boolean;

Begin
  F := 0;
  L := 0;
  Numents := NumUds;
  Remove := T = 'remove from batch';
  If Remove Then Numents := FilesInBatch;
  if numents<1 then Begin
    Writeln('No Files in this area!');
    exit;
  End;
  Repeat
  If Length(Inpt)>1
    Then Inpt := Copy(Inpt,2,15)
    Else Begin
      Sr.C[1] := 'ER'; Sr.S[1] := Strr(NumEnts);
      Sr.C[2] := 'DE'; If Def > 0 Then Sr.S[2] := Strr(Def) Else Sr.S[2] := 'None';
      WriteStr(Prompt);
      If (Inpt = '?') then Begin
        If Not INLIST Then
          If Remove
            Then ListBatch
            Else ListFiles(False,False,0);
          Inpt := '?';
      End;
      If (Inpt='') And (Def>0) Then Inpt := Strr(Def);
      If (length(inpt)>0) and (upcase(inpt[1])='Q') then exit
    End;
  Until (Inpt<>'?') or hungupon;
  if hungupon then exit;
    p:=pos('-',inpt);
    v1:=valu(copy(inpt,1,p-1));
    v2:=valu(copy(inpt,p+1,255));
    if p=0 then begin
      f:=v2;
      l:=v2
    end else if p=1 then begin
      f:=1;
      l:=v2
    end else if p=length(inpt) then begin
      f:=v1;
      l:=numents
    end else begin
      f:=v1;
      l:=v2
    end;
  if (f<1) or (l>numents) or (f>l) then begin
    f:=0;
    l:=0;
    If Inpt <> '' Then F := SearchForFile(Inpt);
    If F = 0 Then Begin
      Writeln;
      If Inpt <> '' Then
        MultiColor(Strng^.Bad_File_Selection);
      Writeln;
    End Else L:=F;
  end;
end;

    Procedure Renamefile(Def:Integer);
    Var CNT,S,E : Integer;
        F       : File;
    Begin
      If Def < 1
        Then GetFileNum('|C1File(s) to Rename (Cr/|C3|DE|C1): ','',S,E)
        Else Begin
          S := Def;
          E := Def;
        End;
      If S = 0 Then exit;

      For CNT := S to E Do Begin
      LoadUDRec(CNT);
      Writestr(^R'Enter new filename for '^S+UpString(UD.FileName)+^R': &');
      If match(inpt,ud.filename)
      Then
        ud.filename:=inpt
      Else If Length(inpt)>0
        Then If validfname(inpt)
          Then If exist(getfname(ud.path,inpt))
            Then
              WriteLn('Name already in use!')
            Else
              Begin
                Assign(f,getfname(ud.path,ud.filename));
                Rename(f,getfname(ud.path,inpt));
                If IOResult=0 Then Begin
                  ud.filename:=inpt;
                  WriteLn(^B^M'File renamed.')
                End Else WriteLn(^B^M'Unable to rename file!')
              End
          Else WriteLn('Invalid filename!');
        seekudfile(CNT);
        NWrite(UDFile,UD)
      End
    End;

    Procedure NewFiles;
    Var a,fn,un:Integer;
        U : UserRec;
        KRad : Lstr;
        Flag,Aborted : Boolean;

    Procedure WriteUDRec;
    Begin
      SeekUDFile(FN);
      NWrite(UDFile,ud);
      Seek(UDIndex,UD.IndexPtr);
      NWrite(UDIndex,Index)
    End;

    Procedure RateFile(p:Integer);
    Begin
      INDEX.points := P;
      UD.WhenRated := Now;
      INDEX.NewFile := False;
      WriteUDRec;
      P := P * Cfg.UploadFactor;
      If P>0 Then Begin
        WriteSTR(^R'Give '^S+INDEX.SentBy+^R' how many pts? [Cr/'^O+Strr(P)+^R']: &');
        If Inpt = '' Then Else If (Valu(Inpt)>0) Or (inpt='0')
        Then P := Valu(Inpt);
        UN := Lookupuser(INDEX.sentby);
        If UN = 0
        Then WriteLn(INDEX.sentby,' has vanished!')
          Else Begin
            WriteLn('Giving ',INDEX.sentby,' ',p,' points.');
            If UN = Unum Then Writeurec;
            Seek(UFile,un);
            NRead(UFile,u);
            Inc(U.UDPoints,P);
            Seek(ufile,un);
            nWrite(ufile,u);
            If UN = Unum Then ReadUrec
          End
        End
      End;

      Procedure DoArea;
      Var I,AdVance : Integer;
          Done : Boolean;
      Begin
        FN := 1;
        Advance := 0;
        While FN + Advance <= NumUDS
        Do Begin
          Inc(FN,Advance);
          Advance := 1;
          LoadUDRec(FN);
          If UD.Whenrated = 0 Then Begin
            Flag := False;
            Done := False;
            Repeat
              Ansicls;
              WriteHdr('New File Received: '+DateStr(Ud.When));
              WriteLn(^B^M^R'Filename    '^A': '^S+UpString(ud.filename),
              ^R^M'Subdir Path '^A': '^S+upstring(ud.path),
              ^R^M'Uploaded by '^A': '^S+INDEX.sentby,
              ^R^M'File Size   '^A': '^S+strr(ud.filesize),
              ^R^M'Description '^A': '^S+INDEX.descrip[1]);

              For I := 2 to Total_Lines(Index.Descrip)
                Do Writeln('              '+Index.Descrip[i]);

              WriteStr(^R'SysOp File Newscan / Enter Point Value ('^S'?/Help'^R') : *');

              I := Valu(Inpt);

              If I > 0
              Then
                Begin
                  RateFile(i);
                  Done := True
                End
              Else
                Case Upcase(Inpt[1]) Of
                  '?':Begin
                        WriteLn(^R'[C] - Change Description    [E] - Rename File');
                        Writeln(^R'[D] - Delete File           [M] - Move File');
                        Writeln(^R'[CR]- Goto Next File        [Q] - Quit');
                        Writeln(^R'### - Give file ### File Points (0/Free)');
                      End;
                  'Q':Begin
                        Aborted := True;
                        Exit
                      End;
                  #13:done:=True;
                  'C':Begin
                        DoDescrip(Index.Descrip,UD.FileName);
                        WriteUDRec
                      End;
                  'E':Begin
                        RenameFile(FN);
                        Advance := 0
                      End;
                  'D':Begin
                        RemoveFile(FN,True,Ask,Ask);
                        Advance := 0
                      End;
                  'M':Begin
                        Def := FN;
                        MoveFiles;
                        Advance := 0
                      End;
                  '0':Begin
                        Ratefile(0);
                        Done := True
                      End
                End
            Until done Or (advance=0)
          End
        End
      End;

    Begin
      Flag := True;
      Writelog(16,1,'');
      If IsSYSoP Then Begin
        WriteHdr('SysOp File NewScan');
        Writestr(^R'Newscan all areas? !');
        If Yes Then Begin
          For A := 1 To NumAreas
          Do Begin
            SetArea(A,True);
            Aborted := False;
            DoArea;
            If Aborted Then EXIT
          End
        End Else DoAREA;
      End Else DoAREA;
      If Flag Then WriteLn(^B'No new files.')
    End;

begin
end.