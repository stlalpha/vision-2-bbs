{$I+}    {I/O checking}
{$N-}    {Numeric coprocessor}
{$V-}    {Relaxes string typing}
{$B-}    {Boolean complete evaluation}
{$S-}    {Stack checking}
{$R-}    {Range checking}
{$D+}
{$L-}
{$M 15000,1024,1024}

Program UE;

Uses Dos,Crt,MNet,DispEdit,ConfigRT,GenTypes;

Type Userrec = Record
      Handle : Mstr;
      Realname : String[40];
      Password : Mstr;
      Phonenum : String[15];
      SysOpNote : String[35];
      PrivateNote : String[50];
      Prompt : Lstr;
      Expires,
      Laston : Longint;
      Timbank,
      Numon,
      Timetoday,
      nup,
      ndn,
      nbu,
      uploads,
      downloads:integer;
      totaltime:real;
      Voted : Voteset;
      udlevel,
      udpoints,
      level,
      beepedpwd:integer;
      emailannounce:LongInt;
      infoform:array[1..5] of LongInt;
      Color1,
      Color2,
      Color3,
      Color4,
      Color5,
      Color6,
      Color7,
      Displaylen,
      Graphics : Byte;
      Config:Set of Configtype;
      kup,
      kdown:longint;
      UDKratio,
      UDFratio,
      Pcr,
      msglength,
      hackattempts,
      lastrevision:integer;
      MsgHdr,
      DefMsgConf,
      DefFileConf:Byte;
      Lastnummsgs,
      Lastnumfiles:integer;
      FileList:Array [1..9] of Boolean;
      DefProto:Char;
      Flags : String[26]; { A-Z Flags }
      KDownToday : Longint;
      MaxQwk,
      DailyKBLimit:Integer;
      PlayLottery,
      UseDemons:Boolean;
      DemonChance,ListType:Byte;
      TimeLock : Boolean;
      AutoSig : Longint;
     End;

Var UFile : File Of UserRec;
    U : UserRec;

Procedure SetUpScreen;

  Procedure Message(X,Y,BColor,TColor : Byte; M : LStr);
  Begin
    GotoXy(X,Y);
    TextAttr := BColor;
    Disp('[ ');
    TextAttr := TColor;
    Disp(M);
    TextAttr := BColor;
    Disp(' ]');
  End;

Begin
  TextAttr := 8;
  Clear_Screen;
  Display_Border(1,1,79,19,Mixed_Border);
  Message(3,1,9,7,'ViSiON/2 User Editor v2.0á');
  Message(35,1,9,7,'PgDn ú Next þ PgUp ú Last þ ESC ú Exit');
  Message(3,19,9,7,'F1 ú Search');
  Message(27,19,9,7,'F2 ú Delete Account');
  Message(57,19,9,7,'F3 ú Add Account');
End;

Procedure EditUser;
Label
   Start;
Const
   MaxEnt = 25;
Var
   PEntry : Integer;
   Entry : Integer;
   Current : Integer;
   K : Char;

   Procedure Proc_Entry(Func : Edit_Functions);
   Begin

     Case Entry Of
       1 : Edit_String(Func,3,2,'User Handle : ',U.Handle,30,K);
       2 : Edit_String(Func,3,3,'Password : ',U.Password,30,K);
       3 : Edit_String(Func,3,4,'Real Name : ',U.Realname,30,K);
       4 : Edit_String(Func,3,5,'Phone Number : ',U.PhoneNum,15,K);
       5 : Edit_Integer(Func,3,6,'Main Level : ',U.Level,5,-1,32767,K);
       6 : Edit_Integer(Func,3,7,'Total Calls : ',U.Numon,5,0,32767,K);
       7 : Edit_String(Func,3,8,'Public Note : ',U.SysOpNote,30,K);
       8 : Edit_String(Func,3,9,'Access Flags : ',U.Flags,26,K);
       9 : Edit_String(Func,3,10,'Private Note : ',U.PrivateNote,30,K);
       10 : Edit_Integer(Func,3,11,'File Level : ',U.UDLevel,5,0,32767,K);
       11 : Edit_Integer(Func,3,12,'File Points : ',U.UDPoints,5,0,32767,K);
       12 : Edit_Integer(Func,3,13,'Uploads : ',U.Uploads,6,-32767,32767,K);
       13 : Edit_Integer(Func,3,14,'Downloads : ',U.Downloads,6,-32767,32767,K);
       14 : Edit_Long(Func,3,15,'Uploaded Bytes : ',U.KUp,10,0,MaxLongint,K);
       15 : Edit_Long(Func,3,16,'Downloaded Bytes : ',U.KDown,10,0,MaxLongint,K);
       16 : Edit_Integer(Func,3,17,'Total Posts : ',U.Nbu,6,-32767,32767,K);
       17 : Edit_String(Func,3,18,'Prompt : ',U.Prompt,66,K);
       18 : Edit_Integer(Func,50,2,'UDRatio : ',U.UDFRatio,5,0,32767,K);
       19 : Edit_Integer(Func,50,3,'UD K Ratio : ',U.UDKRatio,5,0,32767,K);
       20 : Edit_Integer(Func,50,4,'PCR : ',U.Pcr,5,0,32767,K);
       21 : Edit_Integer(Func,50,5,'Daily K Limit : ',U.DailyKBLimit,5,0,32767,K);
       22 : Edit_Long(Func,50,6,'K Down Today : ',U.KDownToday,7,0,9999999,K);
       23 : Edit_Integer(Func,50,7,'Msg. Length : ',U.MsgLength,5,0,32767,K);
       24 : Edit_YesNo(Func,50,8,'Demon Attacks : ',U.UseDemons,K);
       25 : Edit_Byte(Func,50,9,'Demon Chance : ',U.DemonChance,3,0,100,K);
     End;

     Select_Next_Entry(Func,Entry,MaxEnt,K);
   End;

   Function GetName : Mstr;
   Var Search : Mstr;
   Begin
     Search[0] := #0;

     GotoXy(10,20);
     TextAttr := 9;
     Disp('[ ');
     TextAttr := 15;
     Disp('Handle Search; Enter String:                          ');
     TextAttr := 9;
     Disp(' ]');

     TextAttr := 13;
     Edit_String(edit,41,20,'',search,25,k);

     GotoXy(1,20);
     ClrEol;

     GetName := Search;
   End;

   Function Upstring(S : Mstr) : Mstr;
   Var X : Byte;
   Begin
     For X := 1 to Length(S)
       Do S[x] := Upcase(S[x]);
     UpString := S;
   End;

  Function Valu (Q : Mstr) : Integer;
  Var I,S,Pu : Integer;
      R : Real;
  Begin
    Valu := 0;
    If Length(q) = 0
      Then Exit;
    If Not (q[1] in ['0'..'9','-'])
      Then Exit;
    If Length(q) > 5
      Then Exit;
    Val (q,r,s);
    If S <> 0
      Then Exit;
    If (R <= 32767.0) And (R >= -32767.0)
      Then Valu := Round(r)
  end;

Var X : Byte;
    Total : Integer;
    Search : Mstr;
    Yes : Boolean;
Begin
  Assign(UFile,Cfg.DataDir+'USERS.');
  Reset(UFile);

  If IOResult <> 0 Then Begin
    Close(UFile);
    Disp(#10#13+'USERS. Not Found!');
    Exit;
  End;

  Total := FileSize(UFile) - 1;

  If (ParamStr(1) <> '') and (Valu(ParamStr(1)) <= Total)
    Then Current := Valu(ParamStr(1))
    Else Current := 1;

  Start:

  Seek(UFile,Current);
  nRead(UFile,U);

  K := PGDN;
  Entry := 0;

  For X := 1 to MaxEnt Do Begin
    Inc(Entry);
    Proc_Entry(Display);
  End;

  Entry := 1;

  Repeat
    Proc_Entry(Edit);
    U.Flags := UpString(U.Flags);
  Until (K <> UP) and (K <> DOWN);

  Seek(UFile,Current);
  nWrite(UFile,U);

  Case K Of
    PGDN : Begin
      Inc(Current);
      If Current > Total
        Then Current := 1;
      Goto Start;
    End;

    PGUP : Begin
      Dec(Current);
      If Current < 1
        Then Current := Total;
      Goto Start;
    End;

    F1 : Begin
      Search := GetName;
      If Search = ''
        Then Goto Start;
      For X := 1 to Total Do Begin
        Seek(UFile,X);
        nRead(UFile,U);
        If Pos(UpString(Search),UpString(U.Handle)) > 0
          Then Begin
            Current := X;
            Goto Start;
          End;
      End;
      Goto Start;
    End;

    F2 : Begin
      GotoXy(1,20);
      Yes := False;
      Edit_YesNo(edit,1,20,'Nuke '+U.Handle+'''s Account? ',Yes,k);
      GotoXy(1,20);
      ClrEol;
      If Yes Then
        FillChar(U,SizeOf(U),0);
      Seek(UFile,Current);
      nWrite(UFile,U);
      Goto Start;
    End;

    F3 : Begin
      GotoXy(1,20);
      Yes := False;
      Edit_YesNo(edit,1,20,'Add a [NEW] User Record? ',Yes,K);
      GotoXy(1,20);
      ClrEol;
      If Yes Then Begin
        FillChar(U,SizeOf(U),0);
        Seek(UFile,Total + 1);
        nWrite(UFile,U);
        Inc(Total);
        Current := Total;
      End;
      Goto Start;
    End;

  End;
  Close(UFile);
End;

Procedure Show(S : Mstr);
Begin
  TextAttr := 3;
  Disp('þ ');
  TextAttr := 15;
  Disp(S + #10#13);
End;

Begin
  ReadCfg;
  SetUpScreen;
  EditUser;
  TextAttr := 9;
  Clear_Screen;
  Show('Pretty Small User Editor v2.0á');
  Show('For use with ViSiON/2 BBS');
  Show('(c) Ruthless Enterprises 1993');
  Show('Written By Crimson Blade');
End.