{$I-}
{$M 10024,0,0}

Program Fig2Smc;

Var F : File of Byte;
    B : Byte;

Begin
  If ParamCount < 1 Then Begin
    Writeln;
    Writeln('Small Utility by Crimson Blade');
    Writeln('Proper Format: FIG2SMC <filename> <x>');
    Writeln('Where x can be, 0 or 1');
    Writeln;
    Halt;
  End;
  If ParamStr(2) = '1' Then B := 1
  Else B := 0;
  Assign(F,ParamStr(1));
  Reset(F);
  If IoResult <> 0 Then Begin
    Writeln('Error Opening: ',ParamStr(1));
    Halt;
  End;
  Writeln('Updating: ',ParamStr(1));
  Seek(F,2);
  Write(F,B);
  Close(F);
  Writeln('Done.');
End.