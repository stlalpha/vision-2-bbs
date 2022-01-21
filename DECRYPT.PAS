{$M 10024,0,0}

program decrypt;

uses dos, myio, crc32, crt;

var regfile   : file of byte;
    sysopname : string;
    boardname : string;
    savefile  : string;
    crc,
    namecrc,
    bbscrc    : longint;
    usedbytes : array[0..$0400] of boolean;

const title = 'ViSiON/2 Registration Utility v1.2á';

procedure decrypt_file;
var where : word;
    sysop, bbs : string;
    k : byte;
    x : byte;
    c : char;
begin
  savefile := 'REGDATA.KEY';
  textattr := 14;
  writeln('Key file to check.');
  infielde(savefile,12);
  writeln;
  writeln('SysOp Name.');
  sysopname := '';
  infielde(sysopname,30);
  writeln;
  writeln('BBS Name.');
  boardname := '';
  infielde(boardname,50);
  writeln;
  fillchar(usedbytes,sizeof(usedbytes),0);
  namecrc := 0;
  bbscrc  := 0;
  crcstr(sysopname[1],namecrc,integer(sysopname[0]));
  crcstr(boardname[1],bbscrc,integer(boardname[0]));
  writeln(namecrc);
  writeln(bbscrc);
  assign(regfile,savefile);
  reset(regfile);
  if ioresult <> 0 then
    begin
      writeln(savefile + ' not found.');
      halt;
    end;
  sysop:= '';
  bbs  := '';
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
      read(regfile,k);
      if odd(x) then
        bbs := bbs + char(k xor random($00FF)) else
        bbs := bbs + char(k xor random($0080))
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
      read(regfile,k);
      if odd(x) then
        sysop := sysop + char(k xor random($0080)) else
        sysop := sysop + char(k xor random($00FF));
    end;
  close(regfile);
  Writeln('This file is registered to:');
  writeln(sysop);
  writeln(bbs);
  writeln;
end;

begin
  decrypt_file;
end.