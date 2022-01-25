Program Reverse;

Uses Crt;

Var Places_Over : Byte;  { 10th's, 100th's, 1000th's etc.. }
    WorkNum : Longint;   { Number we're working with }
    Result : Longint;    { New Result }
    X : Byte;            { For Control Var }
    Number : Byte;       { Current Number 'Mod' pulls out }
    Place : Byte;        { What 'Place' Number is in.. 10th's, etc..}

    Function Tens ( Times : Byte ) : Longint;  { Function returns 10 }
    Var X : Byte;                              { squared by 'times' }
        Finish : Longint;
    Begin
      Finish := 1;
      For X := 1 To (Times - 1)
        Do Finish := Finish * 10;
      Tens := Finish;
    End;

Begin
  ClrScr;

  Write('Enter Number To Reverse [1 - 2,147,483,647]: ');  { Read in Number }
  ReadLn(WorkNum);

  If (WorkNum < 1) or (WorkNum > MaxLongint)     { Check Range }
    Then Begin
      Writeln('Invalid Number!');
      Halt;
    End;

  Places_Over := 10;                             { Max Number Range }

  While WorkNum Div Tens(Places_Over) = 0        { Determine Max amount }
    Do Dec(Places_Over);                         { of places in number }

  Inc(Places_Over);                              { Add one }
  Result := 0;                                   { Set to 0 }
  Place := Places_Over;                          { Set Places Var }

  For X := 1 to Places_Over Do Begin

   Number := WorkNum MOD 10;                      { Return Last Digit }
   Result := Result + (Number * Tens(Place - 1)); { Add to Result }
   WorkNum := WorkNum DIV 10;                     { Knock off last number }
   Dec(Place);                                    { decrement places over }

  End;

  Write('Reversed Number = ',Result);             { Display Result! }

End.