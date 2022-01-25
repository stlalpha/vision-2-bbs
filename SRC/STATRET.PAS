{$R-,S-,I-,D-,F-,V-,B-,N-,L+ }

unit statret;

interface

uses gentypes,ConfigRt,General,dos;

Type StatRec = Record
      NumCallers : Real;
      ToNext : Longint;
      SysopAvail : Availtype;
      LastDayUp : Sstr;
      NumDaysUp,
      CallsToday : Integer;
      numminsidle,
      numminsused,
      numminsxfer:minuterec;
      timedeventdate:sstr;
      newfeedback,
      newuploads,
      newdownloads,
      newcalls,
      newposts,
      newmail:integer;
      totalfiles,
      totalmsgs:word;
      LastUser,
      AMAuthor : Mstr;
      LastNetTime : Longint;
    End;

    DailyLogRec=Record
      Day:Sstr;
      Calls,
      DLoads,
      ULoads,
      Posts,
      Feedback,
      NewUsers,
      MinsUsed:Integer;
    End;

VAR Status : StatRec;
    Log : DailyLogRec;

function timer:integer;
procedure starttimer (var m:minuterec);
function elapsedtime (var m:minuterec):integer;
procedure stoptimer (var m:minuterec);
procedure writestatus;
procedure readstatus;
procedure writedailylog;
procedure readdailylog;

implementation

function timer:integer;
var r:registers;
begin
  r.ax:=$2c00;
  intr ($21,r);
  timer:=(r.cx shr 8) * 60 + (r.cx and 255)
end;

procedure starttimer (var m:minuterec);
begin
  if m.started then exit;
  m.startedat:=timer;
  m.started:=true
end;

function elapsedtime (var m:minuterec):integer;
var n:integer;
begin
  if not m.started then begin
    elapsedtime:=0;
    m.startedat:=timer;
    exit
  end;
  n:= timer - m.startedat;
  if n<0 then n:=n+1440;
  elapsedtime:=n
end;

procedure stoptimer (var m:minuterec);
begin
  if not m.started then begin
    m.startedat:=0;
    exit
  end;
  m.startedat:=elapsedtime(m);
  m.total:=m.total+m.startedat;
  m.started:=false
end;

procedure writestatus;
var f:file of statrec;
begin
  assign (f,Cfg.VisionDir+'STATUS.DAT');
  rewrite (f);
  write (f,Status);
  close (f);
end;

procedure readstatus;
var f:file of StatRec;
begin
  assign (f,Cfg.VisionDir+'STATUS.DAT');
  reset (f);
  if ioresult<>0 then begin
    close(f);
    FillChar(Status,SizeOf(Status),0);
    Status.tonext:=-1;
    Status.sysopavail:=bytime;
    writestatus;
    exit
  end;
  read (f,status);
  close (f);
End;

Procedure WriteDailyLog;
Var DFile : File Of DailyLogRec;
    Cnt : Integer;
Begin
  Assign(DFile,Cfg.VisionDir+'DAILYLOG.DAT');
  Reset(DFile);
  If IoResult<>0 then Begin
    FillChar(Log,SizeOf(Log),0);
    Log.Day := Datestr(Now);
    Rewrite(DFile);
    Write(DFile,Log);
    Close(DFile);
    Exit;
  End;
  If Log.Day<>DateStr(Now) Then Begin
    If FileSize(Dfile) >= 30 then Begin
       For Cnt:=1 To 30 Do Begin
         Seek(DFile,Cnt);
         Read(DFile,Log);
         Seek(DFile,Cnt - 1);
         Write(DFile,Log);
       End;
       Seek(DFile,29);
       Truncate(DFile);
    End;
    FillChar(Log,SizeOf(Log),0);
    Log.Day:=DateStr(Now);
    Seek(DFile,FileSize(DFile));
    Write(DFile,Log);
  End Else Begin
    Seek(DFile,FileSize(DFile)-1);
    Write(DFile,Log);
  End;
  Close(DFile);
End;

Procedure ReadDailyLog;
Var DFile : File Of DailyLogRec;
Begin
  Assign(DFile,Cfg.VisionDir+'DAILYLOG.DAT');
  Reset(DFile);
  If IoResult<>0 then Begin
    FillChar(Log,SizeOf(Log),0);
    Log.Day := DateStr(Now);
    WriteDailyLog;
    Exit;
  End;
  Seek(Dfile,FileSize(DFile)-1);
  Read(DFile,Log);
  Close(DFile);
  If Log.Day<>DateStr(Now) Then
    WriteDailyLog;
end;

begin
end.