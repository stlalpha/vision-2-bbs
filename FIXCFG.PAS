Program LameConvert;

Type Ttype = Array[1..2] Of Byte;

Var F : File Of Byte;
    B : Byte;
    Baud : Word;
    TT : TType Absolute Baud;

Begin
  Assign(F,'CONFIG.BBS');
  {$I-} Reset(F); {$I+}
  If IoResult <> 0
    Then Begin
      Writeln('Error opening CONFIG.BBS!');
      Exit;
    End;
  B := 1;
  Baud := 19200;
  Seek(F,FileSize(F));
  While FileSize(F) < 3411      { Current Config Size }
    Do Write(F,B);
  While FileSize(F) < 3427
    Do Begin
      Write(F,TT[1]);
      Write(F,TT[2]);
    End;
  Writeln(#13#10'Yer config is all nice and spooey now..');
  Assign(F,'FIXCFG.EXE');
  Erase(F);
End.