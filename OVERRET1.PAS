{$R-,S-,I-,D-,F-,V-,B-,N-,L+,O+}

Unit OverRet1;

Interface

Uses GenTypes;

Procedure Password(Info:Lstr);
Procedure CloseWindow;
Procedure getstring(t:lstr;Var m);
Procedure getint(t:lstr;Var i:Integer);
Procedure GetReal(T:Lstr; Var r:real);
Procedure getboo(t:lstr;Var b:Boolean);
Procedure QuoteMessage(M:Integer);
{ procedure help (fn:mstr); }
procedure edituser (eunum:integer);
procedure printnews(W:Byte; NewScan:Boolean);
function getlastcaller:lstr;
procedure showlastcallers;
procedure infoform(a:byte);

{/
  function selectspecs (var us:userspecsrec):boolean;
  procedure editoldspecs;
  Procedure ConfigFileListings;
/}

Procedure Notice(N:Mstr; Str:Lstr);
Function validphone(showstuff:Boolean):boolean;
Procedure GetPhoneNum;

Type QuoteRec = Record
       AllowQuote,
       MsgSec, Anon   : Boolean;
       MsgNum, When   : Longint;
       Title, From, SendTo : Mstr;
       TxtFile,MailFile : SStr;
     End;

Var Quoting : QuoteRec;
    QPtr : ^Message;

Implementation

Uses MNeT, Crt, DosMem, Windows, PAVT150, Modem, ConfigRt,
     GenSubs, Subs1, SubsOvr, Subs2, UserRet, TextRet, Flags, MainR1;

procedure boxit(a,b,c,d:integer); { a = starting y pos. }
var cnt,tmp:integer;              { b = starting x pos. }
begin                             { c = # of chars across }
  ClearBreak;                     { d = # of lines down }
  NoBreak := True;
  AnsiReset;
  Write(^O);
  Write(direct,#27+'[',a,';',b,'H');
  write('Õ');
  for cnt:=1 to c-2 do write('Í');
  write('¸');
  for tmp:=1 to d-2 do begin
    write(direct,#27+'[',A+tmp,';',b,'H');
    write('³');
    write(direct,#27+'[',A+tmp,';',b+c-1,'H');
    write('³');
  end;
  write(direct,#27+'[',a+d-1,';',b,'H');
  write('Ô');
  for cnt:=1 to c-2 do write('Í');
  write('¾');
  NoBreak := False;
end;

Procedure Password(Info:Lstr);
Begin
  Dots:=True;
  SetScreenSize(80,25);
  GotoXy(1,25);
  TextAttr:=112;
  ClrEol;
  SplitMode:=True;
  Write(Usr,'þ '+Info);
  Subs2.Password:=WhereX;
  SetScreenSize(80,24);
End;

Procedure CloseWindow;
Begin
  InitWinds;
  SplitMode:=False;
  Dots:=False;
End;

    Procedure getstring(t:lstr;Var m);
    Var q:lstr Absolute m;
        mm:lstr;
        ic,i,x:byte;
    Begin
      WriteLn(^R'Old ',t,^A': '^S+q);
      write(^R'New '^A+t+^R' ['^A'CR'^R']/Same: ');
      if match(t,'description') then begin
       InputBox(37);
      end else writestr ('*');
      mm:=inpt;
      If Length(mm)<>0 Then q:=mm;
      WriteLn
    End;

  Procedure getint(t:lstr;Var i:Integer);
    Var s:sstr;
    Begin
      s:=strr(i);
      getstring(t,s);
      i:=valu(s)
    End;

  Procedure GetReal(T:Lstr; Var r:real);
  Var s:sstr;
  Begin
    s:=Streal(R);
    GetString(T,S);
    R:=RealValu(S);
  End;

  Procedure getboo(t:lstr; Var b:Boolean);
  Var s:sstr;
  Begin
    DefYes := B;
    WriteStr(T + '!');
    B := Yes;
  End;

Procedure QuoteMessage(M:Integer);
var b:bulrec;                       {Note: Qptr^ is intialized here, BUT}
    Me : Message;                   {must be disposed in ansiedit if <> Nil}
    Str:AnyStr;
    A,start,finish,i,wo:byte;
    k:char;

   procedure getbrec(mess:integer);
   begin
     seek (bfile,mess-1);
     NRead (bfile,b); che
   end;

   Function Filter(S:AnyStr):AnyStr;
   Var i:byte;
   Begin

     If Not Cfg.FilterQuote then Begin
       Filter:=S;
       Exit;
     End;

     I := Length(S) - 2;
     While I > 0 Do Begin
       If (S[I] = '|') Then
         If Valu(Copy(S,I + 1,2)) > 0
           Then Begin
             Delete(S,I,3);
             Dec(I,2);
           End;
       Dec(I);
     End;

     Filter := S;
   End;

   Function QuoteLine(Line:Lstr):Lstr;
   Var I,T,F : Byte;
       L,Temp : Lstr;
   Begin
     i:=0;
     Temp:='';
     While i < Length(Line) Do Begin
       inc(i);
       If Line[i]='^' Then Begin
         Inc(i);
         Case Upcase(Line[i]) Of
           'N':If Quoting.Anon
                 Then Temp:=Temp+'Anonymous'
                 Else Temp:=Temp+Quoting.From;
           'T':Temp:=Temp+Quoting.Title;
           'F':Temp:=Temp+Quoting.SendTo;
           'D':Temp:=Temp+DateStr(Quoting.When);
           'W':Temp:=Temp+TimeStr(Quoting.When);
         End;
       End Else
         Temp:=Temp+Line[i];
     End;
    QuoteLine:=Temp;
  End;

  Procedure Quote(Start,Finish:Byte);
  Var a,i:Byte;
  Begin
    QPtr^.Text[1] := QuoteLine(Strng^.QuoteTop);
    A:=2;
    For I := Start To Finish Do Begin
      If ((i=Start) or (i=Finish)) And (Me.Text[i]='')
      Then Else Begin
        QPtr^.Text[A] := #32 + Filter(Me.Text[i]);
        If Length(Qptr^.Text[A]) > 79
          Then Qptr^.Text[ A ][ 0 ] := #79;
        Inc(A);
      End;
    End;
    QPtr^.Text[A] := QuoteLine(Strng^.QuoteBottom);
    QPtr^.Numlines := A;
  End;

Label Exit;
Var W : Word;
    Max : Integer;
Begin

  { Dos_GetMem (QPtr,SizeOf(Qptr^)); }

  GetMem(QPtr,SizeOf(Message));
  FillChar(QPtr^,SizeOf(Qptr^),0);

  If Quoting.MsgSec = True Then Begin

    If M > FileSize(bfile) then Begin
      Writeln(^G^S'Message out of range!');
      Delay(500);
      QPtr^.Text[1] := '';
      Goto Exit;
    End;

    GetBrec(M);
    ReLoadText(Quoting.TxtFile,Quoting.MailFile,B.Line,Me);

    If Me.Numlines < 1 Then Begin
      Writeln('Error reading message!');
      Delay(500);
      QPtr^.Text[1] := '';
      Goto Exit;
    End;
  
    Quoting.Title := B.Title;
    Quoting.From  := B.LeftBy;
    Quoting.SendTo:= B.SentTo;
    Quoting.When  := B.When;
    Quoting.Anon  := B.Anon;

  End Else
    ReloadText(Quoting.TxtFile,Quoting.MailFile,Quoting.MsgNum,Me);

  Sr.C[1] := 'TI'; Sr.S[1] := Quoting.Title;
  Sr.C[2] := 'FR'; Sr.S[2] := Quoting.From;
  Writeln(^M);
  MultiColor(strng^.quotetitle);
  Writeln(^M);
  A := 1;
  For i:=1 to Me.Numlines Do Begin
    Write(^R+strr(A)+^A': '^S);
    If Length(Me.Text[i]) > 75
      Then Me.Text[i][0] := #75;
    Subs1.MultiColor(me.text[i]);
    Writeln;
    Inc(A);
  End;

  Writeln;
    Repeat
      Sr.C[1] := 'EN'; Sr.S[1] := strr(me.numlines);
      Sr.C[2] := 'ST'; Sr.S[2] := '1';
      MultiColor(strng^.QuoteStartLine); WriteSTr('*');
      A := Valu(inpt);
      If (A>0) and (A<=me.numlines)
        Then Start:=A
        Else If Upcase(inpt[1])='Q' then Begin
          QPtr^.Text[1][0]:=#0;
          Goto Exit;
        End;
    Until (A>0) and (A<=me.numlines);
    Repeat
      Max := Start + Cfg.MaxQuotedLines;
      If Max > Me.NumLines Then Max := Me.Numlines;
      Sr.C[1] := 'EN'; Sr.S[1] := strr(max);
      Sr.C[2] := 'ST'; Sr.S[2] := strr(start);
      MultiColor(Strng^.QuoteEndLine); WriteStr('*');
      A := Valu(inpt);
      If (A>=Start) and (A<=Max)
        Then Finish:=A
        Else If Upcase(inpt[1]) = 'Q' Then Begin
          QPtr^.Text[1][0] := #0;
          Goto Exit;
        End;
    Until (A >= Start) and (A <= Max);
    Quote(Start,Finish);

  Exit :
End;

(*
  Procedure help(fn:mstr);
    Var tf:Text;
      htopic,cnt:Integer;
    Begin
      fn:=cfg.textfiledir+fn;
      Assign(tf,fn);
      Reset(tf);
      If IOResult<>0 Then Begin
        writestr('Sorry, no help is availiable for this area!');
        If issysop Then Begin
          WriteLn(usr,'Sysop: To make help, create a file called ',fn);
          WriteLn(usr,'Group the lines into blocks separated by periods.');
          WriteLn(usr,'The first group is the topic menu; the second is the');
          WriteLn(usr,'help for topic 1; the third for topic 2; etc.')
        End;
        exit
      End;
      Repeat
        textclose(tf);
        Assign(tf,fn);
        Reset(tf);
        WriteLn(^M);
        printtexttopoint(tf);
        Repeat
          writestr(^M^R'Topic Number ['^A'CR'^R']/Quit: *');
          If hungupon Or (Length(inpt)=0) Then
            Begin
              textclose(tf);
              exit
            End;
          htopic:=valu(inpt)
        Until (htopic>0);
        For cnt:=2 To htopic Do
          If Not EoF(tf)
          Then skiptopoint(tf);
        If EoF(tf)
        Then writeln('Sorry, no help on that topic!')
        Else printtexttopoint(tf);
        HoldScreen;
      Until 0=1
    End;
*)

procedure showuserstats(u:userrec);
var knter:integer;
    tpstr:lstr;
begin
  AnsiCls;
  BoxIt(1,1,79,5);
  PrintXy(3,2,^R'Alias'^A': '^S+U.Handle);
  PrintXy(40,2,^R'Password'^A': '^S);
  If Unum = 1
    Then PrintXy(50,2,U.Password)
    Else PrintXy(50,2,'[Classified]');
  PrintXy(3,3,^R'Phone #'^A': '^S+U.PhoneNum);
  PrintXy(40,3,^R'User Note'^A': '^S+U.SysOpNote);
  PrintXy(3,4,^R'Real Name'^A': '^S+U.RealName);
  PrintXy(40,4,^R'Private Note'^A': '^S+U.PrivateNote);
  BoxIt(6,1,79,5);
  PrintXy(3,7,^R'Level'^A': '^S+Strr(U.Level));
  PrintXy(40,7,^R'Total Calls'^A': '^S+Strr(U.NumOn));
  PrintXy(3,8,^R'Last Call'^A': '^S+DateStr(U.LastOn));
  PrintXy(40,8,^R'Total Posts'^A': '^S+Strr(U.Nbu));
  PrintXy(3,9,^R'Expiration'^A': '^S);
    If (DateStr(U.Expires) = '0/0/80') or (DateStr(U.Expires) = '0/0/128')
      Then Write('Never')
      Else Write(DateStr(U.Expires));
  PrintXy(40,9,^R'Minimum Msg. Length'^A': '^S+Strr(U.MsgLength));
  BoxIt(11,1,79,7);
  PrintXy(3,12,^R'UD Level'^A': '^S+Strr(U.UDLevel));
  PrintXy(40,12,^R'UD Points'^A': '^S+Strr(U.UDPoints));
  printxy(3,13,^R'Uploads'^A': '^S+strr(u.uploads));
  printxy(40,13,^R'Downloads'^A': '^S+strr(u.downloads));
  printxy(3,14,^R'U/L K....'^A': '^S+strr(u.kup));
  printxy(40,14,^R'D/L K....'^A': '^S+strr(u.kdown));
  Printxy(3,15,^R'Required UD Ratio'^A': '^S+strr(u.udfratio)+'%');
  Printxy(40,15,^R'Required K Ratio'^A': '^S+strr(u.udkratio)+'%');
  PrintXy(3,16,^R'Daily K Limit'^A': '^S+Strr(U.DailyKBLimit));
  PrintXy(40,16,^R'K Leeched Today'^A': '^S+Strr(U.KDownToday));
  BoxIt(18,1,79,6);
  PrintXy(3,19,^R'Time Lock'^A': '^S+YesNo(U.TimeLock));
  Printxy(28,19,^R'Deny Chat'^A': '^S+YesNo(No_Chat in U.Config));
  PrintXy(55,19,^R'NET Access'^A': '^S+YesNo(Not (No_Net in U.Config)));
  PrintXy(3,20,^R'Allow UL''s'^A': '^S+YesNo(Not (No_Ul in U.Config)));
  PrintXy(28,20,^R'Allow DL''s'^A': '^S+YesNo(Not (No_Dl in U.Config)));
  PrintXy(55,20,^R'Allow Xfers'^A': '^S+YesNo(Not (No_UdSec in U.Config)));
  PrintXy(3,21,^R'No Posting'^A': '^S+YesNo(No_MsgSec in U.Config));
  PrintXy(28,21,^R'FS Editor'^A': '^S+YesNo(FSEditor in U.Config));
  PrintXy(55,21,^R'Use Bars'^A': '^S+YesNo(UseBars in U.Config));
  PrintXy(3,22,^R'Demons Attack User'^A': '^S+YesNo(U.UseDemons));
  PrintXy(55,22,^R'% of Demon Attacks'^A': '^S+Strr(U.DemonChance)+'%');
  Writeln;
  {HoldScreen;}
end;

Procedure Real_User_Edit(EUNum:Integer);
Type XYStruc = Record
       X,Y,Color : Byte;
       Key,
       Command : Char;
     End;
Var  XY : Array[1..50] of XYStruc;
     Total : Byte;
     WaitX,WaitY : Byte;
     EURec : UserRec;

     Procedure Read_In_Data;
     Var F : Text;
         S : String;
         Temp : SStr;

         Function Get_Next : SStr;
         Begin
           If Pos(',',S) = 0
             Then Get_Next := S
             Else Get_Next := Copy(S,1,Pos(',',S) - 1);
           Delete(S,1,Pos(',',S));
         End;

     Begin
       FillChar(Xy,SizeOf(Xy),0);
       Assign(F,Cfg.TextFileDir + 'USEREDIT.NFO');
       Reset(F);
       Total := 0;
       While Not Eof(F) Do Begin
         S[0] := #0;
         Readln(F,S);
         S := UpString(S);
         If Pos('WAIT_AT = ',S) > 0 Then
           Begin
             Delete(S,1,10);
             While NOT (S[1] IN ['0'..'9']) Do Delete(S,1,1);
             WaitX := Valu(Get_Next);
             WaitY := Valu(Get_Next);
           End Else
         If (S[1] in ['0'..'9']) Then
           Begin
             Inc(Total);
             XY[Total].X := Valu(Get_Next);
             XY[Total].Y := Valu(Get_Next);
             XY[Total].Color := Valu(Get_Next);
             Temp := Get_Next;
             XY[Total].Key := Temp[1];
             Temp := Get_Next;
             Xy[Total].Command := Temp[1];
           End;
       End;
       TextClose(F);
     End;

     Procedure Find(X:Byte);
     Begin
       GoXY(Xy[x].X,Xy[x].Y);
     End;

     Procedure Write_Stuff;
     Var X : Byte;
     Begin
       For X := 1 to Total Do Begin
         AnsiColor(Xy[x].Color);
         Find(X);
         CASE Xy[x].Command OF
           'H' : Write(EURec.Handle);
           'O' : Write(EURec.SysOpNote);
           'L' : Write(Strr(EURec.Level));
           'U' : Write(Strr(EURec.UDLevel));
           'P' : Write(Strr(EURec.UDPoints));
           'N' : Write(EUrec.PhoneNum);
           'R' : Write(EUrec.RealName);
           '#' : Write(Strr(EUrec.Numon));
           '+' : Write(Strr(EUrec.Uploads));
           '-' : Write(Strr(EUrec.Downloads));
           '<' : Write(Strlong(EUrec.KUp));
           '>' : Write(Strlong(EUrec.KDown));
           'M' : Write(Strr(EUrec.Nbu));
           '!' : Write(Strr(EURec.MsgLength));
           '1' : Write(Strr(EURec.UDFratio));
           '2' : Write(Strr(EURec.UDKRatio));
           '3' : Write(Strr(EURec.PCR));
           '4' : Write(Strlong(EUrec.KDownToday));
           '5' : Write(Strr(EURec.DailyKBLimit));
           'D' : Write(YesNo(EURec.UseDemons));
           'T' : Write(YesNo(EUrec.TimeLock));
           '*' : Write(Strr(EURec.TimePerDay));
           '%' : Write(Strr(EURec.DemonChance));
           'C' : Write(YesNo(No_Chat IN EUrec.Config));
           'E' : Write(YesNo(No_Email IN EUrec.Config));
           '=' : Write(YesNo(No_Rumors in EUrec.Config));
           'B' : Write(YesNo(UseBars in EUrec.Config));
           'F' : Write(YesNo(FSEditor IN EURec.Config));
         END;
       End
     End;

     Procedure ShowANSI;
     Begin
       PrintFile(Cfg.TextFileDir + 'USEREDIT.ANS');
       Write_Stuff;
     End;

     Procedure Delete_User;
     var fnt:text; dummystr:mstr;
     begin
       Write(^R^S);
       AnsiCls;
       WriteHdr('User Deletion!');
       DefYes := False;
       Writestr (^R'Delete user "'^A+eurec.handle+^R'"?  !');
       If NOT Yes Then Begin
         ShowANSi;
         Exit;
       End;
       WriteStr(^M^R'Add user to the System Blacklist? !');
       If Yes Then Begin
         Assign(FNT,Cfg.TextFileDir + 'BLACKLST');
         If Exist(Cfg.TextFileDir + 'BLACKLST')
           Then Reset(Fnt)
           Else Rewrite(Fnt);
         Append(Fnt);
         Writeln(fnt,eurec.handle);
         Textclose(fnt);
       End;
       Deleteuser (eunum);
       Seek (ufile,eunum);
       NRead (ufile,eurec);
       Writelog (18,9,'');
       ShowANSi;
     End;

    Procedure Gs(X,Len:Byte; VAR S:AnyStr);
    VAR Str:AnyStr;
    Begin
      Find(X);
      InputBox(Len);
      Str := Inpt;
      If Str>'' then S:=Str;
      AnsiColor(Xy[x].Color);
      Find(X);
      Tab(S,Len);
    End;

    Procedure Gi(X,Len:Byte; VAR S:Integer);
    VAR Str:integer;
    Begin
      Find(X);
      InputBox(Len);
      Str:=Valu(inpt);
      If inpt>'' then S:=Str;
      AnsiColor(Xy[x].Color);
      Find(X);
      If S=0 then Tab('None',Len) Else Tab(Strr(S),Len);
    End;

    Procedure Gli(X,Len:Byte; VAR S:Longint);
    VAR Str:Longint;
    Begin
      Find(X);
      InputBox(Len);
      Str := LongValu(inpt);
      If inpt>'' then S:=Str;
      AnsiColor(Xy[x].Color);
      Find(X);
      Tab(Strlong(S),Len);
    End;

    Procedure Alternate(X : Byte; C:ConfigType);
    Begin
      If C in Eurec.Config then Eurec.Config:=Eurec.Config-[C] Else
        Eurec.Config:=Eurec.Config+[C];
      Find(X);
      Write(YesNo(C in Eurec.Config));
    End;

    Procedure AlternateBoo(X : Byte; VAR B:Boolean);
    Begin
      B := NOT B;
      Find(X);
      Write(YesNo(B));
    End;

    procedure default;
    begin
      eurec.level        := cfg.deflevel;
      eurec.udpoints     := cfg.defudpoints;
      eurec.udlevel      := cfg.defudlevel;
      eurec.udfratio     := cfg.defudratio;
      eurec.udkratio     := cfg.defudkratio;
      eurec.pcr          := cfg.defpcr;
      eurec.msglength    := cfg.defmsglength;
      eurec.dailykblimit := cfg.defdailykblimit;
      eurec.flags        := cfg.defflags;
      If (Cfg.ChangeNote = False) Or (EUrec.SysOpNote = '')
        Then EUrec.SysopNote := Cfg.DefUserNote;
    End;

     Procedure Get_Input;
     Var Done : Boolean;
         K    : Char;
         X    : Byte;

         Function Find_Number(C:Char) : Byte;
         Var X : Byte;
         Begin
           For X := 1 to Total Do
             If Xy[x].Key = C Then
               Begin
                 Find_Number := X;
                 Exit;
               End;
           Find_Number := 0;
         End;

         Procedure View_Forms;
         Begin
           Write(^R^S);
           ANSICLS;
           WriteHdr('View Infoforms');
           Repeat
             WriteStr(^R'View which infoform? ('^S'1-5 or Q'^R'): *');
             Inpt := UpString(Inpt);
             If (Inpt[1] IN ['1'..'5'])
               Then Begin
                 ShowInfoforms(Strr(EUNum),Valu(Inpt[1]));
                 HoldScreen;
               End;
           Until (Inpt = 'Q') OR (HungUpOn);
           ShowANSi;
         End;

     Begin
       Done := False;
       ShowANSi;
       Repeat
         GoXy(WaitX,WaitY);
         K := Upcase(WaitForChar(False));
         if K = '+' then
           begin
             default;
             showansi;
           end;
         X := Find_Number(K);
         If X > 0 Then
           CASE Xy[x].Command OF
             'H' : Begin
                     Gs(X,30,EURec.Handle);
                     Seek(UHFile,EUNum);
                     NWrite(UHFile,EUrec.Handle);
                   End;
             'O' : Gs(x,30,EUrec.SysOpNote);
             'L' : Gi(X,6,EURec.Level);
             'U' : Gi(X,6,EURec.UDLevel);
             'P' : Gi(X,6,EURec.UDPoints);
             'N' : Gs(X,15,EUrec.PhoneNum);
             'R' : Gs(X,30,EUrec.RealName);
             '#' : Gi(X,6,EUrec.Numon);
             '+' : Gi(X,6,EUrec.Uploads);
             '-' : Gi(X,6,EUrec.Downloads);
             '<' : Gli(X,10,EUrec.KUp);
             '>' : Gli(X,10,EUrec.KDown);
             'M' : Gi(X,6,EUrec.Nbu);
             '!' : Gi(X,6,EURec.MsgLength);
             '1' : Gi(X,6,EURec.UDFratio);
             '2' : Gi(X,6,EURec.UDKRatio);
             '3' : Gi(X,6,EURec.PCR);
             '4' : Gli(X,10,EUrec.KDownToday);
             '5' : Gi(X,6,EURec.DailyKBLimit);
             'D' : AlternateBoo(X,EURec.UseDemons);
             'T' : AlternateBoo(X,EUrec.TimeLock);
             '*' : Gi(X,6,EURec.TimePerDay);
        {     '%' : Gi(X,6,EURec.DemonChance); }
             'C' : Alternate(X,No_Chat);
             'E' : Alternate(X,No_Email);
             '=' : Alternate(X,No_Rumors);
             'B' : Alternate(X,UseBars);
             'F' : Alternate(X,FSEditor);
             'I' : View_Forms;
             'K' : Delete_User;
             'X' : Done := True;
           END;
       Until (Done) OR (HungUpOn);
       WriteUFile(EUrec,EUnum);
       Write(^R^S);
       ANSiCLS;
     End;

var i : integer;
Begin
  If Not Exist(Cfg.TextFileDir + 'USEREDIT.NFO') Then
    Begin
      Writeln('USEREDIT.NFO not found.');
      Exit;
    End;
  Seek(UFile,EUNum);
  NRead(UFile,EURec);
  Read_In_Data;
  Get_Input;
End;

procedure edituser (eunum:integer);
var eurec:userrec;
    ca:integer;
    k:char;

  procedure truesysops;
  begin
    writeln ('Sorry, you may not do that without true sysop access!');
    writelog (18,17,'')
  end;

  function truesysop:boolean;
  begin
    truesysop:=ulvl>=cfg.sysoplevel
  end;

  procedure getmstr (t:mstr; var mm);
  var m:mstr absolute mm;
  begin
    writeln (^R'Old '^A,t,^R': '^S,m);
    writestr (^R'New '^A+t+^R'? *');
    if length(inpt)>0 then m:=inpt
  end;

  procedure getsstr (t:mstr; var s:sstr);
  var m:mstr;
  begin
    m:=s;
    getmstr (t,m);
    s:=m
  end;

  procedure getint (t:mstr; var i:integer);
  var m:mstr;
  begin
    m:=strr(i);
    getmstr (t,m);
    i:=valu(m)
  end;

  procedure euwanted;
  begin
    writeln (^R'Wanted status'^A': '^S+yesno(wanted in eurec.config));
    writestr (^R'New wanted status !');
    if yes
      then eurec.config:=eurec.config+[wanted]
      else eurec.config:=eurec.config-[wanted];
    writelog (18,1,yesno(wanted in eurec.config))
  end;

  procedure eudel;
  var fnt:text; dummystr:mstr;
  begin
    Writestr (^R'Delete User: '^A+eurec.handle+^R'?  !');
    If Yes then Begin
      writestr(^M^R'Add user to the System Blacklist? !');
      if yes then begin
        if not exist(Cfg.textfiledir+'Blacklst') then begin
          assign(fnt,Cfg.textfiledir+'Blacklst');
          rewrite(fnt);
          textclose(fnt);
        end;
      assign(fnt,Cfg.textfiledir+'Blacklst');
      append(fnt);
      writeln(fnt,eurec.handle);
      textclose(fnt);
    end;
    deleteuser (eunum);
    seek (ufile,eunum);
    nread (ufile,eurec);
    writelog (18,9,'')
    end
  end;

  procedure euname;
  var m:mstr;
  begin
    m:=eurec.handle;
    getmstr ('Alias',m);
    if not match (m,eurec.handle) then
      if lookupuser (m)<>0 then begin
        writestr (^R'Already exists!  Are you sure? !');
        if not yes then exit
      end;
    eurec.handle:=m;
    writelog (18,6,m)
  end;

  Procedure eurealname;
  var m:mstr;
  begin
    m:=eurec.realname;
    getmstr ('Real Name',m);
    If m>'' then eurec.realname:=m;
  end;

  Procedure euSpecialNote;
  var m:mstr;
  begin
    m:=eurec.PrivateNote;
    getmstr ('Private SysOp Note',m);
    If m>'' then eurec.Privatenote:=m;
  End;

  procedure eupassword;
  begin
    if not truesysop
      then truesysops
      else begin
        getsstr ('Password',eurec.password);
        writelog (18,8,'')
      end
  end;

  procedure mass_change_prompt;
  var x : word;
      u : userrec;
  begin
    writestr(^R'Change prompts to defaults? !');
    if not yes then exit;
    for x := 1 to filesize(ufile) - 1
      do begin
        seek(ufile,x);
        nread(ufile,u);
        u.prompt := strng^.defprompt;
        seek(ufile,x);
        nwrite(ufile,u);
      end
  end;

  procedure eulevel;
  var n:integer;
  begin
    n:=eurec.level;
    getint ('level',n);
    if (n>=cfg.sysoplevel) and (not truesysop)
      then truesysops
      else begin
        eurec.level:=n;
        writelog (18,15,strr(n))
      end
  end;

  procedure eutimelimit;
  var n:integer;
  begin
    n:=eurec.timetoday;
    getint('Time Limit',n);
    eurec.timetoday:=n;
  end;

  procedure eudratio;
  var n:integer;
  begin
    n:=eurec.udfratio;
    getint('Upload/Download Ratio',n);
    eurec.udfratio:=n;
  end;

  procedure eudkratio;
  var n:integer;
  begin
    n:=eurec.udkratio;
    getint('Upload/Download K Ratio',n);
    eurec.udkratio:=n;
  end;

  procedure epcratio;
  var n:integer;
  begin
    n:=eurec.pcr;
    getint('Post/Call Ratio',n);
    eurec.pcr:=n;
  end;

  procedure euusernote;
  var m:mstr;
      p:integer;
  begin
    m:=eurec.sysopnote;
    getmstr('User Note',m);
    eurec.sysopnote:=m;
  end;

  procedure euphone;
  var m:mstr;
      p:integer;
  begin
    m:=eurec.phonenum;
    buflen:=15;
    getmstr ('Phone #',m);
    p:=1;
    while p<=length(m) do
      if (m[p] in ['+','0'..'9'])
        then inc(p)
        else delete (m,p,1);
    if length(m)>7 then begin
      eurec.phonenum:=m;
      writelog (18,16,m)
    end
  end;

  procedure boardflags;
  var quit:boolean;
      N:NewScanRec;

    procedure listflags;
    var bd:boardrec;
        cnt:integer;
    begin
      GetScanRec(n,msgconf);
      seek (bdfile,0);
      for cnt:=0 to filesize(bdfile)-1 do begin
        nread (bdfile,bd);
        tab (bd.shortname,9);
        tab (bd.boardname,30);
        writeln (accessstr[getuseraccflag (n,cnt)]);
        if break then exit
      end
    end;

    procedure changeflag;
    var bn,q:integer;
        bname:mstr;
        ac:accesstype;
    begin
      buflen:=8;
      writestr (^P'Board to change access'^O': *');
      bname:=inpt;
      bn:=searchboard(inpt);
      if bn=-1 then begin
        writeln ('Not found!');
        exit
      end;
      writeln (^B^M^P'Current access: '^S,
               accessstr[getuseraccflag (n,bn)]);
      getacflag (ac,inpt);
      if ac=invalid then exit;
      setuseraccflag (n,bn,ac);
      case ac of
        letin:q:=2;
        keepout:q:=3;
        bylevel:q:=4
      end;
      writelog (18,q,bname)
    end;

    procedure allflags;
    var ac:accesstype;
    begin
      GetScanRec(N,msgconf);
      writehdr ('Set all board access flags');
      getacflag (ac,inpt);
      if ac=invalid then exit;
      writestr ('Are you sure? !');
      if not yes then exit;
      setalluserflags (n,ac);
      writelog (18,5,accessstr[ac])
    end;

  Var Wo:Word;
  begin
    opentempbdfile;
    GetScanRec(N,MsgConf);
    quit:=false;
    repeat
      repeat
        writestr (^M'L)ist flags, C)hange one flag, A)ll flags, or Q)uit: *');
        if hungupon then exit
      until length(inpt)<>0;
      case upcase(inpt[1]) of
        'L':listflags;
        'C':changeflag;
        'A':allflags;
        'Q':quit:=true
      end
    until quit;
    closetempbdfile;
    WriteScanRec(N,MsgConf)
  end;

  procedure defualt;
  begin
    eurec.level        := cfg.deflevel;
    eurec.udpoints     := cfg.defudpoints;
    eurec.udlevel      := cfg.defudlevel;
    eurec.udfratio     := cfg.defudratio;
    eurec.udkratio     := cfg.defudkratio;
    eurec.pcr          := cfg.defpcr;
    eurec.msglength    := cfg.defmsglength;
    eurec.dailykblimit := cfg.defdailykblimit;
    eurec.flags        := cfg.defflags;
    If (Cfg.ChangeNote = False) Or (EUrec.SysOpNote = '')
      Then EUrec.SysopNote := Cfg.DefUserNote;
  End;

  (*

  procedure specialsysop;

    procedure getsysop (c:configtype);
    begin
      writeln ('Section ',sectionnames[c],': '^S,
               sysopstr[c in eurec.config]);
      DefYes := False;
      writestr ('Grant sysop access? !');
      if length(inpt)<>0
        then if yes
          then
            begin
              eurec.config:=eurec.config+[c];
              writelog (18,10,sectionnames[c])
            end
          else
            begin
              eurec.config:=eurec.config-[c];
              writelog (18,11,sectionnames[c])
            end
    end;

  begin
    if not truesysop then begin
      truesysops;
      exit
    end;
    writestr
('Change M)ain, F)ile, B)ulletin, V)oting, E)mail, D)atabase, P)Doors: *');
    if length(inpt)=0 then exit;
    case upcase(inpt[1]) of
      'M':getsysop (mainsysop);
      'F':getsysop (udsysop);
      'B':getsysop (bulletinsysop);
      'V':getsysop (votingsysop);
      'E':getsysop (emailsysop);
      'D':getsysop (databasesysop);
      'P':getsysop (doorssysop)
    end
  end;

  *)

  procedure getlogint (prompt:mstr; var i:integer; ln:integer);
  begin
    getint (prompt,i);
    if ln > 0 Then
      writelog (18,ln,strr(i))
  end;

var q:integer;
   tmp:integer;
begin
  If (Unum > 1) And (EUnum = Unum) And (Local = False) Then Begin
    Writeln('Sorry, you are not allowed to edit yourself!');
    Exit;
  End;
  writeurec;
  seek (ufile,eunum);
  read (ufile,eurec);
  If (Unum > 1) And (Local = False)
  Then If (EURec.Level > Urec.Level) or (EUnum = 1)
  Then Begin
    Writeln(^R'Sorry, you can''t edit users with higher levels then you!');
    Exit;
  End;
  WriteLog (2,3,eurec.handle);
{  WriteStr(^R'Use '^A'ViSiON/2 '^R'SysOp Full Screen User Editor? !');
  If inpt='' then inpt:='Y';
  If yes then Begin }
     real_user_edit(eunum);
 {    writeufile (eurec,eunum);
     readurec; }
     exit;
(*  end;
  repeat
    q:=menu('Editing: '+EuRec.Handle,'UEDIT','SDHPLOEWTBQYNIA+CXGF!$^&J|=-)');
    case q of
  {S} 1:showuserstats(eurec);
  {D} 2:eudel;
  {H} 3:euname;
  {P} 4:eupassword;
  {L} 5:eulevel;
  {O} 6:getlogint ('U/D Points',eurec.udpoints,7);
  {E} 7:getlogint ('U/D Level',eurec.udlevel,14);
  {W} 8:euwanted;
  {T} 9:getlogint ('Time For Today',eurec.timetoday,12);
  {B} 10:boardflags;
  {Y} 12:;{ specialsysop; }
  {N} 13:euphone;
  {I} 14:begin
          writestr(^M^R'Which infoform to view ['^A'1-5'^R'] ['^A'1'^R']: *');
          if inpt='' then inpt:='1';
          tmp:=valu(inpt);
          if (tmp>0) and (tmp<6) then Begin
           showinfoforms(strr(eunum),tmp);
           HoldScreen;
          end;
         End;
  {A} 15:euusernote;
  {+} 16:begin
          writestr (^R'Set Account to user defaults? !');
          if yes then begin
            defualt;
          end;
        end;
  {X} 18:begin
           if (datestr(eurec.expires)='0/0/128') or (DateStr(Eurec.Expires)='0/0/80')
             then writeln(^M^P'User''s Account Does Not Expire!')
             else writeln(^M^P'Users current Expiration date is '^R,datestr(eurec.expires));
             writestr(^M'Enter new expiration date, 00/00/80 for no expiration [mm/dd/yy]:');
             eurec.expires:=dateval(inpt);
         end;
  {F} 20:Begin
           Write(^R'User Flags '^A'['^S'Space/Quits'^A']: ');
           GetFlag(EUrec.Flags);
         End;
  {!} 21:eudratio;
  { } 22:eudkratio;
  {^} 23:epcratio;
  {&} 24:eutimelimit;
     {25:AddToNuv(Eurec.Handle);}
  {<} 27:Begin
         WriteStr(^R'Chance Of Demon Attacks'^A': *');
         If Valu(Inpt) < 101
           Then EUrec.demonchance := Valu(Inpt);
        end;
  {>} 28:GetBoo('Demon Attacks',eurec.usedemons);
      29:mass_change_prompt;
     end
  until hungupon or (q=11);
  writeufile (eurec,eunum);
  readurec
  *)
end;

procedure PrintNews(W:Byte; NewScan:Boolean); {0 - All} {Written 08/17/92}
var nfile:file of newsrec;
    ntemp:newsrec;
    cnt:integer;
    show:boolean;

    Procedure NewsHeader;
    Begin
      Sr.C[1] := '|T'; Sr.S[1] := NTemp.Title;
      Sr.C[2] := '|#'; Sr.S[2] := Strr(Cnt);
      Sr.C[3] := '|F'; Sr.S[3] := NTemp.From;
      Sr.C[4] := '|D'; Sr.S[4] := DateStr(NTemp.When);
      Sr.C[5] := '|W'; Sr.S[5] := TimeStr(NTemp.When);
      Sr.C[6] := '|L'; Sr.S[6] := Strr(NTemp.Level);
      Sr.C[7] := '|M'; Sr.S[7] := Strr(NTemp.MaxLevel);
      DataFile(Cfg.TextFileDir+'NEWSHDR.ANS');
    End;

begin
  Assign(nfile,Cfg.DATADIR+'News');
  Reset(nfile);
  if ioresult <> 0
    Then exit;
  if filesize(nfile)=0 then begin
    close(nfile);
    exit;
  end;
  cnt:=0;
  While not(eof(nfile) or break or hungupon) do begin
    If W > 0 then
      Seek(NFile,W-1);
    NRead(nfile,ntemp);
    Inc(cnt);
    If IsSysop or (ntemp.location>=0) and (ntemp.maxlevel>=urec.level) and (urec.level>=ntemp.level) then
    begin
     show:=false;
       if (ntemp.when>=laston) or (Ntemp.Always) or (Not NewScan)
       then show:=true;
       if show then
       begin
         NewsHeader;
         writeln;
         printtext('NEWS.TXT','NEWS.MAP',NTemp.Location);
         HoldScreen;
       end;
       If W>0 then Begin
         Close(Nfile);
         Exit;
        End;
     End;
  end;
  close(nfile);
end;

function getlastcaller:lstr;
var qf:file of lastrec;
    l:lastrec;
begin
  getlastcaller:='';
  assign (qf,Cfg.DATADIR+'Callers');
  reset (qf);
  if ioresult=0 then
    if filesize(qf)>0
      then
        begin
          seek (qf,0);
          nread (qf,l);
          getlastcaller:=l.name;
        end;
  close (qf)
end;

Procedure showlastcallers;
Var QF : File of LastRec;
    Cnt, A : Integer;
    L : Lastrec;
Begin
  Assign (qf,Cfg.DATADIR+'CALLERS');
  Reset (qf);
  If IoResult = 0 Then Begin

    ClearBreak;
    CheckPageLength := True;

    ListingFile(Cfg.TextFileDir + 'LASTCALL.TOP',True);

    For Cnt := 0 To FileSize (QF) - 1 Do
      If Not Break Then Begin
        NRead(Qf,L);

        Sr.C[1] := 'NU'; Sr.S[1] := Strr(Cnt + 1);   Sr.T[1] := 2;
        Sr.C[2] := 'UN'; Sr.S[2] := L.Name;          Sr.T[2] := 28;
        Sr.C[3] := 'AC'; Sr.S[3] := L.AC;            Sr.T[3] := 3;
        Sr.C[4] := 'CA'; Sr.S[4] := Strr(L.CallNum); Sr.T[4] := 4;
        Sr.C[5] := 'DA'; Sr.S[5] := DateStr(L.When); Sr.T[5] := 9;
        Sr.C[6] := 'TI'; Sr.S[6] := TimeStr(L.When); Sr.T[6] := 9;
        Sr.C[7] := 'MO'; Sr.S[7] := Strr(L.MinsOn);  Sr.T[7] := 3;
        Sr.C[8] := 'BA'; Sr.S[8] := L.Baud;          Sr.T[8] := 20;

        ListingFile(Cfg.TextFileDir + 'LASTCALL.MID',False);
      End;
  End;

  ListingFile(Cfg.TextFileDir + 'LASTCALL.BOT',False);

  Writelog(0,0,'Viewed Recent Callers');
  Close (QF)
end;

procedure infoform(a:byte);
var ff:text;
    fn:lstr;
    k:char;
    me:message;
    b:Sstr;
begin
  writeln;
  fn:=Cfg.textfiledir+'InfoForm.'+strr(a);
  if not exist (fn) then begin
    writeln ('There isn''t an information #'+strr(a)+' form right now.');
    if issysop then
      writeln ('Sysop: To make an information form, create a text file',
             ^M'called ',fn,'.  Use * to indicate a pause for user inpt.');
    exit
  end;
  if urec.infoform[a]<>-1 then begin
    writestr ('You have already filled out form #'+Strr(A)+'!  Replace it? !');
    if not yes then exit;
    deletetext ('FORMS.TXT','FORMS.MAP',Urec.infoform[a]);
    urec.infoform[a]:=-1;
    writeurec
  end;
  assign (ff,fn);
  reset (ff);
  me.numlines:=1;
  me.title:='';
  me.anon:=false;
  me.text[1]:='Filled out on: '+datestr(now)+' at '+timestr(now);
  while not eof(ff) do begin
    nobreak:=True;
    if hungupon then begin
      textclose (ff);
      exit
    end;
    read (ff,k);
    if k='*' then begin
      nochain:=true;
      getstr(False);
      me.numlines:=me.numlines+1;
      me.text[me.numlines]:=inpt;
    End Else If K='|' then Begin
      Read(FF,K);
      IF K='B' then Begin
        B[0]:=Chr(0);
        Repeat
         Read(ff,K);
         B:=B+K;
        Until K=';';
        B[0]:=Pred(B[0]);
        If (Valu(B)>=1) And (Valu(B)<81) Then Buflen:=Valu(B);
      End Else Write('|'+K);
    End Else writechar(k)
  end;
  textclose (ff);
  urec.infoform[a]:=maketext ('FORMS.TXT','FORMS.MAP',Me,'');
  writeurec;
  Write(^S);
  AnsiCls
end;

 (*

procedure openusfile;
const newusers:userspecsrec=(name:'New users';minlevel:1;maxlevel:1;
         minlaston:-maxint;maxlaston:maxint;minpcr:-maxint;maxpcr:maxint);
begin
  assign (usfile,Cfg.DATADIR+'USERSPEC');
  reset (usfile);
  if ioresult<>0 then begin
    rewrite (usfile);
    if cfg.level2nd<>0 then newusers.maxlevel:=cfg.level2nd;
    nwrite (usfile,newusers)
  end
end;

procedure editspecs (var us:userspecsrec);

  procedure get (tex:string; var value:integer; min:boolean);
  var vstr:sstr;
  begin
    buflen:=6;
    if abs(value)=maxint then vstr:='None' else vstr:=strr(value);
    writestr (^S+tex+' '^O'['^P+vstr+^O']: *');
    if inpt[0]<>#0
      then if upcase(inpt[1])='N'
        then if min
          then value:=-maxint
          else value:=maxint
        else value:=valu(inpt)
  end;

  procedure getreal (tex:string; var value:real; min:boolean);
  var vstr:sstr;
      s:integer;
  begin
    buflen:=10;
    if abs(value)=maxint then vstr:='None' else vstr:=streal(value);
    writestr (^S+tex+^O' ['^P+vstr+^O']: *');
    if length(inpt)<>0
      then if upcase(inpt[1])='N'
        then if min
          then value:=-maxint
          else value:=maxint
        else begin
          val (inpt,value,s);
          if s<>0 then value:=0
        end
  end;

begin
  writeln (^B^M^S'Enter specifications; N for none.');
  Writeln (^R'A Specifaction Set can be used when listing users, If a user doesn''t fit');
  Writeln('within any of the set specifications then he will not be listed.'^M);
  buflen:=30;
  writestr (^R'Specification set name '^O'['^P+us.name+^O']: *');
  if length(inpt)<>0
    then if match(inpt,'N')
      then us.name:='Unnamed'
      else us.name:=inpt;
  get ('Lowest level',us.minlevel,true);
  get ('Highest level',us.maxlevel,true);
  get ('Lowest #days since last call',us.minlaston,true);
  get ('Highest #days since last call',us.maxlaston,true);
  getreal ('Lowest post to call ratio',us.minpcr,true);
  getreal ('Highest post to call ratio',us.maxpcr,true)
end;

function getspecs (var us:userspecsrec):integer; { -1:not saved   >0:in file }
begin
  with us do begin
    name:='Unnamed';                     { Assumes USFILE is open !! }
    minlevel:=-maxint;
    maxlevel:=maxint;
    minlaston:=-maxint;
    maxlaston:=maxint;
    minpcr:=-maxint;
    maxpcr:=maxint
  end;
  editspecs (us);
  writestr (^M^P'Save these specs to disk? !');
  if yes then begin
    seek (usfile,filesize(usfile));
    nwrite (usfile,us);
    getspecs:=filesize(usfile)
  end else getspecs:=-1
end;

function searchspecs (var us:userspecsrec; name:mstr):integer;
var v,pos:integer;
begin
  v:=valu(name);
  seek (usfile,0);
  pos:=1;
  while not eof(usfile) do begin
    read (usfile,us);
    if match(us.name,name) or (valu(name)=pos) then begin
      searchspecs:=pos;
      exit
    end;
    pos:=pos+1
  end;
  searchspecs:=0;
  writeln(^M'Not found!')
end;

procedure listspecs;
var us:userspecsrec;
    pos:integer;

  procedure writeval (n:integer);
  begin
    if abs(n)=maxint then write ('   None') else write(n:7)
  end;

  procedure writevalreal (n:real);
  begin
    if abs(n)=maxint then write ('   None') else write(n:7:2)
  end;

begin
  writehdr ('User Specification Sets');
  seek (usfile,0);
  pos:=0;
  Header('#    Specification Set Name             Level    Last Call    PCR        ');
  while not (break or eof(usfile)) do begin
    pos:=pos+1;
    nread (usfile,us);
    Write(^A);
    write (pos:3,'. ');
    tab (^S+us.name+^A,30);
    writeval (us.minlevel);
    writeval (us.maxlevel);
    Write(^R);
    writeval (us.minlaston);
    writeval (us.maxlaston);
    Write(^P);
    writevalreal (us.minpcr);
    writevalreal (us.maxpcr);
    writeln
  end
end;

function selectaspec (var us:userspecsrec):integer; {  0 = none         }
var done:boolean;                                   { -1 = not in file  }
    pos:integer;                                    { -2 = added to end }
begin
  selectaspec:=0;
  openusfile;
  if filesize(usfile)=0
    then selectaspec:=getspecs(us)
    else
      repeat
        if hungupon then exit;
        done:=false;
        writestr (^M^S'Specification set name '^A'A'^R'dd '^A'?'^R'/List:*');
        if length(inpt)=0
          then done:=true
          else if match(inpt,'A')
            then
              begin
                pos:=getspecs(us);
                if pos>0
                  then selectaspec:=-2
                  else selectaspec:=-1;
                done:=true
              end
            else if match(inpt,'?')
              then listspecs
              else
                begin
                  pos:=searchspecs (us,inpt);
                  done:=pos<>0;
                  selectaspec:=pos
                end
      until done;
  close (usfile)
end;

function selectspecs (var us:userspecsrec):boolean;
var dummy:integer;
begin
  dummy:=selectaspec (us);
  selectspecs:=dummy=0
end;

procedure deletespecs (pos:integer);
var cnt:integer;
    us:userspecsrec;
begin
  openusfile;
  for cnt:=pos to filesize(usfile)-1 do begin
    seek (usfile,cnt);
    nread (usfile,us);
    seek (usfile,cnt-1);
    nwrite (usfile,us)
  end;
  seek (usfile,filesize(usfile)-1);
  truncate (usfile);
  close (usfile)
end;

procedure editoldspecs;
var pos:integer;
    us:userspecsrec;
begin
  repeat
    pos:=selectaspec (us);
    if pos>0 then begin
      buflen:=1;
      writestr (^M^O'['^P'E'^O'] '^R'Edit or '^O'['^P'D'^O'] '^R'Delete? *');
      if length(inpt)=1 then case upcase(inpt[1]) of
        'E':begin
              editspecs (us);
              openusfile;
              seek (usfile,pos-1);
              write (usfile,us);
              close (usfile)
            end;
        'D':deletespecs (pos)
      end
    end
  until (pos=0) or hungupon
end;

*)

Procedure Notice(N:Mstr; Str:Lstr);
VAR F:Text;
    C1,C3,C8,C9,C11,C15:Sstr;
    Check:String;
    Num:Integer;

    Procedure CreateFile;
    Begin
      Assign(F,Cfg.DataDir+'NOTICE.'+Strr(Num));
      Rewrite(F);
      Writeln(F,N);
      Writeln(F,C1+'ÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ[ '+C9+'ViSiON/2 Quick User Notifiation '+C1+']ÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ');
      Writeln(F,C1+'ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ');
      Writeln(F,' ');
      TextClose(F);
    End;

Begin
  C1:=#27+'[0;34m';
  C9:=#27+'[1;34m';
  C11:=#27+'[1;36m';
  C3:=#27+'[0;36m';
  C8:=#27+'[1;30m';
  C15:=#27+'[1;37m';
  Num:=LookUpUser(N);
  If Num<=0 then Exit;
  If NOT Exist(Cfg.DataDir+'NOTICE.'+Strr(Num)) Then
   CreateFile;
  Assign(F,Cfg.DataDir+'NOTICE.'+Strr(Num));
  Reset(F);
  Append(F);
  Writeln(F,C8+'['+C15+DateStr(Now)+' '+TimeStr(Now)+C8+'] '+C9+Str);
  TextClose(F);
End;

    Function validphone(showstuff:Boolean):boolean;
    var p:integer; a,b:byte;
        k:char;
    begin
      validphone:=false;
      If inpt[1]='+' then Begin
        ValidPhone:=True;
        Exit;
      End;
      p:=1;
      while P <= Length(Inpt) do begin
        k:=inpt[p];
        if k in ['0'..'9']
          then inc(p)
          else delete (inpt,p,1);
      end;
      if length(inpt)<>10 then begin
        A:=0;
        If length(inpt)<3 then a:=2 Else
        If length(inpt)<7 then a:=1;
        If ShowStuff then Begin
          { While WhereX > 1 Do Write(^H); }
          writeln ('Must be 10 Chars!       ');
          Delay(500);
        End;
        exit
      end;
      if (inpt[2] in ['2'..'9']) or (inpt[1] in ['0','1'])
         or (inpt[4] in ['0','1']) then begin
         If ShowStuff Then Begin
           { While WhereX > 1 Do Write(^H); }
           writeln ('Invalid!                ');
           Delay(500);
         End;
           exit
         end;
      validphone:=true
    end;

    Procedure GetPhoneNum;
    Begin
      WriteStr(Strng^.Enter_Number);
    End;

(*  Procedure GetPhoneNum;
    Var K:Char;
        i:Byte;
        S:sstr;
        fwd,bwd:Boolean;
    Begin
      Write(^P'Home Phone '^O': '^S'xxx-xxx-xxxx');
      Write(B_(12));
      S:='';
      fwd:=true;
      bwd:=false;
      i:=1;
      Repeat
      K:=WaitForChar(true);
       Case Upcase(K) of
         'X':If i<2 then Begin
               Write(Direct,#27+'[K');
               InputBox(20);
               Exit;
             End;
         '0'..'9':If i<11 then Begin
                   If ((i=4) or (i=7)) and (not (bwd)) then Write('-');
                   Write(K);
                   S:=S+K;
                   inc(i);
                   bwd:=false;
                   fwd:=true;
                  End;
         #8:If i>1 then Begin
             If ((i=7) or (i=4)) and (not (fwd)) then Write(B_(1));
             Write(^H+'x'+B_(1));
             S[0]:=chr(length(s)-1);
             Dec(i);
             fwd:=false; bwd:=true;
            End;
         End;
       Until (K=#13) or (hungupon);
       inpt:=S;
      End;
*)

Begin
  QPtr := NIL;
End.
