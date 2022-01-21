{$R-,S-,I-,D-,F-,V-,B-,N-,L+,O+}

Unit Nuv;

Interface

Uses Gentypes;

Procedure AddToNUV(Name:Mstr);
Procedure ListAccounts;
Procedure NewScan(UseBars:Boolean);
Procedure VoteOn(Which:Byte; NewScan,UseBars:Boolean);
Function Init_NUV : Boolean;

Implementation

Uses Dos, MNET, Crt, ConfigRT, GenSubs, Windows, Subs1, UserRet, SubsOvr,
     Subs2, OverRet1, Mainr1;

Procedure AddToNUV(Name:Mstr);
VAR N:NUVRec;
    I,X,T:Integer;
Begin
    If IsOpen(NuvFile) Then Close(NuvFile);
    I := IoResult;
    Assign(NUVFile,Cfg.DataDir+'NUV.DAT');
    Reset(NUVFile);
    If IoResult<>0 Then
      Rewrite(NuvFile);
    T := FileSize(NuvFile);
    If Name = '' Then Begin
      WriteStr(^R'Add who to NUV? : *');
      Name := Inpt;
    End;
    For X:=1 to T Do Begin
      Seek(NuvFile,X-1);
      nRead(NuvFile,N);
      If Match(UpString(N.Who),UpString(Name)) Then Begin
        Writeln('That name is already in New User Voting!');
        Close(NuvFile);
        Exit;
      End;
    End;
    FillChar(N,SizeOf(N),0);
    N.TotalVoters := 0;
    N.Who := Name;
    N.When := Now;
    Seek(NuvFile,T);
    nWrite(NuvFile,N);
    Close(NuvFile);
End;

Procedure OpenNUVFile;
BEGIN
  ASSIGN(NUVFile,Cfg.DataDir+'NUV.DAT');
  If Exist(Cfg.DataDir + 'NUV.DAT')
    Then Reset(NUVFile)
    Else ReWrite(NUVFile);
END;

Function TotalNUV : Integer;
BEGIN
  TotalNUV := FileSize(NuvFile);
END;

Function AlreadyVoted(N:NuvRec):Byte;
Var X : Byte;
Begin
  AlreadyVoted:=0;
  For X:=1 to N.TotalVoters DO Begin
    If N.Voters[X]=Urec.Handle then Begin
      AlreadyVoted:=X;
      Exit;
    End
  End
End;

Function YesVotes(N:NuvRec):Byte;
Var X,
    T,
    Y : Byte;
Begin
  YesVotes := 0;
  Y := 0;
  T := N.TotalVoters;
  If T > 0 then Begin
    For X := 1 to T Do
      If N.Votes[X] then Inc(Y);
  End;
  YesVotes := Y;
End;

Procedure ListAccounts;
VAR X,A:Byte;
    N:NuvRec;
    U:UserRec;
Begin
  ListingFile(Cfg.TextFileDir + 'NUVLIST.TOP',True);

  Reset(NUVFIle);

  For X:=TotalNuv Downto 1 Do Begin
    Seek(NUVFile,X-1);
    nRead(NuvFile,N);
    If (N.Who <> '') Then Begin

      Sr.C[1] := 'NU'; Sr.S[1] := Strr(X); Sr.T[1] := 2;
      Sr.C[2] := 'NA'; Sr.S[2] := N.Who;   Sr.T[2] := 30;

      A:=AlreadyVoted(N);

      Sr.C[3] := 'VO'; Sr.T[3] := 3;

      If A > 0
        Then Sr.S[3] := YesNo(N.Votes[A])
        Else Sr.S[3] := 'New';

      ListingFile(Cfg.TextFileDir + 'NUVLIST.MID',False);
    End
  End;

  ListingFile(Cfg.TextFileDir + 'NUVLIST.BOT',False);
End;

Procedure DisplayStats(N : NuvRec);
VAR X,T,Y:Byte;

  Procedure Update;
  Begin
    Sr.C[1] := 'NA'; Sr.S[1] := N.Who;
    Sr.C[2] := 'YV'; Sr.S[2] := Strr(Y);
    Sr.C[3] := 'NV'; Sr.S[3] := Strr(T-Y);
  End;

Begin
  T := N.TotalVoters;
  Y := YesVotes(N);
  AnsiCls;

  Update; MultiColor(Strng^.NUV_Voting_On);
  Writeln;
  Update; MultiColor(Strng^.NUV_Yes_Votes);
  Writeln;
  Update; MultiColor(Strng^.NUV_No_Votes);
  Writeln(^M);
  Update; MultiColor(Strng^.NUV_Comment_Header);
  Writeln;

  IF T > 0
    Then For X := 1 to T Do Begin
      If N.Comment[x]<>'' Then Begin
        Write(^R);
        Tab(N.Voters[X],27);
        Writeln(^A':'^R' "'^S+N.Comment[X]+^R'"')
      End;
  End Else
  Writeln('No Comments Now!');
  Writeln;
End;

Procedure Validate(N:NuvRec);
VAR U:UserRec;
    I:Integer;
BEGIN
  IF Cfg.NuvValidate then Begin
    I:=LookUpUser(N.Who);
    IF I<=0 then Exit;
    Seek(UFile,I);
    nRead(UFile,U);
    U.Level := Cfg.NuvLevel;
    U.UDLevel := Cfg.NuvUDLevel;
    U.UDPoints := Cfg.NuvPoints;
    U.UDFRatio := Cfg.DefUdRatio;
    U.UDKRatio := Cfg.DefUDKRatio;
    U.Pcr := Cfg.DefPcr;
    U.MsgLength := Cfg.DefMsgLength;
    U.DailyKBLimit := Cfg.DefDailyKBLimit;
    U.SysopNote := Cfg.DefUserNote;
    WriteUFile(U,I);
    Writeln(N.Who+' has been auto-validated!');
    Notice(Cfg.SysopName,N.Who+' was Validated via New User Voting...');
  End Else Notice(Cfg.SysopName,N.Who+' has enough NUV YES Votes; Validate Him!!');
End;

Procedure AutoDelete(N:NUVRec);
VAR I:Integer;
    U:UserRec;
BEGIN
  If Cfg.NUVKill then Begin
    I := LookUpUser(N.Who);
    If I > 0 then Begin
      Close(NuvFile);
      DeleteUser(I);
      OpenNUVFile;
      Notice(Cfg.SysopName,N.Who+' was voted off the board and was auto-deleted!');
    End;
  End Else Begin
    Notice(Cfg.SysopName,'Delete '+N.Who+', he was voted off the board!!');
    RemoveFromNuv(N.Who,0);
  End;
End;

Function NUVComment : Lstr;
Begin
  NuvComment:='';
  MultiColor(Strng^.Enter_NUV_Comment);
  Inputbox(48);
  NuvComment := Inpt;
End;

Procedure VoteOn(Which:Byte; NewScan,UseBars:Boolean);
Label Done;
VAR N:NuvRec;
    A,T:Byte;
    K:Char;

    Procedure Help;
    Begin
      WriteHdr('New User Voting Help');
      Write(^S);
      Writeln(^R'['^A'Y'^R'] - Yes');
      Writeln(^R'['^A'N'^R'] - No');
      Writeln(^R'['^A'C'^R'] - Comment About User');
      Writeln(^R'['^A'I'^R'] - View Infoform');
      Writeln(^R'['^A'R'^R'] - Reshow Stats');
      Writeln(^R'['^A'Q'^R'] - Quit'^M);
   End;

   Procedure BarMenu;

   Const Bars : Array[1..6] of Sstr =
         (' Yes ',' No ',' Comment ',' Infoform ',' Reshow ',' Quit ');

         Keys : Array[1..6] Of Char =
         ('Y','N','C','I','R','Q');

         Spaces_Over : Array[1..6] Of Byte = (0,5,9,18,28,36);

   Var K:Char;
       X,Y,A:Byte;

      Procedure PlaceBar(Hi:Boolean);
      Var Go:Byte;
      Begin
        Go := X + Spaces_Over[A];
        Write(Direct,#13);
        Write(Direct,#27 + '[' + Strr(Go) + 'C');
        If Hi
          Then AnsiColor(Urec.Color7)
          Else AnsiColor(Urec.Color1);
        Write(^B+Bars[A]);
      End;

   Begin
     Y := WhereY;
     Write(^B^R'Voting'^A': '^S+N.Who+' '^O+Cfg.BarChar[1]+^R);
     X := WhereX - 1;
     Write(^B' Yes  No  Comment  Infoform  Reshow  Quit '^O+Cfg.BarChar[2]);
     A := 1;
     Placebar(true);
     Repeat
       K := ArrowKey(True);
       Case Upcase(K) Of
         'Y','N','C','I','R','Q':Begin
           Inpt[1] := K;
           Writeln(^R);
           Exit;
         End;
         ^A,^D,'8','4':Begin
           PlaceBar(False);
           Dec(A);
           If A < 1 Then A := 6;
           PlaceBar(True);
         End;
         #32,^B,^C,'6','2':Begin
           PlaceBar(False);
           Inc(A);
           If A > 6 Then A := 1;
           PlaceBar(True);
         End;
         #13:Begin
              Inpt[0] := #0;
              Inpt := Inpt + Keys[a];
              Writeln(^R);
              Exit;
             End;
       End;
     Until HungUpOn;
   End;

Begin
  If (Which > TotalNUV) OR (Which < 1)
    Then Exit;
  Seek(NuvFile,Which - 1);
  nRead(NuvFile,N);
  A := AlreadyVoted(N);
  T := N.TotalVoters;
  DisplayStats(N);
  If A > 0 then Writeln(^R'Your Vote'^A': '^S+YesNo(N.Votes[A]));
  Repeat
  If (BARS_OK) AND (UseBars)
    Then BarMenu
    Else Begin
      Sr.C[1] := 'NA'; Sr.S[1] := N.Who;
      WriteStr(Strng^.NUV_Vote_Prompt);
    End;
  K:=Upcase(inpt[1]);
  Case K Of
    'Y':Begin
        If A<=0 then Begin
          N.Voters[T+1]:=Unam;
          N.Votes[T+1]:=True;
          Inc(N.TotalVoters);
          Sr.C[1] := 'NA'; Sr.S[1] := N.Who;
          Writeln;
          MultiColor(Strng^.NUV_Yes_Cast);
          Writeln;
          N.Comment[T + 1] := NuvComment;
          A := AlreadyVoted(N);
        End Else Begin
          N.Votes[A]:=True;
          Writeln(^M^S'Vote changed to '^A'YES'^M)
        End;
        If YesVotes(N) >= Cfg.NUVY then Begin
          Validate(N);
          RemoveFromNuv(N.Who,0);
          Exit;
        End;
        If NewScan Then Goto Done;
        End;
    'N':Begin
        If A<=0 then Begin
          N.Voters[T+1]:=Unam;
          N.Votes[T+1]:=False;
          Sr.C[1] := 'NA'; Sr.S[1] := N.Who;
          Inc(N.TotalVoters);
          Writeln;
          MultiColor(Strng^.NUV_No_Cast);
          Writeln;
          N.Comment[T+1]:=NuvComment;
          A:=AlreadyVoted(N);
        End Else Begin
          N.Votes[A]:=False;
          Writeln(^M^S'Vote changed to '^A'NO'^M);
        End;
        If N.TotalVoters-YesVotes(N) >= Cfg.NUVN then Begin
          AutoDelete(N);
          Exit;
        End;
        If NewScan Then Goto Done;
        End;
    'C':If A<=0 then
          Writeln('You have to Vote First!') Else
        N.Comment[A]:=NuvComment;
    'I':If Cfg.NUVForm > 0
          Then Begin
            ShowInfoForms(N.Who,Cfg.NuvForm);
            Writeln(^S);
            AnsiReset;
            GoXy(1,24);
            HoldScreen;
            DisplayStats(N);
          End;
    'R':DisplayStats(N);
    '?':Help;
  End;
  Until (K='Q') or (Hungupon);
  Done:
  Seek(NuvFile,Which-1);
  nWrite(NuvFile,N);
End;

Procedure NewScan(UseBars:Boolean);
VAR X,A,T:Byte;
    N:NuvRec;
Begin
  WriteHdr('Scanning New Users...');
  T := 0;

  If TotalNUV < 1
    Then Exit;

  For X := (TotalNUV - 1) DownTo 0 Do Begin
    Seek(NuvFile,X);
    nRead(NuvFile,N);
    A := AlreadyVoted(N);
    IF A <= 0 then Begin
      Inc(T);
      VoteOn( (X + 1), True, UseBars);
      Writeln(^M^S'Continuing New User Scan...');
      Delay(500);
    End;
  End;

  If T < 1
    Then Writeln(^S'No New Users Found!');
End;

Function Init_NUV : Boolean;
Begin
  Init_Nuv := True;
  If IsOpen(NuvFile) Then EXIT;
  Close_Them_All(NuvFile);
  Init_Nuv := False;
  If (Urec.Level<Cfg.NuvUseLevel) OR (Cfg.UseNuv=False) Then Exit;
  OpenNuvFile;
  If TotalNuv <= 0 then begin
    close(nuvfile);
    writeln; multicolor(strng^.no_nuv_pending); writeln(^M);
    exit;
  end;
  Init_Nuv := True;
End;

begin
end.