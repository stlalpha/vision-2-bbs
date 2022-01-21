{$R-,S-,I-,D-,F-,V-,B-,N-,L+,O+}

unit chatstuf;

interface

uses Dos,MNeT,Crt,Video,PAVT150,general,statret,{fastttt5,}
     gentypes,subs1,userret,modem,windows,configrt;

Procedure GotoDos;
Procedure SysOpCommands;
procedure Configchat (use:integer);
procedure OneLineChat;

implementation

Type ScreenType = array [0..3999] of Byte;
Var ScreenAddr : ScreenType Absolute $B800:$0000;
    U : Userrec;

procedure writecon (k:char);
var r:registers;
begin
  if k=^J
    then write (usr,k)
    else
      begin
        r.dl:=ord(k);
        r.ah:=2;
        intr($21,r)
      end
end;

procedure sendmodemstr (ss:anystr; endifcarrier:boolean);
var cnt,ptr:integer;
    k:char;
label exit;
begin
  ptr:=0;
  while ptr<length(ss) do
    begin
      {if keyhit or (carrier=endifcarrier) then goto exit;}
      ptr:=ptr+1;
      k:=ss[ptr];
      case k of
        '|':sendchar (^M);
        '~':delay (500);
        '^':begin
              ptr:=ptr+1;
              if ptr>length(ss)
                then k:='^'
                else k:=upcase(ss[ptr]);
              if k in ['A'..'Z']
                then sendchar (chr(ord(k)-64))
                else sendchar (k)
            end;
        else sendchar (k)
      end;
      delay (50);
      while numchars>0 do writecon (getchar)
    end;
  cnt:=0;
  repeat
    while numchars>0 do begin
      cnt:=0;
      writecon (getchar)
    end;
    cnt:=cnt+1
  until (cnt=1000) or keyhit or (carrier=endifcarrier);
  exit:
  break:=keyhit
end;

procedure gotodos;
var tmp1:integer;
    st:mstr;
    S:Screens;
begin
  Writeln;
  MultiColor (Strng^.SysopInDos);
  GotoXy(1,25);
  ClrEol;
  Tmp1:=TimeLeft;
  ReadScr(S);
  UpdateUserStats (false);
  TextAttr:=1;
  Write(usr,'[');
  TextColor(11);
  Write(usr,' ViSiON/2 Quick Shell ');
  TextColor(1);
  Write(usr,'] þ [');
  TextColor(11);
  Write(usr,'Type "EXIT" to Return to ViSiON/2');
  TextColor(1);
  Writeln(usr,']');
    ExecuteWithSwap('','',False);
  St := Cfg.visiondir;
  If St[length(st)] = '\'
    Then St[Length(st)] := #0;
  ChDir(St);
  WriteScr(S);
  SetTimeLeft(Tmp1);
  SetUpBottom;
  BottomLine;
  Textbackground(0);
  ChainStr := #13;
end;

procedure hangupmodem;
var tries:integer;
begin
  tries:=0;
  while carrier and (tries<5) do begin
    hangup;
    sendmodemstr (Cfg.modemhangupstr,false);
    tries:=tries+1
  end;
  setparam (Cfg.usecom,baudrate,parity)
end;

procedure disconnect;
begin
  urec.lastnummsgs:=status.totalmsgs;
  urec.lastnumfiles:=status.totalfiles;
  if online then hangupmodem;
  online:=true;
  writelog (0,3,'');
  if (unum>0) and not disconnected then updateuserstats (true);
  disconnected := true
end;

Procedure SysOpCommands;
VAR InChat:Boolean;

  procedure snoopmode;
  begin
    TextAttr:=31;
    GotoXy(35,17);
    write (usr,'All I/O to the modem is locked.');
    modeminlock:=true;
    setoutlock (true)
  end;

  procedure unsnoop;
  begin
    TextAttr:=31;
    GotoXy(35,17);
    write (usr,'I/O to the modem is re-enabled.');
    modeminlock:=false;
    setoutlock (false)
  end;

{$I SYSOPMEN.PAS}

  Procedure ClearBox;
  Var X : Byte;
  Begin
    TextAttr:=31;
    For X:= 7 to 17 Do Begin
      Gotoxy(35,x);
      Write(usr,'                                      ');
    End;
  End;

function lookupuser (var uname:mstr):integer;
var cnt,s:integer;
    wildcarding:boolean;
    k:char;
    uh:mstr;
begin
  lookupuser:=0;
  if length(uname)=0 then exit;
  if uname[1]='/' then exit;
  if uname[1]='#' then delete (uname,1,1);
  wildcarding:=uname[length(uname)]='*';
  if wildcarding then uname[0]:=pred(uname[0]);
  val (uname,cnt,s);
  if (s=0) and (cnt>0) and (cnt<=numusers) then begin
    seek (uhfile,cnt);
    nread (uhfile,uh);
    if length (uh)>0 then begin
      lookupuser:=cnt;
      uname:=uh
    end;
    exit
  end;
  seek (uhfile,1);
  for cnt:=1 to numusers do
    begin
      nread (uhfile,uh);
      if wildcarding and (uh<>'')
        then if match(copy(uh,1,length(uname)),uname)
          then
            begin
            GotoXy(35,13);
              textattr:=30;
              Write(usr,'                                ');
              GotoXy(35,13);
              TextAttr:=30;
              write (usr,uh,' [Y/N/X]: ');
              repeat
                read (k);
                k:=upcase(k)
              until hungupon or (k in ['Y','N','X']);
              write (usr,k);
              case upcase(k) of
                'Y':begin
                      lookupuser:=cnt;
                      uname:=uh;
                      exit
                    end;
                 'X':exit
              end
            end
          else
        else if match (uh,uname)
          then
            begin
              lookupuser:=cnt;
              uname:=uh;
              exit
            end
    end
end;

  Procedure ChooseUser;
  Var A:Byte;
      S:Integer;
      Done:Boolean;
      Name:Mstr;

  Begin
    Done:=False;
    ClearBox;
    GotoXy(35,8);
    TextAttr:=27;
    Write(usr,'Enter User Name/Number to Edit [L]ist');
    GotoXy(35,9);
    Write(usr,'Use ''*'' at end of string to Wildcard');
    GotoXy(35,10);
    Write(usr,'You a have a total of '+strr(numusers)+' Users');
      GotoXy(35,12);
      TextAttr:=31;
      Write(usr,'                        ');
      TextAttr:=31;
      GotoXy(35,12);
      Write(usr,'User Name/# : ');
      ReadLine(Name);
      If Name>'' then Begin
        A:=lookupuser(name);
        If (A=0) and (Upcase(Name[1])='L') Then Exec(GetEnv('COMSPEC'),'/C UE.EXE') Else
        IF A>0 then
      Exec(GetEnv('COMSPEC'),'/C UE.EXE '+Strr(A));
    End;
  End;

  Procedure PrintF;
  Var Done:Boolean;
      P:lstr;
      T:Text;
      K:Char;
      Show:Boolean;
  Begin
    Done:=False;
    Show:=False;
    ClearBox;
    GotoXy(35,8);
    TextAttr:=31;
    Write(usr,'Print File Procedure');
    GotoXy(35,10);
    Write(usr,'Enter Full Path and Filename To Print');
    TextAttr:=30;
    GotoXy(35,12);
    Write(usr,'Print: ');
    Readline(p);
    If Not (p>'') then exit;
    If Not (hungupon) or (local) then Begin
      GotoXy(35,14);
      Write(usr,'Show File to User Online? ');
      Readline(K);
      If Upcase(K)='Y' then Show:=True;
    End;
      If Exist(P) then Begin
        Assign(T,P);
        Reset(T);
        Unsplit;
        Top;
        ClrScr;
        While not (Eof(T)) or (done) Do Begin
          Read(T,k);
          If (break) or (xpressed) or (Keypressed) then done:=true;
          if show then Write(k) else Writecon(k);
        End;
        If show then Write('Press <Enter> :') else
          Write(usr,'Press <Enter> :');
          Readline(P);
        splitscreen(23);
        Top;
        exit;
      End Else Begin
        GotoXy(35,12);
        Write(usr,'File Not Found!');
        GotoXy(35,13);
        Write(usr,'Press <Enter> :');
        Readline(p);
      End;
      TextClose(T);
    End;

  Procedure Execute;
  var f:lstr;
  Begin
    ClearBox;
    GotoXy(35,8);
    TextAttr:=27;
    Write(usr,'Execute File Procedure');
    GotoXy(35,10);
    Write(usr,'Enter Full Path and Filename to Run');
    GotoXy(35,12);
    Write(usr,'>');
    Readline(F);
    If not (F>'') then exit;
      If exist(F) then Begin
      Exec(GetEnv('COMSPEC'),'/C '+F);
      ReadCfg;
      ReadStrings;
      End Else
    Begin
      GotoXy(35,13);
      Write(usr,'Cannot find File! Press <Enter> :');
      Readline(f);
    End;
  End;

  Procedure SendToModem;
  Var Q:lstr;
  Begin
    clearBox;
    GotoXy(35,9);
    TextAttr:=30;
    Write(usr,'Enter Text to Send to Modem');
    GotoXy(35,10);
    Write(usr,'<CR> Exits Procedure');
    GotoXy(35,11);
    Write(usr,'>');
    Readline(Q);
    If Q[length(Q)]<>'|' then Q:=Q+'|';
    SendModemStr(Q,False);
  End;

 procedure hangupyn;
  var q:sstr;
      mes:mstr;
  begin
    ClearBox;
    GotoXy(35,8);
    TextAttr:=27;
    write (usr,'Hang up on '+unam+' (Y/N)? ');
    readline (q);
    if length(q)>0 then if upcase(q[1])='Y' then
      begin
        GotoXy(35,9);
        TextAttr:=31;
        Write(usr,'Enter Text to explain disconnection');
        gotoXy(35,10);
        Write(usr,'<CR> = Sorry, The System is going down!');
        GotoXy(35,11); Write(usr,'>');
        Readline(mes);
        Unsplit;
        If mes>'' then Writeln(^G+mes+^M^M) Else
        writeln (^G'Sorry, The System is going down!'^M^M);
        disconnect;
        dontanswer;
        clrscr;
        Halt(0);
      end
  end;

CONST Name:Array [1..10] Of String[30] =
      (' User Editor       ',' Load Another User ',' Shell to DOS      ',' Print a File      ',
       ' Execute a File    ',' Send Modem String ',' Snoop Mode On     ',' Snoop Mode Off    ',
       ' Hang Up on User   ',' Engage Chat       ');
      BarColor=113;
      NormColor=31;
      X=8;

Procedure Start_Up;
VAR I:Byte;
    Finished:Boolean;

  Procedure PlaceBar(X,Y:Byte; Hi:Boolean);
  BEGIN
    If Hi then Textattr:=barcolor Else Textattr:=normcolor;
    GotoXY(X,Y+7);
    Write (usr,Name[i]);
  END;

  Procedure ChatMenu;
  CONST ChatStr:Array[1..5] of String[25]=
  ('    Chat Screen #1     ',
   '    Chat Screen #2     ',
   '     OneLine Chat      ',
   '   Pick Chat Screen    ',
   '    Exit Chat Menu     ');

  VAR I:Byte; Done:Boolean;

     Procedure ChatBar(Hi:Boolean);
     Begin
       If Hi then TextAttr:=79 Else TextAttr:=NormColor;
       Gotoxy(42,I+10);
       Write(usr,ChatStr[i]);
     End;

  VAR ChatNum : SStr;
  Begin
    ClearBox;
    GotoXy(34,8);
    Done:=False;
    TextAttr:=30;
    Write(usr,'ViSiON/2 Chat  [^Z] Toggles Crazy Colors');
    TextAttr:=NormColor;
    For i:=1 to 5 Do Begin
      GotoXy(42,10+i);
      Write(usr,ChatStr[i]);
    End;
    i:=1;
    ChatBar(True);
    REPEAT
    CASE BiosKey Of
    #200:Begin
         ChatBar(false);
         dec(i);
         IF i<=0 Then i:=5;
         ChatBar(true);
         End;
    #208:Begin       {DOWN}
         ChatBar(False);
         inc(i);
         IF i>=6 Then i:=1;
         ChatBar(true);
         End;
    #13: Begin
         IF I in [1..3] Then Begin
           UnSplit;
           Done:=True;
           Finished:=True;
           InChat:=True;
         END;
          CASE I OF
            1:ConfigChat(1);
            2:ConfigChat(2);
            3:OneLineChat;
            4:Begin
                GotoXy(42,17);
                ChatNum[0]:=#0;
                TextAttr:=NormColor;
                Write(usr,'Chat Screen (1-999): ');
                   Readline(ChatNum);
                   If Valu(ChatNum)>0 Then Begin
                     UnSplit;
                     Done:=True;
                     Finished:=True;
                     InChat:=True;
                     TextAttr:=1;
                     ClrScr;
                     ConfigChat(Valu(ChatNum));
                   End Else Begin
                     GotoXy(42,16);
                     Write(usr,'                        ');
                   End;
              End;
            5:Done:=True;
          END;
        END;
      END;
    UNTIL (DONE) or (HUNGUPON);
  END;

  Procedure DrawMenu;
  Var p:byte;
  Begin
  DrawSysopMenu;
  PlaceBar(x,i,True);
  TextAttr:=30;
  Gotoxy(41,7); Write(usr,timestr(now));
  Gotoxy(66,7); Write(usr,datestr(now));
  Gotoxy(48,9); Write(usr,unam);
  gotoxy(41,10);Write(usr,urec.sysopnote);
  gotoxy(46,11);If local then Write(usr,'Local Login') Else Write(usr,connectstr);
  gotoxy(46,12);Write(usr,urec.realname);
  Gotoxy(49,13); For p:=1 to 10 Do Begin
    If (p=4) or (p=7) Then Write(usr,'-');
    Write(usr,urec.phonenum[p]);
    End;
  gotoxy(48,14); Write(usr,urec.numon);
  Gotoxy(46,15); Write(usr,Cfg.longname);
  Gotoxy(53,16); Write(usr,Cfg.sysopname);
End;

BEGIN
  I:=1;
  Finished:=False;
  InChat:=False;
  DrawMenu;
  REPEAT
    CASE BiosKey OF
    #200:Begin       {UP}
         PlaceBar(x,i,false);
         dec(i);
         IF i<=0 Then i:=10;
         PlaceBar(x,i,true);
         End;
    #208:Begin       {DOWN}
         PlaceBar(x,i,False);
         inc(i);
         IF i>=11 Then i:=1;
         PlaceBar(x,i,true);
         End;
    #13: Begin
          CASE I OF
          1:Begin Exec(GetEnv('COMSPEC'),'/C UE.EXE '+Strr(Unum));
            DrawMenu; readurec; End;
          2:Begin ChooseUser; DrawMenu; End;
          3:Begin GotoDos; ClrScr; Bottomline; DrawMenu; End;
          4:Begin PrintF; ClrScr; DrawMenu; End;
          5:Begin Execute; ClrScr; DrawMenu; End;
          6:Begin SendtoModem; ClrScr; DrawMenu End;
          7:Snoopmode;
          8:Unsnoop;
          9:Begin hangupyn; DrawMenu; End;
         10:Begin ChatMenu; If Not Finished then DrawMenu; End;
          End;
         End;
    #27:Finished:=True;
    End;
    UNTIL Finished;
END;

VAR StartTime:Integer;
    S:Screens;
    XX,YY:Byte;
Begin
  Writeln;
  MultiColor(Strng^.SysopWorkingStr);
  XX := WhereX;
  YY := WhereY;
  ReadScr(S);
  StartTime:=TimeLeft;
  SplitScreen(23);
  Top;
  Start_Up;
  UnSplit;
  If Not InChat Then Begin
    TextAttr:=1;
    ClrScr;
    WriteScr(S);
    GotoXy(XX,YY);
    SetUpBottom;
    Bottomline;
    SetTimeLeft(StartTime);
  End;
  ChainStr := #13;
End;

Procedure Goxy(x,y:byte);
Begin
  If (WhereX = X) and (WhereY = Y)
    Then Exit;
  If Avatar In Urec.Config Then Begin
    If Online Then SendChar(^V);
    Parse_Avt1(^V);
    If Online Then SendChar(^H);
    Parse_Avt1(^H);
    If Online Then SendChar(Chr(Y));
    Parse_Avt1(Chr(Y));
    If Online Then SendChar(Chr(X));
    Parse_Avt1(Chr(X));
    Exit;
  End;
  Write(Direct,#27'[');
  If Y <> 1
    Then Write(Direct,strr(y));
  If X <> 1
    Then Write(Direct,';',Strr(x));
  Write(Direct,'H');
End;

Procedure ConfigChat(Use:Integer);

Type XyRec = Array[1..2] Of Byte;

     ChatRec=Record
       US,UF,SS,SF : Array[1..30] of XyRec;
       UserEOF,SysEOF : Boolean;
       SysName,UName,Time,Date,Elapsed:XyRec;
     End;

Var C : ChatRec;
    StartTime : Integer;
    Col : Array[1..8] of Byte;
    XSys, YSys, XUsr, YUsr,
    CurColor, SysLine, UseLine,
    SysTotal, UseTotal,
    SysOpColor, UserColor,
    StatColor : Byte;
    SysOp1, User1 : Lstr;
    SysClr, UseClr : Array[1..30] of Byte;
    Ok, FromKbd, Color : Boolean;

    Procedure ShowThing(Id:Byte; W:XyRec);
    Begin
      If (W[1]<=0) or (W[2]<=0) Then Exit;
      GoXy(W[1],W[2]);
      AnsiColor(StatColor);
      Case Id Of
        1:Write(Direct,Cfg.SysOpName);
        2:Write(Direct,Urec.Handle);
        3:Write(Direct,TimeStr(Now));
        4:Write(Direct,DateStr(Now));
        5:Write(Direct,Strr(Timer-StartTime));
      End;
    End;

    Function LoadScreenOk : Boolean;
    Label SysOpLine,UserLine;
    Var F:Text;
        L:String;
        V:Byte;

        Procedure FixXy(Str:String; VAR XY:XyRec);
        Var T1,T2:Sstr;
            P:Byte;
        Begin
          P:=Length(Str)+1;
          t1:=Copy(L,P,2);
          P:=P+3;
          If T1[2]=',' Then Begin
            T1[0]:=Chr(1);
            Dec(P);
          End;
          t2:=Copy(L,P,2);
          Xy[1]:=Valu(t1);
          Xy[2]:=Valu(t2);
          { Writeln('XY Valu for String ',str,' ',Xy[1],',',Xy[2]); }
        End;

        Procedure GetCol(Str:String; VAR T:Byte);
        Var P:Byte;
            Temp:Sstr;
        Begin
          P:=Pos(Str,L)+Length(Str);
          Temp:=Copy(L,P,3);
          While Not (Temp[Length(Temp)] in ['0'..'9']) Do
            Temp[0]:=Pred(Temp[0]);
          T:=Valu(Temp);
          { Writeln('Color for String ',str,' ',t); }
        End;

        Procedure DoXyLocation(SysOp:Boolean);
        Var P,Line,x,r:Byte;
            Temp:Sstr;
            T1,T2:XyRec;
        Begin
          Temp:=L[1];
          If L[2] in ['0'..'9'] Then Temp:=Temp+L[2];
          Line:=Valu(Temp);
          Temp[0]:=#0;
          r:=1;
          t2[2]:=0;
          For X:=Length(Strr(Line))+1 To Length(L) Do Begin
            If ((L[X]=',') or (L[X]=#32)) And (Temp<>'') Then Begin
              Case R Of
                1:t1[1]:=Valu(Temp);
                2:t1[2]:=Valu(Temp);
                3:t2[1]:=Valu(Temp);
                4:t2[2]:=Valu(Temp);
              End;
              Temp[0]:=#0;
              Inc(r);
            End;
            If L[X] in ['0'..'9'] Then Temp:=Temp+L[X];
          End;
          If t2[2]=0 Then t2[2]:=Valu(temp);
          If SysOp Then Begin
            C.Ss[Line]:=t1;
            C.Sf[Line]:=t2;
            Inc(SysTotal);
          End Else Begin
            C.Us[Line]:=t1;
            C.Uf[Line]:=t2;
            Inc(UseTotal);
          End;
        End;

    Var K:Char;
    Begin
      LoadScreenOk:=True;
      FillChar(SysClr,SizeOf(SysClr),0);
      FillChar(UseClr,SizeOf(UseClr),0);
      C.UserEof:=False;
      C.SysEof:=False;
      Color:=False;
      Col[1]:=0;
      Assign(F,Cfg.textfiledir+'CHATNFO.'+Strr(Use));
      Reset(F);
      If IoResult<>0 Then Begin
        Close(F);
        Writeln(Usr);
        Writeln(Usr,'SysOp: Unable to open CHATNFO.'+Strr(Use)+'.');
        Writeln(Usr,'       This is required for a Chat Screen!');
        LoadScreenOk:=False;
        Exit;
      End;
      SysTotal:=0;
      UseTotal:=0;
      StatColor:=1;
      SysOpColor:=1;
      UserColor:=1;
      FillChar(C,SizeOf(C),0);
      While Not(Eof(F)) Do Begin
        Readln(F,L);
        L:=UpString(L);
        If Pos('TIME=',L)>0       Then FixXy('TIME=',C.Time)            Else
        If Pos('DATE=',L)>0       Then FixXy('DATE=',C.Date)            Else
        If Pos('ELAPSED=',L)>0    Then FixXy('ELAPSED=',C.Elapsed)      Else
        If Pos('SYSOPNAME=',L)>0  Then FixXy('SYSOPNAME=',C.SysName)    Else
        If Pos('USERNAME=',L)>0   Then FixXy('USERNAME=',C.Uname)       Else
        If Pos('STATCOLOR=',L)>0  Then GetCol('STATCOLOR=',StatColor)   Else
        If Pos('SYSOPCOLOR=',L)>0 Then GetCol('SYSOPCOLOR=',SysOpColor) Else
        If Pos('USERCOLOR=',L)>0  Then GetCol('USERCOLOR=',UserColor)   Else
        If Pos('USER_CLEAR_LINE',L)>0 Then C.UserEof:=True Else
        If Pos('SYSOP_CLEAR_LINE',L)>0 Then C.SysEof:=True Else
        If Pos('SYSOPLINES',L)>0  Then Begin
         Repeat
          SysOpLine:
          Readln(f,l);
          If Pos('USERLINES',L)>0 Then Goto UserLine
          Else DoXyLocation(True);
         Until Eof(F);
        End Else If Pos('USERLINES',L)>0 Then Begin
         Repeat
          UserLine:
          Readln(F,L);
          If Pos('SYSOPLINES',L)>0 Then Goto SysOpLine Else
            DoXyLocation(False);
         Until Eof(F);
        End;
      End;
      TextClose(F);
      Assign(F,Cfg.TextFileDir+'CHAT.'+Strr(Use));
      Reset(F);
      If IoResult<>0 Then Begin
        TextClose(F);
        Writeln(Usr);
        Writeln(Usr,'SysOp: You need a screen called CHAT.'+Strr(Use));
        LoadScreenOk:=False;
        Exit;
      End;
      ModemInLock:=True;
      While Not Eof(F) Do Begin
        Read(F,K);
        If K='|' Then Begin
          Read(F,K);
          If Upcase(K)='U' Then Write(Direct,Urec.Handle) Else
          If Upcase(K)='S' Then Write(Direct,Cfg.SysOpName) Else
          Write('|'+K);
        End Else Write(K);
      End;
      TextClose(F);
      UseTotal:=0;
      For V := 1 to 30
        Do If C.Us[V][1] > 0 Then Inc(UseTotal);
      ShowThing(1,C.SysName);
      ShowThing(2,C.UName);
      ShowThing(3,C.Time);
      ShowThing(4,C.Date);
      ShowThing(5,C.Elapsed);
      ModemInLock:=False;
    End;

    Procedure DoSomeChatting;
    Label Exit;
    Var K:Char;
        Done:Boolean;

      Procedure AlternateColors;
      Var X,Temp:Byte;
      Begin
        If Col[1]=0 Then
          For X:=1 to 8 Do Col[X]:=Cfg.CC[X];
        Temp:=Col[1];
        For X:=2 to 8 Do Col[X-1]:=Col[X];
        Col[8]:=Temp;
        AnsiColor(Col[1]);
      End;

      Procedure ClrSysOpChat;
      Var X,Y:Byte;
      Begin
        ShowThing(3,C.Time);
        ShowThing(4,C.Date);
          AnsiColor(SysOpColor);
          For X:=SysTotal DownTo 2 Do Begin
            GoXy(C.Ss[X][1],C.Ss[X][2]);
            If C.SysEof Then Write(Direct,#27+'[K') Else
              For Y:=1 to SysClr[X] Do Write(Direct,#32);
          End;
          GoXy(C.Ss[1][1],C.Ss[1][2]);
          If Length(SysOp1)>0 Then Begin
            Write(Direct,SysOp1);
            If C.SysEof Then Write(Direct,#27+'[K') Else
              For Y:=Length(SysOp1) To SysClr[1] Do Write(Direct,#32);
            Sysline:=2;
            XSys:=C.Ss[2][1];
            YSys:=C.ss[2][2];
            FillChar(SysClr,SizeOf(SysClr),0);
            SysClr[1]:=Length(SysOp1);
          End Else Begin
            If C.SysEof Then Write(Direct,#27+'[K') Else
              For Y:=1 to SysClr[1] Do Write(Direct,#32);
            SysLine:=1;
            XSys:=C.Ss[1][1];
            YSys:=C.Ss[1][2];
            FillChar(SysClr,SizeOf(SysClr),0);
          End;
        End;

        Procedure ClrUserChat;
        Var X,Y:Byte;
        Begin
          AnsiColor(UserColor);
          For X:=UseTotal DownTo 2 Do Begin
            GoXy(C.Us[X][1],C.Us[X][2]);
            If C.UserEof Then Write(Direct,#27+'[K') Else
              For Y:=1 to UseClr[X] Do Write(Direct,#32);
          End;
          GoXy(C.Us[1][1],C.Us[1][2]);
          If Length(User1)>0 Then Begin
            Write(Direct,User1);
            If C.UserEof Then Write(Direct,#27+'[K') Else
              For Y:=Length(User1) To UseClr[1] Do Write(Direct,#32);
            Useline:=2;
            XUsr:=C.Us[2][1];
            YUsr:=C.Us[2][2];
            FillChar(UseClr,SizeOf(UseClr),0);
            UseClr[1]:=Length(User1);
          End Else Begin
            If C.UserEof Then Write(Direct,#27+'[K') Else
              For Y:=1 to UseClr[1] Do Write(Direct,#32);
            UseLine:=1;
            XUsr:=C.Us[1][1];
            YUsr:=C.Us[1][2];
            FillChar(UseClr,SizeOf(UseClr),0);
          End;
        End;

      Procedure SysOpWordWrap;
      Label Done;
      Var Temp,S:Lstr;
          Cut,X:Byte;
      Begin
        Cut:=0;
          AnsiColor(SysOpColor);
          For X:=Length(SysOp1) DownTo 1 Do Begin
            If SysOp1[X] in [#32,'-'] Then Begin
              Cut:=X+1;
              Goto Done;
            End;
          End;
          Done:
          If Sysline >= SysTotal
          Then Begin
            ClrSysOpChat;
            Sysline:=1;
            XSys:=C.Ss[1][1]+Cut;
            YSys:=C.Ss[1][2];
          End;
          If Cut>0 Then Begin
            S:=Copy(SysOp1,Cut,79);
            GoXy(XSys-Length(S)-1,YSys);
            For Cut:=WhereX to C.Sf[Sysline][1]
              Do Write(Direct,#32);
            SysOp1:=S;
            Inc(Sysline);
            XSys:=C.Ss[SysLine][1];
            YSys:=C.Ss[SysLine][2];
            GoXy(Xsys,YSys);
            If Color Then
              For X:=1 to Length(S) Do Begin
                AlternateColors;
                Write(Direct,S[X]);
              End
            Else
              Write(Direct,S);
            XSys:=Xsys+Length(S)+1;
            SysClr[Sysline]:=Length(S);
          End Else Begin
            Inc(SysLine);
            XSys:=C.Ss[Sysline][1];
            YSys:=C.Ss[Sysline][2];
            GoXy(XSys,YSys);
            SysOp1[0]:=#0;
          End;
        End;

        Procedure UserWordWrap;
        Label UserDone;
        Var Temp,S:Lstr;
            Cut,X:Byte;
        Begin
          Cut:=0;
          AnsiColor(UserColor);
          For X:=Length(User1) DownTo 1 Do Begin
            If User1[X] in [#32,'-'] Then Begin
              Cut := X+1;
              Goto UserDone;
            End;
          End;
          UserDone:
          If Useline>=UseTotal Then Begin
            ClrUserChat;
            Useline:=1;
            XUsr:=C.Us[1][1]+Cut;
            YUsr:=C.Us[1][2];
          End;
          If Cut>0 Then Begin
            S:=Copy(User1,Cut,79);
            GoXy(XUsr-Length(S)-1,YUsr);
            For Cut:=WhereX to C.Uf[UseLine][1]
              Do Write(Direct,#32);
            User1:=S;
            Inc(Useline);
            XUsr:=C.Us[UseLine][1];
            YUsr:=C.Us[UseLine][2];
            GoXy(XUsr,YUsr);
            If Color Then
              For X:=1 to Length(S) Do Begin
                AlternateColors;
                Write(Direct,S[X]);
              End
            Else
            Write(Direct,S);
            XUsr:=XUsr+Length(S)+1;
            UseClr[Useline]:=Length(S);
          End Else Begin
            Inc(UseLine);
            XUsr:=C.Us[Useline][1];
            YUsr:=C.Us[Useline][2];
            GoXy(XUsr,YUsr);
            User1[0]:=#0;
          End;
        End;

      Procedure CheckChars;
      Begin
        If FromKbd Then Begin
          If C.Ss[SysLine][1] + Length(SysOp1) > C.Sf[SysLine][1]
            Then SysOpWordWrap;
        End Else Begin
          If C.Us[UseLine][1]+Length(User1) > C.Uf[Useline][1]
            Then UserWordWrap;
        End;
      End;

      Procedure TypeChar(K:Char; SysOp:Boolean);
      Begin
        If FromKbd Then Begin
          GoXy(XSys,YSys);
          Inc(Xsys);
          CheckChars;
          Inc(SysClr[SysLine]);
          If Color Then AlternateColors Else
            AnsiColor(SysOpColor);
          Write(Direct,K);
          SysOp1:=SysOp1+K;
        End Else Begin
          GoXy(XUsr,YUsr);
          Inc(XUsr);
          CheckChars;
          Inc(UseClr[UseLine]);
          If Color Then AlternateColors Else
            AnsiColor(UserColor);
          Write(Direct,K);
          User1:=User1+K;
        End;
      End;

      Var X : Byte;
      Begin
        Done := False;
        If Carrier = False Then Begin
          GoXy(C.Us[1][1],C.Us[1][2]);
          AnsiColor(UserColor);
          Write('No Carrier Detected!');
        End;
        GoXy(C.Ss[1][1],C.Ss[1][2]);
        XSys := C.Ss[1][1];
        YSys := C.Ss[1][2];
        XUsr := C.Us[1][1];
        YUsr := C.Us[1][2];
        SysLine := 1;
        UseLine := 1;
        SysOp1[0] := #0;
        User1[0] := #0;
        AnsiColor(SysOpColor);
        Repeat
          If HungUpOn Then Begin
            GoXy(C.Us[1][1],C.Us[1][2]);
            AnsiColor(UserColor);
            Write(^G^G'Carrier has been lost...');
          End;
          Repeat Until (KeyHit) or (Carrier and (Numchars>0));
          Fromkbd := KeyHit;
          If FromKbd
            Then K := BiosKey
            Else K := GetChar;
          if (ord(k)>127) And (FromKBD)
            Then if ((ord(k) - 128) in [59,60,61,62])
              Then Done := True;
          if (ord(k)>127) then Begin
            if ((ord(k)-128)=59) And (FromKbd) then begin
              SysOpCommands;
              Done := true;
            end;
          End;
          If Done
            Then Goto Exit;
          If K = #127
            Then K := #8;
          Case Ord(K) Of
           27:If FromKbd
                Then Done:=True;
{BackSpace} 8:Begin
                 If FromKbd Then Begin
                   If Xsys>C.Ss[SysLine][1]
                   Then Begin
                     GoXy(Xsys,YSys);
                     Write(Direct,^H+' '+^H);
                     SysOp1[0]:=Pred(SysOp1[0]);
                     Dec(Xsys);
                     Dec(SysClr[Sysline]);
                   End;
                 End Else Begin
                   If XUsr>C.Us[UseLine][1]
                   Then Begin
                     GoXy(XUsr,YUsr);
                     Write(Direct,^H+' '+^H);
                     User1[0]:=Pred(User1[0]);
                     Dec(XUsr);
                     Dec(UseClr[Useline]);
                   End
                 End
               End;
{Tab}         9:If FromKbd Then Begin
                  GoXy(XSys,YSys);
                  If WhereX+5<C.Sf[Sysline][1]
                  Then Begin
                    AnsiColor(SysOpColor);
                    SysOp1:=SysOp1+'     ';
                    Write(Direct,'     ');
                    XSys:=XSys+5;
                    SysClr[Sysline]:=SysClr[Sysline]+5;
                  End;
                End Else Begin
                  GoXy(XUsr,YUsr);
                  If WhereX+5<C.Uf[UseLine][1]
                  Then Begin
                    AnsiColor(UserColor);
                    User1:=User1+'     ';
                    Write(Direct,'     ');
                    XUsr:=XUsr+5;
                    UseClr[UseLine]:=UseClr[UseLine]+5;
                  End
                End;
{BEEP!}      7:Write(^G);
{Colors??}   26 : Color := Not Color;
{Letters}    32..255 : TypeChar(K,FromKbd);
{Ctrl-X}     24:If FromKbd Then Begin
                  AnsiColor(SysOpColor);
                  GoXy(XSys,YSys);
                  For X:=Length(SysOp1) DownTo 1
                    Do Write(^H+#32+^H);
                  SysOp1[0]:=#0;
                  Xsys:=C.Ss[Sysline][1];
                  SysClr[Sysline]:=0;
                End Else Begin
                  AnsiColor(UserColor);
                  GoXy(Xusr,YUsr);
                  For X:=Length(User1) DownTo 1
                    Do Write(^H+#32+^H);
                  User1[0]:=#0;
                  XUsr:=C.Us[UseLine][1];
                  UseClr[Useline]:=0;
                End;
{El-Entero}  13:Begin
                  ShowThing(5,C.Elapsed);
                  If FromKbd Then Begin
                    If Match(SysOp1,'/Q')
                      Then Goto Exit;
                    If Match(SysOp1,'/CLS')
                    Then Begin
                      SysOp1[0]:=#0;
                      ClrSysOpChat;
                    End Else
                    Inc(SysLine);
                    XSys:=C.Ss[SysLine][1];
                    YSys:=C.Ss[SysLine][2];
                    If SysLine > SysTotal
                      Then ClrSysOpChat;
                    SysOp1[0]:=#0;
                    GoXy(Xsys,Ysys);
                  End Else Begin
                    If Match(User1,'/Q')
                      Then Goto Exit;
                    If Match(User1,'/CLS')
                    Then Begin
                      User1[0]:=#0;
                      ClrUserChat
                    End Else
                    Inc(UseLine);
                    XUsr:=C.Us[UseLine][1];
                    YUsr:=C.Us[UseLine][2];
                    If UseLine > UseTotal
                      Then ClrUserChat;
                    User1[0]:=#0;
                    GoXy(Xusr,Yusr);
                  End
                End
           End;
        Until Done;
        Exit:
      End;

Var SaveTime:Word;
    OldB:Byte;
Begin
  ChatMode := False;
  Writeln;
  MultiColor(Strng^.EnterChat);
  OldB := UseBottom;
  UseBottom := 0;
  InitWinds;
  BottomLine;
  NoBreak := True;
  ClearBreak;
  StartTime := Timer;
  SaveTime := TimeLeft;
  NoChain := True;
  Ok := LoadScreenOk;
  If Not Ok
    Then Exit;
  DoSomeChatting;
  AnsiReset;
  AnsiCls;
  SetTimeLeft(SaveTime);
  UseBottom := OldB;
  InitWinds;
  Bottomline;
  Writeln;
  MultiColor(Strng^.ExitChat);
  NoChain:=False;
  NoBreak:=False;
  ChainStr:=#13;
End;

Procedure OnelineChat;
VAR k:char;
    cnt,displaywid:integer;
    StartedTime:Word;
    quit,carrierloss,fromkbd:boolean;
    linebuffer:lstr;
    l:byte absolute linebuffer;
    CurColor : Byte;

  Procedure Instruct;
  Begin
    AnsiReset;
    AnsiCls;
    Writeln(^P'ViSiON/2 Line Chat - Engaged at '^O+timestr(now)+^M);
    MultiColor(Strng^.EnterChat);
    Writeln;
  End;

  Procedure wordwrap;
  VAR cnt,wl:integer;
      ww:lstr;
  begin
    ww:='';
    cnt:=displaywid;
    while (cnt>0) and (linebuffer[cnt]<>' ') do cnt:=cnt-1;
    if cnt=0 then ww:=k else begin
      ww:=copy(linebuffer,cnt+1,255);
      wl:=length(ww)-1;
      if wl>0 then begin
        for cnt:=1 to wl do write (^H);
        for cnt:=1 to wl do write (' ')
      end
    end;
    writeln;
    ansicolor (curcolor);
    write (ww);
    linebuffer:=ww
  end;

  Procedure TypedChar (K : Char);
  Var Ec:  byte;
  Begin
    Inc(L);
    LineBuffer[ L ] := K;
    If L >= DisplayWid
      Then WordWrap
      Else Write(k)
  End;

VAR Ch ,KK: CHAR;
    inchat:boolean;
    time:integer;
    f:Lstr;
    t:Text;
    Fo:Byte;

begin
  While Keypressed DO
    Ch := ReadKey;
  Writeln(^M);
  carrierloss := false;
  chatmode := false;
  InChat := TRUE;
  writeln(^B);
  if (wanted in urec.config) AND (Ulvl < 90)  then begin
    specialmsg ('(No longer wanted)');
    urec.config:=urec.config-[wanted];
    writeurec;
  end;
  if eightycols in urec.config then displaywid:=80 else displaywid:=40;
  if length(chatreason)>0 then specialmsg ('(Chat reason: '+chatreason+')');
  ChatReason:='';
  clearbreak;
  NoBreak := True;
  StartedTime:=TimeLeft;
  instruct;
  quit:=false;
  l:=0;
  curcolor:=urec.color1;
  nobreak:=true;
  break:=false;
  nochain:=true;
  time:=timeleft;
  repeat
    linecount:=0;
    if (not carrierloss) and (not carrier) then begin
      carrierloss:=true;
      writeln (^M'Warning: No Carrier detected.'^M)
    end;
    repeat until keyhit or (carrier and (numchars>0));
    fromkbd:=keyhit;
    ingetstr:=true;
    curcolor:=urec.color4;
    if not keyhit then read(directin,k) else begin curcolor:=urec.color3;
    K:=bioskey;
    If ((ord(k)-128)=32) Then Begin
      GotoDos;
      Instruct;
      K:=#13;
    End;
    if (ord(k)>127) then if ((ord(k) - 128) in [59,60,61,62]) then inchat:=false;
    if (ord(k)>127) then Begin
      if ((ord(k)-128)=59) then begin
       SysOpCommands;
       inchat:=false;
      end;
    End;
    Case Ord(k)-128 Of
      72 : Write(Direct,#27+'[A');
      80 : Write(Direct,#27+'[B');
      75 : Write(Direct,#27+'[D');
      77 : Write(Direct,#27+'[C');
    End;
    end;
    ansicolor(curcolor);
    if k=#127 then k:=#8;
    Quit := NOT Inchat;
    if quit then k:=#0;
    case ord(k) of
      8:if l>0 then begin
          write (k+' '+k);
          l:=l-1
        end;
      0:;
      13:Begin
           Writeln;
           If UpString(LineBuffer)='/Q'
             Then Quit:=True;
           If pos('/TYPE ',UpString(LineBuffer))=1 then Begin
             F := Copy(LineBuffer,7,80);
             While F [ Length(F) ] = #32
               Do F[0] := Pred(F[0]);
             IF Not Exist(F) Then
               Writeln('File Not Found!')
             Else Begin
               Assign(T,F);
               Reset(T);
               While Not(Eof(T)) or (Break) or (HungUpOn) Do Begin
                 Read(T,KK);
                 Write(KK);
               End;
               TextClose(T);
             End;
           End;
           Bottomline;
           L := 0
         end;
      27:If Not FromKbd Then Begin
           Read(Directin,K);
           If K = '[' Then
             Read(Directin,K);
           Case K Of
             'A' : Write(Direct,#27+'[A');
             'B' : Write(Direct,#27+'[B');
             'C' : Write(Direct,#27+'[C');
             'D' : Write(Direct,#27+'[D');
             Else Write(Direct,#27 + '[' + K);
           End;
        End Else Quit := True;
      32..255:If Not (Ord(K)-128 in [72,75,77,80]) then typedchar (k);
      9:If WhereX<74 then Begin
          LineBuffer:=Linebuffer+'     ';
          Write(Direct,#27+'[5C');
        End;
      24:Begin
          For Fo:=WhereX Downto 1 Do Write(Direct,^H+' '+^H);
          LineBuffer[0]:=#0;
         End;
      1..31:if fromkbd and carrier then sendchar(k)
    end
  until quit;
  chainstr:=#13;
  inpt:='';
  UnSplit;
  ClearBreak;
  Writeln;
  MultiColor(Strng^.ExitChat);
  Writeln(^M);
  SetTimeLeft(Time);
  bottomline;
End;

Begin
End.
