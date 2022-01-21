Unit Open;

Interface

Uses Crt;

Implementation

Begin
  TextAttr := 9;
  ClrScr;
  Write('อออ[');
  TextAttr := 31;
  Write('ViSiON/2 vo.84 BETA; Initializing');
  TextAttr := 9;
  Writeln(']ออออออออออออออออออออออออออออออออออออออออ');
  GotoXy(1,23);
  TextAttr := 9;
  Write('Warning: ');
  TextAttr:=15;
  Writeln('ViSiON/2 "The Revision" is currently in production, and is not');
  Writeln('         ready for any type of release (Beta or Official), RUNNING V/2');
    Write('         WITHOUT THE AUTHOR''S CONSENT RESULTS IN DATA LOSS!');
End.
