{$R-,S-,I-,D-,F-,V-,B-,N-,L+,O+}

unit lineedit;

interface

uses gentypes,configrt,gensubs,subs1,subs2;

function linereedit (var m:message; gettitle:boolean):boolean;

implementation

function linereedit (var m:message; gettitle:boolean):boolean;
var done,editmode:boolean;
    curline,r1,r2,cols:integer;

  procedure init;
  begin
    if eightycols in urec.config
      then cols:=79
      else cols:=39;
    linereedit:=false;
    done:=false;
    editmode:=false;
    curline:=1;
    Write(Direct,#27+'[2J');
    Writeln(^R'['^A'ViSiON/2 '+versionnum,' Message Editor'^R'] (c) 1993 Ruthless Enterprises');
    if m.numlines=0
      then writeln (^B^M^R'['^S'Enter Message - '^P,maxmessagesize,^S' lines maximum'^R']')
      else begin
        writeln (^B^M'Re-editing message.');
        writeln ('Current size: '^S,m.numlines);
        writeln ('Note: Inserting before line 1.');
        writeln ('/A will abort changes.'^M)
      end;
    writeln (^R'['^S'Enter /? for help on / commands'^R']'^B^M)
  end;

  procedure setbreak;
  begin
    clearbreak;
    nobreak:=true;
    dontstop:=true;
    wordwrap:=true;
    linecount:=0
  end;

  function msgisblank:boolean;
  begin
    if m.numlines>0 then msgisblank:=false else begin
      writeln (^B'Sorry, message blank!');
      msgisblank:=true
    end
  end;

  function getrange:boolean;
  begin
    parserange (m.numlines,r1,r2,'Range Listing');
    getrange:=r1<>0
  end;

  function getlinenum (txt:mstr):boolean;
  begin
    writestr (^R'Line # to '^A+txt+^R': *');
    r1:=valu(inpt);
    r2:=r1;
    if (r1>=1) and (r1<=m.numlines)
      then getlinenum:=true
      else begin
        getlinenum:=false;
        writeln (^R'Invalid line!')
      end
  end;

  procedure inslines (r1,r2:integer);
  var n,cnt:integer;
  begin
    n:=r2-r1+1;
    m.numlines:=m.numlines+n;
    for cnt:=m.numlines downto r2+1 do m.text[cnt]:=m.text[cnt-n]
  end;

  procedure dellines (r1,r2:integer);
  var n,cnt:integer;
  begin
    n:=r2-r1+1;
    m.numlines:=m.numlines-n;
    for cnt:=r1 to m.numlines do m.text[cnt]:=m.text[cnt+n]
  end;

  procedure insertline;
  var cnt:integer;
  begin
    if m.numlines=maxmessagesize then exit;
    inslines (curline,curline);
    m.text[curline]:=inpt;
    curline:=curline+1
  end;

  function iseditcommand:boolean;
  begin
    iseditcommand:=(inpt[1]='/') and (length(inpt)>0)
  end;

  function userissure:boolean;
  begin
    writeln ('Warning!  Message will be erased!');
    writestr ('Confirm? !');
    userissure:=yes
  end;

  procedure topofmsg;
  begin
    writeln (^R'[ '^S'Top of msg '^R']')
  end;

  procedure abortmes;
  begin
    done:=userissure
  end;

  procedure backline;
  begin
    if m.numlines<1 then begin
      topofmsg;
      exit
    end;
    writeln (^R'<Correct previous line>');
    curline:=curline-1;
    dellines (curline,curline)
  end;

  procedure continuemes;
  begin
    writeln (^B^R^M'Continue your message...');
    curline:=m.numlines+1;
    editmode:=false
  end;

  procedure deletelines;
  begin
    if not getrange then exit;
    if (r1=1) and (r2=m.numlines) then begin
      writestr ('Delete whole message? !');
      if not yes then exit
    end;
    dellines (r1,r2)
  end;

  procedure seteditmode;
  begin
    if editmode
      then writeln('You are already in edit mode!')
      else editmode:=true
  end;

  procedure fixline;
  var tmp:lstr;
  begin
    if not getlinenum ('fix') then exit;
    setbreak;
    writeln ('Line currently reads:');
    writeln (m.text[r1],^M);
    wordwrap:=false;
    buflen:=cols;
    beginwithspacesok:=true;
    buflen:=79;
    writestr (^R'Enter New Line'^A':'^M'*');
    if length(inpt)<>0 then m.text[r1]:=inpt;
    continuemes
  end;

  procedure insertlines;
  begin
    if not getlinenum ('insert before') then continuemes;
    curline:=r1
  end;

  procedure listmes;
  var cnt,r1,r2:integer;
      linenum:boolean;
  begin
    if msgisblank then exit;
    parserange (m.numlines,r1,r2,'List Message');
    if r1=0 then exit;
    writestr ('Line numbers? !');
    linenum:=yes;
    write (^R);
    for cnt:=r1 to r2 do begin
      if linenum then writeln (cnt,':');
      writeln (m.text[cnt]);
      if break then exit
    end
  end;

  procedure centerline;
  var spaces:lstr;
  begin
    fillchar (spaces[1],80,32);
    if editmode then begin
      setbreak;
      buflen:=cols;
      wordwrap:=false;
      writestr ('Enter line to center:'^M'*')
    end else delete(inpt,1,1);
    while (length(inpt)>0) and (inpt[1]=' ') do delete (inpt,1,1);
    if length(inpt)=0 then exit;
    spaces[0]:=chr((cols-length(inpt)) div 2);
    inpt:=spaces+inpt;
    insertline
  end;

  procedure clearmes;
  begin
    if userissure then begin
      writeln('Starting message over...');
      m.numlines:=0;
      curline:=1
    end
  end;

  procedure searchandreplace;
  var sfor,repw:lstr;
      l:^lstr;
      ask:boolean;
      cl,cp,sl,max:integer;

    procedure replace;
    var new,old:lstr;
    begin
      old:=copy (l^,cp,sl);
      new:=repw;
      if length(new)>0 then
        if old[1] in ['A'..'Z']
          then new[1]:=upcase(new[1]);
      delete (l^,cp,sl);
      while length(l^)+length(new)>cols do l^[0]:=pred(l^[0]);
      insert (new,l^,cp);
      cp:=cp+length(new)-1
    end;

    procedure maybereplace;
    var cnt:integer;
    begin
      if ask then begin
        writeln (^B^M,cl,':'^M,l^);
        for cnt:=1 to cp-1 do write (' ');
        for cnt:=1 to sl do write ('^');
        writeln;
        writestr ('Replace? !');
        if not yes then exit
      end;
      replace
    end;

  begin
    if msgisblank then exit;
    writestr (^R'Search for'^A': *');
    if length(inpt)=0 then exit;
    sfor:=upstring(inpt);
    sl:=length(inpt);
    writestr (^R'Replace with'^A': *');
    repw:=inpt;
    writestr (^R'Ask each time? !');
    ask:=yes;
    max:=length(l^)-sl+1;
    for cl:=1 to m.numlines do begin
      l:=addr(m.text[cl]);
      max:=length(l^)-sl+1;
      cp:=0;
      while cp<max do begin
        cp:=cp+1;
        if match(sfor,copy(l^,cp,sl)) then maybereplace;
        max:=length(l^)-sl+1
      end
    end;
    writeln (^B^M'Search and replace complete')
  end;

  procedure savemes;
  begin
    done:=true;
    if m.numlines=0
      then writeln ('Message blank!')
      else begin
        writeln ('Saving..');
        linereedit:=true
      end
  end;

  procedure retitle;
  begin
    if gettitle then begin
      writeln (^R'Title is'^A': '^S+m.title);
      writestr (^R'Enter new title'^A': &');
      if length(inpt)>0 then m.title:=inpt
    end else writeln ('This message can''t have a title.')
  end;

  procedure edithelp;
  begin
    printfile (Cfg.textfiledir+'Edithelp.');
    HoldScreen;
    editmode:=true
  end;

  procedure editcommand;
  var k:char;
  begin
    while iseditcommand and (length(inpt)>0) do delete (inpt,1,1);
    if length(inpt)=0 then begin
      editmode:=true;
      exit
    end;
    k:=upcase(inpt[1]);
    case k of
      'A':abortmes;
      'B':backline;
      'C':continuemes;
      'D':deletelines;
      'E':seteditmode;
      'F':fixline;
      'I':insertlines;
      'L':listmes;
      'M':centerline;
      'N':clearmes;
      'R':searchandreplace;
      'S':savemes;
      'T':retitle
      else edithelp
    end
  end;

  procedure editcommands;
  begin
    editcommand;
    while editmode and not done do begin
      writestr (^M^R'Edit Command ('^A'?/help'^R'): *');
      if hungupon then done:=true else editcommand
    end
  end;

  procedure getline;
  begin
    setbreak;
    inpt:='/E';
    if m.numlines=maxmessagesize then begin
      writeln ('Sorry, message is full!');
      exit
    end;
    if hungupon then exit;
    if m.numlines=maxmessagesize-3 then writeln ('3 lines left!');
    if curline>m.numlines+1 then curline:=m.numlines+1;
    lastprompt:='Continue your message...'^M;
    buflen:=cols;
    getstr(true);
    if inpt=^H
      then if curline>1
        then
          begin
            writeln (^R'[ '^S'Back'^R' ]');
            curline:=curline-1;
            chainstr:=m.text[curline];
            dellines (curline,curline)
          end
        else topofmsg
      else if not iseditcommand then insertline
  end;

  procedure getlines;
  begin
    repeat
      getline
    until hungupon or iseditcommand or (m.numlines=maxmessagesize);
    if not iseditcommand then inpt:='/'
  end;

begin
  init;
  repeat
    getlines;
    editcommands
  until done;
  writeln (^B^M^M)
end;

begin
end.