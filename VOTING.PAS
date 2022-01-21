{$R-,S-,I-,D-,F-,V-,B-,N-,L+,O+}

unit voting;

interface

procedure listchoices;
procedure getvote (mandatory : boolean);
procedure showresults;
procedure listtopics;
function addchoice : integer;
procedure addtopic;
procedure selecttopic;
procedure deltopic;
procedure removechoice;
procedure nexttopic;
procedure voteonmandatory;
function init_voting : boolean;

implementation

uses MNeT,configrt,gentypes,gensubs,subs1,subs2,userret,overret1;

var curtopic : topicrec;
const curtopicnum : integer = 0;

  function votefn (n:integer):sstr;
  begin
    votefn:='VOTEFILE.'+strr(n)
  end;

  procedure opentopicdir;
  var n:integer;
  begin
    assign (tofile,cfg.DATADIR+'VOTEDIR');
    reset (tofile);
    if ioresult<>0 then begin
      close (tofile);
      n:=ioresult;
      rewrite (tofile)
    end
  end;

  function numtopics:integer;
  begin
    numtopics:=filesize (tofile)
  end;

  procedure opentopic (n:integer);
  var q:integer;
  begin
    curtopicnum:=n;
    if isopen(chfile)
      then close (chfile);
    assign (chfile,cfg.datadir + votefn(n));
    reset (chfile);
    if ioresult<>0 then begin
      close (chfile);
      q:=ioresult;
      rewrite (chfile)
    end;
    seek (tofile,n-1);
    nread (tofile,curtopic)
  end;

  function numchoices:integer;
  begin
    numchoices:=filesize (chfile)
  end;

  procedure writecurtopic;
  begin
    seek (tofile,curtopicnum-1);
    NWrite (tofile,curtopic)
  end;

  Procedure Listchoices;
  Var Ch : Choicerec;
      Cnt : Integer;
  Begin
    Sr.C[1] := 'QU'; Sr.S[1] := CurTopic.TopicName; Sr.T[1] := 40;
    ListingFile(Cfg.TextFileDir + 'VCHOICES.TOP',True);

    Seek (Chfile,0);

    For Cnt := 1 to NumChoices do
    Begin
      Read (chfile,ch);

      Sr.C[1] := 'NU'; Sr.S[1] := Strr(Cnt); Sr.T[1] := 2;
      Sr.C[2] := 'NA'; Sr.S[2] := Ch.Choice; Sr.T[2] := 40;
      Sr.C[3] := 'TV'; Sr.S[3] := Strr(Ch.NumVoted); Sr.T[3] := 3;

      ListingFile(Cfg.TextFileDir + 'VCHOICES.MID',False);

      if break then exit
    End;
    ListingFile(Cfg.TextFileDir + 'VCHOICES.BOT',False);
  End;

  Function AddChoice : Integer;
  Var Ch : Choicerec;
  Begin
    AddChoice:=0;
    Write (^M^R'New Selection'^A': ');
    InputBox(40);
    If Length(Inpt) < 2
      Then Exit;
    Addchoice := NumChoices + 1;
    Ch.NumVoted := 0;
    Ch.Choice := Inpt;
    Seek (chfile,numchoices);
    NWrite (chfile,ch);
    Writelog (20,2,ch.choice)
  End;

  Procedure GetVote (Mandatory : Boolean);
  Var Cnt,Chn : Integer;
      K : Char;
      Ch : ChoiceRec;
      Tmp : Lstr;
      A : Boolean;
  Begin
    If Urec.Voted[CurTopicNum] <> 0 Then Begin
      Writeln (^M'Sorry, can''t vote twice!!'^G);
      Exit
    End;
    A := Ulvl >= Curtopic.Addlevel;
    ListChoices;
    Tmp := ^M^R'Your selection ['^A'?'^R'] List';
    If A
      Then Tmp := Tmp + ' ['^A'A'^R']dd';
    Tmp := Tmp + ': *';
    Repeat
      Writestr (Tmp);
      If (Length(Inpt) = 0) or Hungupon
        Then Exit;
      Chn := Valu(Inpt);
      If Chn = 0 Then Begin
        K := Upcase(Inpt[1]);
        if K = '?'
          Then ListChoices
          Else If k = 'A'
            Then if A
              Then Chn := Addchoice
              Else Writeln (^S'You may not add choices to this topic!')
      End
    Until Chn <> 0;
    If (Chn > NumChoices) or (Chn < 0) then begin
      writeln (^S'Choice number out of range!');
      exit
    end;
    Inc(CurTopic.NumVoted);
    Writecurtopic;
    Seek (chfile,chn-1);
    NRead (chfile,ch);
    Inc(Ch.NumVoted);
    Seek (chfile,chn-1);
    NWrite (chfile,ch);
    Urec.Voted[curtopicnum] := Chn;
    Writeurec;
    Writeln (^P'Thanks for voting!')
  end;

  Procedure ShowResults;
  Var Cnt,TPos,N : Integer;
      Ch : Choicerec;
      Percent : Real;
  Begin
    If Urec.Voted[curtopicnum]=0 Then Begin
      writeln (^S'Sorry, you must vote first!');
      exit
    End;
    Seek (chfile,0);
    Tpos := 1;
    For Cnt := 1 to Filesize (chfile) Do Begin
      NRead (chfile,ch);
      N := length(ch.choice)+2;
      If N > Tpos
        Then Tpos := N
    End;
    Writehdr ('The results so far...');
    Seek (chfile,0);
    For Cnt := 1 to NumChoices Do if not Break then Begin
      NRead (chfile,ch);
      Write(^R);
      Tab (ch.choice,tpos);
      Write(^A);
      Writeln (ch.numvoted)
    End;
    if NumUsers > 0
      Then Percent := 100.0 * curtopic.numvoted / numusers
      Else Percent := 0;
    Writeln (^M^S,percent:0:0,^R'% of '^S+strr(numusers)+^R' users have voted...'^M)
  end;

  Procedure ListTopics;
  Var t:topicrec;
      cnt:integer;
  Begin
    ListingFile(Cfg.TextFileDir + 'LISTVOTE.TOP',True);
    Seek (Tofile,0);
    For Cnt := 1 to NumTopics Do
      If Not Break Then Begin
        NRead (tofile,t);
        Sr.C[1] := 'NU'; Sr.S[1] := Strr(Cnt); Sr.T[1] := 2;
        Sr.C[2] := 'TO'; Sr.S[2] := T.TopicName; Sr.T[2] := 40;
        ListingFile(Cfg.TextFileDir + 'LISTVOTE.MID',False);
      End;
    ListingFile(Cfg.TextFileDir + 'LISTVOTE.BOT',False);
  End;

  Procedure AddTopic;
  Var T : TopicRec;
      Ch : ChoiceRec;
      U : UserRec;
      Cnt,Tpn : Integer;
  Begin
    If NumTopics >= MaxTopics Then
      Begin
        Writeln (^S'No more room to add a topic!');
        Exit
      End;
    Tpn := NumTopics + 1;
    Write (^R'Voting Question'^A': ');
    InputBox(40);
    If Length(Inpt) = 0
      Then exit;
    Writeln(^S'Adjusting User Voting Records...');
    T.TopicName := Inpt;
    T.Numvoted := 0;
    Writeurec;
    For Cnt := 1 to NumUsers Do Begin
      Seek (ufile,cnt);
      NRead (ufile,u);
      If U.Voted[Tpn] <> 0
        Then Begin
          U.Voted[tpn] := 0;
          Seek (ufile,cnt);
          NWrite (ufile,u)
      End
    End;
    ReadUrec;
    Writestr (^M^R'Make all users vote on this topic? !');
    T.Mandatory := Yes;
    Writestr (^R'Allow users to add their own choices? !');
    If Yes Then Begin
      WriteStr (^R'Level required to add choices? *');
      T.Addlevel := Valu(inpt)
    End Else T.Addlevel := MaxInt;
    Seek (tofile,tpn-1);
    NWrite (tofile,t);
    OpenTopic (tpn);
    Writeln (^M^B^R'Enter Voting Choices ('^A'Blank line to end'^R')...');
    Cnt := 1;
    Repeat
      Buflen := 40;
      Writestr (^R'Choice number '^A+strr(cnt)+^R': &');
      If Length(Inpt) > 0 Then Begin
        Inc(Cnt);
        ch.numvoted := 0;
        ch.choice := Inpt;
        NWrite (chfile,ch)
      End
    Until (Length(Inpt) = 0) or hungupon;
    Writeln (^S'Topic created!');
    Writelog (20,3,strr(tpn)+' ('+t.topicname+')')
  End;

  Procedure Maybeaddtopic;
  Begin
    WriteStr (^R'Create new topic? !');
    If Yes
      Then addtopic
  End;

  Procedure SelectTopic;
  Var Ch : Integer;
  Begin
    Inpt := Copy(inpt,2,255);
    If Inpt = ''
      Then Inpt := ' ';
    Repeat
      If Length(inpt) = 0
        Then exit;
      Ch := Valu(inpt);
      If Ch > NumTopics Then Begin
        Ch := Numtopics + 1;
        If IsSysOp
          Then Maybeaddtopic;
        If Numtopics <> Ch
          Then Exit
      End;
      If (Ch < 1) or (Ch > Numtopics) Then Begin
        If Inpt = '?'
          Then ListTopics;
        WriteStr (^M^R'Select voting topic ('^S'?/List'^R') : *');
        Ch := 0
      End
    Until (ch > 0) or hungupon;
    OpenTopic (ch)
  end;

  procedure deltopic;
  var un,cnt:integer;
      u:userrec;
      f:file;
      t:topicrec;
      tn:lstr;
  begin
    tn:=' topic '+strr(curtopicnum)+' ('+curtopic.topicname+')';
    writestr ('Delete topic '+tn+'? !');
    if not yes then exit;
    writelog (20,1,tn);
    close (chfile);
    erase (chfile);
    cnt:=ioresult;
    for cnt:=curtopicnum to numtopics-1 do begin
      assign (f,cfg.DATADIR+votefn(cnt+1));
      rename (f,votefn(cnt));
      un:=ioresult;
      seek (tofile,cnt);
      nread (tofile,t);
      seek (tofile,cnt-1);
      nwrite (tofile,t)
    end;
    seek (tofile,numtopics-1);
    truncate (tofile);
    if curtopicnum<numtopics then begin
      writeln ('Adjusting user voting record...');
      writeurec;
      for un:=1 to numusers do begin
        seek (ufile,un);
        nread (ufile,u);
        for cnt:=curtopicnum to numtopics do
          u.voted[cnt]:=u.voted[cnt+1];
        seek (ufile,un);
        nwrite (ufile,u)
      end;
      readurec
    end;
    if numtopics>0 then opentopic (1)
  end;

  procedure removechoice;
  var n:integer;
      delled,c:choicerec;
      cnt:integer;
      u:userrec;
  begin
    n:=valu(copy(inpt,2,255));
    if (n<1) or (n>numchoices) then n:=0;
    while n=0 do begin
      writestr (^M^P'Choice to delete ['^O'?'^P']/List '^R': *');
      n:=valu(inpt);
      if n=0
        then if inpt='?'
          then listchoices
          else exit
    end;
    if (n<1) or (n>numchoices) then exit;
    seek (chfile,n-1);
    nread (chfile,delled);
    for cnt:=n to numchoices-1 do begin
      seek (chfile,cnt);
      nread (chfile,c);
      seek (chfile,cnt-1);
      nwrite (chfile,c)
    end;
    seek (chfile,numchoices-1);
    truncate (chfile);
    curtopic.numvoted:=curtopic.numvoted-delled.numvoted;
    writecurtopic;
    write (^B^M'Choice deleted; updating user voting records...');
    writeurec;
    for cnt:=1 to numusers do begin
      seek (ufile,cnt);
      nread (ufile,u);
      u.voted[curtopicnum]:=0;
      seek (ufile,cnt);
      nwrite (ufile,u)
    end;
    readurec;
    writeln (^B'Done.')
  end;

  procedure nexttopic;
  begin
    if curtopicnum=numtopics
      then writeln ('No more topics!')
      else opentopic (curtopicnum+1)
  end;

  procedure voteonmandatory;
  var n:integer;
      t:topicrec;
  begin
    for n:=1 to numtopics do
      if urec.voted[n]=0 then begin
        seek (tofile,n-1);
        nread (tofile,t);
        if t.mandatory then begin
          opentopic (n);
          clearbreak;
          nobreak:=true;
          writehdr ('Mandatory Voting!');
          getvote (true);
          if urec.voted[curtopicnum]<>0 then begin
            writestr (^M^R'See results? !');
            if yes then showresults
          end
        end
      end
  end;

  function init_voting : boolean;
  begin
    init_voting := false;
    if isopen(tofile) then exit;
    close_them_all(tofile);
    opentopicdir;
    repeat
    if numtopics=0 then begin
      writehdr ('No voting topics right now.');
      if not issysop
        then exit
        else
          begin
            writestr (^R'Make first topic now? !');
            if yes
              then addtopic
              else exit
          end
    end
    until (numtopics>0) or hungupon;
    opentopic(1);
    init_voting := true;
  end;

begin
end.

  procedure sysopvoting;
  var q,dum:integer;
  begin
    writelog (19,1,curtopic.topicname);
    repeat
      q:=menu ('Voting sysop','VSYSOP','QACDR');
      if hungupon then exit;
      case q of
        2:addtopic;
        3:dum:=addchoice;
        4:deltopic;
        5:removechoice;
      end
    until (q=1) or hungupon or (numtopics=0)
  end;

var q:integer;
label exit;
begin
  cursection:=votingsysop;
  opentopicdir;
  repeat
    if numtopics=0 then begin
      if getmandatory then goto exit;
      writeln ('Sorry, Nothing to vote on right now...');
      if not issysop
        then goto exit
        else
          begin
            writestr ('Make topic #1? !');
            if yes
              then addtopic
              else goto exit
          end
    end
  until (numtopics>0) or hungupon;
  if hungupon then goto exit;
  if getmandatory then begin
    voteonmandatory;
    goto exit
  end;
  opentopic (1);
  writehdr ('The Voting Booths');
  writeln (^R'Number of topics'^O': '^S+strr(numtopics));
  Writeln;
  listtopics;
  repeat
    writeln (^M^R'Current Voting Topic ['^A+strr(curtopicnum)+^R']: '^S+curtopic.topicname);
    q:=menu ('Voting','VOTING','QS_VLR#*H%@');
    if hungupon then goto exit;
    if q<0
      then
        begin
          q:=-q;
          if q<=numtopics then opentopic (q);
          q:=0
        end
      else
        case q of
          2,8:selecttopic;
          3:nexttopic;
          4:getvote (false);
          5:listchoices;
          6:showresults;
          10:sysopvoting
        end
  until (q=1) or hungupon or (numtopics=0);
  if numtopics=0 then writeln (^B'No voting topics right now!');
  exit:
  close (tofile);
  close (chfile)
end;