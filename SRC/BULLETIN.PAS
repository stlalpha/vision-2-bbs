{$R-,S-,I-,D-,F+,V-,B-,N-,L+,O+}

Unit Bulletin;

Interface

Procedure GetHeaderType;
Procedure Postbul;
Procedure NewScanAll (Current_Only : Boolean);
procedure readnextbul;
Function Init_Message : Boolean;

Implementation

Uses Dos, MNet, Crt, Gentypes, Configrt, StatRet, GenSubs, Subs1,
     MailRet, Subs2, UserRet, TextRet, Mainr2, OverRet1, Flags,
     Windows, Mess0, Mess1, Mess2;

  Procedure CheckChars(M:Message);
  Label Ok;
  VAR X,Y:Byte;
      Total:Integer;
  Begin
    If M.Numlines = 0
      Then Exit;
    Total:=0;
    For X:=1 to M.Numlines Do Begin
      If M.Text[X]<>'' Then
        For Y:=1 to Length(M.Text[X]) Do
          If (M.Text[X][Y]<>#32) or (M.Text[X][Y]<>#0) Then Inc(Total);
      If Total>=Urec.MsgLength then Goto Ok;
    End;
    If Exist(Cfg.TextFileDir+'BADPOST.ANS') Then Begin
        Sr.C[1] := '|U'; Sr.S[1] := Urec.Handle;
        Sr.C[2] := '|T'; Sr.S[2] := TimeStr(Now);
        Sr.C[3] := '|D'; Sr.S[3] := DateStr(Now);
        Sr.C[4] := '|P'; Sr.S[4] := Strr(Urec.Nbu);
        Sr.C[5] := '|C'; Sr.S[5] := Strr(CharsUsed);
        Sr.C[6] := '|R'; Sr.S[6] := Strr(Urec.MsgLength);
        DataFile(Cfg.TextFileDir+'BADPOST.ANS');
     End Else
     Begin
      WriteHdr('You did not recieve credit for that post!');
      Writeln(^S'Required Length: '^O+strr(urec.msglength)+' characters');
      Writeln(^S'Your Msg Length: '^O+strr(charsused)+' characters');
    End;
    ansireset;
    Exit;
    Ok:
    Inc(Urec.Nbu);
    Writeurec;
  End;

  Procedure ConfigMsgHeader;
  Var Classified : Boolean;
  BEGIN
    Classified := B.Anon AND IsSysOp;
    Sr.C[1] := '|B'; Sr.S[1] := CurBoard.BoardName;
    Sr.C[2] := '|T'; Sr.S[2] := B.Title;
    Sr.C[3] := '|F'; If Classified
                       Then Sr.S[3] := Cfg.AnonymousStr
                       Else Sr.S[3] := B.LeftBy;
    Sr.C[4] := '|S'; Sr.S[4] := B.SentTo;
                     If B.Recieved Then Sr.S[4] := Sr.S[4] + ' (Read) ';
    Sr.C[5] := '|U'; If Classified
                       Then Sr.S[5] := '-/- Classified -/-'
                       Else Sr.S[5] := B.Status;
    Sr.C[6] := '|L'; Sr.S[6] := Strr(B.PLevel);
    Sr.C[7] := '|R'; Sr.S[7] := B.Realname;
    Sr.C[8] := '|#'; Sr.S[8] := Strr(CurBul);
    Sr.C[9] := '|N'; Sr.S[9] := Strr(NumBuls);
    Sr.C[10] := '|D'; If Classified
                        Then Sr.S[10] := '--/--/--'
                        Else Sr.S[10] := DateStr(B.When);
    Sr.C[11] := '|W'; If Classified
                        Then Sr.S[11] := '--:-- am'
                        Else Sr.S[11] := TimeStr(B.When);
    Sr.C[12] := '|P'; If B.RepNumber > 0
                        Then Sr.S[12] := Strr(B.RepNumber)
                        Else Sr.S[12] := 'None';
    Sr.C[13] := '|E'; Sr.S[13] := Strr(B.Replies);
    DataFile(Cfg.TextFileDir+'MSGHDR.'+Strr(Urec.MsgHdr));
    CurAttrib := 0;
  End;

  Procedure GetHeaderType;

    Procedure Pick_Header(X : Byte);
    Var Temp : Byte;
    Begin
      If Not Exist(Cfg.TextFileDir + 'MSGHDR.' + Strr(X))
      Then Begin
        AnsiCls;
        Writeln('Message Header #'+Strr(X)+' is not found!');
        HoldScreen;
        Exit;
      End;
      B.Title := 'ViSiON/2 Rocks!';
      B.LeftBy:= 'Crimson Blade';
      B.SentTo:= 'Everybody';
      B.Status:= 'All Around Swell Guy';
      B.PLevel:= 100;
      B.RealName := 'Ted Bundy';
      B.When := Now;
      B.RepNumber := 0;
      B.REplies := 0;
      B.Anon := False;
      Temp := Urec.MsgHdr;
      Urec.MsgHdr := X;
      ConfigMsgHeader;
      Writeln;
      WriteStr(Strng^.Pick_This_Header);
      If Not Yes
        Then Urec.MsgHdr := Temp
        Else Inpt := 'Q';
    End;

  Begin
    If Not Exist(Cfg.TextFileDir + 'MSGHDR.ANS')
    Then Begin
      Writeln('MSGHDR.ANS not found!.. please notify SysOp!');
      Exit;
    End;
    Repeat
      InputFile(Cfg.TextFileDir + 'MSGHDR.ANS');
      If Valu(Inpt) > 0 Then Begin
        Pick_Header(Valu(Inpt));
      End;
    Until (HungUpOn) or (Upcase(Inpt[1]) = 'Q');
  End;

  Procedure Readcurbul;
  Var Q   : AnyStr;
      T   : SStr;
      Cnt : Integer;
      Mp  : Boolean;

  Begin

    If CheckCurBul Then Begin

      If Urec.Msghdr < 1 Then Begin
        Writeln(^M);
        WriteHdr('Please select a message header now.');
        HoldScreen;
        GetHeaderType;
      End;

      GetBRec;

      IF Urec.MsgHdr > 0
        Then ConfigMsgHeader
        Else Begin
          Writeln(^G'No Message Header has been selected!');
          Delay(2000);
          Exit;
        End; {IF NOT EXIST MESSAGE.HDR}

      If Break
        Then Exit;

      PrintText (CurBFile1,CurBFile2,B.Line);

      If Curboard.EchoType > 0 Then Begin
        If CurBoard.EchoType = 2 Then Begin
          MultiColor(B.Origin1);
          Writeln;
          MultiColor(B.Origin2);
          Writeln;
        End
      End

    End;

    If (Not (B.Recieved)) And Match (B.SentTo,Unam)
    Then Begin
      B.Recieved := True;
      SeekBFile (curbul);
      NWrite (bfile,b);
    End;

    If CurBul > LastReadNum
    Then Begin
      LastReadnum := CurBul;
      NScan.LastRead[CurBoardNum] := B.Id;
      Dec(UnreadNewMsgs);
      Inc(Urec.LastNumMsgs)
    End;

   If NScan.LastRead[CurBoardNum] > NumBuls
      Then NScan.LastRead[CurBoardNum] := B.Id;

  End;

  function queryaccess:accesstype;
  begin
    queryaccess:=getuseraccflag (nscan,curboardnum)
  end;

  procedure autodelete;
  var cnt:integer;
  begin
    MultiColor(Strng^.Erase5MsgsStr);
    Writeln;
    for cnt:=6 downto 2 do delbul (cnt,true)
  end;

  procedure postbul;
  var l:longint;
      m:message;
      b:bulrec;
  begin
{    if ulvl<Cfg.postlevel then begin
      reqlevel(Cfg.postlevel);
      exit
    end; }
    If (ulvl<curboard.plevel) or (No_MsgSec in Urec.Config)
    or (Not CheckFlags(Urec.Flags,Curboard.postflags)) then Begin
      Writeln('Sorry, you can''t post on this Sub-Board!');
      Exit;
    End;
    CharsUsed := 0;
    M.Add_AutoSig := True;
    M.NumLines := 0;
    OkForTitle := True;
    L := Editor(M,True,True,'0','0',CurBFile1,CurBFile2);
    If L >= 0 then
      begin
        CheckChars(M);
        b.replies:=0;
        b.repnumber:=0;
        B.Origin1 := FidoSIG;
        B.Origin2 := ' * Origin: '+CurBoard.OriginLine+' ('+CurBoard.Address+')';
        b.anon:=m.anon;
        b.title:=m.title;
        b.when:=now;
        b.leftby:=unam;
        b.line:=l;
        b.plevel:=ulvl;
        b.status:=urec.sysopnote;
        b.sentto:=m.sendto;
        b.recieved:=false;
        b.V2_Net:=False;
        B.FidoNeT:=False;
        addbul (b);
        inc(Status.newposts);
        inc(Status.totalmsgs);
        inc(Log.Posts);
        inc(unreadnewmsgs);
        writelog(0,0,'Posted '+b.title);
        with curboard do Begin
          if autodel<=numbuls then autodelete;
          messages:=numbuls;
          End;
        WriteCurBoard;
      end
  end;

  procedure readbul;
  begin
    getbnum ('read');
    readcurbul
  end;

  procedure readnextbul;
  var t:integer;
  begin
    t:=curbul;
    curbul:=curbul+1;
    If curbul>numbuls then begin curbul:=t; exit end;
    readcurbul;
    if curbul=0 then curbul:=t
  end;

  procedure readnum (n:integer);
  begin
    curbul:=n;
    readcurbul
  end;

  procedure sendbreply;
  begin
    Quoting.MsgSec := False;
    Quoting.MsgNum := B.Line;
    Quoting.Title  := B.Title;
    Quoting.From   := B.LeftBy;
    Quoting.Anon   := B.Anon;
    Quoting.When   := B.When;
    Quoting.SendTo := B.SentTo;
    Quoting.TxtFile:= CurBFile1;
    Quoting.MailFile:= CurBFile2;
    if checkcurbul then begin
      getbrec;
      sendmailto (b.leftby,b.anon)
    end else begin
      getbnum ('Mail to');
      if checkcurbul then sendbreply
    end;
    Quoting.MsgSec := True
  end;

  var beenaborted:boolean;

  function aborted:boolean;
  begin
    if beenaborted then begin
      aborted:=true;
      Write(^B);
      exit
    end;
    aborted:=xpressed or hungupon;
    if xpressed then begin
      beenaborted:=true;
      MultiColor(Strng^.Msg_NewScan_Aborted);
      Writeln;
      {writeln (^B'Newscan aborted!')}
    end
  end;

    Function capfir(inString:STRING):char;
    begin
     capfir:=upcase(inString[1]);
    end;


  function forwardbackthread(search:lstr; forard:boolean):boolean;
  var Done:Boolean;
      old:word;
      cnt:integer;

      function matched(se:lstr):Boolean;
      VAR B:Boolean;
      Begin
        If Pos(' -Re: #',se)>0 then Se:=Copy(se,1,pos(' -Re: #',se)-1);
        B:=Pos(Search,UpString(Se))>0;
        Matched:=B;
      End;

      procedure stripsearch;
      Begin
        If pos(' -Re: #',search)>0 then Search:=Copy(Search,1,pos(' -Re: #',search)-1);
        Search:=UpString(Search);
      End;

      Begin
        StripSearch;
        Done:=False;
        Old:=CurBul;
        if forard then
            Repeat
              inc(curbul);
              getbrec;
              if matched(b.title) then done:=true;
            until Done or (curbul>=numbuls)
            else
             Repeat
               dec(curbul);
               getbrec;
               if matched(b.title) then done:=true;
             until done or (curbul<=1);
        if not done then curbul:=old;
        forwardbackthread:=done;
      end;

Procedure Scanboard(NewScan        : Boolean;
                    ScanDate       : Longint;
                    SearchTo,
                    SearchFrom     : Mstr;
                    RangeStart,
                    RangeEnd       : Word;
                    UpdatePointers : Boolean);

  Function GetNumNum(Title : Lstr) : Integer;
  Var EndPoint : Byte;
      A        : String[4];
  Begin
    Endpoint  := 0;
    Getnumnum := 0;
    Endpoint  := Pos(' -Re: #',title);
    If Endpoint < 1
      Then Exit;
    Inc(EndPoint,7);
    A[0] := #0;
    While ( Title[EndPoint] in ['0'..'9'] )
    And   ( Endpoint <= Length(Title) )
    Do Begin
      A := A + title[endpoint];
      Inc(Endpoint);
    End;
    GetNumNum := Valu(a);
  End;

  Function GetTitle(Title : Lstr; Reply : Word) : Lstr;
  Var Search : Boolean;
      Srcstr : Sstr;
      Cursrc : Word;
      Tit    : Lstr;
  Begin
    Srcstr := ' -Re: #';
    Search := False;
    Tit    := '';
    Cursrc := 0;
    Repeat
     If Pos(' -Re: #',title) <= 0
     Then Begin
       If Length(Title) >= 30 Then Delete(Title,21,10);
       gettitle := title + ' -Re: #'+Strr(Reply)+'-';
       exit;
     end;
     If Copy(Title,cursrc,length(srcstr)) = SrcStr
     Then Begin;
        Tit := Copy(title,1,cursrc-1);
        GetTitle := tit+' -Re: #'+strr(reply)+'-';
        Exit;
     End;
     If CurSrc = 79
     Then Begin
       Gettitle := title+' -Re: #'+strr(reply)+'-';
       Exit;
     End;
     Inc(cursrc);
    Until cursrc=80;
  End;

  Label Complete,Jump,Thread;
  Const Names:Array[1..10] of Sstr =(' Next ',' Reply ',' Again ',
                                    ' Skip ',' Thread ',' Post ',
                                    ' Jump ',' Mail ',' List ',' Quit ');
  Var NewMsgs, Oldb, Done, Priv : Boolean;
      Tt : Text;
      Wock, K : Char;
      Wock2, RepNumber : Word;
      Me : Message;
      I : Integer;
      L : Longint;
      T : Sstr;
      X,Y : Byte;
      Rep : lstr;
      Read_To : Word;

      Procedure PlaceBar(Hi:Boolean);
      Const Cols : Array[1..10] Of Byte = (2,8,15,22,28,36,42,48,54,60);
      Begin
        If Hi Then
          Ansicolor(Urec.Color7)
          Else ansicolor(urec.color3);
        Write(Direct,#13);
        Write(Direct,#27 + '[' + Strr(Cols[X] - 1) + 'C');
        Write(Names[x]);
      End;

  Var Okay : Boolean;
  Begin
    beenaborted:=false;
    newmsgs:=false;
    Quoting.MsgSec     := True;
    Quoting.AllowQuote := True;
    Quoting.TxtFile    := CurBFile1;
    Quoting.MailFile   := CurBFile2;

    Priv := Pos('*PRIV*',CurBoard.BoardName) > 0;

    If ScanDate > -1
      Then CurBul := 1
      Else CurBul := LastReadNum + 1;

    If CurBul > 0
      Then Dec(CurBul);

    If RangeStart > 0
      Then If RangeStart <= NumBuls
        Then CurBul := RangeStart - 1;

    If (RangeEnd > 0) And (RangeEnd <= NumBuls)
      Then Read_To := RangeEnd - 1
      Else Read_To := NumBuls;

    While Curbul <= Read_To
    Do Begin

      Inc(CurBul);

      If CurBul > NumBuls
        Then Exit;

      GetBRec;

      Okay := True;

      If (ScanDate > 0) And (B.When < ScanDate)
        Then Okay := False;

      If (SearchTo <> '') Then
        If Pos(UpString(SearchTo),UpString(B.SentTo)) = 0
          Then Okay := False;

      If (SearchFrom <> '') Then
        If Pos(UpString(SearchFrom),UpString(B.LeftBy)) = 0
          Then Okay := False;

      If Priv And (Match(B.SentTo,Unam)=False)
        Then Okay := FALSE;

      If Okay Then Begin

      Readnum (Curbul);
      NewMsgs := True;
      Repeat
        Wock := 'N';

        If (TimeLeft<1) and Not Local
        Then Begin
          PrintFile(Cfg.textfiledir+'TiMESUP.ANS');
          ForceHangup := True;
          Exit;
        End;

        If Not BARS_OK
        Then Begin
           Sr.C[1] := 'BN'; Sr.S[1] := CurBoard.BoardName;
           Sr.C[2] := 'CB'; Sr.S[2] := Strr(CurBul);
           Sr.C[3] := 'NB'; Sr.S[3] := Strr(NumBuls);
          If NewScan
             Then WriteStr(Strng^.Msg_NewScan_Prompt)
             Else WriteStr(Strng^.Msg_Reading_Prompt);
        End
        Else Begin
          Writeln;
          ClearChain;
          Inpt[0]:=#0;
          Break := False;
          XPressed := False;
          Sr.C[1] := 'BN'; Sr.S[1] := CurBoard.BoardName;
          Sr.C[2] := 'NU'; Sr.S[2] := CurBoardName;
          {Writeln(^R'Current Area'^A': '^S+CurBoard.BoardName);}
          MultiColor(Strng^.Current_Board_NewScan);
          Writeln;
          Bottomline;
          NoBreak:=True;
          ClearChain;
          Inpt[0]:=#0;
          Write(^B^O+Cfg.BarChar[1]+' '^P'Next  Reply  Again  Skip  Thread  Post  Jump  Mail  List  Quit '^O+Cfg.BarChar[2]);
          If NewScan
            Then Write(^R' ('^S'NewScan'^R')')
            Else Write(^R' ('^S'Reading'^R')');
          X := 1;
          PlaceBar(True);
          Clearbreak;
          Nobreak:=True;
          Done:=false;
          Repeat
            K := ArrowKey(True);
            Case Upcase(K) of
            ^A,^D,'8','4':
             Begin
               Nobreak:=True;
               PlaceBar(False);
               Dec(x);
               If X < 1
                 Then X := 10;
               PlaceBar(True);
               NoBreak := False;
             End;
             #32,^B,^C,'6','2':
             Begin
               NoBreak:=True;
               PlaceBar(False);
               Inc(x);
               If X > 10
                 Then X := 1;
               PlaceBar(True);
               NoBreak:=False;
             End;
             'A','N','R','G','J','S','P','M','T','Q','L':
             Begin
               If Upcase(K)='J' Then Goto Jump;
               If Upcase(K)='T' then Goto Thread;
               Done:=True;
               Inpt := K;
             End;
             #13 : Begin
               Case X Of
                 1:Begin Writeln(^S^R); Inpt := 'N'; End;
                 2:inpt:='R';
                 3:inpt:='A';
                 4:inpt:='S';
                 5:Begin
                     Thread:
                     Ansireset;
                     Writeln(^S);
                     WriteStr(Strng^.Thread_Which_Way);
                   End;
                 6:inpt:='P';
                 7:Begin
                     Jump:
                     Ansireset;
                     Sr.C[1] := 'NB';
                     Sr.S[1] := Strr(NumBuls);
                     Writeln(^S);
                     WriteStr(Strng^.Jump_To_Msg_Number);
                   End;
                 8:inpt := 'M';
                 9:inpt := 'L';
                 10:Inpt := 'Q';
               End;

               If X in [8..10]
                 Then Writeln(^S^M);

               Done:=True;

             End;
          End;

          Until (Done) Or (hungupon);

          Complete:
          Ansireset;
        End;

        If Length(Inpt) < 1
          Then Inpt := 'N';

        Wock := Upcase(inpt[1]);
        Wock2:=valu(inpt);
        If Wock2>0 then begin
          if wock2<=numbuls then begin
            curbul:=wock2;
            readnum (curbul);
          end;
        end else
          wock:=upcase(wock);
        case wock of
        'F':Begin
            If curbul<numbuls then Begin
              If not forwardbackthread(b.title,true) then WriteLn(^M^S'No Forward thread found!')
              else Begin
               getbrec;
               readnum(curbul);
              end;
              End;
             End;
        'B':If not curbul<1 then If not forwardbackthread(b.title,false) then WriteLn(^M^S'No backward thread found!')
            else
              Begin
                GetBrec;
                ReadNum(CurBul);
              End;
         '?':begin
              Writeln;
              Writehdr ('Bulletin NewScan Help');
              Writeln (^R'[N]ext Message          [#]Read that Message #');
              Writeln ('[A]Read Message Again   [R]eply to Message');
              Writeln ('[D]elete Message        [P]ost a Message');
              Writeln ('[S]Next Sub-board       [/]Toggle Auto-Scan');
              Writeln ('[B]ackwards Thread      [F]orward thread');
              if (match(unam,b.leftby)) or (issysop) or (sponsoron)
              then write ('[E]dit Message          ');
              writeln ('[Q]uit Newscan');
              writeln;
             end;
	 'A':readcurbul;
	 'P':postbul;
         'L':Begin
               AnsiReset;
               Writeln(^M);
               ListBuls;
             End;
         'M':Begin
               Writeln;
               SendBReply;
             End;
         'D':begin
              {reading:=true;}
              killbul;
              Dec(CurBul);
              {reading:=false;}
             end;
         'R':begin
              if ulvl<curboard.plevel then begin
                reqlevel(curboard.plevel);
                exit
              end;
              If (ulvl<curboard.plevel) or (No_MsgSec in urec.config) then Begin
                Writeln('Sorry, you can''t post on this Sub-Board!');
                exit;
              End;
              inc(b.replies);
               seekbfile (curbul);
               nwrite (bfile,b);
              okfortitle:=false;
              rep:=b.leftby;
              if b.anon then rep:=Cfg.anonymousstr;
              ReplyNum:=curbul;
              okfortitle:=false;
              Me.Add_AutoSig := True;
              Me.NumLines := 0;
              l:=editor(me,false,true,rep,b.title,CurBFile1,CurBFile2);
              okfortitle:=true;
              if l>=0 then
                begin
                  CheckChars(Me);
                  b.anon:=me.anon;
                  repnumber:=getnumnum(b.title);
                  inc(repnumber);
                  b.repnumber:=repnumber;
                  b.title:=gettitle(b.title,repnumber);
                  b.replies:=0;
                  b.when:=now;
                  b.sentto:=rep;
                  b.leftby:=unam;
                  b.status:=urec.sysopnote;
                  b.line:=l;
                  b.recieved:=false;
                  b.RealName:=Urec.RealName;
                  B.V2_Net:=False;
                  B.FidoNet:=False;
                    B.Origin1 := FidoSIG;
                    B.Origin2 := ' * Origin: '+CurBoard.OriginLine+' ('+CurBoard.Address+')';
                  b.plevel:=ulvl;
                  addbul (b);
                  inc(Status.newposts);
                  inc(Status.totalmsgs);
                  inc(Log.Posts);
                  inc(unreadnewmsgs);
                   with curboard do
                    if autodel<=numbuls then begin
                      autodelete;
                      if curbul>5 then curbul:=curbul-5 else curbul:=1;
                    end;
                end;
                ReplyNum:=0;
             end;
         'E':begin
              if checkcurbul then begin
              if (not match(b.leftby,unam)) and (not issysop) and (not sponsoron)
                then begin
                  writeln ('You didn''t post that!');
                end
              else begin
              reloadtext (CurBFile1,CurBFile2,b.line,me);
              me.title:=b.title;
              me.anon:=b.anon;
              if reedit (me,true) then begin
                writelog (4,6,b.title);
                deletetext (CurBFile1,CurBFile2,b.line);
                b.line:=maketext (CurBFile1,CurBFile2,me,'');
                if b.line<0 then begin
                  writestr (^M'Deleting bulletin...');
                  delbul (curbul,false)
                end else begin
                  seekbfile (curbul);
                  nwrite (bfile,b)
                 end
                end
               end;
              end;
             end;
         'S':Begin
              AnsiReset;
              Writeln(^P);
              exit;
             end;
         {'/':togglenewscan;}
         'Q':begin
              Writeln;
              quitnewscan:=true;
              exit;
             end;
       end;
       Until wock in ['N'];

       If Aborted
         Then Exit;

    End; (* If Okay Then Begin *)
    End;

    If CurBul > Numbuls
      Then CurBul:=NumBuls;

    if (postprompts in urec.config) and (newmsgs) and (ulvl>=curboard.plevel) and
    (newscan)
      then begin
        okfortitle:=true;
        defyes:=false;
        Writeln(^R^B);
        If BARS_OK
          Then Writeln;
        Sr.C[1] := 'CB';
        Sr.S[1] := Curboard.BoardName;
        WriteStr(Strng^.PostOnBoardStr);
        if yes then postbul
      end
  end;

  Procedure NewScanAll (Current_Only : Boolean);
  Label Done;
  Var Cb : Integer;
      OldCurBoard : Sstr;
      NonStop : Boolean;
      MsgTo, From : Mstr;
      ScanDate : Longint;
      UpdatePointers : Boolean;
      WhichAreas : Byte;
      Range_Start, Range_End : Word;

      Procedure ArrowBar;
      Const Bars : Array[1..6] of Sstr=(' Read ',' Post ',' Jump ',' Skip ',' Quit ',' NonStop ');
            Chars : Array[1..6] of Char=('R','P','J','S','Q','N');
      Var K:Char;
          X,Y,B:Byte;

          Procedure PlaceBar(Hi:Boolean; Backward : Boolean);
          Var Xx : Byte;
          Begin
            If Hi
              Then AnsiColor(Urec.Color7)
              Else AnsiColor(Urec.Color3);
            Write(Direct,#13);
            XX := X + ( 6 * (B - 1) );
            Write(Direct,#27 + '[' + Strr(XX) + 'C');
            Write(Direct,Bars[b]);
          End;

      Begin
        Write(^B^R'Msg Scanning... '^R'['^S+Strr(CurBul)+^O'/'^S+Strr(NumBuls));
        Write(^R'] '^O+Cfg.BarChar[1]);
        X := WhereX - 1;
        Write(^Z' Read ');
        Write(^B^P' Post  Jump  Skip  Quit  NonStop '^O+Cfg.BarChar[2]);
        B := 1;
        Repeat
          K := ArrowKey(True);
          Case Upcase(K) Of
           ^A,^D,'8','4':
             Begin
               NoBreak := True;
               PlaceBar(False,False);
               Dec(b);
               If B < 1
                 Then B := 6;
               PlaceBar(True,False);
               NoBreak:=False;
             End;
           ^B,^C,'6','2':
             Begin
               NoBreak:=True;
               PlaceBar(False,False);
               Inc(b);
               if B > 6
                 Then B := 1;
               PlaceBar(True,True);
               NoBreak:=False;
             End;
           #13:Begin
                Inpt[0] := #1;
                Inpt[1] := Chars[B];
                Writeln(^R);
                Exit;
               End;
           'R','P','J','S','Q','N':Begin
               Inpt[1]:=K;
               Writeln(^R);
               Exit;
             End;
          End;
        Until True = False;
      End;

      Procedure GetScanType;
      Var Done : Boolean;
          K : Char;

         Procedure ShowStuff;
         Begin
           WriteHdr('Message Scanning Setup');
           Write(^S'D'^R'ate: '^P);
           If ScanDate < 0
             Then Writeln('All New Messages')
             Else
           If ScanDate = 0
             Then Writeln('ALL Messages')
             Else Writeln('From: '+DateStr(ScanDate));
           Write(^S'T'^R'o  : '^P);
           If MsgTo <> ''
             Then Writeln('Search For ',MsgTo)
             Else Writeln('N/A');
           Write(^S'F'^R'rom: '^P);
           If From <> ''
             Then Writeln('Search For ',From)
             Else Writeln('N/A');
           Write(^S'R'^R'ange: '^P);
           If (Range_Start < 1) or (Range_End < 1)
             Then Writeln('All')
             Else Writeln(Strr(Range_Start)+'-'+Strr(Range_End));
           Writeln(^S'U'^R'pdate NewScan Pointers: '^P+YesNo(UpdatePointers));
           Write(^S'S'^R'can Which Areas?      : '^P);
           Case WhichAreas Of
             1 : Writeln('All Tagged Areas');
             2 : Writeln('ALL Areas in Conference');
             3 : Writeln('Current Area Only');
           End;
           Writeln(^S'A'^R'bort Message Scanning');
           Writeln;
         End;

      Begin
        Done := False;
        Repeat
          ShowStuff;
          Write(^R'Selection; ('^S'Cr'^A'/'^S'Scan'^R') : ');
          K := Upcase(WaitforChar(True));
          Writeln(K);
          Done := K in [#13,'A','Q'];
          Case K Of
            'D' : Begin
                    Write(^R'Scan From; '^S'A'^R'll, '^S'N'^R+
                    +'ew Messages, or Enter '^S'Date'^R': ');
                    WriteStr('*');
                    If Inpt <> '' Then
                      Case Upcase(Inpt[1]) Of
                        'A' : ScanDate := 0;
                        'N' : ScanDate := -1
                        Else ScanDate := DateVal(Inpt);
                      End;
                  End;
            'T' : Begin
                    Write(^R'"'^S'To'^R'" string to Search for ('^S'Cr/'+Unam+^R'): ');
                    WriteStr('*');
                    If Inpt = '' Then Begin
                      WriteStr('Search For Messages only to you? !');
                      If Yes
                        Then MsgTo := Unam
                        Else MsgTo[0] := #0;
                    End
                      Else MsgTo := Inpt;
                  End;
            'F' : Begin
                    Write(^R'"'^S'From'^R'" string to Search for : ');
                    WriteStr('*');
                    From := Inpt;
                  End;
            'U' : Begin
                    DefYes := True;
                    WriteStr(^R'Update NewScan Pointers as you read? !');
                    UpdatePointers := Yes;
                  End;
            'S' : Begin
                    Write(^S'M'^R'arked Areas, '^S'A'^R'll Areas, '^S'C'^R'urrent Area : ');
                    WriteStr('*');
                    Case Upcase(Inpt[1]) Of
                      'M' : WhichAreas := 1;
                      'A' : WhichAreas := 2;
                      'C' : WhichAreas := 3;
                    End;
                  End;
            'R' : Begin
                     WriteStr(^R'Range Start ('^S'1-'+Strr(NumBuls)+^R') : *');
                     If Valu(Inpt) > NumBuls
                       Then Range_Start := 0
                       Else Range_Start := Valu(Inpt);
                     If Range_Start = NumBuls
                     Then Range_End := Range_Start
                     Else
                     If Range_Start > 0 Then Begin
                       WriteStr(^R'Range End ('^S+Strr(Range_Start)+'-'+Strr(NumBuls)+^R') : *');
                       If (Valu(Inpt) > NumBuls)
                       Or (Valu(Inpt) < Range_Start)
                         Then Range_End := 0
                         Else Range_End := Valu(Inpt);
                     End
                   End;
            'A','Q' : ScanDate := -69;
          End;
        Until (Done) Or (HungUpOn);
      End;

  Begin
    OldCurBoard := CurBoardName;
    BeenAborted := False;
    Ansicls;

    ScanDate := -1;
    MsgTo[0] := #0;
    From[0] := #0;
    Range_Start := 0;
    Range_End := 0;
    UpdatePointers := True;

    If Current_Only
      Then WhichAreas := 3
      Else WhichAreas := 1;

    GetScanType;

    If ScanDate = -69
      Then Exit;

    WriteHdr ('Scanning Messages...');

    If Not Current_Only
      Then WriteLog(0,0,'Started Message NewScan; (Conf: '+Strr(MsgConf)+')');

    NonStop := False;
    QuitNewScan := False;

    If (FileSize(BDFile) = 1) Or (WhichAreas = 3)
    Then Begin
      Scanboard(True,ScanDate,MsgTo,From,Range_Start,Range_End,UpdatePointers);
      Exit
    End;

    For Cb := 0 To FileSize(bdfile) - 1
    Do Begin

      If Aborted
        Then Exit;

      If Haveaccess(Cb) Then
        If (Not (Cb In NScan.NewScanConfig))
        Or (WhichAreas = 2)
      Then Begin
        CurBoardName := Curboard.Shortname;
        OpenBFile;
        CurBul := LastReadNum;
        Sr.C[1] := 'CB';
        Sr.S[1] := CurBoard.BoardName;
        MultiColor(Strng^.NewScanBoardStr);
        Writeln(^B);
        If Not NonStop Then Begin

          If BARS_OK
          Then ArrowBar
          Else Begin
            Sr.C[1] := 'CB'; Sr.S[1] := Strr(CurBul);
            Sr.C[2] := 'NB'; Sr.S[2] := Strr(NumBuls);
            WriteStr(Strng^.AreaMsgNewScan);
          End;

          If Inpt = ''
            Then Inpt := 'R';

          Inpt[1] := Upcase(Inpt[1]);
          If Inpt[1] = 'N' Then NonStop := True Else
          If Inpt[1] = 'Q' Then QuitNewScan := True Else
          If Inpt[1] = 'S' Then Goto Done Else
          If Inpt[1] = 'P' Then PostBul Else
          If Inpt[1] = 'J' Then Begin
            Sr.C[1] := 'NB'; Sr.S[1] := Strr(NumBuls);
            Writeln;
            WriteStr(Strng^.Jump_To_Msg_Number);
            If ( Valu(Inpt)>0 ) and ( Valu(Inpt)<=NumBuls )
            Then Else Begin
              Writeln(^M'Invalid Entry!');
              Inpt:='R';
            End;
          End;

          If (Valu(Inpt)>0) and (Valu(Inpt)<=NumBuls)
          Then Begin
            Nscan.LastRead[Cb]:=Valu(Inpt)-1;
            LastReadNum:=Valu(Inpt)-1;
            CurBul:=Valu(Inpt)-1;
          End;

        End;

        If (Aborted) or (QuitNewscan)
          Then Exit;

        Curboard.Messages := NumBuls;
        WriteCurBoard;

        if (aborted) or (quitnewscan)
          Then Exit;

        Scanboard(True,ScanDate,MsgTo,From,Range_Start,Range_End,UpdatePointers);

        If UpdatePointers
          Then WriteScanRec(NScan,MsgConf);

        Done:
      end
    end;

    WriteLog(0,0,'Completed Message NewScan (Conf: '+Strr(MsgConf)+')');
    writeln (^B^M);
    WriteHdr('Newscan complete!');
    SetActive(OldCurBoard,False);
  End;

  Procedure noboards;
  begin
    writeln ('No sub-boards exist!');
    if not issysop then exit;
    defyes:=true;
    writestr (^R'Create the first sub-board now? !');
    if not yes then exit;
    writestr (^R'Enter its access name/number'^A': &');
    if not validbname(inpt) then writeln (^B'Invalid board name!') else begin
      curboardname:=inpt;
      makeboard
    end
  end;

  Function Init_Message : Boolean;
  Begin
    Init_Message := True;
    If (MsgConf < 1) OR (MsgConf > Cfg.MaxMsgConf) Then
      MsgConf := 1;
    If LastMsgConf <> MsgConf Then Begin
      If IsOpen(BDFile) Then CloseBDFile;
      If IsOpen(BFile) Then Close(BFile);
    End;
    If IsOpen(BDFile) Then Exit;
    Close_them_all(BDFile);
    LastMsgConf := MsgConf;
    OpenBDFile;
    if filesize(bdfile)=0 then begin
      noboards;
      if filesize(bdfile)=0 then begin
        closebdfile;
        Init_Message := False;
        exit;
      end
    end;
    if not haveaccess(0)
    then
      begin
        writehdr ('You do not have access to the first sub-board!');
        closebdfile;
        init_message := false;
      end;
    GetScanRec(NScan,MsgConf);
    Setfirstboard;
  End;

begin
end.

(*
label Start,exit;
var wo:word;
    SeenStats:Boolean;
begin
  UpdateNode('In Message Area...');
  SeenStats:=False;
  Start:
  Quoting.AllowQuote := True;
  Quoting.MsgSec := True;
  If MsgConf < 1
    Then MsgConf:=1;

  cursection:=bulletinsysop;
  openbdfile;

  if filesize(bdfile)=0 then begin
    noboards;
    if filesize(bdfile)=0 then begin
      closebdfile;
      goto exit
    end
  end;

  UnreadNewMsgs:=Status.totalmsgs-urec.lastnummsgs;
  if not haveaccess(0)
    then
      begin
        writeln (^B'You do not have access to the first sub-board!');
        Writeln(^B'(This is on Current Conferece #'+Strr(MsgConf));
        closebdfile;
        goto exit
      end;

  OkForTitle := True;
  GetScanRec(NScan,MsgConf);

  If (ShowStuff) and (SeenStats=False) Then Begin
    SeenStats:=True;
    IF Not SeenMsgStats then Begin
      ViewTopTen(1);
      SeenMsgStats:=True;
    End else Begin
      DefYes:=False;
      WriteStr(Strng^.ViewTTAgainStr);
      If Yes then ViewTopTen(1);
    End;
    If Exist(Cfg.textfiledir+'MSGNEWS.BBS')
     Then Printfile(Cfg.textfiledir+'MSGNEWS.BBS');
  End;

  SetFirstBoard;
  Replynum:=0;

  If (PostPrompts in urec.config) and (UnReadNewMsgs>0) then Begin
    DefYes:=True;
    WriteStr(Strng^.MsgNewScanStr);
    If Yes then NewScanall(False);
  End;

  Repeat
    If Cfg.UseRumors = 2
      Then RandomRumor;
    q:=menu (Cfg.MsgMenuStr,'BULLET','PRKFUDT*MQ#|%LNBAVZHES+WC!-][JOG');
    case q of
      1 : PostBul;
{      2 : Begin
            WriteStr(^R'Message to Start Reading At? '^O'['^P'1..'+strr(numbuls)+^O']: *');
            If (Valu(inpt)>0) and (Valu(inpt)<=numbuls) then Begin
              CurBul:=Valu(inpt);
              Scanboard(false);
              End;
            End; }
      3:;{downloadfile;}
      4,22:sendmailto (curboard.sponsor,false);
      5:;{uploadfile;}
      6:killbul;
      8,16,17:activeboard;
      7:Begin
          WriteHdr('Jumping To File Transfers');
          BulletinMenu:=-32767;
          Goto Exit;
        End;
      9:sendbreply;
      {12:if (not (hungupon) and (curbul<numbuls)) then readnextbul;}
      13:boardsponsor;
      14:listbuls;
      2,15:newscanall(Q=2);
      {18:If (CurBul<NumBuls) Then ScanBoard(true) Else Writeln('No new messages!');}
      19:togglenewscan;
      20:; { help ('MESSAGE.HLP'); }
      21:editbul;
      23,28:nextsubboard(True);
      24:readnum (lastreadnum+1);
      25:FixNewScan;
      26:GetHeaderType;
      27,29:NextSubBoard(False);
      30:If Cfg.MaxMsgConf>1 then Begin
           Close(BFile);
           CloseBDFile;
           WriteScanRec(NScan,MsgConf);
           ChangeConf(True);
           If MsgConf>0 then Goto Start Else Begin
             MsgConf:=1;
             Goto Exit;
           End;
         End Else Writeln(^M'There is only one conference...');
      31:QwkMenu;
      32:LogOff;
      else if q<0 then readnum (-q)
    end
  until (q=10) or hungupon or (filesize(bdfile)=0);

  BulletinMenu := 0;

  Exit:
  Quoting.AllowQuote := False;
  Quoting.MsgSec := False;
  Close (bfile);
  Closebdfile;
  WriteScanRec(NScan,MsgConf);
  UpdateNode('')
end;
*)
