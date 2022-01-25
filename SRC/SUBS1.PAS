{$R-,S-,I-,D-,F-,V-,B-,N-,L+}

UNIT Subs1;

INTERFACE

Uses SwapUnit, Crt, Dos, PAVT150, BufIO, GenSubs, GenTypes,
     StatRet, ConfigRt, Modem;

CONST BAD1 = '´——Žü˜•‰÷™“ô…›‚™€€âþëƒšè„“—–†Œ•Œæžèòéÿþñäâðæöö';
      BAD2 = '¶–”“•õëø”—›ô‘—ñ‚Š‰„ŸŸ›ƒæ‡ãŽŽëÿþèòôþ˜ôäüùàýÿ';
      BAD3 = '¢“Ÿ™™ûšùíçãøâáàüæ÷þùâëž‰‰åŒ—à';

      MultiTasking : Boolean = TRUE;

Type StrRec = Record
       C : Array[1..15] of String[2];
       S : Array[1..15] of Lstr;
       T : Array[1..15] of Byte;
     End;

Var FirstVariable,

    Usebottom : Byte;

    Local,
    Online,
    ChatMode,
    Disconnected : Boolean;

    Unum,
    Ulvl : Integer;

    Baudrate : Longint;
    Unam : Mstr;
    BaudStr : Mstr;
    Parity : Boolean;
    Urec : UserRec;

    LogonTime,
    LogoffTime,
    LogonUnum : Integer;
    Laston : Longint;

    Dots,
    Nochain,
    Break,
    XPressed,
    Requestchat,
    RequestCom,
    RequestBreak,
    ReqSpecial,
    ForceHangup,
    Modeminlock,
    Modemoutlock,
    Timelock,
    TempSysop,
    SplitMode,
    Fromdoor,
    Texttrap,
    PrinterEcho,
    UseLineFeeds,
    UseCapsonly,
    DontStop,
    NoBreak,
    WordWrap,
    BeginWithSpacesOK,
    SysNext,
    InGetStr,
    No_Local_Output : Boolean;

    RegularLevel,
    NumUsers,
    CurBoardnum,
    Lasty,
    LineCount,
    Curattrib,
    Firstfree,
    LockedTime,
    IoCode,
    Buflen : integer;

    ScreenSeg : Word;

    CurSection : Configtype;
    CurboardName : Sstr;

    Inpt,
    Chainstr : Anystr;

    Chatreason,
    Lastprompt,
    Errorparam,
    ErrorProc : Lstr;

    Curboard : Boardrec;

    Mes : Message;

    Syslogdat : Array [0..maxsyslogdat] of syslogdatrec;

    NumSysLogDat : Integer;
    ReturnTo     : Char;
    ConnectBaud  : Longint;
    OkForTitle   : Boolean;
    UnReadNewMsgs,
    CharsUsed,
    ReplyNum     : Integer;
    MCStrLength  : Byte;
    LastMsgConf,
    LastFileConf,
    MsgConf,
    FileConf     : ShortInt;
    TotalSent,
    TotalReceived: Longint;
    LastMenu     : SStr;
    IOErrors     : Array[1..48] of Mstr;
    LastVariable : Byte;

    Sr           : StrRec;

    NameValue    : Longint;
    BBSValue     : Longint;

    Non_Stop,
    CheckPageLength : Boolean;
    Emul            : EmulationRec;
    USR, Direct, DirectIN, Display : Text;

{ (R) 82 Xor 255 = 173 }
{ (E) 69 Xor 234 = 175 }
{ (G) 71 Xor 243 = 180 }
{ (D) 68 Xor 237 = 169 }
{ (A) 65 Xor 222 = 159 }
{ (T) 84 Xor 234 = 190 }
{ (A) 65 Xor 250 = 187 }

Const Numsysfiles = 28;
      RegKey = 8682025;
      Tasker : (TaskView_,             {taskview/omniview/topview/desqview}
                DoubleDos_,            {doubledos}
                NoTasker,              {single task}
                Unknown) = Unknown;    {before first call}

Var TextFile : File of Lstr;
    MailFile : File of MailPtrRec;
    UFile    : File of UserRec;
    UHFile   : File of Mstr;
    MFile    : File of MailRec;
    UDFile   : File of UDRec;
    UDIndex  : File of UDIndexREC;
    AFile    : File of Arearec;
    BFile    : File of Bulrec;
    BDFile   : File of Boardrec;
    BiFile   : File of Sstr;
    ScanFile : File of NewScanRec;
    Tofile   : File of TopicRec;
    CHFile   : File of choicerec;
    DDFile   : File of Baserec;
    EFile    : File of entryrec;
    DoFile   : File of DoorRec;
    GFile    : File of GroupRec;
    Logfile  : File of Logrec;
    USDile   : File of UserSpecsRec;
    RFile    : File of RumorRec;
    NFile    : File Of NewsRec;
    NUVFile  : File Of NuvRec;
    MNFile   : File Of MultiNodeRec;
    BLFile   : File Of BBSRec;
    MNIFile  : File Of Node_Message;
    EMUFile  : File of EmulationRec;
    FFile    : File of MailRec;

    SysFiles : Array [1..NumSysFiles] of File Absolute Textfile;

    TTFile : Text;

Function UnReg : Mstr;
Procedure UnCrunch (var Addr1,Addr2; BlkLen:Integer);
Function ScreenColor ( X,Y : Byte) : Byte;
Function B_(X:Byte):Sstr;
Function diskspace(path:lstr; total:boolean):real;
function truelength(M:Lstr):Byte;
Procedure MultiColor(M:String);
procedure writelog (m,s:integer; prm:lstr);
procedure files30;
function ioerrorstr (num:integer):lstr;
procedure error (errorstr,proc,param:lstr);
procedure fileerror (procname,filename:mstr);
procedure che;
Procedure Bad_User;
function timeleft:integer;
function timetillevent:integer;
function timetillnet:integer;
procedure settimeleft (tl:integer);
procedure tab (n:anystr; np:integer);
function yes:boolean;
function yesno (b:boolean):sstr;
function timeontoday:integer;
function isopen (var ff):boolean;
procedure textclose (var f:text);
procedure close (var ff);
function withintime (t1,t2:sstr):boolean;
function hungupon:boolean;
function sysopisavail:boolean;
function sysopavailstr:sstr;
function singularplural (n:integer; m1,m2:mstr):mstr;
function s (n:integer):sstr;
function numthings (n:integer; m1,m2:mstr):lstr;
procedure thereisare (n:integer);
procedure thereare (n:integer; m1,m2:mstr);
procedure assignbdfile;
procedure openbdfile;
procedure formatbdfile;
procedure closebdfile;
procedure opentempbdfile;
procedure closetempbdfile;
function keyhit:boolean;
function bioskey:char;
procedure readline (var xx);
procedure writereturnbat;
procedure ensureclosed;
procedure close_them_all(var ff);
procedure clearbreak;
procedure ansicolor (attrib:integer);
procedure ansireset;
procedure specialmsg (q:anystr);
procedure writedataarea;
function bars_ok : boolean;
procedure readdataarea;
Procedure Color(Foreground,Background : Byte);
Function Percentage(A,B:Integer) : Real;
Procedure executewithswap(ProgName : LStr; CommandLine : AnyStr; Force:Boolean);
function lget_ms: longint;
procedure delay(ms: longint);
procedure give_up_time;
function total_valu(s:string) : longint;

implementation

{ (R) 82 Xor 255 = 173 }
{ (E) 69 Xor 234 = 175 }
{ (G) 71 Xor 243 = 180 }
{ (D) 68 Xor 237 = 169 }
{ (A) 65 Xor 222 = 159 }
{ (T) 84 Xor 234 = 190 }
{ (A) 65 Xor 250 = 187 }

    Function UnReg : Mstr;
    VAR Temp:Mstr;
    Begin
      Temp[0]:=#0;
      Temp:=Temp + Chr(49 Xor 100);
      Temp:=Temp + Chr(213 Xor 187);
      Temp:=Temp + Chr(186 Xor 200);
      Temp:=Temp + Chr(182 Xor 211);
      Temp:=Temp + Chr(185 Xor 222);
      Temp:=Temp + Chr(255 Xor 150);
      Temp:=Temp + Chr(161 Xor 210);
      Temp:=Temp + Chr(202 Xor 190);
      Temp:=Temp + Chr(182 Xor 211);
      Temp:=Temp + Chr(186 Xor 200);
      Temp:=Temp + Chr(182 Xor 211);
      Temp:=Temp + Chr(172 Xor 200);
      UnReg:=Temp;
    End;


Procedure UnCrunch (var Addr1,Addr2; BlkLen:Integer);
Begin
  InLine ($1E/$C5/$B6/Addr1/$C4/$BE/Addr2/$8B/$8E/BlkLen/$8B/$D7/
          $B4/$00/$AC/$3C/$10/$73/$07/$80/$E4/$F0/$0A/$E0/$EB/$44/
	  $3C/$18/$74/$13/$73/$19/$2C/$10/$02/$C0/$02/$C0/$02/$C0/
	  $02/$C0/$80/$E4/$0F/$0A/$E0/$EB/$2D/$81/$C2/$A0/$00/$8B/
	  $FA/$EB/$25/$3C/$1A/$75/$0B/$AC/$49/$51/$32/$ED/$8A/$C8/
	  $AC/$EB/$0D/$90/$3C/$19/$75/$11/$AC/$51/$32/$ED/$8A/$C8/
	  $B0/$20/$0B/$C9/$74/$03/$AB/$E2/$FD/$59/$49/$AB/$0B/$C9/
	  $74/$02/$E2/$AA/$1F);
End;

Function ScreenColor ( X,Y : Byte) : Byte;
Begin
  ScreenColor := Mem[ $B800 : X * Y - 1 ];
End;

Function B_(X:Byte):Sstr;
VAR B:Byte;
Begin
  B_:=#27+'['+Strr(X)+'D';
End;

    Function diskspace(path:lstr; total:boolean):real;
    Var drive:Byte;
      r:registers;
      csize,free,totalsize:Real;

    Function unsigned(i:Integer):Real;
    Begin
      If i >= 0
      Then unsigned:=i
      Else unsigned:=65536.0+i
    End;

    Begin
      r.ah:=$36;
      r.dl:=Ord(UpCase(path[1]))-64;
      Intr($21,r);
      If r.ax=-1 Then Begin
        WriteLn('Invalid drive');
        exit
      End;
      csize:=unsigned(r.ax)*unsigned(r.cx);
      free:=csize*unsigned(r.bx);
      totalsize:=csize*unsigned(r.dx);
      If total then diskspace:=totalsize else diskspace:=free;
    End;

procedure ansicolor (attrib:integer);
var tc:integer;
    W:Byte;
    Temp:String[3];
const colorid:array [0..7] of byte=(30,34,32,36,31,35,33,37);
begin
  If AVATAR in Urec.Config Then Begin
    Temp := Strr(Attrib);
    If Online Then SendChar(^V);
    Parse_Avt1(^V);
    If Online Then SendChar(^A);
    Parse_Avt1(^A);
    If Online Then SendChar(Chr(Attrib));
    Parse_Avt1(Chr(Attrib));
    CurAttrib := Attrib;
    Exit;
  End;
  if attrib=0 then begin
    textcolor (7);
    textbackground (0)
  end else begin
    textcolor (attrib and $8f);
    textbackground ((attrib shr 4) and 7)
  end;
  if not (ansigraphics in urec.config) or (attrib=0) or (usecapsonly)
     or (attrib=curattrib) or break then exit;
  curattrib:=attrib;
  write (direct,#27'[0');
  tc:=attrib and 7;
  if tc<>7 then write (direct,';',colorid[tc]);
  tc:=(attrib shr 4) and 7;
  if tc<>0 then write (direct,';',colorid[tc]+10);
  if (attrib and 8)=8 then write (direct,';1');
  if (attrib and 128)=128 then write (direct,';5');
  write (direct,'m')
end;

Procedure Color(Foreground,Background : Byte);
var kr:integer;
Begin
  KR := ForeGround + (BackGround SHL 4);
  ansicolor(kr);
End;

Procedure Bad_User;

  Procedure Show(S:STRING);
  VAR X : BYTE;
  BEGIN
    FOR X := 1 TO LENGTH(S) DO
      SendCHAR(CHAR (BYTE(S[X]) XOR ($FF - X - $1E)));
    SendCHAR(Char(20 XOR 25));
    SendCHAR(Char(19 XOR 25))
  END;

  Procedure Lock_UP;
  CONST X : Byte = 1;
  BEGIN
    REPEAT
      REPEAT
      UNTIL X=0;
    UNTIL X<0
  END;

BEGIN
  Show(BAD1);
  Show(BAD2);
  Show(BAD3);
  IF TOTAL_VALU(BAD1) <> (4348 + 4349)
    THEN Lock_UP;
END;

Function TrueLength(M:Lstr) : Byte;
Var temp,bad,i:Byte;
Begin
  TrueLength := 0;
  I := 1;
  Temp := 0;
  Bad  := 0;
    While I<=Length(M) Do Begin
       If M[i]='|' then
       Begin
        Inc(Bad,3);
        Inc(I,3);
       End Else
       inc(i);
    End;
  If POS('|UH',M)>0 then Temp:=Length(Urec.Handle);
  TrueLength:=Length(M)-bad+Temp;
End;

Procedure MultiColor(M:String);
Const HexStr = '0123456789ABCDEF';
Var X, Z, ForeGround, BackGround : Byte;
    A : String[2];
    SChar : Char;

    Function ConvertHex (S:Sstr) : Byte; { PCB COLOR CODES ARE LAME!! -CB}
    Var X : Byte;
    Begin
      X := Pos(S[1],HexStr) - 1;
      X := (X Shl 4) + Pos(S[2],HexStr) - 1;
      ConvertHex := X;
    End;

Var PCB : String[2];
Begin
  ClearBreak;
  X := 1;
  McStrLength := 0;
  BackGround := 0;
  ForeGround := Urec.Color1;
  While X <= Length(M)
  Do Begin
    Case M[X] Of
      '@' : If X < ( Length(M) - 3)
            Then Begin
              Inc(X);
              If (M[X] = 'X')
              And ( Pos(M[X + 1],HexStr) > 0)
              And ( Pos(M[X + 2],HexStr) > 0)
              Then Begin
                Inc(X);
                PCB := M[X];
                Inc(X);
                PCB := PCB + M[X];
                Inc(X);
                AnsiColor(ConvertHex(PCB));
              End
                Else Write('@');
            End Else Begin
              Write(M[X]);
              Inc(X);
            End;
      '$':Begin
           Inc(X);
           Case M[X] Of
             'a':ansicolor(0);
             'b':ansicolor(1);
             'g':ansicolor(2);
             'c':ansicolor(3);
             'r':ansicolor(4);
             'p':ansicolor(5);
             'y':ansicolor(6);
             'w':ansicolor(7);
             'A':ansicolor(8);
             'B':ansicolor(9);
             'G':Ansicolor(10);
             'C':Ansicolor(11);
             'R':ansicolor(12);
             'P':ansicolor(13);
             'Y':ansicolor(14);
             'W':ansicolor(15);
             Else Write('$' + M[x]);
           End;
           Inc(X);
          End;
      '|':Begin
            A[0]:=#0;
            Inc(X);
            A:=M[x];
            Inc(X);
            A:=A+M[x];
            A:=UpString(A);
            If A[1]='@' Then Begin
              SChar:=A[2];
              A[0]:=#0;
              Inc(X);
              While (Length(A)<3) and (M[x] in ['0'..'9'])
              Do Begin
                A := A+M[X];
                Inc(X);
              End;
              Dec(X);
              For Z:=1 to Valu(A) Do Write(Direct,Schar);
            End Else If
             A='C1' then AnsiColor(Urec.Color1) Else If
             A='C2' then AnsiColor(Urec.Color2) Else If
             A='C3' then AnsiColor(Urec.Color3) Else If
             A='C4' Then AnsiColor(Urec.Color4) Else If
             A='C5' Then AnsiColor(Urec.Color5) Else If
             A='C6' Then Ansicolor(Urec.Color6) Else If
             A='C7' Then ansiColor(Urec.Color7) Else If
             A='TL' then write (strr(timeleft)) Else if
             A='TN' then write (timestr(now)) Else if
             A='UH' then write (urec.handle) Else if
             A='CR' then writeln Else if
             A=Sr.C[1] Then If (Sr.C[1]<>'OR') and (Sr.C[1]<>'MN')
               Then Write(Sr.S[1]) Else MultiColor(Sr.S[1]) Else If
             A=Sr.C[2] then Write(Sr.S[2]) Else If
             A=Sr.C[3] then Write(Sr.S[3]) Else
             If (A[1]='B') and (A[2] in ['0'..'7']) Then Begin
               AnsiColor(Valu(A[2]) * 16 + ForeGround);
               BackGround:=Valu(A[2]);
             End Else
             If (Valu(A) in [1..15]) Then Begin
               AnsiColor(BackGround * 16 + Valu(A));
               ForeGround:=Valu(A);
             End Else
               Write('|'+A);
             Inc(X);
          End;
      #0..#255 : Begin
        Inc(McStrLength);
        Write(Direct,M[x]);
        Inc(X);
      End
    End
  End
End;

procedure writelog (m,s:integer; prm:lstr);
var n:integer;
    l:logrec;
begin
  with l do begin
    menu:=m;
    subcommand:=s;
    when:=now;
    param:=copy(prm,1,41)
  end;
  if not isopen(logfile) then
    begin
      assign (logfile,cfg.VisionDir+'SYSLOG');
      reset (logfile);
      if ioresult<>0 then begin
        rewrite (logfile);
        if ioresult<>0 then begin
          writeln (usr,'system error: cannot write to log');
          exit
        end
      end
    end;
  seek (logfile,filesize(logfile));
  write (logfile,l)
end;

procedure files30;
begin
  writeln (usr,'You MUST put FILES=30 in your CONFIG.SYS!');
  exit;
end;

function ioerrorstr (num:integer):lstr;
var tmp:lstr; ok:boolean;
    x:string[3];
    n,s:integer;
begin
  If Num=243 then files30;
  ok:=false;
  For n:=1 to 50 Do Begin
    X:=Copy(Ioerrors[N],1,3);
    S:=Valu(X);
    If S=Num then Begin
      ok:=true;
      Tmp:=Copy(Ioerrors[N],5,40);
      IoErrorStr:=^R'('^S'ERROR'^A': '^S+Strr(Num)+' - '+Tmp+^R')';
    End;
  End;
  If Not ok then ioerrorstr:='ERROR: Cannot be identified!';
end;

procedure error (errorstr,proc,param:lstr);
var p,n:integer;
    pk:char;
    tf:text;
begin
  n:=ioresult;
  repeat
    p:=pos('%',errorstr);
    if p<>0 then begin
      pk:=errorstr[p+1];
      delete (errorstr,p,2);
      case upcase(pk) of
        '1':insert (param,errorstr,p);
        'P':insert (proc,errorstr,p);
        'I':insert (ioerrorstr(iocode),errorstr,p)
      end
    end
  until p=0;
  assign (tf,Cfg.DATADIR+'ErrLog');
  append (tf);
  if ioresult<>0
    then
      begin
        textclose (tf);
        rewrite (tf)
      end;
  Writeln(tf,#27+'[1;33m'+DateStr(now)+' - '+TimeStr(Now)+#27+'[1;37m: '+#27+'[1;36m'+unam+' was Online When'+#27+'[0;36m:');
  writeln (tf,#27+'[1;32m'+errorstr);
  writeln (tf);
  textclose (tf);
  n:=ioresult;
  writelog (0,4,errorstr);
  writeln (errorstr)
end;

procedure fileerror (procname,filename:mstr);
begin
  error ('%I accessing %1 in %P',procname,filename)
end;

procedure che;
var i:integer;
begin
  i:=ioresult;
  case i of
    0:;
    4:files30;
    else
      begin
        iocode:=i;
        error ('','','')
      end
  end
end;

function timeleft:integer;
var timeon:integer;
begin
  timeon:=timer-logontime;
  if timeon<0 then timeon:=timeon+1440;
  timeleft:=urec.timetoday-timeon
end;

function timetillevent:integer;
var n:integer;
begin
  if (length(Cfg.eventtime)=0) or (length(Cfg.eventbatch)=0) or
    (status.timedeventdate = datestr(now))
    then n:=1440
    else n:=timeval(Cfg.eventtime)-timer;
  if n < 0 then n:=n+1440;
  timetillevent:=n
end;

function TimeTillNet : Integer;
Var N : Integer;
Begin
  TimeTillNet := TimeTillEvent;
{  if ( Length(Cfg.NetStc) = 0)
  or ( DateStr(Status.LastNETTime) = Datestr(Now) )
    Then N := 1440
    Else N := TimeVal (Cfg.NetStc) - Timer;
  If N < 0
    Then N := N + 1440;
  TimeTillNet := N; }
end;

procedure settimeleft (tl:integer);
begin
  {If LogonTime<1 Then LogonTime:=0;}
  urec.timetoday:=timer+tl-logontime
end;

procedure tab (n:anystr; np:integer);
var cnt:integer;
begin
  write (n);
{  Cnt:=np - length(n) -1;
  If (CNT<1) or (Cnt>4) then Begin }
  for cnt:=length(n) to np-1 do write (' ')
{  End Else Write(#27+'['+strr(cnt)+'C');}
end;

function yes:boolean;
begin
  if length(inpt)=0
    then yes:=false
    else yes:=upcase(inpt[1])='Y'
end;

function yesno (b:boolean):sstr;
begin
  if b
    then yesno := 'Yes'
    else yesno := 'No '
end;

function timeontoday:integer;
var timeon:integer;
begin
  timeon:=timer-logontime;
  if timeon<0 then timeon:=timeon+1440;
  timeontoday:=timeon
end;

function isopen (var ff):boolean;
var fi : fib absolute ff;
begin
  isopen := fi.handle <> 0
end;

procedure textclose (var f:text);
var n:integer;
    fi:fib absolute f;
begin
  if isopen(f)
    then system.close (f);
  fi.handle:=0;
  n:=ioresult
end;

procedure close (var ff);
var f:file absolute ff;
    fi:fib absolute ff;
    n:integer;
begin
  if isopen(f)
    then system.close (f);
  fi.handle:=0;
  n:=ioresult
end;

function withintime (t1,t2:sstr):boolean;
var t,a,u:integer;
begin
  t:=timer;
  If ((t1='') or (t2='')) then begin
    withintime:=false;
    exit;
  end;
  a:=timeval(t1);
  u:=timeval(t2);
  if a<=u
    then withintime:=(t>=a) and (t<=u)
    else withintime:=(t>=a) or (t<=u)
end;

function hungupon:boolean;
begin
  hungupon:=forcehangup or
  (online and not (carrier or modeminlock or modemoutlock))
end;

function sysopisavail:boolean;
begin
  case status.sysopavail of
    available    : sysopisavail:=true;
    notavailable : sysopisavail:=false;
    bytime       : sysopisavail:=withintime (Cfg.availtime,Cfg.unavailtime)
  end
end;

function sysopavailstr:sstr;
const strs:array [available..notavailable] of string[9]=
        ('On      ','Time=','Off     ');
var tstr:sstr;
    tmp:availtype;
begin
  tstr:=strs[status.sysopavail];
  if status.sysopavail=bytime
    then
      begin
        if sysopisavail
          then tmp:=available
          else tmp:=notavailable;
        tstr:=tstr+strs[tmp]
      end;
  sysopavailstr:=tstr
end;

function singularplural (n:integer; m1,m2:mstr):mstr;
begin
  if n=1
    then singularplural:=m1
    else singularplural:=m2
end;

function s (n:integer):sstr;
begin
  s:=singularplural (n,'','s')
end;

function numthings (n:integer; m1,m2:mstr):lstr;
begin
  numthings:=strr(n)+' '+singularplural (n,m1,m2)
end;

procedure thereisare (n:integer);
begin
  write (^R'There ');
  if N = 1
    then write ('is '^A'1 '^R)
    else
      begin
        write ('are ');
        if n=0
          then write (^A'no '^R)
          else write (^A+strr(n),' '^R)
       end
end;

procedure thereare (n:integer; m1,m2:mstr);
begin
  thereisare (n);
  if n=1
    then write (m1)
    else write (m2);
  writeln ('.')
end;

procedure assignbdfile;
begin
  assign (bdfile,Cfg.boarddir+'BOARDDIR.'+Strr(MsgConf));
  assign (bifile,Cfg.boarddir+'BDINDEX.'+Strr(MsgConf))
end;

procedure openbdfile;
var i:integer;
begin
  closebdfile;
  assignbdfile;
  reset (bdfile);
  i:=ioresult;
  reset (bifile);
  i:=i or ioresult;
  if i<>0 then formatbdfile
end;

procedure formatbdfile;
begin
  close (bdfile);
  close (bifile);
  assignbdfile;
  rewrite (bdfile);
  rewrite (bifile)
end;

procedure closebdfile;
begin
  close (bdfile);
  close (bifile)
end;

var wasopen:boolean;

procedure opentempbdfile;
begin
  wasopen:=isopen(bdfile);
  if not wasopen then openbdfile
end;

procedure closetempbdfile;
begin
  if not wasopen then closebdfile
end;

function keyhit:boolean;
var r:registers;
begin
  {r.ah:=1;
  intr ($16,r);
  keyhit:=(r.flags and 64)=0}
  keyhit:=keypressed;
end;

function bioskey:char;
var r:registers;
begin
  r.ah:=0;
  intr ($16,r);
  if r.al=0
    then bioskey:=chr(r.ah+128)
    else bioskey:=chr(r.al)
end;

procedure readline (var xx);
var a:anystr absolute xx;
    l:byte absolute xx;
    k:char;

  procedure backspace;
  begin
    if l>0 then begin
      write (usr,^H,' ',^H);
      l:=l-1
    end
  end;

  procedure eraseall;
  begin
    while l > 0 do backspace
  end;

  procedure addchar (k:char);
  begin
    if l<buflen then begin
      l:=l+1;
      a[l]:=k;
      write (usr,k)
    end
  end;

begin
  l:=0;
  repeat
    k:=bioskey;
    case k of
      #8:backspace;
      #27:eraseall;
      #32..#254 : addchar(k)
    end
  until k=#13;
  writeln (usr)
end;

procedure writereturnbat;
var tf:text;
    bd:integer;
    tmp:lstr;
begin
  assign (tf,'RETURN.BAT');
  rewrite (tf);
  getdir (0,tmp);
  writeln (tf,'CD '+tmp);
  if unum=0
    then begin
      writeln (tf,'PAUSE   ***  No one was logged in!');
      writeln (tf,'KEEPUP')
    end else begin
      if online then bd:=baudrate else bd:=0;
      writeln (tf,'keepup ',unum,' ',bd,' ',ord(parity)) {Was 'M'}
    end;
  textclose (tf);
  writeln (usr,'Type  RETURN  to return to ViSiON/2')
end;

procedure ensureclosed;
var cnt,i:integer;
begin
  stoptimer (status.numminsidle);
  stoptimer (status.numminsused);
  writestatus;
  textclose (ttfile);
  i:=ioresult;
  for cnt:=1 to numsysfiles do begin
    close (sysfiles[cnt]);
    i:=ioresult
  end
end;

procedure close_them_all(var ff);    { close most open files EXCEPT ff }
var cnt, i : integer;
begin
  i := ioresult;
  for cnt := 6 to numsysfiles do begin
    if ofs(ff) <> ofs(sysfiles[cnt])
      then begin
        if filerec(sysfiles[cnt]).handle <> 0
          then close(sysfiles[cnt]);
        i := ioresult;
      end
  end
end;

procedure clearbreak;
begin
  break:=false;
  xpressed:=false;
  dontstop:=false;
  nobreak:=false
end;

procedure ansireset;
begin
  textattr := urec.color1;
  if usecapsonly then exit;
  if urec.color1<>0 then begin
    ansicolor (urec.color1);
    exit
  end;
  if (not (ansigraphics in urec.config)) or (curattrib=0) or break then exit;
  write (direct,#27'[0m');
  curattrib:=0
end;

procedure specialmsg (q:anystr);
begin
  textattr:=9;
  writeln (usr,q);
end;

procedure readdataarea;
var f:file of byte;
begin
  assign (f,cfg.VISIONDIR+'VISION-2.DAT');
  reset (f);
  if ioresult<>0
    then unum:=-1
    else begin
      dos.filerec(f).recsize:=ofs(lastvariable)-ofs(firstvariable);
      read (f,firstvariable);
      close (f)
    end
end;

procedure writedataarea;
var f:file of byte;
begin
  assign (f,Cfg.VISIONDIR+'ViSiON-2.DAT');
  rewrite (f);
  dos.filerec(f).recsize:=ofs(lastvariable)-ofs(firstvariable);
  write (f,firstvariable);
  close (f)
end;

function bars_ok : boolean;
begin
  bars_ok := (usebars in urec.config) AND emul.allowbars;
end;

Function Percentage(A,B:Integer):Real;
Begin
  If (A>0) and (B>0)
    Then Percentage := (A/B) * 100
    Else percentage := 0;
End;

Procedure ExecuteWithSwap( ProgName : Lstr; Commandline : AnyStr; Force:Boolean);
{Const SwapLoc : Array[Boolean] of String[7]=('on disk','in EMS');}
Const SWAPFILE = 'V2SWAP.$$$';
Var W : Integer;
    S : AnyStr;
Begin

  If ProgName <> '' Then Begin
    S := '/C ' + ProgName;
    If CommandLine <> ''
      Then S := S + #32 + CommandLine;
  End Else S := '';

  If (Not Cfg.MaxDosShell) And (Not Force) Then Begin
    SwapVectors;
    Dos.Exec(GetEnv('COMSPEC'),S);
    SwapVectors;
    Exit;
  End;

  (*
  Writeln(Usr,'Swapping Out...');
  *)

  W := SwapExec(GetEnv('COMSPEC'),S,SwapFile,SwapToAny);

  Case Hi(W) Of
    1 : Writeln('DOS Memory Chain Error');
    2 : Writeln('Unable to Swap Out ViSiON/2!');
    3 : Case Lo(W) Of
          2 : Writeln('Unable to find/execute '+Progname);
          5 : Writeln('Couldn''t open '+Progname);
          8 : Writeln('Insufficient memory to run '+Progname);
        End;
  End;
End;

procedure determine_tasker;
var reg : registers;
begin
   reg.bx := 0;
   reg.ax := $1022;
   intr($15,reg);
   tasker := taskview_;
   if reg.bx <> 0 then
   begin
      directVideo := false;
      exit;
   end;
   reg.ax := $e400;
   msdos(reg);
   tasker := doubledos_;
   if (reg.al = 1) or (reg.al = 2) then
      exit;
   tasker := notasker;
end;

procedure give_up_time;
var
   reg:  registers;

begin

   {determine what multi-tasker is active, if any}
   if tasker = unknown then
      determine_tasker;
   
   {give up time with taskview/omniview/topview}
   if tasker = taskview_ then
   begin
      reg.ax := $1000;          {give up remainder of timeslice}
      intr($15,reg);
   end
   else
   if tasker = doubledos_ then
   begin
      reg.ax := $0001;           {give up 1 clock tick/slice}
      intr($fe,reg);
   end
end;

function lget_ms: longint;
var
   h,m,s,s1: word;
begin
   GetTime(h,m,s,s1);
   lget_ms  := longint(s1) * longint(10) +      {seconds/100}
               longint(s)  * longint(1000) +    {seconds}
               longint(m)  * longint(60000) +   {minutes}
               longint(h)  * longint(3600000);  {hours}
end;

procedure delay(ms: longint);
var
   finish:  longint;
   start:   longint;
   now:     longint;

begin
   start := lget_ms;
   finish := start + ms;

   repeat
      give_up_time;
      now := lget_ms;
   until (now > finish) or    {time elapsed}
         (now < start);       {midnight rolover!}
end;

function total_valu(s:string) : longint;
var temp : longint;
    x : byte;
begin
  temp := 0;
  for x := 1 to length(s) do
    inc(temp,byte(s[x]));
  total_valu := temp;
end;

Begin
End.
