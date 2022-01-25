{$M 15000,0,1024}

Program Emulate;

Uses Dos,
     Crt,
     MNet,
     DispEdit,
     ConfigRT,
     GenTypes,
     General,
     Video,
     Little;

{$I-,V-,B-,S-,R-}

Var EFile  : File of EmulationRec;
    Emul   : EmulationRec;
    EArray : Array[1..20] of EmulationRec;
    Total  : Byte;

Procedure Def_Colors;
Begin
  PColor := 31;
  NormColor := 30;
  InColor := 14;
  Def_Fill := #32;
End;

Procedure Ask_Colors;
Begin
  PColor := 5 * 16 + 14;
  NormColor := 5 * 16 + 15;
  InColor := 14;
  Def_Fill := #32;
End;

Procedure Ask(X1,Y1,X2,Y2 : Byte;     { Where }
              Title       : Lstr;     { Title of Box }
              Question    : Lstr;     { Da Question }
              Len         : Byte;     { Max Input Length }
              VAR Result  : Mstr);    { User Input }
Var S : Screens;
    K : Char;
    X : Byte;
Begin
  ReadScr(S);
  Ask_Colors;
  Color(5,15);
  GrowBOX(X1,Y1,X2,Y2);
  Color(13,15);
  GotoXy(X1 + 1,Y1 + 1);
  For X := (X1 - 1) to (X2 - 3)
    Do Write(#32);
  Center_Write(Title,Y1 + 1);
  GotoXy(X1 + 3,Y1 + 2);
  Raw_Editor(Edit,X1 + 3,Y1 + 3,Question,Result,Len,K,False,'',True);
  If K = ESC
    Then Result := '';
  WriteScr(S);
  Def_Colors;
End;

Procedure Message(M : Lstr; Beep : Boolean);
Var S : Screens;
    X : Word;
    K : Char;
Begin
  ReadScr(S);
  Color(4,12);
  GrowBOX(10,12,70,14);
  Color(12,15);
  GotoXy(11,13);
  For X := 11 to 69
    Do Write(#32);
  Center_Write(M,13);
  If Beep Then Begin
    For X := 4500 to 5500
      Do Sound(X);
    For X := 3500 to 4500
      Do Sound(X);
    NoSound;
    K := GetKey;
  End Else
    Delay(2000);
  WriteScr(S);
End;

Procedure New_File;
Begin
  Assign(EFile,Cfg.DataDir + 'EMULATE.DAT');
  FillChar(EMul,SizeOf(EMul),0);
  EMul.Name := 'ViSiON/2';
  EMul.TextDir := Cfg.TextFileDir;
  EMul.AllowBars := True;
  EMul.MaxLevel := 32767;
  Emul.Identity := 1;
  {$I-} Rewrite(EFile); {$I+}
  NWrite(EFile,Emul);
  Close(EFile);
End;

Procedure Read_All;
Var X : Byte;
Begin
  If Not Exist(Cfg.DataDir + 'EMULATE.DAT')
    Then New_File;
  Assign(EFile,Cfg.DataDir + 'EMULATE.DAT');
  {$I-} Reset(EFile); {$I+}
  Total := 0;
  For X := 1 to FileSize(EFile)
  Do Begin
    Inc(Total);
    Seek(EFile,X-1);
    NRead(EFile,EArray[Total]);
  End
End;

Procedure Edit_All;
Label Start;
Const MaxEnt = 7;
Var
   PEntry : Integer;
   Entry : Integer;
   Current : Word;
   K : Char;

   Procedure Proc_Entry(Func : Edit_Functions);
   Begin
     Case Entry Of
       1 : Edit_String (Func,17,12,'Emulation Name: ',EMul.Name,30,K);
       2 : Edit_FName  (Func,17,13,'Text Directory: ',EMul.TextDir,32,False,K);
       3 : Edit_YesNo  (Func,17,14,'Use Arrow Bars: ',EMul.AllowBars,K);
       4 : Edit_Integer(Func,17,15,'Minimum Level : ',EMul.MinLevel,5,0,32767,K);
       5 : Edit_Integer(Func,17,16,'Maximum Level : ',EMul.MaxLevel,5,0,32767,K);
       6 : Edit_String (Func,17,17,'Access Flags  : ',EMul.E_Flags,26,K);
       7 : Edit_Byte   (Func,17,18,'Access Number : ',Emul.Identity,3,1,255,K);
     End;
     Select_Next_Entry(Func,Entry,MaxEnt,K);
   End;

Var Total,X : Word;
    Result  : String[3];
Begin
  Color(1,9);
  GrowBOX(15,8,65,19);
  Color(9,15);
  GotoXY(16,10);
  Write('PgUp Next  PgDn Prev. ESC Quit  F10 Abort  F5 New');
  Def_Colors;
  Total := FileSize(EFile);
  Current := 1;
  Start:
  Seek(EFile,Current - 1);
  NRead(EFile,EMul);
  K := PGDN;
  Entry := 0;
  For X:=1 to MaxEnt Do Begin
    Inc(Entry);
    Proc_Entry(Display);
  End;
  Entry := 1;
  Repeat
    Proc_Entry(Edit);
    EMul.E_Flags := UpString(EMul.E_Flags);
  Until (K <> UP) and (K <> DOWN);

  If K <> DispEdit.F10 Then Begin
    Seek(EFile,Current - 1);
    NWrite(EFile,Emul);
  End;

  Case K Of
    DispEdit.PGDN : Begin
      Inc(Current);
      If Current > Total
        Then Current := 1;
      Goto Start;
    End;

    DispEdit.PGUP : Begin
      Dec(Current);
      If Current < 1
        Then Current := Total;
      Goto Start;
    End;

    DispEdit.F5 : Begin
      Result := 'N';
      Ask(9,9,71,15,'תש Create a NEW Record Entry Now? שת',
                     'Are you sure you want to make another entry? ',3,Result);
      If Upcase(Result[1]) <> 'Y' Then
        Goto Start;
      FillChar(Emul,SizeOf(Emul),0);
      Seek(EFile,Total);
      NWrite(EFile,EMUL);
      Inc(Total);
      Current := Total;
      Goto Start;
    End;

  End;
End;

Procedure Open_Screen;
Begin
  Fill_Screen('²',7,1);
  GotoXy(1,1); Color(8,15); ClrEOl;
  Center_Write('ViSiON/2 BBS Multiple Text File Directories Setup Utility v1.0ב',1);
  GotoXy(1,25); ClrEOL;
  Center_Write('Written by Crimson Blade  (C) 1993 Ruthless Enterprises',25);
  Message('Loading Current Setup',False);
End;

Var K : Char;
Begin
  ReadCfg;
  Hi_Back_On;
  Open_Screen;
  Read_All;
  Edit_All;
  Hi_Back_Off;
  TextAttr := 1;
  ClrScr;
End.