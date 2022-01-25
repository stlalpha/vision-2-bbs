{$V-,I-,B-,R-}
{$M 65000,1024,10024}

Program NewConfig;

Uses Dos, Crt, MDosIO, GenTypes, Configrt, General, Mnet, DispEdit, Video,
     Little;

{$R-,S+,I-,F-,V-,B-}

Var TopScreen : Screens;

procedure writeconfig;
var c : file of configsettype;
begin
  assign(c,'CONFIG.BBS');
  rewrite(c);
  write(c,cfg);
  close(c);
end;

procedure formatconfig;
var cnt : integer;
    x   : byte;
begin
  cfg.versioncode :=thisversioncode;
  cfg.longname    :='Theft of Services';
  cfg.shortname   :='TOS BBS';
  cfg.sysopname   :='Crimson Blade';
  Cfg.BoardPhone  :='505-622-6804';
  getdir (0,cfg.visiondir);
  if cfg.visiondir[length(cfg.visiondir)]<>'\'
    then cfg.visiondir:=cfg.visiondir+'\';
  cfg.textdir     :=cfg.visiondir+'TEXT\';
  cfg.uploaddir   :=cfg.visiondir+'WORK\';
  cfg.boarddir    :=cfg.visiondir+'BOARDS\';
  cfg.overlaypath[0]:=#0;
  cfg.textfiledir :=cfg.visiondir+'MENUS\';
  cfg.doordir     :=cfg.visiondir+'DOORS\';
  cfg.DataDir     :=cfg.visiondir+'DATA\';
  Cfg.ExtractDir  :=Cfg.visiondir+'EXTRACT\';
  Cfg.MenuDir     :=Cfg.VisionDir + 'MENUDATA\';
  cfg.MaxDosShell :=True;
  cfg.UseEms      :=True;
  cfg.modemsetupstr:='ATX6HM0S0=1|';
  cfg.modemhangupstr:='+++~~~ATH|';
  Cfg.OffHookStr:='ATH1 M0|';
  cfg.defbaudrate:=38400;
  cfg.usecom:=1;
  cfg.anonymouslevel:=5;
  cfg.numwelcomes:=1;
  cfg.numstats:=1;
  cfg.numprelogon:=1;
  cfg.mintimeout:=5;
  cfg.sysoplevel:=1000;
  cfg.deflevel:=25;
  cfg.defudratio:=25;
  cfg.defudkratio:=25;
  cfg.defpcr:=25;
  cfg.defmsglength:=30;
  Cfg.DefFlags[0]:=#0;
  cfg.defdailykblimit:=5000;
  cfg.defudlevel:=0;
  cfg.defudpoints:=0;
  cfg.uploadfactor:=5;
  cfg.private:=false;
  cfg.autologin:=false;
  cfg.useconmode:=true;
  cfg.escinmsgs:=false;
  cfg.bkspinmsgs:=true;
  cfg.requiredforms:='15';
  cfg.nuvform:=5;
  cfg.Infoformstr[1]:='New User Application';
  cfg.Infoformstr[2]:='';
  cfg.Infoformstr[3]:='';
  cfg.Infoformstr[4]:='';
  cfg.Infoformstr[5]:='New User Voting Form';
  For Cnt:=1 to 5 do Cfg.Infoformlvl[Cnt] := 0;
  Cfg.DotChar:='ù';
  cfg.supportedrates:=[b2400,b4800,b9600,b19200,b38400];
  cfg.downloadrates:=cfg.supportedrates;
  cfg.availtime:='10:00 am';
  cfg.unavailtime:='10:00 pm';
  for cnt:=1 to 100 do cfg.usertime[cnt]:=60;
  cfg.level2nd:=1;
  cfg.udlevel2nd:=0;
  cfg.logonlevel:=5;
  cfg.anonymousstr:='[ Anonymous ]';
  cfg.systempassword:='Change This';
  cfg.remotedoors:=false;
  cfg.allowdoors:=true;
  cfg.eventtime[0]:=#0;
  cfg.eventbatch[0]:=#0;
  cfg.directvideomode:=true;
  cfg.checksnowmode:=true;
  cfg.matrixtype:=2;
  cfg.defcolor1:=3;
  cfg.defcolor2:=11;
  cfg.defcolor3:=9;
  cfg.defcolor4:=5;
  cfg.defcolor5:=1;
  cfg.defcolor6:=13;
  cfg.defcolor7:=31;
  cfg.lowbaudpassword:='!Get Lost!';
  cfg.newuserpassword:='';
  cfg.sysopmenupassword:='Change This';
  cfg.dospassword:='Change This';
  cfg.RumChar:='  ';
  cfg.ZipComment:=True;
{  cfg.ZipFileAdd:='C2C.ADD'; }
  cfg.DSZLOG:=CFG.ViSiONDiR+'XFER';
  cfg.KPerPoint:=100;
  cfg.PointCommision:=1;
  cfg.TimepercentBack:=50;
  cfg.MinFreeSpace:=250;
  cfg.ExemptLevel:=99;
  cfg.UseBox:=True;
  cfg.BoxChar:='°';
  Cfg.BoxAbort:='Aborted!!';
  Cfg.FilterQuote:=True;
  Cfg.PercentLocal:=20;
  Cfg.UseNUV:=True;
  Cfg.AutoADDNuv:=True;
  Cfg.NUVUseLevel:=25;
  Cfg.NuvY:=10;
  Cfg.NuvN:=10;
  Cfg.NUVKill:=True;
  Cfg.NuvValidate:=True;
  Cfg.NuvLevel:=25;
  Cfg.NuvUDLevel:=25;
  Cfg.NUVPoints:=5;
  Cfg.NetName:='BLiTZMail';
  Cfg.ChangeNote:=True;
  Cfg.cc[1]:=1;
  Cfg.cc[2]:=9;
  Cfg.cc[3]:=5;
  Cfg.cc[4]:=13;
  Cfg.cc[5]:=5;
  Cfg.cc[6]:=9;
  Cfg.cc[7]:=1;
  Cfg.cc[8]:=8;
  Cfg.MaxMsgConf:=1;
  Cfg.MaxFileConf:=1;
  Cfg.BarChar:='³³';
  Cfg.FilePoint:='File Point';
  Cfg.FilePoints:='File Points';
  Cfg.ChatCost:=2;
  Cfg.HangUpOnNew:=True;
  Cfg.ScreenSave:=5;
  Cfg.UseAutoAnswer:=True;
  Cfg.AutoAnswerStr[0]:=#0;
  Cfg.DefTopFive:=3;
  cfg.DefBottomline:=1;
  cfg.ExtractCost:=0;
  cfg.fidoorigin[0]:=#0;
  cfg.DefUserNote := 'Regular User';
  cfg.NodeNum := 1;
  cfg.TotalNodes := 1;
  cfg.NodeDir[0] := #0;
  cfg.LockDTE := True;
  cfg.Use_One_Liners := True;
  for x := 2 to 9
    do cfg.lockrate[x] := 38400;
  cfg.DefFidoAddress:= '';
  cfg.QWKname := 'V2-';
  cfg.MaxQuotedLines := 5;
  writeconfig
end;

procedure def_colors;
begin
  pcolor    := 31;
  normcolor := 27;
  incolor   := 14;
  def_fill  := #32;
end;

procedure message(m : lstr; beep : boolean);
var s : screens;
    x : word;
    k : char;
begin
  readscr(S);
  color(4,12);
  growbox(10,12,70,14);
  color(12,15);
  gotoxy(11,13);
  for x := 11 to 69
    do write(#32);
  center_write(M,13);
  if beep then begin
    for x := 4500 to 5500
      do sound(X);
    for x := 3500 to 4500
      do sound(X);
    nosound;
    k := getkey;
  end else
    delay(2000);
  writeScr(S);
end;

Procedure Ask_Colors;
Begin
  PColor := 5 * 16 + 14;
  NormColor := 5 * 16 + 15;
  InColor := 14;
  Def_Fill := #32;
End;

Procedure Ask(X1,Y1,X2,Y2 : Byte;     { Where }
              Title       : Lstr;     { Title of Box }
              Question    : Lstr;     { Da Question }
              Len         : Byte;     { Max Input Length }
              VAR Result  : Mstr);    { User Input }
Var S : Screens;
    K : Char;
    X : Byte;
Begin
  ReadScr(S);
  Ask_Colors;
  Color(5,15);
  GrowBOX(X1,Y1,X2,Y2);
  Color(13,15);
  GotoXy(X1 + 1,Y1 + 1);
  For X := (X1 - 1) to (X2 - 3)
    Do Write(#32);
  Center_Write(Title,Y1 + 1);
  GotoXy(X1 + 3,Y1 + 2);
  Raw_Editor(Edit,X1 + 3,Y1 + 3,Question,Result,Len,K,False,'',True);
  If K = ESC
    Then Result := '';
  WriteScr(S);
  Def_Colors;
End;

procedure create_box(top,bottom:byte; title:mstr);
begin
  color(1,15);
  growbox(5,top,75,bottom);
  gotoxy(7,top);
  color(1,7);
  write('[');
  color(1,12);
  write(title);
  color(1,7);
  write(']');
end;

Procedure Edit_Main_Config;

procedure edit_stuff(curfield : byte);
const maxfield = 13;
var pentry,
    entry : integer;
    current : word;
    k : char; x : byte;
    s : screens;

    procedure process_main(func:edit_functions);
    begin
      case entry of
        1 : edit_string(func,7,10,'BBS Full Name : ',cfg.longname,50,k);
        2 : edit_string(func,7,11,'BBS Short Name : ',cfg.shortname,50,k);
        3 : edit_string(func,7,12,'SysOp Name : ',cfg.sysopname,30,k);
        4 : edit_string(func,7,13,'BBS Phone Number : ',cfg.boardphone,12,k);
      end;
      select_next_entry(func,entry,4,k);
    end;

    procedure process_dirs(func:edit_functions);
    begin
      case entry of
        1 : edit_string(func,7,8,'Main Directory : ',cfg.visiondir,40,k);
        2 : edit_string(func,7,9,'ANSI Directory : ',cfg.textfiledir,40,k);
        3 : edit_string(func,7,10,'Menu Data Directory : ',cfg.menudir,40,k);
        4 : edit_string(func,7,11,'Misc. Data Directory : ',cfg.datadir,40,k);
        5 : edit_string(func,7,12,'Message Storage Directory : ',cfg.textdir,40,k);
        6 : edit_string(func,7,13,'Boards Directory : ',cfg.boarddir,40,k);
        7 : edit_string(func,7,14,'Work Directory : ',cfg.uploaddir,40,k);
        8 : edit_string(func,7,15,'Extraction Directory : ',cfg.extractdir,40,k);
        9 : edit_string(func,7,16,'Doors Directory : ',cfg.doordir,40,k);
      end;
      select_next_entry(func,entry,9,k);
    end;

    procedure process_modem(func:edit_functions);
    begin
      case entry of
        1 : edit_integer(func,7,6,'COM Port (0-8) : ',cfg.usecom,1,0,8,k);
        2 : edit_baud(func,7,7,'Default Baud Rate (Space Toggles) : ',cfg.defbaudrate,k);
        3 : edit_string(func,7,8,'Modem Init String : ',cfg.modemsetupstr,44,k);
        4 : edit_string(func,7,9,'Modem Hang-up String : ',cfg.modemhangupstr,44,k);
        5 : edit_string(func,7,10,'Off-hook String : ',cfg.offhookstr,44,k);
        6 : edit_yesno(func,7,11,'Using Auto-Answer : ',cfg.useautoanswer,k);
        7 : edit_string(func,7,12,'Manual Answer String : ',cfg.autoanswerstr,44,k);
        8 : edit_yesno(func,7,13,'Lock DTE Rate : ',cfg.lockdte,k);
        9 : edit_baud(func,7,14,'1200  Baud Locked Rate : ',cfg.lockrate[2],k);
        10: edit_baud(func,7,15,'2400  Baud Locked Rate : ',cfg.lockrate[3],k);
        11: edit_baud(func,7,16,'4800  Baud Locked Rate : ',cfg.lockrate[4],k);
        12: edit_baud(func,7,17,'9600  Baud Locked Rate : ',cfg.lockrate[5],k);
        13: edit_baud(func,7,18,'19200 Baud Locked Rate : ',cfg.lockrate[6],k);
        14: edit_baud(func,7,19,'38400 Baud Locked Rate : ',cfg.lockrate[7],k);
        15: edit_baud(func,7,20,'57600 Baud Locked Rate : ',cfg.lockrate[8],k);
      end;
      select_next_entry(func,entry,15,k);
    end;

    procedure writeat(x,y,f,b:byte;s:string);
    begin
      gotoxy(x,y);
      color(b,f);
      write(s);
    end;

    procedure dobaud(var newbaud:baudset; title:mstr);
    const baud : array[1..7] of string[5] =
                 ('1200','2400','4800','9600','19200','38400','57600');
    var b,x,globalb : baudratetype;
        a : byte;
        old : baudset;

        procedure placebar(b:baudratetype; hi:boolean);
        var c1,c2 : byte;
        begin
          if not hi then begin
            c1 := 15;
            c2 := 1;
          end else begin
            c1 := 14;
            c2 := 0;
          end;
          if b > B300 then
           if b in newbaud then
             writeat(22,a+9,12,1,'û ') else
             writeat(22,a+9,12,1,'  ');
          writeat(23,a+9,c1,c2,baud[a]);
        end;

        procedure setbox;
        begin
          color(1,15);
          growbox(20,8,60,17);
          gotoxy(22,8);
          color(1,7);
          write('[');
          color(1,12);
          write(title);
          color(1,7);
          write(']');
          writeat(30,11,11,1,'<CR> : Saves List and Exits');
          writeat(30,12,11,1,'Esc  : Aborts/Keeps Old Value');
          writeat(30,13,11,1,'Space: Toggles Hilighted Baud');
          writeaT(30,14,11,1,'Up/Down Arrows Scroll');
          a:=1;
        end;

        procedure changebaud(b:baudratetype);
        begin
          if b in newbaud then
            newbaud := newbaud-[b] else
            newbaud := newbaud+[b];
          globalb := b;
        end;

    begin
      old := newbaud;
      setbox;
      a := 0;
      for x := b1200 to b57600 do
        begin
          inc(a);
          placebar(x,false);
        end;
      a := 1;
      placebar(b1200,true);
      repeat
        k := get_key;
        case k of
          down : begin
                   placebar(b300,false);
                   inc(a);
                   if a>7 then a := 1;
                   placebar(b300,true);
                 end;
          up   : begin
                   placebar(b300,false);
                   dec(a);
                   if a < 1 then a := 7;
                   placebar(b300,true);
                 end;
          #32  : begin
                   case a of
                     1 : changebaud(b1200);
                     2 : changebaud(b2400);
                     3 : changebaud(b4800);
                     4 : changebaud(b9600);
                     5 : changebaud(b19200);
                     6 : changebaud(b38400);
                     7 : changebaud(b57600);
                   end;
                   placebar(globalb,false);
                   inc(a);
                   if a > 7 then a := 1;
                   placebar(b300,true);
                 end;
          #27  : newbaud := old;
        end;
        until k in [#13,#27,pgup,pgdn];
        if k = #13 then k := pgdn;
    end;

    procedure docolors;
    const colorstr : array [0..15] of string[8] =
      ('Black   ','Blue    ','Green   ','Cyan    ','Red     ','Purple  ',
       'Brown   ','White    ','Gray    ','Hi Blue ','Hi Green','Hi Cyan ',
       'Hi Red  ','Magenta ','Yellow  ','Hi White ');
    var x,a,b : byte;
        c : array[1..15] of byte;
        done : boolean;

        procedure rcolor(x,y:byte);
        begin
          color(x,y);
        end;

         procedure doattrib(VAR Color:Byte);

           function demo : integer;
           var loc,hic : integer;
               it : byte;
               k  : char;
               s  : screens;
           begin
             demo := color;
             readscr(s);
             rcolor(0,8);
             growbox(49,6,78,18);
             writeat(51,7,9,0,  '    Left/Right Arrow:');
             writeat(51,8,9,0,  '    Changes Forground');
             writeat(51,9,9,0,  '      Up/Down Arrow:');
             writeat(51,10,9,0, '    Changes Background');
             writeat(51,11,9,0, '    Enter: Change Color');
             writeat(51,12,11,0,'       ESC: Aborts');
             Writeat(51,15,8,0,'On');
             gotoxy(60,15);
             for loc:=0 to 15 do begin
               TextAttr:=loc+16;
               write('Û');
             end;
             it:=color;
             If It>15 then loc:=it Mod 16 else loc:=it;
             hic:=(it shr 4) and 7;
             repeat
              gotoxy(60+loc,14);
              TextAttr:=15;
              write('');
              gotoxy(60+hic,16);
              write(chr(30));
              gotoxy(50,14);
              TextAttr:=loc;
              if loc=0 then begin         { foreground }
                textattr:=8;
                write('Black   ');
              end else write(colorstr[loc]);
              gotoxy (50,16); textattr:=hic;
              if hic = 0 then begin        { background }
                textattr:=8;
                write('Black   ');
              end else write (colorstr[hic]);
              textattr:=9;
              k:=readkey;
              if (k=#77) then begin
                gotoxy(loc+60,14);write(' ');
                loc:=loc+1;
                if loc > 15 then loc:=0;
              end else if (k=#75) then begin
                gotoxy(loc + 60,14);write(' ');
                loc:=loc - 1;
                if loc < 0 then loc:=15;
              end else
              if k=#72 then begin
                gotoxy(hic+60,16);write (' ');
                hic:=hic + 1;
                if hic > 7 then hic:=0;
              end else if k = #80 then begin
                gotoxy (hic+60,16);write (' ');
                hic:=hic - 1;
                if hic < 0 then hic:=7;
              end;
             until (k=#13) or (k=#27);
             if k=#13 then demo:=(hic * 16) + loc else demo:=color;
             writescr(s);
           end;

      var cnt,v,back:integer;
          k:char;
      begin
        v:=demo;
        Color:=v;
      end;

       procedure writecolor(hi:boolean; color:integer);
       var c1,c2 : byte;
       begin
         if hi then writeat(33,X+4,14,1,'>')
         else writeat(33,x+4,15,1,#32);
         if hi then begin
           c1 := 15;
           c2 := 4;
         end else begin
           c1 := color and 15;
           c2 := color shr 4;
         End;
         writeat(34,X+4,C1,C2,colorstr[Color and 15]+' on '+colorstr[(Color shr 4) and 7]);
         C[x]:=Color;
       end;

    var xx : byte;
    begin
      done := false;
      create_box(4,20,'Default Color Settings');
      window(7,5,75,20);
      color(1,15);
      for x := 1 to 7 do writeln('Default User Color '+strr(x)+'     : ');
      for x := 1 to 8 do writeln('Alternating Chat Color '+strr(x)+' : ');
      window(1,1,80,25);
      x := 1;
      writecolor(False,Cfg.DefColor1); X:=2;
      writecolor(False,Cfg.DefColor2); X:=3;
      writecolor(False,Cfg.DefColor3); X:=4;
      writecolor(False,Cfg.DefColor4); X:=5;
      writecolor(False,Cfg.DefColor5); X:=6;
      writecolor(False,Cfg.DefColor6); X:=7;
      writecolor(False,Cfg.DefColor7); X:=8;
      for x := 8 to 15 Do WriteColor(False,Cfg.CC[X-7]);
      x := 1;
      WriteColor(True,Cfg.DefColor1);
      Repeat
      k := get_key;
      CASE k OF
        up:Begin       {UP}
             WriteColor(false,C[X]);
             dec(x);
             IF x<=0 Then x:=15;
             WriteColor(true,C[X]);
             End;
        down:Begin       {DOWN}
             Writecolor(False,C[X]);
             inc(x);
             IF x>=16 Then x:=1;
             WriteColor(true,C[X]);
             End;
        #13: Begin
              CASE X OF
               1..15:DoAttrib(C[X]);
               End;
              WriteColor(true,C[x]);
             End;
        #196,pgup,pgdn:Begin
               Cfg.DefColor1:=C[1];
               Cfg.DefColor2:=C[2];
               Cfg.DefColor3:=C[3];
               Cfg.DefColor4:=C[4];
               Cfg.DefColor5:=C[5];
               Cfg.DefColor6:=C[6];
               Cfg.DefColor7:=C[7];
               For X:=8 to 15 Do Cfg.CC[X-7]:=C[X];
              Done:=True;
            End;
        #27:Done:=True;
        End;
      until done;
    End;

    procedure process_systemvars(func:edit_functions);
    begin
      case entry of
        1 : edit_yesno(func,7,6,'Use Direct Screen Writes : ',cfg.directvideomode,k);
        2 : edit_yesno(func,7,7,'Use EMS for Overlay file : ',cfg.useems,k);
        3 : edit_yesno(func,7,8,'Swap for DOS Shell : ',cfg.maxdosshell,k);
        4 : edit_yesno(func,7,9,'Local Auto-Login : ',cfg.autologin,k);
        5 : edit_yesno(func,7,10,'Refuse New Users : ',cfg.private,k);
        6 : edit_string(func,7,11,'Available for Chat start time : ',cfg.availtime,12,k);
        7 : edit_string(func,7,12,'Available for Chat end time : ',cfg.unavailtime,12,k);
        8 : edit_byte(func,7,13,'Screen Save after this many minutes : ',cfg.screensave,3,1,100,k);
        9 : edit_byte(func,7,14,'Node Number : ',cfg.nodenum,2,0,10,k);
        10: edit_byte(func,7,15,'Total Nodes : ',cfg.totalnodes,2,0,10,k);
        11: edit_byte(func,7,16,'Default Bottom Line (0-3) : ',cfg.defbottomline,1,0,3,k);
        12: edit_byte(func,7,17,'Default Top-Five Listing : ',cfg.deftopfive,2,0,3,k);
        13: edit_byte(func,7,18,'Total Message Conferences : ',cfg.maxmsgconf,2,1,99,k);
        14: edit_byte(func,7,19,'Total File Conferences : ',cfg.maxfileconf,2,1,99,k);
        15: edit_string(func,7,20,'QWK Packet Name : ',cfg.qwkname,6,k);
        16: edit_integer(func,7,21,'Chat Cost (file points) : ',cfg.chatcost,3,0,999,k);
      end;
      select_next_entry(func,entry,16,k);
    end;

    procedure process_levels(func:edit_functions);
    begin
      case entry of
        1 : edit_integer(func,7,7,'Minimum SysOp Level : ',cfg.sysoplevel,5,1,32767,k);
        2 : edit_integer(func,7,8,'Minimum Login Level : ',cfg.logonlevel,5,1,32767,k);
        3 : edit_integer(func,7,9,'Post Anonymous Level : ',cfg.anonymouslevel,5,1,32767,k);
        4 : edit_integer(func,7,10,'Default User Level : ',cfg.deflevel,5,0,32767,k);
        5 : edit_integer(func,7,11,'Default User File Level : ',cfg.defUDlevel,5,0,32767,k);
        6 : edit_integer(func,7,12,'Default User File Points : ',cfg.defudpoints,5,0,32767,k);
        7 : edit_integer(func,7,13,'Default User UD Ratio : ',cfg.defudratio,5,0,32767,k);
        8 : edit_integer(func,7,14,'Default User UD K Ratio : ',cfg.defudkratio,5,0,32767,k);
        9 : edit_integer(func,7,15,'Default Daily KB Limit : ',cfg.defdailykblimit,5,0,32767,k);
        10: edit_integer(func,7,16,'Default Required PCR : ',cfg.defpcr,5,0,32767,k);
        11: edit_integer(func,7,17,'Default Required Message Length for credit : ',cfg.defmsglength,5,0,32767,k);
        12: edit_string(func,7,18,'Default Flags : ',cfg.defflags,26,k);
        13: edit_string(func,7,19,'Default User Note : ',cfg.defusernote,30,k);
        14: edit_integer(func,7,20,'Exempt from PCR/Ratios Level : ',cfg.exemptlevel,5,0,32767,k);
      end;
      select_next_entry(func,entry,14,k);
    end;

    procedure process_forms(func:edit_functions);
    begin
      case entry of
        1 : edit_byte(func,7,7,'Matrix (0/None 1/Script 2/Pulldown) : ',cfg.matrixtype,1,0,2,k);
        2 : edit_yesno(func,7,8,'Hang-up on New Users : ',cfg.hanguponnew,k);
        3 : edit_string(func,7,9,'Required Infoforms : ',cfg.requiredforms,5,k);
        4 : edit_string(func,7,10,'Infoform #1 Description : ',cfg.infoformstr[1],30,k);
        5 : edit_string(func,7,11,'Infoform #2 Description : ',cfg.infoformstr[2],30,k);
        6 : edit_string(func,7,12,'Infoform #3 Description : ',cfg.infoformstr[3],30,k);
        7 : edit_string(func,7,13,'Infoform #4 Description : ',cfg.infoformstr[4],30,k);
        8 : edit_string(func,7,14,'Infoform #5 Description : ',cfg.infoformstr[5],30,k);
        9 : edit_integer(func,7,15,'Infoform #1 Minimum Level : ',cfg.infoformlvl[1],5,0,32767,k);
        10: edit_integer(func,7,16,'Infoform #2 Minimum Level : ',cfg.infoformlvl[2],5,0,32767,k);
        11: edit_integer(func,7,17,'Infoform #3 Minimum Level : ',cfg.infoformlvl[3],5,0,32767,k);
        12: edit_integer(func,7,18,'Infoform #4 Minimum Level : ',cfg.infoformlvl[4],5,0,32767,k);
        13: edit_integer(func,7,19,'Infoform #5 Minimum Level : ',cfg.infoformlvl[5],5,0,32767,k);
      end;
      select_next_entry(func,entry,13,k);
    end;

    procedure process_password(func:edit_functions);
    var s : string[1];
    begin
      case entry of
        1 : edit_string(func,7,9,'BBS Login Password : ',cfg.systempassword,30,k);
        2 : edit_string(func,7,10,'New User Password : ',cfg.newuserpassword,30,k);
        3 : edit_string(func,7,11,'Lockout Baud Password : ',cfg.lowbaudpassword,30,k);
        4 : edit_string(func,7,12,'SysOp Password : ',cfg.sysopmenupassword,30,k);
        5 : edit_string(func,7,13,'DOS Shell Password : ',cfg.dospassword,30,k);
        6 : begin
              s[1] := cfg.dotchar;
              edit_string(func,7,14,'Password Echo Character : ',s,1,k);
              cfg.dotchar := s[1];
            end;
      end;
      select_next_entry(func,entry,6,k);
    end;

    procedure process_filesec(func:edit_functions);
    begin
      case entry of
        1 : edit_integer(func,7,8,'File Point Validation Commision : ',cfg.uploadfactor,3,0,100,k);
        2 : edit_integer(func,7,9,'Value/File Size Conversion (in K) : ',cfg.KPerPoint,4,0,9999,k);
        3 : edit_byte(func,7,10,'File Commision when Downloaded : ',cfg.pointcommision,3,0,255,k);
        4 : edit_byte(func,7,11,'Time % Back After Upload : ',cfg.timepercentback,3,0,255,k);
        5 : edit_integer(func,7,12,'Minimum HD Space for Uploads (K) : ',cfg.minfreespace,4,0,9999,k);
        6 : edit_string(func,7,13,'Path/Filename to DSZLOG : ',cfg.dszlog,40,k);
        7 : edit_string(func,7,14,'Name for File Point (Singular) : ',cfg.filepoint,30,k);
        8 : edit_string(func,7,15,'Name for File Points (Plural) : ',cfg.filepoints,30,k);
        9 : edit_byte(func,7,16,'Cost per File when Extracting : ',cfg.extractcost,3,0,100,k);
      end;
      select_next_entry(func,entry,9,k);
    end;

    procedure process_nuv(func:edit_functions);
    begin
      case entry of
        1 : edit_integer(func,7,8,'New User Voting Form # : ',cfg.nuvform,1,0,5,k);
        2 : edit_yesno(func,7,9,'Allow New User Voting : ',cfg.usenuv,k);
        3 : edit_yesno(func,7,10,'Auto-Add All New Users : ',cfg.autoaddnuv,k);
        4 : edit_integer(func,7,11,'Level to Use NUV : ',cfg.nuvuselevel,5,0,32767,k);
        5 : edit_integer(func,7,12,'Required Yes Votes : ',cfg.nuvy,3,0,999,k);
        6 : edit_integer(func,7,13,'Required No Votes : ',cfg.nuvn,3,0,999,k);
        7 : edit_yesno(func,7,14,'Auto-Delete Rejected Users : ',cfg.nuvkill,k);
        8 : edit_yesno(func,7,15,'Auto-Validate Accepted Users : ',cfg.nuvvalidate,k);
        9 : edit_integer(func,7,16,'Level to Give to Accepted Users : ',cfg.nuvlevel,5,0,32757,k);
        10: edit_integer(func,7,17,'File Level to Give to Accepted Users : ',cfg.nuvudlevel,5,0,32767,k);
        11: edit_integer(func,7,18,'File Points to Give to Accepted Users : ',cfg.nuvpoints,5,0,32767,k);
        12: edit_byte(func,7,19,'Maximum Percent Local : ',cfg.percentlocal,3,0,100,k);
      end;
      select_next_entry(func,entry,12,k);
    end;

    procedure process_misc(func:edit_functions);
    var s : string[1];
    begin
      case entry of
        1 : edit_integer(func,7,7,'Total # of Welcome Screens : ',cfg.numwelcomes,3,0,999,k);
        2 : edit_integer(func,7,8,'Total Pre-Login Screens : ',cfg.numprelogon,3,0,999,k);
        3 : edit_integer(func,7,9,'Total Login System Stats : ',cfg.numstats,3,0,999,k);
        4 : edit_integer(func,7,10,'Minutes Before Time-out : ',cfg.mintimeout,3,1,999,k);
        5 : edit_string(func,7,11,'Time for Shell Event : ',cfg.eventtime,12,k);
        6 : edit_string(func,7,12,'File to Run on Event : ',cfg.eventbatch,12,k);
        7 : edit_string(func,7,13,'Rumor Bracket Characters : ',cfg.rumchar,2,k);
        8 : edit_yesno(func,7,14,'Use ''Input Box'' : ',cfg.usebox,k);
        9 : begin
              s[1] := cfg.boxchar;
              edit_string(func,7,15,'Input Box Character : ',s,1,k);
              cfg.boxchar := s[1];
            end;
        10: edit_string(func,7,16,'Box Abort String : ',cfg.boxabort,15,k);
        11: edit_yesno(func,7,17,'Allow Users to Change Notes : ',cfg.changenote,k);
        12: edit_string(func,7,18,'Bar Menu Brackets : ',cfg.barchar,2,k);
        13: edit_string(func,7,19,'Default FIDO Origin : ',cfg.FidoOrigin,39,k);
        14: edit_string(func,7,20,'Default FIDO Address : ',cfg.deffidoaddress,10,k);
        15: edit_string(func,7,21,'Anonymous String : ',cfg.anonymousstr,30,k);
        16: edit_byte(func,7,22,'Maximum Lines per Quote : ',cfg.maxquotedlines,2,1,99,k);
      end;
      select_next_entry(func,entry,16,k);
    end;

begin
  k := #0;
  repeat
    readscr(s);
    def_colors;
    case curfield of
      1 : begin
            create_box(9,14,'BBS Registration Info');
            for entry := 1 to 4 do process_main(display);
            entry := 1;
            repeat
              process_main(edit);
            until (k<>up) and (k<>down)
          end;
      2 : begin
            create_box(5,22,'BBS Variables');
            for entry := 1 to 16 do process_systemvars(display);
            entry := 1;
            repeat
              process_systemvars(edit);
            until (k<>up) and (k<>down)
          end;
      3 : begin
            create_box(7,17,'Paths/Directories');
            for entry := 1 to 9 do process_dirs(display);
            entry := 1;
            repeat
              process_dirs(edit);
            until (k<>up) and (k<>down);
          end;
      4 : begin
            create_box(5,21,'Modem Setup');
            for entry := 1 to 15 do process_modem(display);
            entry := 1;
            repeat
              process_modem(edit);
            until (k<>up) and (k<>down);
          end;
      5 : dobaud(cfg.supportedrates,'Supported Login Rates');
      6 : dobaud(cfg.downloadrates,'Supported Download Rates');
      7 : docolors;
      8 : begin
            create_box(6,21,'Levels/Defaults');
            for entry := 1 to 14 do process_levels(display);
            entry := 1;
            repeat
              process_levels(edit);
            until (k<>up) and (k<>down);
          end;
      9 : begin
            create_box(6,20,'Matrix/Infoforms');
            for entry := 1 to 13 do process_forms(display);
            entry := 1;
            repeat
              process_forms(edit);
            until (k<>up) and (k<>down);
          end;
      10: begin
            create_box(8,15,'Passwords');
            for entry := 1 to 6 do process_password(display);
            entry := 1;
            repeat
              process_password(edit);
            until (k<>up) and (k<>down);
          end;
      11: begin
            create_box(7,17,'File Area Variables');
            for entry := 1 to 9 do process_filesec(display);
            entry := 1;
            repeat
              process_filesec(edit);
            until (k<>up) and (k<>down);
          end;
      12: begin
            create_box(7,20,'New User Voting');
            for entry := 1 to 12 do process_nuv(display);
            entry := 1;
            repeat
              process_nuv(edit);
            until (k<>up) and (k<>down);
          end;
      13: begin
            create_box(6,23,'Miscellaneous');
            for entry := 1 to 16 do process_misc(display);
            entry := 1;
            repeat
              process_misc(edit);
            until (k<>up) and (k<>down);
          end;
    end;
    case k of
      dispedit.pgdn : begin
                        inc(curfield);
                        if curfield > maxfield then curfield := 1;
                      end;
      dispedit.pgup : begin
                        dec(curfield);
                        if curfield < 1 then curfield := maxfield;
                      end;
    end;
    writescr(s);
  until k = #27;
end;

procedure pick_something;
var pentry, entry : integer;
    k : char;
    yes : string[1];

    procedure process_entry(func:edit_functions);
    begin
      case entry of
        1 : edit_funkey(func,27,6,'Registration Info','1',k);
        2 : edit_funkey(func,27,7,'BBS Variables','2',k);
        3 : edit_funkey(func,27,8,'Pathnames/Directories','3',k);
        4 : edit_funkey(func,27,9,'Modem Setup','4',k);
        5 : edit_funkey(func,27,10,'Supported Bauds','5',k);
        6 : edit_funkey(func,27,11,'Supported Download Buads','6',k);
        7 : edit_funkey(func,27,12,'Default Colors','7',k);
        8 : edit_funkey(func,27,13,'Levels/Defaults','8',k);
        9 : edit_funkey(func,27,14,'Matrix/Infoforms','9',k);
        10: edit_funkey(func,27,15,'System Passwords','A',k);
        11: edit_funkey(func,27,16,'File Area Variables','B',k);
        12: edit_funkey(func,27,17,'New User Voting','C',k);
        13: edit_funkey(func,27,18,'Miscellaneous','D',k);
        14: edit_funkey(func,27,19,'Quit Config','Q',k);
      end;
      select_next_entry(func,entry,14,k);
    end;

    procedure def_colors;
    begin
      pcolor    := 16 * 15 + 0;
      normcolor := 16 * 9 + 15;
    end;

begin
  color(9,15);
  growbox(25,5,55,20);
  def_colors;
  for entry := 1 to 14 do process_entry(display);
  entry := 1;
  repeat
    def_colors;
    repeat
      process_entry(edit);
    until (k<>up) and (k<>down);
    case k of
      '1'..'9' : edit_stuff(valu(k));
      'A'      : edit_stuff(10);
      'B'      : edit_stuff(11);
      'C'      : edit_stuff(12);
      'D'      : edit_stuff(13);
    end;
  until (k = 'Q') or (k = #27);
  yes := 'Y';
  ask(9,9,71,15,'ViSiON/2 BBS Configuration v1.0á',
     'Write any modifications to disk? ',3,yes);
  if upcase(yes[1]) = 'Y' then writeconfig;
end;

procedure start_screen;
begin
  writescr(topscreen);
{  fill_screen('²',7,1); }
  gotoxy(1,1);
  color(8,15);
  clreol;
  center_write('ViSiON/2 Bulletin Board System Configuration v1.0á',1);
  gotoxy(1,25);
  clreol;
  center_write('Written by Crimson Blade  (c) 1993 Ruthless Enterprises',25);
  if not exist('CONFIG.BBS') then
    begin
      message('Creating new CONFIG.BBS',false);
      formatconfig;
    end;
  readcfg;
end;

begin
  start_screen;
  pick_something;
end;             (* Edit_Main_Config *)

(***********************************************************************)

Procedure Protocol_Editor;
Const Files : Array[1..4] Of String[12]
      = ('PROT_S.DAT','PROT_R.DAT','PROT_D.DAT','PROT_U.DAT');

Var CurFile : File Of ProtoRec;
    Total : Byte;
    Prot : Array[1..15] Of ProtoRec;

Procedure SetUpScreen(Title : Mstr);

  Procedure Message(X,Y : Byte; M : LStr);
  Begin
    GotoXy(X,Y);
    TextAttr := 16 + 7;
    Disp('[');
    TextAttr := 31;
    Disp(M);
    TextAttr := 16 + 7;
    Disp(']');
  End;

Begin
  Message(3,10,Title);
  Message(35,10,'PgDn - Next   PgUp - Last   ESC - Exit');
  Message(3,15,'F1 - Delete a Protocol');
  Message(54,15,'F2 - Add a Protocol');
End;

Procedure EditProt( W : Byte );
Label
    Start;
Const
    MaxEnt = 4;
Var
    PEntry : Integer;
    Entry : Integer;
    Current : Integer;
    K : Char;
    P : ProtoRec;


    Procedure Proc_Entry(Func : Edit_Functions);
    Var Khar : String[1];
    Begin
      Case Entry Of
        1 : Begin
              Khar[1] := Prot[current+1].Letter;
              Edit_String(Func,4,11,'Protocol Letter : ',Khar,1,K);
              Prot[current+1].Letter := Khar[1];
            End;
        2 : Edit_String(Func,4,12,'Protocol Title : ',Prot[current+1].Desc,30,K);
        3 : Edit_String(Func,4,13,'File Name : ',Prot[current+1].ProgName,12,K);
        4 : Edit_String(Func,4,14,'Command Line : ',Prot[current+1].Commfmt,59,K);
      End;
      Select_Next_Entry(Func,Entry,MaxEnt,K);
    End;

  Procedure WriteFile(X : Byte);
  Var A : Byte;
  Begin
    Rewrite(CurFile);
    For A := 1 to (Total + 1) Do
        nWrite(CurFile,Prot[a]);
    Close(CurFile);
  End;

    Procedure WhichProt;
    Begin
      GotoXy(33,15);
      TextAttr := 16 + 7;
      Disp('[');
      TextAttr := 31;
      Disp('Current: ');
      Write(Current + 1);
      TextAttr := 16 + 7;
      Disp(']');
    End;

    Procedure Create_File;
    var p : protorec;
    Begin
      ReWrite(curfile);
      P.Letter := 'Z';
      P.Desc := 'Zmodem CRC-32';
      P.ProgName := 'DSZ.EXE';
      P.CommFmt := '';
      case w of
        1: P.CommFmt := 'port %1 speed %2 sz %3';
        2: P.CommFmt := 'port %1 speed %2 rz %3';
        3: P.CommFmt := 'port %1 speed %2 sz @%3';
        4: P.CommFmt := 'port %1 speed %2 rz %3';
      end;
      Seek(curfile,0);
      NWrite(curfile,p);
    End;

  Procedure LoadFile( X : Byte );
  Var A : Byte;
  Begin
    Assign(CurFile,Cfg.DataDir + Files[W]);
    If Not Dos_Exists(Cfg.DataDir + Files[w])
      Then Create_File
      Else Reset(CurFile);
    A := 0;
    Seek(Curfile,0);
    While Not Eof(CurFile) Do Begin
      Inc(a);
      nRead(CurFile,Prot[a]);
    End;
    Total := A;
  End;

const titles : array[1..4] of mstr =
      ('Upload Protocols','Download Protocols','Batch Uploads','Batch Downloads');

Var X   : Byte;
    Yes : String[1];
    S   : Screens;
Begin
  ReadScr(s);
  FillChar(prot,SizeOf(prot),0);
  LoadFile(w);
  def_colors;
  color(1,7);
  growbox(2,10,78,15);
  setupscreen(titles[w]);
  Total := FileSize(CurFile) - 1;
  Current := 0;

  Start :

  Seek(CurFile,Current);
  NRead(CurFile,P);

  K := PGDN;
  Entry := 0;

  For X := 1 to MaxEnt
  Do Begin
    Inc(Entry);
    Proc_Entry(Display);
  End;

  Entry := 1;

  WhichProt;

  Repeat
    Proc_Entry(Edit);
  Until (K <> UP) and (K <> DOWN);

  Seek(Curfile,Current);
  NWrite(CurFile,Prot[Current + 1]);

  Case K Of

    PGDN : Begin
      Inc(Current);
      If Current > Total
        Then Current := 0;
      Goto Start;
    End;

    PGUP : Begin
      Dec(Current);
      If Current < 0
        Then Current := Total;
      Goto Start;
    End;

    F1 : Begin
      yes := 'N';
      ask(9,9,71,15,'Protocol Deletion',
                    'Delete protocol "'+prot[current+1].Desc+'"? ',3,yes);
      if upcase(yes[1]) <> 'Y' then goto start;
      fillchar(prot[current+1],SizeOf(prot[current+1]),0);
      Seek(CurFile,Current);
      NWrite(CurFile,prot[current+1]);
      If Current = Total Then Begin
        Seek(CurFile,Current);
        Truncate(CurFile);
      End;
      Goto Start;
    End;

    F2 : Begin
      yes := 'N';
      ask(9,9,71,15,'Protocol Addition',
                    'Add a new protocol now? ',3,yes);
      if upcase(yes[1]) = 'Y' then
      Begin
        inc(total);
        Seek(CurFile,FileSize(curfile));
        Prot[total].Letter := #0;
        Prot[total].ProgName := 'DSZ.EXE';
        Prot[total].CommFmt := '';
        Prot[total].Desc := '';
        NWrite(CurFile,Prot[total]);
        Current := Total;
      End;
      Goto Start;
    End;

  End;
  WriteFile(w);
  WriteScr(s);
End;

Procedure Select;
Var
  PEntry : Integer;
  Entry : Integer;
  K : Char;

  Procedure Proc_Entry(Func : Edit_Functions);
  Begin
    Case Entry Of
      1 : Edit_FunKey (Func,26,11,'      Upload Protocols       ','1',K);
      2 : Edit_FunKey (Func,26,12,'     Download Protocols      ','2',K);
      3 : Edit_FunKey (Func,26,13,'   Batch Upload Protocols    ','3',K);
      4 : Edit_FunKey (Func,26,14,'  Batch Download Protocols   ','4',K);
      5 : Edit_FunKey (Func,26,15,'    Quit Protocol Editor     ','Q',K);
    End;
    select_next_entry(func,entry,5,k);
  End;

    procedure def_colors;
    begin
      pcolor    := 16 * 15 + 0;
      normcolor := 16 * 9 + 15;
    end;

Begin
  color(9,15);
  growbox(25,10,55,16);
  def_colors;
  GotoXy(28,6);
  For Entry := 1 to 5
    Do Proc_Entry(Display);
  Entry := 1;
  Repeat
    def_colors;
    Repeat
      Proc_Entry(Edit);
    Until (K<>Up) and (K<>Down);
    Case Upcase(K) Of
      '1' : EditProt(1);
      '2' : EditProt(2);
      '3' : EditProt(3);
      '4' : EditProt(4);
      'Q' : K := ESC;
    End;
  Until K = ESC;
End;

procedure start_screen;
begin
  writescr(topscreen);
{  fill_screen('²',7,1); }
  gotoxy(1,1);
  color(8,15);
  clreol;
  center_write('ViSiON/2 Bulletin Board Protocol Editor v1.0á',1);
  gotoxy(1,25);
  clreol;
  center_write('Written by Crimson Blade  (c) 1993 Ruthless Enterprises',25);
end;

begin
  start_screen;
  select;
end;           (* Protocol Editor *)

(*************************************************************************)

Procedure Edit_Conferences;
Const ConfFile : Array[1..2] Of String[12]
               = ('XFERCONF.DAT','MSGCONF.DAT');

Type ConfRec = Record
       Name,
       Password : Lstr;
       Flags : String[26];
       Minlevel,
       Maxlevel : integer;
       OpenTime,
       CloseTime : Sstr;
     End;

Var Fd : File Of ConfRec;
    C : ConfRec;
    Total : Word;

  Procedure Nuke_Msg_Conf(X : Byte);
  Var F     : File;
      BFile : File of BoardRec;
      BDir  : BoardRec;
      NSFile: File of NewScanRec;
      NS    : NewScanRec;
      I,P   : Integer;
  Begin
    ClrScr;
    I := IoResult;
    If Not Exist(Cfg.BoardDir + 'BOARDDIR.' + Strr(X))
      Then Exit;
    Assign(BFile,Cfg.BoardDir + 'BOARDDIR.' + Strr(X));
    Reset(BFile);
    If IoResult <> 0 Then Begin
      Close(BFile);
      Exit;
    End;
    For I := 1 to FileSize(BFile) Do Begin
      Seek(BFile,I-1);
      NRead(BFile,BDir);
      If Exist(Cfg.BoardDir + BDir.ShortName + '.' + Strr(X))
      Then Begin
        Writeln('Deleting Sub-Board: ',BDir.BoardName);
        Assign(F,Cfg.BoardDir + BDir.ShortName + '.' + Strr(X));
        Erase(F);
        P := IoResult;
        Assign(F,Cfg.TextDir + BDir.ShortName + '.M' + Strr(X));
        Erase(F);
        P := IoResult;
        Assign(F,Cfg.TextDir + BDir.ShortName + '.T' + Strr(X));
        Erase(F);
        P := IoResult;
      End;
    End;
    Writeln('Deleteing Board Index File');
    Close(BFile);
    Erase(BFile);
    I := IoResult;
    Assign(NSFile,Cfg.DataDir + 'SCANDATA.' + Strr(X));
    Reset(NSFile);
    If IoResult <> 0 Then Begin
      Close(NSFile);
      Exit;
    End;
    Write('Updating NewScan Records...');
    For I := 1 to FileSize(NSFile) Do Begin
      Seek(NSFile,I-1);
      NRead(NSFile,NS);
      FillChar(NS.LastRead,SizeOf(NS.LastRead),0);
      NS.NewScanConfig := [];
      NS.Access1 := [];
      NS.Access2 := [];
      Seek(NSFile,I-1);
      NWrite(NSFile,NS);
    End;
    Close(NSFile);
  End;


Procedure SetUpScreen(Title : Mstr);

  Procedure Message(X,Y : Byte; M : LStr);
  Begin
    GotoXy(X,Y);
    TextAttr := 16 + 7;
    Disp('[');
    TextAttr := 31;
    Disp(M);
    TextAttr := 16 + 7;
    Disp(']');
  End;

Begin
  Message(3,10,Title);
  Message(35,10,'PgDn - Next   PgUp - Last   ESC - Exit');
  Message(3,18,'F1 = Delete Conference');
  Message(54,18,'F2 = Add Conference');
End;

Procedure EditConf( W : Byte );
Label
    Start;
Const
    MaxEnt = 7;
Var
    PEntry : Integer;
    Entry : Integer;
    Current : Integer;
    K : Char;


    Procedure Proc_Entry(Func : Edit_Functions);
    Begin
      Case Entry Of
        1 : Edit_String(Func,4,11,'Conference Name : ',C.Name,55,K);
        2 : Edit_String(Func,4,12,'Conference Password : ',C.Password,30,K);
        3 : Edit_String(Func,4,13,'Conference Flags : ',C.Flags,26,K);
        4 : Edit_Integer(Func,4,14,'Minimum Entry Level : ',C.MinLevel,5,0,32767,K);
        5 : Edit_Integer(Func,4,15,'Maximum Entry Level : ',C.MaxLevel,5,0,32767,K);
        6 : Edit_String(Func,4,16,'Conference Open Time : ',C.OpenTime,12,K);
        7 : Edit_String(Func,4,17,'Conference Close Tome : ',C.CloseTime,12,K);
      End;
      Select_Next_Entry(Func,Entry,MaxEnt,K);
    End;

    Procedure WhichConf;
    Begin
      GotoXy(33,18);
      TextAttr := 16 + 7;
      Disp('[');
      TextAttr := 31;
      Disp('Conf #: ');
      Write(Current + 1);
      TextAttr := 16 + 7;
      Disp(']');
    End;

    Procedure Create_File;
    Begin
      ReWrite(FD);
      C.Name := 'New Conference';
      C.OpenTime := '4:01 am';
      C.CloseTime := '4:00 am';
      C.MinLevel := 5;
      C.MaxLevel := 32767;
      Seek(FD,0);
      NWrite(Fd,C);
    End;


Var X   : Byte;
    Yes : String[1];
    S   : Screens;
Begin
  ReadScr(s);
  FillChar(C,SizeOf(C),0);
  Assign(FD,Cfg.DataDir + ConfFile[W]);
  If Not Dos_Exists(Cfg.DataDir + ConfFile[w])
    Then Create_File
    Else Reset(Fd);
  def_colors;
  color(1,7);
  growbox(2,10,78,18);
  If W = 1
    then SetUpScreen('File Conference Editor')
    else SetUpScreen('Message Conference Editor');
  Total := FileSize(Fd) - 1;
  Current := 0;

  Start :

  Seek(Fd,Current);
  NRead(Fd,C);

  K := PGDN;
  Entry := 0;

  For X := 1 to MaxEnt
  Do Begin
    Inc(Entry);
    Proc_Entry(Display);
  End;

  Entry := 1;

  WhichConf;

  Repeat
    Proc_Entry(Edit);
  Until (K <> UP) and (K <> DOWN);

  Seek(Fd,Current);
  NWrite(Fd,C);

  Case K Of

    PGDN : Begin
      Inc(Current);
      If Current > Total
        Then Current := 0;
      Goto Start;
    End;

    PGUP : Begin
      Dec(Current);
      If Current < 0
        Then Current := Total;
      Goto Start;
    End;

    F1 : Begin
      yes := 'N';
      ask(9,9,71,15,'Conference Deletion',
                    'Delete conference "'+C.Name+'"? ',3,yes);
      if upcase(yes[1]) <> 'Y' then goto start;
      fillchar(C,SizeOf(C),0);
      Seek(Fd,Current);
      NWrite(Fd,C);
      If W = 2 Then Begin
        Nuke_Msg_Conf(Current + 1);
        TextAttr := 1;
        {ClrScr;}
        SetUpScreen('Message Conference Editor');
      End;
      If Current = Total Then Begin
        Seek(FD,Current);
        Truncate(FD);
      End;
      Goto Start;
    End;

    F2 : Begin
      yes := 'N';
      ask(9,9,71,15,'Conference Addition',
                    'Add a new conference now? ',3,yes);
      if upcase(yes[1]) = 'Y' then
      Begin
        FillChar(C,SizeOf(C),0);
        Seek(Fd,FileSize(FD));
        C.Name := 'New Conference';
        C.OpenTime := '4:01 am';
        C.CloseTime := '4:00 am';
        C.MinLevel := 5;
        C.MaxLevel := 32767;
        NWrite(Fd,C);
        Inc(Total);
        Current := Total;
      End;
      Goto Start;
    End;

  End;

  WriteScr(s);
  Close(Fd);
End;

Procedure Select;
Var
  PEntry : Integer;
  Entry : Integer;
  K : Char;

  Procedure Proc_Entry(Func : Edit_Functions);
  Begin
    Case Entry Of
      1 : Edit_FunKey (Func,26,12, '   Edit Message Conference   ','1',K);
      2 : Edit_FunKey (Func,26,13, '    Edit File Conferences    ','2',K);
      3 : Edit_FunKey (Func,26,14,'   Quit Conference Editing   ','Q',K);
    End;
    select_next_entry(func,entry,3,k);
  End;

    procedure def_colors;
    begin
      pcolor    := 16 * 15 + 0;
      normcolor := 16 * 9 + 15;
    end;

Begin
  color(9,15);
  growbox(25,11,55,15);
  def_colors;
  GotoXy(28,6);
  For Entry := 1 to 3
    Do Proc_Entry(Display);
  Entry := 1;
  Repeat
    def_colors;
    Repeat
      Proc_Entry(Edit);
    Until (K<>Up) and (K<>Down);
    Case Upcase(K) Of
      '1' : EditConf(2);
      '2' : EditConf(1);
      'Q' : K := ESC;
    End;
  Until K = ESC;
End;

procedure start_screen;
begin
  writescr(topscreen);
{  fill_screen('²',7,1); }
  gotoxy(1,1);
  color(8,15);
  clreol;
  center_write('ViSiON/2 Bulletin Board Conference Editor v1.0á',1);
  gotoxy(1,25);
  clreol;
  center_write('Written by Crimson Blade  (c) 1993 Ruthless Enterprises',25);
end;

Begin
  start_screen;
  select;
End;           (* Edit_Conferences *)

(**********************************************************************)

Procedure Edit_Emulation;
Var EFile  : File of EmulationRec;
    Emul   : EmulationRec;
    EArray : Array[1..20] of EmulationRec;
    Total  : Byte;

Procedure New_File;
Begin
  Assign(EFile,Cfg.DataDir + 'EMULATE.DAT');
  FillChar(EMul,SizeOf(EMul),0);
  EMul.Name := 'ViSiON/2';
  EMul.TextDir := Cfg.TextFileDir;
  EMul.AllowBars := True;
  EMul.MaxLevel := 32767;
  Emul.Identity := 1;
  {$I-} Rewrite(EFile); {$I+}
  NWrite(EFile,Emul);
  Close(EFile);
End;

Procedure Read_All;
Var X : Byte;
Begin
  If Not Exist(Cfg.DataDir + 'EMULATE.DAT')
    Then New_File;
  Assign(EFile,Cfg.DataDir + 'EMULATE.DAT');
  {$I-} Reset(EFile); {$I+}
  Total := 0;
  For X := 1 to FileSize(EFile)
  Do Begin
    Inc(Total);
    Seek(EFile,X-1);
    NRead(EFile,EArray[Total]);
  End
End;

Procedure Edit_All;
Label Start;
Const MaxEnt = 7;
Var
   PEntry : Integer;
   Entry : Integer;
   Current : Word;
   K : Char;

   Procedure Proc_Entry(Func : Edit_Functions);
   Begin
     Case Entry Of
       1 : Edit_String (Func,17,12,'Emulation Name: ',EMul.Name,30,K);
       2 : Edit_FName  (Func,17,13,'Text Directory: ',EMul.TextDir,32,False,K);
       3 : Edit_YesNo  (Func,17,14,'Use Arrow Bars: ',EMul.AllowBars,K);
       4 : Edit_Integer(Func,17,15,'Minimum Level : ',EMul.MinLevel,5,0,32767,K);
       5 : Edit_Integer(Func,17,16,'Maximum Level : ',EMul.MaxLevel,5,0,32767,K);
       6 : Edit_String (Func,17,17,'Access Flags  : ',EMul.E_Flags,26,K);
       7 : Edit_Byte   (Func,17,18,'Access Number : ',Emul.Identity,3,1,255,K);
     End;
     Select_Next_Entry(Func,Entry,MaxEnt,K);
   End;

Var Total,X : Word;
    Result  : String[3];
Begin
  Color(1,9);
  GrowBOX(15,8,65,19);
  Color(9,15);
  GotoXY(16,10);
  Write('PgUp Next  PgDn Prev. ESC Quit  F10 Abort  F5 New');
  Def_Colors;
  Total := FileSize(EFile);
  Current := 1;
  Start:
  Seek(EFile,Current - 1);
  NRead(EFile,EMul);
  K := PGDN;
  Entry := 0;
  For X:=1 to MaxEnt Do Begin
    Inc(Entry);
    Proc_Entry(Display);
  End;
  Entry := 1;
  Repeat
    Proc_Entry(Edit);
    EMul.E_Flags := UpString(EMul.E_Flags);
  Until (K <> UP) and (K <> DOWN);

  If K <> DispEdit.F10 Then Begin
    Seek(EFile,Current - 1);
    NWrite(EFile,Emul);
  End;

  Case K Of
    DispEdit.PGDN : Begin
      Inc(Current);
      If Current > Total
        Then Current := 1;
      Goto Start;
    End;

    DispEdit.PGUP : Begin
      Dec(Current);
      If Current < 1
        Then Current := Total;
      Goto Start;
    End;

    DispEdit.F5 : Begin
      Result := 'N';
      Ask(9,9,71,15,'úù Create a NEW Record Entry Now? ùú',
                     'Are you sure you want to make another entry? ',3,Result);
      If Upcase(Result[1]) <> 'Y' Then
        Goto Start;
      FillChar(Emul,SizeOf(Emul),0);
      Seek(EFile,Total);
      NWrite(EFile,EMUL);
      Inc(Total);
      Current := Total;
      Goto Start;
    End;

  End;
End;

Procedure Open_Screen;
Begin
  writescr(topscreen);
{  Fill_Screen('²',7,1); }
  GotoXy(1,1); Color(8,15); ClrEOl;
  Center_Write('ViSiON/2 BBS Multiple Text File Directories Setup Utility v1.0á',1);
  GotoXy(1,25); ClrEOL;
  Center_Write('Written by Crimson Blade  (C) 1993 Ruthless Enterprises',25);
  Message('Loading Current Setup',False);
End;

Var K : Char;
Begin
  Open_Screen;
  Read_All;
  Edit_All;
End;         (* Edit_Emulation *)


(********************************************************************)

Procedure Select;
Var
  PEntry : Integer;
  Entry : Integer;
  K : Char;

  Procedure Proc_Entry(Func : Edit_Functions);
  Begin
    Case Entry Of
      1 : Edit_FunKey (Func,21,11,'      Main ViSiON/2 Configuration      ','1',K);
      2 : Edit_FunKey (Func,21,12,'           Protcol Editor              ','2',K);
      3 : Edit_FunKey (Func,21,13,'         Conferences Editor            ','3',K);
      4 : Edit_FunKey (Func,21,14,'        Emulation Set Editor           ','4',K);
      5 : Edit_FunKey (Func,21,15,'            Quit Program               ','Q',K);
    End;
    select_next_entry(func,entry,5,k);
  End;

    procedure def_colors;
    begin
      pcolor    := 16 * 15 + 0;
      normcolor := 16 * 9 + 15;
    end;

Var S : Screens;
Begin
  color(9,15);
  growbox(20,8,60,17);
  color(1,15);
  Center_Write('      ViSiON/2 BBS "The ReVision"      ',9);
  def_colors;
  GotoXy(28,6);
  For Entry := 1 to 5
    Do Proc_Entry(Display);
  Entry := 1;
  ReadScr(s);
  Repeat
    def_colors;
    Repeat
      Proc_Entry(Edit);
    Until (K<>Up) and (K<>Down);
    Case Upcase(K) Of
      '1' : Edit_Main_Config;
      '2' : Protocol_Editor;
      '3' : Edit_Conferences;
      '4' : Edit_Emulation;
      'Q' : K := ESC;
    End;
    If K in ['1'..'4'] Then WriteScr(s);
  Until K = ESC;
  TextAttr := 1;
  Clear_Screen;
End;

procedure start_screen;
begin
  fill_screen('²',7,1);
  gotoxy(1,1);
  color(8,15);
  clreol;
  center_write('ViSiON/2 Bulletin Board Config Program v1.0á',1);
  gotoxy(1,25);
  clreol;
  center_write('Written by Crimson Blade  (c) 1993 Ruthless Enterprises',25);
  ReadScr(TopScreen);
  if not exist('CONFIG.BBS') then
    begin
      message('Creating new config!',false);
      formatconfig;
    end;
  readcfg;
end;

begin
  hi_back_on;
  start_screen;
  select;
  textattr := 15;
  clrscr;
  Writeln('ViSiON/2 BBS Configuration v1.0á');
  Writeln('(c) Ruthless Enterprises 1993');
  hi_back_off;
end.