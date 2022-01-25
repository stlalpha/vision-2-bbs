{$M 10024,0,0}

program newreg;

uses dos, myio, crc32, crt, general;

var regfile   : file of byte;
    sysopname : string;
    boardname : string;
    savefile  : string;
    crc,
    namecrc,
    bbscrc    : longint;
    usedbytes : array[1..$0400] of boolean;

const title = 'ViSiON/2 Registration Utility v1.2á';

procedure update_log;
var t : text;
begin
  assign(t,'REG.LOG');
  if exist('REG.LOG') then
    reset(t) else
    rewrite(t);
  append(t);
  writeln(t,datestr(now)+': created reg for '+sysopname+', bbs: '+boardname);
  close(t);
end;

procedure get_any_params;

  procedure fix_underscore(VAR s:string);
  var x : byte;
  begin
    for x := 1 to length(s) do
      if s[x] = #95 then s[x] := #32;
  end;

begin
  fillchar(sysopname,256,0);
  fillchar(boardname,256,0);
  fillchar(usedbytes,sizeof(usedbytes),0);
  if paramcount < 1 then exit;
  sysopname := paramstr(1);
  fix_underscore(sysOpname);
  if paramcount < 2 then exit;
  boardname := paramstr(2);
  fix_underscore(boardname);
end;

procedure display_title;
begin
  textattr := 14;
  writeln(#13#10+Title+#13#10);
  textattr := 15;
end;

function itoh(i: longint): string;   {integer to hex conversion}
type two = array[1..2] of word;
var
   h:   string;
   w:   word;
   p:   two absolute i;
   x:   byte;
   total:byte;

   procedure digit(ii: word);
   begin
      inc(total);
      ii := ii and 15;
      if ii > 9 then 
         ii := ii + 7;
      h[total] := chr(ii + ord('0'));
   end;

begin
   h[0] := #8;
   total := 0;
   for x := 1 to 2 do begin
     w := p[x] and $FFFF;
     digit(w shr 12);
     digit(w shr 8);
     digit(w shr 4);
     digit(w);
   end;
   itoh := h + 'h';
end;

procedure create_file;
var x : word;
    where : word;
    k : byte;
begin
  textattr := 14;
  writeln(#10#13#10#13'Creating Registration Key.');
  assign(regfile,savefile);
  rewrite(regfile);
  randseed := bbscrc;
  for x := $0001 to $0400 do
    begin
      randseed := randseed + $d8f1 - x;
      k := random($00FF);
      write(regfile,k);
    end;
  randseed := namecrc + $f054;
  for x := 1 to length(boardname) do
    begin
      where := 0;
      while where < 1 do
        begin
          where := random($0400);
          if usedbytes[where] then where := 0;
        end;
      usedbytes[where] := true;
      seek(regfile,where);
      if odd(x) then
        k := byte(boardname[x]) xor random($00FF) else
        k := byte(boardname[x]) xor random($0080);
      write(regfile,k);
    end;
  randseed := random(randseed);
  for x := 1 to length(sysopname) do
    begin
      where := 0;
      while where < 1 do
        begin
          where := random($0400);
          if usedbytes[where] then where := 0;
        end;
      usedbytes[where] := true;
      seek(regfile,where);
      if odd(x) then
        k := byte(sysopname[x]) xor random($0080) else
        k := byte(sysopname[x]) xor random($00FF);
      write(regfile,k);
    end;
  close(regfile);
end;

procedure get_input;

   function okay(s:string; crcseed:longint) : boolean;
   var k   : char;
   begin
     writeln;
     repeat
       textattr := 9;
       write(#13#10'Is this okay? (Y)es, (N)o or e(X)it: ');
       textattr := 11;
       k := upcase(readkey);
       if k = #13 then k := 'Y';
       writeln(k);
     until k in [#13,'Y','N','X'];
     case k of
       'Y' : okay := true;
       'N' : okay := false;
       'X' : halt(1);
     end;
     textattr := 15;
     crc      := 0;
     crc_seed := crcseed;
     crcstr(s[1],crc,integer(S[0]));
     writeln('CRC Value: ',itoh(crc),' (',crc,')');
     writeln;
   end;

begin
  get_any_params;
  display_title;
  repeat
    writeln('Enter SysOp Name.');
    infielde(sysopname,30);
  until okay(sysopname,$CBCBCBCB);
  namecrc := crc;
  repeat
    writeln('Enter Board Name.');
    infielde(boardname,50);
  until okay(boardname,$F0F0F1F1);
  bbscrc := crc;
  savefile := 'REGDATA.KEY';
  writeln('Save as Filename.');
  infielde(savefile,12);
  create_file;
  update_log;
end;

begin
  get_input;
end.
