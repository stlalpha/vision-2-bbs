{$M 9024,0,1024}

Program ConfEd;

Uses Crt, MNet, MDosIo, DispEdit, GenTypes, ConfigRt, General,
     Video, Little;

{$I-}

Const ConfFile : Array[1..2] Of String[12]
               = ('XFERCONF.DAT','MSGCONF.DAT');

Type ConfRec = Record
       Name,
       Password : Lstr;
       Flags : String[26];
       Minlevel,
       Maxlevel : integer;
       OpenTime,
       CloseTime : Sstr;
     End;

Var Fd : File Of ConfRec;
    C : ConfRec;
    Total : Word;

procedure def_colors;
begin
  pcolor    := 31;
  normcolor := 27;
  incolor   := 14;
  def_fill  := #32;
end;

procedure message(m : lstr; beep : boolean);
var s : screens;
    x : word;
    k : char;
begin
  readscr(S);
  color(4,12);
  growbox(10,12,70,14);
  color(12,15);
  gotoxy(11,13);
  for x := 11 to 69
    do write(#32);
  center_write(M,13);
  if beep then begin
    for x := 4500 to 5500
      do sound(X);
    for x := 3500 to 4500
      do sound(X);
    nosound;
    k := getkey;
  end else
    delay(2000);
  writeScr(S);
end;

Procedure Nuke_Msg_Conf(X : Byte);
Var F     : File;
    BFile : File of BoardRec;
    BDir  : BoardRec;
    NSFile: File of NewScanRec;
    NS    : NewScanRec;
    I,P   : Integer;
Begin
  ClrScr;
  I := IoResult;
  If Not Exist(Cfg.BoardDir + 'BOARDDIR.' + Strr(X))
    Then Exit;
  Assign(BFile,Cfg.BoardDir + 'BOARDDIR.' + Strr(X));
  Reset(BFile);
  If IoResult <> 0 Then Begin
    Close(BFile);
    Exit;
  End;
  For I := 1 to FileSize(BFile) Do Begin
    Seek(BFile,I-1);
    NRead(BFile,BDir);
    If Exist(Cfg.BoardDir + BDir.ShortName + '.' + Strr(X))
    Then Begin
      Writeln('Deleting Sub-Board: ',BDir.BoardName);
      Assign(F,Cfg.BoardDir + BDir.ShortName + '.' + Strr(X));
      Erase(F);
      P := IoResult;
      Assign(F,Cfg.TextDir + BDir.ShortName + '.M' + Strr(X));
      Erase(F);
      P := IoResult;
      Assign(F,Cfg.TextDir + BDir.ShortName + '.T' + Strr(X));
      Erase(F);
      P := IoResult;
    End;
  End;
  Writeln('Deleteing Board Index File');
  Close(BFile);
  Erase(BFile);
  I := IoResult;
  Assign(NSFile,Cfg.DataDir + 'SCANDATA.' + Strr(X));
  Reset(NSFile);
  If IoResult <> 0 Then Begin
    Close(NSFile);
    Exit;
  End;
  Write('Updating NewScan Records...');
  For I := 1 to FileSize(NSFile) Do Begin
    Seek(NSFile,I-1);
    NRead(NSFile,NS);
    FillChar(NS.LastRead,SizeOf(NS.LastRead),0);
    NS.NewScanConfig := [];
    NS.Access1 := [];
    NS.Access2 := [];
    Seek(NSFile,I-1);
    NWrite(NSFile,NS);
  End;
  Close(NSFile);
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

Procedure SetUpScreen(Title : Mstr);

  Procedure Message(X,Y : Byte; M : LStr);
  Begin
    GotoXy(X,Y);
    TextAttr := 16 + 7;
    Disp('[');
    TextAttr := 31;
    Disp(M);
    TextAttr := 16 + 7;
    Disp(']');
  End;

Begin
  Message(3,10,Title);
  Message(35,10,'PgDn - Next   PgUp - Last   ESC - Exit');
  Message(3,18,'F1 = Delete Conference');
  Message(54,18,'F2 = Add Conference');
End;

Procedure EditConf( W : Byte );
Label
    Start;
Const
    MaxEnt = 7;
Var
    PEntry : Integer;
    Entry : Integer;
    Current : Integer;
    K : Char;


    Procedure Proc_Entry(Func : Edit_Functions);
    Begin
      Case Entry Of
        1 : Edit_String(Func,4,11,'Conference Name : ',C.Name,55,K);
        2 : Edit_String(Func,4,12,'Conference Password : ',C.Password,30,K);
        3 : Edit_String(Func,4,13,'Conference Flags : ',C.Flags,26,K);
        4 : Edit_Integer(Func,4,14,'Minimum Entry Level : ',C.MinLevel,5,0,32767,K);
        5 : Edit_Integer(Func,4,15,'Maximum Entry Level : ',C.MaxLevel,5,0,32767,K);
        6 : Edit_String(Func,4,16,'Conference Open Time : ',C.OpenTime,12,K);
        7 : Edit_String(Func,4,17,'Conference Close Tome : ',C.CloseTime,12,K);
      End;
      Select_Next_Entry(Func,Entry,MaxEnt,K);
    End;

    Procedure WhichConf;
    Begin
      GotoXy(33,18);
      TextAttr := 16 + 7;
      Disp('[');
      TextAttr := 31;
      Disp('Conf #: ');
      Write(Current + 1);
      TextAttr := 16 + 7;
      Disp(']');
    End;

    Procedure Create_File;
    Begin
      ReWrite(FD);
      C.Name := 'New Conference';
      C.OpenTime := '4:01 am';
      C.CloseTime := '4:00 am';
      C.MinLevel := 5;
      C.MaxLevel := 32767;
      Seek(FD,0);
      NWrite(Fd,C);
    End;


Var X   : Byte;
    Yes : String[1];
    S   : Screens;
Begin
  ReadScr(s);
  FillChar(C,SizeOf(C),0);
  Assign(FD,Cfg.DataDir + ConfFile[W]);
  If Not Dos_Exists(Cfg.DataDir + ConfFile[w])
    Then Create_File
    Else Reset(Fd);
  def_colors;
  color(1,7);
  growbox(2,10,78,18);
  If W = 1
    then SetUpScreen('File Conference Editor')
    else SetUpScreen('Message Conference Editor');
  Total := FileSize(Fd) - 1;
  Current := 0;

  Start :

  Seek(Fd,Current);
  NRead(Fd,C);

  K := PGDN;
  Entry := 0;

  For X := 1 to MaxEnt
  Do Begin
    Inc(Entry);
    Proc_Entry(Display);
  End;

  Entry := 1;

  WhichConf;

  Repeat
    Proc_Entry(Edit);
  Until (K <> UP) and (K <> DOWN);

  Seek(Fd,Current);
  NWrite(Fd,C);

  Case K Of

    PGDN : Begin
      Inc(Current);
      If Current > Total
        Then Current := 0;
      Goto Start;
    End;

    PGUP : Begin
      Dec(Current);
      If Current < 0
        Then Current := Total;
      Goto Start;
    End;

    F1 : Begin
      yes := 'N';
      ask(9,9,71,15,'Conference Deletion',
                    'Delete conference "'+C.Name+'"? ',3,yes);
      if upcase(yes[1]) <> 'Y' then goto start;
      fillchar(C,SizeOf(C),0);
      Seek(Fd,Current);
      NWrite(Fd,C);
      If W = 2 Then Begin
        Nuke_Msg_Conf(Current + 1);
        TextAttr := 1;
        ClrScr;
        SetUpScreen('Message Conference Editor');
      End;
      If Current = Total Then Begin
        Seek(FD,Current);
        Truncate(FD);
      End;
      Goto Start;
    End;

    F2 : Begin
      yes := 'N';
      ask(9,9,71,15,'Conference Addition',
                    'Add a new conference now? ',3,yes);
      if upcase(yes[1]) = 'Y' then
      Begin
        FillChar(C,SizeOf(C),0);
        Seek(Fd,FileSize(FD));
        C.Name := 'New Conference';
        C.OpenTime := '4:01 am';
        C.CloseTime := '4:00 am';
        C.MinLevel := 5;
        C.MaxLevel := 32767;
        NWrite(Fd,C);
        Inc(Total);
        Current := Total;
      End;
      Goto Start;
    End;

  End;

  WriteScr(s);
  Close(Fd);
End;

Procedure Select;
Var
  PEntry : Integer;
  Entry : Integer;
  K : Char;

  Procedure Proc_Entry(Func : Edit_Functions);
  Begin
    Case Entry Of
      1 : Edit_FunKey (Func,26,12, '   Edit Message Conference   ','1',K);
      2 : Edit_FunKey (Func,26,13, '    Edit File Conferences    ','2',K);
      3 : Edit_FunKey (Func,26,14,'   Quit Conference Editing   ','Q',K);
    End;
    select_next_entry(func,entry,3,k);
  End;

    procedure def_colors;
    begin
      pcolor    := 16 * 15 + 0;
      normcolor := 16 * 9 + 15;
    end;

Begin
  color(9,15);
  growbox(25,11,55,15);
  def_colors;
  GotoXy(28,6);
  For Entry := 1 to 3
    Do Proc_Entry(Display);
  Entry := 1;
  Repeat
    def_colors;
    Repeat
      Proc_Entry(Edit);
    Until (K<>Up) and (K<>Down);
    Case Upcase(K) Of
      '1' : EditConf(2);
      '2' : EditConf(1);
      'Q' : K := ESC;
    End;
  Until K = ESC;
  TextAttr := 1;
  Clear_Screen;
End;

procedure start_screen;
begin
  fill_screen('²',7,1);
  gotoxy(1,1);
  color(8,15);
  clreol;
  center_write('ViSiON/2 Bulletin Board Conference Editor v1.0á',1);
  gotoxy(1,25);
  clreol;
  center_write('Written by Crimson Blade  (c) 1993 Ruthless Enterprises',25);
  if not exist('CONFIG.BBS') then
    begin
      message('CONFIG.BBS not found!',false);
      halt;
    end;
  readcfg;
end;

Begin
  hi_back_on;
  start_screen;
  select;
  hi_back_off;
End.