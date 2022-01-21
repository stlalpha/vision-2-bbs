{$R-,S-,I-,D-,F+,V-,B-,N-,L+,O+ }

Unit MessSys0;
                          {/ message sysop routines /}
Interface

Uses GenTypes;

procedure setnameaccess;
procedure setallaccess;
procedure listaccess;
procedure movebulletin;
Procedure Bul_To_Text;
Procedure EditBoard;
procedure killboard;
procedure orderboards;

Implementation

Uses Dos, MNET, ConfigRt, GenSubs, Windows, Subs1, Flags, Subs2,
     TextRET, MyComman, UserRET, Mainr2, Mess0, Mess1, Mess2, Mainr1;

  procedure switchboards (bnum1,bnum2:integer; var bo:boardorder);
  var bd1,bd2:boardrec;
      n1:integer;
  begin
    Seekbdfile (bnum1);
    NRead (bdfile,bd1);
    seekbdfile (bnum2);
    nread (bdfile,bd2);
    seekbdfile (bnum1);
    writebdfile (bd2);
    seekbdfile (bnum2);
    writebdfile (bd1);
    n1:=bo[bnum1];
    bo[bnum1]:=bo[bnum2];
    bo[bnum2]:=n1
  end;

    procedure getbgen (txt:mstr; var q);
    var s:lstr absolute q;
    begin
      writeln (^B^P'Current '+txt+^O': '^S+s);
      write (^P'Enter new '+txt+^O': ');
      InputBox(30);
      if length(inpt)>0 then s:=inpt
    end;

    procedure getbint (txt:mstr; var i:integer);
    var a:anystr;
    begin
      a:=strr(i);
      getbgen (txt,a);
      i:=valu(a);
      writecurboard
    end;

    procedure getbstr (txt:mstr; var q);
    begin
      getbgen (txt,q);
      writecurboard
    end;

    procedure setacc (ac:accesstype; un:integer);
    var u:userrec;
    begin
      seek (ufile,un);
      nread (ufile,u);
      setuseraccflag (nscan,curboardnum,ac);
      seek (ufile,un);
      nwrite (ufile,u)
    end;

    function queryacc (un:integer):accesstype;
    var u:userrec;
    begin
      seek (ufile,un);
      nread (ufile,u);
      queryacc:=getuseraccflag (nscan,curboardnum)
    end;

    procedure setnameaccess;
    var un,n:integer;
        ac:accesstype;
        q,unm:mstr;
    begin
      writestr (^M^P'Change access for user'^O': ');
      un:=lookupuser(inpt);
      if un=0 then begin
        writeln ('No such user!');
        exit
      end;
      unm:=inpt;
      ac:=queryacc(un);
      writeln (^B^M'Current access: ',accessstr[ac]);
      getacflag (ac,q);
      if ac=invalid then exit;
      if un=unum then writeurec;
      setacc (ac,un);
      if un=unum then readurec;
      case ac of
        letin:n:=1;
        keepout:n:=2;
        bylevel:n:=3
      end;
      writelog (5,n,unm)
    end;

    procedure setallaccess;
    var cnt:integer;
        ac:accesstype;
        q:mstr;
    begin
      writehdr ('Set Everyone''s Access');
      getacflag (ac,q);
      if ac=invalid then exit;
      writeurec;
      setallflags (curboardnum,ac);
      readurec;
      writeln ('Done.');
      writelog (5,4,accessstr[ac])
    end;


    procedure listaccess;

      procedure listacc (all:boolean);
      var cnt:integer;
          a:accesstype;
          u:userrec;

        procedure writeuser;
        begin
          if all
            then
              begin
                tab (u.handle,30);
                if a=bylevel
                  then writeln ('Level='+strr(u.level))
                  else writeln ('Let in')
              end
            else writeln (u.handle)
        end;

      begin
        seek (ufile,1);
        for cnt:=1 to numusers do begin
          nread (ufile,u);
          a:=getuseraccflag (nscan,curboardnum);
          case a of
            letin:writeuser;
            bylevel:if all and (u.level>=curboard.level) then writeuser
          end;
          if break then exit
        end
      end;

    begin
      writestr ('List A)ll users who have access, or only those with S)pecial access? *');
      if length(inpt)=0 then exit;
      case upcase(inpt[1]) of
        'A':listacc (true);
        'S':listacc (false)
      end
    end;

    procedure movebulletin;
    var b:bulrec;
        tcb:boardrec;
        tcbn,dbn,bnum:integer;
        tcbname,dbname:sstr;
        M:Message;
    begin
      writehdr ('Bulletin Move');
      getbnum ('Move');
      if not checkcurbul then exit;
      bnum:=curbul;
      seekbfile (bnum);
      nread (bfile,b);
      Repeat
        writestr (^P'Move "'^O+b.title+^P'" posted by '^O+b.leftby+^M^P+
         'Move to which sub-board? ['^O'?'^P']/Lists: *');
        if length(inpt)=0 then exit;
        if inpt='?' then listboards;
      Until inpt<>'?';
      tcbname:=curboardname;
      dbname:=inpt;
      dbn:=searchboard(dbname);
      if dbn=-1 then begin
        writeln ('No such board!');
        exit
      end;
      writeln ('Moving...');
      ReloadText(CurBFile1,CurBFile2,B.line,M);
      delbul (bnum,false);
      close (bfile);
      curboardname:=dbname;
      openbfile;
      B.Line:=MakeText(CurBFile1,CurBFile2,M,'');
      addbul (b);
      close (bfile);
      curboardname:=tcbname;
      openbfile;
      writelog (5,13,b.title);
      writeln (^B'Done!')
    end;

    Procedure Bul_To_Text;
    Var B  : BulRec;
        Num: Integer;
    Begin
      Writehdr ('Bulletin -2- Text File!');
      GetBNum ('Convert to text');
      if not checkcurbul then exit;
      Num := curbul;
      SeekBFile (Num);
      NRead (BFile,b);
      TextToFile(CurBFile1,CurBFile2,B.Line,B.Title,B.LeftBy,B.Sentto);
    End;

    Procedure EditBoard;
    Const NetType:Array[0..2] of String[8] = ('Local','V2_Net','FidoNet');
    VAR K:Char;
        Done:Boolean;
        New,Old:Mstr;
        nfp,nbf:lstr;
        qf:file; d:Integer;

        Procedure SetUpScreen;
        Begin
          AnsiCls;
          Header('Sub Board Editing...');
          Writeln(^P'Change Which? [ ]'^M);
          With Curboard Do Begin
           Writeln(^O'['^P'A'^O'] Board Number....: '^S+Shortname);
           Writeln(^O'['^P'B'^O'] Board Name......: '^S+Boardname);
           Writeln(^O'['^P'C'^O'] Area Flag(s)....: '^S+AreaFlags);
           Writeln(^O'['^P'D'^O'] Area Sponsor....: '^S+Sponsor);
           Writeln(^O'['^P'E'^O'] Area Level......: '^S+Strr(Level));
           Writeln(^O'['^P'F'^O'] Post Level......: '^S+Strr(PLevel));
           Writeln(^O'['^P'G'^O'] Post Flags......: '^S+PostFlags);
           Writeln(^O'['^P'H'^O'] Auto-Delete.....: '^S+Strr(AutoDel));
           Writeln(^O'['^P'I'^O'] NET Type........: '^S+NetType[EchoType] + '(' + Strr(EchoType) + ')');
           Writeln(^O'['^P'J'^O'] NET ID Number...: '^S+Strr(Echo));
           Writeln(^O'['^P'K'^O'] Fido-Address....: '^S+Address);
           WRiteln(^O'['^P'L'^O'] Fido-Directory..: '^S+Fido_Dir);
           Writeln(^O'['^P'M'^O'] Fido-OriginLine.: '^S+OriginLine);
           Writeln(^O'['^P'N'^O'] Net Name........: '^S+NetName);
          End
         End;

         Procedure GetS(T,L,X,Y:Byte; VAR S);
         VAR St:Mstr Absolute S;
             Ls:Lstr Absolute S;
             Int:Integer Absolute S;
             Str:Mstr;
         BEGIN
           Case T Of
            1:Str:=St;
            2:Str:=Strr(Int);
            3:Str:=Ls;
           End;
           Goxy(X,Y);
           InputBox(L);
           If inpt>'' then Begin
             Case T Of
              1:St:=inpt;
              2:Int:=Valu(inpt);
              3:Ls:=Inpt;
             End;
        {     Case Y Of
              6:Writelog(5,5,CurBoard.BoardName);
              7:Writelog(0,0,'Changed Board Access Flags');
              8:Writelog(5,8,inpt);
              9:Writelog(5,12,inpt);
             10:Writelog(0,0,'Changed Post Level '+inpt);
             11:Writelog(0,0,'Changed Post Flags');
             12:Writelog(5,11,inpt);
            End;
            }
           End;
           Goxy(X,Y);
           Write(^S+#27+'[K');
           Case T Of
             1:If inpt>'' then Write(St) Else Write(Str);
             2:If inpt>'' then Write(Strr(Int)) Else Write(Str);
             3:If Inpt>'' Then Write(Ls) Else Write(Str);
           End;
        END;

    Begin
     SetUpScreen;
     Done:=False;
     Writelog(0,0,'Area Editor: '+Curboard.BoardName);
     Repeat
       Goxy(16,3);
       K:=WaitForChar(False);
       Case Upcase(K) Of
       'A':Begin
            Goxy(23,5);
            NoCRInput(CurBoard.ShortName,10);
            If inpt>'' then Begin
              New:=inpt;
              Old:=CurBoard.ShortName;
              If Not ValidBName(New) Then Begin
               Printxy(23,5,^R'Invalid Board Name!');
               WriteStr('&');
              End Else If BoardExist(New) Then Begin
               Printxy(23,5,^R'Hey! That board name already exists!');
               WriteStr('&');
              End Else Begin
               Goxy(1,15);
               WriteHdr('Resetting..');
               curboard.shortname:=new;
               writecurboard;
               nfp:=Cfg.boarddir+new+'.'+Strr(MsgConf);
               assign (qf,nfp);
               {erase (qf);}
               d:=ioresult;
               rename (bfile,nfp);
               Close(BFile);
{               nfp:=Cfg.TextDir+OLD+'.'+Strr(MsgConf)+'X';
               assign(QF,nfp);
               ReName(QF,Cfg.textDir+NEW+'.'+Strr(MsgConf)+'X');
               ASsign(QF,Cfg.TextDir+OLD+'.'+Strr(MsgConf)+'T') }
               Setfirstboard;
               q:=9;
               EXiT;
             end
           End;
           Printxy(23,5,#27+'[K'^S+Curboard.Shortname);
           End;
       'B':GetS(1,30,23,6,CurBoard.BoardName);
       'C':Begin
             Goxy(23,7);
             PromptFlag(CurBoard.AreaFlags);
             Goxy(23,7);
             Write(#27+'[K'^S+CurBoard.AreaFlags);
           End;
       'D':GetS(1,30,23,8,CurBoard.Sponsor);
       'E':GetS(2,7,23,9,CurBoard.Level);
       'F':GetS(2,7,23,10,Curboard.PLevel);
       'G':Begin
             Goxy(23,11);
             PromptFlag(Curboard.PostFlags);
             Goxy(23,11);
             Write(#27+'[K'^S+Curboard.PostFlags);
          End;
       'H':Begin
             GetS(2,5,23,12,CurBoard.AutoDel);
             If CurBoard.AutoDel<10 then Begin
               CurBoard.AutoDel:=10;
               Printxy(23,12,'10  ');
             End;
            {If Curboard.autodel<=numbuls then
             Begin
               Printxy(23,12,'Deleting bulletins...');
               While NumBuls > CurBoard.Autodel Do DelBul (2,true);
               Printxy(23,12,#27+'[K'^S+Strr(CurBoard.AutoDel));
             End}
           End;
       'I':Begin
             Goxy(23,13);
             Inc(CurBoard.EchoType);
             If CurBoard.EchoType > 2
               Then CurBoard.EchoType := 0;
             If Curboard.EchoType = 0
               then CurBoard.UseNet := False
               Else CurBoard.UseNet := True;
             Write(#27+'[K'+NetType[CurBoard.Echotype]);
           End;
       'J':Begin
            Goxy(23,14);
            InputBox(4);
            If inpt>'' then CurBoard.Echo:=Valu(inpt);
            Printxy(23,14,^S+Strr(CurBoard.Echo)+'    ');
           End;
        'K':GetS(1,10,23,15,CurBoard.Address);
        'L':GetS(3,50,23,16,CurBoard.Fido_Dir);
        'M':GetS(3,50,23,17,CurBoard.OriginLine);
        'N':GetS(1,20,23,18,CurBoard.NetName);
       'Q':Done:=True;
     End;
     Until (Done) or HungUpOn;
     Goxy(1,20);
     WriteStr('Save this to disk? !');
     If Yes then WriteCurBoard Else SetFirstBoard;
   End;

    procedure killboard;
    var cnt:integer;
        f:file;
        fr:filerec;
        bd:boardrec;
    begin
      Writestr (^R'Kill Area ('^S+Curboard.BoardName+^R')? !');
      If Not
        Yes Then Exit;
      WriteLog (5,10,'');
      Write (^B^M^S'Deleting messages...');
      Close(MailFile);
      Close(TextFile);
      Assign(F,LastTextFile);
      Erase(F);
      Assign(F,LastMailFile);
      Erase(F);
      LastMailFile := 'WHOBEBO!';
      Writeln('Done!');
      Writeln (^B^M'Deleting Sub-board files...');
      close (bfile);
      assignbfile;
      erase (bfile);
      if ioresult<>0 then writeln (^B'Error erasing board file.');
      Writeln (^M'Removing sub-board...');
      Delboard (curboardnum);
      Writeln (^B'Sub-board erased!');
      Setfirstboard;
      q:=9
    end;
(*
    procedure sortboards;
    var cnt,mark,temp:integer;
        bd1,bd2:boardrec;
        bn1,bn2:sstr;
        bo:boardorder;
    begin
      writestr (^R'Sub-Board Sorting... Continue? !');
      if not yes then exit;
      clearorder (bo);
      mark:=filesize(bdfile)-1;
      repeat
        if mark<>0 then begin
          temp:=mark;
          mark:=0;
          for cnt:=0 to temp-1 do begin
            seek (bifile,cnt);
            nread (bifile,bn1);
            nread (bifile,bn2);
            if upstring(bn1)>upstring(bn2) then begin
              mark:=cnt;
              switchboards (cnt,cnt+1,bo)
            end
          end
        end
      until mark=0;
      carryout (bo);
      writelog (5,16,'');
      setfirstboard;
      q:=9
    end;
*)

    procedure orderboards;
    var numb,curb,newb:integer;
        bo:boardorder;
    label exit;
    begin
      clearorder (bo);
      writehdr ('Re-order sub-boards');
      numb:=filesize (bdfile);
      thereare (numb,'Sub-Board','Sub-Boards');
      for curb:=0 to numb-2 do begin
        repeat
          writestr (^P'New board #'+strr(curb+1)+' ['^O'?'^P']/List ['^O'CR'^P']/Quit '^R': &');
          if length(inpt)=0 then goto exit;
          if inpt='?'
            then
              begin
                listboards;
                newb:=-1
              end
            else
              begin
                newb:=searchboard(inpt);
                if newb<0 then writeln ('Not found!  Please re-enter...')
              end
        until (newb>=0);
        switchboards (curb,newb,bo)
      end;
      exit:
      carryout (bo);
      writelog (5,14,'');
      q:=9;
      setfirstboard
    end;

begin
end.