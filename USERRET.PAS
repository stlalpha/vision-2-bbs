{$R-,S-,I-,D-,F-,V-,B-,N-,L+ }

unit userret;

interface

uses dos,MNeT,
     gentypes,gensubs,subs1,configrt,mailret,textret;

Procedure WriteUFile (var u:userrec; n:integer);
Procedure WriteUrec;
Procedure ReadUrec;
Function ValidUName (m:mstr):boolean;
Function LookUpUname (n:integer):mstr;
Function LookUpUser (var uname:mstr):integer;
Function AddUser (var u:userrec):integer;
Procedure RemoveFromNuv(Name:Mstr; Num:Byte);
Procedure DelAllMail (n:integer);
Procedure Deleteuser (n:integer);
Procedure UpdateUserStats (disconnecting:boolean);
Function PostCallRatio (var u:userrec):real;
Function FitsSpecs (var u:userrec; var us:userspecsrec):boolean;

implementation

procedure writeufile (var u:userrec; n:integer);
var i : integer;
begin
  if N=1 then Begin
    If U.Password='' then
    If U.UdLevel=0 then Exit;
  End;
  i := ioresult;
  seek (ufile,n);
  nwrite (ufile,u);
  i := ioresult;
  seek (uhfile,n);
  nwrite (uhfile,u.handle)
end;

procedure writeurec;
begin
  if unum<1 then exit;
  if (urec.handle <> '') And (urec.level < 1)
    then exit;
  urec.level:=ulvl;
  urec.handle:=unam;
  writeufile (urec,unum)
end;

procedure readurec;
begin
  seek (ufile,unum);
  nread (ufile,urec);
  ulvl:=urec.level;
  unam:=urec.handle
end;

function validuname (m:mstr):boolean;
var n:integer;
begin
  if length(m)>0
    then if (m<>'?') and (m[1]<>'#') and (m[1]<>'/') and (m[length(m)]<>'*')
                     and (not match(m,'new')) and (not match(m,'q'))
      then if valu(m)=0
        then validuname:=true
        else begin
          validuname:=false;
          writeln (^B'Invalid user name!')
        end
end;

function lookupuname (n:integer):mstr;
var un:mstr;
begin
  if (n<1) or (n>numusers) then un:='* Unknown *' else begin
    seek (uhfile,n);
    nread (uhfile,un);
    if length(un)=0 then un:='* User Disappeared *'
  end;
  lookupuname:=un
end;

function lookupuser (var uname:mstr):integer;
var cnt,s:integer;
    wildcarding:boolean;
    k:char;
    uh:mstr;
begin
  lookupuser:=0;
  if length(uname)=0 then exit;
  if uname[1]='/'
    then exit;
  if uname[1]='#'
    then delete (uname,1,1);
  wildcarding:=uname[length(uname)]='*';
  if wildcarding then uname[0]:=pred(uname[0]);
  val (uname,cnt,s);
  if (s=0) and (cnt>0) and (cnt<=numusers) then begin
    seek (uhfile,cnt);
    nread (uhfile,uh);
    if length (uh) > 0
    then begin
      lookupuser:=cnt;
      uname:=uh
    end;
    exit
  end;
  If (WildCarding) Then
    If (Unam = '') Or (Ulvl < Cfg.LogonLevel)
      Then Exit;
  Seek (uhfile,1);
  For Cnt := 1 to Numusers do
    begin
      nread (uhfile,uh);
      if wildcarding and (uh<>'')
        then if match(copy(uh,1,length(uname)),uname)
          then
            begin
              write (^B^R,UH,' '^A'Y'^R'es, '^A'N'^R'o, e'^A'X'^R'it: ');
              repeat
                read (k);
                k:=upcase(k)
              until hungupon or (k in ['Y','N','X']);
              writeln (k);
              case upcase(k) of
                'Y':begin
                      lookupuser:=cnt;
                      uname:=uh;
                      exit
                    end;
                 'X':exit
              end
            end
          else
        else if match (uh,uname)
          then
            begin
              lookupuser:=cnt;
              uname:=uh;
              exit
            end
    end
end;

function adduser (var u:userrec):integer;
var un:userrec;
    num,cnt:integer;
    level:integer;
    handle:mstr;
    password:sstr;
label found;
begin
  num:=numusers+1;
  for cnt:=1 to numusers do begin
    seek (ufile,cnt);
    nread (ufile,un);
    if length(un.handle)=0 then
      begin
        num:=cnt;
        goto found
      end
  end;
  if num>maxusers then begin
    adduser:=-1;
    exit
  end;
  numusers:=num;
  found:
  handle:=u.handle;
  level:=u.level;
  password:=u.password;
  fillchar (u,sizeof(u),0);
  u.config:=[lowercase,eightycols,linefeeds,postprompts,ansigraphics,asciigraphics];
  u.color1:=Cfg.Defcolor1;
  u.color2:=Cfg.Defcolor2;
  u.color3:=Cfg.Defcolor3;
  u.color4:=Cfg.Defcolor4;
  u.color5:=Cfg.Defcolor5;
  u.color6:=Cfg.Defcolor6;
  u.color7:=Cfg.Defcolor7;
  If U.UdLevel<>-500 then u.udlevel:=Cfg.Defudlevel;
  u.udpoints:=Cfg.Defudpoints;
  u.dailykblimit:=Cfg.DefDailyKBLimit;
  u.emailannounce:= -1;
  For cnt:=1 to 5 do u.infoform[Cnt]:= -1;
  u.autosig := -1;
  u.displaylen:=25;
  u.handle:=handle;
  u.level:=level;
  u.password:=password;
  writeufile (u,num);
  adduser:=num
end;

Procedure RemoveFromNuv(Name:Mstr; Num:Byte);
VAR N:NuvRec;
    I,X,A:Byte;
BEGIN
  Assign(NuvFile,Cfg.DataDir+'NUV.DAT');
  Reset(NuvFile);
  If IoResult<>0 then Begin
    Close(Nuvfile);
    Exit;
  End;
  I:=FileSize(NuvFile);
  X:=1;
  If Name>'' then Begin
  While (Not (A>0)) or (Not (X>I)) Do Begin
    Seek(NuvFile,X-1);
    nRead(NuvFile,N);
    If Match(N.Who,Name)
      Then A:=X;
    Inc(X);
  End;
  End Else A:=Num;
  If A > 0 Then Begin
    If I = 1 then Erase(NuvFile) Else
    For X:=A To I Do Begin
      Seek(NuvFile,X);
      nRead(NuvFile,N);
      Seek(NuvFile,X-1);
      nWrite(NuvFile,N);
    End;
    Seek(NuvFile,I-1);
    Truncate(NuvFile);
  End;
  Close(NuvFile);
End;

procedure delallmail (n:integer);
var cnt,delled:integer;
    t : text;
    m:mailrec;
    u:userrec;
begin
  cnt:=-1;
  delled:=0;
  repeat
    cnt:=searchmail(cnt,n);
    if cnt>0 then begin
      delmail(cnt);
      dec(cnt);
      inc(delled)
    end
  until cnt=0;
  if delled>0 then writeln (^R'Mail deleted'^A':'^S' ',delled);
  writeurec;
  Assign(T,Cfg.DataDir+'NOTICE.'+Strr(N));
  Erase(T);
  Close(T);
  seek (ufile,n);
  nread (ufile,u);
  For cnt:=1 to 5 do deletetext ('FORMS.TXT','FORMS.MAP',U.Infoform[Cnt]);
  deletetext ('ANNOUNCE.TXT','ANNOUNCE.MAP',u.emailannounce);
  For cnt:=1 to 5 do u.infoform[cnt]:=-1;
  u.emailannounce:=-1;
  writeufile (u,n);
  readurec
end;

procedure deleteuser (n:integer);
var u:userrec;
    cnt:byte;
begin
  delallmail (n);
  fillchar (u,sizeof(u),0);
  For cnt:=1 to 5 do u.infoform[cnt]:=-1;
  u.emailannounce:=-1;
  writeufile (u,n);
  RemoveFromNuv(U.Handle,0)
end;

procedure updateuserstats (disconnecting:boolean);
var timeon:integer;
    f:file;
begin
  with urec do begin
    timeon:=timeontoday;
    timetoday:=timetoday-timeon;
    if timetoday<0 then timetoday:=0;
    totaltime:=totaltime+timeon;
    if tempsysop then begin
      ulvl:=regularlevel;
      writeln (usr,'(Disabling temporary sysop powers)');
      writeurec
    end;
    {
    if disconnecting and (numon=1) then begin
      if (ulvl=1) and (Cfg.level2nd<>0) then ulvl:=Cfg.level2nd;
      if (udlevel=Cfg.Defudlevel) and (Cfg.udlevel2nd<>0) then udlevel:=Cfg.udlevel2nd;
    end;
    }
    if not disconnecting then writedataarea
  end;
  Assign(F,Cfg.TextFileDir+'STATUS.'+Strr(unum));
  Reset(F);
  If IoRESULT = 0 THEN ERASE(F);
  Close(F);
  WriteUREC
end;

function postcallratio (var u:userrec):real;
begin
  if u.numon=0
    then postcallratio:=0
    else postcallratio:=u.nbu/u.numon
end;

function fitsspecs (var u:userrec; var us:userspecsrec):boolean;
var days:integer;
    pcr:real;
    thisyear,thismonth,thisday,t:word;
    lastcall:datetime;

  function inrange (n,min,max:integer):boolean;
  begin
    inrange:=(n>=min) and (n<=max)
  end;

begin
  unpacktime (u.laston,lastcall);
  getdate (thisyear,thismonth,thisday,t);
  days:=(thisyear-lastcall.year)*365+(thismonth-lastcall.month)*30+
        (thisday-lastcall.day);
  pcr:=postcallratio (u);
  fitsspecs:=inrange (u.level,us.minlevel,us.maxlevel) and
             inrange (days,us.minlaston,us.maxlaston) and
             (pcr>=us.minpcr) and (pcr<=us.maxpcr)
end;

end.
