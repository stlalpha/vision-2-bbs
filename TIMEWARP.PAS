program timewarp;

uses general,types,dos;



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
   datestr:=strr(dt.month)+'/'+strr(dt.day)+'/'+strr(dt.year)S
end;

begin
  writeln('so like the dates are uhh...'+datestr(now));

end.