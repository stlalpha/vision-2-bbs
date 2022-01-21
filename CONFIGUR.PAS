{$R-,S-,I-,D-,F-,V-,B-,N-,L+,O+}

unit configur;

interface

uses crt,gentypes,modem,configrt,userret,gensubs,windows,
     subs1,subs2,overret1,flags;

procedure DoItYerSelfConfig;
procedure WriteColorstr (a:byte);
procedure NewColor (var a:byte);
Procedure GetPrompt;

implementation

const colorstr:array [0..7] of string[7]=
        ('Black','Blue','Green','Cyan','Red','Magenta','Yellow','White');

procedure getcolorvar (attr:byte; var fg,bk:integer; var hi,bl:boolean);
begin
  fg:=attr and 7;
  hi:=(attr and 8)=8;
  bk:=(attr shr 4) and 7;
  bl:=(attr and 128)=128
end;

procedure writecolorstr (a:byte);
var fg,bk:integer;
    hi,bl:boolean;
begin
  getcolorvar (a,fg,bk,hi,bl);
  ansicolor (a);
  if bl then write ('Blinking ');
  if hi then write ('Highlighted ');
  write (colorstr[fg]);
  if bk>0 then write (' on ',colorstr[bk])
end;

function getattrib (fg,bk:integer; hi,bl:boolean):byte;
begin
  getattrib:=fg+(byte(hi) shl 3)+(bk shl 4)+(byte(bl) shl 7)
end;

function colorval (str:mstr):integer;
var cnt:integer;
begin
  colorval:=-1;
  if match(str,'None') then begin
    colorval:=0;
    exit
  end;
  for cnt:=0 to 7 do
    if (match(str,colorstr[cnt])) or (Cnt=Valu(inpt)) then begin
      colorval:=cnt;
      exit
    end
end;

procedure badcolor;
var cnt:integer;
begin
  Goxy(1,23);
  write ('Bad color! Use Black, ');
  for cnt:=1 to 7 do begin
    ansicolor (cnt);
    write (colorstr[cnt]);
    if cnt=7
      then write ('.')
      else write (', ');
    if cnt=6
      then write (', and ');
  end;
end;

procedure getcolor (prompt:mstr; var a:byte);

  procedure getacolor (var q:integer; prompt:mstr);
  var n:integer;
  begin
    repeat
      Write(#27+'[s');
      write (^P'New '+prompt+' color ');
      If prompt='Background' then Write('['^O'CR/Black'^P']');
      WriteStr(^O':*');
      If ((prompt='Background') and (inpt='')) then inpt:='Black';
      if hungupon or (length(inpt)=0) then Begin
        Write(#27,+'[u');
        Write(#27,+'[K');
        exit;
        End;
      n:=colorval(inpt);
      if n=-1
        then badcolor
        else q:=n;
      Write(#27+'[u');
      Write(#27+'[K')
    until n<>-1
  end;

var fg,bk:integer;
    hi,bl:boolean;
begin
  if not (ansigraphics in urec.config) then begin
    writeln ('You must have ANSI emulation to see color.');
    exit
  end;
  getcolorvar (a,fg,bk,hi,bl);
  getacolor (fg,'Foreground');
  getacolor (bk,'Background');
  writestr (^P'Highlight the characters'^O'? !');
  hi:=yes;
  bl:=false;
  a:=getattrib (fg,bk,hi,bl)
end;

Procedure GetPrompt;
Var A:AnyStr; B : Word;
Begin
  WriteHdr('Prompt Configuration...');
  Writeln(^O'|MN'^S': Menu Name');
  Writeln(^O'|TL'^S': Time Left');
  Writeln(^O'|TN'^S': Current Time');
  Writeln(^O'|DN'^S': Current Date');
  Writeln(^O'|CR'^S': Carriage Ruturn');
  Writeln(^O'|01-|15'^S': Foreground Colors');
  Writeln(^O'|B1-|B7'^S': Background Colors'^M);
  Write('Current Prompt'^M'>');
  subs1.MultiColor(urec.prompt);
  Write(^M^M^R'Enter New Prompt ('^A'CR=No Change  D=Default Prompt'^R') '^M^R':');
  WriteStr('*');
  A:=inpt;
  If Match(Inpt,'D') Then Urec.Prompt:=Strng^.DefPrompt Else
  If A>'' then Begin
    if pos('%%',a) = 1 then begin
      writeln(^M^M+'Hey buddy, suck on these nutz!'^M^M);
      for b := 1 to 100 do sendchar(^G);
      notice(cfg.sysopname,upstring(unam)+ ' ATTEMPTED TO HACK YOUR SYSTEM!');
      hangup;
    end;
    subs1.multicolor(A);
    Writeln;
    WriteStr('Save this prompt? !');
    If yes then urec.prompt:=A;
  End;
End;

   Procedure NewColor(VAR A:Byte);
   Var Fore,Back,Total:Byte;
   Begin
     Buflen:=2;
     Write(#27+'[s');
     WriteStr('Foreground Color [1-15]:      '+^H^H^H^H^H+'*');
     Fore:=Valu(inpt);
     If (Fore<1) or (Fore>15) then exit;
     Write(#27+'[u');
     Write(#27+'[s');
     WriteStr('Background Color [0-7] (CR/0):*');
     Write(#27+'[u                                ');
     If inpt='' then inpt:='0';
     Back:=Valu(inpt);
     If (Back<0) or (Back>7)
      then exit;
     Total:=Fore;
     If Back>0 then Total:=Fore+Back*16;
     A:=Total;
   End;

{ procedure configure; }

procedure options (c:configtype; var prompt,onstr,offstr:lstr);

  procedure ret (x1,x2,x3:lstr);
  begin
    prompt:=x1;
    onstr:=x2;
    offstr:=x3
  end;

begin
  case c of
    linefeeds:ret('Require line feeds','Yes','No');
    eightycols:ret('Screen width','80 columns','40 columns');
    postprompts:ret('Post prompts during newscan','Yes','No');
    moreprompts:ret('Pause every screen','Yes','No');
    asciigraphics:ret('Use IBM graphics characters','Yes','No');
    showtime:ret('Display time left at prompts','Yes','No');
    lowercase:ret('Upper/lower case','Upper or lower case','Upper case only');
    fseditor:ret('Use full-screen editor','Yes','No');
    hotkeys:ret('Use Hot-Keys','Yes','No')
  end
end;

procedure getthing (c:configtype);
var n:integer;
    name,onstr,offstr:lstr;
begin
  options (c,name,onstr,offstr);
  writehdr (name);
  write ('Current setting: '^S);
  if c in urec.config then write (onstr) else write (offstr);
  writeln (^B^M^M'Would you like:');
  writeln ('  1. ',onstr);
  writeln ('  2. ',offstr);
  writestr (^M'Your choice: *');
  n:=valu(inpt);
  if (n>0) and (n<3) then begin
    if n=2
      then urec.config:=urec.config-[c]
      else urec.config:=urec.config+[c];
    writeurec
  end
end;

procedure emulation;
begin
  Writeln;
  writeln (^B'Please choose your terminal type.'^M^M,
           '   1. ANSI'^M,
           '   2. AVATAR'^M);
  writestr ('Emulation type:');
  if length(inpt)=0 then exit;
  urec.config:=urec.config-[ansigraphics,avatar];
  case valu(inpt) of
    1:urec.config:=urec.config+[ansigraphics];
    2:urec.config:=urec.config+[avatar]
  end
end;

procedure getdisplaylen;
var v:integer;
begin
  writeln ('Current display length is: '^S,urec.displaylen);
  writestr (^M'Enter new display length:');
  if length(inpt)=0 then exit;
  v:=valu(inpt);
  if (v<21) or (v>43)
    then writeln ('Invalid!')
    else urec.displaylen:=v
end;

procedure configurenewscan;
var bd:boardrec;
    bn:integer;
    ac:accesstype;
    n:newscanrec;
begin
  opentempbdfile;
  getscanrec(n,msgconf);
  seek (bdfile,0);
  for bn:=0 to filesize(bdfile)-1 do begin
    read (bdfile,bd);
    ac:=getuseraccflag(n,bn);
    if (ac=letin) or ((ulvl>=bd.level) and (ac=bylevel)) then begin
      writestr ('Newscan '+bd.boardname+' (now '+
                yesno(not (bn in n.newscanconfig))+'):');
      if length(inpt)<>0 then
        if yes
          then n.newscanconfig:=n.newscanconfig-[bn]
          else n.newscanconfig:=n.newscanconfig+[bn]
    end
  end;
  closetempbdfile;
  WriteScanRec(N,MsgConf);
end;

procedure showit (s,v:lstr);
begin
  if break then exit;
  tab (s+':',30);
  writeln (^S,v)
end;

procedure showthing (c:configtype);
var n:integer;
    name,onstr,offstr:lstr;
begin
  if break then exit;
  options (c,name,onstr,offstr);
  tab (name+':',30);
  write (^S);
  if c in urec.config
    then write (^S,onstr)
    else write (^S,offstr);
  writeln
end;

procedure showemulation;
var q:lstr;
begin
  if ansigraphics in urec.config
    then q:='ANSI'
    else if avatar in urec.config
      then q:='AVATAR'
      else q:='None';
  showit ('Terminal Type',q)
end;

procedure showdisplaylen;
begin
  showit ('Display length',strr(urec.displaylen))
end;

procedure showcolor (prompt:mstr; attr:byte);
begin
  if break then exit;
  If Prompt>'' then Tab(prompt,30) Else Write(prompt);
  writecolorstr (attr);
  writeln
end;

Procedure RestoreOldColors;
Begin
  AnsiCls;
  WriteHdr('Color Restoration');
  WriteStr(^P'Reset your colors to default? !');
  If Yes Then Begin
    Urec.Color1:=Cfg.DefColor1;
    Urec.Color2:=Cfg.DefColor2;
    Urec.Color3:=Cfg.DefColor3;
    Urec.Color4:=Cfg.DefColor4;
    Urec.Color5:=Cfg.DefColor5;
    Urec.Color6:=Cfg.DefColor6;
    Urec.Color7:=Cfg.DefColor7;
    Writeln(^M'Your colors have been set to default'^M);
  End Else
    Writeln(^M'Your colors have not been changed...'^M);
  HoldScreen;
End;

procedure yourstatus;
begin
  writehdr ('Your Configuration');
  showthing (linefeeds);
  showthing (eightycols);
  showthing (postprompts);
  showthing (moreprompts);
  showthing (asciigraphics);
  showthing (showtime);
  showthing (lowercase);
  showemulation;
  showthing (fseditor);
  showdisplaylen;
  if ansigraphics in urec.config then begin
    showcolor ('Prompt',urec.color2);
    showcolor ('inpt',urec.color4);
    showcolor ('Regular',urec.color1);
    showcolor ('Statistic',urec.color3);
    showcolor ('Regular 2',urec.color5);
    showcolor ('Statistic 2',urec.color6);
    showcolor ('Bar Color',urec.color7);
  end
end;

Procedure DoItYerSelfConfig;

Type Cords = Array[1..2] of Byte;
     XyRec = Record
       Name,Pass,Phon,AskN,Bars,FSEd,
       HotK,Emul,Rums,Note,More,Col1,Col2,
       Col3,Col4,Col5,Col6,Col7,Go:Cords;
     End;

Var Xy : XyRec;
    DefCol : Byte;
    K : Char;
    T : Text;
    L : String;
    NewPW : Mstr;
    DoAgain : Boolean;

    Procedure AssignXy(VAR What:Cords);
    Var X,Y:Byte;
        Temp:Sstr;
    Begin
      Temp:=L[3];
      If L[4]<>',' Then Temp:=Temp+L[4];
      X:=Valu(Temp);
      If L[5]<>',' Then Begin
        Temp:=L[5];
        If Length(L)>5 then Temp:=Temp+L[6];
      End Else Begin
        Temp:=L[6];
        If Length(L)>6 Then Temp:=Temp+L[7];
      End;
      Y:=Valu(Temp);
      What[1]:=X;
      What[2]:=Y;
    End;

    Procedure Show(S:String; XY:Cords);
    Begin
      If (Xy[1]=0) or (Xy[2]=0) Then Exit;
      GoXy(Xy[1],Xy[2]);
      Write(Direct,S);
    End;

    Procedure ShowEmul;
    Var S:Sstr;
    Begin
     If (Xy.Emul[1]=0) or (Xy.Emul[2]=0) Then Exit;
     Goxy(Xy.Emul[1],Xy.Emul[2]);
     AnsiColor(DefCol);
     If Avatar in Urec.Config Then
       S:='AVATAR' Else
     If AnsiGraphics in Urec.Config Then
       S:='ANSI  ' Else
     If VT52 in Urec.config then
       S:='VT52  ' Else
       S:='NONE  ';
    Write(Direct,S);
   End;

   Procedure Color(Col:Byte; XY:Cords);
   Begin
     If (Xy[1]=0) or (Xy[2]=0) Then Exit;
     GoXy(Xy[1],Xy[2]);
     ShowColor('',Col);
   End;

   Procedure Alternate(XY:Cords; C:ConfigType);
   Begin
     If (Xy[1]=0) or (Xy[2]=0) Then Exit;
     GoXy(Xy[1],Xy[2]);
     If C in Urec.Config Then Urec.Config:=Urec.Config-[C] Else
     Urec.Config:=Urec.Config+[C];
     Show(YesNo(C in Urec.Config),XY);
   End;

   Procedure DoColor(XY:Cords; VAR Col:Byte);
   Begin
     If (Xy[1]=0) or (Xy[2]=0) Then Exit;
     GoXy(Xy[1],Xy[2]);
     NewColor(Col);
     GoXy(Xy[1],Xy[2]);
     Tab(' ',25);
     GoXy(Xy[1],Xy[2]);
     ShowColor('',Col);
   End;

Begin
  DoAgain:=False;
  FillChar(Xy,SizeOf(Xy),0);
  DefCol:=1;
  Assign(T,Cfg.TextFileDir+'CONFIG.NFO');
  Reset(T);
  While Not(Eof(T)) Or (HungUpOn) Do Begin
    Readln(T,L);
    If Pos('DEFCOLOR=',UpString(L))>0 Then
      DefCol:=Valu(Copy(L,10,Length(L)))
    Else Case Upcase(L[1]) Of
      'A':AssignXy(Xy.Name);
      'P':AssignXy(Xy.Pass);
      'U':AssignXy(Xy.Phon);
      'L':AssignXy(Xy.Bars);
      'K':AssignXy(Xy.AskN);
      'F':AssignXy(Xy.FSed);
      'H':AssignXy(Xy.HotK);
      'E':AssignXy(Xy.Emul);
      'R':AssignXy(Xy.Rums);
      'N':AssignXy(Xy.Note);
      'M':AssignXy(Xy.More);
      '1':AssignXy(Xy.Col1);
      '2':AssignXy(Xy.Col2);
      '3':AssignXy(Xy.Col3);
      '4':AssignXy(Xy.Col4);
      '5':AssignXy(Xy.Col5);
      '6':AssignXy(Xy.Col6);
      '7':AssignXy(Xy.Col7);
      '@':AssignXy(Xy.Go);
    End;
  End;
  TextClose(T);
  PrintFile(Cfg.TextFileDir+'CONFIG.ANS');
  AnsiColor(DefCol);
  With Urec Do Begin
    Show(RealName,Xy.Name);
    Show('(Classified)',Xy.Pass);
    Show(Phonenum,Xy.Phon);
    Show(YesNo(UseBars in Config),Xy.Bars);
    Show(YesNo(PostPrompts in Config),Xy.AskN);
    Show(YesNo(FSEditor in Config),Xy.FSed);
    Show(YesNo(HotKeys in Config),Xy.HotK);
    Show(YesNo(MorePrompts in Config),Xy.More);
    ShowEmul;
    Show(YesNo(ShowRumors in Config),Xy.Rums);
    If Cfg.ChangeNote=True Then Show(SysOpNote,Xy.Note) Else
      Show('- Disabled -',Xy.Note);
    Color(Color1,Xy.Col1);
    Color(Color2,Xy.Col2);
    Color(Color3,Xy.Col3);
    Color(Color4,Xy.Col4);
    Color(Color5,Xy.Col5);
    Color(Color6,Xy.Col6);
    Color(Color7,Xy.Col7);
  End;
  Repeat
    AnsiColor(DefCol);
    GoXy(Xy.Go[1],Xy.Go[2]);
    K:=WaitForChar(False);
    K:=Upcase(K);
    Case K Of
   'N':If Cfg.ChangeNote then Begin
        Goxy(Xy.Note[1],Xy.Note[2]);
        NoCRInput('Forget It!',29);
        If inpt>'' then Urec.SysopNote:=inpt;
        Goxy(Xy.Note[1],Xy.Note[2]);
        AnsiColor(DefCol);
        Tab(Urec.SysopNote,30);
       End;
   'A':Begin
        GoXy(Xy.Name[1],Xy.Name[2]);
        InputBox(30);
        If inpt>'' then
          Urec.RealName:=inpt;
        GoXy(Xy.Name[1],Xy.Name[2]);
        AnsiColor(DefCol);
        Tab(urec.realname,30);
       End;
   'P':Begin
        NewPw:='';
        GoXy(Xy.Pass[1],Xy.Pass[2]);
        Write('New PW: ');
        InputBox(20);
        If inpt>'' then Begin
          NewPw:=inpt;
          GoXy(Xy.Pass[1],Xy.Pass[2]);
          Write('Verify: ');
          InputBox(20);
          If inpt>'' then If UpString(NewPw)=UpString(inpt)
            Then Urec.Password:=inpt Else
            NewPw:='';
        End;
        If NewPw<='' then Begin
          goxy(Xy.Pass[1],Xy.Pass[2]);
          Write('Aborted...    ');
          Delay(250);
        End;
        GoXy(Xy.Pass[1],Xy.Pass[2]);
        AnsiColor(DefCol);
        Tab('(Classified)',30);
       End;
   'U':Begin
         Goxy(Xy.Phon[1],Xy.Phon[2]);
         GetPhoneNum;
         If Validphone(True) then urec.phonenum:=inpt;
         Printxy(Xy.Phon[1],Xy.Phon[2],'                         ');
         Goxy(Xy.Phon[1],Xy.Phon[2]);
         AnsiColor(DefCol);
         Tab(urec.phonenum,25);
        End;
   'L':Alternate(Xy.Bars,UseBars);
   'K':Alternate(Xy.AskN,PostPrompts);
   'F':Alternate(Xy.Fsed,Fseditor);
   'H':Alternate(Xy.HotK,HotKeys);
   'R':Alternate(Xy.Rums,ShowRumors);
   'M':Alternate(Xy.More,MorePrompts);
   'E':Begin
        If Avatar in urec.config then
          urec.config:=urec.config-[avatar] else
          urec.config:=urec.config+[avatar];
        Urec.Config := Urec.Config + [ANSIGraphics];
        ShowEmul;
        End;
   '1':DoColor(Xy.Col1,Urec.Color1);
   '2':DoColor(Xy.Col2,Urec.Color2);
   '3':DoColor(Xy.Col3,Urec.Color3);
   '4':DoColor(Xy.Col4,Urec.Color4);
   '5':DoColor(Xy.Col5,Urec.Color5);
   '6':DoColor(Xy.Col6,Urec.Color6);
   '7':DoColor(Xy.Col7,Urec.Color7);
   'X':Begin
         Ansireset;
         AnsiCls;
         GetPrompt;
         DoAgain:=True;
         K:='Q';
       End;
   '=':Begin
        AnsiReset;
        RestoreOldColors;
        DoAgain:=True;
        K:='Q';
      End;
    End;
  Until (K='Q') or (HungUpOn);
  If DoAgain Then DoItYerSelfConfig;
  AnsiCls;
End;

(*


Procedure FullScreenUserConfig;
VAR K:Char; Back,I:Byte;
    DoAgain,Done:Boolean;
    NewPw:Mstr;

    Procedure ShowThing(C:ConfigType);
    Begin
      If C In Urec.Config then Write(^S'Yes') Else Write(^S'No ');
    End;

    Procedure ShowEmul;
    Var S:Sstr;
    Begin
     Goxy(69,8);
     If Avatar in Urec.Config Then
       S:='AVATAR' Else
     If AnsiGraphics in Urec.Config Then
       S:='ANSI  ' Else
     If VT52 in Urec.config then
       S:='VT52  ' Else
       S:='NONE  ';
    Write(^S+S);
   End;

   Procedure AlterNate(C:ConfigType);
   Begin
     If C in urec.config then urec.config:=urec.config-[c] else
     urec.config:=urec.config+[c];
     Showthing(C);
   End;

BEGIN
  Back:=UseBottom;
  UseBottom:=0;
  DoAgain:=False;
  InitWinds;
  Bottomline;
  Ansicls;
  Write(^R'Õ['^A'User Config'^R']'); For i:=1 to 64 Do Write('Í'); Writeln('¸');
  Write(^R'³ '^P'Command '^O'[ ] '^R); Write(#27+'[64C'); Writeln('³');
  Write(^R'Ô'); For i:=1 to 77 Do Write('Í'); Writeln('¾');
  Goxy(16,2); Write(^R+'User ['^S'N'^R']ote: '^S);
  If Cfg.ChangeNote Then Writeln(urec.sysopnote) Else Writeln('- Disabled -');
  Writeln;
  Write(^R'Ú'); For i:=1 to 77 Do Write('Ä'); Writeln('¿');
  Writeln(^R'³ ['^P'A'^R'] Real Name:'+#27+'[33C['^P'K'^R'] Ask NewScan  :           ³');
  Writeln(^R'³ ['^P'P'^R'] Password :'+#27+'[33C['^P'F'^R'] FullScreen Ed:           ³');
  Writeln(^R'³ ['^P'U'^R'] Phone Num:'+#27+'[33C['^P'H'^R'] Hot Keys     :           ³');
  Writeln(^R'³ ['^P'L'^R'] Bars?    :'+#27+'[33C['^P'E'^R'] Emulation    :           ³');
  Writeln(^R'³ ['^P'G'^R'] Page Lgth:'+#27+'[33C['^P'R'^R'] Show Rumors? :           ³');
  Write(^R'À'); For i:=1 to 77 Do Write('Ä'); Writeln('Ù'^S);
  Write(^R'Ú'); For i:=1 to 77 Do Write('Ä'); Writeln('¿');
  Writeln(^R'³ ['^P'1'^R'] Regular Color :'+#27+'[57C³');
  Writeln(^R'³ ['^P'2'^R'] Status Color  :'+#27+'[57C³');
  Writeln(^R'³ ['^P'3'^R'] Prompts Color :'+#27+'[57C³');
  Writeln(^R'³ ['^P'4'^R'] Input Color   :'+#27+'[57C³');
  Writeln(^R'³ ['^P'5'^R'] Status Color 2:'+#27+'[57C³');
  Writeln(^R'³ ['^P'6'^R'] Prompt Color 2:'+#27+'[57C³');
  Writeln(^R'³ ['^P'7'^R'] Bar Color     :'+#27+'[57C³');
  Write(^R'À'); For i:=1 to 77 Do Write('Ä'); Writeln('Ù'^S);
  Write(^R'Ú'); For i:=1 to 77 Do Write('Ä'); Writeln('¿');
  Writeln(^R'³ ['^P'X'^R'] Configure Prompt   ['^P'='^R'] Set Colors To Defaults'+#27+'[27C³');
  Write(^R'À'); For i:=1 to 77 Do Write('Ä'); Writeln('Ù'^S);
  PrintXy(18,5,Urec.RealName);
  GoXy(69,5); ShowThing(PostPrompts);
  PrintXy(18,6,'Classified');
  GoXy(69,6); ShowThing(FSEditor);
  PrintXy(18,7,urec.phonenum);
  GoXy(69,7); ShowThing(HotKeys);
  GoXy(18,8); showthing(UseBars);
  ShowEmul;
  PrintXy(18,9,Strr(Urec.DisplayLen));
  GoXy(69,9); Showthing(ShowRumors);
  GoXy(23,12); ShowColor('',urec.color1);
  GoXy(23,13); ShowColor('',urec.color2);
  GoXy(23,14);ShowColor('',urec.color3);
  GoXy(23,15);ShowColor('',urec.color4);
  GoXy(23,16);showcolor('',urec.color5);
  GoXy(23,17);showcolor('',urec.color6);
  GoXy(23,18);showcolor('',urec.color7);
  Bottomline;
  GoXy(12,2);
  Repeat
    K:=WaitForChar(False);
    CASE Upcase(K) OF
      'N':If Cfg.ChangeNote then Begin
           Goxy(29,2);
           NoCRInput('Forget It!',29);
           If inpt>'' then Urec.SysopNote:=inpt;
           Goxy(29,2);
           Tab(^S+Urec.SysopNote,30);
          End;
      'A':Begin
           GoXy(18,5);
           InputBox(30);
           If inpt>'' then
             Urec.RealName:=inpt;
           GoXy(18,5);
           Tab(^S+urec.realname,31);
          End;
      'P':Begin
           NewPw:='';
           GoXy(18,6);
           Write(^P'New PW: ');
           InputBox(20);
           If inpt>'' then Begin
             NewPw:=inpt;
             GoXy(18,6);
             Write(^P'Verify: ');
             InputBox(20);
             If inpt>'' then If UpString(NewPw)=UpString(inpt)
               Then Urec.Password:=inpt Else
               NewPw:='';
           End;
           If NewPw<='' then Begin
             goxy(18,6);
             Write(^U'Aborted...    ');
             Delay(250);
           End;
           GoXy(18,6);
           Tab(^S+'Classified',30);
          End;
      'U':Begin
            Goxy(18,7);
            GetPhoneNum;
            If Validphone(True) then urec.phonenum:=inpt;
            Printxy(18,7,'                         ');
            Goxy(18,7);
            Tab(^S+urec.phonenum,25);
           End;
      'L':Begin
           Goxy(18,8);
           Alternate(UseBars);
          End;
      'G':Begin
            Goxy(18,9);
            Write('  '+^H^H);
            Buflen:=2;
            WriteStr('&');
            If (Valu(inpt)>21) and (Valu(inpt)<45)
            Then Urec.Displaylen:=Valu(inpt);
            Goxy(18,9);
            Write(^S+Strr(urec.displaylen));
          End;
      'K':Begin
            goxy(69,5);
            Alternate(PostPrompts);
          End;
      'F':Begin
            goxy(69,6);
            Alternate(Fseditor);
          End;
      'H':Begin
           goxy(69,7);
           Alternate(HotKeys);
          End;
      'E':Begin
           If Avatar in urec.config then
             urec.config:=urec.config-[avatar] else
             urec.config:=urec.config+[avatar];
           ShowEmul;
           End;
      'R':Begin
           Goxy(69,9);
           Alternate(ShowRumors);
          End;
      '1':Begin
           Goxy(23,12);
           NewColor(urec.color1);
           Printxy(23,12,'                              ');
           Goxy(23,12);
           ShowColor('',urec.color1);
          End;
      '2':Begin
           Goxy(23,13);
           NewColor(urec.color2);
           Printxy(23,13,'                              ');
           Goxy(23,13);
           ShowColor('',urec.color2);
          End;
      '3':Begin
           Goxy(23,14);
           NewColor(urec.color3);
           Printxy(23,14,'                              ');
           Goxy(23,14);
           ShowColor('',urec.color3);
          End;
      '4':Begin
           Goxy(23,15);
           NewColor(urec.color4);
           Printxy(23,15,'                              ');
           Goxy(23,15);
           ShowColor('',urec.color4);
          End;
      '5':Begin
           Goxy(23,16);
           NewColor(urec.color5);
           Printxy(23,16,'                              ');
           Goxy(23,16);
           ShowColor('',urec.color5);
          End;
      '6':Begin
           Goxy(23,17);
           NewColor(urec.color6);
           Printxy(23,17,'                              ');
           Goxy(23,17);
           ShowColor('',urec.color6);
          End;
      '7':Begin
           Goxy(23,18);
           NewColor(urec.color7);
           Printxy(23,18,'                              ');
           Goxy(23,18);
           ShowColor('',urec.color7);
          End;
      'X':Begin
            Ansireset;
            AnsiCls;
            GetPrompt;
            DoAgain:=True;
            K:='Q';
          End;
      '=':Begin
           AnsiReset;
           RestoreOldColors;
           DoAgain:=True;
           K:='Q';
         End;
      End;
  GoXy(12,2);
  Until Upcase(K)='Q';
  Ansireset;
  AnsiCls;
  If DoAgain then FullScreenUserConfig;
  UseBottom:=Back;
  initwinds;
  bottomline;
End;

*)

begin
end.


var q:integer;
    usefullscreen:Boolean;
begin
  usefullscreen:=false;
  DefYes:=True;
  WriteStr(^M^M^M^P'Use Full Screen User Editor? !');
  UseFullScreen:=Yes;
  If UseFullScreen Then If (Exist(Cfg.TextFileDir+'CONFIG.NFO')) and
    (Exist(Cfg.TextFileDir+'CONFIG.ANS')) Then
    DoItYerSelfConfig Else
  FullScreenUserConfig Else
  Begin
  repeat
    if (not (lowercase in urec.config)) and (ansigraphics in urec.config)
      then begin
        urec.config:=urec.config+[lowercase];
        writeln('You may not use ANSI in uppercase-only mode.')
      end;
    if (fseditor in urec.config) and
       (urec.config=urec.config-[avatar,ansigraphics,vt52])
      then begin
        urec.config:=urec.config-[fseditor];
        writeln('You may not use the full-screen editor without AVATAR, ANSI or VT52 emulation.')
      end;
    q:=menu ('User Configuration','CONFIG','QLWOMGRUED!#$%NYF^&*XZH');
    case q of
      2:getthing (linefeeds);
      3:getthing (eightycols);
      4:getthing (postprompts);
      5:getthing (moreprompts);
      6:getthing (asciigraphics);
      7:getthing (showrumors);
      8:getthing (lowercase);
      9:emulation;
      10:getdisplaylen;
      11:getcolor ('Prompt',urec.color3);
      12:getcolor ('Inpt',urec.color4);
      13:getcolor ('Regular',urec.color1);
      14:getcolor ('Statistic',urec.color2);
      15:configurenewscan;
      16:yourstatus;
      17:getthing (fseditor);
      18:getcolor ('Regular 2',urec.color5);
      19:getcolor ('Status 2',urec.color6);
      20:getcolor ('Bar Color',urec.color7);
      21:GetPrompt;
      22:If Cfg.ChangeNote Then Begin
           Writeln(^M^R'Your User Note'^A': '^S+Urec.SysopNote);
           WriteStr(^R'New User Note '^A': *');
           If inpt<>'' then Urec.SysopNote:=inpt;
         End;
      23:GetThing(HotKeys);
    end;
  until (q=1) or hungupon or UseFullScreen;
  End;
  Writeurec;
end;