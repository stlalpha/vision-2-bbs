Unit Little;

Interface

Procedure Fastwrite(col,row,attrib:byte; str:string);
Procedure Hi_Back_On;
Procedure Hi_Back_Off;
Procedure Cursor_On;
Procedure Cursor_Off;
Function GetKey : Char;
Procedure Color(B,F : Byte);
Procedure Box(X1,Y1,X2,Y2 : Byte);
Procedure GrowBox(X1,Y1,X2,Y2 : Integer);
Procedure Center_Write(S : String; Y : Byte);
Function Tab(S:String; Spaces:Byte) : String;
Procedure Fill_Screen(C : Char; F,B : Byte);

Implementation

Uses Dos, Crt, Video;

procedure fastwrite(col,row,attrib:byte; str:string);
var x,where : word;
begin
  for x := 1 to length(str) do
    begin
      where := ( (col + x) * 2) + (row * 160) - 164; {2;}
      mem[$B800:where+1] := attrib;
      mem[$B800:where]   := byte(str[x]);
    end;
end;

Procedure Fill_Screen(C:Char; F,B : Byte);
Var S : Screens;
Begin
  FillScreenC(S,C,F,B);
  WriteScr(S);
End;

Procedure Hi_Back_On;
Begin
  ASM
    MOV Ah,8h
    MOV Bh,0h
    MOV Bl,0h
    MOV Ax,1003h
    INT 10h
  END
End;

Procedure Hi_Back_Off;
Begin
  ASM
    MOV Ah,8h
    MOV Bh,0h
    MOV Bl,1h
    MOV Ax,1003h
    INT 10h
  END
End;

Procedure Cursor_On;
Begin
  ASM
    MOV Ah,1h
    MOV Ch,6h
    MOV Cl,7h
    INT 10h
  END
End;

Procedure Cursor_Off;
Begin
  ASM
    MOV Ah,1h
    MOV Ch,32h
    MOV Cl,0h
    INT 10h
  END;
End;

Function Getkey : Char;
Var R : Registers;
Begin
  R.Ah := 0;
  Intr ($16,R);
  If R.Al = 0
    Then GetKey := Chr(R.Ah + 128)
    Else GetKey := Chr(R.Al)
End;

Procedure Color(B,F : Byte);
Begin
  TextAttr := B * 16 + F;
End;

Procedure Box(X1,Y1,X2,Y2 : Byte);
Var S : String; X,Len : Byte;
Begin
  Len := X2 - X1 + 1;
  For X := Y1 to Y2
  Do Begin
    If X =
      Y1 Then Begin
             FillChar(S,$FE,#196);
             S[0] := Chr(Len);
             S[1] := Chr($DA);
             S[Len] := Chr($BF);
           End
    Else If X =
      Y2 Then Begin
             FillChar(S,$FE,#196);
             S[0] := Chr(Len);
             S[1] := Chr($C0);
             S[Len] := Chr($D9);
           End
    Else Begin
             FillChar(S,$FE,#32);
             S[0] := Chr(Len);
             S[1] := Chr($B3);
             S[Len] := Chr($B3);
           End;
    FastWrite(x1,x,textattr,s);
  End;
End;

Procedure GrowBox(X1,Y1,X2,Y2 : Integer);
Var I,TX1,TY1,TX2,TY2,Ratio : Integer;
Begin
  If 2*(Y2 -Y1 +1) > X2 - X1 + 1 then
    Ratio :=   2
    Else
    Ratio :=  1;
  TX2 := (X2 - X1) div 2 + X1 + 2;
  TX1 := TX2 - 3;
  TY2 := (Y2 - Y1) div 2 + Y1 + 2;
  TY1 := TY2 - 3;
  If (X2-X1) < 3 then
  Begin
    TX2 := X2;
    TX1 := X1;
  End;
  If (Y2-Y1) < 3 then
  Begin
    TY2 := Y2;
    TY1 := Y1;
  End;
  Repeat
    Box(TX1,TY1,TX2,TY2);
    If TX1 >= X1 + (1*Ratio) then TX1 := TX1 - (1*Ratio) else TX1 := X1;
    If TY1 > Y1  then TY1 := TY1 - 1;
    If TX2 + (1*Ratio) <= X2 then TX2 := TX2 + (1*Ratio) else TX2 := X2;
    If TY2 + 1 <= Y2 then TY2 := TY2 + 1;
  Until (TX1 = X1) and (TY1 = Y1) and (TX2 = X2) and (TY2 = Y2);
  Box(TX1,TY1,TX2,TY2);
End;

Procedure Center_Write(S : String; Y : Byte);
Begin
  fastwrite( (80-length(s)) div 2 + 1,y,textattr,s);
End;

Function Tab(S:String; Spaces:Byte) : String;
Var X : Byte;
Begin
  While Length(s) < Spaces Do S := S + #32;
  Tab := S;
End;

Begin
End.