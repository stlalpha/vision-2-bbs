{$R-,S-,I-,D-,F+,V-,B-,N-,L+ }

unit windows;

interface

uses PAVT150,gensubs,gentypes,crt,subs1,configrt,modem,statret,Video;

var winds:array [0..2] of windowrec;
    split,inuse:integer;

procedure getcoor;
procedure usewind (n:byte);
procedure setwind (n:byte; nx1,ny1,nx2,ny2:byte);
procedure initwind (n,nx1,ny1,nx2,ny2,ncolor:byte);
procedure top;
procedure bottom;
procedure wholescreen;
procedure drawsplit;
procedure initwinds;
procedure unsplit;
procedure splitscreen (v:byte);
procedure setoutlock (b:boolean);
Procedure SetUpBottom;
procedure bottomline;
procedure ansicls;

implementation

TYPE ScreenType = array [0..7999] of Byte;

VAR ScreenAddr:ScreenType Absolute $B800:$0000;

{$I STATUS.PAS}

procedure getcoor;
begin
{  with winds[inuse] do begin
    cx:=wherex;
    cy:=wherey;
    if cy<1 then cy:=1;
    if cy>(y2-y1)+1 then cy:=(y2-y1)+1
  end }
end;

procedure usewind (n:byte);
begin
{  getcoor;
  inuse:=n;
  with winds[n] do begin
    window (x1,y1,x2,y2);
    {gotoxy (cx,cy);
    textattr:=color;
    lasty:=y2-y1+1
  end }
end;

procedure setwind (n:byte; nx1,ny1,nx2,ny2:byte);
var i:integer;
begin
{  i:=inuse;
  usewind(n);
  with winds[n] do begin
    x1:=nx1;
    y1:=ny1;
    x2:=nx2;
    y2:=ny2
  end;
  usewind(n);
  if n<>i then usewind(i) }
end;

procedure initwind (n,nx1,ny1,nx2,ny2,ncolor:byte);
begin
{  with winds[n] do begin
    x1:=nx1;
    y1:=ny1;
    x2:=nx2;
    y2:=ny2;
    cx:=1;
    cy:=1;
    color:=ncolor
  end }
end;

procedure top;
begin
  {usewind (1)}
end;

procedure bottom;
begin
  {usewind (2)}
end;

procedure wholescreen;
begin
  {usewind (0);
  inuse:=0;}
end;

procedure drawsplit;
var cnt:integer;
begin
  usewind (0);
  TextAttr:=8;
  gotoxy (1,split);
  for cnt:=0 to 79 do write (usr,chr(196));
  bottom
end;

procedure initwinds;
begin
  splitmode:=false;
  {initwind (0,1,1,80,25,Cfg.splitcolor);}
  If (usebottom>0) and (UseBottom<3) then SetScreenSize(80,24) Else
  SetScreenSize(80,25);
  split:=0;
  inuse:=0;
  {bottom}
end;

procedure unsplit;
var y:integer;
begin
  SplitMode:=False;
End;
{
  if not splitmode then exit;
  if inuse=2
    then y:=wherey
    else y:=winds[2].cy;
  y:=y+split;
  If Usebottom>0 then setwind (2,1,1,80,25) Else
  setwind (2,1,1,80,25);
  setwind (1,1,1,80,split);
  top;
  clrscr;
  splitmode:=false;
  bottom;
  gotoxy (wherex,y)

end; }

procedure splitscreen (v:byte);
var x,y:integer;
begin
{
  if splitmode then unsplit;
  x:=wherex;
  y:=wherey-v;
  splitmode:=true;
  split:=v;
  drawsplit;
  initwind (1,1,1,80,split-1,Cfg.normtopcolor);
  If usebottom>0 then setwind (2,1,split+1,80,25) Else
  setwind (2,1,split+1,80,25);
  top;
  clrscr;
  bottom;
  gotoxy (x,y)
  }
end;

procedure setoutlock (b:boolean);
begin
  modemoutlock:=b;
  if b
    then winds[2].color:=9
    else winds[2].color:=1;
  {if inuse=2 then usewind (2)}
end;

Procedure SetUpBottom;
Begin
  If UseBottom=3 Then DrawStatus;
End;

procedure bottomline;
var o:integer;
    A:Real;

  procedure flash (q:anystr);
  begin
    textcolor (31);
    write (usr,q);
    textcolor (15)
  end;

  Procedure dull (q:Sstr);
  Begin
    Textcolor(8);
    Write(usr,q);
    Textcolor(15);
  End;

  Procedure Yes(X,Y:Byte; B:Boolean);
  Begin
    If B Then XYString(X,Y,'On ',14,0) Else
      XYString(X,Y,'Off',14,0);
  End;

Var OldX,OldY:Byte;
begin

  If usebottom<=0
    then Exit;;

  if (unum < 1) or ((splitmode) and (Dots)) then exit;
  TextAttr:=1;
  OldX:=WhereX; OldY:=WhereY;
{  o:=inuse;
  wholescreen; }
  If UseBottom=3 Then Begin
    XYString(17,27,Urec.Handle,14,0);
    XyString(54,27,Strr(TimeLeft)+'  ',14,0);
    XyString(74,27,Strr(Timer - LogonTime),14,0);
    XYString(17,28,Urec.SysOpNote,14,0);
    XYString(17,29,Strr(Urec.Level),14,0);
    XyString(50,29,TimeStr(Now),14,0);
    XyString(72,29,DateStr(Now),14,0);
    XYString(17,30,Strr(Urec.UDLevel),14,0);
    XyString(54,30,Strr(Urec.UDPoints),14,0);
    XyString(69,30,Strr(Urec.NBu),14,0);
    XYString(17,31,Urec.Flags,14,0);
    XYString(54,31,Strr(Urec.NumOn),14,0);
    XyString(69,31,Strr(Ratio(Urec.NBu,Urec.Numon))+'%',14,0);
    Yes(12,33,ModemInlock);
    Yes(27,33,ModemOutLock);
    Yes(43,33,TextTrap);
    Yes(61,33,TempSysOp);
    Yes(77,33,TimeLock);
    XyString(17,35,SysOpAvailStr,14,0);
    XYString(43,35,ConnectStr,14,0);
    If ChatMode Then XYString(2,36,'Chat: '+ChatReason,10,0) Else
    XyString(2,36,'                                  ',10,0);
  End Else Begin
    gotoxy (1,25);
    textattr:=112;

    If TimeLock
      Then Settimeleft (lockedtime);

    If No_Local_Output Then Begin
      TextColor(1);
      Write(Usr,Unam);
      Write(usr,' : -  Ctrl-F1 Toggles Local Output -  Alt-B Toggles this line');
    End Else
    If ChatMode Then Begin
      TextColor(1);
      Write(usr,unam);
      Write(usr,' - Chat Requested: ');
      Flash(Copy(chatreason,0,40));
      END ELSE
    If usebottom=2 Then BEGIN
      TextColor(8);
      Write(usr,'þ '); TextColor(15);
      Write(usr,timestr(now)); TextColor(8);
      if tempsysop then flash (' TempSysOp') else Dull(' TempSysOp');
      if sysnext then flash (' Next On') else dull(' Next On');
      if timelock then flash (' TimeLock') Else Dull(' TimeLock');
      if modeminlock then flash (' InLock') Else Dull(' InLock');
      if modemoutlock then flash (' OutLock') Else Dull(' OutLock');
      if texttrap then flash (' TRAP') ELSE Dull(' TRAP');
      if printerecho then flash (' PRN') else Dull(' PRN');
      TextColor(8);
      Write(usr,'  Page: '); TextColor(4);
      Write(usr,Copy(SysOpAvailStr,1,8));
      TextAttr:=112;
      End Else If UseBottom=1 then Begin
        TextBackground(7);
        TextColor(8);
        Write(usr,'('); TextColor(0);
        Write(usr,unam); TextColor(8);
        Write(usr,') ');
        If cursection=bulletinsysop Then
        Begin
          TextColor(4);
          If Local then Write(usr,'LOCAL')
          Else Write(usr,connectbaud); TextColor(8);
          Write(usr,' Posted: '); TextColor(15);
          Write(usr,urec.nbu); TextColor(8);
          Write(usr,' Calls: '); TextColor(15);
          Write(usr,urec.numon); TextColor(8);
          Write(usr,' PCR: '); Textcolor(15);
            A:=percentage(urec.nbu,urec.numon);
          Write(usr,streal(a)+'%'); TextColor(8);
          Write(usr,' Unread Messages: '); Textcolor(15);
          If unreadnewmsgs<0 then unreadnewmsgs:=0;
          Write(usr,strr(unreadnewmsgs));
        End Else
        If cursection=udsysop Then
        Begin
          Write(usr,'Lvl/Pts: '); TextColor(15);
          Write(usr,strr(urec.udlevel)); Dull('/'); Write(usr,strr(urec.udpoints)); TextColor(8);
          Write(usr,' U/D Ratio: '); TextColor(15);
          A:=percentage(urec.uploads,urec.downloads);
Write(usr,strr(urec.uploads)); Dull('/'); Write(usr,strr(urec.downloads)); Dull('='); Write(usr,streal(A)+'%'); TextColor(8);
          Write(usr,' K Ratio: '); Textcolor(15);
          A:=percentage(urec.Kup,urec.KDown);
      Write(usr,strr(urec.kup)); Dull('/'); Write(usr,strr(urec.kdown)); If WhereX<76 Then Dull('=');
      If WhereX<76 Then Write(usr,streal(A)+'%'); TextColor(8);
      End Else
      Begin
        TextColor(4);
        If Local then Write(usr,'LOCAL')
        Else Write(usr,connectbaud); TextColor(8);
        Write(usr,' Time: '); Textcolor(15);
        Write(usr,timeleft); Textcolor(8);
        Write(usr,' Lvl: '); Textcolor(15);
        Write(usr,urec.level); Textcolor(8);
        Write(usr,' Calls: '); TextColor(15);
        Write(usr,urec.numon); textcolor(8);
        Write(usr,' Last on: '); textcolor(15);
        If datepart(subs1.laston)>0 then
          Begin
          Write(usr,datestr(subs1.laston)); Textcolor(8);
          If WhereX<72 then Begin
          Write(usr,'/'); TextColor(15);
          Write(usr,timestr(subs1.laston));
          End;
          End
          Else Write(usr,'Never on');
        End;
    End;
  clreol;
  End;
  TextAttr:=1;
  GotoXy(OldX,OldY);
  {usewind (o);}
end;

procedure ansicls;
Var Temp:String[4];
    X:Byte;
begin
 If avatar in urec.config then Begin
   If Online Then SendChar(^L);
   Write(Direct,^L);
   Exit;
 End;
 Temp := #27 + '[2J';
 If Online Then
   For X:=1 to 4
     Do Sendchar(Temp[X]);
 For X:=1 to 4
   Do Write(Direct,Temp[X]);
 if (inuse<>0) then BottomLine;
end;

begin
end.