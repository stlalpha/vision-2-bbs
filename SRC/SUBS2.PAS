{$R-,S-,I-,D-,F-,V-,B-,N-,L+}

unit subs2;

{ $define testingdevices}   (* Activate this define for test mode *)

interface

Uses Dos,Gentypes;

Var AverageCalls,AverageUls,AverageDls,AveragePosts : Integer;

Procedure BeepBeep;
Procedure SummonBEEP;
Procedure WriteCON (k:char);
Function charready:boolean;
Function readchar:char;
Function waitforchar(carriage:boolean):char;
Procedure clearchain;
Function charpressed (k:char):boolean;  { TRUE if K is in typeahead }
Procedure addtochain (l:lstr);
Procedure directoutchar (k:char);
Procedure handleincoming;
Procedure writechar (k:char);
Function ArrowKey(Enter:Boolean) : Char;
Procedure setscrptr;
Procedure SetHooks;
{$F+}
      Function Opendevice (var t:textrec):integer;
      Function Closedevice (var t:textrec):integer;
      Function Cleardevice (var t:textrec):integer;
      Function Ignorecommand (var t:textrec):integer;
      Function Directoutchars (var t:textrec):integer;
      Function Writechars (var t:textrec):integer;
      Function Directinchars (var t:textrec):integer;
      Function Readcharfunc (var t:textrec):integer;
{$F-}
Function getinputchar:char;
Procedure getstr(usecolor:boolean);
{Procedure PercentBar(First,Z:Mstr);}
Procedure writestr (s:anystr);
Procedure Node_Listing;
Procedure InputBox(A:Byte);
Procedure CLS;
{Procedure Average(Title,Suffix:Mstr; I,U:Integer);}
Procedure Header(q:lstr);
Function  Correct_Dir(S:String) : String;
Procedure Writehdr (q:lstr);
Function  Issysop:boolean;
Procedure reqlevel (l:integer);
Procedure datafile (fn:lstr);
Procedure printfile (fn:lstr);
Procedure inputfile (fn:lstr);
Procedure ListingFile(FN : Lstr; Top : Boolean);
  {
  procedure printtexttopoint (var tf:text);
  procedure skiptopoint (var tf:text);
  }
Function minstr (blocks:integer):sstr;
Procedure parserange (numents:integer; var f,l:integer; Name : Mstr);
function Check_Incoming_Messages : boolean;
Procedure Load_Emulation(Which : Byte);
Procedure Send_Node_Message(nuke:boolean);
(* Function menu (mname:mstr; mfn:sstr; choices:anystr):integer; *)
Function checkpassword (var u:userrec):boolean;
Function getpassword:boolean;
Procedure getacflag (var ac:accesstype; var tex:mstr);
Procedure GoXy(X,Y:Byte);
Procedure PrintXy(X,Y:Byte; S:AnyStr);
Procedure NoCRInput(Defualt:Mstr; L:Byte);
Procedure HoldScreen;
{Function Validphone(ShowStuff:Boolean):Boolean;
Procedure GetPhoneNum;}
procedure Tabul (n:anystr; np:integer);
{ Function ExecProto (X:Byte; Fn:AnyStr; UploadDir:Lstr) : Integer; }
Procedure MultiColor(M:String);

{ Type ListBufType = Array[1..$FFF] Of Char; }

const hot_keys_active : boolean = false;
      last_in_check   : longint = 0;
      check_is_okay   : boolean = true;
      multitaskername : mstr = 'None';
      force_pause     : boolean = false;

Var AnsiEditInUse,
    DefYes,
    KeepQuite : Boolean;
    Password,
    InptColor,
    InptX,
    InptY : Byte;
    RegMe,
    RegMe2  : Lstr;

{   ListBuf : ^ListBufType; }

Implementation

Uses Printer, DosMem, MNeT, Crt, OpenShare,
     Configrt, Gensubs, Subs1, Windows, Modem, Statret,
     SubsOvr, ChatStuf, MailRet, Later, PAVT150, PAVTIO, Video;

{$I DHOOKS.INC}

VAR WriteDot:Boolean;

Procedure BeepBeep;
Begin
  NoSound;
  Sound (200);
  Delay (10);
  NoSound
End;

procedure summonbeep;
var cnt:integer;
begin
  nosound;
  cnt:=2330;
  repeat
    sound (cnt);
    delay (10);
    Inc(Cnt,$C8);
  until Cnt > 4300;
  nosound
end;

Function charready : boolean;
var k:char;
begin
  if modeminlock then while numchars>0 do k:=getchar;
  if hungupon or keyhit
    then charready:=true
    else if online
      then charready:=(not modeminlock) and (numchars>0)
      else charready:=false
end;

Function ReadChar : Char;
Var K,Rk : Char;
    Ret  : Char;
    DoReFresh, Quite : Boolean;

Begin
  RequestChat := False;
  RequestCOM  := False;
  ReqSpecial  := False;

  If KeyHit Then
  Begin

    Quite := False;
    K := Bioskey;
    Ret := K;

    If Ord(K) > 127 Then Begin
      Ret := #0;
      DoRefresh := InGetStr;

      Case Ord(K) - 128 Of

      AvailToggleChar :
        Begin
          ToggleAvail;
          ChatMode:=false;
          DoRefresh:=true
        End;

      SysopcomChar : SysOpCommands;
      ChatChar     : ConfigChat(1);
      VertChatChar : ConfigChat(2);
      LineChat     : OneLineChat;
      BreakOutChar : Halt(E_ControlBreak);
      LessTimeChar : Dec(urec.timetoday);
      MoreTimeChar : Inc(urec.timetoday);
      NoTimeChar   : SetTimeleft (-1);
      SysNextChar  : SysNext := Not Sysnext;

      TimeLockChar :
        If Timelock
          Then TimeLock := False
          Else Begin
            TimeLock := True;
            LockedTime := Timeleft
          End;

      InLockChar   : ModemInLock := Not ModemInLock;
      OutLockchar  : SetOutLock (Not Modemoutlock);
      TempSysopChar: ToggleTempSysop;
      BottomChar   : Toggle_BottomLine;
      HangupChar   : Disconnect;

      16 :
        Begin
          Writeln(^G^M^M^R'You have not hit a key within'+
                  +' the allotted time limit.. disconnecting');
          Disconnect;
        End;

      TextTrapChar    : toggletexttrap;
      PrinterEchoChar : PrinterEcho := Not PrinterEcho;
      LineNoiseChar   : Line_Noise;
      GotoDosChar     : GotoDos;
      94              : Begin
                          No_Local_Output := Not No_Local_OutPut;
                          ClrScr;
                        End;

      59..68,114,30,48,32,18,35,37,38,50,20,47 : Quite:=True;
      1..128 : If Not Quite Then Ret := K;
    End;

    Case Ord(K) - 128 Of
      LeftArrow  : Ret := ^D;
      RightArrow : Ret := ^C;
      UpArrow    : Ret := ^A;
      DownArrow  : Ret := ^B;
    End;

    If AnsiEditinUse Then Begin
      Case Ord(K) - 128 Of
        72 : Ret := ^E;
        75 : Ret := ^S;
        77 : Ret := ^D;
        80 : Ret := ^X;
        115: Ret := ^A;
        116: Ret := ^F;
        73 : Ret := ^R;
        81 : Ret := ^C;
        71 : Ret := ^Q;
        79 : Ret := ^W;
        83 : Ret := ^G;
        82 : Ret := ^V;
        117: Ret := ^P;
      End
    End;

    If (DoRefresh) And (UseBottom > 0)
      Then BottomLine;
  End;

  Bottomline;
  End
    Else If Online Then
      Begin
        K := Getchar;
        Inc(TotalReceived);
        if ModemInLock
          Then Ret := #0
          Else Ret := K
      End;

  ReadChar := Ret
End;

  procedure updatelastcaller;
  var qf:file of lastrec;
      last,cnt,A:integer;
      l:lastrec;
  begin
    If (Urec.Handle='') Or (Unum<1)
      Then Exit;
    If (Keepquite) and (Local)
      Then Exit;
    assign (qf,Cfg.DATADIR+'Callers');
    reset (qf);
    if ioresult<>0
      then Begin
      Close(Qf);
      Exit;
    End;
    last:=filesize(qf);
    if last > maxlastcallers
      then last:=maxlastcallers;
    If Last > 19 Then Begin
      Seek(QF,19);
      Truncate(QF);
      Last:=19;
    End;
    Seek(Qf,0);
    nRead(Qf,L);
    L.MinsOn := Timer - LogonTime + 1;
    seek (qf,0);
    nwrite (qf,l);
    close (qf);
    Log.MinsUsed := Log.MinsUsed + (Timer - LogonTime);
  end;

function waitforchar(carriage:boolean):char;
var t:integer;
    k:char;
    timeout:minuterec;
    b : boolean;
begin
  t := timer + Cfg.mintimeout;
  if t >= 1440
    Then t:=t-1440;
  b := false;
  Repeat
    if check_is_okay then b := check_incoming_messages;
    if b then begin
      waitforchar := #13;
      clearchain;
      exit;
    end;
    if (Timer = T) Then Begin
      If Urec.Handle<>'' Then
        Writelog(0,0,'Logged off due to keyboard inactivity!');
      PrintFile(Cfg.TextFileDir+'TIMEOUT.ANS');
      TextAttr:=1;
      Disconnect;
      Ensureclosed;
      UpdateLastCaller;
      Halt(0);
    End;
    If MultiTasking Then Give_Up_Time;
  Until (Charready) or (ForceHangUp) or (HungUpOn);
  If HungUpOn Then Begin
    If Urec.Handle<>''
      Then Writelog(0,0,'Uh Oh! the punk DROPPED CARRIER!!!');
    TextAttr:=1;
    Disconnect;
    EnsureClosed;
    UpdateLastCaller;
    Halt(0);
  End;
  K := Readchar;
  If Not Carriage Then Begin
    if K = #13
      Then Waitforchar := #0
      Else WaitForChar := K;
  End Else Waitforchar := K;
end;

Procedure WriteCON (k:char);
Begin
    If No_Local_Output
      Then Exit;
    Parse_Avt1(K);
End;

procedure clearchain;
begin
  chainstr[0]:=#0
end;

function charpressed (k:char):boolean;  { TRUE if K is in typeahead }
begin
  charpressed:=pos(k,chainstr)>0
end;

procedure addtochain (l:lstr);
begin
  if length(chainstr)<>0 then chainstr:=chainstr+',';
  chainstr:=chainstr+l
end;

procedure directoutchar (k:char);
var n:integer;
begin
  if inuse<>1
    then writecon(k)
    else begin
      bottom;
      writecon (k);
      top
    end;
  if online and (not modemoutlock) and ((k<>#10) or uselinefeeds)
    then Begin sendchar(k); inc(totalsent); end;
  if texttrap then begin
    write (ttfile,k);
    n:=ioresult;
    if n<>0 then abortttfile (n)
  end;
  { if printerecho then write (lst,k); }
end;

procedure handleincoming;
var k:char;
begin
  k:=readchar;
  case upcase(k) of
    'X',^X,^K,^C,#27,' ':begin
      writeln (direct);
      break:=true;
      linecount:=0;
      xpressed:=(upcase(k)='X') or (k=^X);
      if xpressed then clearchain
    end;
    ^S:k:=waitforchar(true);
    else if length(chainstr)<255 then chainstr:=chainstr+k
  end
end;

Procedure WriteChar (k:char);

  Procedure Endofline;
  Var K : Char;
  Begin
    If (Timelock)
      Then SetTimeLeft (LockedTime);
    If (Urec.TimeLock)
      Then SetTimeLeft (9999);
    WriteCon(#10);
    WriteCon(#13);
    If Online Then SendChar(#10);
    If Online then SendChar(#13);
    if non_stop then exit;
    If not CheckPageLength Then
      if not force_pause then exit;
    Inc(LineCount);
    If LineCount>=Urec.DisplayLen then
      If (MorePrompts in Urec.Config) OR (Force_Pause)
    Then Begin
      Linecount := 1;
      MultiColor(strng^.ContinueStr);
      Repeat
        K := Upcase(WaitForChar(False));
      Until (HungUpOn) or (K iN [#0,#13,#32,'Y','N','S']);
      Write(Direct,#13);
      Write(Direct,#27 + '[K');
      Case K Of
        'S' : Non_Stop := True;
        'N' : Break    := True;
      End
    End
  End;

Begin
  if hungupon then exit;
  if k<=^Z then
    case k of
      ^J,#0:exit;
      ^Q:k:=^H;
      ^B:begin
           clearbreak;
           break:=false;
           exit
         End
      End;
  if break then exit;
  if k<=^Z then begin
    case k of
      ^G:beepbeep;
      ^L:cls;
      ^N,^R:ansireset;
      ^S:ansicolor (urec.color2);
      ^P:ansicolor (urec.color3);
      ^U:ansicolor (urec.color4);
      ^O:ansicolor (urec.color5);
      ^A:ansicolor (urec.color6);
      ^Z:ansicolor (urec.color7);
      ^H:Directoutchar (k);
      ^M:EndOfLine
    end;
    exit
  end;
  { if usecapsonly then k:=upcase(k); }
  directoutchar (k);
  if (keyhit or ((not modemoutlock) and online and (numchars>0)))
     and (not nobreak) then handleincoming
end;

Function ArrowKey(Enter : Boolean) : Char;
Var K:Char;
Begin
  K:=WaitForChar(Enter);
  If K = #9 Then Begin   (* Tab *)
    ArrowKey := ^C;
    Exit;
  End;
  if (k = #27) and (Not Local) then begin  (* Ansi Mode *)
    Repeat
      K := WaitForChar(Enter);
    Until (k<>'[') Or hungupon;
    Case K Of
      'A' : ArrowKey := ^A;  { Up }
      'B' : ArrowKey := ^B;  { Down }
      'C' : ArrowKey := ^C;  { Right }
      'D' : ArrowKey := ^D;  { Left }
    End;
    Exit;
  End Else
  If (K=#0) and (Not Local) Then Begin  (* Doorway Mode *)
    K:=WaitForChar(Enter);
    Case K Of
      'M' : ArrowKey := ^A;
      'K' : ArrowKey := ^B;
      'P' : ArrowKey := ^C;
      'H' : ArrowKey := ^D;
    End;
    Exit;
  End Else
    ArrowKey := K;
End;

function getinputchar:char;
var k:char;
begin
  if length(chainstr)=0 then begin
    getinputchar:=waitforchar(true);
    exit
  end;
  k:=chainstr[1];
  delete (chainstr,1,1);
  if (k=',') and (not nochain) then k:=#13;
  getinputchar:=k
end;

{$ifdef testingdevices}

procedure devicedone (var t:textrec; m:mstr);
var r:registers;
    cnt:integer;
begin
  write (usr,'Device ');
  cnt:=0;
  while t.name[cnt]<>#0 do begin
    write (usr,t.name[cnt]);
    cnt:=cnt+1
  end;
  writeln (usr,' ',m,'... press any key');
  r.ax:=0;
  intr ($16,r);
  if r.al=3 then halt
end;

{$endif}

{$F+}

function opendevice;
begin
  {$ifdef testingdevices}  devicedone (t,'opened');  {$endif}
  t.handle:=1;
  t.mode:=fminout;
  t.bufend:=0;
  t.bufpos:=0;
  opendevice:=0
end;

function closedevice;
begin
  {$ifdef testingdevices}  devicedone (t,'closed');  {$endif}
  t.handle:=0;
  t.mode:=fmclosed;
  t.bufend:=0;
  t.bufpos:=0;
  closedevice:=0
end;

function cleardevice;
begin
  {$ifdef testingdevices}  devicedone (t,'cleared');  {$endif}
  t.bufend:=0;
  t.bufpos:=0;
  cleardevice:=0
end;

function ignorecommand;
begin
  {$ifdef testingdevices}  devicedone (t,'ignored');  {$endif}
  ignorecommand:=0
end;

function directoutchars;
var cnt:integer;
begin
  for cnt:=t.bufend to t.bufpos-1 do
    directoutchar (t.bufptr^[cnt]);
  t.bufend:=0;
  t.bufpos:=0;
  directoutchars:=0
end;

function writechars;
var cnt:integer;
begin
  for cnt:=t.bufend to t.bufpos-1 do
    writechar (t.bufptr^[cnt]);
  t.bufend:=0;
  t.bufpos:=0;
  writechars:=0
end;

function directinchars;
begin
  with t do begin
    bufptr^[0]:=waitforchar(true);
    t.bufpos:=0;
    t.bufend:=1
  end;
  directinchars:=0
end;

function readcharfunc;
begin
  with t do begin
    bufptr^[0]:=getinputchar;
    t.bufpos:=0;
    t.bufend:=1
  end;
  readcharfunc:=0
end;

{$F-}

procedure getstr (usecolor : boolean);
var marker,cnt,Where:integer;
    p:byte absolute inpt;
    k:char;
    oldinput:anystr;
    done,wrapped:boolean;
    wordtowrap:lstr;

  procedure bkspace;

    procedure bkwrite (q:sstr);
    begin
      IF WriteDot THEN q:=^H+Cfg.BoxChar+B_(1);
      write (q);
      if splitmode and dots then Begin
        TextAttr:=121;
        GotoXy(Where,25);
        write (usr,q);
        Dec(Where);
      end;
    end;

  begin
    if p<>0
      then
        begin
          if inpt[p]=^Q
            then bkwrite (' ')
            else bkwrite (k+' '+k);
          p:=p-1
        end
{      else if wordwrap
        then
          begin
            inpt:=k;
            done:=true
          end }
  end;

  procedure sendit (k:sstr; n:integer);
  var temp:anystr;
      X:Byte;
  begin
    temp[0]:=chr(n);
    fillchar (temp[1],n,k[1]);
    NoBreak:=True;
    If K=^A then Write(B_(N)) Else
    write (temp);
  end;

  procedure superbackspace (r1:integer);
  var cnt,n:integer;
      whattosend:char;
  begin
    n:=0;
    IF WriteDot THEN WhatToSend:=Cfg.BoxChar Else WhatToSend:=' ';
    for cnt:=r1 to p do
      if inpt[cnt]=^Q
        then n:=n-1
        else n:=n+1;
    if n<0 then sendit (' ',-n) else begin
      If (Dots) And (SplitMode) Then Begin
        TextAttr:=117;
        GotoXy(Where-N,25);
        For Cnt:=1 to N Do Write(Usr,' ');
        Where:=Where-N;
      End;
      sendit (^H,n);
      sendit (whattosend,n);
      If WriteDot Then sendit (^A,n) Else Sendit(^H,n);
    end;
    p:=r1-1
  end;

  procedure cancelent;
  begin
    superbackspace (1)
  end;

  function findspace:integer;
  var s:integer;
  begin
    s:=p;
    while (inpt[s]<>' ') and (s>0) do s:=s-1;
    findspace:=s
  end;

  procedure wrapaword (q:char);
  var s:integer;
  begin
    done:=true;
    if q=' ' then exit;
    s:=findspace;
    if s=0 then exit;
    wrapped:=true;
    wordtowrap:=copy(inpt,s+1,255)+q;
    superbackspace (s)
  end;

  procedure deleteword;
  var s,n:integer;
      x:Byte;
  begin
    if p=0 then exit;
    s:=findspace;
    if s<>0 then s:=s-1;
    n:=p-s;
    p:=s;
    sendit (^H,n);
    If WriteDot then Sendit(Cfg.BoxChar,n) Else
    sendit (' ',n);
    If Not WriteDot Then sendit (^H,n) Else SendIt(Cfg.BoxChar,n);
    If (Dots) And (SplitMode) Then Begin
      TextAttr:=117;
      GotoXy(Where-N,25);
      For X:=1 to N Do Write(Usr,' ');
      Where:=Where-N;
    End;
  end;

  procedure addchar (k:char);
  Var Temp:String[1];
  begin
    if p<buflen
      then if (k<>#32) or (p>0) or wordwrap or beginwithspacesok
        then
          begin
            Inc(P);
            Inpt[0] := Chr(P);
            inpt[p]:=k;
            if dots
              then
                begin
                  writechar (Cfg.dotchar);
                  if splitmode then Begin
                    TextAttr:=121;
                    Crt.GotoXy(Where,25);
                    write (usr,k);
                    Inc(Where);
                  End;
                end
              else writechar (k)
          end
        else
      else if wordwrap then wrapaword (k)
  end;

  procedure repeatent;
  var cnt:integer;
  begin
    for cnt:=1 to length(oldinput) do addchar (oldinput[cnt])
  end;

  procedure tab;
  var n,c:integer;
  begin
    n:=(P+8) and 248;
    if n>buflen then n:=buflen;
    for c:=1 to n-p do addchar (#32)
  end;

  procedure getinput;
  var now, start, finish : longint;
  begin
    oldinput := inpt;
    ingetstr := true;
    done     := false;
    where    := password;
    If usebottom > 0 then bottomline;
    p:=0;
    repeat
      clearbreak;
      nobreak:=true;

      if (hot_keys_active) and (inpt > '') then begin
        start  := lget_ms;
        finish := start + 300;
        repeat
          give_up_time;
          now := lget_ms;
          if (now > finish) or (now < start)
            then done := true;
        until (keypressed) or (numchars > 0) or (done);
      end;

      if not done then
        k := getinputchar else
        k := #0;

      if hungupon then begin
        inpt:='';
        k := #13;
        done := true
      end;

      case k of
        ^I:tab;
        ^H:bkspace;
        ^M:done:=true;
        ^R:repeatent;
        ^X,#27:cancelent;
        ^W:deleteword;
        ' '..#254 : addchar (k);
        ^Q:if wordwrap and Cfg.bkspinmsgs then addchar (k)
      end;
    until done;
    If UseColor Then AnsiReset;
    If Online Then SendChar(#10);
    WriteCon(#10);
    If Online Then SendChar(#13);
    WriteCon(#13);
    if Splitmode and Dots then begin
      InitWinds;
      Bottomline;
    end;
    ingetstr:=false;
    hot_keys_active := false
  end;

  procedure divideinput;
  var p:integer;
  begin
    p:=pos(',',inpt);
    if p=0 then exit;
    addtochain (copy(inpt,p+1,255)+#13);
    inpt[0]:=chr(p-1)
  end;

begin
  che;
  clearbreak;
  linecount:=1;
  wrapped:=false;
  nochain:=nochain or wordwrap;
  If UseColor then ansicolor (urec.color4);
  getinput;
  if not nochain then divideinput;
  while inpt[length(inpt)]=' '
    do inpt[0]:=pred(inpt[0]);
  if (WordWrap = False) and (BeginWithSpacesOk = False) then
    while (length(inpt)>0) and (inpt[1]=' ')
      do delete (inpt,1,1);
  if wrapped
    then chainstr:=wordtowrap;
  wordwrap:=false;
  nochain:=false;
  beginwithspacesok:=false;
  dots := false;
  buflen := 80;
  linecount:=1
end;

procedure writestr (s:anystr);
var k,g:char;
    fromkbd,ex,Yes:boolean;
    usefile:boolean;

    Procedure PlaceYesNo;
    Begin
      ansireset; Write(#32);
      If Yes then ansicolor(urec.color7) ELSE Ansicolor(urec.color6);
      Write ('Yes');
      ansireset; Write('  ');
      IF Yes then ansicolor(urec.color6) ELSE ansicolor(urec.color7);
      Write ('No!');
      Write(B_(9));
      ANSiCOLOR(Urec.Color6);
    End;

begin
  che;
  clearbreak;
  ansireset;
  uselinefeeds:=linefeeds in urec.config;
  usecapsonly:=not (lowercase in urec.config);
  g:=s[length(s)];
  usefile := copy(s,1,2) = '%%';
  If Not (G in [';','*','&','!','@']) Then G:='$' Else
  s:=copy(s,1,length(s)-1);
  case g of
    ';':write (s);
    '*':begin
          write (s);
          lastprompt:=s;
          GetStr(True);
        end;
    '&','$':begin
          nochain:=true;
          if G = '$'
            Then MultiColor(S)
            Else Write (s);
          lastprompt:=s;
          if not usefile then
            getstr(true);
        end;
    '!','@':Begin
          nochain:=true;
          IF G='@'
            Then MultiColor(S)
            Else Write(s);
          Yes:=DefYes;
          PlaceYesNo;
          Repeat
            k:=ArrowKey(true);
            K := Upcase(K);
          if K in ['Y','N'] Then
          Begin
            IF k = 'Y' Then BEGIN
              inpt:='Y';
              If Not yes then yes:=true;
              placeyesno;
            END ELSE BEGIN
              inpt:='N';
              If yes then yes:=false;
              placeyesno;
            END;
            Writeln;
            Ansicolor(urec.color1); Write('');
            Exit;
          end else if
          Not (K in [#13,'N','Y']) then
          begin
            yes:=not yes;
            placeyesno;
           end else
           Begin
             If K=#13 Then Begin
             If Yes
              Then Inpt:='Y'
              Else inpt:='N';
             Writeln;
             Ansicolor(urec.color1); Write('');
             Exit;
           End;
         End;
      Until HungUpOn;
      End
    else writeln (s,k)
  end;
  clearbreak
end;

Procedure Node_Listing;
Var M : MultiNodeRec;
    X : Byte;
Begin
  If Not IsOpen(MNFile) Then
    Begin
      Assign(MNFile,Cfg.DataDir + 'MULTNODE.DAT');
      Reset(MNFile);
    End;
  ListingFile(Cfg.TextFileDir + 'NODELIST.TOP',True);
  For X := 1 to Cfg.TotalNodes Do Begin
    Seek(MNFile,X-1);
    NRead(MNFile,M);
    Sr.C[1] := 'NU'; Sr.S[1] := Strr(X);  Sr.T[1] := 2;
    Sr.C[2] := 'NA'; Sr.S[2] := M.Name;   Sr.T[2] := 28;
    Sr.C[3] := 'ST'; Sr.S[3] := Copy(M.Status,1,25); Sr.T[3] := 25;
    Sr.C[4] := 'BA'; Sr.S[4] := Copy(M.Baud,1,18);   Sr.T[4] := 18;
    ListingFile(Cfg.TextFileDir + 'NODELIST.MID',False);
  End;
  ListingFile(Cfg.TextFileDir + 'NODELIST.BOT',False);
End;

Procedure InputBox(A:Byte);
Var Back : Byte;
Begin
  Buflen:=A;
  If Cfg.UseBox then Begin
    back:=urec.color4;
    urec.color4:=31;
    Ansicolor(31);
    For A:=1 to A do Write(Cfg.BoxChar);
    Write(B_(A));
    WriteDot:=True;
    WriteStr('&');
    WriteDot:=False;
    urec.color4:=back;
    ansicolor(urec.color4);
  End Else
  WriteStr('&');
End;

procedure cls;
begin
  bottom;
  clrscr;
  bottomline
end;

procedure ClearScr;
Begin
  If AnsiGraphics in urec.config then Write(#27+'[2J');
End;

Procedure Header(q:lstr);
Begin
  Write(^B);
  Sr.C[1] := 'HD';
  Sr.S[1] := Q;
  MultiColor(Strng^.HeaderStr);
  Ansireset;
  Writeln(^M);
End;

Function Correct_Dir(S:String) : String;
Var Path : PathStr;
    F    : NameStr;
    Ext  : ExtStr;
    Temp : Lstr;
Begin
  If Urec.Graphics < 1
    Then Begin
      Correct_Dir := S;
      Exit;
    End;
  FSplit(S,Path,F,Ext);
  If EMUL.TextDir[ Length(EMUL.TextDir) ] <> '\'
    Then EMUL.TextDir := Emul.TextDir + '\';
  Temp := EMul.TextDir + F + Ext;
  If Not Exist(Temp)
    Then Correct_Dir := S
    Else Correct_Dir := Temp;
End;

Procedure WriteHDR (q:lstr);

Type BufArray = Array[1..3072] Of Char;

Var Buf : ^BufArray;
    Cnt : Byte;
    Fd : File;
    BufPos,EndBuf : Word;
    K : Char;
    S : String;

Begin

  S := Correct_Dir(Cfg.TextFileDir + 'HEADER.ANS');

  If Not Exist(S)
    Then Writeln(^R'ú '^A+Q+^R' ú')
    Else Begin

      Assign(FD,S);
      Reset(FD,1);

      If IoResult <> 0 Then Begin
        Close(FD);
        Exit;
      End;

      Dos_GetMem(Buf,3072);

      NBlockRead(FD,Buf^,3072,EndBuf);
      BufPos := 1;

    While Not ( BufPos > EndBuf ) or (HungUpOn) Do Begin

      K := Buf^[BufPos];
      Inc(BufPos);

      If K='|' Then Begin

        K := Buf^[BufPos];
        Inc(BufPos);

        Case K Of
        '*':Begin

             K := Buf^[BufPos];
             Inc(BufPos);

             For Cnt:=1 to Length(Q) Do Begin
               If Online Then SendChar(K);
               Writecon(K);
             End;

            End;
        '@':For Cnt:=1 to Length(Q) Do Begin
             If Online Then SendChar(Q[Cnt]);
             WriteCon(Q[Cnt]);
            End;

        'T':Write(TimeStr(Now));

        End;

      End Else Begin
        If Online Then SendChar(K);
        WriteCon(K);
     End
  End;

  Writeln(^B);

  Close(Fd);

  Dos_FreeMem(Buf);
  CurAttrib := 0;
  End
End;

function issysop:boolean;
begin
  issysop := (urec.level>=Cfg.sysoplevel)
          or (cursection in urec.config)
          or (TempSysOp);
end;

procedure reqlevel (l:integer);
begin
  writeln (^B'Nice try, but level ',l,' is required.')
end;

Procedure ListingFile(FN : Lstr; Top : Boolean);
Type LB = Array[1..$FFF] Of Char;
Var T : File;
    K : Char;
    S : Lstr;
    X : Byte;
    BufPos, Temp : Integer;
    EndBuf : Word;
    AddSpaces,FileOpen : Boolean;
    ListBuf : ^LB;

    Procedure CheckBuf;
    Begin
      If BufPos > EndBuf
      Then Begin
        BufPos := 1;

        NBlockRead(T,ListBuf^,$FFF,EndBuf);

        If ListBuf^[EndBuf] = #26
        Then Begin
          ListBuf^[EndBuf] := #0;
          Dec(EndBuf);
        End
      End
    End;

Begin

  FN := Correct_Dir(FN);

  If Not Exist(FN)
    Then Exit;

  Assign(T,FN);
  Reset(T,1);

  If IoResult <> 0 Then Begin
    Close(T);
    Exit;
  End;

  Dos_GetMem(ListBuf,$FFF);

  BufPos := 1;
  EndBuf := 0;
  CheckBuf;

  CheckPageLength := True;

  Repeat

    K := ListBuf^[BufPos];
    Inc(BufPos);
    CheckBuf;

    If (K='^') Or (K='|')
    Then Begin
      AddSpaces := K = '|';

      K := ListBuf^[BufPos];
      Inc(BufPos);
      CheckBuf;

      S := K;

      K := ListBuf^[BufPos];
      Inc(BufPos);
      CheckBuf;

      S := S + K;

      For X := 1 to 15
        Do If S = Sr.C[x]
        Then Begin
          S := Sr.S[x];
          If AddSpaces
            Then For X := Length(S) To (Sr.T[x] - 1)
              Do S := S + #32;
          If Sr.C[x] <> 'OL'
            Then Write(S)
            Else Subs1.MultiColor(S);
        End;
    End Else
      Write(K);

  Until (HungUpOn) Or (Break) Or (EndBuf < 1);

  If Break Then
    NukeOutput;

  CheckPageLength := False;
  Close(T);
  Dos_FreeMem(ListBuf);
  CurAttrib := 0;
  FillChar(Sr,SizeOf(Sr),0);
End;

Procedure DataFile(fn:lstr);

Type BufArray = Array[1..$3000] Of Char;

Var Buf : ^BufArray;
    Fd : File;
    K : Char;
    X : Byte;
    BufPos : Integer;
    EndBuf : Word;

    Procedure CheckBuf;
    Begin
      If BufPos > EndBuf Then Begin
        BufPos := 1;
        NBlockRead(FD,Buf^,$3000,EndBuf);
        If Buf^[EndBuf] = #26
        Then Begin
          Buf^[EndBuf] := #0;
          Dec(EndBuf);
        End
      End
    End;

Begin
  ClearBreak;

  FN := Correct_Dir(FN);

  Assign(FD,FN);
  Reset(FD,1);

  If IoResult <> 0 Then Begin
    Close(FD);
    Exit;
  End;

  EndBuf := 0;
  BufPos := 1;

  Dos_GetMem(Buf,$3000);

  CheckBuf;

  Repeat

    K := Buf^[BufPos];

    If K = '|' Then Begin

      Inc(BufPos);
      CheckBuf;
      K := Buf^[BufPos];

      X := 1;
      While (X < 16) Do Begin
        If Match('|'+K,Sr.C[x]) Then Begin
          Write(Direct,Sr.S[x]);
          X := 19;
        End;
        Inc(X);
      End;
      If X = 16 Then Write('|'+K);

    End Else Begin
      If Online
        Then SendChar(K);
      WriteCon(K);
    End;

    Inc(BufPos);
    CheckBuf;

  Until (EndBuf = 0) or (HungUpOn);

  FillChar(Sr,SizeOf(Sr),0);
  Close(Fd);
  Dos_FreeMem(Buf);
  Writeln(^M);
  CurAttrib := 0;
End;

Procedure PrintFile(FN : Lstr);

Label Abort;

Type BufArray = Array[1..$3000] Of Char;

Var Buf : ^BufArray;
    Fd : File; {Dos_Handle;}
    C,K : Char;
    S : String[2];
    BufPos : Integer;
    EndBuf : Word;
    Z : Byte;
    R : Real;

   Function LastCaller : Mstr;
   Var F : File Of LastRec;
       L : LastRec;
   Begin
     LastCaller := 'Nobody!';
     If Not Exist(Cfg.DataDir + 'CALLERS')
       Then Exit;
     Assign(F,Cfg.DataDir + 'CALLERS');
     Reset(F);
     If FileSize(F) > 1 Then Begin
       Seek(F,1);
       NRead(F,L);
       LastCaller := L.Name;
     End;
     Close(F);
   End;

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

  FN := Correct_Dir(FN);

  Assign(FD,FN);
  Reset(FD,1);

  If IoResult <> 0 then Begin
    Close(FD);
    Exit;
  End;

  EndBuf := 0;
  BufPos := 1;

  Dos_GetMem(Buf,$3000);

  CheckBuf;

  Repeat

    C := Buf^[BufPos];

    If C = '|' Then Begin

      Inc(BufPos);
      CheckBuf;
      S := Buf^[BufPos];
      Inc(BufPos);
      CheckBuf;
      S := S + Buf^[BufPos];

       If S='UH' then write(urec.handle) else
       if s='UP' then Write(Urec.PhoneNum) Else
       if s='AC' then For Z:=1 to 3 Do Write(Urec.PhoneNum[Z]) else
       If s='PX' then For Z:=4 to 6 Do Write(Urec.Phonenum[Z]) else
       If s='SX' then For Z:=7 to 10 Do Write(Urec.Phonenum[Z]) else
       if s='UL' then write(strr(urec.level)) else
       if s='FL' then write(strr(urec.udlevel)) else
       if s='FP' then write(strr(urec.udpoints)) else
       if s='NU' then write(strr(urec.uploads)) else
       if s='ND' then write(strr(urec.downloads)) else
       if s='UK' then write(strlong(urec.kup)) else
       if s='DK' then write(strlong(urec.kdown)) else
       if s='UN' then write(urec.sysopnote) else
       if s = 'TT' then write(urec.timetoday) else
       if s = 'NF' then write(status.totalfiles-urec.lastnumfiles) else
       if s = 'NP' then write(status.totalmsgs-urec.lastnummsgs) else
       if s = 'TC' then write(trunc(status.numcallers)) else
       if s = 'NM' then write(getnummail(unum)) else
       if s = 'TE' then write(timetillevent) else
       if s = 'CT' then write(status.callstoday) else
       if s = 'UU' then write(unum) else
       if s = 'LN' then write(Cfg.longname) else
       if s = 'SN' then write(Cfg.shortname) else
       if s = 'CP' then write(strr(Cfg.usecom)) else
       if s = 'CD' then write(datestr(now)) else
       if s = 'TI' then write(timestr(now)) else
       if s = 'TL' then write(timeleft) else
       If s = 'HA' then write(urec.hackattempts) else
       If s = 'RN' then write(urec.realname) else
       if s = 'TP' then write(urec.nbu) else
       If s = 'AT' then Write(Streal(urec.totaltime)) Else
       If s = 'PA' then HoldScreen Else
       If S = 'HS' then WriteStr('&') Else
       If s = 'ML' then Write(urec.msglength) else
       If s = 'KL' then Write(urec.dailykblimit) else
       If S = 'DT' then Write(urec.kdowntoday Div 1024) else
       If S = 'CS' then Write(ConnectStr) Else
       If S = 'LC' Then Write(LastCaller) Else
       if s = 'MT' then write(multitaskername) else
       if s = 'LO' then begin
         if urec.laston<>0 then
          write(datestr(subs1.laston)) else
         write('Never');
       end else
       if s = 'LT' then Begin
         if urec.laston<>0 then
          Write(TimeStr(Subs1.laston)) else
          Write('Never');
       End Else
       if s = 'UD' then begin
         If urec.udfratio>0 then
           Write(Strr(urec.udfratio)+'%')
           Else Write('Exempt');
       End Else
       If s= 'RK' then Begin
         If urec.udkratio>0 then
           Write(Strr(urec.udkratio)+'%')
           Else Write('Exempt');
       End Else
       If s= 'PR' then Begin
         If urec.pcr>0 then
         Write(Strr(Urec.Pcr)+'%')
         Else Write('Exempt');
       End Else
       If s= 'RU' then Begin
         R:=Percentage(urec.uploads,urec.downloads);
         write(streal(r)+'%')
       end else
       If S= 'KD' then Begin
         R:=Percentage(urec.kup,urec.kdown);
         Write(Streal(r)+'%');
       End Else
       if s = 'PC' then begin
         R:=Percentage(urec.nbu,urec.numon);
         Write(Streal(R)+'%');
       end else
       If S = 'EX' then Begin
         If (DateStr(Urec.Expires)='0/0/80') or (DateStr(Urec.Expires)='0/0/128')
         Then Write('Never') Else Write(Datestr(Urec.Expires));
       End Else
       Write('|'+S);

    End Else If C <> ^Z Then Begin

      If (In_Command = False) and (NumChars > 0) or (KeyPressed)
      Then Begin
        If KeyPressed Then
          K := BiosKey
        Else K := GetChar;
        If K in [#32,'X','x',^X]
        Then Begin
          NukeOutput;
          NukeInput;
          Goto Abort;
        End;
      End;

      If Online
        Then SendChar(C);

      WriteCon(C);

    End Else BeepBeep;

    Inc(BufPos);
    CheckBuf;

  Until (EndBuf = 0) or (HungUpOn);

  Abort :

  Close(Fd);
  Dos_FreeMem(Buf);

  Writeln(^M);
  CurAttrib := 0;

End;

Procedure Bars_File(FN:Lstr);

Type Bar_Record = Record
       X,Y    : Byte;
       HiLite : Byte;
       Regular: Byte;
       Return : SStr;
       Title  : MStr;
       HotKey : String[1];
     End;

     Bar_Array = Array[1..30] of Bar_Record;

Var  Bars : ^Bar_Array;
     Total,
     Cur  : Byte;
     Done : Boolean;
     S    : String;
     HotK : MStr;

     Procedure READ_IT_IN;

       Function Get_Next : Mstr;
       Var Temp: Mstr;
           Len : Byte Absolute Temp;
       Begin
         Len := 0;
         While S[1] = #44 Do Delete(S,1,1);
         While (S[1] <> #44) And (Length(S) > 0)
           Do Begin
             Inc(Len);
             Temp[Len] := S[1];
             Delete(S,1,1);
           End;
         Get_Next := Temp;
       End;

     BEGIN
       Bars^[Total].X      := Valu(Get_Next);
       Bars^[Total].Y      := Valu(Get_Next);
       Bars^[Total].HiLite := Valu(Get_Next);
       Bars^[Total].Regular:= Valu(Get_Next);
       Bars^[Total].HotKey := Get_Next;
       Bars^[Total].Return := Get_Next;
       Delete(S,1,1);
       Bars^[Total].Title  := S;
       HotK := HotK + Bars^[Total].HotKey;
     END;

     Procedure Write_Bar(HiLited:Boolean);
     Begin
       GoXy(Bars^[Cur].X,Bars^[Cur].Y);
       If HiLited Then
         AnsiColor(Bars^[Cur].HiLite) Else
         AnsiColor(Bars^[Cur].Regular);
       Write(Direct,Bars^[Cur].Title);
     End;

  Procedure Read_In_File;
  Var CurDir : PathStr;
      CurFile: NameStr;
      CurExt : ExtStr;
      T      : Text;
  Begin
    FSplit(FN,CurDir,CurFile,CurExt);
    Total := 0;
    Assign(T,CurDir + CurFile + '.BAR');
    Reset(T);
    While NOT Eof(T) Do
      Begin
        Readln(T,S);
        If (Valu(S[1])>0) OR (S[1] = '0') Then
          Begin
            Inc(Total);
            READ_IT_IN;
          End
      End;
    TextClose(T);
  End;

Var K : Char;
Begin
  Dos_GetMem(Bars,SizeOf(Bar_Array));
  FillChar(Bars^,SizeOf(Bars^),0);
  HotK  := '';
  Read_In_File;
  PrintFile(FN);
  Cur := 1;
  Done := FALSE;
  Repeat
    Write_Bar(True);
    K := ArrowKey(True);
    K := Upcase(K);
    Write_Bar(False);
    Case K OF
      ^A,^C : IF Cur > 1 THEN Dec(Cur) ELSE Cur := Total;
      ^B,^D : If Cur < Total THEN Inc(Cur) ELSE Cur := 1;
      #32   : PrintFile(FN);
      #13   : Done := TRUE;
    End;
    IF Pos(K,UpString(HotK)) > 0 THEN Begin
      Cur := Pos(K,HotK);
      Done := True;
    End;
  Until (HungUpOn) OR (Done);
  CurAttrib := 0;
  AnsiColor(Urec.Color4);
  INPT := Bars^[Cur].Return;
  Dos_FreeMem(Bars);
End;



Procedure InputFile(FN : Lstr);

Type BufArray = Array[1..$3000] Of Char;

Var Fd : File;
    Buf : ^BufArray;
    K : Char;
    B : String[4];
    BufPos : Integer;
    EndBuf : Word;

    Procedure CheckBuf;
    Begin
      If BufPos > EndBuf Then Begin
        BufPos := 1;
        NBlockRead(FD,Buf^,$3000,EndBuf);
        If Buf^[EndBuf] = #26
        Then Begin
          Buf^[EndBuf] := #0;
          Dec(EndBuf);
        End
      End
    End;


Var X : Byte;
    PathName : PathStr;
    FileName : NameStr;
    ExtName  : ExtStr;
Begin
  ClearBreak;
  Break := False;
  NoBreak := True;

  FN := Correct_Dir(FN);

  FSplit(FN,PathName,FileName,ExtName);

  If EXIST(Pathname+FileName+'.BAR') THEN
    Begin
      Bars_File(FN);
      EXIT;
    End;

  Assign(FD,FN);
  Reset(FD,1);

  If IoResult <> 0 Then Begin
    Close(FD);
    Exit;
  End;

  EndBuf := 0;
  BufPos := 1;

  Dos_GetMem(Buf,$3000);

  CheckBuf;

  Repeat

    K := Buf^[BufPos];

    IF K='|' Then Begin

      Inc(BufPos);
      CheckBuf;
      K := Buf^[BufPos];

      If K='B' Then Begin

        B[0]:=Chr(0);
        Repeat
         Inc(BufPos);
         CheckBuf;
         K := Buf^[BufPos];
         B := B + K;
        Until (K=';') or (Length(B) > 3);

        B[0] := Pred(B[0]);
        If (Valu(B)>=1) And (Valu(B)<81)
          Then Buflen:=Valu(B);

      End Else If K = '=' Then Begin
        B[0] := #0;
        Repeat
          Inc(BufPos);
          CheckBuf;
          K := Buf^[BufPos];
          If (K<>';') Then B := B + K;
        Until (K=';') or (Length(B) > 3);
        InptColor:=Valu(B);
     End Else Begin

      Inc(BufPos);
      CheckBuf;
      X := 1;
      While (X < 16) Do Begin
        If Match('|'+K,Sr.C[x]) Then Begin
          Write(Direct,Sr.S[x]);
          X := 19;
        End;
        Inc(X);
      End;
      If X = 16 Then Write('|'+K);
    End;

    End Else
    IF k='@' Then Begin

      InptX:=WhereX;
      InptY:=WhereY;
      Inpt[0] := #0;
      GetStr(False);

    End Else Begin
      If Online Then SendChar(K);
      WriteCon(k);
    End;

    Inc(BufPos);
    CheckBuf;

  Until (EndBuf = 0) or (HungUpOn);

  Close(Fd);
  Dos_FreeMem(Buf);
  CurAttrib := 0;

End;

(*
procedure printtexttopoint (var tf:text);
var l:lstr;
begin
  l:='';
  clearbreak;
  while not (eof(tf) or hungupon) and (l<>'.') do begin
    if not break then writeln (l);
    readln (tf,l)
  end
end;

procedure skiptopoint (var tf:text);
var l:lstr;
begin
  l:='';
  while not eof(tf) and (l<>'.') do
    readln (tf,l)
end;
*)

function minstr (blocks:integer):sstr;
var min,sec:integer;
    rsec:real;
    ss:sstr;
    Temp:Word;
begin
  If Pos('1200',ConnectStr)>0 Then Temp:=1200 Else
  If Pos('2400',Connectstr)>0 then Temp:=2400 Else
  If Pos('9600',Connectstr)>0 then Temp:=14400 Else
  If Pos('14400',ConnectStr)>0 Then Temp:=19200 Else
  If Pos('16800',ConnectStr)>0 Then Temp:=19200 Else
  If Pos('19200',ConnectStr)>0 then Temp:=19200 Else
  Temp := 19200;
  rsec:=1.38 * blocks * (1200/Temp);
  min:=trunc (rsec/60.0);
  sec:=trunc (rsec-(min*60.0));
  sec:=Round(60*sec/100);
  ss:=strr(sec);
  if length(ss)<2 then ss:='0'+ss;
  minstr:=strr(min)+':'+ss
end;

procedure parserange (numents:integer; var f,l:integer; Name : Mstr);
var rf,rl:mstr;
    p,v1,v2:integer;
begin
  f:=0;
  l:=0;
  if numents<1 then exit;
  Inpt := Copy(Inpt,2,255);
  If Inpt = '' Then
  repeat

    Sr.C[1] := 'ST'; Sr.S[1] := Name;
    Sr.C[2] := 'SR'; Sr.S[2] := '1';
    Sr.C[3] := 'ER'; Sr.S[3] := Strr(NumEnts);

    WriteStr(strng^.ListRange);

    If Inpt = '?'
      Then printfile (Cfg.textfiledir+'RANGEHEL.ANS');

    if (length(inpt)>0) and (upcase(inpt[1])='Q')
      Then exit

  until (inpt<>'?') or hungupon;

  if hungupon then exit;
  if length(inpt)=0 then begin
    f:=1;
    l:=numents
  end else begin
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
    end
  end;
  if (f<1) or (l>numents) or (f>l) then begin
    f:=0;
    l:=0;
    (* writeln (^R'('^S'Invalid range!'^R')') *)
  end;
  writeln (^B)
end;

Function Check_Incoming_Messages : Boolean;
Var X : Byte;
    MNI : Node_Message;
Begin
  check_incoming_messages := false;
  If Cfg.TotalNodes < 2
    Then Exit;
  inc(last_in_check);
  if last_in_check > 100 then
    last_in_check := 0 else exit;
  Assign(MNIFile,Cfg.DataDir + 'INCOMING.' + Strr(Cfg.NodeNum));
  If Not Exist(Cfg.DataDir + 'INCOMING.' + Strr(Cfg.NodeNum))
  Then Begin
    Rewrite(MNIFile);
    Close(MNiFile);
    Exit;
  End;
  Reset(MNIFile);
  If FileSize(MNIFile) < 1 Then
    Begin
      Close(MNIFile);
      Exit;
    End;
  check_is_okay := false;
  For X := 1 to filesize(mnifile)
  Do Begin
    Seek(MNIFile,X - 1);
    nRead(MNIFile,MNI);
    If MNI.Message <> '' Then Begin
      If urec.handle = mni.receiver then begin
        Writeln(^M^G^R'Incoming message from '^A+mni.author+^R' on node '+Strr(mni.nodefrom)+'.');
        Write(^R'"'^S);
        MultiColor(MNI.Message);
        Writeln(^R'"');
        holdscreen;
        chainstr := #13;
        check_incoming_messages := true;
        if mni.nukenode then begin
          rewrite(mnifile);
          close(mnifile);
          forcehangup := true;
          exit;
        end
      end
    end;
  end;
  rewrite(mnifile);
  close(mnifile);
  check_is_okay := true;
end;

Procedure Load_Emulation(Which : Byte);
Var S : File of StringRec;
Begin
  Assign(EMUFile,Cfg.DataDir + 'EMULATE.DAT');
  Reset(EMUFile);
  If IOResult <> 0 Then Begin
    Close(EMUFile);
    Rewrite(EMUFile);
    EMul.Name      := 'ViSiON/2';
    EMul.TextDir   := Cfg.TextFileDir;
    EMul.AllowBars := True;
    EMul.MaxLevel  := 32767;
    Emul.Identity  := 1;
    NWrite(EMUFile,Emul);
    Close(EMUFile);
    Exit;
  End;
  Seek(EMUFile,Which-1);
  NRead(EMUFile,Emul);
  If Emul.TextDir[ Length(Emul.TextDir) ] <> '\'
    Then Emul.TextDir := Emul.TextDir + '\';
  If Exist(Emul.TextDir + 'STRINGS.DAT')
    Then Begin
      Assign(S,Emul.TextDir + 'STRINGS.DAT');
      Reset(S);
      If IoRESULT = 0
        Then Read(S,Strng^);
      Close(S);
    End;
  If (Emul.TextDir = '') or (Emul.Identity < 1)
  Then Begin
    Seek(EMUFile,0);
    NRead(EMUFile,Emul);
  End;
  Close(EMUFile);
End;

Procedure Open_Message_File(Where : Byte);
Var MNI : Node_Message;
    X : Byte;
Begin
  Assign(MNIFile,Cfg.DataDir + 'INCOMING.' + Strr(Where));
  If Not Exist(Cfg.DataDir + 'INCOMING.' + Strr(Where))
  Then Begin
    Rewrite(MNIFile);
    Exit;
  End;
  Reset(MNIFile);
End;

Procedure Close_Message_File;
Begin
  Close(MNIFile);
End;

procedure send_node_message(nuke:boolean);
var mni : node_message;

  function get_which_node : byte;
  var which : byte;
  begin
    get_which_node := 0;
    repeat
      which := 0;
      writestr(^R'Send to which Node ('^S'?/Lists'^R') #?'^A' : *');
      if inpt = '?' then node_listing else
      if inpt = '' then exit else
      which := valu(inpt);
      if which > cfg.totalnodes then
        begin
          writeln('Invalid Node #!');
          which := 0;
        end;
      if which = cfg.nodenum then
        begin
          writeln('Send a message to yourself?');
          which := 0;
        end;
    until (hungupon) or (which > 0);
    get_which_node := which;
  end;

  function get_node_name(x:byte) : mstr;
  var m : multinoderec;
  begin
    if not isopen(mnfile) then begin
      assign(mnfile,cfg.datadir + 'MULTNODE.DAT');
      reset(mnfile);
    end;
    seek(mnfile,x-1);
    nread(mnfile,m);
    get_node_name := m.name
  end;

var nodenum : byte;
    who     : mstr;
begin
  fillchar(mni,sizeof(mni),0);
  writehdr('Send Multi-Node Message');
  nodenum := get_which_node;
  if nodenum < 1 then exit;
  buflen := 77;
  who := get_node_name(nodenum);
  mni.nukenode := false;
  if nuke then
    begin
      defyes := false;
      writestr(^R'Are you sure you want to nuke '+who+'? !');
      if not yes then exit;
      mni.nukenode := true;
      writeln('After '+who+' receives the following message, he will be nuked!');
    end;
  writeln(^R'Message to send to '+who+' on node '+strr(nodenum)+^O'.');
  writestr(': &');
  if inpt = '' then
    begin
      writeln(^S'Aborted!');
      exit;
    end;
  mni.message := inpt;
  mni.author  := unam;
  mni.receiver:= who;
  mni.when    := now;
  mni.nodefrom:= cfg.nodenum;
  open_message_file(nodenum);
  seek(mnifile,filesize(mnifile));
  nwrite(mnifile,mni);
  close_message_file;
end;

(*

Function Menu (MName : Mstr; Mfn : Sstr; Choices : Anystr) : Integer;
Var K : Char;
    SysMenu,
    Percent,
    NeedSys : Boolean;
    N,P,I,X : integer;
    Prompt  : Lstr;

Begin
  Sysmenu := False;
  Percent := False;
  Nobreak := True;
  CheckPageLength := False;
  Non_Stop := False;

  For P := 1 To Length(choices)-1 do
    If Choices[p] = '%'
      then if choices[P+1] = '@'
        then percent:=true
        else
      else if choices[P+1] = '@'
        then sysmenu:=true;

  Writeln (^B);

  Repeat

    If ChatMode
      Then For N := 1 to 3
        Do SummonBeep;

    If Cfg.TotalNodes > 1
      Then Check_Incoming_Messages;

    If ((TimeLeft < 1) or (TimeTillEvent<=5) or (TimeTillNet <=5))
    Then Begin

      If Local Then Begin
        SetTimeLeft(1000);
        Exit;
      End;

      If (IsSysop) and (TimeTillEvent > 5) And (TimeTillNet > 5)
        Then Begin
          Writeln(^S'Your Time Left is set at'^A': '^U+strr(timeleft));
          DefYes := True;
          WriteStr(^R'Enter new Time? !');
          If Yes then Begin
            WriteStr(^R'New Time'^A': *');
            If length(inpt)>0 then settimeleft(valu(inpt));
          End;
          Exit;
        End;

      If (TimeTillEvent <= 5) Or (TimeTillNet <= 5)
        Then Writeln(^M^M^M^R^G+'A Timed Event is about to take place.  Call back later.')
        Else Printfile (Cfg.textfiledir+'TIMESUP.');

      ForceHangup := True;
      Menu := 0;
      Inpt[1] := WaitForChar(True);
      Exit
    End;

    If (RegSysOp <> Cfg.SysOpName) or (RegSysOp = UnReg) Then Begin
      If (RegMe[1] <> #86) or (RegMe[25] <> #103)
        Then Repeat
        Until RegMe = 'HEX_EDITORS := GEEKS';
      Writeln(^R+RegMe);
      Writeln(RegMe2);
    End;

    Sr.C[1] := 'MN';
    Sr.S[1] := MName;
    Bottomline;
    Write(^B);
    Subs1.MultiColor(Urec.Prompt);
    If HotKeys in urec.config then Begin
      ChainStr[0]:=#0;
      Begin
      Repeat
        K := WaitForChar(True);
        Inpt := K;
        If (inpt=#13) and (Pos('_',Choices)>0) then inpt:='_';
        If (Valu(K)>0) and (Pos('#',Choices)>0) then Begin
          Inpt:='';
          If K<>#8 then Write(K);
          Repeat
           If K<>#8 then inpt:=inpt+K;
           K:=WaitForChar(True);
           If (K=#8) and (inpt[0]>Chr(0)) then Begin
             Write(^H+' '^H);
             Inpt[0]:=Pred(inpt[0]);
           End
             Else If K<>#8 then Write(K);
      Until (K=#13) or (HungUpOn);
      End;
    Until (Pos(Upcase(K),Choices)>0) or (K in [#13,'/','?'])
          or (Hungupon) or (ChainStr>'') or (Length(inpt)>1);

    If ChainStr>'' then Begin
      K := ChainStr[1];
      ChainStr:='';
    End;

    If K='/' then Begin
      Inpt:='';
      If K<>#8 then Write(K);
      Repeat
        If K <> #8
          Then Inpt := Inpt + K;
        K := WaitForChar(True);
      If (K=#8) and (inpt[0]>Chr(0)) then Begin
        Write(^H+' '^H);
        inpt[0]:=Pred(inpt[0]);
    End Else If K<>#8 then Write(K);

    Until (K=#13) or (HungUpOn);

    Writeln;

    End Else Begin
      If K=#13 then Begin
        K:='_';
        Writeln;
      End Else
      Write(K);
      End;
    End;

    Bottomline;
    NoChain:=False;
    End
    Else WriteStr('*');

    Bottomline;
    N := 0;
    If Length(Inpt) = 0
      Then K := '_'
      Else
        Begin
          if (match(inpt,'/OFF')) OR (match(inpt,'/O')) then begin
            Inpt[0] := #0;
            Urec.lastnummsgs := Status.TotalMSGS;
            Urec.lastnumfiles:= Status.TotalFILES;
            ForceHangup := True;
            Menu := 0;
            EXiT
          end;
          If (Match(Inpt,'/WHO')) OR (Match(Inpt,'/W')) Then Begin
            Inpt[0] := #0;
            Writeln(Direct);
            Node_Listing;
            Menu := 0;
            Exit;
          End;
          If (Pos('/SE',UpString(Inpt))=1) or (Pos('/SEND',UpString(Inpt))=1)
          Then Begin
            Menu := 0;
            Send_Node_Message;
            Inpt[0] := #0;
            Exit;
          End;
          If Match(inpt,'/MEM') Then Begin
            Inpt[0] := #0;
            Writeln(^R'Free Memory (Conventional):'^S' ',Dos_MaxAvail,' Bytes');
            Exit;
          End;
          If Match(inpt,'/VER') Then Begin
            Inpt[0] := #0;
            Writeln(^R'Current Version: ',Version);
            Exit;
          End;
          If (match(inpt,'/CLS')) OR (match(inpt,'/C')) Then Begin
             Inpt[0] := #0;
             ANSiCLS;
             exit;
          End;
          N := Valu(inpt);
          IF N>0
            Then K := '#'
            Else K := Upcase(Inpt[1])
        end;
    p:=1;
    i:=1;
    If K = '?'
      Then
        Begin
          Printfile (Cfg.TextFileDir + MFN + 'M.ANS')
        End
      Else
        while p<=length(choices) do begin
          needsys:=false;
          if p<length(choices)
            then if choices[p+1]='@'
              then needsys:=true;
          if upcase(choices[p])=k
            then if needsys and (not issysop)
              then
                begin
                  reqlevel (cfg.sysoplevel);
                  p:=255;
                  needsys:=false
                end
              else p:=256
            else
              begin
                p:=p+1;
                if needsys then p:=p+1;
                i:=i+1
              end
        end
  until (p=256) or hungupon;
  writeln (^B^M);
  if hungupon
    then menu:=0
    else
      if k='#' then menu:=-n else menu:=i;
  nobreak:=false;
  bottomline
end;

*)

function getpassword:boolean;
var t:sstr;
    A:Byte;
begin
  getpassword:=false;
  dots:=true;
  InputBox(20);
  if inpt=''
    then exit
    else begin
      T := Inpt;
      Dots := True;

      MultiColor(strng^.ReEnter_Password);
      InputBox(20);

      if not match(t,inpt) then begin
        writeln (^M'They don''t match!');
        getpassword:=hungupon;
        exit
      end;

      urec.password:=t;
      getpassword:=true
    end
end;

Function CheckPassword (VAR U:UserRec):Boolean;
VAR Tries,W:Byte;
    UseFile:Boolean;
BEGIN
  Tries:=1;
  CheckPassword:=False;
  UseFile:=Exist(Cfg.TextFileDir+'PASSWORD.ANS');
  Repeat
    SetScreenSize(80,25);
    GotoXy(1,25);
    TextAttr:=112;
    ClrEol;
    Write(Usr,'Password Attempt #'+Strr(Tries)+' (');
    TextAttr:=113;
    Write(usr,U.Handle);
    TextAttr:=112;
    Write(Usr,') PW: ');
    TextAttr:=116;
    Write(Usr,U.Password);
    TextAttr:=112;
    Write(Usr,' ³ ');
    Password:=WhereX;
    Dots:=True;
    SplitMode:=True;
    SetScreenSize(80,24);
    If UseFile Then Begin
      If Tries=1 Then InputFile(Cfg.TextFileDir+'PASSWORD.ANS')
      Else Begin
        AnsiColor(InptColor);
        GoXy(InptX,InptY);
        Write('Wrong!');
        If Length(Inpt)>6 Then For W:=1 To Length(Inpt)-6 Do Write(#32);
        Delay(500);
        If Length(Inpt)>6 Then For W:=1 To Length(Inpt)-6 Do Write(^H+' '+^H);
        For W:=1 to 6 Do Write(^H+' '+^H);
        GetStr(False);
      End;
    End Else
      Begin
        MultiColor(Strng^.WhatsYourPW);
        WriteStr('*');
      End;
    If HungUpOn Then Begin
      CheckPassword:=False;
      Exit;
    End;
    If Match(Inpt,U.Password) Then Begin
      CheckPassword:=True;
      SplitMode:=False;
      Exit;
    End;
    Inc(tries);
  Until (Tries>4);
  InitWinds;
  SplitMode:=False;
  CheckPassword:=False;
End;

procedure getacflag (var ac:accesstype; var tex:mstr);
const accessstr:array [accesstype] of string[8]=
        ('By level','Keep out','Let in','');
begin
  writestr (^R'['^S'K'^R']ick off, ['^S'B'^R']y level, ['^S'L'^R']et in: &');
  ac:=invalid;
  if length(inpt)=0 then exit;
  case upcase(inpt[1]) of
    'B':ac:=bylevel;
    'L':ac:=letin;
    'K':ac:=keepout
  end;
  tex:=accessstr[ac]
end;

Procedure Goxy(x,y:byte);
Begin
  If Avatar In Urec.Config Then Begin
    If Online Then SendChar(^V);
    WriteCon(^V);
    If Online Then SendChar(^H);
    WriteCon(^H);
    If Online Then SendChar(Chr(Y));
    WriteCon(Chr(Y));
    If Online Then SendChar(Chr(X));
    WriteCon(Chr(X));
    Exit;
  End;

  {If Not(ansigraphics In urec.config) Then exit;}

  Write(Direct,#27'[');
  If Y <> 1 Then Write(Direct,Strr( Y ));
  If X <> 1 Then Write(Direct,';',Strr( X ));
  Write(Direct,'H');
End;

Procedure PrintXy(x,y:byte; S:anyStr);
Begin
  Goxy(X,Y);
  Write(S);
End;

Procedure HoldScreen;
Var I : Byte;
    K : Char;
Begin
  ClearBreak;
  MultiColor(Strng^.PauseString);
  K := WaitForChar(False);
  For I := MCStrLength Downto 0
    Do Write(Direct,^H + ' ' + ^H);
End;

procedure tabul (n:anystr; np:integer);
var cnt:integer;
begin
  AnsiColor(Urec.Color2);
  write (Direct,n);
  AnsiColor(Urec.Color1);
  for Cnt := Length(n)
    To Np - 1 Do Write ('ú');
end;

Procedure MultiColor(M:String);
Const HexStr = '0123456789ABCDEF';
Var X, Z, ForeGround, BackGround : Byte;
    A : String[2];
    SChar : Char;

    Function ConvertHex (S:Sstr) : Byte; { PCB COLOR CODES ARE LAME!! }
    Var X : Byte;
    Begin
      X := Pos(S[1],HexStr) - 1;
      X := (X Shl 4) + Pos(S[2],HexStr) - 1;
      ConvertHex := X;
    End;

Var PCB : String[2];
Begin
  ClearBreak;
  X := 1;
  McStrLength := 0;
  BackGround := 0;
  ForeGround := Urec.Color1;
  While X <= Length(M)
  Do Begin
    Case M[X] Of
      '@' : If X < ( Length(M) - 3)
            Then Begin
              Inc(X);
              If (M[X] = 'X')
              And ( Pos(M[X + 1],HexStr) > 0)
              And ( Pos(M[X + 2],HexStr) > 0)
              Then Begin
                Inc(X);
                PCB := M[X];
                Inc(X);
                PCB := PCB + M[X];
                Inc(X);
                AnsiColor(ConvertHex(PCB));
              End
                Else Write('@');
            End Else Begin
              Write(M[X]);
              Inc(X);
            End;
      '$':Begin
           Inc(X);
           Case M[X] Of
             'a':ansicolor(0);
             'b':ansicolor(1);
             'g':ansicolor(2);
             'c':ansicolor(3);
             'r':ansicolor(4);
             'p':ansicolor(5);
             'y':ansicolor(6);
             'w':ansicolor(7);
             'A':ansicolor(8);
             'B':ansicolor(9);
             'G':Ansicolor(10);
             'C':Ansicolor(11);
             'R':ansicolor(12);
             'P':ansicolor(13);
             'Y':ansicolor(14);
             'W':ansicolor(15);
             Else Write('$' + M[x]);
           End;
           Inc(X);
          End;
      '%':Begin
            Inc(X);
            If M[x] = '%'
              Then Begin
                InputFile(Copy(M,X+1,Length(M)));
                Exit;
              End Else
                Write('%' + M[x]);
          End;
      '|':Begin
            A[0]:=#0;
            Inc(X);
            A:=M[x];
            Inc(X);
            A:=A+M[x];
            A:=UpString(A);
            If A[1]='@' Then Begin
              SChar:=A[2];
              A[0]:=#0;
              Inc(X);
              While (Length(A)<3) and (M[x] in ['0'..'9'])
              Do Begin
                A := A+M[X];
                Inc(X);
              End;
              Dec(X);
              For Z:=1 to Valu(A) Do Write(Direct,Schar);
            End Else If
             A='C1' then AnsiColor(Urec.Color1) Else If
             A='C2' then AnsiColor(Urec.Color2) Else If
             A='C3' then AnsiColor(Urec.Color3) Else If
             A='C4' Then AnsiColor(Urec.Color4) Else If
             A='C5' Then AnsiColor(Urec.Color5) Else If
             A='C6' Then Ansicolor(Urec.Color6) Else If
             A='C7' Then ansiColor(Urec.Color7) Else If
             A='TL' then write (strr(timeleft)) Else if
             A='TN' then write (timestr(now)) Else if
             A='UH' then write (urec.handle) Else if
             A='BE' then write(^G) else if
             A='CR' then writeln Else if
             A=Sr.C[1] Then If (Sr.C[1]<>'OR') and (Sr.C[1]<>'MN')
               Then Write(Sr.S[1]) Else MultiColor(Sr.S[1]) Else If
             A=Sr.C[2] then Write(Sr.S[2]) Else If
             A=Sr.C[3] then Write(Sr.S[3]) Else
             If (A[1]='B') and (A[2] in ['0'..'7']) Then Begin
               AnsiColor(Valu(A[2]) * 16 + ForeGround);
               BackGround:=Valu(A[2]);
             End Else
             If (Valu(A) in [1..15]) Then Begin
               AnsiColor(BackGround * 16 + Valu(A));
               ForeGround:=Valu(A);
             End Else
               Write('|'+A);
             Inc(X);
          End;
      #0..#255 : Begin
        Inc(McStrLength);
        Write(Direct,M[x]);
        Inc(X);
      End
    End
  End
End;

Procedure NoCRInput(Defualt:Mstr; L:Byte);
VAR K:Char;
    A,B:Byte;
    S:Lstr;
BEGIN
  ClearBreak;
  ChainStr[0] := #0;
  inpt[0]:=Chr(0);
  S[0]:=Chr(0);
  B:=Urec.Color4;
  IF Cfg.UseBox Then Begin
    Urec.Color4:=31;
    Write(^U);
    For A:=1 to L Do Write(Cfg.BoxChar);
    Write(B_(L));
  End Else
    AnsiColor(Urec.Color4);
  Repeat
    K:=WaitForChar(False);
    CASE K Of
    #32..#254:If Length(S)<L Then Begin
                S:=S+K;
                If Not Dots Then Write(K) Else Write(Cfg.DotChar);
                If Dots Then Begin
                  Top;
                  TextAttr:=113;
                  Write(Usr,K);
                  Bottom;
                End;
              End;
    #8:If Length(S)>0 then Begin
         S[0]:=Pred(S[0]);
         If Cfg.UseBox then Write(^H+Cfg.BoxChar+B_(1)) Else Write(^H+' '+^H);
         If Dots Then Begin
           Top;
           TextAttr:=113;
           Write(Usr,^H+' '^H);
           Bottom;
         End;
       End;
    ^X,#27:Begin
        If Length(S)>0 Then
        For A:=1 to Length(S) Do If Cfg.UseBox then Write(^H+Cfg.BoxChar+B_(1)) Else Write(^H+' '+^H);
        If Dots Then Begin
          Top;
          TextAttr:=113;
          For A:=1 To Length(S) Do Write(Usr,^H+' '+^H);
          Bottom;
        End;
        S[0]:=Chr(0);
      End;
    End;
  Until (K = #0) or HungUpOn;
  inpt:=S;
  If inpt='' then If Defualt>'' then Write(Direct,Defualt);
  Ansireset;
  Writeln;
  urec.color4:=B;
End;

begin
  writedot := false
end.
