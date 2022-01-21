Program OffModem;

Uses Fossil;

Var K : Char;
Begin
  If Not Install_Fossil(2)
  Then Begin
    Writeln('Unable to detect FOSSIL Driver!');
    Halt(0);
  End;
  Set_Fossil(2,19200,8,'N',1);
  Fossil_DTR(2,True);
  SendChar('A');
  SendChar('T');
  SendChar('H');
  SendChar('0');
  SendChar(#13);
  While Fossil_Chars Do Begin
    K := GetChar;
    Write(K);
  End;
  Writeln;
  Fossil_DTR(2,False);
  Close_Fossil(2);
  Writeln('Modem has been SHUTDOWN!');
End.
