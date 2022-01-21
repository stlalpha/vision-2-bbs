{ Include file for the demo programs in PAvatar. }
{ These are the video and user hook routines     }

type
  ScreenWord = record
    chr  : char;
    attr : byte;
  end;
  ScreenPtr = ^Screen;
  Screen = Array[1..25,1..80] of ScreenWord;

var
  ScrPtr : ScreenPtr; { pointer to the screen for direct writes }

{$IFNDEF DPMI}
const  { constants found in TP 7.0 }
  SegB000 = $B000;
  SegB800 = $B800;
{$ENDIF}

{$IFDEF DPMI} {$DEFINE VER55} {$ENDIF}
{$IFDEF VER55}         { TP 5.5 & DPMI version }
Function DV_Get_Video_Buffer(cseg:word): word;
begin
  if DESQview_version = 0 then DV_Get_Video_Buffer := cseg
   else
    InLine(
      $b4/$fe/    {  MOV    AH,0FEH          DV's get video buffer function }
      $cd/$10/    {  INT    10H              Returns ES:DI of alt buffer }
      $8c/$c0);   {  MOV    AX,ES            Return video buffer }
end; { DV_Get_Video_Buffer }
{$ELSE}
Function DV_Get_Video_Buffer(cseg:word): word; assembler;
asm
  MOV    ES,cseg            { Put current segment into ES }
  CALL   DESQview_version   { Returns AX=0 if not in DV }
  TEST   AX,AX              { In DV? }
  JZ     @DVGVB_X           { Jump if not }
  MOV    AH,0FEH            { DV's get video buffer function }
  INT    10H                { Returns ES:DI of alt buffer }
  MOV    AX,ES              { Return video buffer }
  JMP    @DVGVB_E           { Exit and return DV buffer }
@DVGVB_X:
  MOV    AX,cseg            { Load old buffer for return to caller }
@DVGVB_E:
end; { DV_Get_Video_Buffer }
{$ENDIF}
{$IFDEF DPMI} {$UNDEF VER55} {$ENDIF}

Procedure SetScrPtr;
var
  sg : word;
begin
  if LastMode = 7 then sg := SegB000  { Monochrome video buffer }
    else sg := SegB800;               { Color video buffer }
  sg := DV_Get_Video_Buffer(sg);
  ScrPtr := Ptr(sg,$0000);
end;

(* Hooks *)

{ Identical to FillChar but fills with word values }
procedure FillWord(var x; count:integer; w:word);
begin
  Inline(
  $c4/$be/x/
  $8b/$86/w/
  $8b/$8e/count/
  $fc/
  $f2/$ab);
(*  LES  DI,x              { load target address }
  MOV  AX,w              { load word to fill in }
  MOV  CX,count          { number of words to move }
  CLD                    { clear direction flag }
  REPNZ STOSW            { copy the data } *)
end;

{$IFNDEF VER55}
{ Identical to Move but moves words instead of bytes (faster) }
procedure MoveW(var Source, Dest; count:integer); assembler;
asm
  MOV  DX,DS           { Save DS }
  LES  DI,Dest         { Load destination ptr }
  LDS  SI,Source       { load source ptr }
  MOV  CX,Count        { load # of words to move }
  CLD
  CMP  SI,DI           { are they overlapping? }
  JNB  @move           { no, do foward }
  MOV  BX,CX           { yes, do backward }
  SHL  BX,1            { count to bytes }
  DEC  BX              { prep for addition }
  DEC  BX
  ADD  SI,BX           { set them to end of area to move }
  ADD  DI,BX
  STD                  { other direction }
@move:
  REP  MOVSW           { move 'em }
  MOV  DS,DX           { restore DS }
end;
{$ELSE}
procedure MoveW(var Source, Dest; count:integer);
begin
  Move(Source, Dest, count * 2); { a SLOW kludge but it will work }
end;
{$ENDIF}

procedure GetXY(var x,y:byte);
begin
  x := WhereX;
  y := WhereY;
end;

{$F+}
procedure SetXY(x,y:byte);
begin
  GotoXY(x,y);
end;

procedure WriteAT(x,y,a:byte;ch:char);
begin  { Write char ch on the screen at x,y using attribute a }
  with ScrPtr^[y,x] do begin
    attr := a;
    chr := ch;
  end;
end;

procedure FillArea(x1,y1,x2,y2,a:byte;ch:char);
var  { Fill the screen area with char ch and attribute a }
  sw : screenword;
  w : byte;
begin
  if x1 > x2 then x1 := x2;
  if y1 > y2 then y1 := y2;
  sw.chr := ch;
  sw.attr := a;
  w := succ(x2-x1);
  for y1 := y1 to y2 do
   FillWord(ScrPtr^[y1,x1],w,word(sw));
end;

procedure Scroll(dir,x1,y1,x2,y2,n,a:byte);
var  { Scroll scrn area dir (1=up,2=dn,3=lt,4=rt) n lines, fill with color a }
  t : byte;
begin
  if x1 > x2 then x1 := x2;
  if y1 > y2 then y1 := y2;
  if n = 0 then begin
    FillArea(x1,y1,x2,y2,a,' ');
    exit;
  end;
  case dir of
    1 : begin { up }
          if n > succ(y2-y1) then n := succ(y2-y1);
          for t := y1+n to y2 do
           MoveW(ScrPtr^[t,x1], ScrPtr^[t-n,x1], succ(x2-x1)); { move a line }
          FillArea(x1,succ(y2-n),x2,y2,a,' ');
        end;
    2 : begin { down }
          if n > succ(y2-y1) then n := succ(y2-y1);
          for t := y2-n downto y1 do
           MoveW(ScrPtr^[t,x1], ScrPtr^[t+n,x1], succ(x2-x1)); { move a line }
          FillArea(x1,y1,x2,pred(y1+n),a,' ');
        end;
    3 : begin { left }
          if n > succ(x2-x1) then n := succ(x2-x1);
          for t := y1 to y2 do
           MoveW(ScrPtr^[t,x1+n], ScrPtr^[t,x1], succ(x2-(x1+n)));
          FillArea(succ(x2-n),y1,x2,y2,a,' ');
        end;
    4 : begin { right }
          if n > succ(x2-x1) then n := succ(x2-x1);
          for t := y1 to y2 do
           MoveW(ScrPtr^[t,x1], ScrPtr^[t,x1+n], succ(x2-(x1+n)));
          FillArea(x1,y1,pred(x1+n),y2,a,' ');
        end;
  end; { case dir }
end;

procedure GetScrChar(x,y:byte;var a:byte;var c:char);
begin  { retrieve the character and attribute on the screen at x,y }
  with ScrPtr^[y,x] do begin
    a := attr;
    c := chr;
  end;
end;

procedure HighArea(x1,y1,x2,y2,a:byte);
var  { change the attribute of the screen area to a }
  i,j,m : byte;
  c : char;
begin  { Note, this is a slow kludge }
  if x1 > x2 then x1 := x2;
  if y1 > y2 then y1 := y2;
  for i := x1 to x2 do
   for j := y1 to y2 do begin
     GetScrChar(i,j,m,c);
     WriteAT(i,j,a,c);
   end;
end;

procedure Pause(tens:word);
begin  { delay for tens 10ths of a second, abort delay if a key is pressed }
  for tens := tens downto 1 do begin
     DelayTicks(2); { not wonderful accuracy but it works }
     if KeyPressed then tens := 1; { abort the pause }
  end;
end;

Procedure ShapeCursor(typ:byte);

 procedure SetCursor(shape:word);
 begin
   Inline($b4/$01/        { MOV  AH, 01    }
          $8b/$8e/shape/  { MOV  CX, shape }
          $cd/$10);       { INT  10h       }
 end;

begin
  case typ of
    NormCursor   : SetCursor(Def_Cursor);
    BigCursor    : if lo(Def_Cursor) > 7 then SetCursor($000e) { Mono / EGA }
                    else SetCursor($0007); { CGA, yuck! }
    HiddenCursor : SetCursor($0100);
  end;
end;

{$F-}

(* End Hook Definitions *)

procedure SetHooks;
begin
{ Query_Hook := <defualt null hook for this application> }
  Pauseh := Pause;
  HighAreah := HighArea;
  GetATh := GetScrChar;
  FillAreah := FillArea;
  Scrollh := Scroll;
  GotoXYh := SetXY;
  WriteATh := WriteAT;
{ FlushInputh := <defualt null hook is fine for the demo> }
  Cursorh := ShapeCursor;
end;

