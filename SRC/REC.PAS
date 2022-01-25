{ Cypher Version 1.07 }

Const MaxMessageSize = 200;         (* Total Number of Message Lines   *)
      CBaudS:Array [1..7] of Longint =
        (1200,2400,4800,9600,19200,38400,57600);

Type  BaudRateTyp = (B1200,B2400,B4800,B9600,B19200,B38400,
                     B57600);
      BaudRateSet = Set of BaudRateTyp;
      CCIndex = Record
        Indx:LongInt;
        Len:Word;
      End;

Const BaudRateArr : Array [B1200..B57600] of LongInt =
                    (1200,2400,4800,9600,19200,38400,57600);

(* Cypher BBS Multi-Node *)
      MaxNodes = 10;                (* Maximum # of Cypher Multi-Nodes *)
      MaxSend_Lines = 70;           (* Maximum Node Chat Buffer Lines  *)
      ChatDoneStr = 'IZZZ DONEE';   (* Done with Multi-Node Chat Str   *)
      Browse = 'Browsing';          (* Browsing String                 *)
      Node_Denied = 'REQ DENIED';   (* Request Denied String!          *)

      AnsiModes:Array [0..2] Of String[6] = ('None  ','ANSI  ','Avatar');
      ProtTypes:Array [0..2] of String =
      ('Available','Not Available','Not Batch');
      NetArray : Array[0..3] of String = ('VizNET     ','CelerityNET','FidoNET    ',
                                          'All        ');
      BoardType: Array[0..3] of String = ('Public','Private','Pvt-Pub',
                                          'Read-Only');
      Months_A : Array[1..12] of String[20] = ('January','February','March',
                                               'April','May','June','July',
                                               'August','September','October',
                                               'November','December');
      N_Days   : Array [1..7] of String[10] = ('Sunday',  'Monday',
                                               'Tuesday', 'Wednesday',
                                               'Thursday','Friday',
                                               'Saturday');
Type LStr      = String[80];      { String of 80 Chars }
     DStr      = String[45];      { String of 45 Chars }
     MStr      = String[30];      { String of 30 Chars }
     SStr      = String[15];      { String of 15 Chars }

     AvailType = (Available,Bytime,NotAvailable);
     MsgArray  = Array [1..MaxMessageSize] of Lstr;
     VoteArry  = Array [1..10] of Byte;
     InfoArry  = Array [1..5] of Integer;
     LastArry  = Array [0..40,1..40] of Word;
     Days      = Array [1..7] of Boolean;

     MenuPtr   = ^MenuItem;   { The Prompt is Found in PROMPTS.PRM }
                              { Where it's Like                    }
     MNURec    = Record       { MAIN: Prompt Here                  }
       Task      : Byte;
       ClrScrn,
       AutoRun   : Boolean;
       Extra     : String[20];
       Executer  : Char;
       Level     : Integer;
       Flags     : String[26];
     End;

     MenuItem  = Record
       Menu      : MNURec;
       Next      : MenuPtr;
     End;

     PackedTimeRec = Record
       Date,Time:Word;
     End;

     UserRec = Record
       Handle,MailTo,Note,State,City:Mstr;
       RealName:Lstr;
       Password:Sstr;
       VoiceNum,DataNum:String[14];
       Expiration,Birth:String[8];
       Flags:String[26];
       Level,HiLevel,HiUdr,Calls,Posts,EMail,TimeToday,UdLevel,UdPoints,
       Uploads,Downloads,HackAttempts,LastMessages,LastUps:Integer;
       Downk,Upk,Laston,LastNow:Longint;
       TotalTime:Real;
       Voted:VoteArry;
       RegularColor,PromptColor,StatColor,InputColor,Prompt2Color,
       WindwBordColor,WindwStatColor,WindwMenuColor,SLength:Byte;
       Newuser:Boolean;
       Ansi:Byte;     { 0 = None, 1 = ANSI, 2 = Avatar }
       Clear,FSEditor,MailBox,Expert,HotKey,Block,Cent,Shadow,Lowered,
       UsePlaque,OwnPrompt,Full_Newscan,DeleteAble:Boolean;
       InfoForm:InfoArry;
       LastRead:LastArry;
       YourPrompt:Lstr;
       File_Config_Bits:Byte;  { Bits: 01 = Filename, 02 = Cost,  04 = Size,
                                       08 = Uploader, 16 = Group, 32 = When,
                                       64 = Description }
       CypherVersion:Sstr;
     End;

     Message = Record
       LeftTo,
       LeftBy     : MStr;
       Title      : MStr;
       When       : LongInt;
       Anon,
       Private    : Boolean;
       NumLines   : Integer;
       Text       : MsgArray;
       ContextID  : Word;          { Random Number Between 2..60000 }
     End;


     NUVoteRec = Record
       UserName:MStr;
       YesVote,NoVote,Form:Integer;
       WhoVoted:Array [1..20] of MStr;
     End;

     LevelRec = Record
       Level,Lower,UserTime,Conf,Udr,XPcr,DPcr:Integer;
       Status:Sstr;
       FExp:Boolean;
     End;

     ActionLog_Rec = Record
       Action:Lstr;
       When:Longint;
     End;

     ProtocolRec = Record
       Key:String[1];
       Name,ProtFile:Sstr;
       Upcommand,Downcommand,LogFile:Lstr;
       Status:Integer;
     End;

     MailRec = Record
       Title,SentBy,SentTo:Mstr;
       When:Longint;
       Index:Word;
       Anon,Read:Boolean;
     End;

     AreaRec = Record
       Name,AreaDir:Lstr;
       ASysop,Flags:Mstr;
       Level,Files:Integer;
       FBytes:LongInt;
       Upload,Download,FreeArea:Boolean;
     End;

     UdRec = Record
       FileName:SStr;
       Path:Lstr;
       SentBy,SentTo:Mstr;
       Descrip:Array [1..5] Of DStr;
       DLPass:SStr;
       Group:String[4];
       Points:Integer;
       When,Filesize:Longint;
       NewFile:Boolean;
     End;

     BQueue = ^BatchRec;

     BatchRec = Record
       BR   : UDRec;
       Next : BQueue;
     End;

     MAreaRec = Record
       Name,Sysop:Mstr;
       Level,AutoDel,PostLvl,SysLvl,NetCode,BrdType:Integer;
       Flags,SysFlags:String[26];
       FidoNET_NetNode:SStr;
       Fido_Directory:LStr;
       FidoNetOrigin:String[60];
       EchoNet,RealNames:Boolean;
     End;

     MsgRec = Record
       Title:Lstr;
       Leftby,LeftTo:Mstr;
       When:Longint;
       Anon,Received,Private:Boolean;
       Location:Word;
       PLvl:Integer;
       Id:Word;
       Where1,Where2:Lstr;
     End;

     FRRec = Record              { File Requests Record Structure }
       Entry1:String[40];
       Entry2:String[30];
       When:LongInt;
     End;

     RumorRec = Record
       Rumor:String[78];
       Sentby:Mstr;
       Extra:Lstr;
       Title,DateBy:Sstr;
       Anonr:Boolean;
     End;

     InfoRec = Record
       InfoDescrip:String[38];
       InfoLevel:Integer;
       Forced:Boolean;
     End;

     FBackRec = Record
       Title,SentBy,LeftTo:Mstr;
       When:Longint;
       Location:Word;
     End;

     ConfRec = Record
       Name:Mstr;
       Password:Sstr;
       Level:Integer;
       Flags:String[26];
     End;

     NewsRec = Record
       Level:Integer;
       Location:Word;
       LessPCR,LessUDR:Integer;
       From:Mstr;
       Title:String[28];
       Flags:String[26];
       When:Longint;
       AllRead:Boolean;
     End;

     BBSRec = Record
       Name:String[40];
       Number,Ware:String[12];
       Maxbaud:String[5];
       Leftby:Mstr;
     End;

     TopicRec = record
       TopicName:Lstr;
       Flags:String[26];
       NumVoted,MLev:Integer;
       AllowAdd:Boolean;
     End;

     ChoiceRec = Record
       Choice:Mstr;
       Numvoted:Integer;
     End;

     LastRec = Record
       Name:Mstr;
       CallNum,When:Longint;
       Baud:Sstr;
     End;

     StatRec = Record
       StatInfo:String[60];
       SysopAvail:AvailType;
       LastDayUp:Sstr;
       NumCallers,NumDaysUp,CallsToday,EMails,NewUsers,NewMail,NewFeedBack,
       NewCalls,NewPosts,NewUploads,TotMessages,TotFiles:Word;
       NumMinsIdle,NumMinsUsed,NumMinsXfer:MinuteRec;
       Msgs,Fls,Netted_Today:Integer;
       NetEventDate,DailyEventDate:Sstr;
       More_Events:Array [1..5] of Sstr;
     End;