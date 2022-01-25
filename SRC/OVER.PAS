{$R-,S-,I-,D-,F-,V-,B-,N-,L+,O+}

Unit Over;  { New Overlay Unit }

Interface

Uses MNeT,Crt,DosMem,PAvt0,Windows,Gentypes,Modem,Configrt,Gensubs,
     Subs1,subs2,userret,textret,flags,mainr1;

Procedure Boxit(a,b,c,d:integer); { a = starting y pos. }
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
End;

Procedure ViewTopTen(Which:Byte);
Type HighestPCR=record
        Name:mstr;
        PCR:longint;
     end;

    Tp=Array[1..10] of HighestPCR;

Var I:Byte;
    TopTen:File of Tp;
    TT:Tp;
    B:Boolean;

    Procedure ReadTopTen(What:Byte);
    Begin
      FillChar(Tt,SizeOf(tt),0);
      Assign(TopTen,Cfg.DataDir+'TOPTEN.DAT');
      Reset(Topten);
      Seek(Topten,What-1);
      nRead(TopTen,Tt);
      Close(TopTen)
    End;

    Procedure ShowSomething(T:Byte; ToSay,Header:Mstr);
    Var Cnt,R:Integer;

     Procedure ShowStats;
     Var F : Text;
         K : Char;
         C : String[2];
         Save : Byte;
     Begin
       Assign(F,Cfg.TextFileDir+'TOPTEN'+Strr(T)+'.ANS');
       Reset(F);
       If IoResult<>0 Then Begin
         TextClose(F);
         Exit;
       End;
       While Not(Eof(F)) Or (HungUpOn) Do Begin
         Read(F,K);
         Save:=0;
         If K='|' Then Begin
           Read(F,K);
           Case Upcase(K) Of
           '^':Begin
                C[0]:=#0;
                Save:=0;
                Repeat
                  Read(F,K);
                  If K in ['0'..'9'] Then C:=C+K;
                  Inc(Save);
                Until (Save>2) or (K=';');
                Save:=Valu(C);
                If (Save>0) and (Save<15) Then
                 ReadTopTen(Save);
               End;
           'U':Write(Direct,Urec.Handle);
           'T':Write(Direct,TimeStr(Now));
           'D':Write(Direct,DateStr(Now));
           'N':Begin
                 Read(F,K);
                 If (K='0') or ((Valu(K)>0) and (Valu(K)<10)) Then
                 Write(Direct,TT[Valu(K)+1].Name);
               End;
           'B':Begin
                 Read(F,K);
                 If (K='0') or ((Valu(K)>0) And (Valu(K)<10)) Then
                 PercentBar(Strlong(TT[1].PCR),Strlong(Tt[Valu(K)+1].Pcr));
               End;
           'V':Begin
                 Read(F,K);
                 If (K='0') or ((Valu(K)>0) And (Valu(K)<10)) Then
                 Write(Direct,Strlong(TT[Valu(K)+1].PCR));
               End;
           End;
         End Else Write(Direct,K);
         If ( (Online) And (NumChars>0) ) or (KeyHit) and (In_Command=False) Then Begin
           Break := True;
           TextClose(F);
           Exit;
         End;
       End;
       TextClose(F);
     End;

     Procedure Normal;
     Var X, A : Byte;
     Begin
       ListingFile(Cfg.TextFileDir + 'TOPFIVE.' + Strr(T) + 'T',True);

       A := Length( Strlong(TT[1].Pcr) );

       For X := 1 to 5 Do Begin
          LineCount := 1;
          Sr.C[1] := 'NU'; Sr.S[1] := Strr(X); Sr.T[1] := 1;
          Sr.C[2] := 'NA'; Sr.S[2] := Tt[X].Name; Sr.T[2] := 30;
          Sr.C[3] := 'VA'; Sr.S[3] := Strlong(TT[x].Pcr); Sr.T[3] := A;
          ListingFile(Cfg.TextFileDir + 'TOPFIVE.' + Strr(T) + 'M',False);
       End;

       ListingFile(Cfg.TextFileDir + 'TOPFIVE.' + Strr(T) + 'B',False);
     End;

     Procedure Box;
     Var Cnt:Byte;
     Begin
       Write(^O'ÚÄÄ');            {Â 194} {Ã 197} {Æ 198}
       Write(^P+' '+Header+' '^O);
       For Cnt:=1 to 70-Length(Header) Do Write(Direct,'Ä');
       Writeln('Ä¿');               {192;191;217;218}
       For Cnt:=1 to 5 Do
         Begin
           If Break Then Exit;
           Write(^O'³ ');
           TabUl(Tt[Cnt].Name+' ',28);
           AnsiColor(Urec.Color6);
           Tab(' '+Strlong(Tt[Cnt].PCR)+ToSay,10);
           PercentBar(Strlong(Tt[1].PCR),Strlong(Tt[Cnt].PCR));
           If WhereX<>77 Then Goxy(77,WhereY);
           Writeln(^O'³');
           If Break Then Exit;
         End;
       Write(^O'À');
       For Cnt:=1 to 75 Do Write(Direct,'Ä');
       Write('Ù');
       Writeln(^M);
     End;

     Procedure ShadowBox;
     Var Cnt:Byte;
     Begin
       Write(^O'ÚÂÄÄ');            {Â 194} {Ã 197} {Æ 198}
       Write(^P+' '+Header+' '^O);
       For Cnt:=1 to 70-Length(Header) Do Write(Direct,'Ä');
       Writeln('Â¿');               {192;191;217;218}
       Write('³Æ');
       For Cnt:=1 to 74 Do Write(Direct,'Í');
       Write('µ³');
       AnsiColor(8);
       Writeln('Û');
       For Cnt:=1 to 5 Do
         Begin
           If Break Then Exit;
           Write(^O'³³ ');
           TabUl(Tt[Cnt].Name+' ',28);
           AnsiColor(Urec.Color6);
           Tab(' '+Strlong(Tt[Cnt].PCR)+ToSay,10);
           PercentBar(Strlong(Tt[1].PCR),Strlong(Tt[Cnt].PCR));
           If WhereX<>77 Then Goxy(77,WhereY);
           Write(^O'³³');
           AnsiColor(8);
           Writeln('Û');
           If Break Then Exit;
         End;
       Write(^O'ÀÁ');
       For Cnt:=1 to 74 Do Write(Direct,'Ä');
       Write('ÁÙ');
       AnsiColor(8);
       Writeln('Û');
       Write('  ');
       For Cnt:=1 to 77 Do Write('ß');
       Writeln(^M);
     End;

     Begin
       ReadTopTen(T);
       Case Cfg.DefTopFive Of
         0:ShowStats;
         1:Normal;
         2:Box;
         3:ShadowBox;
       End;
     End;

Begin
    AnsiCls;
    Break:=False;
    If Which=1 then Begin
      ShowSomething(1,' Posts','Top Five Posters');
      ShowSomething(2,' %','Top Five Post/Call Ratios');
      End Else
    If which=2 then Begin
      ShowSomething(3,' Posts','Five Lowest Posters');
      ShowSomething(4,' %','Five Lowest PCR');
    End Else
    If Which=3 then Begin
      ShowSomething(5,' UL''s','Top Five Uploaders');
      ShowSomething(6, ' K','Top Five Uploaded K');
    End Else
    If Which=4 then Begin
      ShowSomething(7,' UL''s','Lowest Five Uploaders');
      ShowSomething(8, ' K','Lowest Five Uploaders K');
    End Else
    If Which=5 then Begin
      ShowSomething(9,' DL''s','Top Five Downloaders');
      ShowSomething(10,' K','Top Five Downloaders K');
    End Else
    If Which=6 then Begin
      ShowSomething(11,' DL''s','Lowest Five Downloaders');
      ShowSomething(12,' K','Lowest Five Downloaders K');
    End Else
    If Which=7 then Begin
      ShowSomething(13,' Calls','Top Five Callers');
      ShowSomething(14,' Calls','Lowest Five Callers');
    End;
    HoldScreen;
End;

Procedure ViewWhich;
VAR K:Char;
    i:Byte;
Begin
  Repeat
  NoBreak:=True;
  WriteHdr('High/Low Statistics');
  AnsiReset;
  Writeln(^O'['^P'1'^O'] '^S'Top Posters/PCR');
  Writeln(^O'['^P'2'^O'] '^S'Lowest Posters/PCR');
  Writeln(^O'['^P'3'^O'] '^S'Top Uploaders/K');
  Writeln(^O'['^P'4'^O'] '^S'Lowest Uploaders/K');
  Writeln(^O'['^P'5'^O'] '^S'Top Downloaders/K');
  Writeln(^O'['^P'6'^O'] '^S'Lowest Downloaders/K');
  Writeln(^O'['^P'7'^O'] '^S'Top Callers/Lowest Callers');
  Writeln;
  ClearChain;
  WriteStr(^O'['^P'#'^O'] '^R'Any '^A'A'^R'll '^A'Q'^R'uit :&');
  If inpt='' then inpt:='Q';
   K:=Upcase(inpt[1]);
   If (Valu(k)>0) and (valu(k)<8) then ViewTopTen(Valu(k)) Else
   If K='A' then For i:=1 to 7 do ViewTopTen(i) Else
{   If K='U' then Begin
     Writeln(^P'One Moment.. Calculating');
     MakeTopTen;
     End;
}
  If K='' then K:='Q';
  Until (K='Q') or (HungUpOn);
  NoBreak:=False;
End;

Procedure QuoteMessage(M:Integer);  {Quoting Stuff; Written July 16 92}
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
    QPtr^.Text[1] := QuoteLine(Strng.QuoteTop);
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
    QPtr^.Text[A] := QuoteLine(Strng.QuoteBottom);
    QPtr^.Numlines := A;
  End;

Label Exit;
Var W : Word;
Begin

  If Quoting.MsgSec = True Then Begin

    If M > FileSize(bfile) then Begin
      Writeln(^G^S'Message out of range!');
      Delay(500);
      Goto Exit;
    End;

    GetBrec(M);
    ReLoadText(Quoting.TxtFile,Quoting.MailFile,B.Line,Me);

    If Me.Numlines<1 Then Begin
      Writeln('Error reading message!');
      Delay(500);
      Goto Exit;
    End;

    Quoting.Title := B.Title;
    Quoting.From  := B.LeftBy;
    Quoting.SendTo:= B.SentTo;
    Quoting.When  := B.When;
    Quoting.Anon  := B.Anon;

  End Else Begin

    ReloadText(Quoting.TxtFile,Quoting.MailFile,Quoting.MsgNum,Me);

  End;

  Dos_GetMem (QPtr,SizeOf(Qptr^));
  FillChar(Qptr^,SizeOf(Qptr^),0);

  Writeln(^M^M^O'ù '^R'You are Quoting "'^A+quoting.title+^R'" by '+^A+
          +quoting.from+^O' ù'^M);
  A := 1;

  For i:=1 to Me.Numlines Do Begin
    Write(^R+strr(A)+^A': '^S);
    If Length(Me.Text[i]) > 75
      Then Me.Text[i][0] := #75;
    MultiColor(me.text[i]);
    Writeln;
    Inc(A);
  End;

  Writeln;
  Repeat
    WriteStr(^R'Quoting Selection'^R' - '^A'A'^R'll '^A'S'^R'ome '^A'Q'^R'uit :*');
    k:=Upcase(inpt[1]);
  Until K in ['A','S','Q'];

  Case K of
    'Q':Begin
          QPtr^.Text[1][0]:=#0;
          Goto Exit;
        End;
    'A':Begin
          Quote(1,Me.Numlines);
        End;
    'S':Begin

          Repeat
            WriteStr(^P'Start Quoting At Line ('^S'1..'+strr(me.numlines)+^P') '^A'Q'^R'uit :*');
            A:=Valu(inpt);
            If (A>0) and (A<=me.numlines)
              Then Start:=A
              Else If Upcase(inpt[1])='Q' then Begin
                QPtr^.Text[1][0]:=#0;
                Goto Exit;
              End;
          Until (A>0) and (A<=me.numlines);

          Repeat
            WriteStr(^P'End Quoting At Line ('^S+strr(A)+'..'+strr(me.numlines)+^P') '^A'Q'^R'uit :*');
            A := Valu(inpt);
            If (A>=Start) and (A<=me.numlines)
              Then Finish:=A
              Else If Upcase(inpt[1]) = 'Q' then Begin
                QPtr^.Text[1][0] := #0;
                Goto exit;
              End;
          Until (A>=start) and (A<=me.numlines);

          Quote(Start,Finish);
        End
  End;
  Exit :
End;

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

procedure edituser (eunum:integer);
var eurec:userrec;
    ca:integer;
    k:char;

const sysopstr:array [false..true] of string[6]=('Normal','Sysop');
      sectionnames:array [udsysop..mainsysop] of string[20]=
        ('File Menu','Message Menu','Voting',
         'E-mail Menu','Doors','Main Menu');

  Procedure SysOpOf;
  Var C:ConfigType;
      SysOp:Boolean;
  Begin
   SysOp:=False;
   Writeln;
   For C:=UdSysOp To MainSysop Do
     If C In Urec.Config then Begin
       If Not SysOp then Write(^P'SysOp Of'^O': '^S) Else
       Write(', ');
       SysOp:=True;
       Write(SectionNames[C])
     End;
  End;

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
      if (m[p] in ['0'..'9'])
        then p:=p+1
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
    eurec.level:=cfg.deflevel;
    eurec.udpoints:=cfg.defudpoints;
    eurec.udlevel:=cfg.defudlevel;
    eurec.udfratio:=cfg.defudratio;
    eurec.udkratio:=cfg.defudkratio;
    eurec.pcr:=cfg.defpcr;
    eurec.msglength:=cfg.defmsglength;
    eurec.dailykblimit:=cfg.defdailykblimit;
    eurec.flags:=Cfg.DefFlags;
    If (Cfg.ChangeNote = False) Or (EUrec.SysOpNote = '')
      Then EUrec.SysopNote := Cfg.DefUserNote;
  End;

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

  procedure getlogint (prompt:mstr; var i:integer; ln:integer);
  begin
    getint (prompt,i);
    if ln > 0 Then
      writelog (18,ln,strr(i))
  end;

var q:integer;
   tmp:integer;
begin
  writeurec;
  seek (ufile,eunum);
  read (ufile,eurec);
  If (EURec.Level > Urec.Level) or (EUnum = 1) And (Local = False)
  Then Begin
    Writeln(^R'Sorry, you can edit users with higher levels then you!');
    Exit;
  End;
  WriteLog (2,3,eurec.handle);
{  WriteStr(^R'Use '^A'ViSiON/2 '^R'SysOp Full Screen User Editor? !');
  If inpt='' then inpt:='Y';
  If yes then Begin
     choose;
     writeufile (eurec,eunum);
     readurec;
     exit;
  end; }
  repeat
    q:=menu('Editing: '+EuRec.Handle,'UEDIT','SDHPLOEWTBQYNIA+CXGF!$^&J|=-');
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
  {Y} 12:specialsysop;
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
     end
  until hungupon or (q=11);
  writeufile (eurec,eunum);
  readurec
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
       If Exist(Cfg.textfiledir+'NEWSHDR.ANS') Then NewsHeader Else Begin
         AnsiCls;
         Writeln(^P+Cfg.LongName+' - News Update Number'^O': '^S+Strr(Cnt));
         Writeln(^P'Title..'^O': '^S+ntemp.title);
         Writeln(^P'From...'^O': '+ntemp.from);
         Writeln(^P'When...'^O': '^S+DateStr(NTemp.When)+^P' at '^S+TimeStr(Ntemp.When));
         Writeln(^P'Levels.'^O': '^S+Strr(NTemp.Level)+' to '+Strr(NTemp.MaxLevel));
       End;
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

procedure sendmodemstr (ss:anystr; endifcarrier:boolean);
var cnt,ptr:integer;
    k:char;
label exit;
begin
  ptr:=0;
  while ptr<length(ss) do
    begin
      if { keyhit or } (carrier=endifcarrier) then goto exit;
      ptr:=ptr+1;
      k:=ss[ptr];
      case k of
        '|':sendchar (^M);
        '~':delay (500);
        '^':begin
              ptr:=ptr+1;
              if ptr>length(ss)
                then k:='^'
                else k:=upcase(ss[ptr]);
              if k in ['A'..'Z']
                then sendchar (chr(ord(k)-64))
                else sendchar (k)
            end;
        else sendchar (k)
      end;
      delay (75);
      while numchars>0 do write (usr,getchar)
    end;
  cnt:=0;
  repeat
    while numchars>0 do begin
      cnt:=0;
      write (usr,getchar)
    end;
    cnt:=cnt+1
  until (cnt=1000) or keyhit or (carrier=endifcarrier);
  exit:
  break:=keyhit
end;