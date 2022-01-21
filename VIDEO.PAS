Unit ViDEO;

Interface

Uses Dos, Crt;

Type
  ScreenChars = Record
    Ch : Char;
    At : Byte;
  End;

  Screens = Record
    Position : Array[1..25,1..80] of ScreenChars;
    X,Y : Byte;
  End;

  ScreenType = (Mono,Color);

Var
  SType : ScreenType;
  VidSeg : Word;

Procedure ShowScreen(var source, video; length : word);
Procedure GetScreen(var video,source; length: word);
Procedure XYString(x,y : byte;s : string;fg,bg : byte);
Procedure ReadScr(var S);
Procedure WriteScr(var s);
Procedure HorStr(x,y,len : byte;fg,bg : byte;ch : char);
Procedure VerStr(x,y,len : byte;fg,bg : byte;ch : char);
Procedure Box(x1,y1,x2,y2 : byte; fg,bg : byte);
Procedure Center(y : byte;st : string;fg,bg :byte);
Procedure BoxString(y:byte;st : string;fg,bg : byte);
Procedure FillScreen(var sc : screens;s : string;x,y:byte;fg,bg : byte);
Procedure FillScreenC(Var Sc : Screens; Fill : Char; Fg,Bg : Byte);
Procedure CursorOff;
Procedure CursorSmall;
Procedure CursorBig;

Implementation

Var
  Regs : Registers;
  Vid  : Pointer;

Procedure ShowScreen(Var Source, Video; Length : Word);
Begin
  If SType = Color Then
  Inline($90/$90/$90/$90/$1E/$55/$BA/$DA/$03/$C5/$B6/ SOURCE /
         $C4/$BE/ VIDEO /$8B/$8E/ LENGTH /$FC/$AD/$89/$C5/$B4/
         $09/$EC/$D0/$D8/$82/$FB/$FA/$EC/$20/$E0/$74/$FB/$89/
         $E8/$AB/$FB/$E2/$EA/$5D/$1F)
  Else Begin
    Length := Length * 2;
    Move(Source,Video,Length);
  End
End;

Procedure GetScreen(Var Video, Source; Length : Word);
Begin
  If SType = Color Then
  Inline($1E/$55/$BA/$DA/$03/$C5/$B6/ Video /$C4/$BE/ Source /
         $8B/$8E/Length/$FC/$EC/$D0/$D8/$72/$FB/$FA/$EC/$D0/
         $D8/$73/$FB/$AD/$FB/$AB/$E2/$F0/$5D/$1F)
  Else Begin
    Length := Length * 2;
    Move(Source,Video,Length);
  End
End;

Procedure XYString(X,Y : Byte; S:String; FG,BG:Byte);
Var Sa : Array[1..255] Of Record
      Ch : Char;
      At : Byte;
    End;
    B,I : Byte;
    Offset : Word;
Begin
  If (Length(S) = 0) or (x>80) or (x<1) or (y>48) or (y<1)
    Then Exit;
  B := (Ord(bg shl 4)) or ord(fg);
  FillChar(Sa,Sizeof(sa),B);
  For i := 1 To Length(s)
    Do Sa[i].Ch := S[i];
  Offset := (((Y - 1) * 80) + (X - 1)) * 2;
  Vid := Ptr(VidSeg,Offset);
  ShowScreen(Sa,Vid^,Length(s));
End;

Procedure ReadScr(Var S);
Begin
  Vid := Ptr(VidSeg,0);
  GetScreen(Vid^,S,2000);
End;

Procedure WriteScr(Var S);
Begin
  Vid := Ptr(Vidseg,0);
  ShowScreen(S,Vid^,2000);
End;

Procedure HorStr(X,Y,Len : Byte; fg,bg : byte; ch : char);
Var I : Byte;
Begin
  For I := 1 to Len Do
  Begin
    XYString(x,y,ch,fg,bg);
    Inc(x);
  End
End;

Procedure Verstr(x,y,len,fg,bg : byte;ch : char);
Var I : Byte;
Begin
  For i := 1 To Len Do
  Begin
    XYString(x,y,ch,fg,bg);
    Inc(y);
  End
End;

Procedure Box(x1,y1,x2,y2 : byte; fg,bg : byte);
Begin
  If (x1<1) or (x2>80) or (y1<1) or (y2>25) or ((x2 -x1)<2) or ((y2-y1)<2)
    Then Exit;
  HorStr(x1,y1,1,fg,bg,#201);
  HorStr(x2,y1,1,fg,bg,#187);
  HorStr(x1,y2,1,fg,bg,#200);
  HorStr(x2,y2,1,fg,bg,#188);
  VerStr(x1,y1+1,y2-y1-1,fg,bg,#186);
  VerStr(x2,y1+1,y2-y1-1,fg,bg,#186);
  HorStr(x1+1,y1,x2-x1-1,fg,bg,#205);
  HorStr(x1+1,y2,x2-x1-1,fg,bg,#205);
End;

Procedure Center(Y : Byte; St : String; Fg,Bg : Byte);
Var X : Byte;
Begin
  X := (40-(length(st) div 2));
  XYString(x,y,st,fg,bg);
End;

Procedure BoxString(y:byte;st : string;fg,bg : byte);
Var x1,y1,x2,y2 : Byte;
Begin
  Center(y,st,fg,bg);
  x1 := 40-(length(st) div 2)-2;
  x2 := x1 + length(st) + 3;
  y1 := y - 1;
  y2 := y + 1;
  Box(x1,y1,x2,y2,fg,bg);
End;

Procedure FillScreen(var sc : screens;s : string;x,y,fg,bg : byte);
Var I,Atx : Byte;
Begin
  Atx := fg or (bg shl 4);
  For I := 1 To Length(s) Do
  Begin
    Sc.position[y,x].ch := s[i];
    Sc.position[y,x].at := atx;
    Inc(x);
    If X > 80 Then
    Begin
      X := 1;
      Inc(y);
      If Y > 25 then
        exit;
    End
  End
End;

Procedure FillScreenC(Var Sc : Screens; Fill : Char; Fg,Bg : Byte);
Var Color,X,Y : Byte;
Begin
  Color := FG Or (BG Shl 4);
  For Y := 1 to 25
    Do For X := 1 to 80 Do Begin
      Sc.Position[Y,X].CH := Fill;
      Sc.Position[Y,X].AT := Color;
    End;
End;

Procedure CursorOff;
Begin
  Fillchar(Regs,Sizeof(Regs),0);
  With Regs Do
  Begin
    ah := $01;
    ch := $20;
    cl := $20;
  End;
  Intr($10,Regs);
End;

Procedure CursorSmall;
Begin
  Fillchar(Regs,Sizeof(Regs),0);
  Regs.Ah := $01;
  Case SType Of
    Mono : Begin
             With Regs Do Begin Ch:=12; cl:=13; End;
           End;
    Color : Begin
              With Regs Do Begin Ch:=6; Cl:=7; End;
            End;
  End;
  Intr($10,regs);
End;

Procedure CursorBig;
Begin
  FillChar(Regs,SizeOf(Regs),0);
  Regs.Ah:=1;
  Regs.Ch:=0;
  Case SType Of
    mono : regs.cl := 13;
    color : regs.cl := 7;
  End;
  Intr($10,Regs);
End;

Begin
  FillChar(Regs,Sizeof(Regs),0);
  Regs.Ah := $0F;
  Intr($10,Regs);
  If Regs.Al = 7 Then Begin
    SType := Mono;
    VidSeg := $B000;
  End
  Else Begin
    SType := Color;
    Vidseg := $B800;
  End;
End.
