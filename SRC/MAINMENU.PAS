{$R-,S-,I-,D-,F-,V-,B-,N-,L+,O+ }

unit mainmenu;

interface

Procedure ShowCredits;
Procedure EditStatus;
Procedure BlackList;
procedure editusers;
{ procedure zapspecifiedusers; }
procedure summonsysop;
Procedure Auto_Message;
procedure Logoff;
procedure feedback;
{ procedure listusers; }
Procedure ShowDailyLog;
procedure transfername;
procedure editnews;
procedure yourstatus;
procedure delerrlog;
procedure settime;
procedure changepwd;
{ procedure requestraise; }
procedure makeuser;
procedure infoformhunt;
{ procedure donations; }
procedure viewsyslog;
procedure delsyslog;
procedure showsystemstatus;
procedure showallforms;
procedure showallsysops;
procedure readerrlog;
{ procedure showad; }
procedure setlastcall;
procedure removeallforms;
{ procedure readfeedback; }
Procedure RemoteDosShell;

Implementation

uses Crt,MNeT,Dos,gentypes,configrt,statret,textret,userret,mailret,
     Gensubs,Subs1,subsovr,subs2,windows,modem,chatstuf,mainr1,email0,
     Mainr2,overret1,rumors,MyComman,Chat;

Procedure ShowCREDITS;
BEGIN
Write(
'[40m[2J[29C[0m‹[1;30;47m∞≤[40m‹[C[0m‹[1;30;47m±∞[40m‹[C[0m‹[s',
'[u[1;30;47m±≤[40m‹[C[0m‹[1;30;47m±≤[40m‹[2;20H[37m‹‹‹‹‹‹‹‹‹[C[s',
'[u[30;41mﬂ[0m±[1;30;41mﬂ[40m≤[C[0m≤[1;31;41m›[30;47m≤[40m€[C[s',
'[u[41mﬁﬂ [40m€[C[0m≤[1;30m€€[47m≤[C[37;40m‹‹‹‹‹‹‹‹‹‹‹[0m‹',
'[3;20H[1m€[47m≤≤±∞    [0;30;47mﬂ[31;40mﬂ[1;41m±[0;31m≤ﬂ[C[1;30mﬂ[s',
'[u[31;41m≤∞[0;31mﬂ[C[1mﬁ[41m±[30mﬁ[40mﬂ[C[31;41mﬂ[30mﬂ[40m[s',
'[u[41m[31m∞[30;40mﬂ[0;30;47mﬂ           [1m∞[4;20H[37;40m€[s',
'[u[47m≤±[0;30;47m‹     ‹ [31;40mﬁ›[30;47mﬂ‹[C[1;31;41m±[C[40m[s',
'[u[0mﬂ€‹[1;31m≤[C[47m  [40mﬁ[41m±±[47m   [0;30;47m‹   ‹‹‹  [40m[s',
'[u[47m [1m±[5;20H[37m€±∞ [0;30;47mﬂ‹   € [31;40mﬁ[30;47m›ﬂ‹[40m[s',
'[u[C[31m›[47m [30m‹ €[1;31;40m›[47m [0;30;47m€ €[1;31;41m∞[40m[s',
'[u[C[47m   [0;30;47m€  ﬂ   € [1m∞≤[6;20H[37m≤∞    [0;30;47mﬂ[40m[s',
'[u[47m‹ € €    € € €  € €[1;31;40m›[47m [0;30;47mﬂ‹ €    ‹ﬂ  [40m[s',
'[u[47m[1m±€[7;20H[37m±       [0;30;47mﬂ€ € ‹‹‹ﬂ €‹€‹‹ﬂ €    ﬂ€[40m[s',
'[u[47m  ‹€‹‹‹[1m±≤[40m€[8;20H[37;47m∞        [0mﬂﬂ[47m  [40m[s',
'[u[40mﬂ[31m‹[37mﬂﬂ[1;30m‹[31;41mﬂ±[30m‹[40m‹[0;30;47m‹     [40m[s',
'[u[47m         [1m∞±≤≤[40m€[9;20H[0mﬂ[1;30mﬂﬂﬂﬂﬂﬂﬂ[31m‹[41m[40m[s',
'[u[41m€±[0;31m‹[1;30mﬂ[31m‹[41m±[0;31m‹[C[1;30m€€[0;31m€[1;30m[s',
'[u≤±[Cﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ[10;22H[0;31mﬂ[1;41m≤ﬂ[0;31mﬂ[C[1mﬂﬂ[s',
'[u[41m≤∞[0;31m€ﬂﬂ[C›[2C[1;30mﬂﬂﬂ[15C˘S[0;31m.[1m\[37m\[30m˘',
'[11;23H[31;41m∞[0;31m›[2C˛[C[1mﬁ[0;31m€›[C˙[12;23Hﬁ[6C[s',
'[u[1;41m›[13;23H[0;31mﬂ[5C[1mﬁ[41m∞[0;31m›[3C˛[3C[1;37mP[33mr[s',
'[u[31mo[0;31mgramm[1mi[33mn[37mg[0;31m:[C[1;37mC[33mr[31mi[s',
'[u[0;31mmson[CBl[1ma[33md[37me[14;23H[0;31m˙[6Cﬂ[15;30H˛',
'[16;32H[34m˙[1m˙[C[37mSpecial[CThanks[C[34m˙[0;34m˙[18;20H[s',
'[u[1;37mNet[CDistortion,[CAmplitude,[CDigital[CDisorder,[19;20HFel[s',
'[uonious[CMonk,[CNocturnus,[CShattered[CMind,[CThe[20;20HChairman,[s',
'[u[CDelerious[CNomad,[CV/2[CBETA[CSites,[Cand[21;20Hall[Ccontrib[s',
'[uuting[CANSI[Cartists.[0m');
  CurATTRIB := 0;
  AnsiColor(14);
  Writeln;
{  Writeln(^M^R'Registered SysOp'^A': '^S+RegSYSOP);
  Writeln(^R^R'Registered BBS  '^A': '^S+RegBBS); }
END;

Procedure EditStatus;
VAR Done:Boolean;
    FN:File Of ConfigSetType;

    Procedure DisplayStatus;
    Begin
      Header('System Status');
      Writeln(^A'1'^R') Total Callers: '^S+Streal(Status.NumCallers));
      Writeln(^A'2'^R') Total Days Up: '^S+Strr(Status.NumDaysUp));
      Writeln(^A'3'^R') Calls Today..: '^S+Strr(Status.CallsToday));
      Writeln(^A'4'^R') Short Name...: '^S+Cfg.ShortName);
      Writeln(^A'5'^R') Sysop PW.....: '^S+Cfg.SysOpMenuPassword);
      Writeln(^A'6'^R') System PW....: '^S+Cfg.SystemPassword);
      Writeln(^A'7'^R') New User PW..: '^S+Cfg.NewUserPassword);
    End;

BEGIN
  If Not(Local) Then Begin
    Writeln(^M'Sorry, you must be local to edit system stats!');
    Exit;
  End;
  AnsiCls;
  DisplayStatus;
  Writeln;
  Done:=False;
  Repeat
   Buflen:=1;
   WriteStr(^P'Edit Which? '^A'Q'^R'uits [ ]'+B_(2)+'*');
   If inpt='' then inpt:='D';
   Case Upcase(inpt[1]) Of
   '1':GetReal('Total Callers',Status.NumCallers);
   '2':Getint('Total Days Up',Status.NumdaysUp);
   '3':Getint('Calls Today',Status.CallsToday);
   '4':GetString('Short Name',Cfg.ShortName);
   '5':GetString('SysOp Password',Cfg.SysopMenuPassword);
   '6':Getstring('System Password',Cfg.SystemPassword);
   '7':GetString('New User Password',Cfg.NewUserPassword);
   'Q':Done:=True;
   'D':DisplayStatus;
   End;
  Until Done or (hungupon);
  Writeln(^M^M'Resetting configuration files...');
  If Status.NumDaysUp<1 Then Status.NumDaysUp:=1;
  If status.NumCallers<1 Then Status.numCAllers:=1;
  assign(fn,cfg.visiondir+'CONFIG.BBS');
  rewrite(fn);
  NWrite(fn,cfg);
  Close(fn);
  ReadCfg;
  WriteStatus;
  ReadStatus;
End;

Procedure BlackList;
var fn:text;
    Num:Integer;
    Loozers:Array[1..100] of Mstr;
    dummystr:mstr;
    Ch:Char;

  Procedure ShowLoozers;
  Var Cnt:Integer;
  Begin
   AnsiCls;
   WriteHdr('Unwanted Users..');
   For Cnt:=1 to Num Do Begin
     If Not Odd(Cnt) Then
       WriteLn(^A+Strr(Cnt)+') '^R+Loozers[Cnt])
     Else Tab(^A+Strr(Cnt)+') '^R+Loozers[Cnt],40);
   End;
   Writeln;
  End;

  Procedure AddLoozers;
  Begin
    Buflen:=30;
    WriteStr(^M^R'Add a Name to BlackList '^A'[                              ]'+B_(31)+'*');
    if inpt<>'' then Begin
      Inc(Num);
      Loozers[Num]:=inpt;
    End;
  End;

  Procedure DeleteLoozer;
  Var Cnt:Integer;
  Begin
    WriteStr(^M^R'Enter Number to Remove From BlackList: *');
    If (inpt='') or (valu(inpt)<1) or (Valu(inpt)>Num) then Exit;
    If Valu(inpt)=Num then  Else
      For Cnt:=Valu(inpt) to Num-1 do Loozers[Cnt]:=Loozers[Cnt+1];
      Dec(Num);
    End;

  Procedure SaveLoozers;
  Var Cnt:Integer;
  Begin
   Assign(Fn,Cfg.TextFileDir+'BlackLst');
   ReWrite(Fn);
   For Cnt:=1 to Num Do WriteLn(Fn,Loozers[Cnt]);
   TextClose(Fn);
   End;

  Procedure ReadLoozers;
  Begin
    Assign(Fn,Cfg.TextFileDir+'BlackLst');
    Reset(Fn);
    Num:=0;
    While Not Eof(Fn) do
      Begin
        ReadLn(Fn,DummyStr);
        Inc(Num);
        Loozers[Num]:=DummyStr;
      End;
    TextClose(Fn);
   End;

begin
  if not exist(cfg.textfiledir+'Blacklst') then begin
    writestr(^M+'There is no BlackList, Create One? !');
    if not yes then exit;
    assign(fn,cfg.textfiledir+'Blacklst');
    rewrite(fn);
    textclose(fn);
  end;
  ReadLoozers;
  Repeat
    ShowLoozers;
    Buflen:=1;
    WriteStr(^M^R'BlackList ['^A'A'^R']dd ['^A'D'^R']elete ['^A'Q'^R']uit [ ]'+B_(2)+'*');
    If inpt='' then inpt:='Q';
    Ch:=UpCase(inpt[1]);
      If Ch='A' then AddLoozers;
      If Ch='D' then DeleteLoozer;
  Until (Ch='Q') or HungUpOn;
  saveloozers;
end;

procedure editusers;
var eunum:integer;
    matched:boolean;

  procedure elistusers (getspecs:boolean);
  var cnt,f,l:integer;
      u:userrec;
      us:userspecsrec;

    procedure listuser;
    begin
      ansicolor(Urec.Color1);
      Tab(Strr(Cnt),5);
      AnsiColor(Urec.COlor2);
      tab (u.handle,31);
      AnsiColor(Urec.Color4);
      write (u.level:6,' ');
      ansicolor(Urec.Color6);
      tab (datestr(u.laston),8);
      ansicolor(Urec.Color3);
      Writeln(u.nbu:6,u.numon:6,percentage(u.nbu,u.numon):7:2)
    end;

  begin
{    if getspecs
      then if selectspecs(us)
        then exit
        else
          begin
            f:=1;
            l:=numusers
          end
     else }
    parserange (numusers,f,l,'User Range');
    seek (ufile,f);
    matched:=false;
    Writeln(^M);
    Header
    ('Num Name                            Level Last on  Posts Calls  PCR  ');
    for cnt:=f to l do begin
      nread (ufile,u);
      if (not getspecs) {or fitsspecs(u,us)} then begin
        listuser;
        matched:=true
      end;
      if break then exit
    end;
    if not matched then
      if getspecs
        then writeln (^R'('^S'No users match specifications!'^R')')
        else writeln (^R'('^S'No users found in that range!'^R')')
  end;

 procedure globalnew;
 var cnt,f,l:integer;
     U:userrec;
 begin
 f:=1;
 L:=numusers;
 seek(ufile,f);
 cnt:=0;
 for f:=1 to l do begin
   If break then exit;
   nread(ufile,u);
   if (u.level<=cfg.logonlevel) and (u.handle<>'') then begin
    cnt:=cnt+1;
      Buflen:=1;
      writestr(^M^R'Edit '^A+u.handle+^R'? ['^A'Y'^R']es ['^A'N'^R']o ['^A'Q'^R']uit [ ]'+B_(2)+'*');
      If Upcase(Inpt[1])='Q' Then Exit;
      if yes then begin
        edituser(f);
        seek(ufile,f+1);
        writeln(^B^U'Continuing with the scan...');
      end;
      end;
   end;
 If Cnt=0 then Writeln(^S'No New Users Found!') Else
 writeln(^B^R'End of user list! ['^P,cnt,^R'] Match(s) found!');
 end;

 Procedure GlobalLevel;
 VAR Which:Byte;
     Level,Start,Fin,T,Total:Integer;
     U:UserRec;

     Procedure QueryEdit;
     Begin
       Repeat
         Inc(Total);
         Inpt[0]:=#0;
         Buflen:=1;
         WriteStr(^R'Edit '^A+U.Handle+^R' ('^S'Level '+Strr(U.Level)+^R') ['^A+
                  +'Y'^R']es ['^A'N'^R']o e['^A'X'^R']it [ ]'+B_(2)+'*');
       Until ( Upcase(Inpt[1]) in ['Y','N','X']) or (HungupOn);
       If UpString(Inpt)='Y'
         Then EditUser(T);
     End;

 Begin
   Total:=0;
   Repeat
     Buflen:=5;
     WriteStr(^M^R'User Edit By What Level? '^A'[     ]'+B_(6)+'*');
     If Inpt='' Then Begin
       Writeln(^M^S'Aborted!');
       Exit;
     End;
     Level:=Valu(Inpt);
     If (Level<1) or (Level>32767) Then Begin
       Writeln(^M^S'Bad Value!');
       Exit;
     End;
   Until (Level>0) and (Level<32768) or (HungUpOn);
   Which:=0;
   Writeln;
   Repeat
     Buflen:=1;
     WriteStr(^R'Edit Users - ['^A'G'^R']reater, ['^A'L'^R']ess or ['^A+
              +'E'^R']qual to '+Strr(Level)+'? ['^U'E'^R']'+B_(2)+'*');
     If Inpt='' Then Inpt:='E';
     If Upcase(Inpt[1])='Q' Then Exit;
     Case Upcase(Inpt[1]) Of
       'G':Which:=1;
       'L':Which:=2;
       'E':Which:=3;
     End;
   Until (Upcase(Inpt[1]) in ['G','L','E']) Or (HungUpOn);
   Write(^P'User Search ');
   ParseRange(NumUsers,Start,Fin,'User Range');
   For T:=Start To Fin Do Begin
     Seek(UFile,T);
     NRead(UFile,U);
     If U.Handle<>'' Then
     If (Which=1) And (Level<U.Level) Then QueryEdit Else
     If (Which=2) And (Level>U.Level) Then QueryEdit Else
     If (Which=3) And (Level=U.Level) Then QueryEdit;
     If Upcase(Inpt[1])='X' Then Exit;
   End;
   If Total=0 Then Writeln(^S'No Users Found!');
 End;

begin
  repeat
    Writeln;
    WriteHdr('User Edit...');
    writestr (^R'['^A'N'^R']ew Users ['^A'S'^R']pecification Set ['^A'B'^R']y Level ['^A'?'^R'] List Users: *');
    if (length(inpt)=0) or (match(inpt,'Q')) then exit;
    If Upstring(inpt)='N' then GlobalNew Else
    If UpString(Inpt)='B' Then GlobalLevel Else
    if (inpt[1]='?') or (UpString(inpt)='S')
      then elistusers (UpString(inpt)='S')
      else begin
        eunum:=lookupuser (inpt);
        if eunum=0
          then writeln('User not found!')
          else edituser (eunum)
      end
  until hungupon
end;
(*
procedure zapspecifiedusers;
var us:userspecsrec;
    confirm:boolean;
    u:userrec;
    cnt:integer;
    done:boolean;
begin
  { if selectspecs (us) then exit;
  writestr ('Confirm each deletion individually? !');
  if length(inpt)=0 then exit;
  confirm:=yes;
  if not confirm then begin
    writestr (^M^P'Are you '^S'SURE'^P' you want to mass delete without confirmation? !');
    if not yes then exit
  end;
  for cnt:=1 to numusers do begin
    seek (ufile,cnt);
    NRead (ufile,u);
    if (length(u.handle)>0) and fitsspecs (u,us) then begin
      if confirm
        then
          begin
            done:=false;
            repeat
            Buflen:=1;
            writestr (^P'Delete '+u.handle+'? '^A'Y'^R'es '^A'N'^R'o e'^A'X'^R'it '^A'E'^R'dit [ ]'+B_(2)+'*');
              if length(inpt)>0 then case upcase(inpt[1]) of
                'Y':begin
                      done:=true;
                      writeln (^R'('^S'Deleting '+u.handle+^R')');
                      deleteuser (cnt)
                    end;
                'N':done:=true;
                'X':exit;
                'E':begin
                      edituser(cnt);
                      writeln;
                      writeln
                    end
              end
            until done
          end
        else
          begin
            writeln (^R'('^S'Deleting '+u.handle+^R')');
            if break then begin
              writeln('Aborted!!');
              exit
            end;
            deleteuser (cnt)
          end
    end
  end
end;
*)

procedure summonsysop;
var tf:text;
    k:char;
begin
  If (No_Chat in Urec.Config) Then Begin
    { Writeln(^S+Cfg.Sysopname+' has chat turned off.'); }
    MultiColor(Strng^.SysOp_Not_Here);
    Writeln;
    Exit;
  End;
  chatmode:=not chatmode;
  bottomline;
  if chatmode
    then if sysopisavail
      then begin
        If Cfg.ChatCost > 0
        then Begin
          chatmode:=false;

          Sr.C[1] := 'CC'; Sr.S[1] := Strr(Cfg.ChatCost);

          MultiColor(Strng^.Chat_Request_Will_Cost);
          Writeln;

          DefYes:=False;
          WriteStr(Strng^.Still_Wanna_Chat);

          If Not Yes Then Exit;

          If Urec.UdPoints<Cfg.ChatCost then Begin
            {Writeln(^M^G'Hey! You don''t have enough '+Cfg.FilePoints+'!');}
            MultiColor(Strng^.No_Chat_No_FP);
            Writeln;
            Exit;
          End;

          Urec.UdPoints := Urec.UdPoints - Cfg.ChatCost;
          Writeln;
          Chatmode:=true;
        End;

        Inpt := Chr(254);

            If Exist(Cfg.TextFileDir+'CHAT.ANS') Then
              InputFile(Cfg.TExtFileDir+'CHAT.ANS');

            If Inpt = Chr(254)
            Then Begin
              MultiColor(Strng^.ChatRequestStr);
              NoCRInput(Cfg.BoxAbort,35);
            End;

            ChatReason := Inpt;

            if length(inpt)=0 then begin
              chatmode:=false;
              exit
            end;

            writelog (1,3,chatreason);
            assign (tf,cfg.textfiledir+'SUMMON');
            reset (tf);

            if ioresult=0 then begin
              while (not (eof(tf) or hungupon)) and chatmode do
                begin
                  read (tf,k);
                  nobreak:=true;
                  if ord(k)=7 then summonbeep else writechar (k);
                  if keyhit then begin
                    k:=bioskey;
                    clearbreak;
                    configchat (1)
                  end
                end;
              textclose (tf)
            end;

            if chatmode
              then Begin
                { writeln (^M^R'Use '^O'['^P'C'^O']'^R' again to turn off page.') }
                MultiColor(Strng^.Use_C_to_Stop_Chat);
                Writeln;
              end
              else unsplit
          end
        else
          begin
            Fake_Chat;
            MultiColor(Strng^.SysOp_Not_Here);
            Writeln;
            chatmode:=false;
            writelog (1,2,'')
          end
    else
      Begin
        MultiColor(Strng^.Use_C_to_Start_Chat);
        Writeln;
      End;
  clearbreak
end;

    Procedure Auto_Message;
    Var q:longint;
        m:message;
    Begin
      DefYes:=False;
      WriteStr(Strng^.ChangeAutoMsgStr);
      If Not YES Then Exit;
      Okfortitle := False;
      M.Add_AutoSig := False;
      Q := Editor(m,false,true,'All Users','0','AUTOMESS.TXT','AUTOMESS.MAP');
      okfortitle := True;
      If Q >= 0 then begin
        If Status.ToNext >=0
          Then DeleteText ('AUTOMESS.TXT','AUTOMESS.MAP',Status.ToNext);
        Status.ToNext := Q;
        Status.AMauthor := Urec.Handle;
        WriteStatus;
        Writelog(0,0,'Changed Auto-Message')
      End
    End;

procedure Logoff;
var n:integer;
    tn:file of integer;
    b:boolean;
begin
  Repeat
  B:=Exist(Cfg.TextFileDir+'LOGOFF.ANS');
  If B
    Then InputFile(Cfg.TextFileDir+'LOGOFF.ANS') Else Begin
    WriteStr(Strng^.LogoffStr)
  End;
  if inpt='' then inpt:='Y';
  Case Upcase(inpt[1]) Of
   'A':Auto_Message;
   'N':Exit;
   End;
    Until Upcase(inpt[1])='Y';
    WriteStatus;
    If NOT B Then Auto_Message;
    Urec.PlayLottery:=False;
{    If (Cfg.UseLottery) and (Urec.Level>=Cfg.LotLevel) Then Begin
      DefYes:=False;
      WriteStr(^M^R'Would You Like to Play '+Cfg.FilePoint+' Lottery? !');
      If Yes Then Begin
        Write(^M^R'Playing Lottery will cost you '^A+Strr(Cfg.LotCost)+^R' ');
        If Urec.UDPoints<Cfg.LotCost Then Begin
          Writeln('UH OH!  You don''t have enough '+Cfg.FilePoints+' HAHAHA!'^G);
          Delay(500);
        End Else Begin
          If Cfg.LotCost=1 Then Writeln(Cfg.FilePoint) Else Writeln(Cfg.FilePoint);
          Writeln(^R'Chances of winning are '^A+Strr(Cfg.LotChance)+'% '^R'(Your winnings would be '+
                +Strr(Cfg.LotCost * Cfg.LotWinnings)+')');
          WriteStr(^M^R'Want to risk it? !');
          If yes Then Begin
             Urec.PlayLottery:=True;
             Urec.UDPoints:=Urec.UDPoints-Cfg.LotCost;
          End;
        End;
      End;
    End; }
    { If Cfg.UseQuotes > 1 then RandomQuote; }
    { If Cfg.UseThisDay > 1 then ThisDay; }
    Printfile (Cfg.textfiledir+'GOODBYE.ANS');
    Disconnect
end;

procedure transfername;
var un,nlvl,ntime,tmp:integer;
    u:userrec;
begin
  if tempsysop then begin
    writeln ('Disabling temporary sysop powers...');
    ulvl:=regularlevel;
    tempsysop:=false
  end;
  write(^P'Transfer to user name'^O': ');
  InputBox(30);
  if length(inpt)=0 then exit;
  un:=lookupuser(inpt);
  if unum=un then begin
    writeln ('You can''t transfer to yourself!');
    exit
  end;
  if un=0 then begin
    writeln ('No such user.');
    exit
  end;
  Seek (ufile,un);
  NRead (ufile,u);
{  if (ulvl<cfg.sysoplevel) or (Un=1) then if not checkpassword(u) then begin
    writelog (1,5,u.handle);
    exit
  end;  }

  If (IsSysOp = False) Or (Un = 1)
  Then Begin
    MultiColor(Strng^.WhatsYourPw);
    Dots:=True;
    WriteStr('*');
    Dots:=False;
    If Not Match(Inpt,U.PassWord) Then Begin
      Writeln(^M^M^S+'That''s not it!');
      WriteLog(1,5,U.Handle);
      Exit;
    End;
  End;

  writelog (1,4,u.handle);
  updateuserstats (false);
  ntime:=0;
  if datepart(u.laston)<>datepart(now) then begin
    tmp:=ulvl;
    if tmp<1 then tmp:=1;
    if tmp>100 then tmp:=100;
    ntime:=cfg.usertime[tmp]
  end;
  if u.timetoday<10
    then if issysop or (u.level>=Cfg.sysoplevel)
      then
        begin
          writeln (^S'The user has '+strr(u.timetoday)+' min(s) left!');
          writestr (^P'New time left'^O': *');
          ntime:=valu(inpt)
        end
      else
        if u.timetoday>0
          then writeln ('Warning: You have ',u.timetoday,' minutes left!')
          else
            begin
              writeln ('Sorry, that user doesn''t have any time left!');
              exit
            end;
  unum:=un;
  readurec;
  readcatalogs(true);
  if ntime<>0 then begin
    urec.timetoday:=ntime;
    writeurec
  end;
end;

procedure editnews;
var nn,numnews:integer;
    nf:file of NewsRec;

  procedure getnn (txt:mstr);
  begin
    writestr (^P'News number to '+txt+^O': *');
    nn:=valu(inpt);
    if (nn<1) or (nn>numnews) then nn:=0
  end;

    Procedure delnews;
    Var cnt:Integer;
      r:Integer;
      NTmp:newsrec;
    Begin
      If nn=0 Then getnn('delete');
      If nn<>0 Then Begin
      WriteLog(0,0,'Deleted News Item: '+strr(nn));
        Seek(nf,nn-1);
        NRead(nf,Ntmp);
        che;
        deletetext('NEWS.TXT','NEWS.MAP',Ntmp.Location);
        numnews:=FileSize(nf)-1;
        For cnt:=nn To numnews Do
          Begin
            Seek(nf,cnt);
            NRead(nf,nTmp);
            Seek(nf,cnt-1);
            NWrite(nf,Ntmp)
          End;
        Seek(nf,numnews);
        Truncate(nf)
      End
    End;

  Procedure NewsEditor;
  VAR News:NewsRec;
      Me:Message;

     Procedure ShowNews;
     Begin
       Writeln;
       Header('News Entry: '+Strr(nn));
       Writeln(^A'T'^R'itle.........: '^S+News.Title);
       Writeln(^A'M'^R'inimum Level.: '^S+Strr(News.Level));
       Writeln(^R'Ma'^A'X'^R'imum Level.: '^S+Strr(News.MaxLevel));
       Writeln(^A'F'^R'rom..........: '^S+News.From);
       Writeln(^A'A'^R'lways Display: '^S+YesNo(News.Always));
       Writeln(^A'E'^R'dit Actual News'^M);
     End;

  Begin
    GetNn('Edit');
    If nn<=0 then Begin
      Writeln('Invalid Number!');
      Exit;
    End;
    Seek(Nf,nn-1);
    NRead(Nf,News); che;
    ShowNews;
    Repeat
      Buflen:=1;
      inpt:=#0;
      WriteStr(^P'New Editor ['^S'Q'^P']uits '^O'[ ]'+B_(2)+'*');
      If inpt='' then inpt:='S';
      Case Upcase(inpt[1]) Of
      'S':ShowNews;
      'T':GetString('Title',News.Title);
      'M':GetInt('Min. Level',News.Level);
      'X':GetInt('Max. Level',News.MaxLevel);
      'F':GetString('Author',News.From);
      'A':Begin
           WriteStr('Display News always? !');
           News.Always:=Yes;
          End;
      'E':Begin
            ReloadText ('NEWS.TXT','NEWS.MAP',news.location,me);
            Me.Title := News.Title;
            Me.Anon := False;
            Me.SendTo := 'All';
            If ReEdit (Me,True)
            Then Begin
              Writelog (4,6,news.title);
              Deletetext ('NEWS.TXT','NEWS.MAP',News.Location);
              News.Location := Maketext ('NEWS.TXT','NEWS.MAP',Me,'');
              if news.location<0 then begin
                writeln (^M'Deleting News..');
                DelNews;
              End;
            End;
           End;
        End;  {Case}
    Until (Upcase(inpt[1])='Q') or (HungupOn);
    Seek(Nf,nn-1);
    NWrite(Nf,News);
  End;

  Procedure listnews;
    Var cnt:Integer;
      l:anystr;
      k:Char;
      Ntmp:newsrec;
    Begin
      clearbreak;
      Header('News  Title                         Min Level  Max Level  Shown    ');
      For cnt:=1 To numnews Do Begin
        Seek(nf,cnt-1);
        NRead(nf,ntmp);
        Write(^R+strr(Cnt)+':');
        Write('      ');
        Tab(^P+NTmp.Title,30);
        Tab(^O+Strr(Ntmp.Level),12);
        Tab(Strr(Ntmp.MaxLevel),12);
        If Ntmp.Always then Writeln(^A'Always') Else Writeln(^A'Once');
        If break Then exit
      End;
    End;

  procedure adddnews;
  begin
    close (nf);
    addnews;
    assign (nf,Cfg.datadir+'News');
    reset (nf)
  end;

var q:integer;
begin
  assign (nf,Cfg.datadir+'News');
  reset (nf);
  if ioresult<>0 then writeln (^R'('^S'No news to edit right now!'^R')') else begin
    repeat
      nn:=0;
      numnews:=filesize(nf);
      write (^B^M^R'Total news entries'^A': '^S+Strr(numnews)+^M);

      WriteStr(^R'['^S'A'^R']dd, ['^S'D'^R']elete, ['^S'E'^R']dit, ['^S'L'^R']ist, ['^S'V'^R']iew : &');

      { q:=menu ('News edit','NEWS','ADLVQE'); }

      nn:=valu(copy(inpt,2,255));

      If Inpt = '' Then Q := 5;

      if (nn<1) or (nn>numnews) then nn:=0;
      case Upcase(Inpt[1]) of
        'A' : adddnews;
        'D' : delnews;
        'L' : listnews;
        'V' : Begin
                WriteStr(^R'View which NEWS Item? '^O'['^P'1..'+strr(NumNews)+^O'] ['^P'0/All'^O']: *');
                If inpt='' then inpt:='-1';
                If (Valu(inpt)>-1) and (Valu(inpt)<=NumNews) Then
                printnews(Valu(inpt),False);
              End;
        'E' : NewsEditor;
        'Q' : Q := 5;
      end;
      if numnews=0 then begin
        close (nf);
        erase (nf);
        writeln (^R'('^S'No news to edit right now!'^R')');
        q:=5
      end
    until (q=5) or hungupon
  end;
  close (nf)
end;

Procedure ShowDailyLog;
VAR Cnt,Back:Byte;
    DFile:File Of DailyLogRec;
    Temp:DailyLogRec;

  {
    Procedure Show(I,L:Integer);
    Begin
      If I<0 Then I:=0;
      If I=0 Then AnsiColor(Urec.Color1) Else AnsiColor(Urec.Color3);
      Tab(Strr(I),L);
    End;
  }

Begin
  WriteHdr('Daily Log');
  Assign(DFile,Cfg.VisionDir+'DAILYLOG.DAT');
  Reset(Dfile);
  WriteStr(^P'List Log how many days back? (1-'+Strr(FileSize(DFile))+'): *');
  If inpt='' then Back:=1 Else
  Back:=FileSize(DFile) - Valu(inpt) + 1;
  If (Back>0) and (Back<=FileSize(DFile)) then Begin

    ListingFile(Cfg.TextFileDir+'DAILYLOG.TOP',True);

    For Cnt:=Back To FileSize(DFile) Do Begin
      Seek(DFile,Cnt-1);
      NRead(DFile,Temp);

      Sr.C[1] := 'DA'; Sr.S[1] := Temp.Day;  Sr.T[1] := 10;
      Sr.C[2] := 'UL'; Sr.S[2] := Strr(Temp.ULoads); Sr.T[2] := 8;
      Sr.C[3] := 'DL'; Sr.S[3] := Strr(Temp.DLoads); Sr.T[3] := 8;
      Sr.C[4] := 'PO'; Sr.S[4] := Strr(Temp.Posts); Sr.T[4] := 8;
      Sr.C[5] := 'NU'; Sr.S[5] := Strr(Temp.NewUsers); Sr.T[5] := 8;
      Sr.C[6] := 'MI'; Sr.S[6] := Strr(Temp.MinsUsed); Sr.T[6] := 8;
      Sr.C[7] := 'FB'; Sr.S[7] := Strr(Temp.FeedBack); Sr.T[7] := 8;
      ListingFile(Cfg.TextFileDir + 'DAILYLOG.MID',False);
    End;
    ListingFile(Cfg.TextFileDir + 'DAILYLOG.BOT',False);
  End;

  Close(DFile);
  Writeln;

End;

Procedure YourStatus;
Begin
  PrintFile(Cfg.TextFileDir + 'YOURSTAT.ANS')
End;

procedure delerrlog;
var e:text;
    i:integer;
begin
  writestr ('Delete error log? !');
  if not yes then exit;
  assign (e,Cfg.datadir+'errlog');
  reset (e);
  i:=ioresult;
  if ioresult=1
    then writeln (^M'No error log!')
    else begin
      textclose (e);
      erase (e);
      writeln ('Error log deleted.');
      if ioresult>1
        then writeln ('I/O error ',i,' deleting error log!');
      writelog (2,2,'')
    end
end;

Procedure Feedback;
Var M : Mailrec;
    Me : Message;
    Sys_Num : Array[1..50] Of Integer;
    Total_Sys : Byte;

    Procedure Show_All_SysOps;
    Var X : Integer;
        U : UserRec;
    Begin
      Total_Sys := 0;
      Writeln;
      WriteHdr('Scanning For SysOp''s');
      For X := 1 to NumUsers
      Do Begin
        Seek(UFile,X);
        NRead(UFile,U);
        If U.Level >= Cfg.SysOpLevel
        Then Begin
          Inc(Total_Sys);
          Sys_Num[Total_Sys] := X;
          Write(^B^R'['^A+Strr(Total_Sys)+^R'] : '^S);
          Tab(U.Handle,30);
          Writeln(^B'  '^R'('^S+U.SysOpNote+^R')');
        End;
      End;
      Writeln;
    End;

    Procedure Send_To_Whom;
    Var I : Integer;
    Begin
      Show_All_SysOps;
      WriteStr(^R'Send Mail to Which #? '^A': *');
      I := Valu(Inpt);
      If (I < 1) or (I > Total_Sys)
        Then Exit;
      Writeln;
      SendMailTo(LookUpUName(Sys_Num[I]),False);
    End;

Begin
  WriteStr (Strng^.LeaveFBStr);
  if Upcase(Inpt[1]) in ['Q','N'] then exit;
  If Upcase(Inpt[1]) = 'S'
    Then Begin
      Send_To_Whom;
      Exit;
    End;
  OkForTitle := True;
  Quoting.AllowQuote := False;
  Me.Add_AutoSig := True;
  M.Line := Editor(Me,False,True,'Management','0','FEEDBACK.TXT','FEEDBACK.MAP');
  If M.Line < 0
    Then Exit;
  DefYes := False;
  WriteStr(Strng^.Mail_Notify);
  M.Return := Yes;
  M.Title := Me.Title;
  M.Sentby := Unam;
  M.Anon := False;
  M.When := Now;
  AddFeedBack (M);
  Inc(Log.Feedback);
  MultiColor (Strng^.Feedback_Sent);
  Writeln
End;

procedure settime;
var t:integer;
    n:longint;
    r:registers;
    d:datetime;
begin
  writeln (^R'Current time'^O': '^S+timestr(now));
  writeln (^R'Current date'^O': '^S+datestr(now));
  WriteStr(^M^R'Change '^A'T'^R'ime or '^A'D'^R'ate? :*');
  Case Upcase(inpt[1]) of
  'T':Begin
  write(^M^R'Enter new time'^O': ');
  InputBox(5);
  if length(inpt)<>0
    then begin
      t:=timeleft;
      unpacktime (timeval(inpt),d);
      r.ch:=d.hour;
      r.cl:=d.min;
      r.dh:=0;
      r.dl:=0;
      r.ah:=$2d;
      intr ($21,r);
      if r.al=$ff then writeln ('Invalid time!');
      settimeleft (t)
    end;
   End;
  'D':Begin
  write(^P'Enter new date'^O': ');
  InputBox(9);
  if length(inpt)<>0
    then begin
      unpacktime (dateval(inpt),d);
      r.dl:=d.day;
      r.dh:=d.month;
      r.cx:=d.year;
      r.ah:=$2b;
      intr ($21,r);
      if r.al=$ff then writeln ('Invalid date!')
    End
   End
  End;
  writelog (2,4,'')
end;

procedure changepwd;
var t:sstr;
begin
  Writehdr ('Password Change');
  dots := true;
  write (^R'Enter new password'^A': ');
  if getpassword
    then begin
      writeurec;
      writeln ('Password changed.');
      writelog (1,1,'')
    end else
      writeln ('No change.')
end;

(*
procedure requestraise;
var t:text;
    q:lstr;
    p,l1,l2:integer;
    s1,s2:sstr;
    me:message;
    m:mailrec;
label nope,found;
begin
  assign (t,Cfg.textfiledir+'RAISEREQ');
  reset (t);
  if ioresult<>0 then goto nope;
  printtexttopoint (t);
  while not eof(t) do begin
    readln (t,q);
    p:=pos('-',q);
    if p>0
      then
        begin
          s1:=copy(q,1,p-1);
          s2:=copy(q,p+1,255)
        end
      else
        begin
          s1:=copy(q,1,15);
          s2:=s1
        end;
    val (s1,l1,p);
    if p=0 then val (s2,l2,p);
    if p<>0 then begin
      textclose (t);
      error ('Invalid range in RAISEREQ: %1','',q);
      exit
    end;
    if (ulvl>=l1) and (ulvl<=l2) then goto found;
    skiptopoint (t)
  end;
  nope:
  error ('No text for level %1','',strr(ulvl));
  textclose (t);
  p:=ioresult;
  exit;
  found:
  printtexttopoint (t);
  textclose (t);
  if hungupon then exit;
  m.line:=editor (me,false,true,'0','0');
  if m.line<0 then exit;
  m.anon:=false;
  m.title:='Raise request; now lvl='+strr(ulvl);
  m.sentby:=unam;
  m.when:=now;
  addfeedback (m);
end;
*)

procedure makeuser;
var u:userrec;
    un,ln,udlvl:integer;
    note:mstr;
begin
  writehdr ('Add a user');
  Writeln;
  writestr (^R'Alias/Name'^A': *');
  if length(inpt)=0 then exit;
  if lookupuser(inpt)<>0 then begin
    writeln ('That name already exists in the user database!');
    exit
  end;
  u.udlevel:=-500;
  u.handle:=inpt;
  writestr (^R'Password'^A': *');
  u.password:=inpt;
  writestr (^R'Level'^A': *');
  if length(inpt)=0 then exit;
  u.level:=valu(inpt);
  WriteStr (^R'File Level'^A': *');
  If length(inpt)=0
    then udlvl:=0
    Else udlvl:=valu(inpt);
  WriteStr(^R'User Note'^A': *');
  Note:=inpt;
  un:=adduser(u);
  if un=-1 then begin
    writeln ('Sorry, no room for new users!');
    exit
  end;
  ln:=u.level;
  if ln<1 then ln:=1;
  if ln>100 then ln:=100;
  u.udlevel:=udlvl;
  u.sysopnote:=note;
  u.timetoday:=cfg.usertime[ln];
  u.config:=u.config+[ansigraphics,linefeeds,asciigraphics,lowercase,eightycols];
  u.config:=u.config+[usebars,fseditor,showrumors];
  u.color1:=cfg.defcolor1; u.color2:=cfg.defcolor2; u.color3:=cfg.defcolor3;
  u.color4:=cfg.defcolor4; u.color5:=cfg.defcolor5; u.color6:=cfg.defcolor6; u.color7:=cfg.defcolor7;
  u.color7:=cfg.defcolor7;
  u.pcr:=cfg.defpcr;
  u.dailykblimit:=cfg.defdailykblimit;
  u.udfratio:=cfg.defudratio;
  u.udkratio:=cfg.defudkratio;
  u.prompt := Strng^.DefPrompt;
  writeufile (u,un);
  writeln ('User added as #'+strr(un)+'.');
  writelog (2,8,u.handle)
end;

procedure infoformhunt;
begin
  writestr (^R'User to search for'^A': *');
  If Inpt = '' then exit;
  writeln (^M);
   WriteStr(^R'Show which infoform? '^A'('^I'1 - 5'^A') '^P':*');
   If (valu(inpt)>0) and (valu(inpt)<6) then
  showinfoforms (inpt,valu(inpt))
end;

(*
procedure donations;
var fn:lstr;
begin
  fn:=Cfg.textfiledir+'Donation';
  if exist (fn)
    then printfile (fn,1)
    else begin
      writeln ('I''m sorry, no information is currently available.');
      if issysop
        then writeln (
'Sysop:  To create donation information text, make a file called '+fn)
    end
end;
*)
procedure viewsyslog;
var n:integer;
    l:logrec;
    ii:byte;

  function lookupsyslogdat (m,s:integer):integer;
  var cnt:integer;
  begin
    for cnt:=1 to numsyslogdat do with syslogdat[cnt] do
      if (menu=m) and (subcommand=s) then begin
        lookupsyslogdat:=cnt;
        exit
      end;
    lookupsyslogdat:=0
  end;

  function firstentry:boolean;
  begin
    firstentry:=(l.menu=0) and (l.subcommand in [1..2])
  end;

  procedure backup;
  begin
    while n<>0 do begin
      n:=n-1;
      seek (logfile,n);
      read (logfile,l);
      if firstentry then exit
    end;
    n:=-1
  end;

  procedure showentry (includedate:boolean);
  var q:lstr;
      p:integer;
  begin
  If l.subcommand>0 then q:=syslogdat[lookupsyslogdat(l.menu,l.subcommand)].text else
   q:=l.param;
    p:=pos('%',q);
    if p<>0 then q:=copy(q,1,p-1)+l.param+copy(q,p+1,255);
    If firstentry then Begin
      AnsiColor(urec.color1);
      Write('˙˙˙ ');
        Ansicolor(Urec.Color2);
        Write(q);
        Write(' on ');
        Write(datestr(l.when));
        Write(' at ');
        Writeln(timestr(l.when));
        inc(ii);
      End Else
    Begin
      AnsiColor(Urec.Color4);
      Write('  '+TimeStr(l.when));
      Ansicolor(Urec.Color6);
      Write(': ');
      if includedate then q:=q+' on '+datestr(l.when);
      Ansicolor(Urec.Color1);
      writeln (q);
      inc(ii);
    End;
  End;

var b,NonStop:boolean;
    k:char;
begin
  writehdr ('Viewing system log');
  writelog (2,6,'');
  n:=filesize(logfile);
  ii:=4;
  NonStop:=False;
  repeat
    clearbreak;
    writeln (^M);
    INC(ii,3);
    If (ii>=23) And (NonStop=False) then Begin
        Write(^R'SysOp Log: '^A'CR'^R'/Continue '^A'Q'^R'uits '^A'N'^R'on-Stop'^R':');
        K:=waitforchar(false);
        For ii:=1 to 47 do Write(^H+' '+^H);
        If Upcase(k)='Q' then exit Else
        If Upcase(K)='N' Then NonStop:=True;
        ii:=1;
    End;
    backup;
    if n=-1 then exit;
    seek (logfile,n);
    read (logfile,l);
    showentry (true);
    b:=false;
    while not (eof(logfile) or break or xpressed or b) do begin
      read (logfile,l);
      b:=firstentry;
      if not b then showentry (false);
      If (ii>=23) And (NonStop=False) then Begin
        Write(^R'SysOp Log: '^A'CR'^R'/Continue '^A'Q'^R'uits '^A'N'^R'on-Stop'^R':');
        K:=waitforchar(false);
        For ii:=1 to 47 do Write(^H+' '+^H);
        If Upcase(k)='Q' then exit Else
        If Upcase(K)='N' Then NonStop:=True;
        ii:=1;
      End
    end;
  until xpressed
end;

procedure delsyslog;
begin
  If Not Match(Urec.Handle,Cfg.SysopName) Then Begin
    Writeln(^M^R'Sorry, only '+Cfg.SysOpName+' can delete this...');
    Exit;
  End;
  writestr (^P'Delete System Log'^O'? !');
  if not yes then exit;
  close (logfile);
  rewrite (logfile);
  writeln (^M'System log deleted.');
  writelog (2,7,unam)
end;

Procedure PrintXy(X,Y:Byte; L:AnyStr);
Begin
  If break then exit;
  GoXy(X,Y);
  Write(L);
End;

procedure showsystemstatus;
var totalused,totalidle,totalup,totaldown,totalmins,callsday,a,b:real;
    D:Word; NumQuotes,numrumors:Integer;
    i:BaudRatetype;

  procedure percent (top,bot:real);
  var p:real;
  begin
    if bot<1 then begin
      writeln ('N/A');
      exit
    end;
    p:=round(1000*top/bot)/10;
    writeln (p:0:1,'%')
  end;

        Function CheckLocals:Integer;
        VAR A,Y:String[3];
            X,X2,Total:Integer;
            U:UserRec;
        BEGIN
          Total:=0;
          A[0]:=CHR(0);
          For X:=1 to 3 Do A:=A+Cfg.BoardPhone[X];
          For X:=1 to NumUsers Do Begin
            Seek(UFile,X);
            NRead(UFile,U);
            If (U.Handle>'') And (U.Phonenum>'') Then Begin
              Y[0]:=CHR(0);
              For X2:=1 to 3 Do Y:=Y+U.Phonenum[X2];
              If Y=A Then
                Inc(Total);
              End;
            End;
          X:=Round(Percentage(Total,NumUsers));
          CheckLocals:=X;
        End;

  Procedure SystemStats;
  VAR T:Text;
      K:Char;
  BEGIN
    ClearBreak;
    ASSIGN(T,Cfg.textfiledir+'SYSSTATS.ANS');
    RESET(T);
    While Not(EOF(T)) Do Begin
      If Break then Exit;
      Read(T,K);
      If K='|' Then Begin
      Read(T,K);
      CASE K OF
      'T':Write(TimeStr(Now));
      'D':Write(DateStr(Now));
      'C':Write(Strr(Status.CallsToday));
      'K':Write(Streal(Status.NumCallers));
      'U':Write(Strr(Status.NumDaysUp));
      'P':Write(Streal(CallsDay));
      'M':Write(Streal(Status.NumMinsUsed.Total));
      'I':Write(Streal(TotalIdle));
      'X':Write(Streal(Status.NumMinsXfer.Total));
      'O':Write(Streal(TotalUp));
      'W':Write(Streal(TotalDown));
      'B':Write(Strr(Status.TotalMsgs));
      'F':Write(Strr(Status.TotalFiles));
      'R':Write(Strr(NumRumors));
      'Q':Write(Strr(NumQuotes));
      '!':Percent(TotalUsed,TotalMins);
      '@':Percent(TotalIdle,TotalMins);
      '#':Percent(TotalUp,TotalMins);
      '$':Percent(TotalDown,TotalMins);
      '%':Write(Streal(A));
      '^':Write(Streal(A-B));
      '&':Write(Streal(B));
      '*':Write(ConnectStr);
      '>':Write(Strlong(TotalSent));
      '<':Write(Strlong(TotalReceived));
      'L':WRite(Strr(CheckLocals));
      'S':Write(Cfg.SysOpName);
      '+':Write(Cfg.LongName);
      '=':Write(NumUsers);
       Else Write( '|' + K );
      End;
      End Else Write(K);
    End;
    TextClose(T);
    AnsiReset;
    Write(^S);
    ClearBreak;
  End;


begin
  totalused:=Status.numminsused.total + elapsedtime(Status.numminsused);
  totalidle:=Status.numminsidle.total;
  totalup:=totalidle+Status.numminsused.total;
  totalmins:=1440.0 * (Status.numdaysup - 1.0) + timer;
  totaldown:=totalmins-totalup;
  If Status.NumDaysUp > 1 Then With Status Do Begin
    If NumCallers - CallsToday > 0 Then
    callsday:=Round( 10 * (Numcallers - CallsToday) / (Numdaysup - 1) ) / 10
    Else CallsToday := 0;
  End Else CallsDay := 0;
    A:=DiskSpace(cfg.visiondir,true);
    B:=DiskSpace(cfg.visiondir,false);
    D:=DosVerSion;
    Assign (rfile,Cfg.datadir+'RUMORS.DAT');
    Reset(Rfile);
    If ioresult<>0 then numrumors:=0 else
    NumRumors:=FileSize(Rfile);
    Close(rfile);

  IF Exist(Cfg.textfiledir+'SYSSTATS.ANS')
    Then SystemStats
    Else Writeln('Error: SYSSTATS.ANS missing!');

  Writelog(0,0,'Viewed System Status');
end;

procedure showallforms;
var a:byte;
begin
  For a:=1 to 5 do showinfoforms ('',a)
end;

procedure showallsysops;
var n:integer;
    u:userrec;
    q:set of configtype;
    s:configtype;

  procedure showuser;
{  const sectionnames:array [udsysop..databasesysop] of string[20]=
         ('File transfer','Bulletin section','Voting booths',
          'E-mail section','Doors','Main menu','Databases'); }
  var s:configtype;
  begin
    writeln (^B^M^P'Name'^O':  '^S,u.handle,
               ^M^P'Level'^O': '^S,u.level,^M);
{    for s:=udsysop to databasesysop do
      if s in u.config then
        writeln (^P'Sysop of the ',sectionnames[s]); }
    writestr (^M^R'Edit user? !');
    if yes then edituser (n)
  end;

begin
  q:=[];
  for s:=udsysop to databasesysop do q:=q+[s];
  for n:=1 to numusers do begin
    seek (ufile,n);
    read (ufile,u);
    if (u.level>=Cfg.sysoplevel) or (q*u.config<>[]) then showuser
  end
end;

procedure readerrlog;
begin
  AnsiCls;
  if exist (Cfg.datadir+'ERRLOG')
    then printfile (Cfg.datadir+'ERRLOG')
    else writeln(^M'No error file!')
end;

(*
procedure showad;
var fn:lstr;
begin
  fn:=Cfg.textfiledir+'VISION.AD';
  if exist (fn) then printfile (fn)
end;
*)

procedure setlastcall;

  function digit (k:char):boolean;
  begin
    digit:=ord(k) in [48..57]
  end;

  function validtime (inp:sstr):boolean;
  var c,s,l:integer;
      d1,d2,d3,d4:char;
      ap,m:char;
  begin
    validtime:=false;
    l:=length(inp);
    if (l<7) or (l>8) then exit;
    c:=pos(':',inp);
    if c<>l-5 then exit;
    s:=pos(' ',inp);
    if s<>l-2 then exit;
    d2:=inp[c-1];
    if l=7
      then d1:='0'
      else d1:=inp[1];
    d3:=inp[c+1];
    d4:=inp[c+2];
    ap:=upcase(inp[s+1]);
    m:=upcase(inp[s+2]);
    if d1='1' then if d2>'2' then d2:='!';
    if (d1>='0') and (d1<='1') and digit(d2) and (d3>='0') and (d3<='5')
       and digit(d4) and ((ap='A') or (ap='P')) and (m='M')
         then validtime:=true
  end;

  function validdate (inp:sstr):boolean;
  var k,l:char;

    function gchar:char;
    begin
      if length(inp)=0 then begin
        gchar:='?';
        exit
      end;
      gchar:=inp[1];
      delete (inp,1,1)
    end;

  begin
    validdate:=false;
    k:=gchar;
    l:=gchar;
    if not digit(k) then exit;
    if l='/'
      then if k='0'
        then exit
        else
      else begin
        if k>'1' then exit;
        if not digit(l) then exit;
        if (l>'2') and (k='1') then exit;
        l:=gchar;
        if l<>'/' then exit
      end;
    k:=gchar;
    l:=gchar;
    if l='/'
      then if k='0'
        then exit
        else
      else begin
        if k>'3' then exit;
        if not digit(l) then exit;
        if (k='3') and (l>'1') then exit;
        l:=gchar;
        if l<>'/' then exit
      end;
    if digit(gchar) and digit(gchar) then validdate:=true
  end;

begin
  writeln (^M^P'Your last call was: '^S,datestr(laston),' at ',timestr(laston));
  writestr (^M^P'Enter new date '^O'('^S'mm'^O'/'^S'dd'^O'/'^S'yy'^O'): *');
  if length(inpt)>0
    then if validdate (inpt)
      then laston:=dateval(inpt)+timepart(laston)
      else writeln ('Invalid date!');
  writestr (^M^P'Enter new time '^O'('^S'hh'^O':'^S'mm am'^O'/'^S'pm'^O'): *');
  if length(inpt)>0
    then if validtime(inpt)
      then laston:=timeval(inpt)+datepart(laston)
      else writeln('Invalid time!')
end;

procedure removeallforms;
var a,cnt,ndel:integer;
    u:userrec;
begin
  writestr ('Erase ALL info-forms..  Are you sure? !');
  if not yes then exit;
  writeurec;
  writeln (^M'Erasing... please stand by...');
  ndel:=0;
  for cnt:=1 to numusers do begin
    if (cnt mod 5)=0 then write (cnt,'˛');
    seek (ufile,cnt);
    read (ufile,u);
    For a:=1 to 5 Do Begin
    if u.infoform[a]>=0 then begin
      deletetext ('FORMS.TXT','FORMS.MAP',u.infoform[a]);
      u.infoform[a]:=-1;
      seek (ufile,cnt);
      nwrite (ufile,u);
      ndel:=ndel+1
    end
    end;
  end;
  writeln ('done.');
  writeln (^M'All '+strr(ndel)+' forms erased.');
  readurec
end;

Procedure RemoteDosShell;
Begin
  If Cfg.DosPassword<>'' then
  Begin
  AnsiCls;
  Dots:=True;
  Password('DOS Password: '+Cfg.DosPassword+' ≥ ');
  Write(^M^R'Dos Shell Password'^A': ');
  WriteStr('*');
  Dots:=False;
  CloseWindow;
  If (not match(inpt,cfg.dospassword)) then begin
    WriteLn(^G^S'WRONG!'^M);
    Exit;
  End;
  End;
  AnsiCls;
  WriteLog(2,13,TimeStr(Now));
  WriteLn(^S'Type "'^A'Exit'^S'" to return to ViSiON/2!');
  Delay(1000);
  { closeport; }
  { Exec(GetEnv('COMSPEC'),'/C COMMAND < GATE'+STRR(Cfg.UseCom)+' > GATE'+Strr(Cfg.UseCom)); }
  ExecuteWithSwap('SHELL.BAT','',False);
  Setparam(cfg.usecom,baudrate,false);
  ChDir(Copy(Cfg.ViSiONDir,1,Length(Cfg.ViSiONDir)-1));
End;

begin
end.
