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
                     {       Unit:   WinTTT5          }
                     {--------------------------------}

{History:    03/05/89   5.00a  corrected Get_ScreenWord procedure
             04/01/89   5.01   added DOS errorlevel 10 on fatal
                               and corrected screen scroll
                        5.01a  added DEBUG compiler directive
}

{$S-,R-,V-}
{$IFNDEF DEBUG}
{$D-}
{$ENDIF}       

unit  WinTTT5;

interface

uses CRT,DOS,FastTTT5,KeyTTT5;

Type
 Direction = (Up, Down, Left, Right);
Const
    Shadow = 5;
Var
    Shadcolor    : byte;
    DisplayLines : byte;

Procedure MoveFromScreen(var Source,Dest;Length:Word);
Procedure MoveToScreen(var Source,Dest; Length:Word);
Procedure SizeCursor(Top,Bot:byte);
Procedure FindCursor(var X,Y,Top,Bot:byte);
Procedure PosCursor(X,Y: integer);
Procedure Fullcursor;
Procedure HalfCursor;
Procedure OnCursor;
Procedure OffCursor;
Procedure GotoXY(X,Y : byte);
Function  WhereX: byte;
Function  WhereY: byte;
Function  GetScreenChar(X,Y:byte):char;
Function  GetScreenAttr(X,Y:byte):byte;
Procedure GetScreenStr(X1,X2,Y:byte;var  St:StrScreen);
Procedure CreateScreen(Page:byte;Lines:byte);
Procedure SaveScreen(Page:byte);
Procedure RestoreScreen(Page:byte);
Procedure PartRestoreScreen(Page,X1,Y1,X2,Y2,X,Y:byte);
Procedure SlideRestoreScreen(Page:byte;Way:Direction);
Procedure PartSlideRestoreScreen(Page:byte;Way:Direction;X1,Y1,X2,Y2:byte);
Procedure DisposeScreen(Page:byte);
Procedure SetCondensedLines;
Procedure Set25Lines;
Procedure CopyScreenBlock(X1,Y1,X2,Y2,X,Y:byte);
Procedure MoveScreenBlock(X1,Y1,X2,Y2,X,Y:byte);
Procedure Scroll(Way:direction;X1,Y1,X2,Y2:byte);
Procedure PartSave(X1,Y1,X2,Y2:byte; VAR Dest);
Procedure PartRestore(X1,Y1,X2,Y2:byte; VAR Source);
Procedure Mkwin(x1,y1,x2,y2,F,B,boxtype:integer);
Procedure GrowMkwin(x1,y1,x2,y2,F,B,boxtype:integer);
Procedure Rmwin;
Procedure FillScreen(X1,Y1,X2,Y2:byte; F,B:byte; C:char);
Procedure TempMessageCh(X,Y,F,B:integer;St:strscreen;var Ch : char);
Procedure TempMessage(X,Y,F,B:integer;St:strscreen);
Procedure TempMessageBoxCh(X1,Y1,F,B,BoxType:integer;St:strscreen;var Ch : char);
Procedure TempMessageBox(X1,Y1,F,B,BoxType:integer;St:strscreen);
Procedure Activate_Visible_Screen;
Procedure Activate_Virtual_Screen(Page:byte);
Procedure Reset_StartUp_Mode;

Const
    Max_Windows = 10;          {Change this constant as necessary}
    Max_Screens = 10;          {Change this constant as necessary}
    WindowCounter : byte = 0;
    ScreenCounter : byte = 0;
    ActiveVScreen: byte = 0;

Type
    ScreenImage = record
                       CursorX : byte;
                       CursorY : byte;
                       ScanTop : byte;
                       ScanBot : byte;
                       SavedLines:byte;
                       ScreenPtr: pointer;
                  end;
    ScreenPtr = ^ScreenImage;
    WindowImage = record
                       ScreenPtr: Pointer;             {pointer to screen data}
                       Coord    : array[1..4] of byte; {window coords}
                       CursorX  : byte;                {cursor location}
                       CursorY  : byte;
                       ScanTop  : byte;                {cursor shape}
                       ScanBot  : byte;
                  end;
    WindowPtr = ^WindowImage;

Var
    Screen : array[1..Max_Screens] of ScreenPtr;
    Win    : array[1..Max_Windows] of WindowPtr;
    W_error: integer;     {Global error to report winTTT errors}
    W_fatal: boolean;

IMPLEMENTATION

CONST
    MonoAdr =$b000;
VAR
    StartTop,      {used to record initial screen state when program is run}
    StartBot   : Byte;
    StartMode  : word;

{$L WINTTT5}

{$F+}
  Procedure MoveFromScreen(var Source,Dest;Length:Word); external;
  Procedure MoveToScreen(var Source,Dest; Length:Word); external;
{$F-}

Procedure WinTTT_Error(No : byte);
{Updates W_error and optionally displays error message then halts program}
var Msg : String;
begin
    W_error := No;
    If W_fatal = true then
    begin
        Case No of
        1 :  Msg := 'Max screens exceeded';
        2 :  Msg := 'Max Windows Exceeded';
        3 :  Msg := 'Insufficient memory to create screen';
        4 :  Msg := 'Screen not saved cannot activate.';
        5 :  Msg := 'Screen has not been created - cannot activate';
        6 :  Msg := 'Screen has not been created - cannot dispose';
        7 :  Msg := 'Screen has not been created - cannot restore';
        8 :  Msg := 'Screen does not exist cannot clear';
        9 :  Msg := 'Insufficient memory for Screen Copy/Move';
        10:  Msg := 'Visible screen must be active for Window operations';
        11:  Msg := 'Visible screen must be active for Message operations';
        12:; {reserved for non-fatal error settings condensed mode}
        13:  Msg := 'Can only save 25 screen lines - check CONST SavedLines';
        else Msg := '?) -- Utterly confused';
        end; {Case}
        Msg := 'Fatal Error (WinTTT -- '+Msg;
        Writeln(Msg);
        Delay(5000);    {display long enough to read if child process}
        Halt(11);       {returns DOS ERRORLEVEL 11}
    end;
end;

{+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++}
{                                                                     }
{     V I S I B L E    a n d    V I R T U A L  P R O C E D U R E S    }
{                                                                     }
{+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++}
Procedure PartSave (X1,Y1,X2,Y2:byte; VAR Dest);
{transfers data from active virtual screen to Dest}
var
   I,width : byte;
   ScreenAdr: integer;
begin
    width := succ(X2- X1);
    For I :=  Y1 to Y2 do
    begin
     ScreenAdr := Vofs + Pred(I)*160 + Pred(X1)*2;
     MoveFromScreen(Mem[Vseg:ScreenAdr],
                    Mem[seg(Dest):ofs(dest)+(I-Y1)*width*2],
                    width);
    end;
end;

Procedure PartRestore (X1,Y1,X2,Y2:byte; VAR Source);
{restores data from Source and transfers to active virtual screen}
var
   I,width : byte;
   ScreenAdr: integer;
begin
    width := succ(X2- X1);
    For I :=  Y1 to Y2 do
    begin
     ScreenAdr := Vofs + Pred(I)*160 + Pred(X1)*2;
     MoveToScreen(Mem[Seg(Source):ofs(Source)+(I-Y1)*width*2],
                  Mem[Vseg:ScreenAdr],
                  width);
    end;
end;

Procedure FillScreen(X1,Y1,X2,Y2:byte; F,B:byte; C:char);
var
   I : integer;
   S : string;
begin
    W_error := 0;
    Attrib(X1,Y1,X2,Y2,F,B);
    S := Replicate(Succ(X2-x1),C);
    For I := Y1 to Y2 do
        PlainWrite(X1,I,S);
end;

Procedure GetScreenWord(X,Y:byte;var Attr:byte; var Ch : char);
{updates vars Attr and Ch with attribute and character bytes in screen
 location (X,Y) of the active screen}
Type
    ScreenWordRec = record
                         Ch   : char;   {5.00a}
                         Attr : byte;
                    end;
var
   ScreenAdr: integer;
   SW : ScreenWordRec;
begin
    ScreenAdr := Vofs + Pred(Y)*160 + Pred(X)*2;
    MoveFromScreen(Mem[Vseg:ScreenAdr],mem[seg(SW):ofs(SW)],1);
    Attr := SW.Attr;
    Ch   := SW.Ch;
end;

Function GetScreenChar(X,Y:byte):char;
var
   A : byte;
   C : char;
begin
    GetScreenWord(X,Y,A,C);
    GetScreenChar := C;
end;

Function GetScreenAttr(X,Y:byte):byte;
var
   A : byte;
   C : char;
begin
    GetScreenWord(X,Y,A,C);
    GetScreenAttr := A;
end;

Procedure GetScreenStr(X1,X2,Y:byte;var  St:StrScreen);
var
   I : integer;
begin
    St := '';
    For I := X1 to X2 do
        St := St + GetScreenChar(I,Y);
end;

{++++++++++++++++++++++++++++++++++++++++++++++}
{                                              }
{         C U R S O R    R O U T I N E S       }
{                                              }
{++++++++++++++++++++++++++++++++++++++++++++++}

Procedure GotoXY(X,Y : byte);
{intercepts normal Turbo GotoXY procedure, in case a virtual screen
 is active.
}
begin
    If VSeg = BaseOfScreen then
       CRT.GotoXY(X,Y)
    else
       with Screen[ActiveVScreen]^ do
       begin
           CursorX := X;
           CursorY := Y;
       end; {with}
end;  {proc GotoXY}

Function WhereX: byte;
{intercepts normal Turbo WhereX procedure, in case a virtual screen
 is active.
}
begin
    If VSeg = BaseOfScreen then
       WhereX := CRT.WhereX
    else
       with Screen[ActiveVScreen]^ do
           WhereX := CursorX;
end; {of func WhereX}

Function WhereY: byte;
{intercepts normal Turbo WhereX procedure, in case a virtual screen
 is active.
}
begin
    If VSeg = BaseOfScreen then
       WhereY := CRT.WhereY
    else
       with Screen[ActiveVScreen]^ do
           WhereY := CursorY;
end; {of func WhereY}

Procedure FindCursor(var X,Y,Top,Bot:byte);
var
   Reg : registers;
begin
  If VSeg = BaseOfScreen then    {visible screen is active}
  begin   
      Reg.Ax := $0F00;              {get page in Bx}
      Intr($10,Reg);
      Reg.Ax := $0300;
      Intr($10,Reg);
      With Reg do
      begin
        X := lo(Dx) + 1;
        Y := hi(Dx) + 1;
        Top := Hi(Cx) and $0F;
        Bot := Lo(Cx) and $0F;
      end;
  end
  else                            {virtual screen active}
     with Screen[ActiveVScreen]^ do
     begin
         X := CursorX;
         Y := CursorY;
         Top := ScanTop;
         Bot := ScanBot;
     end;
end;

Procedure PosCursor(X,Y: integer);
var Reg : registers;
begin
    If VSeg = BaseOfScreen then    {visible screen is active}
    begin   
        Reg.Ax := $0F00;              {get page in Bx}
        Intr($10,Reg);
        with Reg do
        begin
          Ax := $0200;
          Dx := ((Y-1) shl 8) or ((X-1) and $00FF);
        end;
        Intr($10,Reg);
    end
    else                           {virtual screen active}
       with Screen[ActiveVScreen]^ do
       begin
           CursorX := X;
           CursorY := Y;
       end;
end;

Procedure SizeCursor(Top,Bot:byte);
var Reg : registers;
begin
    If VSeg = BaseOfScreen then    {visible screen is active}
       with Reg do
       begin
         ax := 1 shl 8;
         cx := Top shl 8 + Bot;
         INTR($10,Reg);
       end
    else                           {virtual screen active}
       with Screen[ActiveVScreen]^ do
       begin
           ScanTop := Top;
           ScanBot := Bot;
       end;
end;

Procedure HalfCursor;
begin
    If BaseOfScreen = MonoAdr then    
       SizeCursor(8,13)    
    else
       SizeCursor(4,7);    
end; {Proc HalfCursor}

Procedure Fullcursor;
begin
    If BaseOfScreen = MonoAdr then
       SizeCursor(0,13)
    else
       SizeCursor(0,7);
end;

Procedure OnCursor;
begin
    If BaseOfScreen = MonoAdr then
       SizeCursor(12,13)
    else
       SizeCursor(6,7);
end;

Procedure OffCursor;
begin
    Sizecursor(14,0);
end;

{++++++++++++++++++++++++++++++++++++++++++++++++++++}
{                                                    }
{   S C R E E N   S A V I N G  R O U T I N E S       }
{                                                    }
{++++++++++++++++++++++++++++++++++++++++++++++++++++}

Procedure DisposeScreen(Page:byte);
{Free memory and set pointer to nil}
begin
    If Screen[Page] = nil then
    begin
       WinTTT_Error(6);
       exit;
    end
    else
       W_error := 0;
    FreeMem(Screen[Page]^.ScreenPtr,Screen[Page]^.SavedLines*160);
    Freemem(Screen[Page],SizeOf(Screen[Page]^));
    Screen[page] := nil;
    If ActiveVscreen = Page then
       Activate_Visible_Screen;
    dec(ScreenCounter);
end;

Procedure SaveScreen(Page:byte);
{Save screen display and cursor details}
begin
    If (Page > Max_Screens) then
    begin
      WinTTT_Error(1);
      exit;
    end;
    If ((Screen[Page] <> nil) and (DisplayLines <> Screen[Page]^.SavedLines)) then
        DisposeScreen(Page);
    If Screen[Page] = nil then            {need to allocate memory}
    begin
        If MaxAvail < SizeOf(Screen[Page]^) then
        begin
            WinTTT_Error(3);
            exit;
        end;
        GetMem(Screen[Page],SizeOf(Screen[Page]^));
        If MaxAvail < DisplayLines*160 then     {do check in two parts 'cos Maxavail is not same as MemAvail}
        begin
            WinTTT_Error(3);
            Freemem(Screen[Page],SizeOf(Screen[Page]^));
            Screen[Page] := nil;
            exit;
        end;
        GetMem(Screen[Page]^.ScreenPtr,DisplayLines*160);
        Inc(ScreenCounter);
    end;
    With Screen[Page]^ do
    begin
       FindCursor(CursorX,CursorY,ScanTop,ScanBot);     {Save Cursor posn. and shape}
       SavedLines := DisplayLines;
       MoveFromScreen(Mem[BaseOfScreen:0],Screen[Page]^.ScreenPtr^,DisplayLines*80);
    end;
    W_error := 0;
end;

Procedure RestoreScreen(Page:byte);
{Display a screen that was previously saved}
begin
    If Screen[Page] = nil then
    begin
       WinTTT_Error(7);
       exit;
    end
    else
       W_error := 0;
    With Screen[Page]^ do
    begin
        MoveToScreen(ScreenPtr^,mem[BaseOfScreen:0], 80*SavedLines);
        PosCursor(CursorX,CursorY);
        SizeCursor(ScanTop,ScanBot);
    end;
end;  {Proc RestoreScreen}


Procedure PartRestoreScreen(Page,X1,Y1,X2,Y2,X,Y:byte);
{Move from heap to screen, part of saved screen}
Var
   I,width     : byte;
   ScreenAdr,
   PageAdr     : integer;
begin
    If Screen[Page] = nil then
    begin
       WinTTT_Error(7);
       exit;
    end
    else
       W_error := 0;
    Width := succ(X2- X1);
    For I :=  Y1 to Y2 do
    begin
        ScreenAdr := Pred(Y+I-Y1) * 160 + Pred(X) * 2;
        PageAdr   := Pred(I) * 160 + Pred(X1) * 2;
        MoveToScreen(Mem[Seg(Screen[Page]^.ScreenPtr^):ofs(Screen[Page]^.ScreenPtr^)+PageAdr],
                     Mem[BaseOfScreen:ScreenAdr],
                     width);
    end;
end;

Procedure SlideRestoreScreen(Page:byte;Way:Direction);
{Display a screen that was previously saved, with fancy slide}
Var I : byte;
begin
    If Screen[Page] = nil then
    begin
       WinTTT_Error(7);
       exit;
    end
    else
       W_error := 0;
    Case Way of
    Up    : begin
                For I := DisplayLines downto 1 do
                begin
                    PartRestoreScreen(Page,
                                      1,1,80,succ(DisplayLines -I),
                                      1,I);
                    Delay(50);
                end;
            end;
    Down  : begin
                For I := 1 to DisplayLines do
                begin
                    PartRestoreScreen(Page,
                                      1,succ(DisplayLines -I),80,DisplayLines,
                                      1,1);
                    Delay(25);  {savor the moment!}
                end;
            end;
    Left  : begin
                For I := 1 to 80 do
                begin
                    PartRestoreScreen(Page,
                                      1,1,I,DisplayLines,
                                      succ(80-I),1);
                end;
            end;
    Right : begin
                For I := 80 downto 1 do
                begin
                    PartRestoreScreen(Page,
                                      I,1,80,DisplayLines,
                                      1,1);
                end;
            end;
    end; {case}
    PosCursor(Screen[Page]^.CursorX,Screen[Page]^.CursorY);
    SizeCursor(Screen[Page]^.ScanTop,Screen[Page]^.ScanBot);
end;   {Proc SlideRestoreScreen}


Procedure PartSlideRestoreScreen(Page:byte;Way:Direction;X1,Y1,X2,Y2:byte);
{Display a screen that was previously saved, with fancy slide}
Var I : byte;
begin
    If Screen[Page] = nil then
    begin
       WinTTT_Error(7);
       exit;
    end
    else
       W_error := 0;
    Case Way of
    Up    : begin
                For I := Y2 downto Y1 do
                begin
                    PartRestoreScreen(Page,
                                      X1,Y1,X2,Y1+Y2-I,
                                      X1,I);
                    Delay(50);
                end;
            end;
    Down  : begin
                For I := Y1 to Y2 do
                begin
                    PartRestoreScreen(Page,
                                      X1,Y1+Y2 -I,X2,Y2,
                                      X1,Y1);
                    Delay(50);  {savor the moment!}
                end;
            end;
    Left  : begin
                For I := X1 to X2 do
                begin
                    PartRestoreScreen(Page,
                                      X1,Y1,I,Y2,
                                      X1+X2-I,Y1);
                end;
            end;
    Right : begin
                For I := X2 downto X1 do
                begin
                    PartRestoreScreen(Page,
                                      I,Y1,X2,Y2,
                                      X1,Y1);
                end;
            end;
    end; {case}
end;   {Proc PartSlideRestoreScreen}


{++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++}
{                                                                              }
{     V I R T U A L    S C R E E N    S P E C I F I C   P R O C E D U R E S    }
{                                                                              }
{++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++}

Procedure Clear_Vscreen(page:byte);
var
   Tseg, Tofs : word;
begin
    If Screen[Page] = nil then
    begin
       WinTTT_Error(8);
       exit;
    end
    else
       W_error := 0;
    Tseg := Vseg;
    Tofs := Vofs;
    Vseg := Seg(Screen[Page]^.ScreenPtr^);
    Vofs := Ofs(Screen[Page]^.ScreenPtr^);
    ClearText(1,1,80,Screen[Page]^.SavedLines,yellow,black);
    Vseg := Tseg;
    Vofs := Tofs;
end;

Procedure CreateScreen(Page:byte;Lines:byte);
begin
    W_error := 0;
    If (Page > Max_Screens) then
    begin
       WinTTT_Error(1);
       exit;
    end;
    If ((Screen[Page] <> nil) and (Lines <> Screen[Page]^.SavedLines)) then
        DisposeScreen(Page);
    If Screen[Page] = nil then            {need to allocate memory}
    begin
        If MaxAvail < SizeOf(Screen[Page]^) then
        begin
            WinTTT_Error(3);
            exit;
        end;
        GetMem(Screen[Page],SizeOf(Screen[Page]^));
        If MaxAvail < Lines*160 then     {do check in two parts 'cos Maxavail is not same as MemAvail}
        begin
            WinTTT_Error(3);
            Freemem(Screen[Page],SizeOf(Screen[Page]^));
            Screen[Page] := nil;
            exit;
        end;
        GetMem(Screen[Page]^.ScreenPtr,Lines*160);
        Inc(ScreenCounter);
    end;
    With Screen[Page]^ do
    begin
        If BaseOfScreen = $B000 then
        begin
            ScanTop := 12;
            ScanBot := 13;
        end
        else
        begin
            ScanTop := 6;
            ScanBot := 7;
        end;
        CursorX := 1;
        CursorY := 1;
        SavedLines := Lines;
        Clear_Vscreen(Page);
    end;
end;

Procedure Activate_Visible_Screen;
begin
    VSeg := BaseOfScreen;
    VOfs := 0;
    ActiveVscreen := 0;
end;

Procedure Activate_Virtual_Screen(Page:byte);
{Page zero signifies the visible screen}
begin
    If Screen[Page] = nil then
       WinTTT_Error(4)
    else
    begin
       W_error := 0;
       If Page = 0 then
          Activate_Visible_Screen
       else
       begin
           VSeg := Seg(Screen[Page]^.ScreenPtr^);
           VOfs := Ofs(Screen[Page]^.ScreenPtr^);
           ActiveVScreen := page;
       end;
    end;
end;

{++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++}
{                                                                              }
{     V I S I B L E    S C R E E N    S P E C I F I C   P R O C E D U R E S    }
{                                                                              }
{++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++}

Procedure SetCondensedLines;
begin
    If EGAVGASystem then
    begin
        W_Error := 0;
        TextMode(Lo(LastMode)+Font8x8);
        DisplayLines := succ(Hi(WindMax));
    end
    else
        W_Error := 12;
end;  {proc SetCondensedDisplay}

Procedure Set25Lines;
begin
    TextMode(Lo(LastMode));
    DisplayLines := succ(Hi(WindMax));
end;


Procedure CopyScreenBlock(X1,Y1,X2,Y2,X,Y:byte);
{copies text and attributes from one part of screen to another}
Var
   S : word;
   SPtr : pointer;
begin
    W_error := 0;
    S := succ(Y2-Y1)*succ(X2-X1)*2;
    If Maxavail < S then
       WinTTT_Error(9)
    else
    begin
        GetMem(SPtr,S);
        PartSave(X1,Y1,X2,Y2,SPtr^);
        PartRestore(X,Y,X+X2-X1,Y+Y2-Y1,SPtr^);
        FreeMem(Sptr,S);
    end;
end; {CopyScreenBlock}

Procedure MoveScreenBlock(X1,Y1,X2,Y2,X,Y:byte);
{Moves text and attributes from one part of screen to another,
 replacing with Replace_Char}
const
  Replace_Char = ' ';
Var
   S : word;
   SPtr : pointer;
   I : Integer;
   ST : string;
begin
    W_error := 0;
    S := succ(Y2-Y1)*succ(X2-X1)*2;
    If Maxavail < S then
       WinTTT_Error(9)
    else
    begin
        GetMem(SPtr,S);
        PartSave(X1,Y1,X2,Y2,SPtr^);
        St := Replicate(succ(X2-X1),Replace_Char);
        For I := Y1 to Y2 do
            PlainWrite(X1,I,St);
        PartRestore(X,Y,X+X2-X1,Y+Y2-Y1,SPtr^);
        FreeMem(Sptr,S);
    end;
end; {Proc MoveScreenBlock}

Procedure Scroll(Way:direction;X1,Y1,X2,Y2:byte);
{used for screen scrolling, uses Copy & Plainwrite for speed}
const
  Replace_Char = ' ';
var
  I : integer;
begin
    W_error := 0;
    Case Way of
    Up   : begin
               CopyScreenBlock(X1,succ(Y1),X2,Y2,X1,Y1);
               PlainWrite(X1,Y2,replicate(succ(X2-X1),Replace_Char));
           end;
    Down : begin
               CopyScreenBlock(X1,Y1,X2,pred(Y2),X1,succ(Y1));
               PlainWrite(X1,Y1,replicate(succ(X2-X1),Replace_Char));
           end;
    Left : begin
               CopyScreenBlock(succ(X1),Y1,X2,Y2,X1,Y1);
               For I := Y1 to Y2 do
                   PlainWrite(X2,I,Replace_Char);   {5.01}
           end;
    Right: begin
               CopyScreenBlock(X1,Y1,pred(X2),Y2,succ(X1),Y1);
               For I := Y1 to Y2 do
                   PlainWrite(X1,I,Replace_Char);   {5.01}
           end;
    end; {case}
end;

procedure CreateWin(x1,y1,x2,y2,F,B,boxtype:integer);
{called by MkWin and GrowMkWin}
begin
    If WindowCounter >= Max_Windows then
    begin
       WinTTT_Error(2);
       exit;
    end;
    If MaxAvail < sizeOf(Win[WindowCounter]^) then
    begin
       WinTTT_Error(3);
       exit;
    end
    else
       W_error := 0;
    Inc(WindowCounter);
    GetMem(Win[WindowCounter],sizeof(Win[WindowCounter]^));    {allocate space}
    If (BoxType in [5..9]) and (X1 > 1) then     {is there a drop shadow}
    begin
        X1 := pred(X1);    {increase dimensions for the box}
        Y2 := succ(Y2);
    end;
    If MaxAvail < succ(Y2-Y1)*succ(X2-X1)*2 then
    begin
       WinTTT_Error(3);
       exit;
    end;
    GetMem(Win[WindowCounter]^.ScreenPtr,succ(Y2-Y1)*succ(X2-X1)*2);
    PartSave(X1,Y1,X2,Y2,Win[WindowCounter]^.ScreenPtr^);
    with Win[WindowCounter]^ do
    begin
      Coord[1] := X1;
      Coord[2] := Y1;
      Coord[3] := X2;
      Coord[4] := Y2;
      FindCursor(CursorX,CursorY,ScanTop,ScanBot);
    end;  {with}
end; {Proc CreateWin}

procedure mkwin(x1,y1,x2,y2,F,B,boxtype:integer);
{Main procedure for creating window}
var I : integer;
begin
    If ActiveVscreen <> 0 then
    begin
        W_error := 10;
        exit;
    end
    else
        W_error := 0;
    CreateWin(X1,Y1,X2,Y2,F,B,Boxtype);
    If (BoxType in [5..9]) and (X1 > 1) then
       FBox(x1,y1,x2,y2,F,B,boxtype-shadow)
    else
       FBox(x1,y1,x2,y2,F,B,boxtype);
    If (BoxType in [5..9]) and (X1 > 1) then     {is there a drop shadow}
    begin
        For I := succ(Y1) to succ(Y2) do
            WriteAt(pred(X1),I,Shadcolor,black,chr(219));
        WriteAt(X1,succ(Y2),Shadcolor,black,
                replicate(X2-succ(X1),chr(219)));
    end;
end;

procedure GrowMKwin(x1,y1,x2,y2,F,B,boxtype:integer);
{same as MKwin but window explodes}
var I : integer;
begin
    If ActiveVscreen <> 0 then
    begin
        W_error := 10;
        exit;
    end
    else
        W_error := 0;
    CreateWin(X1,Y1,X2,Y2,F,B,Boxtype);
    If (BoxType in [5..9]) and (X1 > 1) then
       GrowFBox(x1,y1,x2,y2,F,B,boxtype-shadow)
    else
       GrowFBox(x1,y1,x2,y2,F,B,boxtype);
    If (BoxType in [5..9]) and (X1 > 1) then     {is there a drop shadow}
    begin
        For I := succ(Y1) to succ(Y2) do
            WriteAt(pred(X1),I,Shadcolor,black,chr(219));
        WriteAt(X1,succ(Y2),Shadcolor,black,
                replicate(X2-succ(X1),chr(219)));
    end;
end;

Procedure RmWin;
begin
    If ActiveVscreen <> 0 then
    begin
        W_error := 10;
        exit;
    end
    else
        W_error := 0;
    If WindowCounter > 0 then
    begin
        with  Win[WindowCounter]^ do
        begin
            PartRestore(Coord[1],Coord[2],Coord[3],Coord[4],ScreenPtr^);
            PosCursor(CursorX,CursorY);
            SizeCursor(ScanTop,ScanBot);
            FreeMem(ScreenPtr,succ(Coord[4]-coord[2])*succ(coord[3]-coord[1])*2);
            FreeMem(Win[WindowCounter],sizeof(Win[WindowCounter]^));
        end; {with}
        Dec(WindowCounter);
    end;
end;

procedure TempMessageCh(X,Y,F,B:integer;St:strscreen;var Ch : char);
var
 CX,CY,CT,CB,I,locC:integer;
 SavedLine : array[1..160] of byte;
begin
    If ActiveVscreen <> 0 then
    begin
        W_error := 11;
        exit;
    end
    else
        W_error := 0;
    PartSave(X,Y,pred(X)+length(St),Y,SavedLine);
    WriteAT(X,Y,F,B,St);
    Ch := GetKey;
    PartRestore(X,Y,pred(X)+length(St),Y,SavedLine);
end;

Procedure TempMessage(X,Y,F,B:integer;St:strscreen);
var Ch : char;
begin
    TempMessageCH(X,Y,F,B,ST,Ch);
end;              

Procedure TempMessageBoxCh(X1,Y1,F,B,BoxType:integer;St:strscreen;var Ch : char);
begin
    If ActiveVscreen <> 0 then
    begin
        W_error := 11;
        exit;
    end
    else
        W_error := 0;
    MkWin(X1,Y1,succ(X1)+length(St),Y1+2,F,B,Boxtype);
    WriteAt(succ(X1),Succ(Y1),F,B,St);
    Ch := getKey;
    Rmwin;
end;

Procedure TempMessageBox(X1,Y1,F,B,BoxType:integer;St:strscreen);
var Ch : char;
begin
    TempMessageBoxCh(X1,Y1,F,B,Boxtype,St,Ch);
end;

{++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++}

Procedure InitWinTTT;
{set Pointers to nil for validity checking}
Var
  I : integer;
  X,Y : byte;
begin
    For I := 1 to Max_Screens do
        Screen[I] := nil;
    StartMode := LastMode;           { record the initial state of screen when program was executed}
    DisplayLines := succ(Hi(WindMax));
    FindCursor(X,Y,StartTop,StartBot);
end;


Procedure Reset_StartUp_Mode;
{resets monitor mode and cursor settings to the state they
 were in at program startup}
begin
    TextMode(StartMode);
    SizeCursor(StartTop,StartBot);
end; {proc StartUp_Mode}

begin
    InitWinTTT;
    W_error := 0;
    W_fatal := false;   {don't terminate program if fatal error}
    Shadcolor := darkgray;
end.
