{$R-,S-,I-,D-,F-,V-,B-,N-,L+ }

Unit Mainr2;

Interface

Uses GenTypes;

Function ReEdit (Var M : Message; G : Boolean) :Boolean;
Function Editor (Var M : Message;
                 Sendto,
                 GetTitle : Boolean;
                 Sent,
                 BS : Mstr;
                 Txt,Mail : SStr) : Longint;
procedure seekbdfile (n:integer);
procedure writebdfile (var bd:boardrec);
procedure writecurboard;
procedure sendmailto (uname:mstr; anon:boolean);
procedure addfeedback (var m:mailrec);
procedure addlastcaller (n:mstr; LogOff:Boolean);
procedure hangupmodem;
procedure setupmodem;
procedure dialnumber (num:lstr);
procedure disconnect;
procedure randomrumor;
Procedure addnews;

implementation

Uses Crt, Dos, Modem, ConfigRt, GenSubs, Windows, StatRet, TextRet,
     Subs1, SubsOvr, Subs2, UserRet, MailRet, LineEdit, AnsiEdit,
     MainR1, MNeT, Protocol;

function reedit (var m:message; g:boolean):boolean;
begin
  if fseditor in urec.config
    then reedit:=ansireedit (m,g)
    else reedit:=linereedit (m,g);
  trimmessage (m)
end;

Procedure Append_AutoSig(VAR Q : Message);
Var X, Line : Byte;
    A : AutoSig;
Begin
  If (Q.Add_AutoSig = False) Or (Urec.AutoSig < 1) Or (Q.Anon = True)
    Then Exit;
  Return_AutoSig(A);
  Line := 0;
  For X := 1 to 5
    Do If A[x] <> '' Then Line := X;
  If Line > 0 Then Begin
      If Q.Text[Q.NumLines] <> ''
        Then Inc(Q.NumLines,2)
        Else Inc(Q.NumLines);
      For X := 1 to Line Do Begin
        If Q.NumLines < 201
          Then Begin
            Q.Text[Q.NumLines] := A[x];
            Inc(Q.NumLines);
          End
      End
  End
End;

  Function Uploadmsg(Txt,Mail : Sstr) : Longint;
  Var F : Text;
      B : Bulrec;
      tu:mstr;
      me:message;
      sub,name:lstr;
      ls:anystr;
      lne, Trans:integer;
  Begin
    Uploadmsg := -1;
    Name := Cfg.TextDir + 'MESSAGE.XYZ';
    If Yes then Begin
      If Local Then Begin
        Write (^P'Name/Path to Text File'^O': ');
        InputBox(40);
        If Length(Inpt) < 1
          Then exit;
        Name:=Inpt;
        Assign (f,Name);
        Reset (f);
        If IoResult <> 0 Then Begin
          Writeln (^R'Cannot find'^A': '^S+UpString(Name));
          TextClose(f);
          Exit
        End;
        TextClose(F);
      End Else Begin
        If Exist(Name) then Begin
          Assign(f,Name);
          Erase(f);
          TextClose(F);
        End;
        Delay(500);
        Trans := ExecProto(1,Cfg.TextDir + 'MESSAGE.XYZ','');
        If Trans <> 0 Then Begin
          Writeln(^G^G'Aborted or Error!');
          If Exist(Name) Then Begin
            Assign(F,Name);
            Erase(f);
            TextClose(f);
            Exit;
          End;
        End;
    End;
    lne := 0;
    Me.anon:=false;
    Me.numlines:=lne;
    Me.note:=urec.sysopnote;
    B.Line:=maketext(txt,mail,me,Name);
    Uploadmsg:=b.line;
    B.replies:=0;
    B.repnumber:=0;
    B.anon:=false;
    B.origin1:='';{Strng^.Origin1;}
    B.origin2:='';{Strng^.Origin2;}
    B.V2_Net:=False;
    B.FidoNet:=False;
    B.RealName:=Urec.RealName;
    B.when:=now;
    B.leftby:=unam;
    B.status:=urec.sysopnote;
    B.recieved:=false;
    B.sentto:=tu;
    B.line:=lne;
    B.plevel:=ulvl;
    inc(Status.newposts);
    inc(Status.totalmsgs);
    inc(unreadnewmsgs);
    inc(Log.Posts);
    writeln(^M^R'þ '^S'Message has been saved...');
  end;
End;


Function Editor (Var M : Message;
                 Sendto,
                 GetTitle : Boolean;
                 Sent,
                 BS : Mstr;
                 Txt,Mail : SStr) : longint;

Var Post : Boolean;
    Cnt  : Byte;

  Function GetTheTitle : Boolean;
  Var Cnt   : Byte;
      Check : Mstr;
  begin
    post:=true;
    m.anon:=false;
    getthetitle:=true;
    If okfortitle then begin
      Writeln(^B);
      MultiColor(Strng^.MsgTitleStr);
      NoCRInput('Aborted!',30);
        if length(inpt)=0 then begin
          getthetitle:=false;
          exit
        end;
        m.title:=inpt;
     End;

    okfortitle:=True;

    if gettitle then begin
      buflen:=24;
      if sendto and (length(sent)=1)
        then begin
          MultiColor(Strng^.MsgToStr);
          NoCRInput('All',24);
          if length(inpt)=0 then m.sendto:='All'
          else m.sendto:=inpt;
        end else m.sendto:='The SysOp''s';
      if bs='EMAIL' then begin
          m.title:='Announcement';
          m.sendto:=urec.handle;
          exit;
      end;
     If Sent <> '0'
       Then M.SendTo := Sent;
     If Bs <> '0' Then Begin
        M.Title := Bs;
        Exit;
     End;
     If Ulvl >= Cfg.AnonymousLevel
     Then Begin
       DefYes := False;
       Writestr (Strng^.MsgAnonStr);
       M.Anon := Yes
     End;
     DefYes := False;
     Writestr (Strng^.UploadMsgStr);
     If Yes Then Begin
       Editor := Uploadmsg(Txt,Mail);
       Post   := False;
     End
    End
  End;

Var B : Boolean;
begin
  Editor := -1;
  M.Numlines := 0;
  M.Note := Urec.SysopNote;
  If Not SendTo Then Begin
    M.Sendto := 'All';
    M.Title := 'Message To All';
  End;
  If Match(bs,'EMAIL') Then M.Title := 'Announcement';
  B := True;
  Post := True;
  If GetTitle then
    B := Getthetitle;
  If Not Post
    Then Exit;
  If B Then If
   ReEdit(M,GetTitle) Then Begin
     If M.Add_AutoSig
       Then Append_AutoSig(M);
     Editor := MakeText(Txt,Mail,M,'');
   End;
End;

procedure seekbdfile (n:integer);
begin
  seek (bdfile,n);
  seek (bifile,n); che
end;

procedure writebdfile (var bd:boardrec);
begin
  write (bdfile,bd);
  write (bifile,bd.shortname)
end;

procedure writecurboard;
begin
  seekbdfile (curboardnum);
  writebdfile (curboard); che
end;

procedure sendmailto (uname:mstr; anon:boolean);
var un:integer;
    me:message;
    line:longint;
    u:userrec;
    return:boolean;
begin
  if length(uname)=0 then exit;
  un:=lookupuser (uname);
  if un=0 then writeln ('User not found.') else begin
    if anon and (ulvl<Cfg.sysoplevel) then uname:=Cfg.anonymousstr;
    seek (ufile,un);
    read (ufile,u);
    if u.emailannounce>-1 then begin
      Writehdr (u.handle+'''s Announcement');
      Printtext ('ANNOUNCE.TXT','ANNOUNCE.MAP',U.EmailAnnounce)
    end;
    writehdr ('Sending mail to '+uname);
    OkForTitle:=True;
    line:=editor(me,false,true,unam,'0','EMAIL.TXT','EMAIL.MAP');
    if line>=0 then Begin
      WriteStr('Would you like to be notified when '+UName+' receives this? !');
      Return:=Yes;
      addmail (un,line,return,me)
    End
  end
end;

procedure addfeedback (var m:mailrec);
var ffile:file of mailrec;
begin
  assign (ffile,Cfg.DATADIR+'FEEDBACK');
  reset (ffile);
  if ioresult<>0 then begin
    close (ffile);
    rewrite (ffile)
  end;
  seek (ffile,filesize(ffile));
  write (ffile,m);
  close (ffile);
  Status.newfeedback:=Status.newfeedback+1;
end;

  procedure addlastcaller (n:mstr; LogOff:Boolean);
  var qf:file of lastrec;
      last,cnt,A:integer;
      l:lastrec;
  begin
    If N<>'' then else Exit;
    Cnt:=LookUpUser(N);
    If Cnt<=0 then Exit;
    If Urec.Level<=1 then N:=N+' *NEW*';
    If (keepquite) and (local) then exit;
    If connectstr='' then exit;
    assign (qf,Cfg.DATADIR+'Callers');
    reset (qf);
    if ioresult<>0 then rewrite (qf);
    last:=filesize(qf);
    if last>maxlastcallers then last:=maxlastcallers;
    If Last>19 Then Begin
      Seek(QF,19);
      Truncate(QF);
      Last:=19;
    End;
    If Not LogOff Then Begin
      for cnt:=last-1 downto 0 do begin
        seek (qf,cnt);
        read (qf,l);
        seek (qf,cnt+1);
        write (qf,l)
      end;
      with l do begin
        name:=n;
        ac:=Copy(Urec.PhoneNum,1,3);
        when:=now;
        callnum:=Urec.numon;
        baud:=connectstr;
        MinsOn:=0;
      end;
    End Else Begin
      Seek(Qf,0);
      Read(Qf,L);
      L.MinsOn:=Timer - LogonTime + 1;
    End;
    seek (qf,0);
    write (qf,l);
    close (qf);
    Log.MinsUsed:=Log.MinsUsed+(timer - logontime);
  end;

procedure hangupmodem;
var tries:integer;
begin
  tries:=0;
  if local then begin
    closeport;
    ensureclosed;
    halt(2);
  end Else
  while carrier and (tries < 5) do begin
    hangup;
    sendmodemstr (Cfg.modemhangupstr,false);
    tries:=tries+1
  end;
  If Carrier Then HangUp;
  setparam (Cfg.usecom,baudrate,parity)
end;

procedure setupmodem;
begin
  GotoXy(1,17);
  TextAttr:=1;
  if carrier then BEGIN
    WriteLn(usr,'Carrier detected; attempting connection');
    exit;
    End;
{  TextAttr:=11;
  Writeln(usr,Fossil_Descrip(Cfg.usecom));
  Writeln; }
  GotoXy(1,17);
  TextAttr:=1;
  Write(usr,'þ ');
  TextAttr:=9;
  write (usr,'Initializing Modem - COM');
  writeln(usr,Cfg.usecom);
  TextAttr:=9;
  sendmodemstr (Cfg.modemsetupstr,true);
{  if Cfg.hashayes then sendmodemstr ('|~~ATS0=0M0Q0V0X1|',true); }
end;

procedure dialnumber (num:lstr);
begin
{  sendmodemstr (Cfg.modemdialprefix+num+Cfg.modemdialsuffix,true) }
end;

procedure disconnect;
begin
  updatenode('0');
  If unum > 0 Then Begin
   urec.lastnummsgs:=Status.totalmsgs;
   urec.lastnumfiles:=Status.totalfiles;
   addlastcaller(unam,True);
  End;
  WriteStatus;
  WriteDailyLog;
  if online then hangupmodem;
  online:=true;
  writelog (0,3,'');
  if (unum>0) and not disconnected then updateuserstats (true);
  disconnected:=true;
end;

procedure randomrumor;

  function numrumors:integer;
  begin
    numrumors:=filesize(rfile)
  end;

  procedure seekrfile (n:integer);
  begin
    seek (rfile,n-1)
  end;

procedure showit (n:integer);
var rr:rumorrec;
    go,i:byte;

begin
   seekrfile (n);
   NRead (rfile,rr);
   if ulvl<rr.level then exit;
   i:=TrueLength(rr.rumor);
   i:=i+1;
   go:=(80-i) Div 2;
   If go<1 then go:=0;
   Writeln;
   Write(direct,#13+#27+'[',go,'C'); {Pushes Cursor forward 'go' times}
   Write(^R+Cfg.RumChar[1]);
   Subs1.MultiColor(rr.rumor);
   Writeln(^R+Cfg.RumChar[2]);
   ansireset;
end;

procedure openrfile;
begin
  assign(rfile,cfg.datadir + 'RUMORS.DAT');
  if exist(cfg.datadir + 'RUMORS.DAT')
    then reset(rfile)
    else rewrite(rfile);
end;

var x:integer;
begin
{ if (Cfg.UseRumors<1) or ((Cfg.UseRumors=1) and (CurSection<>MainSysOp)) then exit; }
 If Not (showrumors in urec.config) then exit;

 if not isopen(rfile) then
   openrfile;

 if numrumors < 1 then begin
  write (^M^R+Cfg.Rumchar[1]);
  writeln (^S'No rumors exists at the moment'+Cfg.RumChar[2]);
  ansireset;
 end else
 begin
  seekrfile (1);
  randomize;
  x:=random (numrumors+1);
  If x<1 then X:=1;
  showit (x);
 end;
{ close (rfile); }
 ansireset;
end;

Procedure addnews;
Var newline,r:longint;
    ntmp,atmp:newsrec;
    numnews,cnt:Integer;
    m:message;
    t:text;
Begin
  writehdr('Adding to the news');
  Writestr(^P'Minimum Level to read news '^O'['^S'1'^O']: *');
  If inpt='' Then inpt:='1';
  ntmp.level:=Valu(inpt);
  Writestr(^P'Maximum Level to read news '^O'['^S'32767'^O']: *');
  If inpt='' Then inpt:='32767';
  ntmp.maxlevel:=valu(inpt);
  Writeln(^R'('^S'Yes = User will see news if has not seen it; No = ALWAYS displayed'^R')');
  WriteStr(^P'Display this just once to every user? !');
  Ntmp.Always:=Not Yes;
  Write(^P'News Author'^O' ['^S'CR/'+Unam+^O']: '); NoCRInput(Unam,25);
  If inpt='' then NTmp.from:=Unam else NTmp.from:=inpt;
  OkForTitle:=True;
  NewLine:=editor(m,false,true,'0','0','NEWS.TXT','NEWS.MAP');
  Ntmp.when:=now;
  Ntmp.title:=m.title;
  Ntmp.location:=newline;
  If newline<0 Then exit;
  r:=IOResult;
  Assign(nfile,Cfg.DATADIR+'News');
  Reset(nfile);
  r:=IOResult;
  If r<>0
  Then Begin
    If r<>1 Then WriteLn(^S'NEWS File has been created...');
    Rewrite(nfile);
    Write(nfile,ntmp);
    numnews:=0
  End Else Begin
    numnews:=FileSize(nfile);
    For cnt:=numnews-1 Downto 0 Do
    Begin
      Seek(nfile,cnt);
      Read(nfile,atmp);
      Seek(nfile,cnt+1);
      Write(nfile,atmp)
    End;
    che;
    Seek(nfile,0);
    Write(nfile,Ntmp)
  End;
  WriteLn(^P'News added!  Total News items'^O': '^S+Strr(numnews+1));
  writelog(2,1,'');
  Close(nfile);
End;

begin
end.
