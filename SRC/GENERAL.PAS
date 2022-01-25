
unit general;

interface

uses dos,types,MDosIo;

function strr (n:integer):mstr;
function streal (r:real):mstr;
function strlong (l:longint):mstr;
function valu (q:mstr):integer;
function longvalu (q:mstr):longint;
function addrstr (p:pointer):sstr;
procedure parse3 (s:lstr; var a,b,c:word);
function packtime (var dt:datetime):longint;
    { Replaces Turbo's procedural version }
function now:longint;
function timestr (time:longint):sstr;
function timeval (q:sstr):longint;
function timepart (time:longint):longint;
function datestr (time:longint):sstr;
function dateval (q:sstr):longint;
function datepart (time:longint):longint;
function upstring (s:anystr):anystr;
function match (s1,s2:anystr):boolean;
function devicename (name:lstr):boolean;
function exist (n:lstr):boolean;
procedure appendfile (name:lstr; var q:text);
procedure addexitproc (p:pointer);
procedure doneexitproc;

implementation

const maxexitprocs=25;

var exitstack:array [1..maxexitprocs] of pointer;
    exitstackptr:integer;

type packedtimerec=record
       date,time:word
     end;

function strr (n:integer):mstr;
var q:mstr;
begin
  str (n,q);
  strr:=q
end;

function streal (r:real):mstr;
var q:mstr;
begin
  str (r:0:0,q);
  streal:=q
end;

function strlong (l:longint):mstr;
var q:mstr;
begin
  str (l,q);
  strlong:=q
end;

function valu (q:mstr):integer;
var i,s,pu:integer;
    r:real;
begin
  valu:=0;
  if length(q)=0 then exit;
  if not (q[1] in ['0'..'9','-']) then exit;
  if length(q)>5 then exit;
  val (q,r,s);
  if s<>0 then exit;
  if (r<=32767.0) and (r>=-32767.0)
    then valu:=round(r)
end;

function longvalu (q:mstr):longint;
var i,s,pu:integer;
    r:longint;
begin
  longvalu:=0;
  if length(q)=0 then exit;
  if not (q[1] in ['0'..'9','-']) then exit;
  if length(q)>11 then exit;
  val (q,r,s);
  if s<>0 then exit;
  if (r<=2147483647) and (r>=-2147483647)
    then longvalu:=r
end;

function addrstr (p:pointer):sstr;

  function hexstr (n:integer):sstr;

    function hexbytestr (b:byte):sstr;
    const hexchars:array[0..15] of char='0123456789ABCDEF';
    begin
      hexbytestr:=hexchars[b shr 4]+hexchars[b and 15]
    end;

  begin
    hexstr:=hexbytestr (hi(n))+hexbytestr(lo(n))
  end;

begin
  addrstr:=hexstr(seg(p^))+':'+hexstr(ofs(p^))
end;

procedure parse3 (s:lstr; var a,b,c:word);
var p:integer;

  procedure parse1 (var n:word);
  var ns:lstr;
  begin
    ns[0]:=#0;
    while (p<=length(s)) and (s[p] in ['0'..'9']) do begin
      ns:=ns+s[p];
      p:=p+1
    end;
    if length(ns)=0
      then n:=0
      else n:=valu(ns);
    if p<length(s) then p:=p+1
  end;

begin
  p:=1;
  parse1 (a);
  parse1 (b);
  parse1 (c)
end;

function packtime (var dt:datetime):longint;
var l:longint;
begin
  dos.packtime (dt,l);
  packtime:=l
end;

function now:longint;
var dt:datetime;
    t:word;
    l:longint;
begin
  gettime (dt.hour,dt.min,dt.sec,t);
  getdate (dt.year,dt.month,dt.day,t);
  l:=packtime (dt);
  now:=l
end;

function timestr (time:longint):sstr;
var h1:integer;
    ms:sstr;
    dt:datetime;
const ampmstr:array [false..true] of string[2]=('am','pm');
begin
  unpacktime (time,dt);
  h1:=dt.hour;
  if h1=0
    then h1:=12
    else if h1>12
      then h1:=h1-12;
  ms:=strr(dt.min);
  if dt.min<10 then ms:='0'+ms;
  timestr:=strr(h1)+':'+ms+' '+ampmstr[dt.hour>11]
end;

function datestr (time:longint):sstr;
var dt:datetime;
begin
  unpacktime (time,dt);
{  datestr:=strr(dt.month)+'/'+strr(dt.day)+'/'+strr(dt.year-1900) }
{  its calling GetTime from the DOS unit, which is pulling system time }
{   if the underlying windows is y2k compliant, you dont need to subtract }
{   1900 anymore.  Yay time.  -felonius 11-Jan 2022 }

   datestr:=strr(dt.month)+'/'+strr(dt.day)+'/'+strr(dt.year)
end;

Function Timepart (Time:Longint) : Longint;
Begin
  Timepart := Time And $0000FFFF;
end;

Function Datepart (Time:Longint) : Longint;
Begin
  DatePart := Time And $FFFF0000;
End;

procedure cleardatetime (var dt:datetime);
begin
  unpacktime (0,dt)
end;

function timeval (q:sstr):longint;
var h1,t:word;
    k:char;
    dt:datetime;
begin
  cleardatetime (dt);
  parse3 (q,h1,dt.min,t);
  k:=upcase(q[length(q)-1]);
  if h1 in [1..11]
    then
      begin
        dt.hour:=h1;
        if (k='P') then dt.hour:=dt.hour+12
      end
    else
      if k='P'
        then dt.hour:=12
        else dt.hour:=0;
  timeval := (dt.hour * 60) + (dt.min);
end;

function dateval (q:sstr):longint;
var dt:datetime;
begin
  cleardatetime (dt);
  Parse3 (q,dt.month,dt.day,dt.year);
  If Dt.Year < 100 Then Dt.Year := Dt.Year+1900;
  dateval:=datepart(packtime(dt))
end;

function upstring (s:anystr):anystr;
var cnt:integer;
begin
  for cnt:=1 to length(s) do s[cnt]:=upcase(s[cnt]);
  upstring:=s
end;

function match (s1,s2:anystr):boolean;
var cnt:integer;
begin
  match:=false;
  if length(s1)<>length(s2) then exit;
  for cnt:=1 to length(s1) do
    if upcase(s1[cnt])<>upcase(s2[cnt])
      then exit;
  match:=true
end;

function devicename (name:lstr):boolean;
var f:file;
    n:integer absolute f;
    r:registers;
begin
  devicename:=false;
  assign (f,name);
  reset (f);
  if ioresult<>0 then exit;
  r.bx:=n;
  r.ax:=$4400;
  intr ($21,r);
  devicename:=(r.dx and 128)=128;
  close (f)
end;

function exist (n:lstr):boolean;
var f:file;
    i:integer;
Begin
   Exist := Dos_Exists(N);
  { assign (f,n);
  reset (f);
  i:=ioresult;
  exist:=i=0;
  close (f);
  i:=ioresult
  }
End;

procedure appendfile (name:lstr; var q:text);
var n:integer;
    b:boolean;
    f:file of char;
begin
  close (q);
  n:=ioresult;
  assign (q,name);
  assign (f,name);
  reset (f);
  b:=(ioresult<>0) or (filesize(f)=0);
  close (f);
  n:=ioresult;
  if b
    then rewrite (q)
    else append (q)
end;

procedure addexitproc (p:pointer);
begin
  inc (exitstackptr);
  if exitstackptr>maxexitprocs then begin
    writeln ('Too many exit procedures');
    halt (255)
  end else begin
    exitstack[exitstackptr]:=exitproc;
    exitproc:=p
  end
end;

procedure doneexitproc;
begin
  exitproc:=exitstack[exitstackptr];
  dec (exitstackptr)
end;

begin
  exitstackptr:=0
end.