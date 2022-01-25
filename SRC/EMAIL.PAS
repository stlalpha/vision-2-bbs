{$R-,S-,I-,D-,F-,V-,B-,N-,L+,O+}

unit email;

interface

uses gentypes;

procedure listmail (var c : catalogrec);
procedure write_to_file;
procedure viewoutgoing;
procedure editmailuser;
procedure copymail;
procedure forwardmail;
procedure nextmail;
procedure sendmail;
procedure zippymail;
procedure readnum (n:integer);
procedure mailread(newonly : boolean);
procedure someoneelse;
procedure deleteincoming;
procedure scanall;
procedure deleterange;
procedure announcement;
procedure querydelete(var c:catalogrec);
procedure killoutgoing;

implementation

uses MNeT,configrt,gensubs,subs1,subsovr,subs2,textret,flags,
     mailret,userret,overret1,mainr1,mainr2, mycomman, email0,
     group;

  procedure writenummail (var c:catalogrec; txt:mstr);
  begin
    writeln (^B^M'You have ',c.nummail+c.additional,' ',txt,
             ' message',s(c.nummail));
    if c.additional>0
      then writeln ('   Note: Of those, ',
                     numthings (c.additional,'is','are'),' uncataloged.')
  end;


  Procedure MailHeader(M:MailRec; Num:Integer);
  Begin
      Sr.C[1] := '|T'; Sr.S[1] := M.Title;
      Sr.C[2] := '|S'; If M.Anon Then Begin
                         Sr.S[2] := Cfg.AnonymousStr;
                         If IsSysOp
                           Then Sr.S[2] := Sr.S[2] + ' ('+m.sentby+')';
                       End
                         Else Sr.S[2] := M.SentBy;
      Sr.C[3] := '|W'; Sr.S[3] := TimeStr(M.When);
      Sr.C[4] := '|D'; Sr.S[4] := DateStr(M.When);
      Sr.C[5] := '|N'; If M.Read
                         Then Sr.S[5] := 'Old'
                         Else Sr.S[5] := 'New';
      Sr.C[6] := '|A'; Sr.S[6] := Strr(Incoming^.NumMail);
      Sr.C[7] := '|#'; Sr.S[7] := Strr(Num);
      DataFile(Cfg.TextFileDir+'MAILHDR.ANS');
  End;

  Procedure Readit (num:integer; var m:mailrec);
  Begin
    MailHeader(m,num);
    If Not Break
      Then PrintText ('EMAIL.TXT','EMAIL.MAP',M.Line);
    If (M.Return) and (Unum=M.SentTo) then Begin
      M.Return:=False;
      Notice(M.Sentby,Unam+' read mail from you titled "'+m.title+'"');
    End
  end;

  procedure readincoming (n:integer);
  var m:^mailrec;
      cnt:integer;
  begin
    m:=addr(incoming^.mail[n]);
    readit (n,m^);
    if not (m^.read) then begin
      m^.read:=true;
      seek (mfile,m^.fileindex);
      nwrite (mfile,m^)
    end;
    for cnt:=n+1 to incoming^.nummail do
      if match(incoming^.mail[cnt].sentby,m^.sentby) then begin
        writeln (^B^M'There''s more mail from ',m^.sentby,'!');
        exit
      end
  end;

  Procedure ListMail (Var C : CatalogRec);

  Const Old_New : Array[False..True] Of Sstr = ('New','Old');

  Var N : Integer;
      U : UserRec;
      Cnt : Integer;
      M : MailRec;
      Name : Sstr;

  Begin

    If Ofs(C) = Ofs(Incoming^)
      Then Name := 'IN_MAIL.'
      Else Name := 'OUT_MAIL.';

    ListingFile(Cfg.TextFileDir + Name + 'TOP',True);

    If Break
      Then exit;

    For Cnt := 1 To C.NumMail Do If Not Break
    Then Begin
      M := C.Mail[Cnt];
      Sr.C[1] := 'NN'; Sr.S[1] := Strr(Cnt);       Sr.T[1] := 2;
      Sr.C[2] := 'TI'; Sr.S[2] := M.Title;         Sr.T[2] := 30;
      Sr.C[3] := 'RE'; Sr.S[3] := Old_New[M.Read]; Sr.T[3] := 3;
      Sr.C[4] := 'FF';
      If Match(M.SentBy,Unam)
        Then Sr.S[4] := LookUpUName (M.SentTo)
        Else Sr.S[4] := M.SentBy;
      Sr.T[4] := 30;
      ListingFile(Cfg.TextFileDir + Name + 'MID',False);
    End;

    ListingFile(Cfg.TextFileDir + Name + 'BOT',False);
  end;

  Procedure Writemail (var c:catalogrec; num:integer);
  Begin
    Seek (mfile,c.mail[num].fileindex);
    NWrite (mfile,c.mail[num])
  End;

  function checklastread:boolean;
  begin
    if (lastread<0) or (lastread>incoming^.nummail) then lastread:=0;
    checklastread:=lastread=0
  end;

  function getmsgnumber (var c:catalogrec; txt:sstr):integer;
  var n:integer;
      inc:boolean;
  begin
    inc:=ofs(c)=ofs(incoming^);
    getmsgnumber:=0;
    if c.nummail=0 then begin
      if c.additional>0 then readcatalogs(true);
      if c.nummail=0 then writeln (^M'Sorry, no mail!');
      if inc then lastread:=0;
      exit
    end;
    inpt:=copy(inpt,2,255);
    if length(inpt)=0
      then if inc
        then n:=lastread
        else n:=0
      else n:=valu(inpt);
    if (n<1) or (n>c.nummail) then begin
      repeat
        writestr (^M^R'E-Mail # to '+txt+' ('^S'?/List'^R'): &');
        if length(inpt)=0 then exit;
        if inpt='?' then listmail (c)
      until inpt<>'?';
      n:=valu(inpt);
      if (n<1) or (n>c.nummail) then n:=0
    end;
    getmsgnumber:=n
  end;

  procedure deletemail (var c:catalogrec; n:integer);
  begin
    delmail (c.mail[n].fileindex);
    writeln (^A+c.mail[n].title+^R' by '^A+c.mail[n].sentby+^R' has been deleted!');
    readcatalogs(true);
  end;

  Procedure QueryDelete(var c:catalogrec);
  var x:byte;
  Begin
    if c.nummail < 1
      then exit;
    For X := C.NumMail DownTo 1 do begin
     if C.Mail[X].Read
     Then Begin
       Sr.C[1] := 'TI'; Sr.S[1] := C.Mail[x].Title;
       Sr.C[2] := 'SB'; Sr.S[2] := C.Mail[x].SentBy;
       MultiColor(Strng^.U_Have_Read_Mail);
       Writeln;
       DefYes := False;
       WriteStr(Strng^.Delete_Mail_Now);
       If Yes
         Then DeleteMail(c,x);
     end
    end
  end;

  procedure nextmail;
  begin
    inc(lastread);
    if lastread>incoming^.nummail
      then
        begin
          lastread:=0;
          if incoming^.nummail < 1
            then writeln(^S^M'You have no mail.') else
          if incoming^.additional > 0
            then writeln (^S^M'You must delete some old mail first!')
            else writeln (^S^M'No more mail.')
        end
      else readincoming (lastread)
  end;

  procedure readnum (n:integer);
  begin
    if (n<1) or (n>incoming^.nummail) then begin
      lastread:=0;
      exit
    end;
    lastread:=n;
    readincoming (n)
  end;

  procedure readmail;
  begin
    readnum (getmsgnumber (incoming^,'read'))
  end;

  Procedure ListAllMail(All : Boolean);
  Begin
    If Incoming^.NumMail > 0
      Then Listmail (incoming^);
    If Not All
      Then Exit;
    if outgoing^.nummail > 0
      then listmail (outgoing^);
  end;

  procedure deleteincoming;
  var n:integer;
  begin
    if checklastread then begin
      n:=getmsgnumber (incoming^,'delete');
      if n=0 then exit;
      lastread:=n
    end;
    deletemail (incoming^,lastread);
    lastread:=lastread-1
  end;

  procedure killoutgoing;
  var n:integer;
  begin
    n:=getmsgnumber (outgoing^,'kill');
    if n<>0 then deletemail (outgoing^,n)
  end;

  procedure autoreply;
  var n:integer;
  begin
    if checklastread then begin
      n:=getmsgnumber (incoming^,'reply to');
      if n=0 then exit;
      lastread:=n
    end;
    With Incoming^.Mail[lastread] Do Begin
      Quoting.AllowQuote := True;
      Quoting.MsgNum := Line;
      Quoting.MsgSec := False;
      Quoting.Anon := Anon;
      Quoting.From := SentBy;
      Quoting.SendTo:=LookUpUName(SentTo);
      Quoting.Title:= Title;
      Quoting.When := When;
      Quoting.TxtFile := 'EMAIL.TXT';
      Quoting.MailFile := 'EMAIL.MAP';
      sendmailto (sentby,anon);
    end;
    Quoting.AllowQuote := False;
    readcatalogs(true);
  end;

  procedure write_to_file;
  begin
    writeln(^S^R^M);
    if not issysop then begin
      writeln('That command requires SysOp Access.');
      exit;
    end;
    if (lastread < 1) or (lastread > incoming^.nummail)
      then exit;
    with incoming^.mail[LastRead] do
      TextToFile('EMAIL.TXT','EMAIL.MAP',Line,Title,SentBy,
                  LookUpUName(SentTo));
  end;

  procedure viewoutgoing;
  var n:integer;
  begin
    n:=getmsgnumber (outgoing^,'view');
    if n=0 then exit;
    readit (n,outgoing^.mail[n])
  end;

  procedure showinfos;
  var a,n:integer;
  begin
    If (IsSysop=False) Then Begin
      Write('You don''t have enough access to do that!');
      Exit;
    End;
    if checklastread then begin
      n:=getmsgnumber (incoming^,'delete');
      if n=0 then exit;
      lastread:=n
    end;
    For a:=1 to 5 do showinfoforms (incoming^.mail[lastread].sentby,a)
  end;

  procedure editmailuser;
  var n:integer;
      m:mstr;
  begin
    If (IsSysop=False) then Begin
      Write(^G^G^G'Bad User...');
      Exit;
    End;
    if checklastread then begin
      n:=getmsgnumber (incoming^,'edit the sender');
      if n=0 then exit;
      lastread:=n
    end;
    m:=incoming^.mail[lastread].sentby;
    n:=lookupuser (m);
    if n=0 then begin
      writeln (^B^R'User ',m,' not found!');
      exit
    end;
    edituser (n)
  end;

  Procedure WriteCurMsg;
  Var B : Boolean;
  Begin
    B := CheckLastRead;
    If LastRead = 0 Then Begin
      MultiColor(Strng^.Current_Mail_None);
      Writeln;
      Exit;
    End;
    With Incoming^.Mail[LastRead] Do Begin
      Sr.C[1] := 'TI'; Sr.S[1] := Title;
      Sr.C[2] := 'AU'; Sr.S[2] := SentBy;
      Sr.C[3] := 'NU'; Sr.S[3] := Strr(LastRead);
    End;
    MultiColor(Strng^.List_Current_Mail);
    Writeln;
  End;

  procedure showannouncement (un:integer);
  var u:userrec;
  begin
    seek (ufile,un);
    nread (ufile,u);
    if u.emailannounce>-1 then begin
      writehdr (u.handle+'''s Announcement');
      printtext ('ANNOUNCE.TXT','ANNOUNCE.MAP',u.emailannounce)
    end
  end;

  procedure copymsg (var m:mailrec; un:integer);
  var me:message;
      line:longint;
      b:boolean;
      U:Userrec;
      Name:Mstr;
  begin
    me.anon:=m.anon;
    me.title:='Was from '+m.sentby;
    reloadtext ('EMAIL.TXT','EMAIL.MAP',m.line,me);
    showannouncement (un);
    writestr (^R'Add a prologue ['^A'Y'^R']es ['^A'N'^R']o ['^A'A'^R']bort? *');
    if match(inpt,'a') then exit;
    if yes then b:=reedit (me,true);
    line:=maketext ('EMAIL.TXT','EMAIL.MAP',me,'');
    Seek(UFile,Un);
    NRead(UFile,U);
    Name:=U.Handle;
    WriteStr('Notify you when '+Name+' reads this? !');
    B:=Yes;
    addmail (un,line,b,me);
    readcatalogs(true);
  end;

  procedure copymail;
  var n,un,line:integer;
  begin
    if checklastread then begin
      n:=getmsgnumber (incoming^,'copy');
      if n=0 then exit;
      lastread:=n
    end;
    n:=lastread;
    writestr (^R'User to copy it to'^A': &');
    if length(inpt)=0 then exit;
    un:=lookupuser (inpt);
    if un=0 then exit;
    copymsg (incoming^.mail[n],un)
  end;

  procedure forwardmail;
  var n,un:integer;
  begin
    if checklastread then begin
      N:=getmsgnumber (incoming^,'forward');
      if n = 0 then exit;
      lastread:=n
    end;
    n:=lastread;
    writestr (^R'User to forward mail to'^A': &');
    if length(inpt)=0 then exit;
    un:=lookupuser (inpt);
    if un=0 then exit;
    copymsg (incoming^.mail[n],un);
    deletemail (incoming^,n)
  end;

  procedure sendmail;
  var g:grouprec;

    procedure sendit (showeach:boolean);
    var un,cnt:integer;
        line:longint;
        me:message;
        return:boolean;

      procedure addit (n:integer);
      begin
        if n<>unum then begin
          if showeach
            then writeln (^R'Sending'^A': '^S + lookupuname(n));
          addmail (n,line,return,me)
        end else deletetext ('EMAIL.TXT','EMAIL.MAP',line)
      end;

    begin
      if g.nummembers < 1 then exit;
      writehdr ('Sending mail to '+g.name);
      okfortitle:=true;
      Me.Add_AutoSig := True;
      line:=editor (me,true,true,g.name,'0','EMAIL.TXT','EMAIL.MAP');
      if line < 0 then exit;
      { WriteStr('Notify you when this mail is read? !'); }
      WriteStr(Strng^.Mail_Notify);
      return:=yes;
      addit (g.members[1]);
      if g.nummembers=1 then exit;
      writeln (^B^M);
      for cnt:=2 to g.nummembers do begin
        un:=g.members[cnt];
        if un<>unum then begin
          line:=maketext ('EMAIL.TXT','EMAIL.MAP',me,'');
          if line<0 then begin
            writeln (cnt,' of ',g.nummembers,' completed.');
            exit
          end;
          addit (un)
        end
      end;
      readcatalogs(true);
    end;

    procedure sendtogroup;
    var gn:integer;
    begin
      gn:=getgroupnum;
      if gn=0 then exit;
      seekgfile (gn);
      nread (gfile,g);
      sendit (true)
    end;

    procedure sendtousers;
    var cnt,un:integer;
    begin
      g.name:=inpt;
      un:=lookupuser (g.name);
      if un=0 then begin
        writeln (^M'User not found.');
        exit
      end;
      g.nummembers:=1;
      g.members[1]:=un;
      cnt:=1;
      showannouncement (un);
      repeat
        MultiColor(Strng^.Carbon_Copy_To);
        InputBox(30);
        if length(inpt)>0 then begin
          un:=lookupuser (inpt);
          if un=0
            then writeln (^M'User not found!'^M)
            else if ismember (g,un)
              then writeln (^M'User is already receiving a copy!')
              else begin
                cnt:=cnt+1;
                g.nummembers:=cnt;
                g.members[cnt]:=un;
                showannouncement (un)
              end
        end
      until (length(inpt)=0) or (cnt=maxgroupsize);
      sendit (g.nummembers>1)
    end;

  begin
    { Write(^P'User to send mail to '^O'['^S'+'^O']'^P'/Group Mail: '); }
    MultiColor(Strng^.Send_Mail_To_Who);
    InputBox(30);
    if length(inpt)<>0
      then if inpt[1]='+'
        then sendtogroup
        else sendtousers
  end;

  procedure zippymail;
  var un:integer;
      me:message;
      l:longint;
  begin
    MultiColor (Strng^.Send_Mail_To_Who);
    InputBox(30);
    if length(inpt)=0 then exit;
    un:=lookupuser (inpt);
    if un=0 then begin
      writeln ('No such user!');
      exit
    end;
    Me.Add_AutoSig := True;
    l:=editor (me,false,false,inpt,'0','EMAIL.TXT','EMAIL.MAP');
    if l<0 then exit;
    me.title:='-----';
    me.anon:=false;
    addmail (un,l,true,me);
    readcatalogs(true);
  end;

  Procedure MailRead(NewOnly : Boolean);
  Const Names : Array[1..9] Of String[10] =
  (' Next ',' Kill ',' Reply ',' Again ',' Jump ',' List ',' Fwrd ',' Copy ',' Quit ');
        Return : Array[1..9] Of Char = ('N','K','R','A','J','L','F','C','Q');
  Var X : Byte;

    Procedure GetInput;

      Procedure PlaceBar(Hi:Boolean);
      Const Cols : Array[1..9] Of Byte = (2,8,14,21,28,34,40,46,52);
      Begin
        If Hi
          Then Ansicolor(Urec.Color7)
          Else Ansicolor(Urec.Color3);
        Write(Direct,#13);
        Write(Direct,#27 + '[' + Strr(Cols[X] - 1) + 'C');
        Write(Names[x]);
      End;

    Var K : Char;
        Done : Boolean;
    Begin
      If Not BARS_OK Then Begin
        Write(^R'('^S'Mail'^R') ');
        WriteStr(^S'K'^P'ill '^S'N'^P'ext '^S'R'^P'eply '^S'A'^P'gain '+
        ^S+'J'^P'ump '^S'L'^P'ist '^S'F'^P'orward '^S'C'^P'opy '^S'Q'^P'uit : *');
        Exit;
      End;
      Done := False;
      NoBreak:=True;
      ClearChain;
      Inpt[0]:=#0;
      Write(^B^O+Cfg.BarChar[1]+' '^P'Next  Kill  Reply  Again  Jump  List  Fwrd  Copy  Quit '^O+Cfg.BarChar[2]);
      If NewOnly
        Then Write(^R' ('^S'Scanning New Mail'^R')')
        Else Write(^R' ('^S'Scanning All Mail'^R')');
      PlaceBar(True);
      Repeat
        K := Upcase(ArrowKey(True));
        Case K Of
         ^A,^D,'8','4':
            Begin
              Nobreak:=True;
              PlaceBar(False);
              Dec(x);
              If X < 1
                Then X := 9;
              PlaceBar(True);
              NoBreak := False;
             End;
         #32,^B,^C,'6','2':
             Begin
               NoBreak:=True;
               PlaceBar(False);
               Inc(x);
               If X > 9
                 Then X := 1;
               PlaceBar(True);
               NoBreak:=False;
              End;
         'K','N','R','A','J','L','F','C','Q','+' :
              Begin
                Done:=True;
                Inpt := K;
              End;
         #13 : Begin
               Inpt := Return[X];
               Done := True;
             End;
         End;
      Until (HungUpOn) Or (Done);
      Writeln(^S);
    End;

  Var Done : Boolean;
      TotalRead : Byte;
  Begin
    Lastread := 0;
    Done := False;
    TotalRead := 0;
    Repeat
      Inc(LastRead);
      If LastRead > Incoming^.NumMail
      Then Begin
        LastRead := 0;
        If (NewOnly) And (TotalRead < 1)
          Then Writeln(^M^S + 'No new mail found!');
        Exit
      End;
      If (NewOnly = False) Or ( (NewOnly) And (Incoming^.Mail[LastRead].Read = False) )
      Then Begin
        Inc(TotalRead);
        X := 1;
        ReadIncoming (Lastread);
        Repeat
          GetInput;
          If Inpt = ''
            Then Inpt := 'N';
          Case Upcase(Inpt[1]) Of
            'R' : AutoReply;
            'A' : ReadIncoming(LastRead);
            'K' : Begin
                    Writeln(^S^R);
                    DeleteMail(Incoming^,LastRead);
                    Dec(LastRead);
                    Inpt := 'N';
                  End;
            'J' : Begin
                    Writeln(^R^S);
                    Write(^R'Mail # to Jump to ');
                    WriteStr('('^A'1-'+Strr(Incoming^.NumMail)+^R') : *');
                    If (Valu(Inpt)>0) And (Valu(Inpt) <= Incoming^.NumMail)
                      Then LastRead := Valu(Inpt) - 1;
                    Inpt := 'N';
                  End;
            'L' : ListAllMail(False);
            'F' : ForwardMail;
            'C' : CopyMail;
            '+' : Write_To_File;
            'Q' : Done := True;
          End;

          If Incoming^.NumMail < 1
            Then Exit;

        Until (Match(Inpt,'N')) or (Done) or hungupon;
        If Done
          Then Exit;
      End
    Until hungupon;
  End;

    function sysopreadnum (var n:integer):boolean;
    var m:mailrec;
        k:char;
        done:boolean;

      procedure showit;
      begin
        MailHeader(M,n);
        printtext ('EMAIL.TXT','EMAIL.MAP',m.line);
      end;

      procedure changen (m:integer);
      var r2:integer;
      begin
        r2:=filesize(mfile)-1;
        if (m<1) or (m>r2) then begin
          writestr ('Continue scan at [1-'+strr(r2)+']: &');
          m:=valu(inpt)
        end;
        if (m>=1) and (m<=r2) then begin
          n:=m-1;
          done:=true
        end
      end;

    begin
      sysopreadnum:=false;
      seek (mfile,n);
      nread (mfile,m);
      showit;
      repeat
        done:=false;
        WriteStr(^R'SysOp Mail Scan ('^S'?/Help'^R') : &');
        If Inpt = '' Then Done := True Else
        If Inpt = '?' Then Begin
          Writeln('<CR> Next Mail');
          Writeln('Q - Quit Scanning   S - Send Mail to User');
          Writeln('E - Edit User       R - Edit User Sent To');
          Writeln('D - Delete Mail     A - Show Again');
        End Else
        If Valu(Inpt) > 0 Then ChangeN(Valu(Inpt))
        Else Case Upcase(Inpt[1]) Of
          'Q' : sysopreadnum:=true;
          'S' : sendmail;
          'E' : edituser(lookupuser(m.sentby));
          'R' : edituser(m.sentto);
          'D' : delmail(n);
          'Q' : done:=true;
          'A' : showit;
        End;
      until done or hungupon
    end;

    procedure someoneelse;
    var t,last:integer;
    begin
      writestr (^M^R'User name to look at'^A': &');
      if (length(inpt)=0) or hungupon then exit;
      writeln;
      t:=lookupuser (inpt);
      if t=0 then begin
        writeln ('No such user!');
        exit
      end;
      writelog (14,1,inpt);
      writehdr ('Looking in mailbox...');
      last:=searchmail(0,t);
      if last=0 then writeln ('No mail.');
      while last<>0 do begin
        seek (mfile,last);
        nread (mfile,m);
        if sysopreadnum (last) or hungupon then exit;
        last:=searchmail(last,t)
      end;
      writeln (^B^M'No more mail!')
    end;

    procedure scanall;
    var r1,r2:integer;
        u:userrec;
        n:mstr;
    begin
      r2:=filesize(mfile)-1;
      writestr (^R'Start scanning at ['^S'1-'+strr(r2)+^R']: &');
      if length(inpt)=0 then r1:=1 else r1:=valu(inpt);
      if (r1<1) or (r1>r2) then exit;
      writelog (14,2,'');
      while r1<filesize(mfile) do begin
        seek (mfile,r1);
        nread (mfile,m);
        if m.sentto<>0 then
          if sysopreadnum (r1) then exit;
        r1:=r1+1
      end;
      writeln (^B^M'No more mail!')
    end;

    procedure deleterange;
    var first,last,num,cnt:integer;
    begin
      writehdr ('Mass Mail Delete');
      parserange (filesize(mfile)-1,first,last,'Mass Delete Range');
      if first=0 then exit;
      num:=last-first;
      if num<>1 then begin
        writeln ('Warning! ',num,' pieces of mail will be deleted!');
        writestr ('Are you sure? !');
        if not yes then exit
      end;
      for cnt:=last downto first do begin
        delmail (cnt);
        write (cnt,' ');
        if break then begin
          writeln (^B^M'Aborted!');
          exit
        end
      end;
      writeln
    end;

  Procedure announcement;

    procedure delannouncement;
    begin
      if urec.emailannounce=-1 then begin
        writeln (^M'You don''t have an announcement compadre!');
        exit
      end;
      deletetext ('ANNOUNCE.TXT','ANNOUNCE.MAP',urec.emailannounce);
      urec.emailannounce := -1;
      writeurec;
      writeln (^M'Deleted.')
    end;

    Procedure CreateAnnouncement;
    Var Me : Message;
        Temp : Longint;
    Begin
      If Urec.EmailAnnounce >= 0
        Then DeleteText ('ANNOUNCE.TXT','ANNOUNCE.MAP',urec.emailannounce);
      Writeln(^M+'Creating Email Announcement');
      Me.Add_AutoSig := True;
      Temp := Editor (Me,False,False,'0','0','ANNOUNCE.TXT','ANNOUNCE.MAP');
      Urec.EmailAnnounce := Temp;
      Writeurec
    end;

  var k:char;
  begin
    if urec.emailannounce>=0
      then showannouncement (unum)
      else writeln ('You don''t have an announcement right now.');
    WriteStr(Strng^.Announce_Prompt);
    if length(inpt)=0 then exit;
    k:=upcase(inpt[1]);
    case k of
      'D':delannouncement;
      'C':createannouncement
    end
  end;

begin
  incoming := nil;
  outgoing := nil;
end.

(*

var q:integer;
begin
  cursection:=emailsysop;
  Quoting.AllowQuote := False;
  Quoting.MsgSec := False;
  opengfile;
  readcatalogs;
  WriteHdr('Electronic Mail');
  ListAllMail(False);
  If Exist(Cfg.TextFileDir+'MAILNEWS.BBS')
    Then Printfile(Cfg.TextFileDir+'MAILNEWS.BBS');
  lastread:=0;
  Repeat
    WriteCurMsg;
    If Cfg.UseRumors > 1
      Then RandomRumor;
    q:=menu (Cfg.MailMenuStr,'EMAIL','QRSLN_%@DKAV#E@CFHGI@Z+');
    if q<0
      then readnum (abs(q))
      else case q of
        2:autoreply;
        3:sendmail;
        4:listallmail(True);
        5:MailRead(True); {newmail;}
        6:MailRead(False); {nextmail;}
        7:sysopmail;
        8:deleteincoming;
        9:killoutgoing;
        10:announcement;
        11:viewoutgoing;
        13:editmailuser;
        14:copymail;
        15:forwardmail;
        16:; { help ('EMAIL.HLP'); }
        17:groupediting;
        18:showinfos;
        19:zippymail;
        20:write_to_file
      end
  until hungupon or (q=1);
  QueryDelete(InComing);
  close (gfile)
end;

*)