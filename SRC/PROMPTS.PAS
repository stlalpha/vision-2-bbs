unit prompts;

{$R-,S-,I-,D-,F+,V-,B-,L+}

interface

uses dos,crt,
     general,scrnunit,scrninpt,KeyTTT5;

const maxprompts=50;

type prompttype=(number,strng,yesno,command);
     promptrecptr=^promptrec;
     chars79=string[79];
     promptrec=record
       ptype:prompttype;
       r1,r2:integer;
       x,y,len,inputwid:integer;
       text:string[80];
       yesnostr:array [false..true] of string[15];
       next,prev:promptrecptr;
       case prompttype of
         command:(dataptr:pointer);
         number:(numberptr:^integer);
         strng:(strptr:^string);
         yesno:(yesnoptr:^boolean)
     end;

     promptset=record
       barcolor,datacolor,choicecolor:integer;
       first,last,current:promptrecptr
     end;

procedure beginprompts (var p:promptset);
procedure addprompt (var p:promptset; t:prompttype; var data; xx,yy:integer;
                     ptext:string);
procedure setinputwid (var p:promptset; n:integer);
procedure drawprompt (var p:promptset);
procedure drawprompts (var p:promptset);
function  useprompts (var p:promptset):integer;
procedure freeprompts (var p:promptset);
procedure beginchoices (var p:promptset);
procedure addchoice (var p:promptset; ptext:string);
function  usechoices (var p:promptset):integer;
procedure freechoices (var p:promptset);
function bioskey:char;
function bioswait:char;
function bioslook:char;

implementation
Var CC:integer;

Function Cool:chars79;
VAR S:String[215];
    S2:String[85];
    A,B:String[80];
    W:Integer;
BEGIN
  S:='ViSiON/2 - "The Revision"  Staff - Programming: Crimson Blade, '+ (*62*)
     'Menus/ANSI/Stat Screens: Spectral Illusion                     '+
     'ViSiON/2 was started as of July 1st, 1992, Rewritten from the F'+
     'orum v2.10 Source.  '; (*20*) (* S length TOTAL = 206 *)
 S2:=' Commands: [ F1 ] Edit Entry  [ CR ] Change  [ F10 ] Save and Exit'+
     ' [ESC] Abort   '; (* S2 Length 80 Chrs Long *)
  If cc<1 then cc:=1;
  IF CC<131 Then Cool:=Copy(S,cc,79) Else
  Begin
    IF CC<211 Then
    Begin
    W:=210-CC;
    A:=Copy(S,cc,W);
    B:=Copy(S2,1,79-W);
    Cool:=A+B;
    End
  ELSE
  Begin
    W:=289-CC;
    A:=Copy(S2,CC-207,W);
    B:=Copy(S,1,79-W);
    Cool:=A+B;
  End;
  End;
  inc(cc);
  IF cc>287 then cc:=1;
END;

function bioslook:char;    (* Returns 255 if not keypressed *)
var r:registers;
begin
  if keypressed then begin
    r.ah:=1;
    intr ($16,r);
    if r.al=0
      then bioslook:=chr(r.ah+128)
      else bioslook:=chr(r.al)
  end else bioslook:=#255
end;

function bioswait:char;    (* Waits for a key but doesn't take it out *)
var k:char;
begin
  repeat
    k:=bioslook
  until ord(k)<>255;
  bioswait:=k
end;

function bioskey:char;
var r:registers;
begin
  bioskey:=GetKey;
  {
  r.ah:=0;
  intr ($16,r);
  if r.al=0
    then bioskey:=chr(r.ah+128)
    else bioskey:=chr(r.al)
  }
end;

procedure beginprompts (var p:promptset);
begin
  with curwindowptr^ do begin
    p.barcolor:=barcolor;
    p.datacolor:=datacolor;
    p.choicecolor:=choicecolor
  end;
  p.first:=nil;
  p.last:=nil;
  p.current:=nil
end;

procedure addprompt (var p:promptset; t:prompttype; var data; xx,yy:integer;
                     ptext:string);
var n:integer;
    np:promptrecptr;
begin
  new (np);
  if p.first=nil
    then
      begin
        p.first:=np;
        p.last:=np;
        p.current:=np;
        np^.prev:=np;
        np^.next:=np
      end
    else
      begin
        p.first^.prev:=np;
        p.last^.next:=np;
        np^.prev:=p.last;
        np^.next:=p.first;
        p.last:=np
      end;
  with np^ do begin
    ptype:=t;
    x:=xx;
    y:=yy;
    len:=length(ptext);
    dataptr:=@data;
    text:=ptext;
    inputwid:=curwindowptr^.xsize-x-len;
    if inputwid<3 then begin
      writeln ('Not enough room for input box for prompt');
      halt (1)
    end;
    case t of
      strng:r1:=80;
      number:begin
        r1:=-maxint;
        r2:=maxint
      end;
      yesno:begin
        yesnostr[false]:='No';
        yesnostr[true]:='Yes'
      end
    end
  end
end;

procedure setinputwid (var p:promptset; n:integer);
begin
  p.last^.inputwid:=n
end;

function promptstr (var p:promptrec):string;
begin
  with p do
    case ptype of
      number:promptstr:=strr(numberptr^);
      strng:promptstr:=copy(strptr^,1,80);
      yesno:promptstr:=yesnostr[yesnoptr^];
      command:promptstr:='';
    end
end;

procedure drawaprompt (var ps:promptset; var p:promptrec);
var val:string[80];
begin
  with p do begin
    if inputwid>80 then begin
      writeln ('Invalid prompt');
      halt
    end;
    setcolor (ps.choicecolor);
    gotoxy (x,y);
    write (text);
    gotoxy (x+len,y);
    val:=copy(promptstr(p),1,inputwid);
    while length(val)<inputwid do val:=val+' ';
    setcolor (ps.datacolor);
    write (val);
  end
end;

procedure drawprompt (var p:promptset);
begin
  if p.last<>nil
    then drawaprompt (p,p.last^)
end;

procedure drawprompts (var p:promptset);
var pp,cnt,ns:promptrecptr;
begin
  pp:=p.first;
  if pp=nil then exit;
  repeat
    drawaprompt (p,pp^);
    pp:=pp^.next
  until pp=p.first
end;

function useprompts (var p:promptset):integer;
var done:boolean;
    k:char;
    cp:promptrecptr;
const inputable:set of prompttype=[strng,number];

  procedure imdone (retval:integer);
  begin
    useprompts:=retval;
    p.current:=cp;
    done:=true
  end;

  procedure getinput;
  var x:string;
  begin
    if cp^.ptype in inputable then begin
      setinputregion (cp^.x+cp^.len,cp^.x+cp^.len+cp^.inputwid,cp^.y);
      case cp^.ptype of
        strng:buflen:=cp^.r1;
        number:buflen:=6
      end;
      readln (x);
      case cp^.ptype of
        strng:cp^.strptr^:=x;
        number:cp^.numberptr^:=valu(x)
      end;
      drawaprompt (p,cp^)
    end
  end;

  procedure selected;
  var pp:promptrecptr;
      n:integer;
  begin
    pp:=p.first;
    n:=1;
    while pp<>cp do begin
      n:=n+1;
      pp:=pp^.next;
      if pp=p.first then halt(2)
    end;
    imdone (n)
  end;

  procedure normal (k:char);
  begin
    if (k>=#32) and (k<=#255) and (cp^.ptype in inputable) then begin
      getinput;
      exit
    end;
    case k of
      #27:imdone (0);
      #13:if cp^.ptype in inputable
            then
              begin
                k:=bioskey;
                setdefaultinput (promptstr(cp^));
                getinput
              end
            else selected;
      else selected
    end
  end;

  procedure extended (code:integer);
  var k:char;
  begin
    case code of
      72,75:cp:=cp^.prev;
      77,80:cp:=cp^.next;
      71:cp:=p.first;
      79:cp:=p.last;
      119,132:cp:=p.first;
      117,118:cp:=p.last;
      end;
      {else}
      begin
      selected;
      exit
    {  end}
    end;
    k:=bioskey
  end;

var i:byte;
begin
  cp:=p.current;
  if cp=nil then cp:=p.first;
  if cp=nil then begin
    useprompts:=0;
    exit
  end;
  done:=false;
  repeat
    {colorregion (cp^.x,cp^.x+cp^.len-1,cp^.y,p.barcolor);}
    colorregion (cp^.x,26,cp^.y,p.barcolor);
    setcolor(p.barcolor);
    Gotoxy(27,cp^.y); Write('>');
    While Not Keypressed DO Begin
    gotoxy(1,25);
    SetColor(30);
    For i:=1 to 100 Do Begin
      If keypressed then i:=100;
      Delay(1);
    End;
    write(cool);
    End;
    k:=bioswait;
    {colorregion (cp^.x,cp^.x+cp^.len-1,cp^.y,p.choicecolor);}
    setcolor(p.choicecolor);
    gotoxy(27,cp^.y); Write(' ');
    colorregion (cp^.x,26,cp^.y,p.choicecolor);
    if ord(k)>127 then extended(ord(k)-128) else normal(k)
  until done
end;

procedure freeprompts (var p:promptset);
var pp,n:promptrecptr;
begin
  pp:=p.first;
  if pp=nil then exit;
  repeat
    n:=pp^.next;
    dispose (pp);
    pp:=n
  until pp=p.first;
  p.first:=nil
end;

procedure beginchoices (var p:promptset);
begin
  beginprompts (p)
end;

procedure addchoice (var p:promptset; ptext:string);
var y:integer;
begin
  if p.last=nil
    then y:=1
    else y:=p.last^.y+1;
  addprompt (p,command,p,2,y,ptext)
end;

function usechoices (var p:promptset):integer;
var n:integer;
    k:char;
begin
  drawprompts (p);
  repeat
    usechoices:=useprompts (p)
  until bioskey in [#27,#13]
end;

procedure freechoices (var p:promptset);
begin
  freeprompts (p)
end;

end.

