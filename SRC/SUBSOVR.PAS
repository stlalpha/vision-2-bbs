{$R-,S-,I-,D-,F-,V-,B-,N-,L+,O+}

Unit SubsOvr;

Interface

Uses GenTypes;

Procedure PercentBar(First,Z:Mstr);
Procedure UpdateNode(Status:Mstr);
procedure openttfile;
procedure abortttfile (er:integer);
procedure toggleavail;
Procedure ToggleTempSysop;
Procedure ToggleTextTrap;
Procedure Line_Noise;
Procedure Toggle_BottomLine;
Procedure Average(Title,Suffix:Mstr; I,U:Integer);
procedure showinfoforms (uname:mstr; a:byte);  { UNAME='' shows all }

Implementation

Uses Dos, Crt, MNET, ConfigRt, StatRet, GenSubs, Windows, Video, Subs1,
     TextRet, UserRet;

Procedure PercentBar(First,Z:Mstr);
Var B:Byte;
    Temp,Temp2:Real;
    T:LongInt;
Begin
  AnsiColor(9);
  Temp:=0;
  If (RealValu(First)>0) and (RealValu(Z)>0)
   Then Temp:=RealValu(Z) / RealValu(First) * 100;
  If First=Z then Begin
     For B:=1 to 30 Do Write('Ü');
     Write(' 100%');
  End Else
  Begin
    T := Round(Temp);
    Temp2 := T * 30/100;
    T := Round(Temp2);
    For B := 1 to T Do Write('Ü');
    AnsiColor(8);
    For B := T+1 to 30 Do Write('Ä');
    AnsiColor(9);
    Write(' '+streal(round(temp))+'%');
  End;
  AnsiReset;
End;

Procedure UpdateNode(Status:Mstr);
Const DefRec : MultiNodeRec = (Name:'[ Open Line ]';Status:'Waiting For Call';
                               AC:'N/A';Baud:'None');
Var M : MultiNodeRec;
    Stat : Mstr;
Begin
  If NOT IsOpen(MNFile) Then
    Begin
      Assign(MNFile,Cfg.DataDir + 'MULTNODE.DAT');
      Reset(MNFile);
    End;
  If Cfg.NodeNum > Cfg.TotalNodes
    Then Cfg.NodeNum := Cfg.TotalNodes;
  Seek(MNFile,Cfg.NodeNum - 1);
  If Status = '0' Then
    NWrite(MNFile,DefRec)
  Else Begin
    Stat := Status;
    If Stat=''
      Then Stat := 'Browsing..';
    M.Name := Urec.Handle;
    M.Baud := Copy(ConnectStr,1,20);
    M.AC := Copy(Urec.Phonenum,1,3);
    M.Status := Stat;
    NWrite(MNFile,M);
  End;
End;

procedure abortttfile (er:integer);
var n:integer;
begin
  specialmsg ('<Texttrap error '+strr(er)+'>');
  texttrap:=false;
  textclose (ttfile);
  n:=ioresult
end;

procedure openttfile;
var n:integer;
begin
  appendfile ('TEXTTRAP',ttfile);
  n:=ioresult;
  if n=0
    then texttrap:=true
    else abortttfile (n)
end;

procedure toggleavail;
begin
  if status.sysopavail=notavailable
    then status.sysopavail:=available
    else status.sysopavail:=succ(status.sysopavail)
end;

Procedure ToggleTempSysop;
Begin
  If TempSysop
    Then Ulvl := Regularlevel
    Else
      Begin
        RegularLevel := Ulvl;
        Ulvl := Cfg.SysopLevel + 1;
      End;
  TempSysop := Not TempSysop
End;

Procedure Line_Noise;
Var Ran : Byte;
    K : Char;
Begin
 For Ran:=1 to Random(50)+25 Do Begin
   If Ran = 70
     Then Writeln(^G);
   K := Char(Random(254));
   If Ord(K) < 120
     Then K:=Char(Ord(K)+120);
   If WhereX > 79
     Then Writeln(Direct);
   Write(Direct,K);
 End;
End;

Procedure ToggleTextTrap;
var n:integer;
begin
  if texttrap
    then
      begin
        textclose (ttfile);
        n:=ioresult;
        if n<>0 then abortttfile (n);
        texttrap:=false
      end
    else openttfile
end;

Procedure Toggle_BottomLine;
Var X,Y : Byte;
    S : Screens;
Begin
  Case UseBottom Of
    1:Begin
        UseBottom:=2;
        X:=WhereX; Y:=WhereY;
        If WhereY=25 Then Begin
         {WriteCon(#10);
         WriteCon(#13);}
        End;
        InitWinds;
      End;
    2:Begin
        UseBottom:=3;
        ReadScr(S);
        TextMode(Co80+Font8x8);
        WriteScr(S);
        GotoXy(1,25);
        TextAttr:=0;
        ClrEol;
        InitWinds;
        SetUpBottom;
        Bottomline;
      End;
    3:Begin
        UseBottom:=0;
        ReadScr(S);
        x:=wherex; y:=wherey;
        TextMode(Co80);
        WriteScr(S);
        GotoXy(x,y);
        InitWinds;
      End;
    0:Begin
        UseBottom:=1;
        X:=WhereX; Y:=WhereY;
        If WhereY=25 Then Begin
         {WriteCon(#10);
         WriteCon(#13);}
        End;
        InitWinds;
      End;
    End;
    Bottomline;
End;

Procedure Average(Title,Suffix:Mstr; I,U:Integer);
VAR OldX,OldY : Byte;
Begin
  If Title>'' then Writeln(^S'- '+title+' -');
   OldX:=WhereX; OldY:=WhereY;
   If OldY>23 then OldY:=23;
   Tab(^P'You have '^S+strr(U)+^P' '+Suffix+' ',32);
   If U<=I then PerCentBar(Strr(I),Strr(U)) Else PerCentBar(Strr(U),Strr(U));
   Writeln;
   {GoXy(OldX,OldY+1);}
   Tab(^P'Average (All Users) '^S+strr(i)+^P' '+Suffix+' ',32);
   If U<=I
     Then PercentBar(Strr(I),Strr(I))
     Else PercentBar(Strr(U),Strr(I));
   Writeln;
End;

procedure showinfoforms (uname:mstr; a:byte);  { UNAME='' shows all }
var lnum,un,cnt,s:integer;
    u:userrec;

  procedure showone(a:byte);
  var ff:text;
      fn:lstr;
      me:message;
      k:char;
      found:boolean;
  begin
    if u.infoform[a]=-1 then begin
      writeln (^B'That user has no information form.');
      exit
    end;
    fn:=Cfg.textfiledir+'infoform.'+strr(a);
    assign (ff,fn);
    reset (ff);
    if ioresult<>0 then begin
      close (ff);
      lnum:=ioresult;
      writeln (^B'Infoform #'+strr(a)+' is blank');
      exit
    end;
    reloadtext ('FORMS.TXT','FORMS.MAP',u.infoform[a],me);
    writeln (^M,me.text[1],^M^M);
    lnum:=1;
    while not (break or eof(ff)) do begin
      read (ff,k);
      if k='*'
        then if lnum>me.numlines
          then writeln ('No answer')
          else begin
            lnum:=lnum+1;
            writeln (me.text[lnum])
          end
        Else If K='|' then Begin
          Read(ff,k);
          If K <> 'B'
            Then Write('|'+K)
            Else Repeat
                   Read(FF,K);
                 Until (K=';') Or (Eof(FF));
        End Else
          Write (k)
    End;
    Textclose (ff)
  End;

begin
  if uname='' then begin
    writeln (^B^M'          Showing All Forms');
    seek (ufile,1);
    for cnt:=1 to numusers do begin
      nread (ufile,u);
      For s:=1 to 5 do begin
      if u.infoform[s]<>-1 then begin
        writeln (^M^M,u.handle,^M);
        showone(s);
      end;
      end;
      if xpressed then exit
    end
  end else begin
    un:=lookupuser (uname);
    if un=0 then writeln (^B'No such user.') else begin
      seek (ufile,un);
      nread (ufile,u);
      showone(a);
    end
  end
end;

begin
end.