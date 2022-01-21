{$I-}

Program FiX_iT;

Uses Dos,GenTypes;

Type OldUserRec=Record
      Handle:Mstr;
      Realname:String[40];
      Password:Mstr;
      Phonenum:String[15];
      SysOpNote:String[35];
      PrivateNote:String[50];
      Prompt:lstr;
      Expires,
      Laston:Longint;
      Timbank,
      Numon,
      Timetoday,
      nup,
      ndn,
      nbu,
      uploads,
      downloads:integer;
      totaltime:real;
      Voted:voteset;
      udlevel,
      udpoints,
      level,
      beepedpwd:integer;
      emailannounce:LongInt;
      infoform:array[1..5] of LongInt;
      color1,
      color2,
      color3,
      color4,
      color5,
      color6,
      color7,
      displaylen,
      graphics:byte;
      Config:Set of Configtype;
      kup,
      kdown:longint;
      UDKratio,
      UDFratio,
      Pcr,
      msglength,
      hackattempts,
      lastrevision:integer;
      MsgHdr,
      DefMsgConf,
      DefFileConf:Byte;
      Lastnummsgs,
      Lastnumfiles:integer;
      FileList:Array [1..9] of Boolean;
      DefProto:Char;
      Flags:String[26]; { A-Z Flags }
      KDownToday:Longint;
      MaxQwk,
      DailyKBLimit:Integer;
      PlayLottery:Boolean
     End;

Var U : File Of UserRec;
    Trunc : Integer;
Begin
  Assign(U,'USERS');
  Reset(U);
  If IoResult<>0 Then Begin
    Writeln('File ''USERS'' not found..');
    Close(U);
    Exit;
  End;
  Writeln;
  Writeln;
  Writeln('This program truncates the user list...');
  Write('Enter Record # to truncate From : ');
  Readln(Trunc);
  Seek(U,Trunc);
  Truncate(U);
  Close(U);
  Writeln('User List has been truncated..');
End.
