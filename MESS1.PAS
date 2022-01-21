{$R-,S-,I-,D-,F+,V-,B-,N-,L+,O+ }

Unit Mess1;
                          {/ low level message area routines /}
Interface

Uses GenTypes;

procedure delbul (bn:integer; deltext:boolean);
procedure delboard (bdn:integer);
procedure listbuls;
procedure getbnum (txt:mstr);
procedure killbul;
procedure editbul;

Implementation

Uses Dos, MNET, ConfigRT, GenSubs, statret, Mess0, Subs1, Subs2,
     UserRet, TextRet, Mainr2;

  procedure delbul (bn:integer; deltext:boolean);
  var c,un:integer;
      b:bulrec;
      u:userrec;
  begin
    if (bn<1) or (bn>numbuls) then exit;
    seekbfile (bn);
    nread (bfile,b);
    if deltext then deletetext (CurBFile1,CurBFile2,b.line);
    for c:=bn to numbuls-1 do begin
      seekbfile (c+1);
      nread (bfile,b);
      seekbfile (c);
      nwrite (bfile,b)
    end;
    seekbfile (numbuls);
    truncate (bfile);
    dec(Status.totalmsgs);
    getlastreadnum
  end;

  procedure delboard (bdn:integer);
  var bd1:boardrec;
      cnt,nbds:integer;
      bo:boardorder;
  begin
    clearorder (bo);
    nbds:=filesize(bdfile)-1;
    Status.totalmsgs:=Status.totalmsgs-nbds;
    if nbds=0 then begin
      close (bdfile);
      rewrite (bdfile);
      exit
    end;
    for cnt:=bdn to nbds-1 do begin
      seekbdfile (cnt+1);
      nread (bdfile,bd1);
      seekbdfile (cnt);
      writebdfile (bd1);
      bo[cnt]:=cnt+1
    end;
    seek (bdfile,nbds);
    truncate (bdfile);
    seek (bifile,nbds);
    truncate (bifile);
    carryout (bo)
  end;

  procedure listbuls;
  var max,r1,r2,cnt,bn:integer;
      q,onlyme:boolean;
      A : Char;
  begin
    If NumBuls<=0 then Begin
      Writeln(^S'Sorry, no titles to list'^M);
      Exit;
    End;
    if length(inpt) > 1 then begin
      curbul:=valu(copy(inpt,2,255));
      q:=checkcurbul
    end;
    Max := NumBuls;
    WriteStr(Strng^.Show_Title_Or_Range);
    If Upcase(Inpt[1]) = 'Q'
      Then Exit;
    If Upcase(Inpt[1]) = 'T' Then Begin
      R1 := CurBul + 1;
      If R1 > NumBuls
        Then R1 := 0;
      R2 := R1 + 10;
      If R2 > Max
        Then R2 := Max;
      If R1 < 1 Then Begin
        { Writeln(^R^G'No more titles to list!'); }
        MultiColor(Strng^.No_More_Titles_To_List);
        Writeln;
        Exit;
      End;
    End Else Begin
      ParseRange(max,r1,r2,'Title Listing');
      DefYes:=False;
      { WriteStr(^M'List Messages only directed to you? !'); }

      WriteStr(Strng^.List_Messages_For_You);

      OnlyMe := Yes;
    End;
    Writeln;
    if Not CheckCurbul
      Then curbul:=1;
    If r1=0 then exit;
    Header('#    Title                        Author                  Directed At   ');
    for cnt:=r1 to r2 do
      begin
        if (cnt>0) and (cnt<=numbuls) then
          begin
            seekbfile (cnt);
            nread (bfile,b);
            If (not onlyme) or ((onlyme) and (match(unam,b.sentto))) then Begin
            Tab(^P+strr(cnt)+^O':',8);
            Tab(^R+b.title,30);
            if b.anon
              then tab(^S+Cfg.anonymousstr,25)
              else tab(^S+b.leftby,25);
            Writeln(^U+b.sentto);
            if break then exit
          end
          end
      end;
      Writeln;
  end;

  procedure getbnum (txt:mstr);
  var q:boolean;
      I:Sstr;
  begin
    if length(inpt)>1
      then curbul:=valu(copy(inpt,2,255))
      else begin
        Repeat
          writestr (^M^R'Bulletin # to '^A+txt+^R'; ['^A'?'^R']/Lists: &');
          I:=Inpt;
          If I='?' then ListBuls;
        Until (I<>'?') or (HungUpOn);
        curbul:=valu(inpt)
      end;
    q:=checkcurbul
  end;

  procedure killbul;
  var un:integer;
      u:userrec;
      A:integer;
  begin
    A:=curbul;
    writehdr ('Bulletin Deletion');
    getbnum ('Delete');
    if not checkcurbul then Begin If A>1 then curbul:=a-1 else curbul:=1;exit;end;
    getbrec;
    if (not match(b.leftby,unam)) and (not issysop) and (not sponsoron)
      then begin
        writeln ('You didn''t post that!');
        exit
      end;
    writeln (^R'Title'^P'..'^O': '^R+b.title+
           ^M^R'Left by'^O': '^R+b.leftby+
           ^M^R'Sent to'^O': '^R+b.sentto+
           ^M^R'When'^P'...'^O': '^R+timestr(b.when)+^S' on '^R+datestr(b.when)+^M);
    writestr (^M'Delete this? !');
    if not yes then exit;
    A:=curbul;
    un:=lookupuser (b.leftby);
    if un<>0 then begin
      writeurec;
      seek (ufile,un);
      nread (ufile,u);
      u.nbu:=u.nbu-1;
      seek (ufile,un);
      nwrite (ufile,u);
      readurec
    end;
    delbul (curbul,true);
    writeln ('Bulletin deleted.');
    writelog (4,5,b.title);
    If A>1 then curbul:=a-1 else curbul:=1;
  end;

  procedure editbul;
  var me:message;
  begin
    getbnum ('Edit');
    if not checkcurbul then exit;
    getbrec;
    if (not match(b.leftby,unam)) and (not issysop) and (not sponsoron)
      then begin
        writeln ('You didn''t post that!'^G);
        exit
      end;
    reloadtext (CurBFile1,CurBFile2,b.line,me);
    me.title:=b.title;
    me.anon:=b.anon;
    me.sendto:=b.sentto;
    if reedit (me,true) then begin
      writelog (4,6,b.title);
      deletetext (CurBFile1,CurBFile2,b.line);
      Me.Add_AutoSig := True;
      b.line:=maketext (CurBFile1,CurBFile2,Me,'');
      if b.line<0 then begin
        writeln (^M'Deleting bulletin...');
        delbul (curbul,false)
      end else begin
        seekbfile (curbul);
        nwrite (bfile,b)
      end
    end
  end;

begin
end.