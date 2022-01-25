{$M 2048,0,0 }
{$N-,S-}

Uses Dos;

{$F+}
Procedure Drip(Flags,CS,IP,AX,BX,CX,DX,SI,DI,DS,ES,BP : Word);
Interrupt;
Var A : Word;
    Scroll : Byte Absolute $0040:$0017;
Begin
  If Scroll And $10 = 0
    Then Exit;
  If Port[$60] >= $80 then
    For A := 1 To 2000 Do
      Mem[$B800:A * 2 - 1] := Random(15) + 1;
End;
{$F-}

Procedure Show(Msg:String);
Var Regs : Registers;
Begin
  Msg := Msg + #13 + #10 + '$';
  Regs.Ah := 9;
  Regs.Ds := Seg(Msg);
  Regs.Dx := Ofs(Msg[1]);
  Intr($21,Regs);
End;

Begin
  Show(#13#10'ACiDDOS By: Crimson Blade'+
      +#13#10+'(c) Ruthless Enterprises 1993'+
      +#13#10+'Scroll Lock Toggles ACiDDOS');
  SetIntVec($1C,@Drip);
  Keep(0);
End.
