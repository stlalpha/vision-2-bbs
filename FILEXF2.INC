(*  Procedure Zipfile;
    Var a:arearec;
      cnt,cn,start_area : integer ;
      bang:text;
      wang:lstr;
      u:udrec;
      color1,color2,color3,color4,color5,color6,color7:sstr;
      done,first:Boolean;
      T:Char;

    Procedure listfileb(n:Integer;extended:Boolean);
    Var ud:udrec;
        q:sstr;
        path, Filez:anystr; _Name:namestr; _Ext: Extstr;
        Sze:longint;
        Any:lstr;

        Procedure WriteTab(Str:Lstr; Len:Byte);
        Var X:Byte;
        Begin
          Write(Bang,Str);
          For Len:=Length(Str) to Len do Write(Bang,#32);
        End;

    Begin
      Seekudfile(n);
      Read(udfile,ud);
      any:=strr(n)+'.';
      write(Bang,Color6);
      WriteTab(Any,4);
      Write(Bang,Color4);
      FSplit(ud.filename,path,_name,_ext);
      path:=upcase(_name[1]);
      _name[1]:=path[1];
      WriteTab(_Name,8);
      WriteTab(_EXT,5);
      Write(Bang,Color3);
      if (ud.sendto='') then
      If ud.newfile
      Then Write(bang,' New   ')
      Else If ud.specialfile
        Then Write(bang,' Ask   ')
        Else If ud.points>0
          Then Write(bang,ud.points:4 , '   ')
          Else Write(bang,' Free  ')
        else if match(ud.sendto,urec.handle) then write(bang,' Take  ') else
        write(bang,' Priv  ');
         write(bang,Color7);
      Filez:=getfname(ud.path,ud.filename);
      If Not(exist(filez)) Then writetab('Offline',10) Else begin
       sze:=ud.filesize;
       if sze<1024 then
       writetab(Strr(sze)+'B',10) else begin
         any:=strlong(sze div 1024)+'K';
         Writetab(any,10);
       end;
      end;
      Write(Bang,Color2);
      WriteTab(ud.descrip,0);
      Writeln(Bang);
    End;

    Begin
      Writehdr('Complete File List');
      writestr (^M'Continue with File List Compiler? !');
      if not yes then exit;
      writestr(^M^P'Add color to the file listing? !');
      WriteHdr('Please wait...Compiling List...');
      Color1:=^M+^M;
      Color2:='';
      Color3:='';
      Color4:='';
      Color5:='';
      Color6:='';
      Color7:='';
      if yes then
      Begin
        Color1:=#27+'[0;1m'+^M+^M+#27+'[37m';
        Color2:=#27+'[36m';
        Color3:=#27+'[35m';
        Color4:=#27+'[34m';
        Color5:=#27+'[37m';
        Color6:=#27+'[33m';
        Color7:=#27+'[31m';
      End;
      assign (Bang,'FileList.Zip');
      if exist('FileList.zip') then erase(Bang);
      assign  (bang,'FileList.txt');
      if exist('FileList.Txt') then erase(bang);
      rewrite(bang);
      write(bang,Color1);
      writeln(bang,'ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ');
      write(bang,Color2+'Complete File Listing for the '+Color3+Cfg.LongName+Color2);
      writeLn(bang,' as of '+Color4+DateStr(Now)+Color2+' - '+Color4+TimeStr(Now));
      writeln(bang,Color5+'ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ');
      writeln(bang,^M);
          beenaborted:=False;
      start_area := curarea ;
      For cn:=1 To FileSize(afile) Do Begin
        seekafile(cn);
        Read(afile,a);
        If Allowed_in_Area(Cn,True,a) Then Begin
          setarea(cn,true);
      Begin
      done:=False;
      Repeat
        first:=False;
        beenaborted:=False;
        For cnt:=1 To FileSize(udfile) Do Begin
          seekudfile(cnt);
          Read(udfile,u);
           Begin
             If Not first Then Begin
               Writeln(bang);
               Writeln(Bang);
               WriteLn(bang,Color5+'ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ');
               writeLn(bang,Color6+' Current File Area: '+Color4+Area.Name);
               writeln(bang,Color5+'ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ'+^M);
               first:=True;
             End;
            listfileb(cnt,False);
           End;
           done:=True;
        End;
        If Not first Then done:=True;
      Until done;
    End;
     End;
      End ;
      textclose(bang);
      Writeln(^M^S'List Compilation done!'^<);
      writehdr(' Demon Tasker... Zipping File List ');
      exec (GetEnv('COMSPEC'),'/C PKZIP.EXE -ex FileList.zip FileList.txt > NUL');
      erase(bang);
      Repeat
       Buflen:=1;
       WriteStr(^R'File List; ['^A'D'^R']ownload, ['^A'A'^R']dd to Batch, a['^A'B'^R']ort:*');
      Until (Upcase(Inpt[1]) in ['D','A','B']) or (HungUpOn);
      Writeln;
      Case Upcase(Inpt[1]) Of
        'D':Download(0,'FILELIST.ZIP',0,False);
        'A':Add_To_Batch(0,Cfg.ViSiONDir+'FILELIST.ZIP',0,True);
      End;
    End;
    *)

    Procedure Listarchive(List:Boolean);
    Label Done;
    Var N,F,L,Rot:Integer;
        Ud:Udrec;
        FName:Lstr;
        T:Text;
        Temp:String;
    Begin
      If nofiles Then exit;
      GetFileNum('view',List,F,L);
      If F<1 Then Exit;
      For N:=F to L Do Begin
        If n=0 Then exit;
        seekudfile(n);
        Read(udfile,ud);
        If Not AbleToDoAnything(Ud,False,n) Then
        Exit;
        FName := GetFName(Ud.Path,UD.Filename);
        FName := UpString(FName);
        ViewArchive(Ud.Filename,Ud.Path);
      End;
      If Exist(Cfg.ExtractDir+'EXTRACT.ZIP') Then Begin
      Repeat
       Buflen:=1;
       WriteStr(^R'File Extraction; ['^A'D'^R']ownload, ['^A'A'^R']dd to Batch, a['^A'B'^R']ort:*');
      Until (Upcase(Inpt[1]) in ['D','A','B']) or (HungUpOn);
      Writeln;
      Case Upcase(Inpt[1]) Of
        { 'D':Download(0);,Cfg.ExtractDir+'EXTRACT.ZIP',0,False); }
        'A':Add_To_Batch(0,Cfg.extractDir+'EXTRACT.ZIP',0,True);
      End;
      End;
    End;
     (*

          ansicls;
          writeHdr('ViSiON/2 Archive Viewer');
          {write(^S'Archive Type: '^U);}
          if Pos ('.ZIP', fname)>0 then Begin
             Writeln(^R'('^A'One Moment;  Un-Zipping: '^S+UpString(Ud.FileName)+^R')');
             SwapVectors;
             Exec(GetEnv('COMSPEC'),'/C PKUNZIP.EXE -v -q '+Fname+' > '+Cfg.ViSiONDir+'ZIPFILE.LST');
             SwapVectors;
             If Exist(Cfg.ViSiONDir+'ZIPFILE.LST') Then Begin
               Assign(T,Cfg.ViSiONDir+'ZIPFILE.LST');
               Reset(T);
               Repeat
                 Readln(T,Temp);
               Until (Pos('Length  Method   Size',Temp)>0) or (Eof(T));
               If Eof(T) Then Begin
                 TextClose(T);
                 Writeln('No Files Found!');
                 Exit;
               End;
               Readln(T,Temp);
               Rot:=1;
               Writeln;
               WriteHdr('Viewing: '+UpString(Ud.Filename));
               Writeln(^R'  '^A'File Name '^R'  ³   '^A'File Size '^R'  ³   '^A'Zip Size '^R'  ³   '^A'Date '^R' ');
               While Not (Eof(T)) or (HungUpOn) Do Begin
                 Readln(T,Temp);
                 If Pos('------',Temp)>0 then Goto Done;
                 Write(^S'  ');
                 Tab(Copy(Temp,63,12),12); Write(^R'³  '^O);
                 Tab(Copy(Temp,1,7),13);   Write(^R'³  '^P);
                 Tab(Copy(Temp,17,7),12);  Write(^R'³  '^U);
                 Writeln(Copy(Temp,31,8));
               End;
               Done:
                 Textclose(T);
             End;
          End Else Begin
          if pos ('.ZIP',Fname)>0 then ZipView(FName) Else
          if pos ('.ARJ',fname)>0 then ARJView(Fname) else
       {   if pos ('.PAK',fname)>0 then PakView(fname) else
          if pos ('.ARC',fname)>0 then Arcview(fname) else
          if (pos ('.LZH',fname)>0) or (pos('.ICE',fname)>0)
            then lzhview(fname) else }
          writeln('Uknonwn Type!'^M^M);
          Writeln;
          HoldScreen;
        End;
   {  End;
    End; }

*)
    Procedure Typefile(list:Boolean);
    var n,f,l:integer;
        ud:udrec;
    Begin
      if nofiles then exit;
      getfilenum('type',list,f,l);
      If f<1 Then Exit;
      For N:=F to L Do Begin
        if n=0 then exit;
        Seekudfile(n);
        Read(udfile,ud);
        If AbleToDoAnything(Ud,False,n) then Begin;
          If Ud.SendTo<>'' then If Not Match(Ud.SendTo,Urec.Handle) Then Exit;
          Archive.TypeFile(ud.path+ud.filename);
          HoldScreen;
        End;
      End;
    End;
