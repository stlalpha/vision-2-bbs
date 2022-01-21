{$R-,S-,I-,D-,F-,V-,B-,N-,L+ }

Unit MainR1;

Interface

Uses Crt,MNeT,Gentypes,configrt,Modem,textret,gensubs,subs1,userret,statret;

function validfname (name:lstr):boolean;
function searchboard (name:sstr):integer;
function numfeedback:integer;
procedure trimmessage (var m:message);
Procedure SendModemStr (ss:anystr; endifcarrier:boolean);

implementation

Procedure SendModemStr (ss:anystr; endifcarrier:boolean);
Var Cnt,Ptr : Integer;
    K : Char;
label exit;
Begin
  ptr:=0;
  while ptr<length(ss) do
    begin
      if { keyhit or } (carrier=endifcarrier) then goto exit;
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
      delay (25);
      while numchars>0 do write (usr,getchar)
    end;
  cnt:=0;
  repeat
    while numchars>0 do begin
      cnt:=0;
      write (usr,getchar)
    end;
    cnt:=cnt+1
  until (cnt=1000) or keyhit or (carrier=endifcarrier);
  exit:
  break:=keyhit
End;

function validfname (name:lstr):boolean;
const invalid:set of char=[#0..#31,'"',']','[',':','\','>','<','/','?','*',
  '|','+','=',';', ',' ,#127..#255];
var p,cnt:integer;
    k:char;
    dotfound:boolean;
begin
  validfname:=false;
  dotfound:=false;
  if (length(name)>12) or (length(name)<1) then exit;
  for p:=1 to length(name) do begin
    k:=upcase(name[p]);
    if k in invalid then exit;
    if k='.' then begin
      if dotfound then exit;
      dotfound:=true;
      if (p<length(name)-3) or (p=1) then exit
    end
  end;
  validfname:=not devicename(name)
end;

function searchboard (name:sstr):integer;
var bi:sstr;
    cnt:integer;
begin
  seek (bifile,0);
  for cnt:=0 to filesize(bifile)-1 do begin
    nread (bifile,bi);
    if match(bi,name) then begin
      searchboard:=cnt;
      exit
    end
  end;
  searchboard:=-1
end;

function numfeedback:integer;
var ffile:file of mailrec;
begin
  assign (ffile,Cfg.DATADIR+'FEEDBACK');
  reset (ffile);
  if ioresult<>0 then begin
    numfeedback:=0;
    rewrite (ffile)
  end else numfeedback:=filesize (ffile);
  close (ffile)
end;

procedure trimmessage (var m:message);
var cnt:integer;
begin
  for cnt:=1 to m.numlines do
    while m.text[cnt][length(m.text[cnt])]=' ' do
      m.text[cnt][0]:=pred(m.text[cnt][0]);
  while (m.numlines>0) and (m.text[m.numlines]='') do
    m.numlines:=m.numlines-1
end;

begin
end.
