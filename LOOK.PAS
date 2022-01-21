Program lookatchars;

Uses DOS;

VAR i,rec:Byte;

BEGIN
  rec:=1;
  FOR i:=1 to 255 DO
  BEGIN
    Writeln(i,' = ',chr(i));
    inc(rec);
    IF rec>24 then
    Begin
      Readln;
      rec:=0;
    END;
  END;
END.


