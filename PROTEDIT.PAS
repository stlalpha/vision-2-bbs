{$M 15000,0,1024}

program protedit;

uses dos, crt, mnet, dispedit, configrt, gentypes, general, mdosio,
     video, little;

{$I-,V-,B-,S-,R-}


Const Files : Array[1..4] Of String[12]
      = ('PROT_S.DAT','PROT_R.DAT','PROT_D.DAT','PROT_U.DAT');

Var CurFile : File Of ProtoRec;
    Total : Byte;
    Prot : Array[1..15] Of ProtoRec;

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
  Message(3,15,'F1 - Delete a Protocol');
  Message(54,15,'F2 - Add a Protocol');
End;

Procedure EditProt( W : Byte );
Label
    Start;
Const
    MaxEnt = 4;
Var
    PEntry : Integer;
    Entry : Integer;
    Current : Integer;
    K : Char;
    P : ProtoRec;


    Procedure Proc_Entry(Func : Edit_Functions);
    Var Khar : String[1];
    Begin
      Case Entry Of
        1 : Begin
              Khar[1] := Prot[current+1].Letter;
              Edit_String(Func,4,11,'Protocol Letter : ',Khar,1,K);
              Prot[current+1].Letter := Khar[1];
            End;
        2 : Edit_String(Func,4,12,'Protocol Title : ',Prot[current+1].Desc,30,K);
        3 : Edit_String(Func,4,13,'File Name : ',Prot[current+1].ProgName,12,K);
        4 : Edit_String(Func,4,14,'Command Line : ',Prot[current+1].Commfmt,59,K);
      End;
      Select_Next_Entry(Func,Entry,MaxEnt,K);
    End;

  Procedure WriteFile(X : Byte);
  Var A : Byte;
  Begin
    Rewrite(CurFile);
    For A := 1 to (Total + 1) Do
        nWrite(CurFile,Prot[a]);
    Close(CurFile);
  End;

    Procedure WhichProt;
    Begin
      GotoXy(33,15);
      TextAttr := 16 + 7;
      Disp('[');
      TextAttr := 31;
      Disp('Current: ');
      Write(Current + 1);
      TextAttr := 16 + 7;
      Disp(']');
    End;

    Procedure Create_File;
    var p : protorec;
    Begin
      ReWrite(curfile);
      P.Letter := 'Z';
      P.Desc := 'Zmodem CRC-32';
      P.ProgName := 'DSZ.EXE';
      P.CommFmt := '';
      case w of
        1: P.CommFmt := 'port %1 speed %2 sz %3';
        2: P.CommFmt := 'port %1 speed %2 rz %3';
        3: P.CommFmt := 'port %1 speed %2 sz @%3';
        4: P.CommFmt := 'port %1 speed %2 rz %3';
      end;
      Seek(curfile,0);
      NWrite(curfile,p);
    End;

  Procedure LoadFile( X : Byte );
  Var A : Byte;
  Begin
    Assign(CurFile,Cfg.DataDir + Files[W]);
    If Not Dos_Exists(Cfg.DataDir + Files[w])
      Then Create_File
      Else Reset(CurFile);
    A := 0;
    Seek(Curfile,0);
    While Not Eof(CurFile) Do Begin
      Inc(a);
      nRead(CurFile,Prot[a]);
    End;
    Total := A;
  End;

const titles : array[1..4] of mstr =
      ('Upload Protocols','Download Protocols','Batch Uploads','Batch Downloads');

Var X   : Byte;
    Yes : String[1];
    S   : Screens;
Begin
  ReadScr(s);
  FillChar(prot,SizeOf(prot),0);
  LoadFile(w);
  def_colors;
  color(1,7);
  growbox(2,10,78,15);
  setupscreen(titles[w]);
  Total := FileSize(CurFile) - 1;
  Current := 0;

  Start :

  Seek(CurFile,Current);
  NRead(CurFile,P);

  K := PGDN;
  Entry := 0;

  For X := 1 to MaxEnt
  Do Begin
    Inc(Entry);
    Proc_Entry(Display);
  End;

  Entry := 1;

  WhichProt;

  Repeat
    Proc_Entry(Edit);
  Until (K <> UP) and (K <> DOWN);

  Seek(Curfile,Current);
  NWrite(CurFile,Prot[Current + 1]);

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
      ask(9,9,71,15,'Protocol Deletion',
                    'Delete protocol "'+prot[current+1].Desc+'"? ',3,yes);
      if upcase(yes[1]) <> 'Y' then goto start;
      fillchar(prot[current+1],SizeOf(prot[current+1]),0);
      Seek(CurFile,Current);
      NWrite(CurFile,prot[current+1]);
      If Current = Total Then Begin
        Seek(CurFile,Current);
        Truncate(CurFile);
      End;
      Goto Start;
    End;

    F2 : Begin
      yes := 'N';
      ask(9,9,71,15,'Protocol Addition',
                    'Add a new protocol now? ',3,yes);
      if upcase(yes[1]) = 'Y' then
      Begin
        inc(total);
        Seek(CurFile,FileSize(curfile));
        Prot[total].Letter := #0;
        Prot[total].ProgName := 'DSZ.EXE';
        Prot[total].CommFmt := '';
        Prot[total].Desc := '';
        NWrite(CurFile,Prot[total]);
        Current := Total;
      End;
      Goto Start;
    End;

  End;
  WriteFile(w);
  WriteScr(s);
End;

Procedure Select;
Var
  PEntry : Integer;
  Entry : Integer;
  K : Char;

  Procedure Proc_Entry(Func : Edit_Functions);
  Begin
    Case Entry Of
      1 : Edit_FunKey (Func,26,11,'      Upload Protocols       ','1',K);
      2 : Edit_FunKey (Func,26,12,'     Download Protocols      ','2',K);
      3 : Edit_FunKey (Func,26,13,'   Batch Upload Protocols    ','3',K);
      4 : Edit_FunKey (Func,26,14,'  Batch Download Protocols   ','4',K);
      5 : Edit_FunKey (Func,26,15,'    Quit Protocol Editor     ','Q',K);
    End;
    select_next_entry(func,entry,5,k);
  End;

    procedure def_colors;
    begin
      pcolor    := 16 * 15 + 0;
      normcolor := 16 * 9 + 15;
    end;

Begin
  color(9,15);
  growbox(25,10,55,16);
  def_colors;
  GotoXy(28,6);
  For Entry := 1 to 5
    Do Proc_Entry(Display);
  Entry := 1;
  Repeat
    def_colors;
    Repeat
      Proc_Entry(Edit);
    Until (K<>Up) and (K<>Down);
    Case Upcase(K) Of
      '1' : EditProt(1);
      '2' : EditProt(2);
      '3' : EditProt(3);
      '4' : EditProt(4);
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
  center_write('ViSiON/2 Bulletin Board Protocol Editor v1.0á',1);
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

begin
  hi_back_on;
  start_screen;
  select;
  hi_back_off;
end.