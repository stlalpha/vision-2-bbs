{$M 10024,1024,1024}

unit mouse;

interface

function msmouse : boolean;
procedure reset_mouse;
procedure hide_mouse;
procedure get_mouse_status (var m2, m3, m4 : integer);
procedure put_mouse ( x, y : integer);
Procedure Get_mouse_button_pressed (Var m1, m2, m3, m4 : integer);
Procedure Get_mouse_button_released (Var m1, m2, m3, m4 : integer);
Procedure Set_mouse_X_range (Min, Max : integer);
Procedure Set_mouse_Y_range (Min, Max : integer);
Procedure Set_Graphics_Icon (Var xspot, yspot, icon_pointer : integer);
Procedure Mouse_motion (Var xcounter, ycounter : integer);

implementation

uses dos, crt;

Var
  MouseR          : registers;
  m1, m2, m3, m4  : integer;

function MsMouse : boolean;
var
  mseg, m  : integer;
Begin
  mseg := 256 * mem[$0000:0207] + mem[$0000:0206];
  m    := 256 * mem[$0000:0205] + mem[$0000:0206];
  if (mseg <> 0) and (m <> 2) then
    Msmouse := true
  else
    msmouse := false;
end;  { MsMouse }

Procedure Reset_mouse;  { resets mouse internal variables }
begin
  Mouser.ax := 0;
  intr ($33, mouser);
end;

Procedure Show_mouse;  { displays the mouse cursor on the screen }
begin
  Mouser.ax := 1;
  intr ($33, mouser);
end;

Procedure Hide_mouse;  { Hides the mouse cursor on the screen }
begin
  Mouser.ax := 2;
  intr ($33, mouser);
end;

Procedure Get_mouse_status (Var m2, m3, m4 : integer);
begin
  Mouser.ax := 3;
  intr ($33, mouser);
    m2 := mouser.bx;
    m3 := mouser.cx;
    m4 := mouser.dx;
end;

Procedure Put_mouse ( x, y : integer);
begin
    mouser.ax := 4;
    mouser.cx := x;
    mouser.dx := y;
  intr ($33, mouser);
end;

Procedure Get_mouse_button_pressed (Var m1, m2, m3, m4 : integer);
begin
    mouser.ax := 5;
    mouser.bx := m2;
  intr ($33, mouser);
    m1 := mouser.ax;
    m2 := mouser.bx;
    m3 := mouser.cx;
    m4 := mouser.dx;
end;

Procedure Get_mouse_button_released (Var m1, m2, m3, m4 : integer);
begin
    mouser.ax := 6;
    mouser.bx := m2;
  intr ($33, mouser);
    m1 := mouser.ax;
    m2 := mouser.bx;
    m3 := mouser.cx;
    m4 := mouser.dx;
end;

Procedure Set_mouse_X_range (Min, Max : integer);
begin
    mouser.ax := 7;
    mouser.cx := min;
    mouser.dx := max;
  intr ($33, mouser);
end;

Procedure Set_mouse_Y_range (Min, Max : integer);
begin
    mouser.ax := 8;
    mouser.cx := min;
    mouser.dx := max;
  intr ($33, mouser);
end;

Procedure Set_Graphics_Icon (Var xspot, yspot, icon_pointer : integer);
begin
    mouser.ax := 9;
    mouser.bx := xspot;
    mouser.cx := yspot;
    mouser.dx := icon_pointer;
  intr ($33, mouser);
end;

Procedure Set_text_cursor (cursor_type, start, stop : integer);
begin
    mouser.ax := 10;
    mouser.bx := cursor_type;
    mouser.cx := start;
    mouser.dx := stop;
  intr ($33, mouser);
end;

Procedure Mouse_motion (Var xcounter, ycounter : integer);
begin
  mouser.ax := 11;
  intr ($33, mouser);
    xcounter := mouser.cx;
    ycounter := mouser.dx;
end;

Procedure mouse_mickeys (x, y : integer);
begin
    mouser.ax := 15;
    mouser.cx := x;
    mouser.dx := y;
  intr ($33, mouser);
end;

Procedure mouse_DST (mickeys : integer);
begin
    mouser.ax := 19;
    mouser.dx := mickeys;
  intr ($33, mouser);
end;

(*

procedure main_stuff;
var k : char;
    ax,bx,cx,dx,bp,si,di,ds,es,Flags : integer;
begin
  textattr := 31;
  clrscr;
  if not msmouse then exit else
    writeln('Mouse Detected.');
  textattr := 30;
  k := #0;
  reset_mouse;
  repeat
    show_mouse;
    gotoxy(1,2);
    get_mouse_status(bx,cx,dx);
    writeln('Mouse Status -            AX: 3  BX: ',bx,'  CX: ',cx,'  DX: ',dx,'     ');
    Get_mouse_button_pressed (ax,bx,cx,dx);
    writeln('Button Pressed Status -   AX: ',ax,'  BX: ',bx,'  CX: ',cx,'  DX: ',dx,'   ');
    get_mouse_button_released (ax,bx,cx,dx);
    writeln('Button Released Status -  AX: ',ax,'  BX: ',bx,'  CX: ',cx,'  DX: ',dx,'   ');
    if keypressed
      then k := readkey;
  until k = #27;
end;

*)

begin
end.