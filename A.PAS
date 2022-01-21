Procedure Alphabetize(VAR U:UseArray; N:Integer);
  Var
    I, J, Bottom, Top, Middle : Integer;
    Temp : Use;

  Begin
    For i := 2 to N Do
    Begin
      Temp := U[i];
      Bottom := 1;
      Top := i - 1;
      While Bottom <= Top Do
      Begin
        Middle := (Bottom + Top) Div 2;
        If Temp.Handle < U[Middle].Handle
          Then Top := Middle - 1
          Else Bottom := Middle + 1;
      End;
      For j := i - 1 DownTo Bottom
        Do U[j + 1] := U[j];
      U[Bottom] := Temp;
    End
  End;