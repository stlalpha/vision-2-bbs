Program MakeTxt;

Uses ConfigRt;

Type Lstr = String[80];

Var F:File Of Lstr;
    T:Text;
    X:Byte;
    L:Lstr;
Begin
  Writeln('þ STRINGS.DAT to STRINGS.TXT Utility'#13#10);
  Assign(F,'STRINGS.DAT');
  Reset(F);
  Assign(T,'STRINGS.TXT');
  Rewrite(T);
  While Not Eof(F) Do Begin
    Read(F,L);
    Writeln(T,L);
  End;
  Close(F);
  Close(T);
End.
