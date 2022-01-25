{$M 10024,1024,650000}
{$I PRODEF.INC}

program scroller;   (* Text scroller example by Crimson Blade *)

uses dos;

type  long_str   = string[80];

const linelength = 79;
      readfile   : string = '';
      maxlines   : word   = 0;
      colors     : array[1..6] of byte = (0,8,7,15,7,8);
      bottom     : array[1..4] of string =
       ('    - MANiAC Magazine Issue #2 -      ',
        '              Credits..               ',
        'Nocturnus - Magazine Editor and Coder.',
        ' Crimson Blade - Text Scroller Coding ');

type  line       = string[linelength];
      lptr       = ^linerec;
      linerec    = record
                     last : lptr;
                     data : line;
                     next : lptr;
                   end;

var   b1,b2      : byte;
      last_change: longint;
      ln, lastln, nextln, firstln, endln : lptr;

Procedure Cursor_On;
Begin
  ASM
    MOV Ah,1h
    MOV Ch,6h
    MOV Cl,7h
    INT 10h
  END
End;

Procedure Cursor_Off;
Begin
  ASM
    MOV Ah,1h
    MOV Ch,32h
    MOV Cl,0h
    INT 10h
  END;
End;

procedure fastwrite(col,row,attrib:byte; str:long_str);
var x,where : word;
begin
  for x := 1 to length(str) do
    begin
      where := ( (col + x) * 2) + (row * 160) - 162;
      mem[$B800:where+1] := attrib;
      mem[$B800:where]   := byte(str[x]);
    end;
end;

function lget_ms: longint;
  var
     h,m,s,s1: word;
  begin
     GetTime(h,m,s,s1);
     lget_ms  := longint(s1) * longint(10) +      {seconds/100}
                 longint(s)  * longint(1000) +    {seconds}
                 longint(m)  * longint(60000) +   {minutes}
                 longint(h)  * longint(3600000);  {hours}
  end;


procedure update_line;

  function go_ahead : boolean;
  var now : longint;
  begin
    now := lget_ms;
    go_ahead := false;
    if now < last_change then   {midnight rollover}
      go_ahead := true else
    if b2 = 1 then
        go_ahead := now > (last_change + 5000)
      else
        go_ahead := now > (last_change + 1000);
  end;

var center : byte;
begin
  if not go_ahead then exit;
  inc(b2);
  if b2 > 6 then
    begin
      inc(b1);
      if b1 > 4 then b1 := 1;
      b2 := 1;
    end;
  center := (80 - length(bottom[b1])) div 2;
  fastwrite(center,24,colors[b2],bottom[b1]);
  last_change := lget_ms;
end;

procedure draw_some (current : word);
var x, start, finish : word;
    y : byte;
    s : long_str;

    function tab(var s : long_str; len : byte) : long_str;
    begin
      while length(s) < len do
      begin
        s[0] := succ(s[0]);
        s[ byte(s[0]) ] := #32;
      end;
      tab := s;
    end;

    procedure show_bar;
    var t,x : integer;
        s : string;
    begin
      x := current + 20;
      if x > maxlines then x := maxlines;
      t := round(x/maxlines * 100);
      str(t,s);
      s := s + '%';
      fastwrite(50,1,10,tab(s,4));
      t := round(maxlines/x * 100);
      t := round(25/t * 100);
      for x := 1 to t do fastwrite(54 + x,1,1,'Û');
      for x := (t+1) to 25 do fastwrite(54 + x,1,31,'±');
    end;

begin
  start    := current;
  finish   := start + 19;
  y        := 3;
  ln       := firstln;
  for x := 1 to (start - 1) do
    ln := ln^.next;
  for x := start to finish do
  begin
    fillchar(s,sizeof(s),#0);
    if x <= maxlines then
      begin
        s  := ln^.data;
        ln := ln^.next;
      end;
    fastwrite(1,y,15,tab(s,79));
    inc(y);
  end;
  show_bar;
end;

function keypressed:boolean;
var r:registers;
begin
  r.ah:=1;
  intr ($16,r);
  keypressed:=(r.flags and 64)=0
end;

function bioskey : char;
var r : registers;
begin
  r.ah := 0;
  intr ($16,r);
  if r.al = 0
    then bioskey := chr(r.ah+128)
    else bioskey := chr(r.al)
end;

procedure do_keys;
var k : char;
    x : integer;

    procedure scroll_lines(total:word; up:boolean);
    var i : byte;
    begin
      if up then
        while (total < x) do
          begin
            dec(x);
            draw_some(x);
          end else
        while (total > x) do
          begin
            inc(x);
            draw_some(x);
          end;
    end;

begin
  k := #0;
  x := 1;
  draw_some(x);
  repeat
    k := #0;
    update_line;
    if keypressed then k := bioskey;
    if maxlines > 20 then
    case k of
      #200 : if x > 2 then scroll_lines(x - 2,true) else
             if x = 2 then scroll_lines(x - 1,true);

      #208 : if x < (maxlines - 21) then scroll_lines(x + 2,false) else
             if x < (maxlines - 20) then scroll_lines(x + 1,false);

      #209 : if (x+40) > maxlines then scroll_lines(maxlines-20,false) else
             scroll_lines(x + 20,false);

      #201 : if x > 20 then scroll_lines(x - 20,true) else
             if x > 1 then scroll_lines(1,true);

      #199 : if x > 1 then
               begin
                 x := 1;
                 draw_some(X);
               end;

      #207 : if x < maxlines then
               begin
                 x := maxlines - 20;
                 draw_some(x);
               end;
    end;
  until k = #27;
end;

procedure load_file;
var f : text;
    s : string;
    x : byte;
    overflow : boolean;
    max : word;
begin
  assign(f,readfile);
  reset(f);
  if ioresult <> 0 then
    begin
      close(f);
      writeln('File not found.');
      halt(2);
    end;
  new(ln);
  ln^.data := '';
  firstln  := ln;
  lastln   := ln;
  overflow := false;
  max      := memavail div 80;
  if max < 0 then max := 2730;
  while not (eof(f) or overflow) do
    begin
      readln(f,s);
      if length(s) > linelength then
        begin
          fastwrite(1,3,15,'Error: Line(s) to long.');
          s[0] := #79;
        end;
      ln^.data := s;
      lastln   := ln;
      new(ln);
      ln^.data := '';
      ln^.last := lastln;
      lastln^.next := ln;
      inc(maxlines);
      if maxlines > max then
        begin
          fastwrite(1,3,12,'File is to large!');
          overflow := true;
        end;
    end;
  close(f);
end;

procedure draw_line(line : byte);
var x : byte;
begin
  for x := 1 to 79
    do fastwrite(x,line,9,#196);
end;

procedure clear_screen;
var x : word;
begin
  for x := 0 to 3999 do mem[$B800:x] := 0;
end;

procedure setup_screen;
begin
  clear_screen;
  fastwrite(1,1,15,'"How to Masterbate" by ');
  fastwrite(24,1,10,'Nocturnus');
  draw_line(2);
  draw_line(23);
end;

begin
  b1 := 1;
  b2 := 1;
  if paramcount > 0 then readfile := paramstr(1)
    else halt(2);
  setup_screen;
  load_file;
  last_change := lget_ms;
  cursor_off;
  do_keys;
  cursor_on;
  clear_screen;
  fastwrite(1,25,15,'(c) Ruthless Enterprises 1993-94');
end.
