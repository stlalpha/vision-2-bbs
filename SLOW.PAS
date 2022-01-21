{$M 1024,0,0}
{$N-,S-}
Program XKeep;

Uses Dos,Crt;

Var K:Word;

Procedure Crawl(Flags,CS,IP,AX,BX,CX,DX,SI,DI,DS,ES,BP:Word);
Interrupt;
Begin
  For k:=1 to K Do
End;

Begin
  Write('Slow down how much? [0-65535]: ');
  Readln(K);
  SetIntVec($1C,@Crawl);
  Keep(0);
End.