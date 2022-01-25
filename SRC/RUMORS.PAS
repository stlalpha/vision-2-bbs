{$R-,S-,I-,D-,F+,V-,B-,N-,L+,O+ }
{$M 65500,0,0 }

unit rumors;

interface

     {Malice in Wonderland}
     {Hackers Key Party}

Procedure ThisDay;
Procedure Infoforms;
procedure listrumors;
procedure addrumor;
procedure deleterumor;
procedure rumorsnewscan;
procedure searchfortext;
Function Init_Rumors : Boolean;

implementation

uses crt,dos,MNeT,gentypes,configrt,modem,statret,
     gensubs,subs1,windows,mainr1,subsovr,overret1,subs2;

Procedure ThisDay;
Label Next;                             { <- how shitty of me }
Const Mons : Array[1..12] Of String[3] =
    ('Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec');
Var F : Text;
    OldB, B, S, D : Mstr;
    A, L : Lstr;
Begin

  D := TDateStr(Now);
  D := (Copy(D,1,2) + Copy(D,4,2));
  S := Copy(D,1,2);
  S := Mons[Valu(S)];

  If Exist(cfg.datadir+'TODAY.'+S) Then Begin
    Assign(F,cfg.datadir+'TODAY.'+S);
    Reset(F);
    OldB:='';

    ListingFile(Cfg.TextFileDir + 'BIRTHDAY.TOP',True);

    While Not Eof(F) Do Begin
      ReadLn(F,L);
      If Pos('Events',L)>0
        Then Goto Next;
      If Pos('B'+D,L)>0
      Then Begin
        A[0] := #0;
        A := Copy(L,10,69);
        If (A[1]<>'C') Then Begin
          Sr.C[1] := 'DA';
          B := Copy(L,6,4);
          If Valu(B) >= 0 then Begin
            OldB := B;
            Sr.S[1] := B;
          End
          Else Begin
            If OldB <> ''
              Then OldB := '    ';
            Sr.S[1] := OldB;
          End
        End Else Sr.S[1] := '    ';
        Sr.T[1] := 4;
        A[1]:=' ';
        Sr.C[2] := 'BD';
        Sr.S[2] := A;
        Sr.T[2] := 60;
        ListingFile(Cfg.TextFileDir + 'BIRTHDAY.MID',False);
      End;

    End;

    Next :

      If OldB = ''
        Then Writeln(^S'None Found!');
      ListingFile(Cfg.TextFileDir + 'BIRTHDAY.BOT',False);

    OldB := '    ';

    ListingFile(Cfg.TextFileDir + 'EVENTS.TOP',False);
      While Not Eof(F) Do Begin
        Readln(F,L);
        If pos('S'+D,L)>0 then Begin
          A := Copy(L,10,69);
          If A[1] <> 'C'
          Then Begin
            Sr.C[1] := 'DA';
            Sr.T[1] := 4;
            B := Copy(L,6,4);
            If Valu(B) >= 0 then Begin
              Oldb := B;
              Sr.S[1] := B;
            End Else Begin
              If OldB <> ''
                Then OldB := '    ';
              Sr.S[1] := OldB;
            End
          End Else Sr.S[1] := '    ';
          A[1] := #32;
          Sr.C[2] := 'EV';
          Sr.S[2] := A;
          Sr.T[2] := 60;
          ListingFile(Cfg.TextFileDir + 'EVENTS.MID',False);
        End;
      End;
    If OldB='' then Writeln(^S'None Found!'^M);
    ListingFile(Cfg.TextFileDir + 'EVENTS.BOT',False);
    TextClose(F);
  End;
  End;

  Procedure Infoforms;
  Label Start;
  Var I:Byte;
      K:Char;
      Done,Stay:Boolean;

      Function AllDone : Boolean;
      Var I : Byte;
      Begin
        Writeln;
        AllDone := True;
        For i:=1 to 5 Do Begin
          If Pos(Strr(i),Cfg.RequiredForms) > 0
          Then Begin
            If Exist(Cfg.TextFileDir+'INFOFORM.'+strr(i)) Then
            If Urec.Infoform[i] < 0
            Then Begin
              Writeln(^S'You still must complete Infoform #',i);
              Alldone:=False;
            End
          End
        End
      End;

      Procedure ShowForms;
      Var i:Byte;
          Head:Boolean;
      Begin
      Head:=True;
      AnsiCls;
      For I := 1 to 5 Do Begin
      If (Exist(cfg.textfiledir+'INFOFORM.'+strr(i))) and
         (Cfg.Infoformlvl[i] <= Urec.Level) Then Begin
        If Head Then
          ListingFile(Cfg.TextFileDir + 'FORMS.TOP',True);
        Head := False;
        Stay := True;

        Sr.C[1] := 'NU'; Sr.S[1] := Strr(I); Sr.T[1] := 1;
        Sr.C[2] := 'DE'; Sr.T[2] := 30;

        If Cfg.InfoformStr[i]<>''
          Then Sr.S[2] := Cfg.InfoformStr[i]
          Else Sr.S[2] := 'ú No Description ú';

        Sr.C[3] := 'RE'; Sr.T[3] := 8;

        If Pos(Strr(i),Cfg.RequiredForms) > 0
          Then Sr.S[3] := 'Required'
          Else Sr.S[3] := 'Optional';

        Sr.C[4] := 'ST'; Sr.T[4] := 11;
        If Urec.Infoform[i] > -1
          Then Sr.S[4] := 'Completed..'
          Else Sr.S[4] := 'Incomplete!';

        ListingFile(Cfg.TextFileDir + 'FORMS.MID',False);
      End
    End;
    ListingFile(Cfg.TExtFileDIr + 'FORMS.BOT',False);
  End;

  Begin
    AnsiCls;
    Start:
    Stay:=True;
    If Stay then Begin
      ShowForms;
      Repeat
        Buflen:=1;
        If Urec.Level > 1
          Then WriteStr(Strng^.InfoForm_Prompt)
          Else WriteStr(Strng^.NewInfoform_Prompt);
        If inpt='' then inpt:='Q';
        If (Upcase(inpt[1])='V') and (Urec.level > 1) then Begin
          Buflen := 1;
          WriteStr(Strng^.ViewWhichForm);
          i:=Valu(inpt);
          If (i in [1..5]) and (exist(cfg.textfiledir+'INFOFORM.'+Strr(i)))
          Then ShowInfoForms(Urec.Handle,i);
        End Else Begin
        i:=Valu(inpt);
        If i in [1..5] then Begin
          If (Exist(Cfg.TextFileDir+'INFOFORM.'+Strr(i))) and
             (Cfg.Infoformlvl[i]<=urec.level) Then Infoform(valu(inpt))
             Else Writeln(^M'Sorry, not a valid Infoform! ');
             HoldScreen;
          Goto Start; {ShowForms;}
        End;
        End;
        If Upcase(inpt[1])='?' then showforms;
        Until (AllDone) and (Upcase(inpt[1])='Q') or (hungupon);
      End;
  End;

  function numrumors:integer;
  begin
    numrumors:=filesize(rfile)
  end;

  procedure seekrfile (n:integer);
  begin
    seek (rfile,n-1)
  end;

  procedure openrfile;
  var n:integer;
  begin
    n:=ioresult;
    assign (rfile,Cfg.DataDir+'RUMORS.DAT');
    reset (rfile);
    if ioresult<>0 then begin
      close (rfile);
      n:=ioresult;
      rewrite (rfile)
    end
  end;

  procedure listrumors;
  var cnt:integer;
      b:boolean;
      n1,n2:integer;
      K:Char;
      r:rumorrec;
  begin
    writeln;
    ansireset;
    if numrumors<1 then begin
     writeln ('There are no Rumors!');
     exit;
    end;
    b:=true;
    seekrfile (1);
    writehdr ('Rumors List');
    Parserange (numrumors,n1,n2,'Rumors Listing');
    if n1=0 then exit;
    Repeat
      MultiColor(Strng^.Get_Rumor_List);
      K := WaitForChar(false);
      If K = #0
        Then K := 'R';
      Writeln(K);
    Until Upcase(K) in ['R','S','B','E'];
    K:=Upcase(K);
    If K='E' then Exit;
    Writeln;
     for cnt:=n1 to n2 do begin
        seekrfile(cnt);
        NRead (rfile,r);
        if b then begin
         If (k='S') or (K='B') then Header
         ('#   Title                         Date      Author             ')
         Else If k='R' then Header('#   Rumor                                                        ');
         b := false
        end;
        If (K='S') or (K='B') then Begin
        ansicolor (urec.color6);
        Tab(Strr(cnt),5);
        ansicolor (urec.color3);
        tab (r.title,30);
        ansicolor (urec.color6);
        tab (datestr(r.when),10);
        ansicolor (urec.color3);
        if r.author='...!@ANON#$...' then
        begin
         write (^R'('^U'Anonymous'^R')');
         if issysop then write (^R' ('^A,r.author2,^R')');
         IF (K='S') or (K='B') then writeln;
        end
        else writeln (^S,r.author);
        ansireset;
        if break then exit;
        ansicolor (urec.color1);
        End;
        If (K='R') or (K='B') then Begin
          If K='R' then
            Tab(^O+strr(cnt)+'. ',5) Else Tab('',3);
            AnsiColor(Urec.Color1);
          Subs1.MultiColor(r.rumor);
          Writeln;
        End;
    end;
    if b then writehdr (^R'There are no rumors. ('^S'A'^R')dd one!')
  end;

  function getrnum (txt:mstr):integer;
  var n:integer;
      r:rumorrec;
  begin
    getrnum:=0;
    repeat
      writeln;
      writestr ('Rumor Number to '+txt+' [?/List]? *');
      if length(inpt)=0 then exit;
      if upcase(inpt[1])='?'
        then listrumors
        else begin
          n:=valu(inpt);
          if (n<1) or (n>numrumors) then begin
            writeln (^M'Number out of range!');
            exit
          end;
          seekrfile (n);
          read (rfile,r);
          if (ulvl<r.level) and (not issysop) then exit;
          getrnum:=n;
          exit
        end
    until hungupon
  end;

procedure showrumor (n:integer);
var rr:rumorrec;
begin
   seekrfile (n);
   NRead (rfile,rr);
   if ulvl<rr.level then exit;
   writeln;
   write (^R+Cfg.RumChar[1]);
   Subs1.MultiColor(rr.rumor);
   writeln (^R+Cfg.RumChar[2]);
   ansireset;
end;

  procedure addrumor;
  var x,b:boolean;
      y,t:text;
      cdir,cddir:lstr;
      n:integer;
      z:anystr;
      apecks:rumorrec;

  function matchtitle (f:sstr):integer;
  var cnt:integer;
      monark:rumorrec;
  begin
    for cnt:=1 to numrumors do begin
      seekrfile (cnt);
      NRead (rfile,monark);
      if match (monark.title,f) then begin
        matchtitle:=cnt;
        ansireset;
        exit
      end
    end;
    matchtitle:=0
  end;

    begin
    if ulvl<2 then begin
     reqlevel (2);
     exit
    end;
    if numrumors>=999 then begin
     writeln;
     writeln ('Sorry, there are too many rumors now!');
     writeln ('Ask your Sysop to delete some.');
     exit
    end;
    ansireset;
    writehdr ('Adding a Rumor');
    MultiColor(Strng^.Get_Rumor_Title);
    InputBox(30);
    apecks.title:=inpt;
    if length(inpt)=0 then exit;
    if matchtitle(apecks.title)>0 then begin
     writeln;
     writeln ('Sorry, that rumor title already exists. Try another Title!');
     exit
    end;
    apecks.level:=1;
    apecks.author:=unam;
    apecks.author2:=unam;
    writeln;
    if ulvl>=Cfg.anonymouslevel then begin
     DefYes := False;
     WriteStr (Strng^.Add_Rumor_Anon);
     if yes then apecks.author:='...!@ANON#$...' else
     apecks.author:=unam;
    end;
    apecks.when:=now;
    ansireset;
    writeln;
    writestr (Strng^.Level_To_See_Rumor);
    if length(inpt)=0 then apecks.level:=1 else
    apecks.level:=valu(inpt);
    Writeln;
    WriteStr (Strng^.Enter_Your_Rumor);
    If Inpt = ''
      Then Exit;
    b:=true;
    apecks.rumor:=inpt;
    seekrfile (numrumors+1);
    nwrite (rfile,apecks);
    if b then Begin
      MultiColor(Strng^.Rumor_Added);
      Writelog(0,0,'Added Rumor #'+strr(numrumors+1));
      end;
    if not b then begin
    exit
    end;
  end;

  procedure deleterumor;
  var cnt,n:integer;
      f:file;
      r:rumorrec;
  begin
    n:=getrnum ('Delete');
    if n=0 then exit;
    seekrfile (n);
    nread (rfile,r);
    if not issysop then
    if not match(r.author2,unam) then
    begin
     writeln (^M'You didn''t post that!!'^M);
     exit
    end;
    writeln;
    Subs1.MultiColor(r.rumor);
    writeln;
    writestr ('Delete this Rumor !');
    if not yes then exit;
    for cnt:=n+1 to numrumors do begin
     seekrfile (cnt);
     nread (rfile,r);
     seekrfile (cnt-1);
     nwrite (rfile,r);
    end;
    seekrfile (numrumors);
    truncate (rfile);
    writelog (0,0,'Deleted Rumor "'+r.title+'"')
  end;

  Const BeenAborted : Boolean = False;

  function aborted:boolean;
  begin
    if beenaborted then begin
      aborted:=true;
      exit
    end;
    aborted:=xpressed or hungupon;
    if xpressed then begin
      beenaborted:=true;
      writeln (^B'Newscan aborted!')
    end
  end;

  procedure rumorsnewscan;
  var first,cnt:integer;
      nd:boolean;
      re:rumorrec;
  begin
    writehdr ('Rumors Newscan');
    if numrumors<1 then exit;
    for cnt:=1 to numrumors do begin
     seekrfile (cnt);
     nread (rfile,re);
     if (re.when>laston) and (ulvl>=re.level) then begin
      ansicolor (urec.color4);
      tab (strr(cnt)+'.',4);
      ansicolor (urec.color3);
      write  (re.title);
      ansicolor (urec.color1);
      write (' by ');
      ansicolor (urec.color4);
      if re.author='...!@ANON#$...' then
      write ('< Anonymous >') else write (re.author2);
      writeln;
      Subs1.MultiColor(Cfg.RumChar[1]+re.rumor+Cfg.RumChar[2]);
      Writeln;
     end;
    end;
  end;

  procedure searchfortext;
  var x:integer;
      mixmasterfag:boolean;
      s:anystr;
      rr:rumorrec;
  begin
   if numrumors<1 then begin
    writeln (^M'No Rumors Exist!'^M);
    exit;
   end;
   writehdr ('Search for Text in all Rumors');
   writeln ('Enter Text to search for:');
   write ('> ');
   InputBox(30);
   writeln;
   if length(inpt)=0 then exit;
   s:=inpt;
   s:=upstring(s);
   for x:=1 to numrumors do begin
    mixmasterfag:=false;
    seekrfile (x);
    NRead (rfile,rr);
    if pos(s,upstring(rr.title))>0 then mixmasterfag:=true;
    if pos(s,upstring(rr.rumor))>0 then mixmasterfag:=true;
    if pos(s,upstring(rr.author))>0 then mixmasterfag:=true;
    {if ((ulvl>=readanonlvl) and (pos(s,upstring(rr.author2))>0)) then mixmasterfag:=true;}
    if (mixmasterfag=true) and (ulvl>=rr.level) then begin
     ansicolor (urec.color4);
     tab (strr(x)+'.',4);
     ansicolor (urec.color3);
     write  (rr.title);
     ansicolor (urec.color1);
     write (' by ');
     ansicolor (urec.color4);
     if rr.author='...!@ANON#$...' then
     write ('<Anonymous>') else write (rr.author2);
     writeln;
     write ('  ');
     Subs1.MultiColor(rr.rumor);
    end;
   end;
  end;

  Function Init_Rumors : Boolean;
  Begin
    Init_Rumors := True;
    If IsOpen(RFile) Then Exit;
    OpenRFile;
  End;

begin
end.
