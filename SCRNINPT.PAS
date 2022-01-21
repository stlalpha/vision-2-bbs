unit scrninpt;

{ Makes it so READLN uses a nice little scrollable region }
{ The default input region is the cursor position to the end of the line }

{$R-,S-,I-,D-,V-,B-,L+}

interface

uses dos,crt,
     scrnunit;

var scrnin:text;         { For input }
    buflen:integer;


procedure setinputregion (left,right,line:integer);
procedure setdefaultinput (x:string);
procedure setinputcolor (attr:integer);

implementation

var scrninbuf:array [0..257] of char;
    x1,x2,y:integer;
    oldinput:string;

{$F+}

function donothing (var t:textrec):integer;
begin
{  t.bufend:=0;
  t.bufpos:=0;  }
  donothing:=0
end;

function scrninchars (var t:textrec):integer;
var s:string;
    len:byte absolute s;
    cx,lx,wid:integer;
    k:char;
    tracking:boolean;

const letters:set of char=['A'..'Z','a'..'z'];

  procedure drawit;
  var cnt:integer;
  begin
    gotoxy (x1,y);
    write (scrn,copy(s,lx,wid));
    for cnt:=1 to wid-len+lx-1 do write (' ');
    gotoxy (cx-lx+x1,y);
    movecsr
  end;

  procedure insert (k:char);
  begin
    if len>=buflen then exit;
    s:=copy(s,1,cx-1)+k+copy(s,cx,255);
    cx:=cx+1
  end;

  procedure del;
  begin
    if cx<=len then s:=copy(s,1,cx-1)+copy(s,cx+1,255)
  end;

  procedure backspace;
  begin
    if cx>1 then begin
      cx:=cx-1;
      del
    end
  end;

  procedure wordleft;
  begin
    if cx=1 then exit;
    cx:=cx-1;
    while (cx>1) and ((s[cx-1] in letters) or (not (s[cx] in letters))) do
      cx:=cx-1
  end;

  procedure wordright;
  begin
    if cx>len then exit;
    cx:=cx+1;
    while (cx<=len) and ((s[cx-1] in letters) or (not (s[cx] in letters))) do
      cx:=cx+1;
  end;

  procedure delword;
  begin
    while (cx<=len) and (s[cx] in letters) do del;
    while (cx<=len) and (not (s[cx] in letters)) do del
  end;

  procedure extended (key:integer);
  begin
    case key of
      71,73:cx:=1;
      75:cx:=cx-1;
      77:cx:=cx+1;
      79,81:cx:=len+1;
      83:del;
      115:wordleft;
      116:wordright;
      117:len:=cx-1;
    end
  end;

  procedure normal (k:char);
  begin
    case ord(k) of
      32..126:if len<buflen then insert(k);
      128..255:if len<buflen then insert(k); {demo}
      8:backspace;
      27:len:=0;
      127,20:delword
    end
  end;

begin
  scrninchars:=0;
  if t.bufend<>t.bufpos then exit;
  pushdarea;
  setcursortracking (false);
  setcolor (curwindowptr^.inputcolor);
  s:=oldinput;
  if x1=0 then begin
    x1:=wherex;
    y:=wherey;
    x2:=curwindowptr^.xsize
  end;
  lx:=1;
  cx:=1;
  wid:=x2-(x1+1);
  repeat
    if cx<1 then cx:=1;
    if cx>len then cx:=len+1;
    if lx>cx-5 then lx:=cx-5;
    if lx<cx-wid+5 then lx:=cx-wid+5;
    if lx>len-wid+1 then lx:=len-wid+1;
    if lx>cx then lx:=cx;
    if lx<cx-wid then lx:=cx-wid;
    if lx<1 then lx:=1;
    if not keypressed then drawit;
    k:=readkey;
    if k=#0 then extended(ord(readkey)) else normal(k)
  until k=#13;
  drawit;
  s:=s+#13#10;
  move (s[1],t.bufptr^,length(s));
  x1:=0;
  buflen:=80;
  oldinput:='';
  t.bufpos:=0;
  t.bufend:=len;
  popdarea
end;

{$F+}

procedure setinputregion (left,right,line:integer);
begin
  x1:=left;
  x2:=right;
  y:=line
end;

procedure setdefaultinput (x:string);
begin
  oldinput:=x
end;

procedure setinputcolor (attr:integer);
begin
  curwindowptr^.inputcolor:=attr
end;

begin
  x1:=0;          { Initialize input stuff }
  buflen:=80;
  oldinput:='';
  with textrec(scrnin) do begin
    mode:=fminput;
    bufptr:=@scrninbuf;
    bufsize:=258;
    openfunc:=@donothing;
    closefunc:=@donothing;
    inoutfunc:=@scrninchars;
    flushfunc:=@donothing;
    bufpos:=0;
    bufend:=0
  end;
  move (scrnin,input,sizeof(textrec))
end.

