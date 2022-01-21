Program Extended;

Uses crt;

Var ch:char;
    done:boolean;

Function ascii(ch:char):char;
Begin
  Write(ch,'(',ord(ch),') ');
  ASCII:=chr(0);
END;

Begin
  Writeln('Key Test');
  done:=false;
  Repeat
    If keypressed then
    Begin
      ch:=readkey;
      If ch=chr(0)
      Then Writeln(ascii(chr(0)),ascii(readkey))
      Else Writeln(ascii(ch));
    Done:=(ch=chr(27));
    End;
  Until done;
End.