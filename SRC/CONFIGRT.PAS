{$R-,S-,I-,D-,F+,V-,B-,N-,L+ }

unit configrt;

interface

uses GenTypes, DosMem;

Type ConfigSetType=Record
    Versioncode:byte;
    Longname,
    Shortname,
    Sysopname,
    Visiondir,
    Textdir,
    Uploaddir,
    Boarddir,
    Overlaypath,
    Textfiledir,
    Doordir,
    Datadir,
    ExtractDir,
    MenuDir,
    Modemsetupstr,
    Modemhangupstr,
    OffHookStr:lstr;
    Defbaudrate : Word;
    Boardphone:Sstr;
    Usecom,
    Anonymouslevel,
    NumWelcomes,
    NumStats,
    NumPrelogon,
    Mintimeout,
    Sysoplevel,
    Defudlevel,
    Defudpoints,
    Deflevel,
    defudratio,
    defudkratio,
    defpcr,
    defmsglength,
    defdailykblimit,
    Uploadfactor : Integer;
    DefFlags : String[26];
    Private,
    Autologin,
    Useconmode,
    Escinmsgs,
    Bkspinmsgs,
    Maxdosshell,
    UseEms:boolean;
    Requiredforms:Sstr;
    Nuvform:integer;
    Infoformstr:Array[1..5] of mstr;
    Infoformlvl:Array[1..5] of integer;
    Dotchar:char;
    Barchar,
    RumChar:String[2];
    Supportedrates,
    Downloadrates:baudset;
    Availtime,
    UnAvailtime : sstr;
    Usertime:Array [1..100] of integer;
    level2nd,
    udlevel2nd,
    logonlevel : integer;
    anonymousstr,
    systempassword,
    lowbaudpassword,
    newuserpassword,
    sysopmenupassword,
    dospassword : mstr;
    remotedoors,
    allowdoors:boolean;
    eventtime,
    eventbatch:sstr;
    directvideomode,
    checksnowmode : boolean;
    defcolor1,
    defcolor2,
    defcolor3,
    defcolor4,
    defcolor5,
    defcolor6,
    defcolor7,
    matrixtype:Byte;
    ZipComment,
    ChangeNote : boolean;
    DSZLOG:Lstr;
    ExemptLevel,
    KPerPoint,
    MinFreeSpace:Integer;
    PointCommision,
    TimePercentBack,
    PercentLocal : Byte;
    UseBox,
    FilterQuote,
    UseNuv,
    AutoADDNuv,
    NUVKill,
    NUVvalidate:Boolean;
    BoxChar:Char;
    BoxAbort:Sstr;
    NetName:Mstr;
    NUVY,
    NUVN,
    NuvUseLevel,
    NuvLevel,
    NuvUDLevel,
    NUVPoints:Integer;
    CC:Array[1..8] of Byte;  (* Rotating Chat Color *)
    MaxMsgConf,
    MaxFileConf:Byte;
    HangUpOnNew,
    UseAutoAnswer:Boolean;
    FilePoint,
    FilePoints,
    AutoAnswerStr:Mstr;
    ChatCost : integer;
    ScreenSave:Byte;
    DefBottomline,
    DefTopFive,
    ExtractCost:Byte;
    FidoOrigin:Lstr;
    DefUserNote : Mstr;
    NodeNum : Byte;
    TotalNodes : Byte;
    NodeDir : Lstr;
    LockDTE, Use_One_Liners : Boolean;
    LockRate : Array[2..9] Of Word;
    DefFidoAddress,
    QWKName : SStr;
    MaxQuotedLines : Byte;
End;

Type StringRec = Record
      ConnectionStr,
      LockedBaudStr,
      ApplyAsNewStr,
      GetNupStr,
      ChatRequestStr,
      LeaveFBStr,
      QuoteMessageStr,
      extra2,
      Erase5MsgsStr,
      ChangeBoardStr,
      newscanboardstr,
      extra3,
      extra11,
      PostOnBoardStr,
      MsgTitleStr,
      MsgToStr,
      UploadMsgStr,
      MsgAnonStr,
      SlashStr,
      QuoteTitle,
      NewScanningStr,
      ChangeFileAreaStr,
      LogOffStr,
      ChangeAutoMsgStr,
      NewUserNameStr,
      CreateAPassword,
      Pausestring,
      Whatsyouralias,
      Whatsyourpw,
      Sysopworkingstr,
      Sysopindos,
      SystemPasswordStr,
      Defprompt,
      Enterchat,
      Exitchat,
      QuoteStartLine,
      QuoteEndLine,
      SysOpIsIn,
      SysOpIsOut,
      HeaderStr,
      Infoform_Prompt,
      NewInfoForm_Prompt,
      User_Not_Found,
      Design_New_Prompt,
      Your_Current_Prompt,
      Want_HotKeys,
      Want_Rumors,
      Your_UserNum,
      Welcome_NewUser,
      Enter_Number_Header,
      extra7,
      Enter_Number,
      Enter_UserNote,
      CurFileArea,
      Enter_RealName,
      ReEnter_Password,
      QuoteTop,
      QuoteBottom,
      Ask_One_Liner,
      Enter_One_Liner,
      NewScanDateStr,
      AddBatchPrompt,
      ListUsers,
      ViewArchivePrompt,
      AreaMsgNewScan,
      GetInfoPrompt,
      MsgNewScanPrompt,
      TypeFilePrompt,
      ConfPrompt,
      FileListPrompt,
      UploadFileStr,
      DownloadStr,
      ListRange,
      ContinueStr,
      ViewWhichForm,  {ver o.70á stops here}
      Checking_PhoneNum,
      Checking_User_Base,
      Name_Already_Used,
      Invalid_UserName,
      Sys_PW_Is,
      You_Are_Not_Validated,
      You_Have_Mail,
      Read_Mail_Now,
      Delete_Notice,
      There_Is_Feedback,
      Read_Feedback,
      Login_Now,
      New_Users_Are_Waiting,
      Vote_On_NewUsers,
      AddBBS_Name,
      AddBBS_Number,
      AddBBS_Baud,
      AddBBS_Type,
      AddBBS_Upload,
      View_Extended_BBS,
      Joined_Msg_Conf,
      Joined_File_Conf,
      BBS_Added,
      NUV_Voting_On,
      NUV_Yes_Votes,
      NUV_No_Votes,
      NUV_Comment_Header,
      Enter_NUV_Comment,
      NUV_Vote_Prompt,
      NUV_Yes_Cast,
      NUV_No_Cast,
      No_NUV_Pending,
      Get_Rumor_Title,
      Add_Rumor_Anon,
      Level_To_See_Rumor,
      Enter_Your_Rumor,
      Rumor_Added,
      Get_Rumor_List,
      Carbon_Copy_To,
      Mail_Notify,
      Send_Mail_To_Who,
      Announce_Prompt,
      SysOp_Not_Here,
      Chat_Request_Will_Cost,
      Still_Wanna_Chat,
      No_Chat_No_FP,
      Use_C_to_Stop_Chat,
      Use_C_To_Start_Chat,
      Feedback_Sent,
      U_Have_Read_Mail,
      Delete_Mail_Now,
      Current_Mail_None,
      List_Current_Mail,
      Pick_This_Header,
      Show_Title_Or_Range,
      No_More_Titles_To_List,
      List_Messages_For_You,
      Sub_No_Exist,
      Msg_NewScan_Aborted,
      Msg_NewScan_Prompt,
      Msg_Reading_Prompt,
      Current_Board_NewScan,
      Jump_To_Msg_Number,
      Thread_Which_Way,
      Adding_Msg_Qwk,
      Total_QWK_Sent,
      Sending_QWK_Packet,
      extra8,
      extra9,
      extra10,
      Show_Thread_Which_Way,  {New}
      Auto_Validate_File,
      Value_Of_File,
      Granting_You_FP,
      File_Does_Not_Exist,
      Crashed_File,
      Bad_Baud_Rate,
      Unvalidated_File,
      Special_File,
      No_Downloads_Here,
      Private_File,
      Passworded_File,
      Wrong_Password,
      File_List_Prompt,
      Bad_File_Selection,
      Untagging_File,
      File_NewScan_Prompt,
      File_Extract_Prompt,
      Bad_UD_Ratio,
      Bad_UDK_Ratio,
      Bad_K_Limit,
      Giving_FP_Credit,
      Good_Download,
      Crash_Save_File,
      Invalid_Upload_Name,
      You_Already_Entered_FN,
      File_Already_Online,
      File_Description,
      Extended_File_Setup,
      ReEnter_Descrip,
      Notify_Download,
      Can_Only_Tag_50,
      You_Cannot_Download,
      File_Already_Marked,
      Not_Enough_FP,
      Enter_Area_Password : Lstr;
    End;

Const ConfigFile : SStr = 'CONFIG.BBS';

Var  Cfg   : ConfigSetType;
     Strng : ^StringRec;

Procedure ReadCfg;
Procedure ReadStrings;

implementation

Procedure Readcfg;
Var Q : File of Configsettype;
    I : Integer;

    Procedure RightVer(Name:Sstr);
    Begin
      If cfg.versioncode<>thisversioncode then begin
        Writeln;
        Writeln ('According to the version code in '+Name+', your system was set up using');
        Write   ('ViSiON/2 version 0.');
        Write   (Cfg.versioncode);
        Write   (', the current version is 0.');
        Writeln (thisversioncode);
        Writeln;
        Writeln ('If you do not have a configuration conversion program, you must');
        Writeln ('delete '+Name+' and redo your configuration!');
        Halt (e_badconfig)
      End
    End;

Begin
  FillChar(Cfg,SizeOf(Cfg),0);
  Assign (q,ConfigFile);
  Reset (q);
  i:=ioresult;
  if i=0
    then read (q,cfg)
    else
      begin
        writeln (ConfigFile + ' not found!  Please run CONFIG.EXE to setup ViSiON/2!');
        halt (5)
      end;
  system.close (q);
  RightVer(ConfigFile);
End;

Procedure ReadStrings;
Var S : File of StringRec;
    I : Integer;
Begin

  FillChar(Strng^,SizeOf(Strng^),0);

  Assign(S,'STRINGS.DAT');
  Reset(S);

  I := IOResult;
  If I = 0
     Then Read(S,Strng^)
     Else
       Begin
         Writeln('STRINGS.DAT not found! Please run STRINGS.EXE to configure strings');
         Halt(5);
       End;

  System.Close(S);

End;

End.+