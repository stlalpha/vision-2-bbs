(*
  Procedure Batch_Upload;
  Var ud:udrec;
      kenny1,kenny2:anystr;
      Notify,ok,ymodem:Boolean;
      Zmodem:Lstr;
      Start_Time,b,proto,cnt,num,start,done:integer;
    Begin
      If (timetillevent<30) Then Begin
        writestr('Uploads are not allowed within 30 minutes of Timed Event!');
        exit
      End;
      If Not CheckFlags(urec.flags,area.upflag) then Begin
        Writeln('You cannot upload to this section!');
        Exit;
      End;
      ok:=False;
      if not enoughfree(area.xmodemdir) then exit;
      ymodem:=False;
      If tempsysop Then Begin
        ulvl:=regularlevel;
        tempsysop:=False;
        writeurec;
        bottomline
      End;
      clear_batchdown;
      cnt:=0;
      start_time := timeleft ;
      B:=BatchUpload(Proto);
      delay(1500);
      WriteLn(^B^M^R'Total Files received'^A': '^S+Strr(filesinbatch));
      If filesinbatch=0 Then exit;
      Start := NumUds + 1;
      Done := Start + FilesinBatch - 1;
      Inpt := 'N';
      WriteHdr('Adding Files To Database...');
      For cnt:=1 To filesinbatch Do Begin
        Zmodem:=batchdown[cnt].wholefilename;
        getpathname(Zmodem,ud.path,ud.filename);
        Num:=0;
        Ud.Descrip[0] := #0;
        Num := GetDescrip(UD.FileName);
        If Num > 0 Then UD.Descrip := Bu[Num].Descrip;
        Notify := False;
        kenny1:=ud.path;
        kenny2:=ud.filename;
        addzipcomment(kenny1+kenny2,kenny1,kenny2);
        writelog(15,2,ud.filename);
        Ud.Filename := UpString(Ud.Filename);
        ud.crash:=false;
        ud.path:=area.xmodemdir;
        ud.sentby:=unam;
        ud.when:=now;
        ud.whenrated:=now;
        ud.points:=0;
        ud.newfile:=True;
        ud.specialfile:=False;
        ud.downloaded:=0;
        If Num>0 Then Begin
          Ud.Password:=Bu[Num].Password;
          Ud.SendTo:=Bu[Num].SendTo;
        End Else Begin
          ud.password:='';
          ud.sendto:='';
        End;
        ud.return := notify;
        getfsize(ud);
        AutoUploadGrant(Ud);
        addfile(ud);
        Inc(urec.uploads);
        inc(status.newuploads);
        inc(status.totalfiles);
      End;
      For Cnt := Start To Done Do Begin
      If Not HungUpOn Then Begin
        SeekUdFile(Cnt);
        nRead(UdFile,UD);
        Num:=GetDescrip(UD.FileName);
        If Num>0 Then Ud.Descrip:=Bu[Num].Descrip Else
        If Not hungupon Then Begin
          nochain:=true;
          Write(^B^R'Description of '^A+UpString(Ud.filename)+^R': ');
          InputBox(39);
          ud.descrip:=inpt;
        End;
        If Not HungUpOn Then Begin
          DefYes := False;
          WriteStr(^R'Notify you when '^A+UpString(Ud.Filename)+^R' is downloaded? !');
          Ud.Return := Yes;
        End;
        SeekUDFile(Cnt);
        nWrite(UdFile,UD);
       End;
      End;
      Clear_Batchdown;
      WriteLn(^B^M'Thank you for Batch Uploading!');
    End;

      (*
        If (X>1) or (Inpt='+') Then Begin
          Batch_Upload;
          Exit;
        End;
      Ud.FileName:=Bu[1].FileName;
      Ud.Path:=Bu[1].Path;
      Ud.Descrip:=Bu[1].Descrip;
      Ud.Password:=Bu[1].Password;
      Ud.SendTo:=Bu[1].SendTo;
      proto:=protocaseselection(1);
      if proto=0 then exit;
      ansicls;
      bottomline;
      {Writehdr(Ud.filename+' Upload');}
      WriteLn(^S'Hitting Ctrl-X many times will abort!');
      If tempsysop Then Begin
        ulvl:=regularlevel;
        tempsysop:=False;
        writeurec;
        bottomline
      End;
      start_time := timeleft;
      clrscr;
      delay(1500);
      b:=protocolxfer(1,crcmode,ymodem,proto,fn);
      beepbeep(b);
      If b=0 Then Begin
        writelog(15,2,ud.filename);
        WriteStr('Notify you when '+UpString(UD.FileName)+' is downloaded? !');
        ud.crash:=false;
        ud.return:=yes;
        ud.sentby:=unam;
        ud.when:=now;
        ud.whenrated:=now;
        ud.points:=0;
        ud.downloaded:=0;
        ud.newfile:=True;
        ud.specialfile:=False;
        ud.downloaded:=0;
        ud.path:=area.xmodemdir;
        tmp1:=ud.path;
        tmp2:=ud.filename;
        addzipcomment(tmp1+tmp2,tmp1,tmp2);
          WriteLn('Thanks for the upload');
        getfsize(ud);
        AutoUploadGrant(Ud);
        If Not Continue then addfile(ud) Else Begin
          SeekUdFile(ic);
          nWrite(UdFile,Ud);
        End;
        inc(urec.uploads);
        inc(status.newuploads);
        inc(status.totalfiles);
        {Inc(Log.ULoads);}
        settimeleft(start_time+(((start_time-timeleft)*Cfg.timepercentback) div 100));
      End Else If B=-2 then Begin
        WriteLog(0,0,unam+' crashed while uploading and saved it');
        ud.crash:=true; ud.sentby:=unam; ud.return:=false; ud.when:=now;
        ud.downloaded:=0; ud.path:=area.xmodemdir; ud.newfile:=true;
        ud.points:=0; ud.specialfile:=false;
        AddFile(Ud);
      End;
    End;

    *)
(*

    Procedure Do_batch_download;
    Var zmodem:Char;
      proto,b:Integer;
      laterguy:boolean;
      loop:integer;

    Begin
    if filesinbatch<1 then exit;
      laterguy:=false;
      Repeat
      Write(^M^P'['^O'S'^P']tart Transfer ['^O'H'^P']ang-Up After Completed ['^O'Q'^P']uit ['^U'S'^P']'+B_(2));
      Buflen:=1;
      WriteStr('&');
      IF inpt='' then inpt:='S';
      If Upcase(inpt[1])='H' then laterguy:=true;
      If Upcase(inpt[1])='Q' then Begin
        WriteStr(^M'Do you want to clear your batch que? !');
        If yes then clear_batchdown;
        Exit;
      End;
      Until Upcase(inpt[1]) in ['S','H','Q'];
      b:=0;
      B:=Batch_Download(Proto,filesinbatch,Batchdown);
      If b>0 Then Begin
         If (b>0) Then Begin
          Write(^M^R'You had '^S+Strr(urec.udpoints)+^R' ');
          If Ud.Points>1 then Writeln(Cfg.FilePoints) Else Writeln(Cfg.FilePoint);
          WriteLn(^B^R'Batch Xfer Total Cost: '^S,b);
          WriteLn;
          urec.udpoints:=urec.udpoints-b;
          Write(^B^R'You now have '^A+Strr(urec.udpoints)+^R' ');
          If Ud.Points>1 then Writeln(Cfg.FilePoints) Else Writeln(Cfg.FilePoint);
        End;
        Clear_BatchDown;
        writeurec;
      End;
      Clear_BatchDown;
      if laterguy then begin
         WriteHdr('Auto-Disconnection!');
         writeln(^M^P'Hit ['^O'SPACE'^P'] if you DO NOT want to disconnect...');
         Writeurec;
         Write(^U);
         For b:=10 Downto 1 Do Begin
           Delay(500);
           If Break then exit;
           Delay(500); Write(Strr(B)+'..');
           If break then exit;
         End;
         Writeln('Hasta!');
         hangup;
         disconnect;
      end;
    End;

Procedure DLoad(Autoselect:Integer;FILE_Override:Lstr;Point_Override:integer; Quite:Boolean);
VAR totaltime:sstr;
    B,timewhilebeing,proto,num,shit,First,L:integer;
    Mins:Real;
    fsize,joe:longint;
    ud:udrec;
    zmodem,fname:lstr;
    ymodem:Boolean;
    f:File;
BEGIN
if file_override='' then begin
      If Not CheckFlags(urec.flags,area.downflag) then Begin
        WriteLn(^S'You can''t download from this section!');
        Exit;
      End;
      If nofiles Then exit;
      If autoselect=0
      Then Begin
        Getfilenum('download',Quite,First,L);
        If First<1 Then Exit;
        If First=L Then Num:=First Else Begin
          For Num:=First to L Do Add_To_Batch(Num,'',0,True);
          Exit;
        End;
      End
      Else Num:=autoselect;
      If Num=0 Then exit;
      WriteLn;
      seekudfile(num);
      nRead(udfile,ud);
      if file_OverRide='' then if Not OkRatiosAnd(Ud,False) then Exit;
      end else ud.points:=ud.points;  { point_override; }
      If (Not sponsoron) And (ud.points>urec.udpoints) and (area.leech=false)
      Then Begin
        If Not Quite then Goxy(1,24);
        Write(^P'That file costs '^S+Strr(ud.points)+^P' ');
        If Ud.Points>1 then Write(Cfg.FilePoint) Else Write(Cfg.FilePoints);
        WriteStr(': *');
        exit
      End;
      If (File_override='') and Not AbleToDoAnything(Ud,False,num) then Exit;
      if file_override='' then fname:=getfname(ud.path,ud.filename) else
          fname:=file_override;
      If tempsysop Then Begin
        ulvl:=regularlevel;
        tempsysop:=False;
        writeurec;
        bottomline
      End;
      ymodem:=False;
      proto:=protocaseselection(2);
      if proto=0 then exit;
      Assign(f,fname);
      Reset(f);
      iocode:=IOResult;
      If iocode<>0 Then
        Begin
          fileerror('DOWNLOAD',fname);
          exit
        End;
      fsize:=FileSize(f);
      Close(f);
      totaltime:=minstr(fsize);
      mins:=realvalu(totaltime);
      If ((mins>timeleft) And (Not sponsoron)) Then Begin
        If Not Quite then Goxy(1,24);
        writestr(^S'Insufficient time for transfer! &');
        exit
      End;
      If (mins-5>timetillevent) Then Begin
        If Not Quite then goxy(1,24);
        writestr(^S'You may not transfer right before the event occurs. &');
        exit
      End;
      AnsiCls;
      bottomline;
      Writehdr('File Download');
      if file_override='' then Begin
        Header('Filename    Size    Cost    Estimated Time   Times Downloaded');
        Write(^S);
        Tab(UpString(Ud.Filename),13);
        Write(^P);
        Tab(Strlong(Ud.FileSize),8);
        Write(^A);
        Tab(Strr(Ud.Points),8);
        Write(^U);
        Tab(Streal(Mins)+' Minutes',17);
        Write(^O);
        Write(Strr(Ud.Downloaded));
      End;
      WriteLn(^M^M^S'Hit ['^A'Ctrl-X'^S'] many times to abort'^B);
      Delay(2500);   clrscr;
      timewhilebeing:=timeleft;
      b:=protocolxfer(2,False,ymodem,proto,fname);
      beepbeep(b);
      If (b=0) Or (b=1) Then Begin
        If Ud.Return then Notice(ud.sentby,Unam+' Downloaded '+UpString(Ud.Filename)+'...');
        writelog(15,1,fname);
        inc(urec.downloads);
        Inc(status.newdownloads);
        inc(Log.DLoads);
        if file_override='' then begin
          inc(ud.downloaded);
          seekudfile(num);
          nWrite(udfile,ud);
        end;
        delay(2000);
        if file_override='' then
        pointcom(ud.sentby,ud.points);
        nosound;
        if file_override='' then else ud.points:=Point_override;
        If (ud.points>0) and (not area.leech) Then Begin
          Write(^B^R'That file cost '^S+Strr(ud.points)+^R' ');
          If Ud.Points>1 then WriteLn(Cfg.FIlePoints) Else Writeln(Cfg.FilePoint);
        if sponsoron then
          Writeln(^B^S'No Charge for Sysop!');
       if not sponsoron then urec.udpoints:=urec.udpoints-ud.points;
          Write(^R'You now have '^A+Strr(urec.udpoints)+^R' ');
          If Ud.Points>1 then WriteLn(Cfg.FIlePoints) Else Writeln(Cfg.FilePoint);
        End;
        writeurec;
      End;
    End;

Procedure Download(Autoselect:Integer;FILE_Override:Lstr;Point_Override:integer; Quite:Boolean);
Begin
  If FilesInBatch>0 then Begin
    { WriteStr(Strng.DLBatch); }
    If Yes then Begin
      Do_Batch_Download;
      Exit;
     End Else Dload(AutoSelect,File_OverRide,Point_OverRide,Quite);
  End Else Dload(AutoSelect,File_OverRide,Point_OverRide,Quite);
End;

*)