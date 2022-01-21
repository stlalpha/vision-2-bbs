{$R-,S-,I-,D-,F-,V-,B-,N-,L+,O+}

unit mailret;

interface

uses MNeT,gentypes,gensubs,subs1,configrt,statret,textret;

function searchmail (startpt,usernum:integer):integer;
procedure delmail (n:integer);
procedure addmail (sentto:integer; line:longint; return:Boolean; var me:message);
function getnummail (un:integer):integer;

implementation

function searchmail (startpt,usernum:integer):integer;
var cnt:integer;
    m:mailrec;
begin
  searchmail:=0;
  if startpt>=filesize(mfile)-1 then exit;
  startpt:=startpt+1;
  seek (mfile,startpt); che;
  for cnt:=startpt to filesize(mfile)-1 do begin
    nread (mfile,m); che;
    if m.sentto=usernum then begin
      searchmail:=cnt;
      exit
    end
  end
end;

procedure delmail (n:integer);
var m:mailrec;
    c:integer;
begin
  Seek (MFile,n);
  NRead (MFile,m);

  Deletetext ('EMAIL.TXT','EMAIL.MAP',M.Line);

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

procedure addmail (sentto:integer; line:longint; return:boolean; var me:message);
var m:mailrec;
    u:userrec;
begin
  m.return:=return;
  m.sentby:=unam;
  m.anon:=me.anon;
  m.when:=now;
  m.title:=me.title;
  m.line:=line;
  m.sentto:=sentto;
  m.read:=false;
  seek (mfile,filesize(mfile));
  nwrite (mfile,m);
  seek (ufile,sentto);
  nread (ufile,u);
  if match(u.handle,Cfg.sysopname) then status.newmail:=status.newmail+1
end;

function getnummail (un:integer):integer;
var cnt:integer;
    m:mailrec;
    total:integer;
begin
  total:=0;
  seek (mfile,0);
  for cnt:=1 to filesize(mfile) do begin
    nread (mfile,m);
    if m.sentto=un then inc(total);
  end;
  getnummail:=total
end;

begin
end.