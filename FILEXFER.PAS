{$R-,S-,I-,D-,F+,V-,B-,N-,L+,O+ }

Unit FileXfer;

Interface

Uses GenTypes;

Procedure Download(Num : Integer);
Procedure Add_to_batch (autoselect:Integer;File_Override:lstr; Point_Override:integer; Quite:Boolean);
Procedure Listarchive(List:Boolean);
Procedure TypeFile(List:Boolean);
Procedure RemoveFromBatch(Auto:Byte; FN:MStr);
Procedure FileInfo;
Procedure ListFiles(Extended,NewScan:Boolean; ScanFrom:Longint);
Procedure Searchfile;
Procedure NewScanall;
Procedure ListBatch;
Procedure EditUpload;

Implementation

Uses Dos, MNeT, Crt, Configrt, Modem, Statret, Gensubs,
     SubsOvr, Subs1, Subs2, Mycomman, Windows, Userret, Mainr1,
     Mainr2, Overret1, Flags, Viewer, Protocol, Archive, File0, File1;

Type DszRec = Record
       Code : Char;
       FileName : String[12];
       Path : String[50];
       CompleteByte, Size : Longint;
       Cps,Errors : String[4];
       Percent : Real;
     End;

     FilesList = Record
       FileNum,
       SpacesDown,
       Where : Integer;
     End;

Const Redraw = 'REDRAW!';

Var Files          : Array[1..20] of FilesList;

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
    X := 51 + X;
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

  Function AbleToDoAnything(UD : UDRec; Quite:Boolean; FileNum:Integer):Boolean;
  Var C : Boolean;

  Procedure Error(Message : Lstr);
  Var K : Char;
  Begin
    Inpt := '';
    If Not C
      Then Exit;
    If Not Quite then
      Printxy(1,23,^S+#27+'[K');
    NoBreak := True;
    MultiColor(Message);
    Repeat
      K := WaitForChar(False);
    Until (K in [#0,#13,#32]) or (HungUpOn);
    Write(Direct,#13);
    Write(Direct,#27 + '[K');
    C := False;
    Inpt := Redraw;
  End;

  Function AllowBaud : Boolean;
  Var K : Integer;
      Cnt : Baudratetype;
  Begin
    For Cnt := Firstbaud To Lastbaud Do
      If Connectbaud = Baudarray[ Cnt ]
        Then If Not (Cnt in Cfg.DownloadRates) Then Begin
          Allowbaud:=false;
          Exit;
        End;
    Allowbaud := true;
  end;

  Begin
    NoBreak := True;
    ClearBreak;
    C:=True;

    If Not Exist(Ud.Path+Ud.FileName) Then Begin
      Error(Strng^.File_Does_Not_Exist);
      Exit;
      If UD.FileSize<>-1 Then Begin
        Ud.FileSize:=-1;
        Seek(UDFile,FileNum-1);
        nWrite(UDFile,UD);
      End
    End;

    If Index.Crash Then
       Error(Strng^.Crashed_File);

    If (SponsorOn) and (C)
      Then Begin
        AbleToDoAnyThing := True;
        Exit;
      End;

    If Not AllowBaud Then
       Error(Strng^.Bad_Baud_Rate);

    If Index.Newfile And Not IsSysop Then
       Error(Strng^.UnValidated_File);

     If Index.SpecialFile and Not IsSysop Then
       Error(Strng^.Special_File);

    If Not Area.DownLoads Then
      Error(Strng^.No_Downloads_Here);

    If (Index.SendTo<>'') and Not Match(Index.Sendto,Urec.Handle) Then
      Error(Strng^.Private_File);

    If (Index.Password<>'') and C then
    Begin
      If Not Quite
        Then GoXy(1,24);
      WriteStr(Strng^.Passworded_File);
      If not Match(Inpt,Index.Password) then Begin
        C:=False;
        Writeln;
        MultiColor(Strng^.Wrong_Password);
        Writeln;
      End;
      Inpt := Redraw;
    End;

    If (C = False) And (Quite = False)
      Then Inpt := Redraw;

    AbleToDoAnything := C;
    NoBreak := False;
  End;

  Function InBatch(Fn:Sstr) : Boolean;
  Var I : Byte;
  Begin
    InBatch := False;
    If FilesInBatch < 1
      Then Exit;
    For i:=1 to FilesInBatch Do
      If Match(Fn,BatchDown^[i].Filename) Then Begin
        InBatch:=True;
        Exit;
      End;
  End;

  Function Batchtotaltime : Real;
  Var Cnt : Integer;
      Time : Real;
  Begin
    Time := 0;
    If Filesinbatch > 0 Then Begin
      For Cnt := 1 To filesinbatch Do
        Time := Time + BatchDown^[Cnt].Mins;
      BatchTotalTime := Time;
    End
      Else BatchTotalTime := 0;
  End;

  Function BatchTotalK : Longint;
  Var Cnt : Byte;
      Total : Longint;
  Begin
    Total:=0;
    If FilesinBatch > 0 Then Begin
      For Cnt:=1 to Filesinbatch Do
        Total:=Total+BatchDown^[Cnt].Size;
      BatchTotalK:=Total
    End
      Else BatchTotalK:=0;
  End;

  Function TotalPoints : Longint;
  Var Cnt : Integer;
      Points : Integer;
  Begin
    Points := 0;
    If Filesinbatch > 0 Then Begin
      For Cnt := 1 To filesinbatch Do
        Points := Points + Batchdown^[Cnt].Points;
      TotalPoints := Points;
    End
      Else TotalPoints := 0;
  End;

  Procedure ListBatch;
  Var X : Byte;
  Begin
    If FilesInBatch < 1
      Then Exit;

    ListingFile(Cfg.TextFileDir + 'BATLIST.TOP',True);

    For X := 1 To FilesInBatch Do Begin

      Sr.C[1] := 'NU'; Sr.S[1] := Strr(X);                     Sr.T[1] := 2;
      Sr.C[2] := 'FN'; Sr.S[2] := BatchDown^[x].FileName;      Sr.T[2] := 12;
      Sr.C[3] := 'SZ'; Sr.S[3] := Strlong(BatchDown^[x].Size); Sr.T[3] := 6;
      Sr.C[4] := 'CO'; Sr.S[4] := Strr(BatchDown^[x].Points);  Sr.T[4] := 4;
      Sr.C[5] := 'AR'; Sr.S[5] := Strr(BatchDown^[x].Area);    Sr.T[5] := 3;
      Sr.C[6] := 'ET'; Sr.S[6] := Streal(BatchDown^[x].Mins);  Sr.T[6] := 5;

      ListingFile(Cfg.TextFileDir + 'BATLIST.MID',False);
    End;

      Sr.C[1] := 'SZ'; Sr.S[1] := Strlong(BatchTotalK); Sr.T[1] := 6;
      Sr.C[2] := 'TP'; Sr.S[2] := Strlong(TotalPoints); Sr.T[2] := 4;
      Sr.C[3] := 'TT'; Sr.S[3] := Streal(BatchTotalTime); Sr.T[3] := 6;

      ListingFile(Cfg.TextFileDir + 'BATLIST.BOT',False);
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

  Procedure Listfile(N : Integer; Extended : Boolean; HiLite:Mstr);
  Var Q      : Sstr;
      Path,
      Filez  : AnyStr;
      _Name  : Namestr;
      _Ext   : Extstr;
      Sze       : Longint;
      Ofline    : Boolean;
      Total,All,X,TotalL : Byte;
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
        totall := total_lines(index.descrip);
        if totall < 1 then totall := 1;
        for all := 1 To totall
        do begin
          if all > 1 then
            begin
              writeln(direct);
              write(direct,#27 + '['+Strr(Total)+'C');
            end;
          if hilite <> '' then
            x := pos(upstring(hilite),upstring(index.descrip[all])) else
            x := 0;
          if x > 0 then
            begin
              ansicolor(urec.color4);
              write(direct,#32 + copy(index.descrip[all],1,x - 1));
              ansicolor(urec.color7);
              write(direct,copy(index.descrip[all],x,length(hilite)));
              ansicolor(urec.color4);
              write(direct,copy(index.descrip[all],x + length(hilite),255));
            end else
              write(direct,#32 + index.descrip[all]);
        end;
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

  Procedure BarMenu(Extended : Boolean);

  Label Complete;

  Const Names:Array[1..6] of String[11]=
   (' Next ',' Download ',' Type ',' View ',' Info ',' Quit ');

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
    Const Cases : Array[1..6] Of Byte = (2,8,18,24,30,36);
    Var I : Byte;
    Begin
      If Hi
        Then Ansicolor(Urec.Color7)
        Else Ansicolor(Urec.Color3);
      I := Cases[X];
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
      ListFile(Files[i].FileNum,Extended,'');
    End;
    GoXy(1,BarLine);
    Write(^O+Cfg.BarChar[1]+' '^P'Next  Download  Type  View  Info  Quit '^O+Cfg.BarChar[2]+
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
                  Then Write(^R'   ') else
                if Files[i].FileNum < 100
                  then Write(^R'  ') else
                Write(^R' ');
              End Else Begin
                Add_TO_Batch(Files[i].FileNum,'',0,False);
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
              Then X := 6;
            PlaceBar(True);
           End;

         ^C,'6':
           Begin
            PlaceBar(False);
            Inc(x);
            If X > 6
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
                 2 : Inpt := 'D';
                 3 : Inpt := 'T';
                 4 : Inpt := 'V';
                 5 : Inpt := 'I';
                 6 : inpt := 'Q';
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
    If Upcase(Inpt[1]) in ['D','T','V','I','Q'] Then Begin
      Def := Files[i].FileNum;
      GoXy(1,BarLine);
      Write(^R);
      Write(Direct,#27+'[K');
    End;
    AnsiReset;
  End;

  Const BeenAborted : Boolean = False;

  Function Aborted : Boolean;
  Begin
    If BeenAborted Then Begin
      Aborted := True;
      Exit
    End;
    Aborted := XPressed Or Hungupon;
    If XPressed Then Begin
      Beenaborted := True;
      WriteLn(^B'Newscan Aborted..')
    End
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

  Const ExtendedStr:Array[false..true] Of String[12]=('Configurable','Extended');
  Var   Shown : Boolean;
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
          If Not BARS_OK
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
          If Not BARS_OK
            Then Listfile(Cnt,Extended,'');
          Inc(Kn);
          Files[Kn].FileNum := Cnt;
          Files[Kn].SpacesDown := Total + 1;
          Total := NewTotal;
          Files[Kn].Where := Total + 1;
        End;

        If Start_List Then
        Repeat
          Kn := 0;
          Total := 0;
          NewTotal := 0;
          Start_List := False;
          If BARS_OK
            Then BarMenu(Extended)
            Else Begin
              Sr.C[1] := 'AN'; Sr.S[1] := Area.Name;
              Writeln;
              If NewScan Then
                WriteStr(Strng^.File_NewScan_Prompt) Else
                WriteStr(Strng^.File_List_Prompt);
            End;
          If Inpt = ''
            Then inpt := 'N';
          T := UpCase(inpt[1]);
          Case T of
            '+' : Add_To_Batch(0,'',0,False);
            'D' : DownLoad(0);
            'R' : RemoveFromBatch(0,'');
            'T' : TypeFile(False);
            'V' : ListArchive(False);
            'I' : FileInfo;
            'Q' : Begin
                    If Not NewScan
                      Then Exit;
                    BeenAborted:=True;
                    Done:=True;
                    AnsiCls;
                    WriteHdr('Newscan Aborted!');
                    SetArea(1,True);
                    Exit;
                  End;
            'N' : Begin
                    If (Not(BARS_OK)) and (Cnt < R2) Then
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
    NoBreak:=False;
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

Procedure GetFileNum(Prompt : Lstr; T:Mstr; List:Boolean; VAR F,L:Integer);
var rf,rl:mstr;
    p,v1,v2:integer;
    numents:Integer;
    remove:boolean;
begin
  f:=0;
  l:=0;
 Numents:=NumUds;
  If t='remove from batch'
    Then Remove:=True
    Else Remove:=False;
  If Remove Then numents:=FilesInBatch;
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
        If List Then
          If Remove
            Then ListBatch
            Else ListFiles(False,False,0);
          Inpt:='?';
      End;
      If (Inpt='') And (Def>0) Then Inpt:=Strr(Def);
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
    If Inpt<>'' Then F:=SearchForFile(Inpt);
    If F=0 Then Begin
      Writeln;
      MultiColor(Strng^.Bad_File_Selection);
      Writeln;
    End Else L:=F;
  end;
end;

  Procedure File_Info;
  Var F : File;
  Begin
    Sr.C[1] := '|A';
    Assign(F,GetFName(UD.Path,UD.Filename));
    Reset(F);
    If IoResult <> 0
      Then Sr.S[1] := '0:00'
      Else Sr.S[1] := MinStr(FileSize(F));
    Close(F);
    Sr.C[2] := '|F'; Sr.S[2] := UpString(UD.Filename);
    Sr.C[3] := '|U'; Sr.S[3] := Index.SentBy;
    Sr.C[4] := '|T'; Sr.S[4] := Strr(Index.Downloaded);
    Sr.C[5] := '|P'; If (Index.Points < 1) or (Area.Leech)
                     Then Sr.S[5] := 'Free'
                     Else Sr.S[5] := Strr(Index.Points);
    Sr.C[6] := '|B'; If Exist(GetFName(UD.Path,UD.Filename))
                     Then Sr.S[6] := Strlong(UD.FileSize)
                     Else Sr.S[6] := '-1';
    Sr.C[7] := '|L'; Sr.S[7] := Strr(TimeLeft);
    Sr.C[8] := '|E'; Sr.S[8] := DateStr(UD.When);
    Sr.C[9] := '|W'; Sr.S[9] := TimeStr(UD.When);
    Sr.C[10] := '|D'; Sr.S[10] := Index.Descrip[1];
    DataFile(Cfg.TextFileDir+'FILEINFO.ANS');
    HoldScreen;
  End;

    Procedure FileInfo;
    VAR N,f,l : Integer;
    Begin
      GetFileNum(Strng^.GetInfoPrompt,'Info On',Def < 1,F,L);
      If F<1 Then Exit;
      For N:=F to L Do Begin
        If N>0 then Begin
          LoadUDREC(N);
          File_Info;
        End
      End
    End;

    Procedure RemoveFromBatch(Auto:Byte; FN:Mstr);
    VAR C,Where:Byte;
        N,F,L:Integer;
        List:Boolean;
    Begin
      If FilesInBatch<1 then Begin
        Writeln('No files currently tagged!');
        Exit;
      End;
      List:=True;
      If (Auto<1) And (FN='') Then Begin
        List:=False;
        If Length(Inpt)<2 Then ListBatch;
        GetFileNum('File [#] to Remove','remove from batch',True,F,L);
      End Else If (Auto=0) and (FN<>'') Then Begin
        For N:=1 to FilesinBatch Do
          If Match(BatchDown^[N].FileName,FN) Then Begin
            L:=N;
            F:=N;
          End;
      End;
      Where:=0;
      For N:=L DownTo F Do Begin
        Fn:=BatchDown^[N].FileName;
      For C:=FilesinBatch downto 1 Do
        If Match(FN,BatchDown^[C].Filename)
        Then Where:=C;
      If Where>0 then Begin
        If Not List Then Begin
          Sr.C[1] := 'FN'; Sr.S[1] := UpString(BatchDown^[Where].Filename);
          MultiColor(Strng^.Untagging_File);
          Writeln;
        End;
        If Where < FilesInBatch then Begin
          For C:=Where to FilesInBatch-1 Do
            BatchDown^[C] := BatchDown^[C + 1];
        End;
          FillChar(BatchDown^[FilesInBatch],SizeOf(BatchDown^[FilesInBatch]),0);
          Dec(FilesInBatch);
        End
       End;
      End;

  Procedure GetFSize(Var ud:udrec);
  Var df:File Of Byte;
  Begin
    Ud.FileSize := -1;
    Assign(df,GetFName(ud.path,ud.filename));
    Reset(df);
    If IOResult <> 0
      Then exit;
    Ud.FileSize := FileSize(df);
    Close(df)
  End;

  Procedure ListArchive(List:Boolean);
  Var N,F,L :Integer;
      FName:Lstr;
  Begin
    If nofiles Then exit;
    GetFileNum(Strng^.ViewArchivePrompt,'ViEW',List,F,L);
    If F < 1 Then Exit;
    For N := F to L Do Begin
      If N = 0
        Then Exit;
      LoadUDREC(N);
      If Not AbleToDoAnything(Ud,False,n)
        Then Exit;
      FName := GetFName(Ud.Path,UD.Filename);
      FName := UpString(FName);
      ViewArchive(Ud.Filename,Ud.Path);
    End;
    If Exist(Cfg.ExtractDir+'EXTRACT.ZIP') Then Begin
    Repeat
     Buflen:=1;
     WriteStr(Strng^.File_Extract_Prompt);
    Until (Upcase(Inpt[1]) in ['Q','A','B']) or (HungUpOn);
    Writeln;
    Case Upcase(Inpt[1]) Of
      'A':Add_To_Batch(0,Cfg.extractDir+'EXTRACT.ZIP',0,True);
    End;
    End;
  End;

  Procedure Typefile(list:Boolean);
  var n,f,l:integer;
  Begin
    if nofiles then exit;
    getfilenum(Strng^.TypeFilePrompt,'type',list,f,l);
    If f<1 Then Exit;
    For N:=F to L Do Begin
      if n=0 then exit;
      LoadUDREC(n);
      If AbleToDoAnything(Ud,False,n) then Begin;
        If Index.SendTo<>'' then
          If Not Match(Index.SendTo,Urec.Handle) Then Exit;
        Archive.TypeFile(UD.Path + UD.Filename);
        HoldScreen;
      End;
    End;
  End;

  Function OkUDRatio (Var _Ratio : Integer) : Boolean;
  Var X3 : Integer;
      Temp : Boolean;
  Begin
    OkUDRatio := False;
    Temp := False;
    If (Urec.UDFRatio = 0) or (Urec.Downloads < 1) or (Area.Leech)
      Then Begin
        OKUDRatio := True;
        Exit;
      End;
    X3 := Ratio(urec.uploads,urec.downloads);
    _Ratio := X3;
    If (SponsorON)
    Or (Ulvl >= Cfg.Exemptlevel)
    Or (X3 >= Urec.udfratio)
      Then Temp := True;
    OkUDRatio := True;
  End;

  Function OkUDK (Var _Ratio : Integer) : Boolean;
  Var X3 : Integer;
      Temp : Boolean;
  Begin
    Temp := False;
    Okudk := False;
    If (Urec.Udkratio = 0) Or (Urec.KDown < 1) Or (Area.Leech)
      Then Begin
        OkUDK := True;
        Exit;
      End;
    X3 := Ratio(urec.KUp,urec.KDown);
    _Ratio := X3;
    If (X3 >= urec.udkratio)
    Or (Ulvl >= Cfg.exemptlevel)
    Or (SponsorOn)
      Then Temp := True;
    OkUDK := Temp;
  end;

    Function OKRatiosAnd(Ud:Udrec; Quite:Boolean):Boolean;
    Var C : Boolean;
        UDRat, UDKRat, KDown : Integer;

      Procedure SeaError(M:Lstr);
      Var K : Char;
      Begin
        If Not C
          Then Exit;
        C := False;
        If Not Quite
          Then PrintXy(1,24,^R+#27+'[K');
        MultiColor(M);
        If Quite
          Then Begin
            Repeat
              K := WaitForChar(False);
            Until (K in [#0,#13,#32]) or (HungupOn);
            Write(Direct,#13);
            Write(Direct,#27 + '[K');
          End
          Else Writeln;
        Inpt := Redraw;
      End;

    Begin
      C:=True;

      If (No_Dl in urec.config)
        Then SeaError('You are not allowed to download!');

      If Not OkUdRatio(UDRat)
        Then Begin
          Sr.C[1] := 'RA'; Sr.S[1] := Strr(UDRat);
          Sr.C[2] := 'RR'; Sr.S[2] := Strr(Urec.UDFRatio);
          SeaError(Strng^.Bad_UD_Ratio);
        End;

      If Not OkUdK(UDKRat)
        Then Begin
          Sr.C[1] := 'RA'; Sr.S[1] := Strr(UDKRat);
          Sr.C[2] := 'RR'; Sr.S[2] := Strr(Urec.UDKRatio);
          SeaError(Strng^.Bad_UDK_Ratio);
        End;

      If Urec.KDownToday + UD.FileSize > 0
        Then KDown := (Urec.KDownToday + UD.FileSize) Div 1024
        Else KDown := 0;

      If (KDown > Urec.DailyKBLimit) and (C) And (Not Area.Leech)
      Then Begin
        Sr.C[1] := 'DK'; Sr.S[1] := Strlong(KDown);
        Sr.C[2] := 'KL'; Sr.S[2] := Strr(Urec.DailyKBLimit);
        IF Urec.DailyKBLimit > 0 then
          SeaError(Strng^.Bad_K_Limit);
      End;
      OkRatiosAnd:=C;
    End;

  Procedure PointCom(Name : Mstr; Pts : Integer);
  Var U : Userrec;
      I : Integer;
  Begin
    If (Cfg.PointCommision <= 0) or (Pts <= 0)
      Then exit;
    I := LookUpUser (Name);
    If I=0 Then Exit;
    Sr.C[1] := 'NA'; Sr.S[1] := Name;
    Sr.C[2] := 'FP'; Sr.S[2] := Strr(Pts);
    Writeln;
    MultiColor(Strng^.Giving_FP_Credit);
    Writeln;
    Seek(ufile,i);
    Read(ufile,u);
    U.UDPoints := U.UDPoints + Pts;
    Seek(ufile,i);
    Write(ufile,u);
    Notice(Name,'File Point Commision, ('+Strr(pts)+') was earned...');
  End;

  Function CheckDownloads : Byte;
  Var T : Text;
      D : DszRec;
      S : String;
      Total : Byte;

      Procedure ChargeUser;
      Var X,Old,OldCONF : Byte;
      Begin
        Inc(Urec.Downloads);
        OldConf := FileConf;
        For X := 1 to FilesInBatch Do
          If Match( GetFName(BatchDown^[x].Path,BatchDown^[x].Filename),
                    GetFName(D.Path,D.Filename) )
          Then Begin

            If BatchDown^[x].Conf <> FileConf
              Then Begin
                OldConf  := FileConf;
                FileConf := BatchDown^[x].Conf;
                CurArea  := BatchDown^[x].Area;
                AssignUD(True);
                Close(UDIndex);
                Assign(UDIndex,Cfg.DataDir + 'AREAINDX.' + Strr(FileConf));
                Reset(UDIndex);
              End
              Else SetArea(BatchDown^[x].Area,False);

            PointCom(BatchDown^[x].By,BatchDown^[x].Points);
            Old := CurArea;
            LoadUDRec(BatchDown^[x].FileNum);
            Inc(Index.Downloaded);
            Seek(UDIndex,UD.IndexPTR);
            NWrite(UDIndex,Index);

            If Index.Return
              Then Notice(Index.SentBy,Unam+' downloaded '+UD.FileName);

            Sr.C[1] := 'FN'; Sr.S[1] := D.Filename;
            Sr.C[2] := 'CP'; Sr.S[2] := D.Cps;
            Sr.C[3] := 'CO';
            If BatchDown^[x].Points > 0
              Then Sr.S[3] := Strr(BatchDown^[X].Points)
              Else Sr.S[3] := 'Free';

            Sr.C[4] := 'ER'; Sr.S[4] := D.Errors;

            MultiColor(Strng^.Good_Download);
            Writeln;

            WriteLog(0,0,'Downloaded: '+D.FileName+' CPS: '+D.Cps);
            AdDSZLog(D.Cps,D.FileName,True,D.Size);

            Urec.UDPoints := Urec.UDPoints - BatchDown^[x].Points;
            Urec.KDown := Urec.KDown + (BatchDown^[x].Size DIV 1024);
            Urec.KDownToday := Urec.KDownToday + (BatchDown^[x].Size Div 1024);
            Inc(Status.NewDownloads);
            Inc(Log.DLoads);
            Inc(Total);

            If OldConf <> FileConf
              Then Begin
                FileConf := OldConf;
                Close(UDIndex);
                Assign(UDIndex,Cfg.DataDir + 'AREAINDX.' + Strr(FileConf));
                Reset(UDIndex);
              End;

            SetArea(Old,False);

            Exit;
          End;
      End;

  Var HSLink : Boolean;
      NSize,Many : Word;
  Begin
    Assign(T,Cfg.DszLog);
    Reset(T);
    Total := 0;
    If IoResult <> 0 Then Begin
      TextClose(T);
      CheckDownloads := 0;
      Exit;
    End;
    HSLink := False;
    Many := 0;
    NSize := NumUDS + 1;
    While Not(Eof(T)) Do Begin
      Readln(T,S);
      ProcessLine(S,D);
   {  If D.Code = 'H' Then Begin
        If Add_Rec(D) Then Begin
          HSlink := True;
          Inc(Many);
        End
      End
      Else }
      If D.Code In ['Z','R','Q','S','h']
        Then ChargeUser
        Else WriteLog(0,0,'Unsuccessful Download: '+D.FileName);
    End;
    WriteUrec;
    TextClose(T);
{    If (Total > 0) And (HSLink) Then
      Redo(NSize,NumUDs); }
    CheckDownloads := Total;
  End;

  Procedure Batch_To_File;
  Var T : Text;
      Cnt : Byte;
      S : String;
  Begin
    Assign(T,Cfg.VisionDir+'FILELIST.TXT');
    Rewrite(T);
    For Cnt := 1 to FilesInBatch Do Begin
      S := GetFName(BatchDown^[Cnt].Path,BatchDown^[Cnt].FileName);
      Writeln(T,S);
    End;
    TextClose(T);
  End;

  Procedure DeleteDSZLog;
  Var F : File;
  Begin
    If Exist(Cfg.DszLog) Then Begin
      Assign(F,Cfg.DSZLog);
      Erase(F);
    End;
  End;

  Procedure Download(Num : Integer);
  Var X : Byte;
      P : Integer;
      Name : Lstr;
  Begin
    DeleteDszLog;
    X := FilesInBatch;

    If X = 0
      Then Begin
        Add_To_Batch(0,'',0,False);
        X := FilesInBatch;
        If X < 1
          Then Exit;
      End;

    Repeat
      ListBatch;
      WriteStr(Strng^.DownloadStr);
      If Upcase(Inpt[1]) = 'X'
        Then Exit;
      If Upcase(Inpt[1]) = 'A'
        Then Add_To_Batch(0,'',0,False);
      X := FilesInBatch;
    Until (HungUpOn) Or (Inpt = '');

    If X = 2
      Then Inc(X);

    If X = 1
      Then X := 2;

    If X <> 2 Then
      Begin
        Batch_To_File;
        X    := 4;
        Name := Cfg.VisionDir + 'FILELIST.TXT';
      End Else Name := GetFName(BatchDown^[1].Path,BatchDown^[1].FileName);

    UpdateNode('Downloading');
    P := ExecProto(X,Name,Area.XModemDir);
    UpdateNode('');

    If P < 0
      Then Exit;

    P := CheckDownloads;
    Clear_BatchDown;
  End;

Procedure Add_To_Batch(AutoSelect     : Integer;
                       File_Override  : Lstr;
                       Point_Override : Integer;
                       Quite          : Boolean);
Var Num,
    FSize,
    Total,
    B,
    First,
    Last : Integer;
    Mins : Real;
    FName : Lstr;
    Tempo : Longint;
    Too,
    Too1 : Mstr;
    F : File;
    Fn : File of byte;

    Procedure Error(Str:Lstr);
    Var K : Char;
    Begin
      If {Not} Quite
        Then Printxy(1,24,^R+#27+'[K');
      MultiColor(Str);
      If {Not} Quite
        Then Begin
          Repeat
            K := WaitForChar(False);
          Until (K in [#0,#13,#32]) or (HungUpOn);
          Write(Direct,#13);
          Write(Direct,#27 + '[K');
        End
        Else Writeln;
      Inpt := Redraw;
    End;

Begin

  If FilesinBatch >= 50
  Then Begin
    Error(Strng^.Can_Only_Tag_50);
    Exit;
  End;

  If (Not CheckFlags(Urec.Flags,Area.DownFlag)) And (File_OverRide='')
  Then Begin
    Error(Strng^.You_Cannot_Download);
    Exit;
  End;

  If Urec.Handle > '' Then Begin

    If (File_OverRide='')
      Then If (Nofiles)
        Then Exit;

    If (AutoSelect = 0) And (File_OverRide = '')
    Then Begin
      Getfilenum(Strng^.AddBatchPrompt,'add to batch',Quite,First,Last);
      If (First < 1)
        Then Exit;
      If First = Last Then Num:=First Else Begin
        For Num:=First to Last Do Add_To_Batch(Num,'',0,Quite);
        Exit;
      End
    End
    Else Num := AutoSelect;

    If (Num = 0) and (File_OverRide = '')
      Then Exit;

    If File_OverRide='' Then
      LoadUDREC(Num);

    If Not OkRatiosAnd(Ud,Quite)
      Then Exit;
  End;

  If Inbatch(Ud.FileName) Then Begin
    Sr.C[1] := 'FN'; Sr.S[1] := UpString(UD.FileName);
    MultiColor(Strng^.File_Already_Marked);
    WriteLn;
    Exit;
  End;

  If (File_OverRide<>'') or ( (File_override='') and (AbleToDoAnything(Ud,Quite,num)) )
  Then Begin
    If TempSysOp Then Begin
      ulvl:=regularlevel;
      tempsysop:=False;
      writeurec;
      bottomline
    End;
    If File_OverRide = ''
      Then FName := GetFName(ud.path,ud.filename)
      Else FName := File_OverRide;
    Assign(f,fname);
    Reset(f);
    Iocode := IOResult;
    If iocode<>0 Then Begin
      FileError('DOWNLOAD',fname);
      Exit
    End;
    FSize:=FileSize(f);
    Close(f);
    Assign(fn,fname);
    Reset(fn);
    Tempo := FileSize(fn);
    Close(fn);
    Mins := RealValu(MinStr(FSize));
    If (((mins+batchtotaltime)>timeleft) And (Not sponsoron))
    Then Begin
      Error('Insufficient time to add this file to batch!');
      exit
    End;
    If (Not SponsorON) or (Not Urec.Level >= Cfg.ExemptLevel) Then
    if (Area.Leech=False) Then Begin
      Total := Totalpoints + INDEX.Points;
      If Total > Urec.UDPoints
      Then begin
        Error(Strng^.Not_Enough_FP);
        Exit;
      End;
      if (Ratio (Urec.Uploads,Urec.downloads + filesinbatch) < urec.udfratio)
      then begin
        Sr.C[1] := 'RA';
        Sr.S[1] := Strr( Ratio(Urec.Uploads,Urec.Downloads + FilesInBatch) );
        Sr.C[2] := 'RR';
        Sr.S[2] := Strr(Urec.UDFratio);
        Error(Strng^.Bad_UD_Ratio);
        exit;
      End;
      If (((batchtotalk+ud.Filesize+Urec.KDownToday) Div 1024) > urec.dailykblimit)
      And (urec.dailyKBLimit > 0) Then Begin
        Sr.C[1] := 'DK'; Sr.S[1] := '+ Batch';
        Sr.C[2] := 'KL'; Sr.S[2] := Strr(Urec.DailyKBLimit);
        Error(Strng^.Bad_K_Limit);
        {Error('Adding this file exceeds your Daily KB Download Limit of '+strr(urec.dailykblimit)+'K');}
        Exit;
      End;
    End;
    If (Mins - 5 > Timetillevent) Then Begin
      Error('Sorry, an event is happening in a few minutes');
      Exit
    End;
    B := Filesinbatch;
    Inc(B);
    Filesinbatch := B;
    BatchDown^[b].Size := Tempo;
    If file_override<>'' Then Begin
      Index.Sentby := '';
      Index.Points := 0;
    End;

    BatchDown^[b].By            := Index.Sentby;
    BatchDown^[b].Wholefilename := FName;
    BatchDown^[b].Mins          := Mins;
    BatchDown^[b].Area          := CurArea;
    BatchDown^[b].Filenum       := Num;
    BatchDown^[b].Conf          := FileConf;

    If Point_OverRide>0
      Then BatchDown^[b].Points := Point_OverRide
      Else If Not Area.Leech
      Then Batchdown^[b].Points := Index.Points
      Else Batchdown^[b].Points := 0;
    FSplit (FName,Ud.Path,Too,Too1);
    Ud.filename:=too+too1;
    BatchDown^[b].Filename := ud.filename;
    BatchDown^[b].Path := ud.path;
    If Quite Then Begin
      Write(^B^R'Tagging'^A': '^S);
      Tab(Upstring(ud.filename),16);
      Write(^R'Bytes'^A': '^S);
      Tab(Strlong(Tempo)+' Bytes',18);
      If File_OverRide=''
        Then Writeln(^R'Cost'^A': '^S+Strr(Index.Points))
        Else Writeln;
    End
  End
End;

    Procedure NewScanAll;
    Var Cnt:Integer;
      a:arearec;
      start_area : integer ;
      ScanFrom:Longint;
    Begin
      ScanFrom:=LastOn;
      Repeat
        Sr.C[1]:='NS';
        Sr.S[1]:=DateStr(ScanFrom);
        WriteStr(^M+Strng^.NewScanDateStr);
        If UpString(Inpt)='Q' Then Exit;
        If Inpt<>'' Then Begin
          If DateVal(Inpt)>0 Then Begin
            ScanFrom:=DateVal(Inpt);
            Inpt[0]:=#0;
          End Else
          Writeln('Invalid Date; Try Again...');
        End;
      Until (Inpt='') or (HungUpOn);
      ansicls;
      Writehdr('Newscanning All Tagged Areas');
      beenaborted:=False;
      If aborted Then exit;
      Start_Area := Curarea ;
      For CNT := 1 To FileSize(afile)
      Do Begin
        SeekAFile(cnt);
        NRead(afile,a);
        If (Allowed_in_Area(Cnt,True,A)) And (Not (Cnt in NScan.FileNewScan)) Then Begin
	If Aborted Then Begin
	  SetArea(start_area,true);
	  Exit;
	End;
        SetArea(Cnt,False);
        Bottomline;
        Sr.C[1]:='AN';
        SR.S[1]:=Area.Name;
        Writeln(^B);
	MultiColor(Strng^.NewScanningStr);
	If aborted Then begin
       	  Goxy(19,1);
          Writeln;
	  setarea(start_area,true);
	  exit;
        end;
      ListFiles(False,True,ScanFrom);
      If aborted Then begin
        Writeln;
        setarea(start_area,true);
        exit;
      end;
     End;
     If aborted Then begin
       exit;
     end;
    End;
  Writeln;
  Setarea(start_area,true);
End;

  Procedure EditUpload;
  VAR X,Proto,F,L:Integer;
      K:Char;
  Begin
    WriteHdr('File Editor');
    GetFileNum('|C1File [|C3#/Name|C1] to Edit : ','Edit',True,F,L);
    For X:=F To L Do Begin
      If X=0 Then Exit;
      LoadUDRec(X);
      If ( Not Match(Index.SentBy,Urec.Handle) ) Then
      If (Not (IsSysOp))
      Then Begin
        Writeln(^G^M'This file was not uploaded by you!');
        Exit;
      End;
      Repeat
        Writeln(^M^R'Editing File'^A': '^S+UpString(UD.FileName));
        Writeln(^R'Upload Date '^A': '^S+DateStr(UD.When));
        Writeln(^M^R'['^A'D'^R'] Description  : Edit Ten-Line Description');
        Writeln(^R'['^A'I'^R'] Private For  : '^S+Index.SendTo);
        Writeln(^R'['^A'P'^R'] File Password: '^S+Index.Password);
        Buflen := 1;
        Inpt[0] := #0;
        WriteStr(^M^R'Edit Which? ['^A'Q'^R']uits [ ]'+B_(2)+'*');
        K:=Upcase(Inpt[1]);
        Case K of
        'P':Begin
           Writeln(^P'Old File Password'^O': '^S+Index.Password);
           Write(^P'File Password'^O': ');
           InputBox(20);
           Index.Password:=inpt;
           Writeln(^R'File Password changed to'^A': '^S+Index.Password);
         End;
        'I':Begin
            Write(^P'Now Private For'^O': '^S);
            If Index.Sendto <> '' then Writeln(Index.Sendto)
              else Writeln('Nobody');
            Write(^P'Private For'^O': ');
            InputBox(30);
            If inpt<>'' then proto:=lookupuser(inpt) else Begin
              WriteStr(^P'Set to Null? !');
              If yes then inpt[0]:=#0;
              proto:=-1;
            End;
            If proto=0 then Begin
              Writeln(^S+inpt+' is not found in the user database!');
              WriteStr('Do you still wish to send file to '+inpt+'? !');
              If Yes then Index.SendTo := Inpt;
            End else Index.Sendto:=inpt;
            Writeln(^R'Now Private For'^A': '^S+Index.SendTo);
            End;
         'D':Begin
               DoDescrip(Index.Descrip,UD.FileName);
               AnsiCls;
        End;
    End;
  Until (K='Q') or (HungUpOn);
    WriteStr(^R'Save this to disk? ['^S'Y'^R'/'^S'n'^R'/'^S'x'^R'] : *');
    If Inpt = '' then Inpt := 'Y';
    Case Upcase(Inpt[1]) Of
      'Y' : Begin
              SeekUDFile(X);
              nWrite(UDFile,UD);
              Seek(UDIndex,UD.IndexPtr);
              nWrite(UDindex,Index);
            End;
      'X' : Exit;
    End
  End;
  End;

  Function WildCardMatch(W,F : Sstr) : Boolean;
  Var A,B : Sstr;

    Procedure transform(t:sstr;Var q:sstr);
    Var P : Integer;

      Procedure FillUntil(K : Char; N : Integer);
      Begin
        While Length(Q) < N Do Q := Q + K
      End;

      Procedure DoPart(Mx : Integer);
      Var K : Char;
      Begin
        Repeat
          If P > Length(t)
            Then K := '.'
            Else K := T[p];
          Inc(P);
          Case K Of
            '.' :Begin
                   FillUntil(' ',mx);
                   Exit
                 End;
            '*' :FillUntil('?',mx);
            Else If Length(Q) < Mx Then q:=q+k
          End
        Until 0 = 1
      End;

      Begin
        P := 1;
        Q := '';
        DoPart(8);
        DoPart(11)
      End;

    Function TheyMatch : Boolean;
    Var cnt:Integer;
      Begin
        theymatch:=False;
        For cnt:=1 To 11 Do
          If (a[cnt] <> '?') And (b[cnt] <> '?') And
          (UpCase(a[cnt])<>UpCase(b[cnt])) Then exit;
        theymatch:=True
      End;

    Begin
      Transform(w,a);
      Transform(f,b);
      WildCardMatch := TheyMatch
    End;

  Procedure SearchFile;
  Var Wild : Sstr;
      S : Mstr;
      X : Integer;
      OldArea,A,B,Y : Byte;
      All : Boolean;
  Begin
    Wild := '*.*';
    S[0] := #0;
    Repeat
      WriteHdr('Search Specs..');
      Writeln(^S'W'^R'ildcards'^A': '^S+Wild);
      Write(^S'S'^R'tring'^A': '^S);
      If S <> '' Then
        Writeln(S)
        Else Writeln('* None Specified *');
      Inpt[0] := #0;
      WriteStr(^M^R'Search Options - Edit ('^S'W'^R')ildcard or ('^S'S'^R')tring (Cr/Continues) : *');
      If Inpt = ''
        Then Inpt := '!';
      Case Upcase(Inpt[1]) Of
        'Q' : Exit;
        'W' : Begin
                Write(^R'Enter ['^S'New'^R'] Filename Search Specs'^A': ');
                InputBox(12);
                If Inpt <> ''
                  Then Wild := Inpt;
              End;
        'S' : Begin
                Write(^R'Enter ['^S'New'^R'] String to Search For'^A': ');
                InputBox(30);
                S := Inpt;
              End;
      End;
    Until (Inpt = '!') or (HungUpOn);
    If (Wild='*.*') AND (S='') Then Begin
      Writeln(^M^M^S'Pick something to search for!');
      Exit;
    End;
    S := UpString(S);
    OldArea := CurArea;
    DefYes := True;
    WriteStr(^M^R'Search '^S'all'^R' areas? !');
    Writeln;
    All := Yes;
    If All Then Begin
      A := 1;
      B := NumAreas;
    End Else Begin
      A := CurArea;
      B := CurArea;
    End;
    For A := A to B Do Begin
      SeekAFile(A);
      NRead(AFile,Area);
      If Allowed_In_Area(A,True,Area) Then Begin
        SetArea(A,False);
        Writeln(^R'Searching Area'^A' - '^S+Area.Name);
        For X := 1 to NumUds Do Begin
          LoadUDREC(X);
          All := False;
          If (WildCardMatch(UpString(Wild),UpString(UD.FileName)))
          Then All := True;
            If (S <> '') and (All) Then Begin
              All := False;
              For Y := 1 to 10 Do
                If Pos(S,UpString(Index.Descrip[ Y ])) > 0
                Then All := True;
              If Pos(S,UpString(Index.SentBy)) > 0
                Then All := True;
            End;
            If All Then Begin
              ListFile(X,False,S);
              ClearChain;
              Inpt[0] := #0;
              WriteStr(^R'Match found - ('^S'A'^R')dd Batch or ('^S'Q'^R')uit : *');
              If Inpt = '' then else
              If Upcase(Inpt[1]) = 'Q'
                Then Begin
                  SetArea(OldArea,True);
                  Exit;
                End else
              If Upcase(Inpt[1]) = 'A'
                Then Add_To_Batch(X,'',0,True);
              Writeln;
            End
        End
      End
    End;
    SetArea(OldArea,True);
  End;

(*


Var i:Integer;
   a:arearec;
   ms,Check,taxz,seenstats:boolean;
   tzz:Mstr;
   fi:file;
Label ok,exit,start;
Begin

  UpdateNode('In File Transer Area...');
  UDSection := -100;
  SeenStats := False;

  Start:

  EnterPw:=[];
  GetFileNewScan;
  Def := 0;
  If FilesInBatch < 1 Then
    Clear_Batchdown;
  CurSection := UDSysop;
  MS := False;
  Inpt := '';

  TZZ := 'AREAINDX.'+Strr(FileConf);

  Assign(UDIndex,Cfg.DataDir + TZZ);
  If Exist(Cfg.DataDir + TZZ)
  Then
    Reset(UDIndex)
  Else
    Rewrite(UDIndex);

  Tzz := 'AREADIR.'+strr(FileConf);

  Assign(AFile,Cfg.DataDir + Tzz);
  If Exist(Cfg.DataDir + Tzz)
  Then
    Begin
      Reset(afile);
      If FileSize(afile) > 0 Then GoTo ok
    End
  Else Rewrite(AFile);

  If (DefArea < 1) Or (DefArea > FileSize(AFile))
    Then DefArea := 1;

  WriteHdr('No File Areas Exist!');

  Area.Xmodemdir := Cfg.ViSiONDir + 'UPLOADS\';

  If IsSysop
    Then If MakeArea
      Then GoTo ok;
    GoTo exit;

  Ok :

  SeekAFile(DefArea);
  nRead(afile,a);

  If Not(Allowed_in_Area(DefArea,True,A)) Then Begin
    If (DefArea = 1) And (IsSysOp = False)
    Then Begin
      WriteLn(^S'You do not have access to the File Section!');
      Goto Exit;
    End
   Else Begin
     SeekAfile(1);
     nRead(afile,a);
     If Not(allowed_in_area(1,True,A)) Then Begin
      Writeln('You do not have access to the File Section!');
      If Not IsSysOp Then
        GoTo Exit
    End
  End
 End;

 If Not PCRatio Then Begin
   Writeln(^M^M);
   Writeln(^R'Your Post/Call Ratio is out of line. Go to the message bases and POST');
   Writeln('some messages in order to correct this!');
   WriteLn(^R'Your Required PCR'^A': '^S + Strr(Urec.PCR)+^R'%'^M);
   Goto Exit;
 End;

 AssignUD(False);
 SetArea(DefArea,False);

 If (ShowStuff) and (SeenStats=False) then Begin
   SeenStats:=True;
   If Not SeenXfrStats then Begin
     ViewTopTen(3);
     SeenXfrStats:=True;
   End Else Begin
     DefYes:=False;
     WriteStr(Strng^.ViewTTAgainStr);
     If Yes then ViewTopten(3);
   End;

   If Exist(Cfg.TextFileDir + 'FILESTAT.ANS')
     Then PrintFile(Cfg.TextFileDir + 'FILESTAT.ANS');

   Check:=False;
   For i:=1 to 9 Do
    If Urec.FileList[i] then Check:=True;
   If Not Check
     Then ConfigFileListings;

   if Exist(cfg.textfiledir+'Filenews.'+Strr(FileConf)) then
     Printfile(cfg.textfiledir+'Filenews.'+Strr(FileConf));

   If urec.lastnumfiles < status.totalfiles then Begin
       curarea:=1;
       DefYes:=True;
       WriteStr(Strng^.FileNewScanStr);
       If Yes
         Then Newscanall;
     End
   End;

    Repeat

      Def:=0;
      If withintime(cfg.xmodemclosetime,cfg.xmodemopentime) or (timetillnet<10) Then
      If Not issysop Then Begin
        If timetillnet < 10
          Then tzz:=cfg.netenc
          else tzz:=cfg.xmodemopentime;
        Writestr(^M^S'File section is closed at this time!');
        WriteLn(^P'The time is now   '^O': '^S,timestr(now));
        WriteLn(^P'File area opens at'^O': '^S,tzz);
        Goto Exit
      End Else If Not ms Then Begin
        WriteLn(^M^R'The File Section is closed until'^A': '^S+cfg.xmodemopentime);
        Ms:=True;
        Goto Exit
      End;

      If Cfg.UseRumors = 2
        Then RandomRumor;

      I := Menu(Cfg.FileMenuStr,'FILE','UDLFYA!SQ%NRVZXWT+BG*IKCJHEM-][');

      If hungupon Then GoTo exit;
      Case i Of
        1:Upload;
        2:Download(0); { ,'',0,True); }
        3,4:Listfiles(False,False,0);
	5:; { Yourudstatus; }
	21,6:Getarea;
        8:Searchfile;
        7:; {ZipFile;}
        10:Begin UDSection:=CurArea; Goto Exit; End;
        11:NewScanall;
        12:RemoveFromBatch(0,'');
        13:listarchive(True);
        14:ListFiles(False,True,LastOn); {newscan(LastOn,True);}
        15:printfile(cfg.textfiledir+'Wantlist.bbs');
        16:listfiles(True,False,0);
        17:typefile(True);
        18:Add_To_Batch(0,'',0,True);
        19:Begin
            ListBatch;  {batch_menu;}
            If FilesInBatch>0 Then
            Writeln(^M^R'To download these file(s), use the ['^A'D'^R']ownload command.');
           End;
        20:Logoff;
        22:FileInfo; {zipfile;}
        23:ConfigFileListings;
        24:FiXNewScan;
        25:If Cfg.MaxFileConf>1 then Begin
             DefArea := 1;
             Close(AFile);
             Close(UDFile);
             Close(UDIndex);
             UpdateNewScan;
             ChangeConf(False);
             { Assign(Fi,Cfg.UploadDir+'TEMPBAT.DAT');
               Erase(Fi);
               Close(Fi); }
             Goto Start;
           End;
        26:; { Help('FILEXFER.HLP'); }
        27:EditUpload;
        28:Begin
             WriteHdr('Jumping to Message Area');
             UDSection:=-32767;
             Goto Exit;
           End;
        29:Begin
             WriteStr('Reset Batch/Marked Files? !');
             If Yes Then Begin
               Clear_BatchDown;
               Writeln(^M'Batch list has been reset!');
             End;
           End;
        30:ScrollForward;
        31:ScrollBackward;
      End
      Until hungupon Or (i=9);

    Exit:

    Close(AFile);
    Close(UDIndex);
    Close(UDFile);

    UpdateNewScan;
    I := IOResult;
    UpdateNode('');
  End;

 *)


Begin
End.
