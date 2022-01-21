Program Fuck;

Uses Dos, Gentypes;

Var F : File of BoardRec;
    B : BoardRec;
    X : byte;

begin
  assign(F,'BOARDDIR.2');
  reset(F);
  if ioresult <> 0 then
    begin
      writeln('error with file - halting');
      halt
    end;
  for X := 0 to FileSize(F) - 1 do
    begin
      seek(f,x);
      read(f,b);
      writeln('Fixing Base: ',b.boardname);
      b.originline := 'Theft of Services - V/2 Home - 505/555-1212';
      seek(f,x);
      write(f,b);
    end;
  close(f);
end.
