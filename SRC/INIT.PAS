{$R-,S-,I-,D-,F-,V-,B-,N-,L+,O+}

Unit Init;

Interface

Procedure ValidConfiguration;
Procedure InitViSiON (CheckFiles30 : Boolean);

Implementation

Uses Crt, MNet, Dos, DosMem, GenTypes, Modem, Pavt150, PavtIo, StatRet, ConfigRt,
     MyComman, Flags, GenSubs, Subs1, Windows, TextRet, UserRet, SubsOvr,
     Subs2, Crc32,OverRet1;

Procedure UnEncrypt;
VAR Temp,T1 : String;
    K,X     : Byte;
    RegFile : File Of Byte;
    UsedBytes: array[0..1024] of boolean;
    namecrc,bbscrc : longint;

    procedure add_letter(k:char);
    var b : byte absolute temp;
    begin
      inc(b);
      temp[b] :=k;
    end;

var where : word;
Begin

  Temp[0] := #0;
  RegSysOp := UnReg;
  RegBBS   := UnReg;

  add_letter(chr(173 Xor 255));
  add_letter(chr(175 Xor 234));
  add_letter(chr(180 Xor 243));
  add_letter(chr(169 Xor 237));
  add_letter(chr(159 Xor 222));
  add_letter(chr(190 Xor 234));
  add_letter(chr(187 Xor 250));
  add_letter(chr(18 xor 60));
  add_letter(chr(131 xor 232));
  add_letter(chr(69));
  add_letter(chr(121));

  Assign(RegFile,Cfg.DataDir+Temp);
  Reset(RegFile);

  If (IoResult <> 0)
{  OR (Byte(RegSYSOP[1]) <> (100 XOR 154)) }
  Then Begin
    RegSysOp := UnReg;
    RegBBS   := RegSysOp;
    Close(RegFile);
    Exit;
  End;

  temp[0] := #0;
  fillchar(usedbytes,sizeof(usedbytes),0);
  namecrc := 0;
  bbscrc  := 0;
  crcstr(cfg.sysopname[1],namecrc,integer(cfg.sysopname[0]));
  crcstr(cfg.longname[1],bbscrc,integer(cfg.longname[0]));
  regsysop:= '';
  regbbs  := '';
  randseed := namecrc + $f054;
  for x := 1 to length(cfg.longname) do
    begin
      where := 0;
      while where < 1 do
        begin
          where := random($0400);
          if usedbytes[where] then where := 0;
        end;
      usedbytes[where] := true;
      seek(regfile,where);
      read(regfile,k);
      if odd(x) then
        regbbs := regbbs + char(k xor random($00FF)) else
        regbbs := regbbs + char(k xor random($0080))
    end;
  randseed := random(randseed);
  for x := 1 to length(cfg.sysopname) do
    begin
      where := 0;
      while where < 1 do
        begin
          where := random($0400);
          if usedbytes[where] then where := 0;
        end;
      usedbytes[where] := true;
      seek(regfile,where);
      read(regfile,k);
      if odd(x) then
        regsysop := regsysop + char(k xor random($0080)) else
        regsysop := regsysop + char(k xor random($00FF));
    end;
  delay(1000);
  close(regfile);
End;

procedure validconfiguration;
var errs:integer;
    cnt:integer;
    flag:boolean;

  procedure error (q:anystr);
  begin
    TextAttr:=5;
    if errs=0 then writeln (usr,'Configuration Errors:');
    TextAttr:=13;
    errs:=errs+1;
    writeln (usr,errs,'. ',q)
  end;

  Function Dir_Exists(Dir : Lstr) : Boolean;
  Var I : Integer;
      F : File;
  Begin
    Assign(F,Dir + 'TEST.DIR');
    Rewrite(F);
    I := IoResult;
    Dir_Exists := I = 0;
    Close(F);
  End;

  procedure ispath (var x:lstr; name:lstr);
  VAR Lc,K:Char;
      Cur:Lstr;
      N:Integer;
  begin
    If not Dir_Exists(X) then Begin
    error (name+' Path Bad: '+x);
    TextAttr:=11;
    Write(Usr,'Create it? [Y/n]: ');
    K:=ReadKey;
    If Upcase(K) in ['Y',#13] then Begin
      Writeln(usr,'Yep');
      lc:=x[length(x)];
      if (length(x)<>1)
      then if (lc<>':') and (lc<>'\') then x:=x+'\';
      if x[length(x)]='\' then x[0]:=pred(x[0]);
      getdir (0,cur);
      chdir (x);
      n:=ioresult;
      chdir (cur);
      if N = 0 Then Begin
        Writeln(Usr,'Error!');
        Exit;
      End;
      MkDir(x);
      If IoResult<>0 then Writeln('Error!') Else Dec(errs);
   End Else Writeln('Nope');
   End;
  end;

  procedure isstring (x:anystr; name:lstr);
  var cnt:integer;
  begin
    if length(x)=0 then begin
      error (name+' has not been set!');
      exit
    end;
    for cnt:=1 to length(x) do if not (x[cnt] in [#32..#255])
      then begin
        error ('Bad '+name+' string');
        exit
      end
  end;

  procedure isinteger (n,r1,r2:integer; name:lstr);
  begin
    if (n<r1) or (n>r2) then error ('Bad '+name+' value: '+strr(n))
  end;

  procedure isword (n,r1,r2:word; name:lstr);
  Begin
    If (n<r1) or (n>r2) then error ('Bad '+name+' value: '+strr(n));
  End;

var w : word;
begin
  errs:=0;
  If Cfg.TotalNodes > 1 Then Begin
    If Not Share_Active Then Begin
      Writeln(usr);
      Writeln(usr,'You must have SHARE.EXE loaded to run ViSiON/2 multi-node.');
      Writeln(usr);
      Halt(4);
    End;
    W := Dos_LockRetry(10,200);
  End;
  isstring (cfg.sysopname,'Sysop Name');
  ispath (cfg.textdir,'Path to Message Base');
  ispath (cfg.uploaddir,'Path to ASCII Uploads');
  ispath (cfg.boarddir,'Path to Sub-Board files');
  ispath (cfg.textfiledir,'Path to Text Files');
  ispath (cfg.doordir,'Path to door batch files');
  ispath (cfg.DataDir,'Path to DATA Files');
  ispath (Cfg.ExtractDir,'Temp Path for File Extractions');
  ispath (Cfg.MenuDir,'Path to Menu Data');
{  If Cfg.Use_Fos
    Then }
    IsWord(Cfg.DefBaudRate,1200,57600,'Default BPS (Fossil)');
    { Else IsWord(Cfg.DefBaudRate,1200,57600,'Default Baud Rate'); }
  isinteger (cfg.usecom,0,8,'Communications Port');
  isinteger (cfg.mintimeout,1,maxint,'Input Time Out');
  isinteger (cfg.sysoplevel,1,maxint,'Co-Sysop Level');
  flag:=true;
  for cnt:=1 to 100 do if flag and (cfg.usertime[cnt]<1) then begin
    flag:=false;
    error ('Time per day has non-positive entries')
  end;
  if errs>0 then halt(e_badconfig)
end;

procedure initViSiON (checkfiles30:boolean);

  procedure formatmfile;
  var m:mailrec;
  begin
    ReWrite (mfile);
    fillchar (m,sizeof(m),255);
    NWrite (mfile,m)
  end;

  procedure openmfile;
  var i:integer;
  begin
    close (mfile);
    i:=ioresult;
    assign (mfile,Cfg.DATADIR+'MAIL');
    reset (mfile);
    i:=ioresult;
    if i<>0
      then if i=2
        then formatmfile
        else begin
          writeln (usr,'Fatal error: Unable to open Email file!');
          halt (e_fatalfileerror)
        end
  end;

  procedure closetfile;
  var n:integer;
  begin
  end;

  procedure formattfile(T:Sstr);
  Begin
  End;
  (*
  var cnt,p:integer;
      r:real;
      buff:buffer;
      x:char;
  const dummystr:sstr='Blank!! ';
  begin
    TextAttr:=3;
    Writeln(usr,T+' Index/Message Files are not located in '+Cfg.TextDir);
    TextAttr:=11;
    write (usr,'Create New Files? [Y/n]: ');
    buflen:=1;
    x:=readkey;
    If x=#13 then x:='Y';
    TextAttr:=9;
    if Upcase(x)<>'Y' then Begin
      Writeln('Nope!');
      halt (e_fatalfileerror);
    End Else Writeln('Yes');
    rewrite (mapfile);
    Buflen:=80;
    if ioresult<>0 then begin
      writeln (usr,'Error: Unable to create files!');
      halt (e_fatalfileerror)
    end;
    p:=-2;
    for cnt:=0 to numsectors do write (mapfile,p);
    p:=1;
    for cnt:=1 to sectorsize do begin
      buff[cnt]:=dummystr[p];
      p:=p+1;
      if p>length(dummystr) then p:=1
    end;
    rewrite (tfile);
    if ioresult<>0 then begin
      writeln (usr,'Error: Unable to create files!');
      halt (e_fatalfileerror)
    end;
    for cnt:=0 to 5 do write (tfile,buff)
  end;
  *)
  procedure opentfile;
  var a,i,j:integer;
  begin
  End;
  (*
    closetfile;
    assign(tfile,cfg.textdir+'EMAIL.TXT');
    assign(Mapfile,Cfg.textdir+'EMAIL.NDX');
    reset(tfile);
    i:=ioresult;
    reset(mapfile);
    j:=ioresult;
    if (i<>0) or (j<>0) then formattfile('Email');
    closetfile;
    assign(tfile,cfg.textdir+'FORMS.TXT');
    assign(Mapfile,Cfg.textdir+'FORMS.NDX');
    reset(tfile);
    i:=ioresult;
    reset(mapfile);
    j:=ioresult;
    if (i<>0) or (j<>0) then formattfile('Infoform');
    closetfile;
    assign(tfile,cfg.textdir+'FEEDBACK.TXT');
    assign(Mapfile,Cfg.textdir+'FEEDBACK.NDX');
    reset(tfile);
    i:=ioresult;
    reset(mapfile);
    j:=ioresult;
    if (i<>0) or (j<>0) then formattfile('Feedback');
    closetfile;
    assign(tfile,cfg.textdir+'NEWS.TXT');
    assign(Mapfile,Cfg.textdir+'NEWS.NDX');
    reset(tfile);
    i:=ioresult;
    reset(mapfile);
    j:=ioresult;
    if (i<>0) or (j<>0) then formattfile('News');
    closetfile;
    assign(tfile,cfg.textdir+'DOORS.TXT');
    assign(Mapfile,Cfg.textdir+'DOORS.NDX');
    reset(tfile);
    i:=ioresult;
    reset(mapfile);
    j:=ioresult;
    if (i<>0) or (j<>0) then formattfile('Doors');
    closetfile;
    CurNdxFile:='!@#$%';
    CurTxtFile:='!@#$%';
  *)

  procedure openufile;
  var u:userrec;
      n,cnt:integer;

    procedure createuhfile;
    var cnt:integer;
    begin
      rewrite (uhfile);
      if ioresult<>0 then begin
        writeln (usr,'Unable to create user index file - Run ViSiON Again!');
        halt (e_fatalfileerror)
      end;
      seek (ufile,0);
      While Not Eof(ufile) do begin
        NRead (ufile,u);
        NWrite (uhfile,u.handle)
      End
    end;

  begin
    close (ufile);
    assign (ufile,Cfg.DATADIR+'USERS');
    reset (ufile);
    n:=ioresult;
    if n=0 then begin
      numusers:=filesize(ufile)-1;
      assign (uhfile,Cfg.DATADIR+'USERINDX');
      reset (uhfile);
      if ioresult<>0
        then createuhfile
        else if filesize(uhfile)<>filesize(ufile) then begin
          close (uhfile);
          createuhfile
        end;
      exit
    end;
    close (ufile);
    n:=ioresult;
    rewrite (ufile);
    fillchar (u,sizeof(u),0);
    write (ufile,u);
    u.handle:=cfg.sysopname;
    u.password:='Sysop';
    u.timetoday:=9999;
    u.level:=cfg.sysoplevel+1;
    u.udlevel:=101;
    u.udpoints:=101;
    u.config:=[ansigraphics,asciigraphics,lowercase,eightycols,linefeeds,postprompts];
    u.config:=u.config+[mainsysop,udsysop,bulletinsysop,emailsysop,votingsysop,doorssysop,fseditor,usebars];
    u.color1:=cfg.defcolor1; u.color2:=cfg.defcolor2; u.color3:=cfg.defcolor3; u.color4:=cfg.defcolor4;
    u.color5:=cfg.defcolor5; u.color6:=cfg.defcolor6; u.color7:=cfg.defcolor7;
    U.Prompt:= Strng^.DefPrompt;
    u.sysopnote:='System Operator';
    u.kdowntoday:=0;
    u.dailykblimit:=0;
    u.emailannounce:=-1;
    For n:=1 to 5 do u.infoform[n]:=-1;
    u.displaylen:=24;
    if cfg.useconmode
      then u.config:=u.config+[ansigraphics]
      else u.config:=u.config+[asciigraphics];
    NWrite (ufile,u);
    Numusers := 1;
    createuhfile
  end;

  procedure initfile (var f:file);
  var fi:fib absolute f;
  begin
    fi.handle:=0;
    fi.name[0]:=chr(0)
  end;

  procedure openlogfile;

    procedure autodeletesyslog;
    var mx,cnt:integer;
        l:logrec;
    begin
      dontanswer;
      write (usr,'Truncating System Log ... one moment ... ');
      mx:=filesize(logfile) div 2;
      for cnt:=1 to mx do begin
        seek (logfile,cnt+mx-1);
        read (logfile,l);
        seek (logfile,cnt-1);
        write (logfile,l)
      end;
      seek (logfile,mx-1);
      truncate (logfile);
      writeln (usr,'Done.');
      doanswer
    end;

  begin
    assign (logfile,cfg.VisionDir+'SYSLOG');
    reset (logfile);
    if ioresult<>0 then begin
      rewrite (logfile);
      if ioresult<>0 then begin
        writeln (usr,'Unable to create log file');
        halt (e_fatalfileerror)
      end
    end;
    if filesize(logfile)>maxsyslogsize then autodeletesyslog
  end;


  Procedure LoadErrorList;
  BEGIN
      IoErrors[1]:='001 Invalid function number';
      IoErrors[2]:='002 File not found';
      IoErrors[3]:='003 Path not found';
      IoErrors[4]:='004 Too many open files';
      IoErrors[5]:='005 Access denied';
      IoErrors[6]:='006 Invalid handle';
      IoErrors[7]:='008 Not enough memory';
      IoErrors[8]:='010 Invalid environment';
      IoErrors[9]:='011 Invalid format';
      IoErrors[10]:='012 Invalid file access code';
      IoErrors[12]:='015 Invalid drive number';
      IoErrors[13]:='016 Cannot remove current directory';
      IoErrors[14]:='017 Cannot rename across drives';
      IoErrors[15]:='018 No more files';
      IoErrors[16]:='100 Disk read error';
      IoErrors[17]:='101 Disk write error';
      IoErrors[18]:='102 File not assigned';
      IoErrors[19]:='103 File not open';
      IoErrors[20]:='104 File not open for input';
      IoErrors[21]:='105 File not open for output';
      IoErrors[22]:='106 Invalid numeric format';
      IoErrors[23]:='150 Disk is write-protected';
      IoErrors[24]:='151 Bad drive request struct length';
      IoErrors[25]:='152 Drive not ready';
      IoErrors[26]:='154 CRC error in data';
      IoErrors[27]:='156 Disk seek error';
      IoErrors[28]:='157 Unknown media type';
      IoErrors[29]:='158 Sector Not Found';
      IoErrors[30]:='159 Printer out of paper';
      IoErrors[31]:='160 Device write fault';
      IoErrors[32]:='161 Device read fault';
      IoErrors[33]:='162 Hardware failure';
      IoErrors[34]:='200 Division by zero';
      IoErrors[35]:='201 Range check error';
      IoErrors[36]:='202 Stack overflow error';
      IoErrors[37]:='203 Heap overflow error';
      IoErrors[38]:='204 Invalid pointer operation';
      IoErrors[39]:='205 Floating point overflow';
      IoErrors[40]:='206 Floating point underflow';
      IoErrors[41]:='207 Invalid floating point operation';
      IoErrors[42]:='208 Overlay manager not installed';
      IoErrors[43]:='209 Overlay file read error';
      IoErrors[44]:='210 Object not initialized';
      IoErrors[45]:='211 Call to abstract method';
      IoErrors[46]:='212 Stream registration error';
      IoErrors[47]:='213 Collection index out of range';
      IoErrors[48]:='214 Collection overflow error';
  End;

  Procedure CheckNuv;
  Var N:NuvRec;
      U:UserRec;
      X,A:Byte;
  Begin
    Assign(NuvFile,Cfg.DataDir+'NUV.DAT');
    Reset(NuvFile);

    If IoResult <> 0
    Then Begin
      Close(NuvFile);
      Exit;
    End;

    For X := FileSize(NuvFile) Downto 1
    Do Begin
      Seek(NuvFile,X-1);
      NRead(NuvFile,N);
      A:=LookUpUser(N.Who);
      If (Length(N.Who)<1) or (A<1) Then Begin
        Close(NuvFile);
        RemoveFromNuv('',X);
        Assign(NuvFile,Cfg.DataDir+'NUV.DAT');
        Reset(NuvFile);
     End Else Begin
       Seek(UFile,A);
       NRead(UFile,U);
       If U.Level>=Cfg.LogonLevel Then Begin
         Close(NuvFile);
         RemoveFromNuv('',X);
         Assign(NuvFile,Cfg.DataDir+'NUV.DAT');
         Reset(NuvFile);
      End;
    End;
  End;
  Close(NuvFile);
  End;

  procedure loadsyslogdat;
  var tf:text;
      q:lstr;
      b1,b2,p,s,n:integer;
  begin
    numsyslogdat:=0;
    with syslogdat[0] do begin
      menu:=0;
      subcommand:=0;
      text:='SYSLOG.DAT entry not found: %'
    end;
    assign (tf,'SYSLOG.DAT');
    reset (tf);
    if ioresult=0 then begin
      while not eof(tf) do begin
        readln (tf,q);
        p:=pos(' ',q);
        if p<>0 then begin
          val (copy(q,1,p-1),b1,s);
          if s=0 then begin
            delete (q,1,p);
            p:=pos(' ',q);
            if p<>0 then begin
              val (copy(q,1,p-1),b2,s);
              if s=0 then begin
                delete (q,1,p);
                if numsyslogdat=maxsyslogdat
                  then writeln (usr,'Too many SYSLOG.DAT entries')
                  else begin
                    numsyslogdat:=numsyslogdat+1;
                    with syslogdat[numsyslogdat] do begin
                      menu:=b1;
                      subcommand:=b2;
                      text:=copy(q,1,30)
                    end
                  end
              end
            end
          end
        end
      end;
      textclose (tf)
    end;
    if numsyslogdat=0 then writeln (usr,'SYSLOG.DAT file missing or invalid')
  end;

  Procedure Doesfilesequal30;
  var f:array [1..14] of file;
      cnt,i:integer;
  begin
  {
    for cnt:=1 to 14 do begin
      assign (f[cnt],'CON');
      reset (f[cnt]);
      i:=ioresult;
      if i<>0 then begin
        writeln (usr,^M^J'Fatal error:  You MUST put the command',
           ^M^J^J'   FILES=30',
           ^M^J^J'in your CONFIG.SYS file on the disk from which you boot.',
           ^M^J^J'Note:  If you have been modifying ViSiON/2, then you may',
             ^M^J'       be leaving a file open.');
        halt (e_files30)
      endf
    end;
    for cnt:=14 downto 1 do close(f[cnt])
    }
  end;

  Procedure Message(Mes:Lstr);
  Begin
    If Not CheckFiles30 Then Exit;
    TextAttr:=1;
    Write(usr,'þ ');
    TextAttr:=9;
    Writeln(Usr,Mes);
  End;

var k  : char;
    cnt: integer;
begin
  with textrec(system.output) do begin
    openfunc:=@opendevice;
    closefunc:=@closedevice;
    flushfunc:=@writechars;
    inoutfunc:=@writechars
  end;
  with textrec(system.input) do begin
    inoutfunc:=@readcharfunc;
    openfunc:=@ignorecommand;
    closefunc:=@ignorecommand;
    flushfunc:=@ignorecommand
  end;
  if checkfiles30 then doesfilesequal30;
  fillchar (urec,sizeof(urec),0);
  no_local_output := false;
  namevalue := total_valu(cfg.sysopname);
  urec.config:=[lowercase,eightycols,asciigraphics];
  iocode:=0;
  linecount:=0;
  Status.sysopavail:=bytime;
  errorparam:='';
  errorproc:='';
  unam:='';
  chainstr[0]:=#0;
  inpt[0]:=#0;
  chatreason:='';
  ulvl:=0;
  unum:=-1;
  bbsvalue := total_valu(cfg.longname);
  logonunum:=-2;
  break:=false;
  nochain:=false;
  nobreak:=false;
  wordwrap:=false;
  beginwithspacesok:=false;
  dots:=false;
  online:=false;
  local:=true;
  chatmode:=false;
  texttrap:=false;
  printerecho:=false;
  fillchar (urec,sizeof(urec),0);
  usecapsonly:=false;
  uselinefeeds:=true;
  curattrib:=0;
  buflen:=80;
  baudrate:=cfg.defbaudrate;
  parity:=false;
  timelock:=false;
  ingetstr:=false;
  modeminlock:=false;
  modemoutlock:=false;
  tempsysop:=false;
  sysnext:=false;
  forcehangup:=false;
  requestbreak:=false;
  disconnected:=false;
  SplitMode:=False;
  cursection:=mainsysop;
  replynum:=0;
  regularlevel:=0;
  UseBottom:=1;
  charsused:=0;
  replynum:=0;
  Non_Stop := False;
  CheckPageLength := False;

  RegMe := 'ViSiON/2 vo.72 can be registered by contacting the ViSiON/2 author';
  RegMe2:= '@ 505-622-6804.  This is a requirement to run this BBS Software!';

  Message('Resetting System Files...');
  for cnt:=1 to numsysfiles do initfile (sysfiles[cnt]);
  Message('Loading Syslog Data...');
  loadsyslogdat;
  Message('Reading System Records...');
  readstatus;
  readdailylog;
  {openufile;}
  Message('Checking Text Storage Files...');
  opentfile;
  Message('Opening SysOp Log/Daily Log Files...');
  openlogfile;
  Message('Opening Mail Files...');
  OpenMFile;
  LastTextFile[0] := #0;
  LastMailFile[0] := #0;
  LastMsgConf  := 1;
  LastFileConf := 1;
  FileConf := 1;
  MsgConf  := 1;
  If Checkfiles30 then Begin
    OpenNodeRec;
    UpdateNode('0');
    Message('Opening User Records...');
    OpenUFile;
    Message('Scanning New User Voting...');
    CheckNuv;
    Message('Loading Error List...');
    LoadErrorList;
    Dos_GetMem(BatchDown,SizeOf(BatchRec) * 50 + 1);
    UnEnCrypt;
    Load_Emulation(1);
  End Else Begin
    Close(MNFiLE);
    Dos_FreeMem(BatchDown);
  End;
  TotalSent     := 0;
  TotalReceived := 0;
End;

procedure assignname (var t:text; nm:lstr);
begin
  with textrec(t) do begin
    move (nm[1],name,length(nm));
    name[length(nm)]:=#0
  end
end;

var r:registers;

begin
  checkbreak:=false;
  checkeof:=false;
  directvideo:=cfg.directvideomode;
  checksnow:=cfg.checksnowmode;
  r.ah:=15;
  intr ($10,r);
  if r.al=7
    then screenseg:=$b000
    else screenseg:=$b800;
  textrec(system.input).mode:=fminput;
  move (output,usr,sizeof(text));           { Set up device drivers }
  move (output,direct,sizeof(text));
  move (system.input,directin,sizeof(text));
  with textrec(direct) do begin
    openfunc:=@opendevice;
    closefunc:=@closedevice;
    flushfunc:=@directoutchars;
    inoutfunc:=@directoutchars;
    bufptr:=@buffer
  end;
  with textrec(directin) do begin
    mode:=fminput;
    inoutfunc:=@directinchars;
    openfunc:=@ignorecommand;
    flushfunc:=@ignorecommand;
    closefunc:=@ignorecommand;
    bufptr:=@buffer
  end;
  with textrec(usr) do bufptr:=@buffer;
  assignname (usr,'USR');
  assignname (direct,'DIRECT');
  assignname (directin,'DIRECT-IN');
  assignname (system.output,'OUTPUTT');
  assignname (system.input,'INPUTT');
  INITUNIT;
  SetScrPtr;
  SetHooks;
  ResetTerminal(80,24);
  SetTerminal(TermAVT0);
{  SetScreenSize(80,25); }
  GotoXy(1,5);
  Assign(Output,'');
  Rewrite(Output);
  Assign(Input,'');
  Reset(Input);
end.
