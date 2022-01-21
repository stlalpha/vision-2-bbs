procedure load_protos;
var tp:protorec;
    ct:integer;
    ft:file of protorec;

    procedure LoadProt(AF:Boolean; Var TempPro:ArProtoRec; Var Num:Integer);
    Var C:Char;
    Begin
     Num:=0;
     Repeat
       Inc(Num);
       Read(Ft,Tp);
       TempPro[Num]:=Tp;
       Ct:=0;
     Until Eof(Ft);
     Close(Ft);
    End;

    Begin
    if exist(Cfg.DataDir+'PROT_R.DAT') then begin
      assign(ft,Cfg.DataDir+'PROT_R.Dat');
      reset(ft);
      loadprot(true,dproto,totalupro);
    End;
  if exist(Cfg.DataDir+'PROT_S.DAT') then begin
     assign(ft,Cfg.DataDir+'PROT_S.Dat');
     reset(ft);
     LoadProt(true,Uproto,totaldownpro);
  end;
  If Exist(Cfg.DataDir+'PROT_U.DAT') then Begin
    Assign(ft,Cfg.DataDir+'PROT_U.DAT');
    Reset(Ft);
    LoadProt(true,BatchUProto,batchu);
    End;
  If Exist(Cfg.DataDir+'PROT_D.DAT') Then Begin
    Assign(ft,Cfg.DataDir+'PROT_D.DAT');
    Reset(Ft);
    LoadProt(false,BatchDproto,batchd);
  End;
end;

function protocaseselection(send:byte):integer;
var a:mstr;
    i,total:integer;
    K:Char;
    exp:mstr;
    ffile:Sstr;
    E:Boolean;
begin
  Case Send Of
    1:Begin fFile:='PROT_S.'; Exp:='Upload'; total:=totalupro; End;
    2:Begin fFile:='PROT_R.'; Exp:='Download'; total:=totaldownpro; End;
    3:Begin fFile:='PROT_U.'; Exp:='Batch Upload'; total:=batchu; End;
    4:Begin fFile:='PROT_D.'; Exp:='Batch Download'; total:=batchd; End;
  End;
  If not exist(Cfg.DataDir+fFILE+'DAT') then Begin
   WriteStr(^M'Tell your SysOp to create a Protocol file first! &');
   Exit;
   End;
  ansicls;
  E:=Exist(Cfg.TextFileDir+FFIle+'ANS');
  If Not E
    Then Writehdr('ViSiON '+exp+' Protocols');
  i:=1;
  if total=0 then begin
    writeln(^M^R'No Protocols Exist!');
    exit;
  end;
  a:='';
  while i<=total do begin
    if send=1 then begin
      If Not E Then Begin
        write(^P'['^R+dproto[i].letter+^P'] '^S);
        Write(dproto[i].desc);
      End;
      a:=a+dproto[i].letter;
    end else if send=2 then begin
      If Not E Then Begin
        write(^P'['^R+uproto[i].letter+^P'] '^S);
        Write(uproto[i].desc);
      End;
      a:=a+uproto[i].letter;
    end else if send=4 then begin
      If Not E Then Begin
        Write(^P'['^R+BatchDProto[i].letter+^P'] '^S);
        Write(BatchDProto[i].desc);
      End;
      A:=A+BatchDProto[i].letter;
    end else if send=3 then Begin
      If Not E Then Begin
        Write(^P'['^R+BatchUProto[i].letter+^P'] '^S);
        Write(BatchUProto[i].desc);
      End;
      A:=A+BatchUProto[i].letter;
    End;
    writeln;
    inc(i);
  End;
  If Not E Then Begin
    write(^M^P'Protocol Selection ['^O'Q'^P']uits [');
    If pos(urec.defproto,A)>0 then Write(^A+urec.defproto+^P) Else Write(' ');
    Write(^P']'+B_(2));
    Buflen:=1;
    WriteStr('*');
  End Else InputFile(Cfg.TextFileDir+FFile+'ANS');
  If inpt='' then inpt:=Urec.defproto;
  if Upcase(inpt[1])='Q' then begin
     protocaseselection:=0;
     exit;
  end;
  K:=Upcase(Inpt[1]);
  If Not Pos(K,A) > 0
    Then Writeln(^M^M'Invalid Entry!');
  If pos(K,A) > 0
    Then urec.defproto:=K;
  protocaseselection:=pos(k,a);
end;

procedure pointcom(name:mstr;pts:integer);
var u:userrec;
    i:integer;
begin
  if (cfg.pointcommision<=0) or (Pts<=0) then exit;
  write(^M^R'Giving ',name,^S' ',pts,^R' ');
  If Pts>1 then Writeln(Cfg.FilePoints) Else Writeln(Cfg.FilePoint);
  i:=lookupuser(name);
  if i=0 then exit;
  seek(ufile,i);
  NRead(ufile,u);
  u.udpoints:=u.udpoints+pts;
  seek(ufile,i);
  NWrite(ufile,u);
  Notice(Name,'You received '+Strr(pts)+' '+Cfg.FilePoints+' via Point Commision..');
end;

Function protocolxfer(send:integer; crcmode,ymodem:Boolean;Protocol:Integer;fn:lstr):Integer;
   var TimeAtXfer:longint;

  Procedure Then_Charge;
    Var a,b,c,d,FN1,Sn:String[255];
      cnt,longerthen,junk:Integer;
      Trans:Char;
      CPS,ttt,CompleteBytes,Errors:sstr;
      num3,Num1,num2,Tr1,Tr2:longint;
      FF:Text;
      F2f:file of byte;
    Begin
      protocolxfer:=2;
      if not exist(Cfg.DszLog) then exit;
      protocolxfer:=0;
      delay(2000);
       HolDScreen;
       d:=Cfg.DszLog;
      Assign(ff,d);
      Reset(ff);
      If Not EoF(ff) Then Begin
        fn1:='';
        ReadLn(ff,c);
        Trans:=c[1];
        longerthen:=0;
        if c[9]<>' ' then longerthen:=1;
        CompleteBytes:=copy (c,3,6+longerthen);
        CPS:=copy (c,20+longerthen,4);
        if cps[1]=' ' then begin
        ttt:=copy(cps,2,3);
        cps:=ttt;
      end;
      Errors:=copy (c,29+longerthen,3);
      textclose(ff);
      Delete(c,1,50+longerthen);
      While (c[1]<>' ') Do Begin
        fn1:=fn1+c[1];Delete(c,1,1);End;While (c[1]=' ') Do Delete(c,1,1);
        sn:=c;
        tr1:=1;
        if connectbaud<>0 then tr1:=(connectbaud div 10);
        Tr2:=TimeAtXfer*tr1;
        trans:=UpCase(trans);
        protocolxfer:=0;
        If match('E',trans) Or match('L',trans) Then protocolxfer:=2;
        if protocol<>9 then begin
          assign (f2f,fn);
          if exist (fn) then begin
            reset(f2f);
            num2:=filesize(f2f);close(f2f); end else num2:=1;
            if num2=0 then num2:=1;
            while (length(CompleteBytes)>0) and (completebytes[1]=' ') do
              delete (completebytes,1,1);
            val(completebytes,num1,Junk);
            num1:=num1*100;
            if num1=0 then num1:=1;
            num3:=num1 div num2;
            if send=1 then begin
              Writeln (^R'Percent complete'^A': '^S,strlong(num3),'%');
              Writeln (^R'CPS Rate'^A': '^S+Cps);
              if num3=100 then protocolxfer:=0;
              if (num3>93) and (num3<100) or (match(trans,'Q')) then begin
                protocolxfer:=0;
                leechzmodem(fn1);
              end;
            end;
           end;
           val(completebytes,num1,Junk);
           If Send<3 then Begin
             If send=2 then adDszLog(cps,fn1,true,num1,unam) else
             If send=1 then adDszLog(cps,fn1,false,num1,unam);
             if send=2 then Begin
               urec.KDownToday:=urec.KDownToday+(Num1 Div 1024);
               urec.KDown:=urec.kDown+(num1 div 1024) End else
             if not match(trans,'E') or match(trans,'L') then
               urec.KUp:=urec.KUp+(num1 div 1024);
               writeurec;
        If Send=1 Then If match(trans,'E') Or match(Trans,'L') or Match(Trans,'Q') Then
          If exist(fn) Then Begin
            Writeln(^M^B^G);
            HoldScreen;
            Writeln(^B^R'Uh Oh.. Apparently your transfer is not complete'^M);
            WriteStr(^S'Do you want to save the partial file and complete it later? !');
            If Yes then ProtoColXfer:=-2 Else
            Begin
              Assign(Ff,fn);
              Erase(Ff);
            End;
          End;
      End;
     End;
    End;

  Procedure ExecDsz;
    Var a,b,tmnt,ttt:anystr;
      ff:File;
      X,Y,Z:longint;
      ct:byte;
      Tsc:String[150];
      bd,cb:mstr; C:Char;
      W : Word;

      Procedure MakeCommandLine(tp:AnyStr);
      Begin
        if baudrate=38400 then bd:='38400' else bd:=strr(baudrate);
        if connectbaud=38400 then cb:='38400' else cb:=strr(connectbaud);
        Ct:=0;
        While Ct<>Length(Tp) do
           Begin
             Inc(Ct);
             If Tp[Ct]<>'%' then Tsc:=Tsc+Tp[Ct]
             Else if Ct<Length(Tp) then
               Begin
                 Inc(Ct);
                 C:=Tp[Ct];
                 Case C of
                   '1':Tsc:=Tsc+Strr(Cfg.UseCoM);
                   '2':Tsc:=Tsc+bd;
                   '5':Tsc:=Tsc+cb;
                   '4':Tsc:=Tsc+Cfg.DszLog;
                   '3':Tsc:=Tsc+Fn;
                 End;
               End;
             End;
        End;

    Begin
      b:=Cfg.DszLog;
        Assign(ff,b);
        If exist(b) Then Erase(ff);
      x:=timepart(now);
      clrscr;
      textattr:=15;
      write(usr,urec.handle+' is ');
      bottomline;
      tsc[0]:=Chr(0);
      Case Send Of
       1:Begin
          Writeln(usr,'Uploading: '+fn);
          MakeCommandLine(DProto[protocol].commfmt);
          SwapVectors;
          {W:=ExecWithSwap}
          Exec(Dproto[protocol].progname+' ',tsc);
          SwapVectors;
         End;
       2:Begin
          Writeln(usr,'Downloading: '+fn);
          MakeCommandLine(UProto[protocol].commfmt);
          SwapVectors;
          {W:=ExecWithSwap}
          Exec(Uproto[protocol].progname+' ',tsc);
          SwapVectors;
         End;
       4:Begin
          Writeln(usr,'Batch Downloading: ');
          MakeCommandLine(BatchDProto[protocol].commfmt);
          SwapVectors;
          {W:=ExecWithSwap}
          Exec(BatchDProto[protocol].progname+' ',tsc);
          SwapVectors;
         End;
       3:Begin
         Writeln(usr,'Batch Uploading: ');
         MakeCommandline(BatchUProto[protocol].commfmt);
         SwapVectors;
         {W:=ExecWithSwap}
         Exec(BatchUProto[protocol].progname+' ',tsc);
         SwapVectors;
        End;
      End;
      {
        Fossil_Nuke_Output(Cfg.UseCom);
        Fossil_Nuke_Input(Cfg.UseCom);
      }

      y:=timepart(now);
      z:=y-x;
      if z<0 then z:=z+65535;
      TimeAtXfer:=z;
      AnsiCls;
      SetUpBottom;
      Bottomline;
      If Cfg.DefBaudRate > 4800
        Then SetParam(Cfg.UseCom,Cfg.DefBaudRate,False)
        Else SetParam(Cfg.UseCom,ConnectBaud,False);
    End;

  Begin
   protocolxfer:=2;
     starttimer(status.numminsxfer);
       execdsz;
        protocolxfer:=2;
        If Send < 3 then Then_Charge;
        stoptimer(status.numminsxfer);
       writestatus;
       { If HungUpOn Then DisConnect; }
    starttimer(status.numminsused);
    SetUpBottom;
    Bottomline;
  End;

Function batch_download(Protocol,AllTheFiles:Integer;batchdown:batchlist):Integer;
  Var Count:longint;

   Procedure findetcharge(The:lstr);
    Var cnt,oldn:Integer;
      ud:udrec;
      c:string[255];
    Begin
    urec.downloads:=urec.downloads+1;
      For cnt:=1 To AllTheFiles Do Begin
        c:=batchdown[cnt].wholefilename;
        if match(the,c) then begin
          pointcom(batchdown[cnt].by,batchdown[cnt].points);
          count:=count+batchdown[cnt].points;
          oldn:=curarea;
          setarea(batchdown[cnt].area,false);
          seek(udfile,batchdown[cnt].filenum-1);
          nread(udfile,ud);
          inc(ud.downloaded);
          seek(udfile,batchdown[cnt].filenum-1);
          nwrite(udfile,ud);
          If ud.return
           then Notice(Ud.Sentby,Unam+' Downloaded '+UpString(Ud.Filename)+'...');
          setarea(oldn,false);
        End Else
          If match(c,the) Then count:=count+batchdown[cnt].points;
      End;
    End;

  Procedure Then_Charge;
  VAR c,fn:String[255];
      cnt,longerthen,junk:Integer;
      cps,krad:sstr;
      Trans:Char;
      FF:Text;
      CompleteBytes,sn:longint;
    Begin
      batch_download:=0;
      If Not exist(Cfg.DszLog) Then exit;
      delay(2300);
      Assign(ff,Cfg.DszLog);
      Reset(ff);
      Repeat
        If Not EoF(ff) Then Begin
          fn:='';
          ReadLn(ff,c);
          longerthen:=0;
          Trans:=c[1];
          if c[9]<>' ' then longerthen:=1;
          krad:=copy (c,3,6+longerthen);
          cps:=copy(c,20+longerthen,4);
          while (length(krad)>0) and (krad[1]=' ') do delete (krad,1,1);
          val (Krad,completebytes,junk);
          Delete(c,1,50+longerthen);
          While (c[1]<>' ') Do Begin
            fn:=fn+c[1];
            Delete(c,1,1);
          End;
          While (c[1]=' ') Do Delete(c,1,1);
          sn:=completebytes;
          WriteLn(^R'Filename'^A': '^S+UpString(fn)+^R'  Bytes'^A': '^S+
                    +strlong(sn)+^R'  CPS'^A': '^S+Cps);
          trans:=UpCase(trans);
          Writelog (15,1,' Code:'+trans+' FN:'+fn);
          If match(trans,'Q') or match(trans,'R') Or match(TRans,'Z') Or match(Trans,'S') Then
          begin
            findetCharge(fn);
            addszlog(cps,fn,true,sn,unam);
            urec.kdown:=urec.kdown+(sn div 1024);
            urec.kdowntoday:=urec.kdowntoday+(sn div 1024);
            Inc(Status.NewDownloads);
            Inc(Log.DLoads);
          end;
        End;
      Until EoF(ff);
      textclose(ff);
      batch_download:=count;
    End;

  Procedure ExecDsz;
    Var a,b:anystr;
    tmnt:anystr;
      qq:File;
      cnt,p:Integer;
      ttt:lstr;
    Begin
     b:=Cfg.DszLog;
      Assign(qq,b);
      If exist(b) Then Erase(qq);
      p:=protocaseselection(4);
      If p=0 then exit;
      p:=protocolxfer(4,true,false,p,Cfg.ViSiONDir+'FILELIST.');
      GoToXY(1,23);
      WriteLn(Usr,^M^M^M);
    End;

  Procedure make_list;
    Var tf:Text;
      cnt,a:Integer;
      d,e:anystr;
    Begin
      d:=Cfg.ViSiONDiR+'FILELIST.';
      Assign(tf,d);
      Rewrite(tf);
      For cnt:=1 To AllTheFiles Do Begin
        d:=batchdown[cnt].wholefilename;
        WriteLn(tf,d);
      End;
      textclose(tf);
    End;

  Begin
{  starttimer(numminsxfer);}
    count:=0;
    batch_download:=0;
    make_list;
    execdsz;
    delay(1500);
    then_charge;
{    stoptimer(numminsxfer); }
    writestatus;
    starttimer(Status.numminsused);
  End;


function okudratio:boolean;
var x3:integer;
slarvdod:boolean;
begin
  okudratio:=false;
  slarvdod:=false;
  if urec.udfratio=0 then slarvdod:=true;
   x3:=ratio(urec.uploads,urec.downloads);
   if (issysop) or (ulvl>=cfg.exemptlevel) or (x3>=urec.udfratio) then slarvdod:=true;
  okudratio:=slarvdod;
end;

  Function getapath:lstr;
    Var q,r:Integer;
      f:File;
      b:Boolean;
      p:lstr;
    Begin
      getapath:=area.xmodemdir;
      If ulvl<cfg.sysoplevel Then exit;
      Repeat
        writestr('Upload path [CR for '+^S+area.xmodemdir+^P+']: &');
        If hungupon Then exit;
        If Length(inpt)=0 Then inpt:=area.xmodemdir;
        p:=inpt;
        If inpt[Length(p)]<>'\' Then p:=p+'\';
        b:=True;
        Assign(f,p+'CON');
        Reset(f);
        q:=IOResult;
        Close(f);
        r:=IOResult;
        If q<>0 Then Begin
          writestr('Path doesn''t exist!  Create it? !');
          b:=yes;
          If b Then Begin
            MkDir(Copy(p,1,Length(p)-1));
            q:=IOResult;
            b:=q=0;
            If b
            Then writeln('Directory created')
            Else writeln('Unable to create directory')
          End
        End
      Until b;
      getapath:=p
    End;

function okudk:boolean;
var x3:integer;
    slarvdod:boolean;
begin
  slarvdod:=false;
  okudk:=false;
  if urec.udkratio=0 then slarvdod:=false;
  x3:=ratio(urec.KUp,urec.KDown);
  if (x3>=urec.udkratio) or (ulvl>=cfg.exemptlevel) or (issysop) then slarvdod:=true;
  okudk:=slarvdod;
end;

  Function batchupload(Protocol:Integer):Integer;
  Var Count:longint;

    Procedure find_and_charge(The:lstr);
      Var cnt:Integer;
      Begin
        inc(filesinbatch);
        cnt:=filesinbatch;
        batchdown[cnt].wholefilename:=the;
        batchdown[cnt].points:=0;
        batchdown[cnt].mins:=0;
      End;

    Procedure Then_Charge;
    Var c,d,fn,sn:String[255];
        cnt,longerthen,junk:Integer;
        Trans:Char;
        FF,qq:Text;
        krad,cps:sstr;
        tpp:lstr;
        Completebytes:longint;
      Begin
        filesinbatch:=0;
        batchupload:=0;
        d:=Cfg.DszLog;
        If Not exist(d) Then exit;
        batchupload:=0;
        Assign(ff,d);
        Reset(ff);
        AnsiCls;
        WriteHdr('Logging Files');
        Repeat
          If Not EoF(ff) Then Begin
            fn:='';
            ReadLn(ff,c);
            Trans:=c[1];
            longerthen:=0;
            if c[9]<>' ' then longerthen:=1;
            cps:=copy(c,20+longerthen,4);
            krad:=copy(c,3,6+longerthen);
            while (length(krad)>0) and (krad[1]=' ')  do delete (krad,1,1);
            val (krad,completebytes,junk);
            Delete(c,1,50+longerthen);
            While (c[1]<>' ') Do Begin
	      if c[1]='/' then c[1]:='\';
              fn:=fn+c[1];
              Delete(c,1,1);
            End;
            While (c[1]=' ') Do Delete(c,1,1);
            sn:=c;
            WriteLn(^R'Filename'^A': '^S+UpString(fn)+
            +'  '^R'Size'^A': '^S+krad+'  '^R'CPS'^A': '^S+Cps);
            trans:=UpCase(trans);
            if (trans='Z') or (trans='R') or (Trans='S') then begin
              urec.kup:=urec.kup+(completebytes div 1024);
              addszlog(cps,fn,false,completebytes,unam);
              writeurec;
            end;
            Writelog(15,2,'Code:'+trans+' File:'+fn);
            If (trans='R') Or (TRans='Z') Or (Trans='S') Then find_and_Charge(fn) Else
              If exist(fn) Then Begin
                Assign(qq,fn);
                Erase(qq);
              End;
          End;
        Until EoF(ff);
        textclose(ff);
        batchupload:=1;
      End;

    Procedure ExecDsz;
      Var a,b:anystr;
        tmnt:anystr;
        qq:File;
        cnt:Integer;
        p:integer;
      Begin
        b:=Cfg.DszLog;
        Assign(qq,b);
        If exist(b) Then Erase(qq);
        p:=Protocaseselection(3);
        If P=0 Then Exit;
        b:=area.xmodemdir;
        cnt:=Length(b);Delete(b,cnt,1);
        if protocol=5 then a:=a+'\';
        {starttimer(numminsxfer);}
    clrscr;
    ansicolor(15);
    bottomline;
     p:=ProtoColXfer(3,true,false,p,b);
        {stoptimer(numminsxfer);}
        GoToXY(1,23);WriteLn(Usr,^M^M^M);
      End;
    Begin
      count:=0;
      filesinbatch:=0;
      execdsz;
      batchupload:=0;
      Then_Charge;
    End;

  Procedure beepbeep(ok:Integer);
    Begin
      Delay(500);
      Write(^B^M);
      Case ok Of
        0:Write('Done');
        1:Write('Error Recovery');
        2:Write('Aborted')
      End;
      WriteLn('!'^M)
    End;

  Procedure seekafile(n:Integer);
    Begin
      Seek(afile,n-1)
    End;

  Function numareas:Integer;
    Begin
      numareas:=FileSize(afile)
    End;

  Procedure seekudfile(n:Integer);
    Begin
      Seek(udfile,n-1)
    End;

  Function numuds:Integer;
  Begin
    numuds:=FileSize(udfile)
  End;

  Procedure assignud;
  Var M:Mstr;
  Begin
    Close(udfile);
    m:=Cfg.DataDir+'AREA'+Strr(CurArea)+'.'+Strr(FileConf);
    Assign(udfile,m);
  End;

  Function sponsoron:Boolean;
  Begin
    Sponsoron:=match(area.sponsor,unam) Or issysop
  End;

  Function PCRatio:Boolean;
  var x3:integer;
      SlarvDodE:Boolean;
  Begin
   pcratio:=False;
   slarvdode:=False;
   If urec.pcr=0 Then slarvdode:=True;
   If slarvdode=True Then Else slarvdode:=False;
   x3:=ratio(urec.nbu,urec.numon);
   If (x3>=urec.pcr) Then slarvdode:=True else slarvdode:=false;
   If sponsoron Or (ulvl>=cfg.exemptlevel)
   Then
    slarvdode:=True;
    pcratio:=slarvdode;
  End;

procedure doheader;
VAR S:String[80];
 begin
  ansicls;
  S[0]:=#0;
  S:='#. ';
  With Urec Do Begin
   If FileList[1] then S:=S+'Name    ';
   If FileList[2] then S:=S+'Ext.   ';
   If FileList[3] then S:=S+'Cost    ';
   If FileList[4] then S:=S+'Size  ';
   If FileList[5] then S:=S+'Description                          ';
   If FileList[6] then S:=S+'Received ';
   If FileList[7] then S:=S+'DL''d ';
   If FileList[8] then S:=S+'Sent By        ';
  End;
  While Length(S) < 77 Do S:=S + #32;
  Sr.C[1] := 'CF';
  Sr.S[1] := S;
  ListingFile(Cfg.TextFileDir + 'FILETOP.ANS',True);
  {
    MultiColor(Strng.FileList1);
    Writeln;
    Sr.C[1] := 'CF';
    Sr.S[1] := S;
    MultiColor(Strng.FileList2);
  }
  If WhereY <> 3
    Then GoXy(1,3);
  nobreak:=false;
  dontstop:=false;
end;

procedure doextended;
begin
  ansicls;
  Header(' #.  Filename    Cost  U/L Date  X DLed   Sent By                  ');
  If WhereY<>3
    Then GoXy(1,3);
  nobreak:=false;
  dontstop:=false;
end;

Function Makearea:Boolean;
VAR num,n:Integer;
    a:arearec;
BEGIN
  Makearea:=False;
  num:=numareas+1;
  n:=numareas;
  writestr(^P'Create area '+^O+strr(num)+^P+'? !');
  If yes Then Begin
  write(^R'Area name'^A': ');
  InputBox(30);
  If Length(inpt)=0 Then exit;
  a.name:=inpt;
  write(^R'Access Flag(s)'^A': ');
  A.Flag[0] := #0;
  PromptFlag(A.Flag);
  write(^R'Access Level for area'^A': ');
  InputBox(6);
  a.level:=valu(inpt);
  writestr(^R'Upload Here'^O'? !');
  if inpt='' then inpt:='Y';
  a.uploads:=yes;
  A.UpFlag[0] := #0;
  If a.uploads Then Begin
    Write(^R'Area Upload Flag(s)'^A': ');
    PromptFlag(A.UpFlag);
  End;
  writestr(^R'Download here'^O'? !');
  a.downloads:=yes;
  A.DownFlag[0] := #0;
  If A.downloads then Begin
    Write(^R'Area Download Flag'^A': ');
    Promptflag(A.DownFlag);
  End;
  write(^R'Entry Password '^P'['^S'CR'^P']/None '^A': ');
  InputBox(20);
  if inpt='N' then inpt:='';
  If Length(inpt)=0 Then inpt:='' else inpt:=upstring(inpt);
  a.password:=inpt;
  write(^P'Moderator of this area '^O'['+^S+unam+^O+']'^A': ');
  InputBox(30);
  If Length(inpt)=0 Then inpt:=unam;
  a.sponsor:=inpt;
  DefYes:=False;
  WriteStr(^P'Leech Area? ('^O'Yes=All files free'^P') !');
  a.leech:=yes;
  a.xmodemdir:=getapath;
  seekafile(num);
  nWrite(afile,a);
  area:=a;
  curarea:=num;
  assignud;
  Rewrite(udfile);
  WriteLn('Area created');
  makearea:=True;
  writelog(15,4,a.name)
  End
End;

  Function allowed_in_area(N:Byte; CheckPW:Boolean; Where:Arearec):Boolean;
  Var c:Boolean;
  Begin
    C:=False;
    If (where.level<=urec.udlevel) Then
      C:=True;
    C:=CheckFlags(Urec.Flags,Where.Flag);
    if C Then Begin
     if (Where.password<>'') and (Not (N in EnterPW)) and (CheckPW) then begin
       Password('Entering File Area #'+strr(N)+' PW: '+Where.Password+' > ');
       WriteStr(^M^R'Area ['^A+Strr(N)+^R'] Password'^A': *');
       CloseWindow;
       Bottom;
       if match (Where.password,inpt) then EnterPw:=EnterPW+[N]
        Else C:=False;
     end;
   End;
    Allowed_In_Area:=c;
  End;

  Procedure setarea(n:Integer; Showit:boolean);
  Var C : Boolean;
      Temp : Byte;

    Procedure nosucharea;
    Begin
      WriteLn(^B^P'Invalid Area'^O': '^S+Strr(N))
    End;

    Begin
      curarea:=n;
      If (n>numareas) Or (n<1) Then Begin
        nosucharea;
        If issysop
        Then If makearea
          Then setarea(curarea,true)
          Else  setarea(1,true)
        Else setarea(1,true);
      End;
      seekafile(n);
      nRead(afile,area);
      If Not(allowed_in_area(N,True,Area))
      Then If curarea=1
        Then error('User can''t access first area','','')
        Else
          Begin
            nosucharea;
            setarea(1,true);
            exit
          End;
        close(udfile);
      assignud;
      Close(udfile);
      Reset(udfile);
      If IOResult<>0 Then Rewrite(udfile);
     If Showit then Begin
       Writeln;
       Sr.C[1]:='CA';
       Sr.S[1]:=Area.Name;
       MultiColor(Strng.CurfileArea);
       Writeln;
     End;
   End;

  Procedure ListAreas;
  Var A : Arearec;
      Cnt,OldArea,X : Integer;
      Total : Word;
  Begin

    OldArea := CurArea;
    Total := 0;

    ListingFile(Cfg.TextFileDir + 'FILEAREA.TOP',False);

    For cnt:=1 To numareas Do Begin
      SeekAFile(Cnt);
      nRead(Afile,A);
      If Allowed_In_Area(Cnt,False,A)
      Then begin
        CurArea := Cnt;
        Close(UDFIle);
        AssignUd;
        Reset(UDFile);

        Sr.C[1] := 'NU'; Sr.S[1] := Strr(Cnt); Sr.T[1] := 3;
        Sr.C[2] := 'AN'; If (A.Password<>'') and (Not (CurArea in EnterPW))
                           Then Sr.S[2] := '[ Password Protected ]'
                           Else Sr.S[2] := A.Name; Sr.T[2] := 30;
        Sr.C[3] := 'NF'; Sr.S[3] := Strr(NumUds); Sr.T[3] := 4;
        Sr.C[4] := 'UL'; Sr.S[4] := YesNo(A.Uploads); Sr.T[4] := 3;
        Sr.C[5] := 'DL'; Sr.S[5] := YesNo(A.Downloads); Sr.T[5] := 3;
        Sr.C[6] := 'NS'; If Cnt IN NScan.FileNewScan
                           Then Sr.S[6] := #32
                           Else Sr.S[6] := 'û'; Sr.T[6] := 1;

        ListingFile(Cfg.TextFileDir + 'FILEAREA.MID',False);
      End;

      Total := Total + NumUds;

      If Break Then Begin
        SetArea(OldArea,False);
        Exit;
      End;

    End;

    Sr.C[1] := 'TF'; Sr.S[1] := Strlong(Total); Sr.T[1] := 6;
    ListingFile(Cfg.TextFileDir + 'FILEAREA.BOT',False);

    SetArea(OldArea,False);
  End;

  Function getareanum:Integer;
    Var areastr:sstr;
      areanum:Integer;
    Begin
      getareanum:=0;
      If Length(inpt)>1
      Then areastr:=Copy(inpt,2,255)
      Else begin
      listareas;
        Repeat
          Writeln(^B);
          Writestr(Strng.ChangeFileAreaStr);
          Writeln;
          If Inpt='?'
            Then Listareas
            Else Areastr:=inpt
        Until (inpt<>'?') Or hungupon;
      end;
      If Length(areastr)=0 Then exit;
      areanum:=valu(areastr);
      If (areanum>0) And (areanum<=numareas)
      Then getareanum:=areanum
      Else Begin
        writeln('(No such area!)');
        If issysop Then If makearea Then getareanum:=numareas
      End
    End;

  Procedure getarea;
  Var AreaNum : Integer;
  Begin
    AreaNum := Getareanum;
    If AreaNum <> 0
      Then SetArea(AreaNum,True)
  End;

  Function GetFName(path:lstr;name:mstr):lstr;
  Var L : Lstr;
  Begin
    L := Path;
    If Length(l)<>0 Then
      If Not(l[Length(l)] In [':','\']) Then
    l := l + '\';
    l := l + name;
    GetFName:=l
  End;

  Procedure getpathname(fname:lstr;Var path:lstr;Var name:sstr);
  Var _Name: NameStr;
      _Ext : ExtStr ;
  Begin
    FSplit(fname,path,_name,_ext);
    name := _name + _ext ;
  End;

 Function CanDownload(Fsz:longint;pts:integer) : Boolean;
 Var t1,t2:longint;
     Dl:boolean;
  begin
  dl:=false;
  if issysop then candownload:=true;
  if issysop then exit;
  if connectbaud=0 then t1:=(2400*timeleft*6) else t1:=(connectbaud*timeleft*6);
  if (t1>=fsz) or (urec.udpoints>=pts)  then dl:=true;
  if (t1>=fsz) and area.leech then dl:=true;
  candownload:=dl;
  end;

  Procedure Listfile(n:Integer;extended:Boolean);
  Var UD : Udrec;
      Q : Sstr;
      Path,
      Filez : AnyStr;
      _Name : Namestr;
      _Ext : Extstr;
      Sze : Longint;
      Ofline : Boolean;
  Begin
    NoBreak:=True;
    Seekudfile(n);
    nRead(udfile,ud);

      Filez := GetFName(ud.path,ud.filename);

      FSplit(ud.filename,path,_name,_ext);

      Write(^R);

      Tab(strr(n),3);

      If Inbatch(Ud.FileName)
        Then Write('û')
        Else Write(' ');

      Path := Upcase(_name[1]);
      _Name[1] := Path[1];

      If Urec.FileList[1] or (Extended) Then Begin
        Write(^P);
        Tab(upstring(_Name),8);
      End;

      If Urec.Filelist[2] or (Extended) Then Begin
        Write(^O);
        Tab (upstring(_ext),6);
      End;

      If Urec.FileList[3] or (extended) Then Begin
        Write(^S);
        If (ud.sendto='') then
          If Ud.NewFile
            Then Write(' New   ')
            Else If Ud.Specialfile
              Then Write(' Ask   ')
              Else If (Ud.Points>0) and (Not Area.Leech)
                Then Write(ud.points:4 , '   ')
                Else Write(' Free  ')
        Else Begin
          Ansicolor(4);
          If Match(ud.sendto,urec.handle)
            Then Write(' Take  ')
            Else Write(' Priv  ');
        End
      End;

      If Urec.FileList[4] And Not (Extended) Then Begin
         Write(^A);
         If Ud.FileSize = -1
           Then Write('  ---- ')
           Else If Ud.Crash
             Then Begin
               Ansicolor(4);
               Write(' Crash ');
             End Else
           Begin
             Sze := Ud.filesize;
             If Sze < 1024
               Then Write(strr(sze)+'B':6,' ')
               Else Write(strlong(sze div 1024)+'K':6,' ');
           End
      End;

      If Urec.FileList[5] And Not (Extended) then Begin
        Write(^U);
        If UD.Descrip = ''
          Then UD.Descrip := '...';
        Tab(#32 + Ud.Descrip,39);
      End;

      If Urec.Filelist[6] or (Extended) then Begin
        Write(^P);
        Tab(DateStr(ud.when),10);
      End;

      If Urec.filelist[7] or (Extended) then Begin
        Write(^P);
        Tab(strlong(ud.downloaded),4);
      End;

      If Urec.FileList[8] or (Extended) then Begin
        Write(^A);
        Write(copy (ud.sentby,1,20));
      End;

     WriteLn;
     NoBreak:=False;
  End;

  Function NoFiles : Boolean;
  Begin
    If NumUDs = 0 Then Begin
      NoFiles:=True;
      Writeln(^M'Sorry, this area is empty!'^M)
    End Else Nofiles := False
  End;