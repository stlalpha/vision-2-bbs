{$R-,S-,I-,D-,F+,V-,B-,N-,L+,O+ }

unit doors;

interface

procedure listdoors;
procedure opendoor(n:byte);
procedure getinfo;
procedure changedoor;
procedure deletedoor;
procedure maybemakedoor;
procedure write_all_door_files;
function init_doors : boolean;

implementation

uses MNeT,gentypes,modem,configrt,statret,gensubs,subs1,subs2,
     userret,textret,overret1,mainr1,mainr2,windows,fossil;

  Procedure MakeChainTxt;
  VAR T:Text;
  BEGIN
    ASSIGN(T,CFG.ViSiONDir+'CHAIN.TXT');
    Rewrite(T);
    Writeln(T,UNUM);
    Writeln(T,Urec.Handle);
    Writeln(T,Urec.RealName);
    Writeln(T,'NONE');
    Writeln(T,'21');
    Writeln(T,'M');
    Writeln(T,Urec.UDPoints);
    Writeln(T,DateStr(Subs1.Laston));
    Writeln(T,'80');
    Writeln(T,'25');
    Writeln(T,Urec.Level);
    If IsSysop then Writeln(T,'1') Else Writeln(T,'0');
    If IsSysOp then Writeln(T,'1') Else Writeln(T,'0');
    Writeln(T,'1');
    If Local then Writeln(T,'0') Else Writeln(T,Cfg.UseCom);
    Writeln(T,timeleft);
    Writeln(T,Cfg.DataDir);
    Writeln(T,Cfg.DataDir);
    Writeln(T,Cfg.VisionDir+'SYSOP');
    Writeln(T,ConnectBaud);
    Writeln(T,Cfg.UseCom);
    Writeln(T,Cfg.LongName);
    Writeln(T,Cfg.SysopName);
    Writeln(T,'10');
    Writeln(T,'0');
    Writeln(T,'0');
    Writeln(T,'0');
    Writeln(T,'0');
    Writeln(T,'0');
    Writeln(T,'8N1');
    Writeln(T,'');
    TextClose(T);
  End;

  procedure write_dorinfo1_def(rname:boolean);  (* RBBS-PC's DORINFO1.DEF *)
  var fp:text;
      first,last:mstr;
      s:mstr;
  begin
    assign(fp,'DORINFO1.DEF');
    rewrite(fp);
    writeln(fp,cfg.longname);
    first := copy(cfg.sysopname,1,pos(' ',cfg.sysopname)-1);
    last  := copy(cfg.sysopname,length(first)+2,length(cfg.sysopname));
    writeln(fp,first);
    writeln(fp,last);
    if local then writeln(fp,'COM0') else writeln(fp,'COM'+strr(cfg.usecom));
    if local then s:='0' else s:=strr(baudrate);
    writeln(fp,s+' BAUD,N,8,1');
    writeln(fp,'0');
    if (rname) then begin
      if pos(' ',urec.realname)=0 then begin
        first:=urec.realname;
        last:='';
      end else begin
        first:= copy(urec.realname,1,pos(' ',urec.realname)-1);
        last := copy(urec.realname,length(first)+2,length(urec.realname));
      end;
      first:= upstring(first);
      last := upstring(last);
    end else begin
      if pos(' ',urec.handle)=0 then begin
        first:=urec.handle;
        last:='';
      end else begin
        first:=copy(urec.handle,1,pos(' ',urec.handle)-1);
        last:=copy(urec.handle,length(first)+2,length(urec.handle));
      end;
    end;
    writeln(fp,upstring(first));
    writeln(fp,upstring(last));
    writeln(fp,urec.sysopnote);
    {if (ansi in thisuser.ac) then} writeln(fp,'1');{ else writeln(fp,'0');}
    writeln(fp,urec.level);
    s:=strr (timeleft);
    if length(s)>3 then s:='999';
    writeln(fp,s);
    writeln(fp,'0');
    textclose(fp);
  end;

  procedure write_door_sys(rname:boolean);    (* GAP's DOOR.SYS *)
  var fp:text;
      i:integer;
      s:sstr;
  begin
    assign(fp,'DOOR.SYS');
    rewrite(fp);
    if not local then writeln(fp,'COM'+strr(cfg.usecom)+':') else writeln(fp,'COM0:');
    if not local then writeln(fp,strlong(baudrate)) else writeln(fp,strlong(cfg.defbaudrate));
	  writeln(fp,' 8');
	  writeln(fp,' 1');
	  writeln(fp,' N');
	  {if wantout then writeln(fp,' Y') else }writeln(fp,' N');
	  writeln(fp,' Y');
	  if issysop then writeln(fp,' Y') else writeln(fp,' N');
	  {if alert in thisuser.ac then writeln(fp,' Y') else} writeln(fp,' N');
    if (rname) then writeln(fp,urec.realname) else writeln(fp,urec.handle);
    writeln(fp,urec.sysopnote);
    writeln(fp,copy(urec.phonenum,1,3)+' '+copy(urec.phonenum,5,8));
    writeln(fp,copy(urec.phonenum,1,3)+' '+copy(urec.phonenum,5,8));
    writeln(fp,urec.password);
    writeln(fp,strr(urec.level));
    writeln(fp,strr(urec.numon));
    writeln(fp,datestr(urec.laston));
    writeln(fp,strlong(timeleft * 60));
    writeln(fp,strr(timeleft));
    {if okansi then} writeln(fp,'GR');{ else writeln(fp,'NG');}
    writeln(fp,'24');
    {if novice in thisuser.ac then writeln(fp,' N') else }
    writeln(fp,' Y');
    s:='';
   { for i:=1 to 7 do
      if chr(i+64) in thisuser.ar then s:=s+cstr(i); }
    writeln(fp,s);
    writeln(fp,'7');
	  writeln(fp,'12/31/99');
	  writeln(fp,' '+strr(unum));
	  writeln(fp,' X');
	  writeln(fp,' '+strr(urec.uploads));
	  writeln(fp,' '+strr(urec.downloads));
	  writeln(fp,' '+strr(trunc(urec.kdown)));
	  writeln(fp,' 999999');
    textclose(fp);
  end;

  procedure write_all_door_files;
  begin
    makechaintxt;
    write_dorinfo1_def(false);
    write_door_sys(false);
  end;

  function numdoors:integer;
  begin
    numdoors:=filesize (dofile)
  end;

  procedure seekdofile (n:integer);
  begin
    seek (dofile,n-1)
  end;

  procedure opendofile;
  var i:integer;
  begin
    assign (dofile,cfg.datadir + 'DOOR.DAT');
    reset (dofile);
    if ioresult<>0 then begin
      i:=ioresult;
      rewrite (dofile)
    end
  end;

  procedure maybemakebatch (fn:lstr);
  var tf:text;
      d:boolean;
  begin
    if not issysop then exit;
    writestr (^R'Make new batch file '+fn+'? !');
    writeln (^M);
    if not yes then exit;
    assign (tf,fn);
    rewrite (tf);
    if ioresult<>0 then begin
      writeln ('Couldn''t create file!');
      textclose(tf);
      exit
    end;
    writehdr ('Enter text, blank line to end.');
    repeat
      writestr (^R': &');
      d:=length(inpt)=0;
      if not d then writeln (tf,inpt)
    until d;
    textclose (tf);
    writeln (^M'Batch file created!');
    writelog (10,4,fn)
  end;

  procedure getdoorinfo (var d:doorrec);
  var m:message;
  begin
    writehdr ('Please enter a description of this door now.');
    holdscreen;
    D.Info := Editor (m,false,false,'0','0','DOOR.TXT','DOOR.MAP')
  end;

  function checkbatchname (var qq):boolean;
  var i:lstr absolute qq;
      p:integer;
  begin
    p:=pos('.',i);
    if p<>0 then i[0]:=chr(p-1);
    i:=i+'.BAT';
    checkbatchname:=validfname(i)
  end;

  procedure maybemakedoor;
  var n:integer;
      d:doorrec;
  begin
    if not issysop then begin
       close(dofile);
       exit;
    end;
    n:=numdoors+1;
    DefYes := False;
    writestr (^R'Create door #'+strr(n)+'? !');
    if not yes then exit;
    write (^M^R'Door Name'^A': ');
    InputBox(30);
    if length(inpt)=0 then exit;
    d.name:=inpt;
    writestr (^R'Access level'^A': ');
    if length(inpt)=0 then exit;
    d.level:=valu(inpt);
    write(^R'Name of batch file'^A': ');
    InputBox(12);
    if length(inpt)=0 then exit;
    if not checkbatchname(inpt) then begin
      writeln (^R'Invalid filename'^A': '^S,inpt);
      exit
    end;
    d.batchname:=Cfg.doordir+inpt;
    DefYes := FALSE;
    writestr (^R'Ask user opening door for parameters? !');
    d.getparams:=yes;
    defyes:=false;
    writestr(^R'Should V/2 FULLY drop to DOS? !');
    d.full_drop := yes;
    getdoorinfo (d);
    if d.info<0 then exit;
    d.numused:=0;
    seekdofile (n);
    nwrite (dofile,d);
    if not exist (d.batchname) then begin
      writeln (^B'Can''t open batch file ',d.batchname);
      maybemakebatch (d.batchname)
    end;
    writeln (^B^M'Door created!');
    writelog (10,3,d.name)
  end;

  function haveaccess (n:integer):boolean;
  var d:doorrec;
  begin
    haveaccess:=false;
    seekdofile (n);
    nread (dofile,d);
    if ulvl>=d.level
      then haveaccess:=true
      else reqlevel (d.level)
  end;

  procedure listdoors;
  var d:doorrec;
      cnt:integer;
  begin
    seekdofile (1);
    ListingFile(Cfg.TextFileDir + 'DOORS.TOP',True);
    for cnt:=1 to numdoors do begin
      nread (dofile,d);
      if ulvl>=d.level then begin
        Sr.C[1] := 'NU'; Sr.S[1] := Strr(Cnt); Sr.T[1] := 1;
        Sr.C[2] := 'DO'; Sr.S[2] := D.Name;    Sr.T[2] := 30;
        Sr.C[3] := 'LV'; Sr.S[3] := Strr(D.Level); Sr.T[3] := 6;
        Sr.C[4] := 'US'; Sr.S[4] := Strr(D.NumUsed); Sr.T[4] := 5;
        ListingFile(Cfg.TextFileDir + 'DOORS.MID',False);
        if break then exit
      end
    end;
    ListingFile(Cfg.TextFileDir + 'DOORS.BOT',False);
    writeln
  end;

  function getdoornum (txt:mstr):integer;
  var g:boolean;
      n:integer;
  begin
    getdoornum:=0;
    g:=false;
    repeat
      writestr (^R'Door number to '+txt+' ('^S'?/Lists'^R') : *');
      writeln;
      if Upcase(inpt[1])='?' then listdoors else g:=true
    until g;
    if length(inpt)=0 then exit;
    n:=valu(inpt);
    if (n<1) or (n>numdoors)
      then writeln (^M^S'Invalid Door Number!'^M)
      else if haveaccess(n)
        then getdoornum:=n
  end;

  procedure opendoor(n:byte);
  var bd,p:integer;
      d:doorrec;
      batchf,outf:text;
      q:boolean;
      tmp,params:lstr;
  begin
    if n < 1 then
      n:=getdoornum ('open');
    if (n<1) or (n>numdoors) then exit;
    seekdofile (n);
    nread (dofile,d);
    printtext ('DOOR.TXT','DOOR.MAP',d.info);
    if d.getparams then writestr ('Parameters:') else inpt:='';
    params:=inpt;
    p:=pos('>',inpt);
    if p=0 then p:=pos('<',inpt);
    if p=0 then p:=pos('|',inpt);
    if p<>0 then begin
      writestr ('You may not specify pipes in door parameters.');
      exit
    end;
    writeln (^R'Press '^A'['^S'Space'^A']'^R' to open the door, or '^A'['^S'X'^A']'^R' to abort');
    if upcase(waitforchar(true))='X' then exit;
    writehdr ('Opening door: '+d.name);
    q:=true;
    repeat
      assign (batchf,d.batchname);
      reset (batchf);
      if ioresult<>0 then begin
        q:=false;
        close (batchf);
        iocode:=ioresult;
        if not issysop
          then
            begin
              fileerror ('Opendoor',d.batchname);
              exit
            end
          else
            begin
              maybemakebatch (d.batchname);
              if not exist (d.batchname) then exit
            end
      end
    until q;
    assign (outf,'DOOR.BAT');
    rewrite (outf);
    writeln (outf,'TEMPDOOR ',params);
    textclose (outf);
    assign (outf,'TEMPDOOR.BAT');
    rewrite (outf);
    while not eof(batchf) do begin
      readln (batchf,tmp);
      writeln (outf,tmp)
    end;
    if online then bd:=baudrate else bd:=0;
    Inc(D.NumUsed);
    seekdofile (n);
    nwrite (dofile,d);
    writelog (9,1,d.name);
    updateuserstats (false);
    writeurec;
    writestatus;
    makechaintxt;
    write_door_sys(false);
    write_dorinfo1_def(false);  (* RBBS-PC's DORINFO1.DEF *)
    getdir (0,tmp);
    If NOT D.Full_Drop Then
      Begin
        textclose(batchf);
        textclose(outf);
       { If Cfg.Use_Fos Then }
          ClosePort;
        ExecuteWithSwap(D.BatchName,'',True);
       { If Cfg.Use_Fos Then }
          Q := Install_Fossil(Cfg.UseCom);
        SetParam(Cfg.UseCom,BaudRate,False);
        ChDIR(TMP);
        AnsiCLS;
        WriteHDr('Welcome back to '+Cfg.LongName);
        BottomLine;
        Exit;
      End;
    writeln (outf,'cd '+tmp);
    writeln (outf,'RETURN');
    textclose (batchf);
    textclose (outf);
    writereturnbat;
    ensureclosed;
    halt (e_door)
  end;

  procedure getinfo;
  var n:integer;
      d:doorrec;
  begin
    n:=getdoornum ('Get information on');
    if n=0 then exit;
    seekdofile (n);
    nread (dofile,d);
    writeln;
    printtext ('DOOR.TXT','DOOR.MAP',d.info)
  end;

  procedure changedoor;
  var n:integer;
      d:doorrec;
  begin
    n:=getdoornum ('Change');
    if n=0 then exit;
    seekdofile (n);
    nread (dofile,d);
    writeln (^R'Name'^A':'^S' ',d.name);
    write (^R'New name [CR]=Same'^A': ');
    InputBox(30);
    if length(inpt)>0 then d.name:=inpt;
    writeln (^M^R'Level'^A':'^S' ',d.level);
    writestr (^R'New level'^A': *');
    if length(inpt)>0 then d.level:=valu(inpt);
    writeln (^M^R'Batch file name'^A':'^S' ',d.batchname);
    write (^R'New batch file name'^A': ');
    InputBox(12);
    if length(inpt)>0 then
      if checkbatchname (inpt)
        then d.batchname:=inpt
        else writeln ('Invalid filename: '^S,inpt);
    maybemakebatch (d.batchname);
    writeln;
    printtext ('DOOR.TXT','DOOR.MAP',d.info);
    writestr (^M'Replace text? !');
    if yes then
      repeat
        deletetext ('DOOR.TXT','DOOR.MAP',d.info);
        getdoorinfo (d);
        if d.info<0 then writeln (^M'You must enter some information.')
      until d.info>=0;
    seekdofile (n);
    nwrite (dofile,d);
    writelog (10,1,d.name)
  end;

  procedure deletedoor;
  var n,cnt:integer;
      td,d:doorrec;
      f:file;
  begin
    n:=getdoornum ('delete');
    if n=0 then exit;
    seekdofile (n);
    nread (dofile,d);
    writestr ('Delete '+d.name+': !');
    if not yes then exit;
    writeln ('Deleting...');
    seekdofile (n+1);
    for cnt:=n to filesize(dofile)-1 do begin
      nread (dofile,td);
      seekdofile (cnt);
      nwrite (dofile,td)
    end;
    seek (dofile,filesize(dofile)-1);
    truncate (dofile);
    deletetext ('DOOR.TXT','DOOR.MAP',d.info);
    writestr (^M'Erase disk file '+d.batchname+'? !');
    if yes then begin
      assign (f,d.batchname);
      erase (f);
      if ioresult<>0 then writeln ('(File not found)')
    end;
    writelog (10,2,d.name)
  end;

  function init_doors : boolean;
  begin
    init_doors := false;
    if not cfg.allowdoors then begin
      fromdoor := false;
      writehdr('The sysop has disabled doors.');
      exit;
    end;
    if not isopen(dofile) then begin
      opendofile;
      Close_Them_All(DoFile);
    end;
    if numdoors = 0 then begin
      writehdr('No doors exist right now!');
      maybemakedoor;
      if numdoors = 0 then exit;
    end;
    init_doors := true;
  end;

begin
end.

var q:integer;
begin
  if not cfg.allowdoors then begin
    writehdr ('All doors are locked!');
    if issysop then writeln('(Please re-configure to change this setting)');
    fromdoor:=false;
    returnto:='M';
    exit
  end;
  if fromdoor then begin
    fromdoor:=false;
    Writeln(^M);
    if returnto='D' then writeHdr ('Welcome back to ViSiON/2!')
  end;
  cursection:=doorssysop;
  opendofile;
  if numdoors=0 then begin
    writeln (^R'('^S'No doors exist!'^R')'^M);
    maybemakedoor;
    if numdoors=0 then begin
      close (dofile);
      exit
    end
  end;
  If ReturnTo <> 'D' Then
    WriteHdr('Online Doors');
  Writeln;
  repeat
    q:=menu('','DOORS','QLOIH%@#');
    if q < 0 then opendoor(-q) else
    case q of
      2:listdoors;
      3:opendoor(0);
      4:getinfo;
      6:sysopdoors
    end
  until hungupon or (q=1) or (filesize(dofile)=0);
  close (dofile)
end;