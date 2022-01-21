{$R-,S-,I-,D-,F-,V-,B-,N-,L+,O+}

unit group;

interface

uses gentypes;

const groupclassstr:array [groupclass] of string[8]=
          ('Public','Private','Personal');

procedure seekgfile (n:integer);
procedure listgroups;
function lookupgroup (nm:mstr):integer;
function groupaccess (var g:grouprec):boolean;
procedure addmember (var g:grouprec; n:integer);
function ismember (var g:grouprec; n:integer):boolean;
function getgroupclass:groupclass;
function getgroupnum:integer;
function init_email : boolean;

implementation

uses dos, mnet, configrt, gensubs, subs1, userret, mainr1, flags,
     email0, subs2;

  procedure opengfile;
  begin
    assign (gfile,Cfg.DATADIR+'GROUPS');
    reset (gfile);
    if ioresult<>0 then begin
      close (gfile);
      rewrite (gfile)
    end
  end;

  procedure seekgfile (n:integer);
  begin
    seek (gfile,n-1)
  end;

  function ismember (var g:grouprec; n:integer):boolean;
  var cnt:integer;
  begin
    ismember:=true;
    for cnt:=1 to g.nummembers do
      if g.members[cnt]=n then exit;
    ismember:=false
  end;

  function groupaccess (var g:grouprec):boolean;
  begin
    if issysop then begin
      groupaccess:=true;
      exit
    end;
    groupaccess:=false;
    case g.class of
      publicgroup:groupaccess:=true;
      personalgroup:groupaccess:=g.creator=unum;
      privategroup:groupaccess:=ismember (g,unum)
    end
  end;

  function lookupgroup (nm:mstr):integer;
  var cnt:integer;
      g:grouprec;
  begin
    lookupgroup:=0;
    seekgfile (1);
    for cnt:=1 to filesize(gfile) do begin
      read (gfile,g);
      if groupaccess(g)
        then if match(g.name,nm)
          then begin
            lookupgroup:=cnt;
            exit
          end
    end
  end;

  procedure listgroups;
  var g:grouprec;
      cnt:integer;
  begin
    Header('Name                          Class      ');
    if break then exit;
    seekgfile (1);
    for cnt:=1 to filesize(gfile) do begin
      read (gfile,g);
      if groupaccess(g) then begin
        tab (g.name,30);
        writeln (groupclassstr[g.class]);
        if break then exit
      end
    end
  end;

  function getgroupclass:groupclass;
  var k:char;
  begin
    repeat
      inpt[1]:=#0;
      writestr ('Group class p(U)blic, p(R)ivate, p(E)rsonal: &');
      k:=upcase(inpt[1]);
      if k in ['U','R','E'] then begin
        case k of
          'U':getgroupclass:=publicgroup;
          'R':getgroupclass:=privategroup;
          'E':getgroupclass:=personalgroup
        end;
        exit
      end
    until hungupon;
    getgroupclass:=publicgroup
  end;

  procedure addmember (var g:grouprec; n:integer);
  begin
    if ismember (g,n) then begin
      writeln ('That person is already a member!');
      exit
    end;
    if g.nummembers=maxgroupsize then begin
      writeln ('Sorry, group is full!');
      exit
    end;
    g.nummembers:=g.nummembers+1;
    g.members[g.nummembers]:=n
  end;

  procedure addgroup;
  var g:grouprec;
      un:integer;
  begin
    writestr ('Group name: &');
    if (length(inpt)=0) or (inpt='?') then exit;
    g.name:=inpt;
    if lookupgroup (g.name)<>0 then begin
      writeln (^M'Group already exists!');
      exit
    end;
    g.class:=getgroupclass;
    g.creator:=unum;
    g.nummembers:=0;
    writestr ('Include yourself in the group? !');
    if yes then addmember (g,unum);
    writeln (^M^R'Enter names of members, ('^S'Cr'^R') when done'^M);
    repeat
      writestr (^R'Member'^A': &');
      if length(inpt)>0 then begin
        un:=lookupuser (inpt);
        if un=0
          then writeln('User not found!')
          else addmember (g,un)
      end
    until hungupon or (length(inpt)=0) or (g.nummembers=maxgroupsize);
    seek (gfile,filesize (gfile));
    nwrite (gfile,g);
    writestr (^M'Group created!');
    writelog (13,1,g.name)
  end;

  function maybecreategroup (nm:mstr):integer;
  begin
    writestr ('Create group '+nm+'? !');
    if yes then begin
      addtochain (nm);
      addgroup;
      maybecreategroup:=lookupgroup (nm)
    end else maybecreategroup:=0
  end;

  function getgroupnum:integer;
  var groupname:mstr;
      gn:integer;
      g:grouprec;
  begin
    getgroupnum:=0;
    groupname:=copy(inpt,2,255);
    repeat
      if length(groupname)=0 then begin
        writestr (^M^R'Group name ['^S'?'^R'] List'^A': &');
        if length(inpt)=0 then exit;
        if inpt[1]='/' then delete (inpt,1,1);
        if length(inpt)=0 then exit;
        groupname:=inpt
      end;
      if groupname='?' then begin
        listgroups;
        groupname:=''
      end
    until length(groupname)>0;
    gn:=lookupgroup (groupname);
    if gn=0 then begin
      writeln ('Group not found!');
      gn:=maybecreategroup (groupname);
      if gn=0 then exit
    end;
    seekgfile (gn);
    nread (gfile,g);
    if not groupaccess(g)
      then writeln ('Sorry, you may not access that group!')
      else getgroupnum:=gn
  end;

    Procedure GroupFlags;
    var gn,bn,un,cnt:integer;
        bname:sstr;
        ac:accesstype;
        g:grouprec;
        u:userrec;
        n:NewScanRec;
    begin
      writeln ('Grant all group members access to a sub-board'^M);
      gn:=getgroupnum;
      if gn=0 then exit;
      writestr ('Sub-board access name/number: &');
      writeln;
      bname:=inpt;
      opentempbdfile;
      bn:=searchboard(bname);
      closetempbdfile;
      if bn=-1 then begin
        writeln ('No such board!');
        exit
      end;
      writelog (14,3,bname);
      for cnt:=1 to g.nummembers do begin
        un:=g.members[cnt];
        writeln (lookupuname(un));
        seek (ufile,un);
        nread (ufile,u);
        GetScanRec(N,MsgConf);
        setuseraccflag (N,bn,letin);
        WriteScanRec(N,MsgConf);
        seek (ufile,un);
        nwrite (ufile,u)
      end
    end;

  function init_email : boolean;
  begin
    init_email := true;
    readcatalogs(false);
    if isopen(gfile) then exit;
    close_them_all(gfile);
    opengfile;
    lastread := 0;
  end;

begin
end.