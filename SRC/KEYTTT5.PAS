{--------------------------------------------------------------------------}
{                         TechnoJock's Turbo Toolkit                       }
{                                                                          }
{                              Version   5.02                              }
{                                                                          }
{                                                                          }
{              Copyright 1986, 1989 TechnoJock Software, Inc.              }
{                           All Rights Reserved                            }
{                          Restricted by License                           }
{--------------------------------------------------------------------------}

                     {--------------------------------}                                       
                     {       Unit:   KeyTTT5          }
                     {--------------------------------}

{Update history:     5.01a  Removed references to VER50 and added DEBUG
                            compiler directive
}

{$S-,R-,V-} 
{$IFNDEF DEBUG}
{$D-}
{$ENDIF}      

unit KeyTTT5;

(*
{$DEFINE K_FULL}
*)
Interface

uses CRT, DOS;

type
  Button = (NoB,LeftB,RightB,BothB);

{$IFNDEF VER40}
      Key_Idle_Type = procedure;
      Key_Pressed_Type = procedure(var Ch:char);
{$ENDIF}

          Key_Hooks = record
{$IFNDEF VER40}
                           Idle_Hook:    Key_Idle_Type;
                           Pressed_Hook: Key_Pressed_Type;
{$ENDIF}
                           Click       : Boolean;           {tactile keyboard click}
                      end;


var
  Moused : boolean;
  Horiz_Sensitivity : integer;
  KTTT : Key_Hooks;      {used in getkey to jump to external procedure}

{$IFDEF VER40}
  Idle_Hook   : pointer;
  Pressed_Hook: pointer;
{$ENDIF}

{$IFDEF K_FULL}
{if}
{if}           CONST
{if}           BackSp  = #8;       PgUp  = #201;      CtrlPgUp = #138;
{if}           Tab     = #9;       PgDn  = #209;      CtrlPgDn = #246;
{if}           Enter   = #13;      Endkey= #207;      CtrlEnd  = #245;
{if}           Esc     = #27;      Home  = #199;      CtrlHome = #247;
{if}           STab    = #143;     Ins   = #210;      Del      = #211;
{if}
{if}           LArr    = #203;      CtrlLArr    = #243;    CtrlPrtsc = #242;
{if}           RArr    = #205;      CtrlRArr    = #244;
{if}           UArr    = #200;
{if}           DArr    = #208;
{if}
{if}
{if}           CtrlA  = #1;          AltA  = #158;        Alt1 = #248;
{if}           CtrlB  = #2;          AltB  = #176;        Alt2 = #249;
{if}           CtrlC  = #3;          AltC  = #174;        Alt3 = #250;
{if}           CtrlD  = #4;          AltD  = #160;        Alt4 = #251;
{if}           CtrlE  = #5;          AltE  = #146;        Alt5 = #252;
{if}           CtrlF  = #6;          AltF  = #161;        Alt6 = #253;
{if}           CtrlG  = #7;          AltG  = #162;        Alt7 = #254;
{if}           CtrlH  = #8;          AltH  = #163;        Alt8 = #255;
{if}           CtrlI  = #9;          AltI  = #151;        Alt9 = #134;
{if}           CtrlJ  = #10;         AltJ  = #164;        Alt0 = #135;
{if}           CtrlK  = #11;         AltK  = #165;        Altminus  = #136;
{if}           CtrlL  = #12;         AltL  = #166;        Altequals = #137;
{if}           CtrlM  = #13;         AltM  = #178;
{if}           CtrlN  = #14;         AltN  = #177;
{if}           CtrlO  = #15;         AltO  = #152;
{if}           CtrlP  = #16;         AltP  = #153;
{if}           CtrlQ  = #17;         AltQ  = #144;
{if}           CtrlR  = #18;         AltR  = #147;
{if}           CtrlS  = #19;         AltS  = #159;
{if}           CtrlT  = #20;         AltT  = #148;
{if}           CtrlU  = #21;         AltU  = #150;
{if}           CtrlV  = #22;         AltV  = #175;
{if}           CtrlW  = #23;         AltW  = #145;
{if}           CtrlX  = #24;         AltX  = #173;
{if}           CtrlY  = #25;         AltY  = #149;
{if}           CtrlZ  = #26;         AltZ  = #172;
{if}
{if}           F1  = #187;              sF1  = #212;
{if}           F2  = #188;              sF2  = #213;
{if}           F3  = #189;              sF3  = #214;
{if}           F4  = #190;              sF4  = #215;
{if}           F5  = #191;              sF5  = #216;
{if}           F6  = #192;              sF6  = #217;
{if}           F7  = #193;              sF7  = #218;
{if}           F8  = #194;              sF8  = #219;
{if}           F9  = #195;              sF9  = #220;
{if}           F10 = #196;              sF10 = #221;
{if}           F11 = #139;              sF11 = #141;
{if}           F12 = #140;              sF12 = #142;
{if}
{if}           CtrlF1  = #222;          AltF1  = #232;
{if}           CtrlF2  = #223;          AltF2  = #233;
{if}           CtrlF3  = #224;          AltF3  = #234;
{if}           CtrlF4  = #225;          AltF4  = #235;
{if}           CtrlF5  = #226;          AltF5  = #236;
{if}           CtrlF6  = #227;          AltF6  = #237;
{if}           CtrlF7  = #228;          AltF7  = #238;
{if}           CtrlF8  = #229;          AltF8  = #239;
{if}           CtrlF9  = #230;          AltF9  = #240;
{if}           CtrlF10 = #231;          AltF10 = #241;
{if}           CtrlF11 = #154;          AltF11 = #156;
{if}           CtrlF12 = #155;          AltF12 = #157;
{if}
{if}          {now the TTT mouse keys}
{if}
{if}           MUp     = #128;
{if}           MDown   = #129;
{if}           MLeft   = #130;
{if}           MRight  = #131;
{if}           MLeftB  = #133;
{if}           MEnter  = #133;
{if}           MEsc    = #132;
{if}           MRightB = #132;
{if}
{$ENDIF}  {def K_Const}
{$IFNDEF VER40}
Procedure No_Idle_Hook;
Procedure No_Pressed_Hook(var Ch:char);
Procedure Assign_Pressed_Hook(PassedProc : Key_pressed_Type);
Procedure Assign_Idle_Hook(PassedProc : Key_Idle_Type);
{$ENDIF}
Procedure Set_Clicking(Clicking : boolean);
Procedure Default_Settings;
Function  Mouse_Installed:Boolean;
Procedure Show_Mouse_Cursor;
Procedure Hide_Mouse_Cursor;
Procedure Get_Mouse_Action(var But: button; var Hor,Ver: integer);
Procedure Move_Mouse(Hor,Ver: integer);
Procedure Confine_Mouse_Horiz(Left,Right:integer);
Procedure Confine_Mouse_Vert(Top,Bot:integer);
Procedure Set_Mouse_Cursor_Style(OrdChar: integer);
Function Mouse_Pressed(Button:integer):boolean;
Function  Alt_Pressed:Boolean;
Function  Ctrl_Pressed:Boolean;
Function  LeftShift_Pressed: Boolean;
Function  RightShift_Pressed: Boolean;
Function  Shift_Pressed: Boolean;
Function  CapsOn: Boolean;
Function  NumOn: Boolean;
Function  ScrollOn: Boolean;
Procedure Set_Caps(On : boolean);
Procedure Set_Num(On : boolean);
Procedure Set_Scroll(On : boolean);
Function  GetKey : Char;
Procedure DelayKey(Time : integer);

Implementation

var
   Key_Status_Bits : word absolute $0040:$0017;

{$IFDEF VER40}
   Procedure Call_Idle_Hook;
          Inline($FF/$1E/Idle_Hook);

   Procedure Call_Pressed_Hook(Var CH : char);
          Inline($FF/$1E/Pressed_Hook);

{$ENDIF}

{$F+}
 Procedure No_Idle_Hook;
 {empty procs}
 begin
 end; {of proc No_Idle_Hook}

 Procedure No_Pressed_Hook(var Ch:char);
 {empty procs}
 begin
 end; {of proc No_Pressed_Hook}
{$F-}

{$IFNDEF VER40}
 Procedure Assign_Pressed_Hook(PassedProc : Key_pressed_Type);
 begin
     KTTT.Pressed_Hook := PassedProc;
 end;

 Procedure Assign_Idle_Hook(PassedProc : Key_Idle_Type);
 begin
     KTTT.Idle_Hook := PassedProc;
 end;
{$ENDIF}

 Procedure Set_Clicking(Clicking : boolean);
 begin
     KTTT.Click := Clicking;
 end;


    Procedure Default_Settings;
    begin
         With KTTT do
         begin
{$IFNDEF VER40}
             Idle_Hook    := No_Idle_Hook;
             Pressed_Hook := No_Pressed_Hook;
{$ELSE}
             Idle_Hook    := Nil;
             Pressed_Hook := Nil;
{$ENDIF}
             Click := false;
         end;
   end; {of proc Default_Settings}


Function Mouse_Installed:Boolean;
var
  Reg: registers;

    Function Interrupt_loaded:boolean;
    begin
        Reg.Ax := 0;
        Intr($33,Reg);
        Interrupt_Loaded :=  Reg.Ax <> 0;
    end;

begin
    If Memw[$0000:$00CC] = 0 then
       Mouse_Installed := false          {don't call interrupt if vector is zero}
    else
       Mouse_Installed := Interrupt_loaded;
end; {Func Mouse_Installed}

Procedure Show_Mouse_Cursor;
var
  Reg: registers;
begin
    Reg.Ax := 1;
    Intr($33,Reg);
end; {Proc Show_Mouse_Cursor}

Procedure Hide_Mouse_Cursor;
var
  Reg : registers;
begin
    Reg.Ax := 2;
    Intr($33,Reg);
end; {Proc Hide_Mouse_Cursor}

Procedure Get_Mouse_Action(var But: button; var Hor,Ver: integer);
var
  Reg: registers;
begin
    with Reg do
    begin
        Ax := 3;
        Intr($33,Reg);
        Hor := Cx div 8;
        Ver := Dx div 8;
        {$B+}
        If ((Bx and $1) <> $1)  and  ((Bx and $2) <> $2) then
        begin
            But := NoB;
            exit;
        end;
        If ((Bx and $1) = $1)  and   ((Bx and $2) = $2) then
           But := BothB
        else
        begin
            If (Bx and $1) = $1 then
               But := LeftB
            else
               But := RightB;
        end;
        {$B-}
    end; {with}
end;   {Get_Mouse_Action}

Procedure Move_Mouse(Hor,Ver: integer);
var
  Reg: registers;
begin
    Reg.Ax := 4;
    Reg.Cx := pred(Hor*8);
    Reg.Dx := pred(ver*8);
    Intr($33,Reg);
end; {Proc Move_mouse}

Procedure Confine_Mouse_Horiz(Left,Right:integer);
var
 Reg: registers;
begin
    Reg.Ax := 7;
    Reg.Cx := pred(Left*8);
    Reg.Dx := pred(Right*8);
    Intr($33,Reg);
end;

Procedure Confine_Mouse_Vert(Top,Bot:integer);
var
 Reg: registers;
begin
    Reg.Ax := 8;
    Reg.Cx := pred(Top*8);
    Reg.Dx := pred(Bot*8);
    Intr($33,Reg);
end;

Procedure Set_Mouse_Cursor_Style(OrdChar: integer);
var
  Reg: registers;
begin
   Reg.Ax := 10;
   Reg.Bx := 0;        {software text cursor}
   Reg.Cx := $7700;
   Reg.Dx := $77 and OrdChar;
   Intr($33,Reg);
end;

 Function Mouse_Released(Button:integer):boolean;
 {}
 var Reg : Registers;
 begin
     Reg.Ax := 6;
     Reg.Bx := Button;
     Intr($33,Reg);
     Mouse_Released := (Reg.BX > 0);
 end; {of proc Mouse_Released}

 Function Mouse_Pressed(Button:integer):boolean;
 {}
 var Reg : Registers;
 begin
     Reg.Ax := 5;
     Reg.Bx := Button;
     Intr($33,Reg);
     Mouse_Pressed := (Reg.BX > 0);
 end; {of proc Mouse_Released}



{++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++}

 Function Alt_Pressed:Boolean;
 var
   AltW : word;
 begin
     AltW := swap(Key_Status_Bits);
     Alt_Pressed := (AltW and $0800) <> 0;
 end;

 Function Ctrl_Pressed:Boolean;
 var
   CtrlW : word;
 begin
     CtrlW := swap(Key_Status_Bits);
     Ctrl_Pressed := (CtrlW and $0400) <> 0;
 end;

 Function LeftShift_Pressed: Boolean;
 {}
 var LSW : word;
 begin
     LSW := swap(Key_Status_Bits);
     LeftShift_Pressed := (LSW and $0200) <> 0;
 end; {of func LeftShift_Pressed}

 Function RightShift_Pressed: Boolean;
 {}
 var RSW : word;
 begin
     RSW := swap(Key_Status_Bits);
     RightShift_Pressed := (RSW and $0100) <> 0;
 end; {of func RightShift_Pressed}

 Function Shift_Pressed: Boolean;
 {}
 var SW : word;
 begin
     SW := swap(Key_Status_Bits);
     Shift_Pressed := ((SW and $0200) <> 0) or ((SW and $0100) <> 0);
 end; {of func LeftShift_Pressed}

 Function CapsOn: Boolean;
 {}
 var CapsOnW : word;
 begin
     CapsOnW := swap(Key_Status_Bits);
     CapsOn := (CapsOnW and $4000) <> 0;
 end; {of func CapsOn}

 Function NumOn: Boolean;
 {}
 var NumOnW : word;
 begin
     NumOnW := swap(Key_Status_Bits);
     NumOn := (NumOnW and $2000) <> 0;
 end; {of func NumOn}

 Function ScrollOn: Boolean;
 {}
 var ScrollOnW : word;
 begin
     ScrollOnW := swap(Key_Status_Bits);
     ScrollOn := (ScrollOnW and $1000) <> 0;
 end; {of func ScrollOn}

 Procedure Set_Caps(On : boolean);
 {}
 begin
     If On then
        Key_Status_Bits := (Key_Status_Bits or $40)
     else
        Key_Status_Bits := (Key_Status_Bits and $BF);
 end; {of proc Set_Caps}

 Procedure Set_Num(On : boolean);
 {}
 begin
     If On then
        Key_Status_Bits := (Key_Status_Bits or $20)
     else
        Key_Status_Bits := (Key_Status_Bits and $DF);
 end; {of proc Set_Num}

 Procedure Set_Scroll(On : boolean);
 {}
 begin
     If On then
        Key_Status_Bits := (Key_Status_Bits or $10)
     else
        Key_Status_Bits := (Key_Status_Bits and $EF);
 end; {of proc Set_Scroll}

{+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++}

   Procedure KeyClick;
   begin
       If KTTT.Click then
       begin
           Sound(1000);
           Sound(50);
           delay(5);
           nosound;
       end;
   end; {of proc KeyClick}

Function GetKey:char;
{waits for keypress or mouse activity}

{Note that if an extended key is pressed e.g. F1, then a value of 128 is
 added to the Char value. Also if a mouse is active the trapped mouse
 activity is returned as follows:

}

Const
 H = 40;
 V = 13;
 MouseUp    =  #128;
 MouseDown  =  #129;
 MouseLeft  =  #130;
 MouseRight =  #131;
 MouseEsc   =  #132;
 MouseEnter =  #133;
var
  Action,
  Finished : boolean;
  Hor, Ver : integer;
  B : button;
  Ch : char;
begin
    Finished := false;
    Action := false;
    B := NoB;
    If Moused then Move_Mouse(H,V);     {logically put mouse in middle of screen}
    Repeat                      {keep checking Mouse for activity until keypressed}
{$IFNDEF VER40}
         KTTT.Idle_Hook;
{$ELSE}
         If Idle_Hook <> Nil then
            Call_Idle_Hook;
{$ENDIF}
         If Moused then
         begin
             Get_Mouse_Action(B,Hor,Ver);
             Case B of
             LeftB : begin
                         Ch := MouseEnter;
                         Finished := true;
                         Delay(200);
                         Repeat
                         Until Mouse_Pressed(0) = false; {absorb}
                     end;
             RightB: begin
                         Ch := MouseEsc;
                         Finished := true;
                         Delay(200);
                         Repeat
                         Until Mouse_Pressed(1) = false; {absorb}
                     end;
             end; {case}

             If (Ver - V) > 1 then
             begin
                 Ch := MouseDown;
                 Finished := true;
             end
             else
                If (V - Ver) > 1 then
                begin
                    Ch := MouseUp;
                    Finished := true;
                end
                else
                   If (Hor - H) > Horiz_Sensitivity then
                   begin
                       Ch := MouseRight;
                       Finished := true;
                   end
                   else
                      If (H - Hor) > Horiz_Sensitivity then
                      begin
                          Ch := MouseLeft;
                          Finished := true;
                      end;
         end;
         If Keypressed or finished then Action := true;
    until Action;
    While not finished do
    begin
        Finished := true;
        Ch := ReadKey;
        KeyClick;
        if Ch = #0 then
        begin
            Ch := ReadKey;
            Case ord(Ch) of    {set to TTT value}
            15,
            16..25,
            30..38,
            44..50,
            59..68,
            71..73,
            75,77,
            79..127 : Ch := chr(ord(Ch) + 128);
            128..140: Ch := chr(ord(Ch) + 6);
            else      Finished := false;
            end;  {case}
        end;
    end;
{$IFNDEF VER40}
      KTTT.Pressed_Hook(Ch);
{$ELSE}
      If Pressed_Hook <> Nil then
         Call_Pressed_Hook(Ch);
{$ENDIF}
    GetKey := Ch;
end;

Procedure DelayKey(Time : integer);
var
  I : Integer;
  ChD : char;
begin
    I := 1;
    While I < Time DIV 100 do
    begin
        Delay(100);
        I := succ(I);
        If Keypressed then
        begin
            I := MaxInt;
            ChD := GetKey;           {absorb the keypress}
        end;
    end;
end; {DelayKey}

begin   {unit initialization code}
    Moused := Mouse_Installed;
    If Moused then Horiz_Sensitivity := 1;
    Default_Settings;
end.

