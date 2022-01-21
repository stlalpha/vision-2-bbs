{$M 40555,0,10024}

Uses Dos,
     Crt,
     MNet,
     DosMem,
     DispEdit,
     ConfigRT,
     GenTypes,
     General,
     Video,
     Little;

{$I-,V-,B-,S-,R-}

Type

  Menu_Array = Array[1..50] of MenuRec;
  Comm_Array = Array[1..99] of CommandRec;

Const  LArrow = #203;
       RArrow = #205;
       UArrow = #200;
       DArrow = #208;
       Home   = #199;
       EndKey = #207;
       PGUp   = #201;
       PGDown = #209;
       Space  = #32;
       F10    = #196;
       F2     = #188;
       F3     = #189;
       SF10   = #221;
       SF2    = #213;
       F5     = #191;
       SF5    = #216;
       F8     = #194;
       Help   = #163;
       CommOpen : Boolean = FALSE;
       WhereHelp: Integer = 1;

Var MenuFile : FILE of MenuRec;
    CommFile : FILE of CommandRec;
    Command  : CommandRec;
    Menu     : MenuRec;
    Menus    : ^Menu_Array;
    Commands : ^Comm_Array;
    Total_Menus,
    Total_Comms : Byte;
    Saved    : Screens;
    SaveProc : Pointer;

Procedure Init_Memory;
BEGIN
  Dos_GetMem(Menus,SizeOf(Menu_Array));
  Dos_GetMem(Commands,SizeOf(Comm_Array));
  fillchar(menus^,sizeof(menu_array),0);
  fillchar(commands^,sizeof(comm_array),0);
END;

Procedure De_Init_Memory;
BEGIN
  Dos_FreeMem(Menus);
  Dos_FreeMem(Commands);
END;

Procedure Def_Colors;
Begin
  PColor    := $1F;
  NormColor := $1E;
  InColor   := $0E;
  Def_Fill  := #32;
End;

Procedure Ask_Colors;
Begin
  PColor    := $5E;
  NormColor := $5F;
  InColor   := $0E;
  Def_Fill  := #32;
End;

Procedure White_Colors;
BEGIN
  PColor    := $F1;
  NormColor := $F0;
  InColor   := $1F;
  Def_Fill  := #32;
END;

Procedure Ask(X1,Y1,X2,Y2 : Byte;     { Where }
              Title       : Lstr;     { Title of Box }
              Question    : Lstr;     { Da Question }
              Len         : Byte;     { Max Input Length }
              File_Only   : Boolean;  { Is this a FILENAME? }
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
  If File_Only THEN
  Edit_FName(Edit,X1+3,Y1+3,Question,Result,Len,False,K) ELSE
  Raw_Editor(Edit,X1 + 3,Y1 + 3,Question,Result,Len,K,False,'',True);
  If K = ESC
    Then Result := '';
  WriteScr(S);
  Def_Colors;
End;

Procedure Un_Message;
Begin
  WriteScr(Saved);
End;

Procedure Message(M : Lstr; Beep : Boolean);

Var X : Word;
    K : Char;

Begin
  ReadScr(Saved);
  Color(5,13);
  GrowBOX(10,12,70,14);
  Color(13,15);
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
End;

Procedure Do_Help_File;
Type AStr = String[50];
Var Total : Integer;
    Line : Array[1..300] of AStr;

    Procedure LoadStuff;
    Var T : Text; S : String;
    Begin
      Assign(T,'MENUEDIT.DAT');
      Reset(T);
      total := 0;
      fillchar(line,sizeof(line),0);
      While (Eof(T) = False) AND (total < 300) Do Begin
        Readln(T,S);
        Inc(total);
        Line[total] := S;
      End;
      Close(T);
      While Line[total] = '' Do Dec(total);
    End;

    Procedure Draw_Some (Current:Word);
    VAR X, Y, L, Start, Finish : Word;
        S : String;
    BEGIN
      START    := Current;
      FINISH   := Start + 18;
      L        := 4;
      For X := START TO FINISH DO BEGIN
        S[0] := #0;
        IF X <= TOTAL THEN
          S := Line[x];
        FastWrite(11,L,TextAttr,Tab(S,59));
        Inc(L);
      END;
    END;

    Procedure DO_KEYS;
    VAR K : CHAR;
    BEGIN
      K := #0;
      If WhereHelp < 1 Then WhereHelp := 1
      Else If WhereHelp > Total Then WhereHelp := Total;
      Color(5,15);
      Draw_Some(WhereHelp);
      REPEAT
        K := #0;
        If KeyPRESSED THEN
          K := GetKEY;
        CASE K OF
          #200 : IF WhereHelp>1 THEN BEGIN
                   Dec(WhereHelp);
                   Draw_Some(WhereHelp);
                 END;
          #208 : IF WhereHelp<TOTAL THEN BEGIN
                   Inc(WhereHelp);
                   Draw_Some(WhereHelp);
                 END;
          #209 : IF WhereHelp<TOTAL THEN BEGIN
                   IF (WhereHelp+20) > TOTAL
                     THEN WhereHelp := TOTAL
                     ELSE Inc(WhereHelp,20);
                   Draw_Some(WhereHelp);
                 END;
          #201 : IF WhereHelp>1 THEN BEGIN
                   IF (WhereHelp-20) > 0
                     THEN Dec(WhereHelp,20)
                     ELSE WhereHelp := 1;
                   Draw_Some(WhereHelp);
                 END;
          #199 : BEGIN
                   WhereHelp := 1;
                   Draw_Some(WhereHelp);
                 END;
          #207 : BEGIN
                   WhereHelp := TOTAL;
                   Draw_Some(WhereHelp);
                 END;
        END;
      UNTIL K = #27;
    END;

Begin
  If Not Exist('MENUEDIT.DAT') Then Begin
    Message('Help File "MENUEDIT.DAT" not found!',True);
    Un_Message;
    Exit;
  End;
  ReadScr(Saved);
  Color(5,15);
  GrowBox(10,3,70,23);
  Color(5,14);
  FastWrite(60,3,TextAttr,'Help File');
  FastWrite(60,23,TextAttr,'ESC Exits');
  LoadStuff;
  Cursor_Off;
  Do_Keys;
  Cursor_On;
  Un_Message;
End;

Procedure New_Menu_File(Name:SSTR; Title:MSTR);
Begin
  Assign(MenuFile,Cfg.MenuDir + Name +'.MNU');
  FillChar(Menu,SizeOf(Menu),0);
  Menu.HelpMenu       := Name + '.ANS';
  Menu.Prompt1        := 'New Menu [|TL Left] : ';
  Menu.Prompt2        := '';
  Menu.Acs            := '';
  Menu.Title          := Title;
  Menu.Password       := '';
  Menu.File_Name      := NAME;
  Menu.FallBack       := '';
  Menu.ForceHelpLevel := 0;
  Menu.ClrScrBefore   := FALSE;
  Menu.UsePrompt      := TRUE;
  {$I-}
    Rewrite(MenuFile);
  {$I+}
  NWrite(MenuFile,Menu);
  Close(MenuFile);
End;

Procedure Read_Menus;
Var X : Byte;
    S : SearchRec;
    F : File;
    N : Word;
    M : MenuRec;
Begin
  Message('Loading Configurable Menus...',False);
  Total_Menus := 0;
  FindFirst(Cfg.MenuDir + '*.MNU',$17,S);
  If DosError <> 0
    Then Begin
      Total_Menus := 1;
      New_Menu_File('MAIN','Main Menu');
      Menus^[1] := MENU;
      Un_Message;
      Exit;
    End;
  While DosERROR = 0 Do BEGIN
    Assign(F,Cfg.MenuDir + S.Name);
    Reset(F,1);
    If FileSize(F) = Sizeof(MenuRec)
      Then Begin
        Inc(Total_Menus);
        NBlockRead(F,M,SizeOf(MenuRec),N);
        Menus^[Total_Menus] := M;
      End;
    FindNext(S);
    Close(F);
  END;
  Un_Message;
End;

Procedure Read_Comms(Name : SSTR);
Var X : Byte;
Begin
  If CommOpen
    Then Close(CommFile);
  Assign(CommFile,Cfg.MenuDir + Name + '.CFG');
  If Not Exist(Cfg.MenuDir + Name + '.CFG')
    Then BEGIN
      Rewrite(CommFile);
      FillChar(Command,Sizeof(Command),0);
      Command.Descrip := 'New Command';
      NWrite(CommFile,Command);
      Total_Comms := 1;
      Commands^[1] := Command;
      Exit;
    END
    Else Reset(CommFile);
  CommOpen := TRUE;
  Total_Comms := 0;
  For X := 1 to FileSize(CommFile)
  Do Begin
    Inc(Total_Comms);
    Seek(CommFile,X-1);
    NRead(CommFile,Commands^[Total_Comms]);
  End
End;

Procedure Insert_Command(Where:Byte; Name:Mstr);
Var X : Byte;
BEGIN
  FillChar(Command,SizeOf(Command),0);
  If Where > Total_Comms Then Begin
    Seek(CommFile,FileSize(CommFile));
    NWrite(CommFile,Command);
    Inc(Total_Comms);
    Exit;
  End;
  Command.Descrip := 'New Command';
  For X := Total_Comms DOWNTO Where Do
    Commands^[x+1] := Commands^[x];
  Commands^[Where] := Command;
  Inc(Total_Comms);
  Seek(CommFile,Where-1);
  For X := Where to Total_Comms
    Do NWrite(CommFile,Commands^[x]);
END;

Procedure Delete_Menu(X:BYTE);
Var Ok : Mstr;

      Procedure Nuke(S:STRING);
      VAR F:FILE;
      Begin
        If Not Exist(S)
          Then EXIT;
        Assign(F,S);
        Erase(F);
      End;

Var Y : BYTE;
BEGIN
  If Total_Menus < 2 Then Begin
    Message('You must have AT LEAST one menu! (Press a key)',True);
    Un_Message;
    Exit;
  End;
  OK := 'N';
  ASK(9,9,71,15,
      'Delete Menu: '+Menus^[x].Title,
      'Delete this MENU and all commands now? ',3,False,OK);
  If Upcase(OK[1]) <> 'Y'
    Then EXIT;
  Message('Deleting Menu '+Menus^[x].Title,False);
  Nuke(Cfg.MenuDir + Menus^[x].FILE_NAME + '.MNU');
  Nuke(Cfg.MenuDir + Menus^[x].FILE_NAME + '.CFG');
  For Y := (X+1) to Total_Menus DO
    Menus^[y - 1] := Menus^[y];
  Dec(Total_Menus);
  Un_Message;
END;

Function Add_MENU : Boolean;
Var OK : Mstr;
BEGIN
  OK :='';
  Add_Menu := False;
  ASK(9,9,71,15,
    'Create a NEW Menu Now?',
    'Enter New Menu FILENAME (Cr/Aborts): ',8,TRUE,OK);
  IF OK = '' THEN EXIT;
  If EXIST(Cfg.MenuDir + OK + '.MNU')
    THEN BEGIN
      Message('That Menu File Already Exists!! (Hit Something)',True);
      Un_Message;
      Exit;
    END;
  Inc(Total_Menus);
  FillChar(Menu,SizeOf(Menu),0);
  New_Menu_File(OK,'New Menu');
  Menus^[Total_Menus] := Menu;
  Add_Menu := TRUE;
END;

Procedure Delete_Command(x:byte);
Var Y : byte;
    OK : SSTR;
BEGIN
  If Total_Comms < 2 Then Begin
    Message('You must have AT LEAST one command! (Press a key)',True);
    Un_Message;
    Exit;
  End;
  OK := 'N';
  ASK(9,9,71,15,
      'Delete Command: '+Commands^[x].Descrip,
      'Do you want to delete this command now? ',3,False,OK);
  If Upcase(OK[1]) <> 'Y'
    Then EXIT;
  for y := x to (total_comms-1) do
    commands^[y] := commands^[y+1];
  dec(total_comms);
  seek(commfile,x-1);
  for y := x to total_comms
    do NWrite(CommFile,Commands^[y]);
  seek(commfile,filesize(commfile)-1);
  truncate(commfile);
END;

Function Add_Command(Name:Mstr) : Byte;
Var OK    : Mstr;
    Where : Integer;
BEGIN
  OK :='';
  Add_Command := 0;
  ASK(9,9,71,15,
    'Create a New Command Record Now?',
    'Insert the command where? (1-'+Strr(Total_Comms)+') (Cr/'+Strr(Total_Comms+1)+' or 0 aborts) : ',
     2,TRUE,OK);
  If OK = ''
    Then Ok := Strr(Total_Comms+1);
  Where := Valu(Ok);
  IF Where<1 THEN EXIT;
  IF Where>(Total_Comms+1)
    Then Where := Total_Comms+1;
  Insert_Command(Where,Name);
  Add_Command := Where;
END;

Function Fill(S:Mstr; X:Byte) : MSTR;
BEGIN
  For X := Length(S) to X
    Do Mem[Seg(S):Ofs(S) + X + 1] := 32;
  Mem[Seg(S):Ofs(S)] := X;
  Fill := S;
END;

Procedure Edit_Command(X,CurMenu:BYTE);
Label
   Start;
Const
   MaxEnt = 13;
Var
   PEntry  : Integer;
   Entry   : Integer;
   Current : Word;
   K       : Char;
   Work    : CommandRec;
   S       : Screens;

   Procedure Proc_Entry(Func : Edit_Functions);
   Begin
     Case Entry Of
       1 : Edit_String (Func,4,11, 'Description  : ',Work.Descrip,30,K);
       2 : Edit_String (Func,4,12, 'Keystroke(s) : ',Work.Keys,12,K);
       3 : Edit_String (Func,4,13, 'Command(s)   : ',Work.Command,60,K);
       4 : Edit_String (Func,4,14, 'ASC Required : ',Work.ACS,30,K);
       5 : Edit_YesNo  (Func,4,15, 'Hidden?      : ',Work.Hidden,K);
     End;
     Select_Next_Entry(Func,Entry,MaxEnt,K);
   End;

   Procedure Write_File;
   BEGIN
     Commands^[Current] := Work;
     Seek(CommFile,Current-1);
     NWrite(Commfile,Work);
   END;

Var Temp : String[50];
Begin

  ReadScr(S);

  Current := X;

  Read_Comms(Menus^[CurMenu].File_Name);

  Color(15,8);
  GrowBox(2,9,78,16);
  Color(15,12);
  Center_Write('Command Editing ('+Menus^[CurMenu].Title+')',10);

  Color(8,15);
  GotoXy(1,25); ClrEOL;
  Center_Write('PgUp/PgDn Scrolls  F8 Aborts  F2  Delete  F5 Add New  ESC Exits',25);

  REPEAT

  If Current > Total_Comms Then Current := 1 Else
  If Current < 1 Then Current := Total_Comms;

  White_Colors;

  Work := Commands^[Current];

  K := PGDN;
  Entry := 0;

  For X := 1 to MaxEnt Do Begin
    Inc(Entry);
    Proc_Entry(Display);
  End;

  GotoXy(50,11);
  TextAttr := $F1;
  Write('Current File: ');
  TextAttr := $F0;
  Temp := Menus^[CurMenu].File_Name + '.CFG';
  Write(Fill(Temp,12));
  GotoXy(50,15);
  TextAttr := $F1;
  Write('Current Number: ');
  TextAttr := $F0;
  Temp := Strr(Current) + ' of '+Strr(Total_Comms);
  Write(Fill(Temp,12));

  Entry := 1;

  Repeat
    Proc_Entry(Edit);
    IF K = ALT_H Then Do_Help_File;
  Until (K <> UP) and (K <> DOWN);

  If K <> DispEdit.F8 Then
    Write_File;

  Case K Of
    DispEdit.PGDN : Inc(Current);
    DispEdit.PGUP : Dec(Current);
    DispEdit.F2   : Delete_Command(Current);
    DispEdit.F5   : Current := Add_Command(Menus^[CurMenu].File_Name)
  End;

  UNTIL K IN [#27,DispEdit.F8];

  WriteScr(S);
End;

Procedure Select_Command(CurMenu:Byte);
VAR Current : Integer;
    S       : Screens;

  Procedure Display_Group;
  Var X, Start, Finish, Where : Integer;
  Begin
    Cursor_Off;
    Start  := Current - 6;
    Finish := Start + 14;
    Where  := 7;
    For X := Start to Finish
    Do Begin
      Color(4,15);
      If (X < 1) or (X > Total_Comms)
        Then FastWrite(5,Where,TextAttr,Tab('',65))
      Else Begin
        If Where = 13
          Then Color(0,14)
          Else Color(4,15);
        FastWrite(5,Where,TextAttr,#32 +
                 + Tab(Copy(Commands^[X].Descrip,1,20),21) +
                 + Tab(Copy(Commands^[X].Keys,1,15),16) +
                 + Tab(Copy(Commands^[X].Command,1,30),32));
      End;
      Inc(Where);
    END;
    Cursor_On;
  End;

  Procedure Do_Keys;
  Var K : Char;
  Begin
    Repeat
      K := GetKey;
      Case K Of
        UArrow : If Current > 1
                 Then Begin
                   Dec(Current);
                   Display_Group;
                 End;
        DArrow : If Current < Total_Comms
                 Then Begin
                   Inc(Current);
                   Display_Group;
                 End;
        Home   : If Current > 1
                 Then Begin
                   Current := 1;
                   Display_Group;
                 End;
        EndKey : If Current < Total_Comms
                 Then Begin
                   Current := Total_Comms;
                   Display_Group;
                 End;
        PgUp   : If Current > 1 Then Begin
                   Dec(Current,12);
                   If Current < 1
                     Then Current := 1;
                   Display_Group;
                 End;
        PgDown : If Current < (Total_Comms - 1) Then Begin
                   Inc(Current,12);
                   If Current > (Total_Comms - 1)
                     Then Current := Total_Comms - 1;
                   Display_Group;
                 End;
        #13    : BEGIN
                   Edit_Command(Current,CurMenu);
                   Display_Group;
                 END;
        F5     : BEGIN
                   Current := Add_Command(Menus^[CurMenu].File_Name);
                   If Current > 0 Then
                     Edit_Command(Current,CurMenu);
                   Display_Group;
                 END;
        F2     : BEGIN
                   Delete_Command(Current);
                   If Current > Total_Comms
                     Then Current := Total_Comms;
                   Display_Group;
                 END;
        Help   : Do_Help_File;
      End;
    Until K = #27;
  End;

Begin
  ReadScr(S);
  Color(4,12);
  GrowBox(4,4,76,22);
  Color(4,14);
  Center_Write('Editing Menu Commands for: '+Menus^[CurMenu].Title,5);
  Color(4,12);
  FastWrite(6,6,textattr,'Command Description   Keystroke(s)    Command(s)');
  Color(8,15);
  GotoXy(1,25); ClrEOL;
  Center_Write('F2  Delete Command  F5 Add New Command  ALT-H Help  ESC Exits',25);
  Read_Comms(Menus^[CurMenu].File_Name);
  Current := 1;
  Display_Group;
  Do_Keys;
  WriteScr(S);
End;

Procedure EditMenu(X:BYTE);
Label
   Start;
Const
   MaxEnt = 13;
Var
   PEntry  : Integer;
   Entry   : Integer;
   Current : Word;
   K       : Char;
   Work    : MenuRec;

   Procedure Proc_Entry(Func : Edit_Functions);
   Begin

     Case Entry Of
       1 : Edit_String (Func,4,7, 'Menu Title      : ',Work.Title,20,K);
       2 : Edit_FName  (Func,4,8, 'Fallback Menu   : ',Work.Fallback,8,false,K);
       3 : Edit_FName  (Func,4,9, 'Help File       : ',Work.HelpMenu,12,false,K);
       4 : Edit_String (Func,4,10,'ASC Required    : ',Work.ACS,30,K);
       5 : Edit_Integer(Func,4,11,'Force Menu Level: ',Work.ForceHelpLevel,5,0,32767,K);
       6 : Edit_String (Func,4,12,'Menu Password   : ',Work.Password,30,K);
       7 : Edit_YesNo  (Func,4,13,'Clear Screen    : ',Work.ClrScrBefore,K);
       8 : Edit_YesNo  (Func,4,14,'Use Menu Prompt : ',Work.UsePrompt,K);
       9 : Edit_String (Func,4,15,'Prompt Line 1   : ',Work.Prompt1,57,K);
       10: Edit_String (Func,4,16,'Prompt Line 2   : ',Work.Prompt2,57,K);
       11: Edit_Byte   (Func,4,17,'Force File Conf.: ',Work.File_Conf,2,0,99,K);
       12: Edit_Byte   (Func,4,18,'Force Msg. Conf.: ',Work.Mes_Conf,2,0,99,K);
       13: Edit_YesNo  (Func,4,19,'Force Hot Keys  : ',Work.Force_HotKey,K);
     End;
     Select_Next_Entry(Func,Entry,MaxEnt,K);
   End;

   Procedure Write_File;
   Var F : File; O : Word;
   BEGIN
     Menus^[Current] := Work;
     Assign(F,Cfg.MenuDir + Work.File_Name + '.MNU');
     Reset(F,1);
     NBlockWrite(F,Work,Sizeof(Work),O);
     Close(F);
   END;

Begin

  Current := X;
  Color(8,15);
  GotoXy(1,25); ClrEOL;
  Center_Write('PgUp/PgDn  Scroll Menus  F2  Delete Menu  F5 Add New Menu  F10  Edit Commands',25);

  REPEAT

  If Current < 1 Then Current := Total_Menus Else
  If Current > Total_Menus Then Current := 1;

  White_Colors;

  Work := Menus^[Current];

  K := PGDN;
  Entry := 0;

  For X := 1 to MaxEnt Do Begin
    Inc(Entry);
    Proc_Entry(Display);
  End;

  GotoXy(50,7);
  TextAttr := $F0;
  Write('Current File: ');
  TextAttr := $F4;
  Write(Fill(Work.File_Name+'.MNU',12));

  Entry := 1;

  Repeat
    Proc_Entry(Edit);
    If K = Help Then Do_Help_File;
  Until (K <> UP) and (K <> DOWN);

  If K <> DispEdit.F8 Then
    Write_File;

  Case K Of
    DispEdit.PGDN : Inc(Current);
    DispEdit.PGUP : Dec(Current);
    DispEdit.F2   : Delete_MENU(Current);
    DispEdit.F5   : If Add_Menu Then Current := Total_Menus;
    DispEdit.F10  : Select_Command(Current);
  End;

  UNTIL K IN [#27,DispEdit.F8];
End;

Procedure Edit_Menu(Who : Word);
Var K : Char;
    S : Screens;
Begin
  ReadScr(S);
  Color(8,15);
  GotoXy(1,25); ClrEOL;
  Center_Write('F8 Aborts  F2 Delete  F5 Add  F10 Edit Menu Commands  ESC Exit ',25);
  Color(15,8);
  GrowBOX(2,6,78,20);
  EditMENU(Who);
  WriteScr(S);
End;

Procedure Select_Menu;
VAR Current : Integer;

  Procedure Display_Group;
  Var X, Start, Finish, Where : Integer;
  Begin
    Cursor_Off;
    Start  := Current - 6;
    Finish := Start + 14;
    Where  := 7;
    For X := Start to Finish
    Do BEGIN
      Color(3,15);
      If (X < 1) or (X > Total_Menus)
        Then FastWrite(16,Where,TextAttr,Tab('',48))
      Else Begin
        Color(8,15);
        If Where = 13
          Then Color(4,15);
        If Where = 13
          Then Color(1,15)
          Else Color(3,15);
        FastWrite(16,Where,TextAttr, #32 +
                 + Tab(Menus^[X].Title,20) +
                 + Tab(Menus^[X].File_Name + '.MNU / '+Menus^[X].File_Name + '.CFG',27));
      End;
      Inc(Where);
    END;
    Cursor_On;
  End;

  Procedure Do_Keys;
  Var K : Char;
  Begin
    Repeat
      K := GetKey;
      Case K Of
        UArrow : If Current > 1
                 Then Begin
                   Dec(Current);
                   Display_Group;
                 End;
        DArrow : If Current < Total_Menus
                 Then Begin
                   Inc(Current);
                   Display_Group;
                 End;
        Home   : If Current > 1
                 Then Begin
                   Current := 1;
                   Display_Group;
                 End;
        EndKey : If Current < Total_Menus
                 Then Begin
                   Current := Total_Menus;
                   Display_Group;
                 End;
        PgUp   : If Current > 1 Then Begin
                   Dec(Current,12);
                   If Current < 1
                     Then Current := 1;
                   Display_Group;
                 End;
        PgDown : If Current < (Total_Menus - 1) Then Begin
                   Inc(Current,12);
                   If Current > (Total_Menus - 1)
                     Then Current := Total_Menus - 1;
                   Display_Group;
                 End;
        #13    : BEGIN
                   Edit_Menu(Current);
                   Display_Group;
                 END;
        F5     : BEGIN
                   IF Add_Menu THEN BEGIN
                     Current := Total_Menus;
                     Edit_Menu(Current);
                   END;
                   Display_Group;
                 END;
        F2     : BEGIN
                   Delete_Menu(Current);
                   If Current > Total_Menus
                     Then Current := Total_Menus;
                   Display_Group;
                 END;
        F10   : Select_Command(Current);
        Help  : ;
      End;
    Until K = #27;
  End;

Begin
  Current := 1;
  Display_Group;
  Do_Keys;
End;

Procedure Back_Ground;
Begin
  Fill_Screen('²',7,1);
End;

Procedure Open_Screen;
BEGIN
  Back_Ground;
  GotoXy(1,1);
  Color(8,15);  ClrEol;
  Center_Write('תש ViSiON/2 MENU EDITOR v1.0ב  -  Written By Crimson Blade (July/93) שת',1);
  GotoXy(1,25); Color(8,15);  ClrEOL;
  Center_Write('(CR) Edits Menu  F10 Edits Menu Commands  F2 Delete  F5 Add Menu  ESC Exits',25);
  Color(3,11);
  GrowBox(15,5,65,22);
  Color(11,3);
  Center_Write(' Menu Title           File Names                 ',6);
END;

Procedure Done;
Const Bye = 'V/2 MENU EDITOR v1.0ב  Written By Crimson Blade  All Rights Reserved Buddy!';
BEGIN
  ExitProc := SaveProc;
  De_Init_Memory;
  TextAttr := 1;
  ClrSCR;
  Cursor_On;
  Hi_Back_OFF;
  TextAttr := $1F;
  ClrEOL;
  Center_Write(Bye,1);
  Writeln(#10#13);
END;

Procedure Start_Up;
Begin
  DirectVideo := TRUE;
  SaveProc := ExitProc;
  ExitProc := @DONE;
  Hi_Back_ON;
  Init_Memory;
  ReadCfg;
  Open_Screen;
  Read_Menus;
End;

BEGIN
  Start_Up;
  Select_Menu;
END.