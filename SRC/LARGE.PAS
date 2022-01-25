{$I-}
{$M 10000,0,0}

Program Large;

Type LStr = String[80];

Var F : File Of Lstr;
    L : Lstr;

Begin
  Assign(F,'STRINGS.DAT');
  Reset(F);
  If IoResult <> 0
    Then Begin
      Writeln('Error opening STRINGS.DAT');
      Close(F);
      Exit;
    End;
  While FileSize(F) <= 179
    Do Begin
      L[0] := #0;
      Seek(F,FileSize(F));
      Write(F,L);
    End;
  Writeln('All Done.');
  Close(F);
End.