unit scrnunit;

{$R-,S-,I-,D-,V-,B-}

interface

uses dos,crt;

{$L scrn.obj}

const maxwindows=20;

type dataarearec=record
       scrnseg,
       filter,
       wchattr,
       wch,
       wattr,
       rchattr,
       scrnwid,
       dubscrnwid,
       numwindows,
       curwindow,
       beepduration,
       beepfrequency,
       realcursortrack:integer;
       windul,
       windlr,
       windulptr,
       windsize,
       windcursor,
       windcptr,
       windattr:array [1..maxwindows] of integer
     end;

     block=record
       x1,y1,x2,y2:byte
     end;

     window=record
       handle,index,
       x1,y1,x2,y2,xsize,ysize,
       titlecolor,framecolor,normalcolor,
       boldcolor,datacolor,choicecolor,barcolor,inputcolor,
       imagesize:integer;
       imageptr:pointer;
       title:string[80]
     end;

     windowptr=^window;

     jointtype=(vertleft,vertright,horizup,horizdown,cross);

var scrn:text;           { Accessed by SCRN.ASM }
    darea:dataarearec;   { Accessed by SCRN.ASM }

    wholescreen:window;
    curwindowptr:windowptr;

procedure initscrnunit;
procedure setblock (var b:block; x1,y1,x2,y2:integer);
procedure pushcurwindow;
procedure popcurwindow;
procedure pushdarea;       { DON'T DO pusdarea; movewindow; popdarea!!!! }
procedure popdarea;
procedure setcurwindow (var w:window);
procedure openwindow (var w:window; x1,y1,x2,y2,framecolor,normalcolor:integer);
procedure windowtitle (title:string);
procedure closewindow;
procedure movewindow (nx,ny:integer);
procedure reshapewindow (x1,y1,x2,y2:integer);
procedure gotoxy (x,y:integer);
procedure drawjoint (x,y:integer; jt:jointtype);
function  wherex:integer;
function  wherey:integer;
function  curcolor:integer;
procedure colorregion (x1,x2,y,attr:integer);
procedure clreol;
procedure clrscr;
procedure setfilter (filtersnow:boolean);
procedure setcursortracking (realtrack:boolean);
procedure fillblock (b:block; ch:char; a:integer);
procedure clearblock (b:block; a:integer);
procedure colorblock (b:block; a:integer);
procedure frameblock (b:block; a:integer);
procedure scrupblock (b:block; a:integer);
procedure scrdnblock (b:block; a:integer);
procedure readblock (b:block; var buffer);
procedure writeblock (b:block; var buffer);
procedure fillwindow (ch:char; a:integer);
procedure clearwindow (a:integer);
procedure colorwindow (a:integer);
procedure framewindow (a:integer);
procedure scrupwindow (a:integer);
procedure scrdnwindow (a:integer);
procedure readwindow (var buffer);
procedure writewindow (var buffer);
procedure setcolor (attr:integer);
procedure movecsr;

implementation

const windowstacksize=50;
      dareastacksize=50;
      jointchars:array [vertleft..cross] of char=(#180,#195,#193,#194,#197);

type dareaptr=^dataarearec;

var windowstack:array [0..windowstacksize] of windowptr;
    windowstackptr:integer;
    dareastack:array [1..dareastacksize] of dareaptr;
    dareastackcwp:array [1..dareastacksize] of windowptr;
    dareastackptr:integer;

{$F+}

procedure setfilter (filtersnow:boolean); external;
procedure setcursortracking (realtrack:boolean); external;
procedure fillblock (b:block; ch:char; a:integer); external;
procedure clearblock (b:block; a:integer); external;
procedure colorblock (b:block; a:integer); external;
procedure frameblock (b:block; a:integer); external;
procedure scrupblock (b:block; a:integer); external;
procedure scrdnblock (b:block; a:integer); external;
procedure readblock (b:block; var buffer); external;
procedure writeblock (b:block; var buffer); external;
procedure fillwindow (ch:char; a:integer); external;
procedure clearwindow (a:integer); external;
procedure colorwindow (a:integer); external;
procedure framewindow (a:integer); external;
procedure scrupwindow (a:integer); external;
procedure scrdnwindow (a:integer); external;
procedure readwindow (var buffer); external;
procedure writewindow (var buffer); external;
procedure setcolor (attr:integer); external;
procedure movecsr; external;

procedure initscrn; external;    {These aren't public}
procedure setwindow (x1,y1,x2,y2:integer); external;
procedure movexy (x,y:integer); external;
function  initwindow (x1,y1,x2,y2:integer):integer; external;
procedure killwindow; external;

{$F-}

procedure setblock (var b:block; x1,y1,x2,y2:integer);
begin
  b.x1:=x1;
  b.y1:=y1;
  b.x2:=x2;
  b.y2:=y2
end;

procedure setcurwindow (var w:window);
begin
  darea.curwindow:=w.handle;
  curwindowptr:=@w;
  if darea.realcursortrack<>0 then movecsr
end;

procedure pushcurwindow;
begin
  if windowstackptr>=windowstacksize then begin
    writeln ('Too many pushed windows');
    halt (1)
  end;
  inc (windowstackptr);
  windowstack[windowstackptr]:=curwindowptr
end;

procedure popcurwindow;
begin
  setcurwindow (windowstack[windowstackptr]^);
  if windowstackptr>0 then dec (windowstackptr)
end;

procedure pushdarea;
begin
  if dareastackptr>=dareastacksize then begin
    writeln ('Too many pushed data areas');
    halt (1)
  end;
  inc (dareastackptr);
  new (dareastack[dareastackptr]);
  dareastack[dareastackptr]^:=darea;
  dareastackcwp[dareastackptr]:=curwindowptr
end;

procedure popdarea;
begin
  if dareastackptr>0 then begin
    darea:=dareastack[dareastackptr]^;
    curwindowptr:=dareastackcwp[dareastackptr];
    dispose (dareastack[dareastackptr]);
    dec (dareastackptr);
  end
end;

procedure setwindowcoors (nx1,ny1,nx2,ny2:integer);
begin
  with curwindowptr^ do begin
    setwindow (nx1,ny1,nx2,ny2);
    x1:=nx1;
    y1:=ny1;
    x2:=nx2;
    y2:=ny2;
    xsize:=nx2-nx1-1;
    ysize:=ny2-ny1-1;
    imagesize:=(xsize+2)*(ysize+2)*2
  end
end;

procedure openwindow (var w:window; x1,y1,x2,y2,framecolor,normalcolor:integer);
begin
  pushcurwindow;
  x1:=x1-1;
  y1:=y1-1;
  x2:=x2-1;
  y2:=y2-1;
  w:=wholescreen;
  w.handle:=initwindow (x1,y1,x2,y2);
  setcurwindow (w);
  if w.handle<0 then begin
    writeln ('Too many opened windows');
    halt (1)
  end;
  w.index:=(w.handle div 2)+1;
  setwindowcoors (x1,y1,x2,y2);
  w.framecolor:=framecolor;
  w.normalcolor:=normalcolor;
  getmem (w.imageptr,w.imagesize);
  readwindow (w.imageptr^);
  framewindow (framecolor);
  clearwindow (normalcolor)
end;

procedure windowtitle (title:string);
begin
  pushdarea;
  movexy (1,0);
  setcolor (curwindowptr^.titlecolor);
  curwindowptr^.title:=title;
  write (scrn,copy(title,1,curwindowptr^.xsize));
  popdarea
end;

procedure closewindow;
var w:windowptr;
begin
  w:=curwindowptr;
  if w^.handle=0 then exit;
  writewindow (w^.imageptr^);
  freemem (w^.imageptr,w^.imagesize);
  killwindow;
  w^.handle:=0;
  popcurwindow
end;

{$S+}

procedure reshapewindow (x1,y1,x2,y2:integer);
var contblock:block;
    contents:array[1..4096] of byte;
    nxs,nys,cx2,cy2:integer;
    w:windowptr;
begin
  x1:=x1-1;
  y1:=y1-1;
  x2:=x2-1;
  y2:=y2-1;
  w:=curwindowptr;
  nxs:=x2-x1-1;
  nys:=y2-y1-1;
  if nxs<w^.xsize then cx2:=nxs else cx2:=w^.xsize;
  if nys<w^.ysize then cy2:=nys else cy2:=w^.ysize;
  setblock (contblock,0,0,cx2,cy2);
  readblock (contblock,contents);
  writewindow (w^.imageptr^);
  freemem (w^.imageptr,w^.imagesize);      { Old window essentially closed }
  setwindowcoors (x1,y1,x2,y2);
  getmem (w^.imageptr,w^.imagesize);
  readwindow (w^.imageptr^);
  framewindow (contents[2]);    { Use attribute from screen }
  clearwindow (w^.normalcolor);
  writeblock (contblock,contents)
end;

{$S-}

procedure movewindow (nx,ny:integer);
begin
  with curwindowptr^ do
    reshapewindow (nx,ny,nx+xsize+1,ny+ysize+1)
end;

procedure gotoxy (x,y:integer);
begin
  movexy (x,y)
end;

procedure drawjoint (x,y:integer; jt:jointtype);
begin
  pushcurwindow;
  x:=x+curwindowptr^.x1;
  y:=y+curwindowptr^.y1;
  setcurwindow (wholescreen);
  gotoxy (x,y);
  write (jointchars[jt]);
  popcurwindow
end;

function wherex:integer;
begin
  wherex:=lo(darea.windcursor[curwindowptr^.index])
end;

function wherey:integer;
begin
  wherey:=darea.windcursor[curwindowptr^.index] shr 8
end;

function curcolor:integer;
begin
  curcolor:=darea.windattr[curwindowptr^.index]
end;

procedure colorregion (x1,x2,y,attr:integer);
var b:block;
begin
  setblock (b,x1,y,x2,y);
  colorblock (b,attr)
end;

procedure clreol;
var b:block;
    y:integer;
begin
  y:=wherey;
  setblock (b,wherex,y,curwindowptr^.xsize,y);
  clearblock (b,curcolor)
end;

procedure clrscr;
begin
  clearwindow (curcolor);
  gotoxy (1,1)
end;

procedure initscrnunit;
begin
  initscrn;
  with wholescreen do begin
    handle:=0;
    index:=1;
    x1:=-1;
    y1:=-1;
    x2:=darea.scrnwid;
    y2:=25;
    xsize:=x2;
    ysize:=y2;
    titlecolor:=$70;
    framecolor:=7;
    normalcolor:=7;
    boldcolor:=15;
    choicecolor:=15;
    datacolor:=15;
    barcolor:=$70;
    inputcolor:=15;
    imagesize:=0;
    imageptr:=nil
  end;
  dareastackptr:=0;
  windowstackptr:=0;
  windowstack[0]:=@wholescreen;
  curwindowptr:=@wholescreen;
  with textrec(output) do begin
    inoutfunc:=textrec(scrn).inoutfunc;
    flushfunc:=textrec(scrn).flushfunc
  end
end;

begin
  initscrnunit
end.
