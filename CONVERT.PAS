{$M 65000,0,65000}

{$R-,S-,I-,D-,F-,V-,B-,N-,L+}

Program Conv;

Uses Crt,GenTypes,ConfigRt,General;

Type OldUserrec = Record
      Handle : Mstr;
      Realname : String[40];
      Password : Mstr;
      Phonenum : String[15];
      SysOpNote : String[35];
      PrivateNote : String[50];
      Prompt : Lstr;
      Expires,
      Laston : Longint;
      Timbank,
      Numon,
      Timetoday,
      NUp,
      Ndn,
      Nbu,
      Uploads,
      Downloads : Integer;
      Totaltime : Real;
      Voted : Voteset;
      UDLevel,
      UDPoints,
      Level,
      Beepedpwd : Integer;
      EmailAnnounce : LongInt;
      Infoform : Array[1..5] of LongInt;
      Color1,
      Color2,
      Color3,
      Color4,
      Color5,
      Color6,
      Color7,
      DisplayLen,
      Graphics : Byte;
      Config : Set of Configtype;
      KUp,
      KDown:longint;
      UDKratio,
      UDFratio,
      Pcr,
      MsgLength,
      HackAttempts,
      LastRevision : Integer;
      MsgHdr,
      DefMsgConf,
      DefFileConf : Byte;
      Lastnummsgs,
      Lastnumfiles : Integer;
      FileList : Array [1..9] of Boolean;
      DefProto : Char;
      Flags : String[26]; { A-Z Flags }
      KDownToday : Longint;
      MaxQwk,
      DailyKBLimit : Integer;
      PlayLottery,
      UseDemons : Boolean;
      DemonChance,
      ListType : Byte;
      TimeLock : Boolean;
     End;

Var OldFile : File Of OldUserRec;
    OldRec : OldUserRec;
    NewFile : File Of UserRec;
    NewRec : UserRec;
    Total,Temp,T : Integer;
    K : Char;
    FF : File;

    Begin
     ClrScr;
     Textattr:=15;
     Writeln('ViSiON/2 User Converter.. (Updates Auto-Sig Variables)');
     TextAttr:=7;
     WRiteln;
     Writeln('Only Run This Once.  A Backup called "USERS.OLD" will be created.');
     TextAttr:=9;
     Writeln;
     Write('Do You Wish To Continue? [y/N]: ');
     TextAttr:=14;
     K := ReadKey;
     If Upcase(K) <> 'Y'
     Then Begin
       Writeln('Aborted..');
       Halt(0);
     End Else Writeln('Yes');
     Writeln;
     ReadCfg;
     TextAttr:=13;
     Writeln('Greetings '+Cfg.SysOpName+'!');
     If Exist(Cfg.DataDir + 'USERS.OLD')
     Then Begin
       Assign(FF,Cfg.DataDir + 'USERS.OLD');
       Erase(FF);
     End;
     Assign(OldFile,Cfg.DataDir+'USERS');
     Reset(OldFile);
     If IoResult<>0 then Begin
       Writeln('Where is your USER File?');
       Exit;
     End;
     Rename(OldFile,Cfg.DataDir+'USERS.OLD');
     Total := FileSize(OldFile);
     Close(OldFile);
     TextAttr := 14;
     Writeln;
     Write('Total User Records: ');
     Writeln(Total);
     FillChar(NewRec,SizeOf(NewRec),0);
     Assign(NewFile,Cfg.DataDir+'USERS');
     Rewrite(NewFile);
     Write(NewFile,NewRec);
     Close(NewFile);
     For Temp:=1 to Total Do Begin
       Assign(OldFile,Cfg.DataDir+'USERS.OLD');
       Reset(OldFile);
       Seek(OldFile,Temp-1);
       Read(OldFile,OldRec);
       Close(OldFile);
       Gotoxy(1,15);
       ClrEol;
       TextAttr:=12;
       Write('Converting: '+OldRec.Handle);
       FillChar(NewRec,SizeOf(NewRec),0);
       NewRec.Handle:=OldRec.Handle;
       NewRec.RealName:=OldRec.RealName;
       NewRec.SysOpNote:=OldRec.SysOpNote;
       NewRec.Password:=OldRec.Password;
       NewRec.PhoneNum:=OldRec.PhoneNum;
       NewRec.Level:=OldRec.Level;
       NewRec.Numon:=OldRec.Numon;
       NewRec.NBu:=OldRec.NBu;
       NewRec.UdLevel:=OldRec.UdLevel;
       NewRec.UdPoints:=OldRec.UdPoints;
       NewRec.Uploads:=OldRec.Uploads;
       NewRec.Downloads:=OldRec.Downloads;
       NewRec.PrivateNote:=OldRec.PrivateNote;
       NewRec.PROMPT:=OldRec.Prompt;
       NewRec.Expires:=OldRec.Expires;
       NewRec.Laston:=OldRec.Laston;
       NewRec.TimBank:=OldRec.TimBank;
       NewRec.TimeToday:=OldRec.TimeToday;
       NewRec.TotalTime:=OldRec.Totaltime;
       NewRec.Voted:=OldRec.Voted;
       NewRec.EmailAnnounce:=OldRec.EmailAnnounce;
       For T:=1 to 5 Do NewRec.Infoform[T]:=OldRec.Infoform[T];
       NewRec.Kup:=OldRec.Kup;
       NewRec.KDown:=OldRec.KDown;
       NewRec.UDKratio:=OldRec.UDKRatio;
       NewRec.UDFratio:=OldRec.UDFRatio;
       NewRec.Pcr:=OldRec.Pcr;
       NewRec.msglength:=OldRec.MsgLength;
       NewRec.hackattempts:=OldRec.HackAttempts;
       NewRec.MsgHdr:=OldRec.MsgHdr;
       NewRec.DefMsgConf:=OldRec.DefMsgConf;
       NewRec.DefFileConf:=OldRec.DefFileConf;
       For T:=1 to 9
         Do NewRec.fileList[T]:=OldRec.FileList[T];
       NewRec.LastNumMsgs:=OldRec.LastNumMsgs;
       NewRec.LastNumFiles:=OldRec.LastNumfiles;
       NewRec.DefProto:=OldRec.DefProto;
       NewRec.Flags:=OldRec.Flags;
       NewRec.KDOwnToday:=OldRec.Kdowntoday;
       NewRec.DailyKBLimit:=NewRec.DailyKBLimit;
       NewRec.Color1:=OldRec.Color1;
       NewRec.Color2:=OldRec.Color2;
       NewRec.Color3:=OldRec.Color3;
       NewRec.Color4:=OldRec.Color4;
       NewRec.Color5:=OldRec.Color5;
       NewRec.Color6:=OldRec.Color6;
       NewRec.Color7:=OldRec.Color7;
       NewRec.DisplayLen:=OldRec.DisplayLen;
       NewRec.Config:=OldRec.CONFIG;
       NewRec.PlayLottery := OldRec.PlayLottery;
       NewRec.UseDemons := OldRec.UseDemons;
       NewRec.DemonChance := OldRec.DemonChance;
       NewRec.ListType := 1;
       NewRec.AutoSig := -1;
       Assign(NewFile,Cfg.DataDir+'USERS');
       Reset(NewFile);
       Seek(NewFile,Temp-1);
       Write(NewFile,NewRec);
       Close(NewFile);
     End;
     Gotoxy(1,20);
End.