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
                     {       Unit:  FastTTT5          }
                     {--------------------------------}

{ Update History:  4/01/89 5.00a    Changed VertLine and Horizline  
                           5.01a    Added DEBUG compiler directive

}

{$S-,R-,V-}
{$IFNDEF DEBUG}
{$D-}
{$ENDIF}

unit FastTTT5;

interface

Uses DOS, CRT;

const
    MaxScreenStr = 80;
    FCol:byte = white;
    BCol:byte = black;
type
  StrScreen = string[MaxScreenStr];
var
  BaseOfScreen : Word;       {Base address of video memory}
  VSeg : word;               {Base address of active screen}
  VOfs : word; 				  {Base address of active screen}
  SnowProne : Boolean;       {Check for snow on color cards?}
  Speed : longint;           {delay factor for growbox routine}


Function  ColorScreen:boolean;
Function  Attr(F,B:byte):byte;
Procedure FastWrite(Col,Row,Attr:byte; St:StrScreen);
Procedure PlainWrite(Col,Row:byte; St:StrScreen);
Procedure ColWrite(Col,Row:byte; St:StrScreen);
Procedure FWrite(St:StrScreen);
Procedure FWriteLN(St:StrScreen);
Procedure Attrib(X1,Y1,X2,Y2,F,B:byte);
Procedure Clickwrite(Col,Row,F,B:byte; St:StrScreen);
Function  Replicate(N:byte; Character:char):StrScreen;
Procedure Box(X1,Y1,X2,Y2,F,B,boxtype:integer);
Procedure FBox(X1,Y1,X2,Y2,F,B,boxtype:integer);
Procedure GrowFBox(X1,Y1,X2,Y2,F,B,boxtype:integer);
Procedure WriteCenter(LineNO,F,B:integer; St:StrScreen);
Procedure HorizLine(X1,X2,Y,F,B,lineType:byte);
Procedure VertLine(X,Y1,Y2,F,B,lineType:byte);
Procedure ClearText(x1,y1,x2,y2,F,B:integer);
Procedure ClearLine(Y,F,B:integer);
Procedure WriteAT(X,Y,F,B:integer; St:StrScreen);
Procedure WriteBetween(X1,X2,Y,F,B:byte; St:StrScreen);
Procedure WriteVert(X,Y,F,B:integer; St:StrScreen);
Function  EGAVGASystem: boolean;
Procedure InitFastTTT;

implementation

  {$L FASTTTT5}

  {$F+}
  Procedure FastWrite(Col,Row,Attr:byte; St:StrScreen); external;
  Procedure PlainWrite(Col,Row:byte; St:StrScreen); external;
  Procedure Attribute(Col,Row,Attr:byte; Number:Word); external;
  {$F-}

  Function ColorScreen: boolean;
  {}
  begin
      ColorScreen := (BaseOfScreen = $B800);
  end; {of func ColorScreen}

  Function Attr(F,B:byte):byte;
  {converts foreground(F) and background(B) colors to combined Attribute byte}
  begin
      Attr := (B Shl 4) or F;
  end;  {Func Attr}

  Procedure ColWrite(Col,Row:byte; St:StrScreen);
  begin
      Fastwrite(Col,Row,attr(FCol,BCol),St);
  end;

  Procedure FWrite(St:StrScreen);
  var Col,Row : byte;
  begin
      Col := WhereX;
      Row := WhereY;
      Fastwrite(Col,Row,attr(FCol,BCol),St);
      GotoXY(Col+length(St),Row);
  end;

  Procedure FWriteLN(St:StrScreen);
  var Col,Row : byte;
  begin
      Col := WhereX;
      Row := WhereY;
      Fastwrite(Col,Row,attr(FCol,BCol),St);
      GotoXY(1,succ(Row));
  end;

  

  Procedure Attrib(X1,Y1,X2,Y2,F,B:byte);
  {changes color attrib at specified coords}
  var
    I,X,A : byte;
  begin
      A := Attr(F,B);
      X := Succ(X2-X1);
      For I := Y1 to Y2 do
          Attribute(X1,I,A,X);
  end; {Proc Attrib}


  Procedure Clickwrite(Col,Row,F,B:byte; St:StrScreen);
  {writes text to the screen with a click!}
  var
    I : Integer;
    L,A : byte;
  begin
      A := attr(F,B);
      L := length(St);
      For I := L downto 1 do
      begin
          Fastwrite(Col,Row,A,copy(St,I,succ(L-I)));
          sound(500);delay(20);nosound;delay(30);
      end;
  end;

  Function Replicate(N : byte; Character:char):StrScreen;
  {returns a string with Character repeated N times}
  var tempstr : StrScreen;
  begin
      If N = 0 then
         TempStr := ''
      else
      begin
         If (N > 80) then
            N := 1;
         fillchar(tempstr,N+1,Character);
         Tempstr[0] := chr(N);
      end;
      Replicate := Tempstr;
  end;

  Procedure ClearText(x1,y1,x2,y2,F,B:integer);
  var
    Y : integer;
    attrib : byte;
  begin
      If x2 > 80 then x2 := 80;
      Attrib := attr(F,B);
      For Y := y1 to y2 do
          Fastwrite(X1,Y,attrib,replicate(X2-X1+1,' '));
  end;   {cleartext}

  Procedure ClearLine(Y,F,B:integer);
  begin
      Fastwrite(1,Y,attr(F,B),replicate(80,' '));
  end;

  Procedure Box(X1,Y1,X2,Y2,F,B,boxtype:integer);
  {Draws a box on the screen}
  var
    I:integer;
    corner1,corner2,corner3,corner4,
    horizline,
    vertline : char;
    attrib : byte;
  begin
      case boxtype of
      0:begin
            corner1:=' ';
            corner2:=' ';
            corner3:=' ';
            corner4:=' ';
            horizline:=' ';
            vertline:=' ';
        end;
      1:begin
            corner1:='Ú';
            corner2:='¿';
            corner3:='À';
            corner4:='Ù';
            horizline:='Ä';
            vertline:='³';
        end;
      2:begin
            corner1:='É';
            corner2:='»';
            corner3:='È';
            corner4:='¼';
            horizline:='Í';
            vertline:='º';
        end;
      3:begin
            corner1:='Ö';
            corner2:='·';
            corner3:='Ó';
            corner4:='½';
            horizline:='Ä';
            vertline:='º';
        end;
      4:begin
            corner1:='Õ';
            corner2:='¸';
            corner3:='Ô';
            corner4:='¾';
            horizline:='Í';
            vertline:='³';
        end;
    else
       corner1:=chr(ord(Boxtype));
       corner2:=chr(ord(Boxtype));
       corner3:=chr(ord(Boxtype));
       corner4:=chr(ord(Boxtype));
       horizline:=chr(ord(Boxtype));
       vertline:=chr(ord(Boxtype));
    end;{case}
    attrib := attr(F,B);
    FastWrite(X1,Y1,attrib,corner1);
    FastWrite(X1+1,Y1,attrib,replicate(X2-X1-1,horizline));
    FastWrite(X2,Y1,attrib,corner2);
    For I := Y1+1 to Y2-1 do
    begin
        FastWrite(X1,I,attrib,vertline);
        FastWrite(X2,I,attrib,vertline);
    end;
    FastWrite(X1,Y2,attrib,corner3);
    FastWrite(X1+1,Y2,attrib,replicate(X2-X1-1,horizline));
    FastWrite(X2,Y2,attrib,corner4);
  end; {Proc Box}

  Procedure FBox(X1,Y1,X2,Y2,F,B,boxtype:integer);
  {Draws a box and clears text within Box frame}
  begin
      Box(X1,Y1,X2,Y2,F,B,boxtype);
      ClearText(succ(X1),succ(Y1),pred(X2),pred(Y2),F,B);
  end;

  Procedure GrowFBox(X1,Y1,X2,Y2,F,B,boxtype:integer);
  {Draws exploding filled box!}
  var I,TX1,TY1,TX2,TY2,Ratio : integer;
  begin
      If 2*(Y2 -Y1 +1) > X2 - X1 + 1 then
         Ratio :=   2
      else
         Ratio :=  1;
      TX2 := (X2 - X1) div 2 + X1 + 2;
      TX1 := TX2 - 3;                 {needs a box 3 by 3 minimum}
      TY2 := (Y2 - Y1) div 2 + Y1 + 2;
      TY1 := TY2 - 3;
      If (X2-X1) < 3 then
      begin
         TX2 := X2;
         TX1 := X1;
      end;
      If (Y2-Y1) < 3 then
      begin
         TY2 := Y2;
         TY1 := Y1;
      end;
      repeat
           FBox(TX1,TY1,TX2,TY2,F,B,BoxType);
           If TX1 >= X1 + (1*Ratio) then TX1 := TX1 - (1*Ratio) else TX1 := X1;
           If TY1 > Y1  then TY1 := TY1 - 1;
           If TX2 + (1*Ratio) <= X2 then TX2 := TX2 + (1*Ratio) else TX2 := X2;
           If TY2 + 1 <= Y2 then TY2 := TY2 + 1;
           For I := 1 to Speed*1000 do {nothing};
      Until (TX1 = X1) and (TY1 = Y1) and (TX2 = X2) and (TY2 = Y2);
      FBox(TX1,TY1,TX2,TY2,F,B,BoxType);
  end;

  procedure HorizLine(X1,X2,Y,F,B,lineType : byte);
  var
    I : integer;
    Horizline : char;
    attrib : byte;
  begin
      case LineType of                     {5.00a}
      0       : HorizLine := ' ';
      2,4,7,9 : Horizline := 'Í';
      1,3,6,8 : HorizLine := 'Ä';
      else HorizLine := Chr(LineType);
      end; {case}
      Attrib := attr(F,B);
      If X2 > X1 then
         FastWrite(X1,Y,attrib,replicate(X2-X1+1,Horizline))
      else
         FastWrite(X1,Y,attrib,replicate(X1-X2+1,Horizline));
  end;   {horizline}

  Procedure VertLine(X,Y1,Y2,F,B,lineType : byte);
  var
    I : integer;
    vertline : char;
    attrib : byte;
  begin
      case LineType of                {5.00a}
      0       : VertLine := ' ';
      2,4,7,9 : Vertline := 'º';
      1,3,6,8 : VertLine := '³';
      else VertLine := Chr(LineType);
      end; {case}
      Attrib := attr(F,B);
      If Y2 > Y1 then
         For I := Y1 to Y2 do Fastwrite(X,I,Attrib,Vertline)
      else
         For I := Y2 to Y1 do Fastwrite(X,I,Attrib,Vertline);
  end;   {vertline}

  Procedure WriteAT(X,Y,F,B:integer;St:StrScreen);
  begin
      Fastwrite(X,Y,attr(F,B),St);
  end;

  Procedure WriteCenter(LineNO,F,B:integer;St:StrScreen);
  begin
      Fastwrite(40 - length(St) div 2,Lineno,attr(F,B),St);
  end;

  Procedure WriteBetween(X1,X2,Y,F,B:byte;St:StrScreen);
  var X : integer;
  begin
      If length(St) >= X2 - X1 + 1 then
         WriteAT(X1,Y,F,B,St)
      else
      begin
          x := X1 + (X2 - X1 + 1 - length(St)) div 2 ;
          WriteAT(X,Y,F,B,St);
      end;
  end;

  Procedure WriteVert(X,Y,F,B:integer;ST : StrScreen);
  var
    I:integer;
    Tempstr:StrScreen;
  begin
      If length(St) > 26 - Y then delete(St,27 - Y,80);
      For I := 1 to length(St) do
      begin
          Tempstr := st[I];
          Fastwrite(X,Y-1+I,attr(F,B),St[I]);
      end;
  end;

  Function EGAVGASystem: boolean;
  {}
  var  Regs : registers;
  begin
      with Regs do
      begin
          Ax := $1C00;
          Cx := 7;
          Intr($10,Regs);
          If Al = $1C then  {VGA}
          begin
              EGAVGASystem := true;
              exit;
          end;
          Ax := $1200;
          Bl := $32;
          Intr($10,Regs);
          If Al = $12 then {MCGA}
          begin
              EGAVGASystem := true;
              exit;
          end;
          Ah := $12;
          Bl := $10;
          Cx := $FFFF;
          Intr($10,Regs);
          EGAVGASystem := (Cx <> $FFFF);  {EGA}
     end; {with}
  end; {of func NoSnowSystem}

  Function Get_Video_Mode:byte;
  {}
  var
     Regs : registers;
  begin
      with Regs do
      begin
          Ax := $0F00;
          Intr($10,Regs);
          Get_Video_Mode := Al;
      end; {with}
  end; {of proc Video_Mode}

  Procedure InitFastTTT;
  begin
      if Get_Video_Mode = 7 then
      begin
         BaseOfScreen := $B000;  {Mono}
         SnowProne := False;
      end
      else
      begin
         BaseOfScreen := $B800; {Color}
         SnowProne := not EGAVGASystem;
      end;
      VSeg := BaseOfScreen;
      Vofs := 0;
  end;

begin   {the following is always called when the unit is loaded}
    InitFastTTT;
    Speed := 200;
end.
