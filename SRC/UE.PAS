{$I-,N-,V-,B-,S-,R-,D+,L-}
{$M 15000,1024,1024}

Program User_Editor;

Uses Dos,
     Crt,
     GenTypes,
     DosMem,
     MNet,
     Video,
     General,
     ConfigRt,
     DispEdit,
     Little;

Type U_Rec = Record
       User_Num : Integer;
       Tagged : Boolean;
       Name   : MStr;
       Level  : String[8];
       Calls  : String[3];
       Number : SStr;
       ULK,
       DLK    : String[6];
       Posts,
       PCR    : String[4];
       LTime,
       LDate  : String[9];
     End;

     U_Array = Array[1..500] Of U_Rec;

Const  LArrow = #203;
       RArrow = #205;
       UArrow = #200;
       DArrow = #208;
       Home   = #199;
       EndKey = #207;
       PGUp   = #201;
       PGDown = #209;
       Space  = #32;
       F9     = #195;
       F10    = #196;
       F2     = #188;
       F3     = #189;
       SF10   = #221;
       SF2    = #213;
       F5     = #191;
       SF5    = #216;

       ListType : Byte = 1;
       ListState: Boolean = True;

Var Use       : ^U_Array;
    U         : UserRec;
    UFile     : File of UserRec;
    MFile     : File of MailRec;
    Total     : Integer;
    Current   : Integer;
    Fore,Back : Byte;
    SaveProc  : Pointer;
    Saved     : Screens;
    IndexFile : File of MStr;
    Quick     : BOOLEAN;

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


Procedure Message(M : Lstr; Wait:Boolean);
Var S : Screens;
    X : Word;
    K : Char;
Begin
  ReadScr(Saved);
  Color(4,12);
  GrowBOX(10,12,70,14);
  Color(12,15);
  GotoXy(11,13);
  For X := 11 to 69
    Do Write(#32);
  Center_Write(M,13);
  For X := 4500 to 5500
    Do Sound(X);
  For X := 3500 to 4500
    Do Sound(X);
  NoSound;
  If Wait Then
    K := GetKey;
End;

Procedure Un_Message;
Begin
  WriteScr(Saved);
End;

Function SearchMail (Startpt,UserNum:integer) : Integer;
Var Cnt : Integer;
    M : MailRec;
Begin
  SearchMail := 0;
  if startpt>=filesize(mfile)-1 then exit;
  Inc(StartPt);
  Seek (mfile,startpt);
  for cnt:=startpt to filesize(mfile)-1 do begin
    NRead (mfile,m);
    If M.Sentto = Usernum then begin
      searchmail:=cnt;
      exit
    end
  end
end;

Procedure DelMail (N:integer);
Var M : MailRec;
    C : Integer;
Begin
  Seek (MFile,n);
  NRead (MFile,m);
  For C := N To FileSize(MFile) - 2 Do Begin
    Seek (mfile,c+1);
    NRead (mfile,m);
    Seek (mfile,c);
    NWrite (mfile,m)
  End;
  Seek (Mfile,Filesize(Mfile) - 1);
  Truncate (MFile);
  If FileSize(Mfile) = 0 Then Begin
    M.SentTo := 0;
    M.Line := -1;
    Seek (MFile,0);
    NWrite (MFile,m)
  End
End;

Procedure Delete_User(Who : Word);
Const Null : Mstr = '';
Var Result : Mstr;
    Cnt : Integer;
Begin
  Seek(UFile,Who);
  NRead(UFile,U);
  Result := 'N';
  Ask(9,9,71,15,'תש Automatic User Annihilator! שת',
                 'You Really Want to Delete '+U.Handle+' Now? ',3,Result);
  If Upcase(Result[1]) <> 'Y' Then
    Exit;

  Seek(IndexFile,Who);
  NWrite(IndexFile,Null);

  FillChar(U,SizeOf(U),0);
  For Cnt := 1 to 5 do U.InfoForm[Cnt] := -1;
  U.EmailAnnounce := -1;
  U.AutoSig := -1;
  Seek(UFile,Who);
  nWrite(UFile,U);
  If Not Exist(Cfg.DataDir + 'MAIL')
    Then Exit;
  Assign(MFile,Cfg.DataDir + 'MAIL');
  Reset(MFile);
  Cnt := -1;
  Repeat
    Cnt := SearchMail(Cnt,Who);
    If Cnt > 0 Then Begin
      DelMail(Cnt);
      Dec(Cnt)
    End;
  Until Cnt = 0;
  Close(MFile);
End;

Procedure Super_Nuker;
Var Result : Mstr;
    X,Y : Word;
Begin
  Y := 0;
  For X := 1 to (Total-1) Do
    If Use^[X].Tagged Then Inc(Y);
  If Y = 0
    Then Begin
      Message('You have not tagged anyone to Delete!',True);
      Un_Message;
      Exit;
    End;
  Result := 'N';
  Ask(9,9,71,15,'תש Super Duper User Nuker שת',
                 'REALLY Delete All Tagged ('+Strr(Y)+') Users? ',3,Result);
  If Upcase(Result[1]) <> 'Y' Then
    Exit;
  For X := 1 to (Total-1) Do
    If Use^[X].Tagged Then Delete_User(Use^[X].User_Num);
End;

Procedure Set_Defaults;
Begin
  U.Level     := Cfg.Deflevel;
  U.Udpoints  := Cfg.Defudpoints;
  U.Udlevel   := Cfg.defudlevel;
  U.Udfratio  := Cfg.defudratio;
  U.Udkratio  := Cfg.defudkratio;
  U.Pcr       := Cfg.defpcr;
  U.Msglength := Cfg.defmsglength;
  U.Dailykblimit := cfg.defdailykblimit;
  U.Flags     := Cfg.DefFlags;
  If (Cfg.ChangeNote = False) Or (U.SysOpNote = '')
    Then U.SysopNote := Cfg.DefUserNote;
End;

Procedure Alphabetize(Numerical : Boolean);
Var
  I, J, Bottom, Top, Middle : Integer;
  Temp : U_Rec;
Begin
  Case Numerical Of
    True  : Message('Restoring User List to Original Order!',False);
    False : Message('Alphabetizing User List.. Weeee!',False);
  End;
  For i := 2 to (Total-1) Do
  Begin
    Temp := Use^[i];
    Bottom := 1;
    Top := i - 1;
    While Bottom <= Top Do
    Begin
      Middle := (Bottom + Top) Div 2;
      Case Numerical Of
        True  : If Temp.User_Num < Use^[Middle].User_Num
                  Then Top := Middle - 1
                  Else Bottom := Middle + 1;
        False : If UpString(Temp.Name) < UpString(Use^[Middle].Name)
                  Then Top := Middle - 1
                  Else Bottom := Middle + 1;
      End;
    End;
    For j := i - 1 DownTo Bottom
      Do Use^[j + 1] := Use^[J];
    Use^[Bottom] := Temp;
  End;
  Delay(1000);
  Un_Message;
  ListState := Numerical;
End;

Procedure Fix_Number(VAR S : SStr);
Var Final : SStr;
    P : Byte;
    K : Char;
Begin
  If (Upcase(S[1]) In ['+','X'])
    Then P := 2
    Else P := 1;
  While P <= Length(S) Do Begin
  K := S[p];
  If K in ['0'..'9']
    Then Inc(P)
    Else Delete (S,P,1);
  End;
  Final := '('+Copy(S,1,3)+') ';
  Final := Final + Copy(S,4,3) + '-';
  Final := Final + Copy(S,7,$FE);
  If Copy(Final,1,2) = '()'
    Then Final := '- No Number -';
  S := Final;
End;

Function Percentage(A,B:Integer):Real;
Begin
  If (A>0) and (B>0)
    Then Percentage := (A/B) * 100
    Else percentage := 0;
End;

Procedure Init(VAR UD:U_REC; X:INTEGER);
BEGIN
  FillChar(UD,SizeOf(UD),0);
  UD.User_Num := X;
  If U.Handle <> ''
    Then UD.Name := U.Handle
    Else UD.Name := '[ Open User Record ]';
  UD.Level := Strr(U.Level);
  UD.Calls := Strr(U.Numon);
  UD.Number := U.PhoneNum;
  Fix_Number(UD.Number);
  UD.ULK := Strlong(U.KUp);
  UD.DLK := Strlong(U.KDown);
  UD.Posts := Strr(U.NBu);
  UD.PCR := Streal(Percentage(U.nbu,U.numon)) + '%';
  UD.LDate := DateStr(U.LastOn);
  UD.LTime := TimeStr(U.LastOn);
END;

Procedure Auto_Validate(Who : Word);
Var Result : Mstr;
Begin
  Seek(UFile,Who);
  NRead(UFile,U);
  Result := 'N';
  Ask(9,9,71,15,'תש Automatic User Quick Validation שת',
                 'Set '+U.Handle+'''s Account to Default? ',3,Result);
  If Upcase(Result[1]) <> 'Y' Then
    Exit;
  Set_Defaults;
  Seek(UFile,Who);
  NWrite(UFile,U);
End;

Procedure Default_Colors;
Var X  : Integer;
    OK : Mstr;
BEGIN
  OK := 'N';
  Ask(9,9,71,15,'תש Change Everyone to Default Colors שת',
                'Mass Change Colors [y/N]? ',1,OK);
  If Upcase(Ok[1]) <> 'Y' Then EXIT;
  For X := 1 to (FileSize(UFILE)-1)
    Do Begin
      Seek(UFile,X);
      NRead(UFile,U);
      U.Color1 := Cfg.DefColor1;
      U.Color2 := Cfg.DefColor2;
      U.Color3 := Cfg.DefColor3;
      U.Color4 := Cfg.DefColor4;
      U.Color5 := Cfg.DefColor5;
      U.Color6 := Cfg.DefColor6;
      U.Color7 := Cfg.DefColor7;
      Seek(UFile,X);
      NWrite(UFile,U);
    End;
END;

Procedure Restructure_UserIndex;
Var X  : Integer;
    OK : Mstr;
    F  : File of Mstr;
    M  : Mstr;

    Procedure Nuke_M;
    Begin
      fillchar(m,sizeof(m),0);
    End;

BEGIN
  OK := 'N';
  Ask(9,9,71,15,'תש Restructure User Index File שת',
                'Re-create User Index [y/N]? ',1,OK);
  If Upcase(Ok[1]) <> 'Y' Then EXIT;
  Assign(F,Cfg.DAtaDir + 'USERINDX.');
  Rewrite(F);
  nuke_m;
  NWrite(F,M);
  For X := 1 to (FileSize(UFILE)-1)
    Do Begin
      Seek(UFile,X);
      NRead(UFile,U);
      nuke_m;
      M := U.Handle;
      NWrite(F,M);
    End;
  Close(F);
END;

Procedure Super_Validate;
Var Result : Mstr;
    X,Y : Word;
Begin
  Y := 0;
  For X := 1 to (Total-1) Do
    If Use^[X].Tagged Then Inc(Y);
  If Y = 0
    Then Begin
      Message('You have not tagged anyone to Quick-Validate!',True);
      Un_Message;
      Exit;
    End;
  Result := 'N';
  Ask(9,9,71,15,'תש Super Duper User Validation שת',
                 'Set All Tagged ('+Strr(Y)+') Users to Defaults? ',3,Result);
  If Upcase(Result[1]) <> 'Y' Then
    Exit;
  For X := 1 to Total Do
    If Use^[X].Tagged
      Then Auto_Validate(Use^[X].User_Num);
End;

Procedure Help_Screen;
Var S : Screens;
    K : Char;
Begin
  ReadScr(S);
  Color(4,15);
  GrowBox(18,4,62,20);
  Color(4,14);
  Center_Write('V/2 User Editor Help (c) RE 1993',5);
  Color(4,15);
  Center_Write('Enter - Edit Highlited User',7);
  Center_Write('Up/Down/End/Home/PgUp/PgDn - Scroll Users',8);
  Center_Write('Left/Right Arrow: Scroll User Data',9);
  Center_Write('F3 - Alphabetize List / De-Alphabetize List',10);
  Center_Write('F2 - Delete Highlited User',11);
  Center_Write('Shift-F2 - Delete All Tagged Users',12);
  Center_Write('F5 - Auto Validate Highlited Users',13);
  Center_Write('Shift-F5 - Auto Validate All Tagged Users',14);
  Center_Write('F9 - Restructure User Index File',15);
  Center_Write('Alt-F10 - Reset Colors to CONFIG defaults',16);
  Center_Write('ESC - Exits Program',17);
  Center_Write('HIT A KEY.',19);
  K := GetKEY;
  WriteScr(S);
End;

Procedure EditUser(Who : Word; OverRide:Boolean);
Label
   Start;
Const
   MaxEnt = 28;
Var
   PEntry : Integer;
   Entry,UNUM,Total : Integer;
   Current : Word;
   K : Char;

   Procedure Write_UserNum;
   Begin
     Color(1,9);
     GotoXy(50,18);
     Write('User Number: ');
     Color(1,14);
     If OVERRIDE
       THEN Write(UNum)
       ELSE Write(Use^[Current].User_Num);
     Write(' of ');
     Write(Total);
     Write(#32#32);
   End;

   Procedure Proc_Entry(Func : Edit_Functions);
   Begin

     Case Entry Of
       1 : Edit_String(Func,3,4,'User Handle : ',U.Handle,30,K);
       2 : Edit_String(Func,3,5,'Password : ',U.Password,30,K);
       3 : Edit_String(Func,3,6,'Real Name : ',U.Realname,30,K);
       4 : Edit_String(Func,3,7,'Phone Number : ',U.PhoneNum,15,K);
       5 : Edit_Integer(Func,3,8,'Main Level : ',U.Level,5,-1,32767,K);
       6 : Edit_Integer(Func,3,9,'Total Calls : ',U.Numon,5,0,32767,K);
       7 : Edit_String(Func,3,10,'Public Note : ',U.SysOpNote,30,K);
       8 : Edit_String(Func,3,11,'Access Flags : ',U.Flags,26,K);
       9 : Edit_String(Func,3,12,'Private Note : ',U.PrivateNote,30,K);
       10 : Edit_Integer(Func,3,13,'File Level : ',U.UDLevel,5,0,32767,K);
       11 : Edit_Integer(Func,3,14,'File Points : ',U.UDPoints,5,0,32767,K);
       12 : Edit_Integer(Func,3,15,'Uploads : ',U.Uploads,6,-32767,32767,K);
       13 : Edit_Integer(Func,3,16,'Downloads : ',U.Downloads,6,-32767,32767,K);
       14 : Edit_Long(Func,3,17,'Uploaded Bytes : ',U.KUp,10,0,MaxLongint,K);
       15 : Edit_Long(Func,3,18,'Downloaded Bytes : ',U.KDown,10,0,MaxLongint,K);
       16 : Edit_Integer(Func,3,19,'Total Posts : ',U.Nbu,6,-32767,32767,K);
       17 : Edit_String(Func,3,20,'Prompt : ',U.Prompt,66,K);
       18 : Edit_Integer(Func,3,21,'Time Per Day : ',U.TimePerDay,6,0,32767,K);
       19 : Edit_Integer(Func,3,22,'Time Left Today : ',U.TimeToday,6,0,32767,K);
       20 : Edit_Integer(Func,50,4,'UDRatio : ',U.UDFRatio,5,0,32767,K);
       21 : Edit_Integer(Func,50,5,'UD K Ratio : ',U.UDKRatio,5,0,32767,K);
       22 : Edit_Integer(Func,50,6,'PCR : ',U.Pcr,5,0,32767,K);
       23 : Edit_Integer(Func,50,7,'Daily K Limit : ',U.DailyKBLimit,5,0,32767,K);
       24 : Edit_Long(Func,50,8,'K Down Today : ',U.KDownToday,7,0,9999999,K);
       25 : Edit_Integer(Func,50,9,'Msg. Length : ',U.MsgLength,5,0,32767,K);
       26 : Edit_YesNo(Func,50,10,'Demon Attacks : ',U.UseDemons,K);
       27 : Edit_Byte(Func,50,11,'Demon Chance : ',U.DemonChance,3,0,100,K);
       28 : Edit_YesNo(Func,50,12,'Time Lock : ',U.TimeLock,K);
     End;
     Select_Next_Entry(Func,Entry,MaxEnt,K);
   End;

   Function Upstring(S : Mstr) : Mstr;
   Var X : Byte;
   Begin
     For X := 1 to Length(S)
       Do S[x] := Upcase(S[x]);
     UpString := S;
   End;

Var X : Byte;
    L : Lstr;
Begin

  Def_Colors;

  Current := Who;

  Total := FileSize(UFile) - 1;

  Start:

  If OverRide
    Then UNum := Current
    Else UNum := Use^[Current].User_Num;

  Seek(UFile,UNum);
  NRead(UFile,U);

  L := U.Prompt;

  K := PGDN;
  Entry := 0;

  For X := 1 to MaxEnt Do Begin
    Inc(Entry);
    Proc_Entry(Display);
  End;

  Write_UserNum;

  Entry := 1;

  Repeat
    Proc_Entry(Edit);
    U.Flags := UpString(U.Flags);
  Until (K <> UP) and (K <> DOWN);

  If K <> DispEdit.F10 Then Begin
    U.Prompt := L;
    Seek(UFile,UNum);
    NWrite(UFile,U);
  End;

  If Not OVERRIDE
    Then Init(Use^[Current],UNum);

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

    DispEdit.F2 : Begin
      Delete_User(Current);
      Goto Start;
    End;

    DispEdit.F5 : Begin
      Auto_Validate(Current);
      Goto Start;
    End;

  End;
End;

Procedure Edit_User(Who : Word; OverRide:Boolean);
Var K : Char;
    S : Screens;
Begin
  ReadScr(S);
  Color(8,15);
  GotoXy(1,1); ClrEOL;
  Center_Write('תש ViSiON/2 Quick & Easy User Editor v1.0ב שת',1);
  GotoXy(1,25); ClrEOL;
  Center_Write('F2 - Delete  F5 - Set Defaults  F10 - Aborts  ESC - Save Changes',25);
  Color(1,9);
  GrowBOX(2,3,78,23);
  EditUser(Who,OverRide);
  WriteScr(S);
End;

Procedure Write_Title;
Const NameStr = '  #   User Name / Handle             ';
Const Title : Array[1..5] Of String[20] = (
        'Level    Calls',
        'Phone Number ',
        'UL K     DL K',
        'Posts    PCR',
        'Last Date Online');
Begin
  GotoXy(11,8);
  Color(9,15);
  Tab(NameStr + Title[ListType],58);
End;

Procedure Back_Ground;
Begin
  Fill_Screen('²',7,1);
End;

Procedure Init_Pick_Screen;
Begin
  Back_Ground;
  GotoXy(1,1);
  Color(8,15);  ClrEol;
  Center_Write('תש ViSiON/2 User Editor v1.3ב  -  Written By Crimson Blade (May/93) שת',1);
  GotoXy(1,25); Color(8,15);  ClrEOL;
  Center_Write('Press Alt-H for Pop-Up Help Screen.',25);
  Color(1,9);
  GrowBox(10,5,70,22);
  Color(1,14);
  Center_Write('תש Bash (CR) to Edit High-Lighted User Now שת',6);
  Write_Title;
End;

Procedure Display_Group;
Var X, Start, Finish, Where : Integer;
Begin
  Cursor_Off;
  Start := Current - 6;
  Finish := Start + 12;
  Where := 9;
  For X := Start to Finish Do Begin
    GotoXy(12,Where);
    Color(1,15);
    If (X < 1) or (X >= Total)
      Then Tab('',57)
    Else Begin
      Color(1,14);
      If Where = 15
        Then Color(0,9);
      If Use^[X].Tagged
        Then Write(#251)
        Else Write(#32);
      If Where = 15
        Then Color(0,14)
        Else Color(1,15);
      Tab(Strr(X),3);
      Tab(Use^[X].Name,30);
      Case ListType Of
        1 : Begin
              Tab(Use^[X].Level,8);
              Tab(Use^[X].Calls,11);
            End;
        2 : Tab(Use^[X].Number,19);
        3 : Begin
              Tab(Use^[X].ULK,8);
              Tab(Use^[X].DLK,11);
            End;
        4 : Begin
              Tab(Use^[X].Posts,8);
              Tab(Use^[X].PCR,11);
            End;
        5 : Begin
              Tab(Use^[X].LDate,11);
              Tab(Use^[X].LTime,8);
            End;
      End;
    End;
    Inc(Where);
  End;
  Cursor_On;
End;

Procedure Tag_All(T : Boolean);
Var X : Integer;
Begin
  For X := 1 to Total
    Do Use^[X].Tagged := T;
  Display_Group;
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
      DArrow : If Current < (Total - 1)
               Then Begin
                 Inc(Current);
                 Display_Group;
               End;
      Home   : If Current > 1
               Then Begin
                 Current := 1;
                 Display_Group;
               End;
      EndKey : If Current < (Total - 1)
               Then Begin
                 Current := Total - 1;
                 Display_Group;
               End;
      PgUp   : If Current > 1 Then Begin
                 Dec(Current,12);
                 If Current < 1
                   Then Current := 1;
                 Display_Group;
               End;
      PgDown : If Current < (Total - 1) Then Begin
                 Inc(Current,12);
                 If Current > (Total - 1)
                   Then Current := Total - 1;
                 Display_Group;
               End;
      RArrow : If ListType < 5 Then Begin
                 Inc(ListType);
                 Write_Title;
                 Display_Group;
               End;
      LArrow : If ListType > 1 Then Begin
                 Dec(ListType);
                 Write_Title;
                 Display_Group;
               End;
      Space  : Begin
                 Use^[Current].Tagged := Not Use^[Current].Tagged;
                 If Current < (Total - 1)
                   Then Inc(Current);
                 Display_Group;
               End;
      F10    : Tag_All(True);
      SF10   : Tag_All(False);
      F2     : Delete_User(Use^[Current].User_Num);
      SF2    : Super_Nuker;
      F5     : Auto_Validate(Use^[Current].User_Num);
      SF5    : Super_Validate;
      F3     : Begin
                 Alphabetize(Not ListState);
                 Display_Group;
               End;
      F9     : Restructure_UserIndex;
      #13    : Edit_User(Current,False);
      #241   : Default_Colors;
      #163   : Help_Screen;

    End;
    IF K IN [#32,F2,SF2,F5,SF5] THEN Display_Group;
  Until K = #27;
End;

Procedure OpenLoad_UserRec;
Var X,Y : Word;
    Numb : Word;
Begin
  TextAttr := 7;
  ClrScr;
  Assign(UFile,Cfg.DataDir + 'USERS');
  Reset(UFile);
  If IoResult <> 0 Then Begin
    Writeln('‏ Unable to open User Records!');
    Halt;
  End;

  Assign(IndexFile,Cfg.DataDir + 'USERINDX.');
  Reset(IndexFile);
  If IoRESULT <> 0 Then Begin
    Writeln('‏ Unable to open USER INDEX file!');
    Halt;
  End;

  Numb := FileSize(UFile) - 1;

  If (ParamCount > 0) and (Valu(ParamStr(1)) <= Numb)
    Then Begin
      QUICK := TRUE;
      Current := Valu(ParamStr(1));
      Back_Ground;
      Edit_User(Current,True);
      Close(UFile);
      TextAttr := 1;
      ClrScr;
      Halt;
    End;

  Total := 1;
  Dos_GetMem(Use,SizeOf(Use^));
  Color(1,9);
  GrowBox(25,9,55,15);
  Color(9,15);
  Center_Write('  ViSiON/2 User Editor v1.3ב ',10);
  Color(1,15);
  Center_Write('Written By Crimson Blade',11);
  Center_Write('Scanning Users...',13);
  Y := 0;
  Current := 1;
  For X := 1 to (FileSize(UFile) - 1)
    Do Begin
      Seek(UFile,X);
      NRead(UFile,U);
      Init(Use^[Total],Total);
      Inc(Total);
    End;
End;

Procedure Aborted;
Begin
  QUICK := FALSE;
  ExitProc := SaveProc;
  TextAttr := 1;
  ClrScr; GotoXy(1,1); Color(1,15); ClrEOL;
  Center_Write('ViSiON/2 User Editor v1.3ב  (c) 1993 RE  All Jams and Jellies Preserved.',1);
  Writeln;
  Close(UFile);
  Close(IndexFile);
  Hi_Back_Off;
  Cursor_On;
End;

Begin
  DirectVideo := True;
  ReadCfg;
  SaveProc := ExitProc;
  ExitProc := @Aborted;
  Hi_Back_On;
  OpenLoad_UserRec;
  Init_Pick_Screen;
  Display_Group;
  Do_Keys;
  TextAttr := 1;
  ClrScr;
  Close(UFile);
  Hi_Back_Off;
End.