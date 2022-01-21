{$R-,S-,I-,D-,F-,V-,B-,N-,L+ }

Unit GenTypes;

Interface

Uses Dos;

Const Versionnum = '0.84';
      Version = 'ViSiON/2 vo.84 BETA - Sub-Version: A';
      ThisVersionCode = 69;
      MaxUsers = 30000;
      MaxMessageSize = 100;
      MaxLastCallers = 20;
      MaxTopics = 10;
      Maxcats = 10;
      Maxcatalogsize = 50;
      Maxgroupsize = 50;
      Maxsyslogdat = 125;
      Maxsyslogsize = 1000;

      E_Door = 3;
      E_Controlbreak = 9;
      e_badconfig = 100;
      e_fatalfileerror = 90;

{ All of these are extended keystroke values. }

      Breakoutchar=    0;   {Control-Break}
      Chatchar=        60;  {F1}
      Sysopcomchar=    59;  {F2}
      Vertchatchar=    61;  {F3}
      Linechat=        62;  {F4}
      Sysnextchar=     65;  {F7}
      Timelockchar=    66;  {F8}
      Inlockchar=      67;  {F9}
      Outlockchar=     68;  {F10}
      Printerechochar= 114; {Ctrl-PrtSc}
      Availtogglechar= 30;  {Alt-A}
      Bottomchar=      48;  {Alt-B}
      Gotodoschar=     32;  {Alt-D}
      Texttrapchar=    18;  {Alt-E}
      Hangupchar=      35;  {Alt-H}
      Notimechar=      37;  {Alt-K}
      Lesstimechar=    38;  {Alt-L}
      Moretimechar=    50;  {Alt-M}
      Tempsysopchar=   20;  {Alt-T}
      Linenoisechar=   44;  {Alt-Z}
      Leftarrow=       75;
      Rightarrow=      77;
      Uparrow=         72;
      Downarrow=       80;

Type AnyStr = String[255];
     Lstr   = String[80];
     Mstr   = String[30];
     Sstr   = String[15];

     AutoSig = Array[1..5] Of Lstr;

     AccessType = (bylevel,
                   keepout,
                   letin,
                   invalid);

     Availtype = (available,
                  bytime,
                  notavailable);

     ConfigType = (lowercase,
                   eightycols,
                   linefeeds,
                   postprompts,
                   moreprompts,
                   asciigraphics,
                   ansigraphics,
                   udsysop,
                   bulletinsysop,
                   votingsysop,
                   emailsysop,
                   doorssysop,
                   mainsysop,
                   databasesysop,
                   wanted,
                   hotkeys,
                   showtime,
                   vt52,
                   fseditor,
                   no_net,
                   no_udsec,
                   no_msgsec,
                   no_rumors,
                   no_email,
                   no_chat,
                   no_ul,
                   no_dl,
                   usebars,
                   showrumors,
                   Avatar);

     GroupClass = (publicgroup,
                   privategroup,
                   personalgroup);

     Voteset = Array [1..maxtopics] Of Byte;
     BoardOrder = Array [0..255] of byte;

Type UserRec = Record
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
      TimePerDay : Integer;
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
      AutoSig : LongInt;
     End;

     UserSpecsRec = Record
       Name : mstr;
       MinLevel,
       MaxLevel,
       MinLaston,
       MaxLaston : integer;
       MinPcr,
       MaxPcr : real
     End;

     MailPtrRec = Record
       TextPtr : Longint;
       Deleted : Boolean;
       TotalLines : Integer;
     End;

     BoardRec = Record
       Boardname,
       Sponsor,
       Postflags,
       Areaflags,
       NetName : Mstr;
       Level,
       Plevel,
       Messages,
       Autodel : Integer;
       EchoType,
       Echo : Byte;
       Shortname,
       Address : Sstr;
       Fido_Dir : Lstr;
       UseNet : Boolean;
       LastScan : Longint;
       OriginLine : String[50];
     End;

     BulRec = Record
       Title,
       Leftby,
       Sentto,
       Status,
       Realname : Mstr;
       When,
       Line : Longint;
       Anon,
       Recieved,
       V2_Net,
       FidoNet,
       Scanned : Boolean;
       Plevel,
       Repnumber : Integer;
       Origin1,
       Origin2 : Lstr;
       Replies : Byte;
       Id : Word
     End;

     MailRec = Record
       Title,
       Sentby : Mstr;
       When : Longint;
       Anon,
       Read,
       Return : Boolean;
       SentTo,
       FileIndex : Integer;
       Line : Longint;
     End;

     CataLogRec = Record
       NumMail,
       Additional : Integer;
       Mail : Array [1..maxcatalogsize] of MailRec
     End;

     GroupRec = Record
       Name : Mstr;
       Class : Groupclass;
       Creator,
       NumMembers : Integer;
       Members : Array [1..maxgroupsize] of integer
     End;

     Message = Record
       Text : Array[1..MaxMessageSize] Of Lstr;
       Title,
       SendTo : Mstr;
       Note : Lstr;
       Anon : Boolean;
       NumLines : Integer;
       Add_AutoSig : Boolean;
     End;

     TopicRec = Record
       TopicName : Lstr;
       NumVoted,
       AddLevel : Integer;
       Mandatory : Boolean
     End;

     ChoiceRec = Record
       Choice : Lstr;
       NumVoted : Integer
     End;

     RumorRec = Record
       Title,
       Author,
       Author2 : Mstr;
       Rumor : Lstr;
       When : Longint;
       Level : Integer;
     End;

     LastRec = Record
       Name : Mstr;
       Callnum : Integer;
       When : longint;
       MinsOn : Word;
       Baud : Lstr;
       AC : String[3]
     End;

     BaseRec = Record
       Numcats,
       Numents,
       Level : Integer;
       BaseName : Mstr;
       Catnames : Anystr
     End;

     EntryRec = Record
       Data : Anystr;
       When : Longint;
       AddedBy : Integer
     end;

     ParsedEntry = Array [1..maxcats] of anystr;

     BigDescrip = Array[1..10] Of String[48];

     UDRec = Record             { 1 File per Area }
       FileName : String[12];
       Path     : String[50];
       When     : Longint;
       WhenRated: Longint;
       FileSize : Longint;
       IndexPtr : Word
     End;

     UDIndexRec = Record        { 1 File per Conference }
       Sentby,
       Password,
       Sendto       : Mstr;
       Points       : Integer;
       Descrip      : BigDescrip;
       DownLoaded   : Integer;
       Crash,
       Newfile,
       SpecialFile,
       Return       : Boolean
     End;

     AreaRec = record
       Name,
       XmodemDir : Lstr;
       Flag,
       Upflag,
       Downflag,
       Sponsor,
       Password : Mstr;
       Level,
       TotalUDs : Integer;
       Uploads,
       Downloads : Boolean;
       Leech : Boolean
     End;

     WindowRec = Record
       X1,Y1,
       X2,Y2,
       CX,CY,
       Color : Byte
     End;

     Fib = TextRec;

     DoorRec = Record
       Name      : Mstr;
       Level,
       NumUsed   : Integer;
       Info      : LongInt;
       BatchName : Lstr;
       GetParams,
       Full_Drop : Boolean;
     End;

     MinuteRec = Record
       Started : Boolean;
       StarteDat : Integer;
       Total : Real
     End;

     LogRec = Record
       Menu,
       Subcommand : Integer;
       Param : String[41];
       When : Longint
     end;

     SysLogDatRec = record
       Menu,
       Subcommand : Integer;
       Text : Mstr
     End;

     ProtoRec = Record
       Letter : Char;
       Desc : String[30];
       ProgName : String[12];
       CommFmt : String[60];
     End;

     Newsrec = Record
        Level,
        MaxLevel : Integer;
        Location : LongInt;
        From : Mstr;
        When : Longint;
        Title : String[28];
        Always : Boolean;
      End;

    NuvRec = Record
      Who : Mstr;
      Voters : Array[1..30] of Mstr;
      Comment : Array[1..30] of String[50];
      Votes : Array[1..30] of Boolean;
      TotalVoters : Byte;
      When : Longint;
    End;

    BBSRec = Record
      Name,
      Leftby : Mstr;
      Baud : String[4];
      Phone : String[12];
      Ware : Sstr;
      Extended : Longint;
    End;

     Node_Net_Rec = Record
       Pass,
       Name  : Mstr;
       Phone : String[12];
       Baud  : Word;
       LastDate : Longint;
       Node  : String[10];
       BaseSelection : Array[1..255] Of Boolean;
       Send  : Boolean;
       Conference,
       Dial_Tries,
       Second_Delay,
       Delay_Before_Send : Byte;
     End;

     Node_Rec = Record
       Bul : BulRec;
       NetIdNum : Byte;
       Name : Sstr;
     End;

     NewScanRec = Record
       Name : Mstr;
       LastRead : Array[0..255] of Word;
       NewScanConfig,
       Access1,
       Access2,
       FileNewScan : Set Of Byte;
     End;

     MultiNodeRec = Record
       Name,
       Status : Mstr;
       AC : String[3];
       Baud : String[20];
     End;

     Node_Message = Record
       Message : Lstr;
       Author  : Mstr;
       Receiver: Mstr;
       When    : Longint;
       NodeFrom: Byte;
       NukeNode: Boolean;
     End;

     EmulationRec = Record
       Name       : Mstr;
       TextDir    : Lstr;
       AllowBars  : Boolean;
       MinLevel,
       MaxLevel   : Integer;
       E_Flags    : String[26];
       Identity   : Byte;
     End;

     BatchRec = Record
       Filename : Sstr;
       Path : String[50];
       By : Mstr;
       Points : Integer;
       Mins : Real;
       Size : Longint;
       WholeFileName : Lstr;
       Area,Filenum : Integer;
       Conf : Byte;
     End;

     BatchList = Array[1..1] of BatchRec;

     MenuRec=                               { *.MNU : Menu records }
     Record
       HelpMenu       : String[12];         { tutorial help file }
       Acs            : Mstr;               { access requirements }
       Title          : String[20];         { title of menu }
       Password       : SStr;               { password required }
       File_Name,                           { name of command file }
       FallBack       : String[8];          { fallback menu }
       ForceHelpLevel : Integer;            { forced help level for menu }
       ClrScrBefore,
       UsePrompt      : Boolean;
       Prompt1        : Lstr;
       Prompt2        : Lstr;
       Mes_Conf,
       File_Conf      : Byte;
       Force_HotKey   : Boolean;
     End;

     CommandRec=                            { *.CFG : Command records }
     Record
       Descrip  : Mstr;                     { description of command }
       Keys     : Sstr;                     { key(s) to activate command }
       Command  : Lstr;                     { command-execution keys }
       Acs      : Mstr;                     { access requirements }
       Hidden   : Boolean                   { is command hidden? }
     End;

     CommandArray = Array[1..1] Of CommandRec;

     BaudRateType = (b300,
                     b600,
                     b1200,
                     b2400,
                     b4800,
                     b9600,
                     b19200,
                     b38400,
                     b57600,
                     b115200);

     BaudSet = Set Of BaudRateType;

Const BaudArray : Array [b300..b115200] of Longint =
      (300,
       600,
       1200,
       2400,
       4800,
       9600,
       19200,
       38400,
       57600,
       115200);

      FirstBaud = b300;
      LastBaud  = b57600;

      FilesInBatch : Byte = 0;

      RegSysOp  : Mstr = 'þ';
      RegBBS    : Lstr = 'ú';

Var   ConnectStr : Anystr;
      BatchDown  : ^BatchList;
      Commands   : ^CommandArray;

Implementation

Begin
  Commands := NIL;
End.
