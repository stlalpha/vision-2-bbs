Program Strings;

{$R-,S+,I-,D+,F-,V-,B-,N-,L+ }
{$M 32000,5000,35000 }

Uses Crt,DOS,
     Scrnunit,ScrnInpt,general,prompts,
     gentypes,configrt,FastTTT5;

Const Normalcolor = 8;
      Boldcolor = 15;
      Barcolor = 95;
      Inputcolor = 31;
      Choicecolor = 15;
      Datacolor = 9;

TYPE ScreenType = array [0..3999] of Byte;
VAR ScreenAddr:ScreenType Absolute $B800:$0000;
    prompt:promptset;
    EraseLine:Boolean;
    Strng : StringRec;

Procedure FormatStrings;
Begin
  FillChar(Strng,SizeOF(Strng),0);
  With Strng Do Begin
    ConnectionStr := '|08þ |15Connect |08(|03|BR|08)';
    LockedBaudStr := '|08þ |15T|07heft |15O|07f |15S|07ervices Active';
    ApplyAsNewStr := '|08A|07p|15ply |08F|07o|15r |08A|07c|15cess? @';
    GetNupStr := '|03[|11NUP|03]|08:';
    ChatRequestStr := '|09Why do you want to |08[|15Chat|08]? :';
    LeaveFBStr := '|09Send |08[|15Feedback|08]|09 to SysOp''s? @';

    QuoteTitle := '|09You are quoting |ST by |FR';
    QuoteMessageStr := '|09Message # to Quote (Cr/|NU) : ';
    QuoteStartLine := '|09Start Quoting @ (1-|EN) : ';
    QuoteEndLine   := '|09End Quoting @ (|ST-|EN) : ';

    { OriginStr1 := '|08þ |15Origin|01: |OR';
      OriginStr2 := '|08þ |15Status|01: |OR'; }


    Erase5MsgsStr := '|14Hold on.. Gotta make some room for your message!';
    ChangeBoardStr := '|07Area Selection |08[|14?|08/|14List |07or |14#|08] : ';
    NewScanBoardStr := '|09Scanning |08[|15|CB|08]...';
    { ViewTTAgainStr := '|05Ä|13Ä|15Ä |09View Top Ten Again? [|15N|09]:'; }
    { MsgNewScanStr := '|09Scan for |08[|15NEW|08]|09 Messages? @'; }
    PostOnBoardStr := '|09Post on |08[|15|CB|08]? @';
    MsgTitleStr := '|08[|15Title|08] : ';
    MsgToStr := '|08[|15To|08   ] : ';
    UploadMsgStr := '|08U|07p|15load |08M|07e|15ssage? @';
    MsgAnonStr := '|08A|07n|15onymous? @';
    SlashStr := '|11S|03ave|08/|11Q|03uote|08/|11A|03bort : ';
    { FileNewScanStr := '|CR|09Scan for |08[|15NEW|08]|09 Files? @'; }
    NewScanningStr := '|09Scanning |08[|15|AN|08]...';
    ChangeFileAreaStr := '|07Area Selection |08[|14?|08/|14List |07or|14 #|08] : ';
    LogOffStr := '|08D|07i|15sembark |08N|07o|15w? @';
    ChangeAutoMsgStr := '|08A|07l|15ter |08A|07u|15to-|08M|07e|15ssage? @';
    NewUserNameStr := '|CR|08E|07n|15ter |08Y|07o|15ur |08A|07l|15ias|09.|CR|08:';
    CreateAPassword := '|08C|07r|15eate A |08P|07a|15ssword |09: ';
    Pausestring := '|15þ|07þ|08þ|B1|09Ý |15Stroke Me! |09Þ|B0|08þ|07þ|15þ';
    Whatsyouralias := '|08E|07n|15ter |08A|07l|15ias |09: ';
    Whatsyourpw := '|08E|07n|15ter |08P|07a|15ssword |09: ';
    Sysopworkingstr := '|15þ|07þ|08þ|B1|09Ý|15Wait, Damn it!|09Þ|B0|08þ|07þ|15þ';
    Sysopindos := '|09[ |15SysOp in DOS |09]';
    SystemPasswordStr := '|08Ä|07Ä|15Ä |09Login Password|01:';
    Defprompt := '|08úù |15|MN |08ùú |13|TL |05Left|08: ';
    Enterchat := '|13Greetings, |05|UH...';
    Exitchat := '|13Back into the BBS...';
    {Origin1 := '|08T|07h|15eft |08O|07f |08S|07e|15rvices |01ú (|09505|01) |09622|01-|096804';
    Origin2 := '|09BL|01i|09TZMail WHQ |01ú|09 ViSiON/2 Home|01 ú |09iCE Member Board';}
    SysOpIsIn := '|09SysOp is |08[|15IN|08]..';
    SysOpIsOut := '|09SysOp is |08[|15OUT|08]...';
    HeaderStr := '|01°|B1|15|HD|B0|01°';
    Infoform_Prompt := '|08I|07n|15foForms|09 þ |01(|09V|01)iew (|09Q|01)uit or |09#|08: ';
    NewInfoForm_Prompt := '|08N|07e|15wuser |08F|07o|15rms |09þ |01(|09Q|01)uit or |09#|08: ';
    User_Not_Found := '|08U|07n|15known |08U|07s|15er! |08A|07p|15ply? @';
    Design_New_Prompt := '|09Re|01-|09Design Prompt|01? @';
    Your_Current_Prompt := '|08Y|07o|15ur |08C|07u|15rrent |08P|07r|15ompt |08i|07s|15...|CR';
    Want_HotKeys := '|08U|07s|15e |08H|07o|15t |08K|07e|15ys? @';
    Want_Rumors := '|08S|07h|15ow |08R|07u|15mors? @';
    Your_UserNum := '|04Y|12o|14ur |04U|12s|14er |09# |04i|12s |15|UN|CR';
    Welcome_NewUser := '|04W|12e|14lcome |04T|12o |04T|08.|12O|08.|14S|08!';
    Enter_Number_Header := '|09Form|01: |09505|01-|09622-6804 |10þ |09Int|01''|09l start with "|15+|09"';
    {SkipStats := '|08[|15CR|08]|09 Continue; |08[|15S|08] |09Skips..';}
    Enter_Number := '|08P|07h|15one |08N|07u|15mber |09: ';
    Enter_UserNote := '|08D|07e|15sired |08U|07s|15er |08N|07o|15te |09: ';
    CurFileArea := '|09Current Area |08[|15|CA|08]';
    Enter_RealName := '|08E|07n|15ter |08Y|07o|15ur |09REAL |08N|07a|15me |09: ';
    ReEnter_Password := '|08R|07e|15nter |08P|07a|15ssword |09: ';
    QuoteTop := '|08úÄÄ |15^N |07Said |08ÄÄú';
    QuoteBottom := '|08úÄÄ |15^N |07Done |08ÄÄú|15';
    Ask_One_Liner := '|05Ä|13Ä|15Ä |09Enter a One-Liner? [|08N|09]|01: ';
    Enter_One_Liner := '|09Enter your |01One|09-|01Liner|09 Now! (|10Blank|02/|10Aborts|09)|CR|08:';
    NewScanDateStr := '|11S|03can |11D|03ate? |08(|11Cr|03/|11|NS|08) : ';
    AddBatchPrompt := '|15Add to |08[|09Batch|08] (|09Cr/|DE|08): ';
    ListUsers := '|11A|03lphabetical |09/ |11N|03umerical |09: ';
    ViewArchivePrompt := '|15ZIP File(s) to |08[|09View|08] (|09Cr/|DE|08): ';
    AreaMsgNewScan := '$cScanning $A[$W|CB$w/$W|NB$A] $CS$ckip $CP$cost $CQ$cuit $CN$conStop: ';
    GetInfoPrompt := '|15File(s) to get |08[|09Info|08] |15On |08(|09Cr/|DE|08): ';
    MsgNewScanPrompt := '';
    TypeFilePrompt := '|15File(s) to |08[|09Type|08] (|09Cr/|DE|08): ';
    ConfPrompt := '|@ 25|13Conferences |05[|15?|08/|15List |07or |15Cr|08/|15|DE|05] :';
    FileListPrompt := '';
    UploadFileStr := '|05File Name |08[|13|NU|08] |09: ';
    DownloadStr := '|05File(s) Download - |13e(|14X|13)it, (|14A|13)dd, (|14Cr|13) Continue |09:';
    ListRange := '|05Ä|13Ä|15Ä |09|ST |08[|15|SR|07-|15|ER |08or |15Cr|07/|15All|08]: ';
    ContinueStr := '|09[|15More?|09] |07(|15Y,n,s|07) :';
    ViewWhichForm := '|09View which |08F|07o|15rm? (|07#|15) |09:';
    Checking_PhoneNum := '|08þ |15Checking Ratio, Local vs. LD, |08(|15One Sec|08)..';
    Checking_User_Base := '|08þ |05Fi|13nding |05A |05Pl|13ace |05Fo|13r |05Y|13ou!';
    Name_Already_Used := '|15þ |13Name is already in use! |15þ';
    Invalid_UserName := '|05þ |10Invalid Name .. Try again!';
    Sys_PW_Is := '|04T|12O|14S |15System PW|05: |13|PW';
    You_Are_Not_Validated := '|15Your access is too |04L|12O|14W|15!..';
    You_Have_Mail := '|08M|07a|15il |08W|07a|15iting|05: |13|MA |05piece(s)';
    Read_Mail_Now := '|08R|07e|15ad |08i|07t |08n|07o|15w? @';
    Delete_Notice := '|CR|08N|07u|15ke |08N|07o|15tices? @';
    There_Is_Feedback := '|08F|07e|15edback |08W|07a|15iting|05: |13|FB|05..';
    Read_Feedback := '|08R|07e|15ad |08i|07t |08n|07o|15w? @';
    Login_Now := '|13Jump onto |04T|08.|12O|08.|14S |13now? @';
    New_Users_Are_Waiting := '$AY$wo$Wu $Ah$wa$Wve $GNOT $Av$wo$Wted $Ao$wn $Y|NE |08N|07e|15w |08U|07s|15ers.';
    Vote_On_NewUsers := '|08V|07o|15te |08N|07o|15w? @';
    AddBBS_Name := '|08B|07B|15S |13Name|05: ';
    AddBBS_Number := '|08B|07B|15S |13Number|05: ';
    AddBBS_Baud := '|08H|07i|15ghest |13BPS|05: ';
    AddBBS_Type := '|08B|07B|15S |13Software|05: ';
    AddBBS_Upload := '|08U|07p|15load |08E|07x|15tended |08D|07e|15scription? @';
    View_Extended_BBS := '|08V|07i|15ew |08N|07e|15xt? @';
    Joined_Msg_Conf := '|05(|13|NA|05) |08C|07o|15nference |08J|07o|15ined!';
    Joined_File_Conf := '|05(|13|NA|05) |08C|07o|15nference |08J|07o|15ined!';
    BBS_Added := '|08ù|02ù|10ù |15Your Entry has been added!';
    NUV_Voting_On := '|08U|07s|15er |08N|07a|15me|09: |15|NA';
    NUV_Yes_Votes := '|08Y|07e|15s |08V|07o|15tes|09: |15|YV  |09(|13Required|01: |0510 Votes|09)';
    NUV_No_Votes := '|08N|07o |08V|07o|15tes|09 :|15 |NV  |09(|13Deletion|01:|05 10 Votes|09)';
    NUV_Comment_Header := '|08C|07o|15mments |08S|07o |08F|07a|15r|09...|CR';
    Enter_NUV_Comment := '|08E|07n|15ter |08a C|07o|15mment |08o|07n |15|NA $B($bCr$B/$bAborts$B)|CR$A:';
    NUV_Vote_Prompt := '|09New User Voting |01- |09(|10?|02/|10Help|09): ';
    NUV_Yes_Cast := '|04Y|12e|14s |09Vote Cast!';
    NUV_No_Cast := '|04N|12a|14h |09Vote Cast!';
    No_NUV_Pending := '|04N|12o |10NEW |04u|12s|14ers |04r|12i|14ght |04n|12o|14w!';
    Get_Rumor_Title := '|05R|13u|14mor |05T|13i|14tle|08 : ';
    Add_Rumor_Anon := '|05A|13n|14onymous? @';
    Level_To_See_Rumor := '|05M|13i|14nimum |05L|13e|14vel|08 :';
    Enter_Your_Rumor := '|05E|13n|14ter |05R|13u|14mor |08(|15Cr|07/|15Abort|08)|CR:';
    Rumor_Added := '|04R|12u|14mor |04h|12a|14s |04b|12e|14en |04a|12d|14ded!';
    Get_Rumor_List := '|09Valid Commands|01: |15R|07umors, |15S|07tats, |15B|07oth :';
    Carbon_Copy_To := '$AC$wa$Wrbon $AC$wo$Wpy $At$wo? $A($BCr$b/$BNone$A) $B: ';
    Mail_Notify := '$AR$we$Wturn $AR$we$Wceipt? @';
    Send_Mail_To_Who := '$AS$we$Wnd $AM$wa$Wil $At$wo? $B:';
    Announce_Prompt := '|09[|15C|09]reate/change ù [|15D|09]elete ù [|10Q|09]uit :';
    SysOp_Not_Here := '$AC$wr$Wimmy $Ai$ws $rB$Ri$Yz-E|08!|CR';
    Chat_Request_Will_Cost := '|09Chat Request costs |15|CC |09file points!';
    Still_Wanna_Chat := '|09Still want to |08C|07h|15at? @';
    No_Chat_No_FP := '|15Haha.. you are too poor!';
    Use_C_to_Stop_Chat := '|08[|15C|08] |14Turns chat page OFF|08.';
    Use_C_To_Start_Chat := '|08[|15C|08] |14Turns chat page ON|08.';
    Feedback_Sent := '|01F|09e|15edba|09c|01k |01S|09e|15n|09t|01!';
    U_Have_Read_Mail := '|08Y|07o|15u |08h|07a|15ve |08r|07e|15ad |14|TI |08b|07y |14|SB|08.';
    Delete_Mail_Now := '|08N|07u|15ke |08i|07t |08n|07o|15w? @';
    Current_Mail_None := '|08C|07u|15rrent |08M|07a|15il: |10None';
    List_Current_Mail := '|08C|07u|15rrent |08M|07a|15il: |09|TI |01by |09|AU';
    Pick_This_Header := '|08P|07i|15ck |08t|07h|15is |08h|07e|15ader? @';
    Show_Title_Or_Range := '|09List Type |08(|15R|08)|07ange, |08(|15N|08)|07ext : ';
    No_More_Titles_To_List := '|10Nore more titles!';
    List_Messages_For_You := '|09Only list messages directed at you? @';
    Sub_No_Exist := 'Invalid Sub-Board!';
    Msg_NewScan_Aborted := '|04N|12e|14wscan |04A|12b|14orted!';
    Msg_NewScan_Prompt := '|09New Scanning |01(|13|BN|01) [|13|CB|05/|13|NB|01]|08: ';
    Msg_Reading_Prompt := '|09Reading |01(|13|BN|01) [|13|CB|05/|13|NB|01]|08: ';
    Current_Board_NewScan := '|09Current |01(|13|BN|01)...';
    Jump_To_Msg_Number := '|09Jump to message # |01(|131|05/|13|NB|01) : ';
    Thread_Which_Way := '|09Message Threading, |08[|15F|08]|09orward or |08[|15B|08]|09ackwards : ';
    Adding_Msg_Qwk := '|09Posting Message on |01(|13|BN|01)';
    Total_QWK_Sent := '|09Total Processed|08: |15|TO';
    Sending_QWK_Packet := '|08[|15Cr|08] |09Send QWK Packet, |08[|15Q|08]|09uits : ';
    {Quick_Login := '|08J|07a|15mm''n |04F|12a|14st |08L|07o|15gin? @';}
    {You_Won_FP_Lot := '|09You won playing file point lottery!';
    You_LOST_FP_Lot := '|04S|12o|14rry, |15You lost at file point lottery!';}
    Show_Thread_Which_Way := '|09Thread - [F]oreward or [B]ackwards : ';
    Auto_Validate_File := '|05A|13u|15to-|05V|13a|15lidating |05(|15|FN|05)';
    Value_Of_File := '|05F|13i|15le |05V|13a|15lue|07: |14|FP Point(s)';
    Granting_You_FP := '|05G|13r|15anting |05Y|13o|15u |14|FP |05f|13i|15le |05p|13o|15int(s)!';
    File_Does_Not_Exist := '|09That file is |05(|13Offline|05)..';
    Crashed_File := '|09That file is not yet complete!';
    Bad_Baud_Rate := '|09Your baud rate is to |04L|12o|14w!';
    Unvalidated_File := '|09That file is not yet |05(|13Validated|05)..';
    Special_File := '|09You must have permission to download this file!';
    No_Downloads_Here := '|09No |05(|13Downloads|05) |09here!';
    Private_File := '|09That file is not for |04Y|12o|14u!';
    Passworded_File := '|09Enter File Password|CR|08:';
    Wrong_Password := '|04W|12r|15ong |04P|12a|15ssword!';
    File_List_Prompt := '|05F|13i|15le |05L|13i|15st ù |13|AN |15ù |05(|13?|05/|34Help|05): ';
    Bad_File_Selection := '|04I|12n|14valid |04A|12r|14ea!';
    Untagging_File := '|05De-Tagging|13: |15|FN';
    File_NewScan_Prompt := '|05N|13e|15w |05S|13c|15anning ù |13|AN|15 ù |05(|13?|05/|15Help|05): ';
    File_Extract_Prompt := '|09File Extract - |08[|15A|08]|09dd to Batch, |08[|15Q|08]|09uit :';
    Bad_UD_Ratio := '|09Bad UD Ratio (|15|RA%|09) - Needed (|15|RR%|09)';
    Bad_UDK_Ratio := '|09Bad UD K Ratio (|15|RA%|09) - Required (|15|RR%|09)';
    Bad_K_Limit := '|09Adding this exceeds your DL ''K'' Limit of (|15|KL|09)';
    Giving_FP_Credit := '|09Giving |13|NA|09 a commision of |14|FP|09 point(s)!';
    Good_Download := '|05S|13u|07c|15cess! |05(|13|FN|05) CPS: |15|CP |05Cost: |15|CO';
    Crash_Save_File := '|09File Crash! Save Partial File? @';
    Invalid_Upload_Name := '|04I|12n|14valid |04F|12i|14lename!';
    You_Already_Entered_FN := '|09You already entered that!';
    File_Already_Online := '|09File exists in current directory!';
    File_Description := '|05D|13e|07s|15cription|07: ';
    Extended_File_Setup := '|05S|13e|15tup ù |05(|13A|05)dd PW, (|13P|05)rivate, or (|13Cr|05) : ';
    ReEnter_Descrip := '|05D|13e|07s|15cription of |05(|13|FN|05): ';
    Notify_Download := '|05N|13o|15tify |05y|13o|15u |05w|13h|15en |FN |05i|13s |05l|13e|15eched? @';
    Can_Only_Tag_50 := '|04You can only tag up to 50 files!';
    You_Cannot_Download := '|04You can''t download here!';
    File_Already_Marked := '|09File is already marked!';
    Not_Enough_FP := '|04N|12o|15t |04e|12n|15ough |04f|12i|15le |04p|12o|15ints!';
    Enter_Area_Password := '|04A|12r|15ea |04P|12a|15ssword|08: ';
  End
End;

procedure WriteStrings;
var q:File of StringRec;
begin
  assign (q,'STRINGS.DAT');
  rewrite (q);
  write (q,strng);
  close (q)
end;

procedure Cursor(A:Byte);
  var regs:registers;
      y,z:byte;
  BEGIN
  If a=0 then begin y:=32; z:=0; end;
  If a=1 then begin y:=6; z:=7; end;
  If a=2 then begin y:=6; z:=1; end;
    Regs.AH :=1;
    Regs.CH :=y;
    Regs.CL :=z;
    intr ($10,Regs);
  END;

type ttypetype=(TInteger,Tsstr,Tmstr,Tlstr,TBoolean,TChar,TBaudset,
                TPath,TTime,TAttrib,Tusertime,TWord,Badtype);
     ptrset=record
       case integer of
         0:(i:^integer);
         1:(l:^lstr);
         2:(b:^boolean);
         3:(k:^char);
         4:(baudsetptr:^baudset)
     end;
     thing=record
       text:mstr;
       descrip:lstr;
       ttype:ttypetype;
       p:pointer;
       r1,r2:integer
     end;

const ttypestr:array [ttypetype] of sstr=
  ('Int','sstr','mstr','lstr','Boo','Char','Baud','Path','Time',
   'Attrib','Usertime','Word','!!!!????');

const maxthings=200;
      dcol=30;

var top,bot,page,numpages,numthings:integer;
    things:array [1..maxthings] of thing;

procedure cb;
begin
  setcolor (boldcolor)
end;

procedure c4;
begin
  setcolor (4)
end;

procedure cn;
begin
  setcolor (normalcolor)
end;

procedure c7;
begin
  setcolor (7)
end;

function match(a1,a2:anystr):boolean;
var cnt:integer;
begin
  match:=false;
  while a1[length(a1)]=' ' do a1[0]:=pred(a1[0]);
  while a2[length(a2)]=' ' do a2[0]:=pred(a2[0]);
  if length(a1)<>length(a2) then exit;
  for cnt:=1 to length(a1) do
    if upcase(a1[cnt])<>upcase(a2[cnt]) then exit;
  match:=true
end;

function whichpage (n:integer):integer;
begin
  whichpage:=((n-1) div 20)+1
end;

function whichline (n:integer):integer;
begin
  whichline:=n-20*(whichpage(n)-1)+2
end;

function varstr (n:integer):string;
var pu:pointer;
    p:ptrset absolute pu;
begin
  pu:=things[n].p;
  VarStr:=P.L^;
end;

procedure writevar (n:integer);
VAR short:string[50];

  Procedure WriteColor(S:AnyStr);
  VAR I:Byte;
      A:String[2];
      Fore, Back : Byte;

      Procedure Set_C(F,B : Byte);
      Begin
        If F > 15
          Then F := 15;
        Fore := F;
        Back := B;
        SetColor(16 * B + F);
      End;

  Begin
    I:=1;
    Fore := 9;
    Back := 0;
    TextAttr := 9;
    While (I<=Length(S)) and (WhereX<77)
    Do Begin
    If S[ i ] = '$' then Begin
      Case S[i+1] Of
        'a':Set_C(0,Back);
        'b':Set_C(1,Back);
        'g':Set_C(2,Back);
        'c':Set_C(3,Back);
        'r':Set_C(4,Back);
        'p':Set_C(5,Back);
        'y':Set_C(6,Back);
        'w':Set_C(7,Back);
        'A':Set_C(8,Back);
        'B':set_c(9,Back);
        'G':set_c(10,Back);
        'C':set_c(11,Back);
        'R':set_c(12,Back);
        'P':set_c(13,Back);
        'Y':set_c(14,Back);
        'W':set_c(15,Back);
        Else Write('$' + S[i + 1]);
      End;
      Inc(i);
    End Else If S[i] = '|'
    Then Begin
      A := S[i+1] + S[i+2];
      If (A[1] = 'B') And (A[2] in ['0'..'7'])
        Then Set_C(Fore,Valu(A[2])) Else
      If A = 'C1' then Set_C(cfg.DefColor1,0) Else
      If A = 'C2' then Set_C(cfg.DefColor2,0) Else
      If A = 'C3' then Set_C(cfg.DefColor3,0) Else
      If A = 'C4' then Set_C(cfg.DefColor4,0) Else
      If A = 'C5' then Set_C(cfg.DefColor5,0) Else
      If A = 'C6' then Set_C(cfg.DefColor6,0) Else
      If A = 'C6' then Set_C(cfg.DefColor7,0) Else
      If Valu(A) > 0 then Set_C(Valu(A),Back) Else
      Write('|'+A);
      Inc(i,2);
    End
      Else Write(S[i]);
    Inc(i);
   End;
   If i<=Length(S) Then Begin
     SetColor(143);
     Write(' ');
   End;
 End;

Begin
  cb;
  WriteColor (varstr(n));
  cn;
  clreol;
  writeln
end;

procedure gotopage (p:integer);
var cnt,cy:integer;
begin
  if p<1 then p:=1;
  if p>numpages then p:=numpages;
  if p<>page then begin
    if page<>0 then freeprompts (prompt);
    page:=p;
    SetColor(16);
    Gotoxy(1,1);
    ClrEOL;
    GotoXy(1,1);
    SetColor(25); Write(' Current Topic Number:');
    top:=(page-1)*20+1;
    SetColor(31); Write(' '+strr(top));
    GotoXy(28,1); SetColor(16); Write('³');
    SetColor(25); Write(' ViSiON/2 BBS String Configuration');
    SetColor(16); Write(' ³');
    SetColor(27); Write(' Current Page:');
    SetColor(31); Write(' '+strr(page));
    SetColor(normalcolor);
    GotoXY(1,2); Clreol; SetColor(15);
    GotoXy(1,24); ClrEOL; writecenter(24,13,0,things[top].descrip);
    bot:=top+19;
    if bot>numthings then bot:=numthings;
    SetColor(8);
    beginprompts (prompt);
    SetColor(normalcolor);
    for cnt:=top to top+19 do begin
      cy:=cnt-top+3;
      gotoxy (1,cy);
      cn; clreol;
      if cnt<=bot then begin
        Gotoxy(1,cy);
        SetColor(8);
        Write('[');
        addprompt (prompt,command,prompt,2,cnt-top+3,things[cnt].text);
        setinputwid (prompt,0);
        drawprompt (prompt);
        gotoxy (Dcol-2,cy);
        SetColor(8); write (']');
        gotoxy (dcol,wherey);
        writevar (cnt)
      end
    end
  end
end;

procedure readdata;
var t:mstr;
    x:Byte;

  procedure dataerror (n:lstr);
  begin
    writeln ('Record ',numthings,': '+n);
    halt
  end;

  procedure illtype;
  begin
    dataerror ('Invalid type: '+t)
  end;

begin
Things[1].text:='Default User''s Prompt';
 Things[1].descrip:='This is the Default prompt for new users';

Things[2].Text:='System Pause String';
 Things[2].Descrip:='This is displayed anytime the screen pauses awaiting a key to be pressed';

Things[3].Text:='System Password String';
 Things[3].Descrip:='This is displayed when asking the login password (if no SYSPASS.ANS)';

Things[4].Text:='Enter Alias String';
 Things[4].Descrip:='This is displayed when asking a user''s alias (if ALIAS.ANS isn''t in use)';

Things[5].Text:='Enter Password String';
 Things[5].Descrip:='This is displayed when asking a user''s password (if PASSWORD.ANS isn''t used)';

Things[6].Text:='SysOp Working String';
 Things[6].Descrip:='This is displayed when the SysOp hits [F2] while a user is online';

Things[7].Text:='Enter Chat String';
 Things[7].Descrip:='This is displayed when the sysop hits F2,F3,F4 to enter chat';

Things[8].Text:='Exit Chat String';
 Things[8].Descrip:='This is displayed when the sysop exits out of chat';

Things[9].Text:='SysOp In Dos String';
 Things[9].Descrip:='This is displayed to the user online when you Shell to DOS';

Things[10].Text:='Quote Starting Line';
 Things[10].Descrip:='When asking Start Line to Quote |ST=Start Line |EN=Max Lines';

Things[11].Text:='Quote End Line';
 Things[11].Descrip:='When asking End line to Quote |ST=Start Line |EN=Max Line';

Things[12].Text:='Connect String';
 Things[12].Descrip:='This is the modem connect string displayed to user (|BR = Baud Rate)';

Things[13].Text:='Locked Baud String';
 Things[13].Descrip:='This string is displayed after the connect string if the baud is locked';

Things[14].Text:='Apply as New String';
 Things[14].Descrip:='Displayed when asking a new user if he wished to apply (@ = Yes/No Bar)';

Things[15].Text:='New User Pw Prompt';
 Things[15].Descrip:='This is the prompt displayed before a new user enters the NUP (If Any..)';

Things[16].Text:='Request Chat Prompt';
 Things[16].Descrip:='This prompt is displayed when a user requests chat (If CHAT.ANS not used)';

Things[17].Text:='Leave Feedback Prompt';
 Things[17].Descrip:='This prompt is displayed when a user want to leave Feedback (@=Yes/No Bar)';

Things[18].Text:='Quoting Title';
 Things[18].Descrip:='Displayed when quoting a message  |TI=Title |FR=From';

Things[19].Text:='Quote which message prompt';
 Things[19].Descrip:='Prompt for quoting which message |NU=Default Number';

Things[20].Text:='Erasing 5 Msgs Prompt';
 Things[20].Descrip:='This is displayed when clearing 5 post out of a message base to create room';

Things[21].Text:='Change Sub-Board Prompt';
 Things[21].Descrip:='This is used when a user hits ''A''/''*'' to change areas in the Msg. Base';

Things[22].Text:='NewScanning Board String';
 Things[22].Descrip:='This is displayed for each Sub-Board that is newscanned (|CB = Current Board)';

Things[23].Text:='Not Used';
 Things[23].Descrip:='';

Things[24].Text:='Not Used';
 Things[24].Descrip:='';

Things[25].Text:='Post on Current Board';
 Things[25].Descrip:='Used when asking if a user wants to leave a Post ( |CB=Current Board )';

Things[26].Text:='Message Title String';
 Things[26].Descrip:='This is displayed when a user is asked what he wishes to title a message';

Things[27].Text:='Send Message To String';
 Things[27].Descrip:='This is displayed when a user is asked who he wishes to send the msg to';

Things[28].Text:='Upload a Message String';
 Things[28].Descrip:='This is displayed when asking a user if he wishes to upload a messages';

Things[29].Text:='Post Anonymous String';
 Things[29].Descrip:='This is displayed when asking a user if he wished to post Anonymous';

Things[30].Text:='Ansi Editor Help String';
 Things[30].Descrip:='This String is displayed when a user hits ''/'' in the ansi editor';

Things[31].Text:='Not Used';
 Things[31].Descrip:='';

Things[32].Text:='NewScanning Current Area';
 Things[32].Descrip:='This is displayed for each file area that is newscanned (|AN = Area Name)';

Things[33].Text:='File Area Change';
 Things[33].Descrip:='This is the prompt that is displayed when asking a user what area to change to';

Things[34].Text:='Log Off String';
  Things[34].Descrip:='Displayed when user hit [G] to Logoff (If LOGOFF.ANS is not used)';

Things[35].Text:='Change Auto Message?';
  Things[35].Descrip:='Displayed when asking if user wishes to change auto-message';

Things[36].Text:='New User Handle';
 Things[36].Descrip:='This is displayed when asking a New User''s Handle';

Things[37].Text:='New User Password';
 Things[37].Descrip:='This is diplayed when asking a New User to specify a password';

Things[38].Text:='SysOp is IN String';
 Things[38].Descrip:='Displayed at login if you are available for chat';

Things[39].Text:='SysOp is OUT String';
 Things[39].Descrip:='Displayed at login if you are not available for chat';

Things[40].Text:='One Line Header';
 Things[40].Descrip:='This is the One-Line Header displayed all over.. |HD = String';

things[41].Text:='Skip Status String';
 things[41].Descrip:='Displayed upon logon, [S] is the key that skips stats';

Things[42].Text:='Current File Area';
 things[42].Descrip:='Displays current file area user is in';

Things[43].Text:='Quoting Top Line';
 Things[43].Descrip:='Quoted Section (Top); ^N=Author ^T=Title ^F=Who To ^D=Date ^W=Time';

Things[44].Text:='Quoting Bottom Line';
 Things[44].Descrip:='Quoted Section (Bottom); ^N=Author ^T=Title ^F=Who To ^D=Date ^W=Time';

Things[45].Text:='NewScan From What Date';
 Things[45].Descrip:='Displayed when asking NewScan Date; |NS = User''s Last NewScan';

Things[46].Text := 'Add Batch Prompt';
 Things[46].Descrip := 'Displayed when asking for a range to add to batch';

Things[47].Text := 'View Archive Prompt';
 Things[47].Descrip := 'Displayed when asking for a range of files to view';

Things[48].Text := 'Get File Info Prompt';
 Things[48].Descrip := 'Displayed when asking for a range of files to get info on';

Things[49].Text := 'Type a Text File Prompt';
 Things[49].Descrip := 'Displayed when asking for a range of files to type';

Things[50].Text := 'Upload File Prompt';
 Things[50].Descrip := '|NU = Current File Number; Asked for each file user enters to upload';

Things[51].Text := 'Download Files Now Prompt';
 Things[51].Descrip := 'Valid Commands are e[X]it, [Cr] Continue; [A]dd More Files';

Things[52].Text := 'Listing Range Prompt';
 Things[52].Descrip := '|ST List String |SR = Start Range |ER = End Range';

Things[53].Text := 'Continue List String';
 Things[53].Descrip := 'Displayed when page is full; [Y]es [N]o or Non-[S]top';

Things[54].Text := 'Conference Prompt';
 Things[54].Descrip := 'Displayed when selecting conference, |DE = Defualt Selection';

Things[55].Text := 'Area NewScan Prompt';
  Things[55].Descrip := '|CB=Current Bul |NB=Total Buls, Commands: [P]ost [S]kip [Q]uit [N]onStop';

Things[56].Text := 'List Users Prompt';
  Things[56].Descrip := 'Displayed when asking (A)lphabetical / (N)umerical';

Things[57].Text := 'Ask One-Liner';
  Things[57].Descrip := 'Asks user if he wished to enter a one-liner after displayed';

Things[58].Text := 'Enter Your One-Liner';
  Things[58].Descrip := 'Displayed when user enters a One-Liner';

Things[59].Text := 'Re-Enter PW Prompt';
  Things[59].Descrip := 'When prompting to re-enter a user password';

Things[60].Text := 'Enter Real Name Prompt';
  Things[60].Descrip := 'When prompting for a user''s real name';

Things[61].Text := 'Enter User Note';
  Things[61].Descrip := 'When prompting for a User Note';

Things[62].Text := 'Enter Phone Number';
  Things[62].Descrip := 'When prompting for User Phone Number';

Things[63].Text := 'Enter Number Header';
  Things[63].Descrip := 'Displayed above "Enter Phone Number" Prompt';

Things[64].Text := 'New User Welcome';
  Things[64].Descrip := 'Displayed to New Users before User Number';

Things[65].Text := 'Your User Number';
  Things[65].Descrip := 'When giving user his User Number (|UN = User Number)';

Things[66].Text := 'New User Current Prompt';
  Things[66].Descrip := 'Displayed to new users before displaying their prompt';

Things[67].Text := 'Create new Prompt?';
  Things[67].Descrip := 'Displayed when asking if new user wants to re-configure his prompt';

Things[68].Text := 'Use Hot Keys?';
  Things[68].Descrip := 'Displayed when asking if user wishes to use hotkeys';

Things[69].Text := 'Show Rumors?';
  Things[69].Descrip := 'Displayed when asking if user wished to see rumors';

Things[70].Text := 'Unkown User, Apply?';
  Things[70].Descrip := 'Asks unknown users if they wish to apply..';

Things[71].Text := 'Infoforms Prompt';
  Things[71].Descrip := 'Infoforms Prompt (V)iew, (Q)uit or (#)';

Things[72].Text := 'NewUser Infoforms Prompt';
  Things[72].Descrip := 'NewUser Infoforms Prompt, (Q)uit or (#)';

Things[73].Text := 'View which Infoform';
  Things[73].Descrip := 'Displayed when a user (V)iews his infoform';

Things[74].Text := 'Checking Local Ratio';
  Things[74].Descrip := 'Displayed when checking local ratio';

Things[75].Text := 'Checking User Database';
  Things[75].Descrip := 'Displayed when finding a place for new users';

Things[76].Text := 'Sorry, Name is already used';
  Things[76].Descrip := 'Displayed when a newuser enters a name already in use';

Things[77].Text := 'Invalid Name';
  Things[77].Descrip := 'Displayed if new user enters an invalid name';

Things[78].Text := 'System Password Is...';
  Things[78].Descrip := '|PW = System Password; Displayed when checking for System PW';

Things[79].Text := 'System PW Access to Low';
  Things[79].Descrip := 'Displayed when user''s access is too low (when getting sys pw)';

Things[80].Text := 'Mail Waiting Header';
  Things[80].Descrip := 'Displayed to users w/mail waiting (|MA = # Mail)';

Things[81].Text := 'Read Mail Now?';
  Things[81].Descrip := 'Asks if user wishes to read waiting mail (|MA = # Mail)';

Things[82].Text := 'Delete Notice Files?';
  Things[82].Descrip := 'Displayed when asking if user wishes to delete his notices';

Things[83].Text := 'There is Feedback Waiting';
  Things[83].Descrip := 'Displayed to sysop''s with feedback waiting (|FB=#Feedback)';

Things[84].Text := 'Read Feedback Now?';
  Things[84].Descrip := 'Displayed when asking if SysOp wishes to read feedback';

Things[85].Text := 'Login Now?';
  Things[85].Descrip := 'Displayed after user checks (and gets) the system password';

Things[86].Text := 'New User Waiting';
  Things[86].Descrip := 'If using NUV this is displayed to notify users (|NE = #New)';

Things[87].Text := 'Vote on New Users';
  Things[87].Descrip := 'When asking Users if they wish to vote on New Users';

Things[88].Text := 'Adding BBS Name';
  Things[88].Descrip := 'Displayed when adding to the BBS List (Name)';

Things[89].Text := 'Adding BBS Number';
  Things[89].Descrip := 'Displayed when adding to the BBS List (Number)';

Things[90].Text := 'Adding BBS Baud';
  Things[90].Descrip := 'Dispayed when adding to the BBS List (Baud)';

Things[91].Text := 'Adding BBS Software';
  Things[91].Descrip := 'Displayed when adding to the BBS List (Software)';

Things[92].Text := 'Add Extended BBS Descrip';
  Things[92].Descrip := 'Displayed when asking if user wants to add extended descrip.';

Things[93].Text := 'BBS Entry Added';
  Things[93].Descrip := 'Displayed after adding to the BBS List';

Things[94].Text := 'View Next Extended Descrip';
  Things[94].Descrip := 'Displayed when viewing extended BBS descrips. (If > 1)';

Things[95].Text := 'Joined Message Conf.';
  Things[95].Descrip := 'Displayed when joining Message Conf (|NA=Name, |NU=#)';

Things[96].Text := 'Joined File Conf.';
  Things[96].Descrip := 'Displayed when joining File Conf (|NA=Name, |NU=#)';

Things[97].Text := 'Who''s being voted on';
  Things[97].Descrip := '(|NA = Name) displays NUV victums name';

Things[98].Text := 'Number of YES Votes';
  Things[98].Descrip := '(|YV = Yes Votes) displays # of YES Votes';

Things[99].Text := 'Number of NO Votes';
  Things[99].Descrip := '(|NV = No Votes) displays # of NO Votes';

Things[100].Text := 'NUV Comment Header';
  Things[100].Descrip := 'Displayed above Comments on New User';

Things[101].Text := 'Enter NUV Comment Prompt';
  Things[101].Descrip := 'Prompt displayed when asking for a comment on new user';

Things[102].Text := 'NUV Vote Prompt';
  Things[102].Descrip := '(If BARS are off) Prompt displayed when voting on user';

Things[103].Text := 'Yes Vote Cast';
  Things[103].Descrip := 'Displayed when YES is cast (|NA=Name)';

Things[104].Text := 'No Vote Cast';
  Things[104].Descrip := 'Displayed when NO is cast (|NA=Name)';

Things[105].Text := 'No New Users Pending';
  Things[105].Descrip := 'Displayed when no New User Voting victums exist';

Things[106].Text := 'Enter Rumor Title';
  Things[106].Descrip := 'Prompt displayed when entering a rumor title';

Things[107].Text := 'Add Rumor Anonymous?';
  Things[107].Descrip := 'Add Rumor Anonymous prompt';

Things[108].Text := 'Enter Rumor Level';
  Things[108].Descrip := 'Lowest Level allowed to see rumor prompt';

Things[109].Text := 'Enter Rumor Prompt';
  Things[109].Descrip := 'Prompt for entering a new rumor';

Things[110].Text := 'Rumor Added!';
  Things[110].Descrip := 'Displayed after a rumor has been added';

Things[111].Text := 'List Rumors Prompt';
  Things[111].Descrip := 'Valid Commands: (R)umors, (S)tats, (B)oth, (E)xit';

Things[112].Text := 'Send Mail To Who';
  Things[112].Descrip := 'Displayed when asking who to send mail to.';

Things[113].Text := 'Carbon Copy Mail';
  Things[113].Descrip := 'Carbon Copy Mail to Who Prompt';

Things[114].Text := 'Notify E-Mail';
  Things[114].Descrip := 'asks if user would like to be notified when read';

Things[115].Text := 'E-Mail Announcement';
  Things[115].Descrip := 'Prompt, Commands: (C)hange/Create, (D)elete, (Q)uit';

Things[116].Text := 'SysOp not here';
  Things[116].Descrip := 'Displayed if user request chat while you are not aruond';

Things[117].Text := 'Chat Costs Header';
  Things[117].Descrip := '(|CC = Chat Cost) header displayed if chat costs FP''s';

Things[118].Text := 'Still want to try?';
  Things[118].Descrip := 'Displayed when asking user still wants to pay for chat';

Things[119].Text := 'Not enough file points';
  Things[119].Descrip := 'Displayed if user doesn''t have enough file points!';

Things[120].Text := '[C] Turns off chat';
  Things[120].Descrip := 'Displayed after user invokes chat call';

Things[121].Text := '[C] Turns chat call on';
  Things[121].Descrip := 'Displayed after user turns chat call off';

Things[122].Text := 'Feedback Sent!';
  Things[122].Descrip := 'Displayed after user sends feedback.';

Things[123].Text := 'You have read mail';
  Things[123].Descrip := 'Header when deleting mail (|TI=Title/|SB=Sent By)';

Things[124].Text := 'Delete mail now';
  Things[124].Descrip := 'When asking if user wants to delete mail';

Things[125].Text := 'Current Mail (None)';
  Things[125].Descrip := 'When displaying mail and there is none';

Things[126].Text := 'Current Mail Reading';
  Things[126].Descrip := '|NU = Number, |TI = Title, |AU = Author';

Things[127].Text := 'Pick this mail header?';
  Things[127].Descrip := 'When asking if user wants to use this mail header';

Things[128].Text := 'List Title Type';
  Things[128].Descrip := 'Either by (R)ange or (N)ext in Line';

Things[129].Text := 'No More Titles to List';
  Things[129].Descrip := 'Displayed when no more titles to list.';

Things[130].Text := 'List Titles to you?';
  Things[130].Descrip := 'When asking if user only wishes to list titles to himself';

Things[131].Text := 'Sub doesn''t exist!';
  Things[131].Descrip := 'Displayed when user trys to enter a Sub that doesn''t exists';

Things[132].Text := 'Msg. NewScan Aborted';
  Things[132].Descrip := 'Displayed if user aborts Message NewScan';

Things[133].Text := 'Message NewScan Prompt';
  Things[133].Descrip := '(If No Bars) |BN=Board Name |CB=Cur. Msg # |NB=Total Msgs.';

Things[134].Text := 'Reading Msg. Prompt';
  Things[134].Descrip := '(If No Bars) |BN=Board Name |CB=Cur. Msg # |NB=Total Msgs.';

Things[135].Text := 'Current Sub (NewScan)';
  Things[135].Descrip := 'Current Sub Display |BN=Board Name |NU=Board #';

Things[136].Text := 'Jump to Message #';
  Things[136].Descrip := 'Displayed when jumping messages (|NB=Total Msgs)';

Things[137].Text := 'Posting QWK Msg.';
  Things[137].Descrip := 'When adding a QWK Packet |TO=Total |BN=Board Name';

Things[138].Text := 'Total QWK Added';
  Things[138].Descrip := 'Total Messages Added (|TO=Total)';

Things[139].Text := 'Sending QWK Packet Prompt';
  Things[139].Descrip := 'Displayed before sending QWK Packet - [Q]uits';

Things[140].Text := 'Not Used';
  Things[140].Descrip := '';

Things[141].Text := 'Not Used';
  Things[141].Descrip := '';

Things[142].Text := 'Not Used';
  Things[142].Descrip := '';

Things[143].Text := 'Thread Which-Way?';
  Things[143].Descrip := 'Prompts when user wants to message thread (F)ore, (B)ack';

Things[144].Text := 'Auto-Validating File';
  Things[144].Descrip := 'Displayed when auto-validating a new upload |FN=Filename';

Things[145].Text := 'File is Worth..';
  Things[145].Descrip := '|FP=File Points |FS=FileSize - after Auto-Validating File';

Things[146].Text := 'Granting User FP''s';
  Things[146].Descrip := '|FP = File Points - Displayed when giving user FP''s for upload';

Things[147].Text := 'File is Offline';
  Things[147].Descrip := 'Displayed if user tries to access offline file';

Things[148].Text := 'Crashed File';
  Things[148].Descrip := 'Displayed if user tries to access an incomplete file';

Things[149].Text := 'Bad Baud Rate';
  Things[149].Descrip := 'Displayed if user tries to access files with a bad baud';

Things[150].Text := 'UnValidated File';
  Things[150].Descrip := 'Displayed if user tries to access an unvalidated file';

Things[151].Text := 'Special File';
  Things[151].Descrip := 'Displayed if user tries to access a "special" file';

Things[152].Text := 'No Downloads Here';
  Things[152].Descrip := 'Displayed if user tries to download from a non-download area';

Things[153].Text := 'Private File';
  Things[153].Descrip := 'Displayed if user tries to download a private file';

Things[154].Text := 'File Password';
  Things[154].Descrip := 'When Prompting for password on passworded files';

Things[155].Text := 'Wrong File PW';
  Things[155].Descrip := 'Displayed if user enters wrong file password';

Things[156].Text := 'File List Prompt';
  Things[156].Descrip := 'Displayed when listing files (after a full page) |AN=Area Name';

Things[157].Text := 'Invalid File Selection';
  Things[157].Descrip := 'Displayed if user enters an invalid #/Name';

Things[158].Text := 'Untagging Batch File';
  Things[158].Descrip := 'Displayed when removing file from Batch list (|FN=Filename)';

Things[159].Text := 'File NewScan Prompt';
  Things[159].Descrip := 'Prompt displayed when newscannig files - |AN = Area Name';

Things[160].Text := 'File Extraction Prompt';
  Things[160].Descrip := '[A]dd to Batch or [Q]uit - displayed after extracting a zip';

Things[161].Text := 'Bad UD Ratio';
  Things[161].Descrip := '|RA=Upload/Download Ratio |RR=Required Ratio';

Things[162].Text := 'Bad UD ''K'' Ratio';
  Things[162].Descrip := '|RA=Upload/Download Kilobyte Ratio |RR=Required Ratio';

Things[163].Text := 'Exceeded Daily KB Limit';
  Things[163].Descrip := '|DK = Downloaded K Today  |KL = Kilobyte Limit';

Things[164].Text := 'File Point Commision';
  Things[164].Descrip := '|NA = Who''s getting points |FP = how many file points';

Things[165].Text := 'Successful Download';
  Things[165].Descrip := '|FN=Filename |CP=CPS |CO=File Cost |ER=# Errors';

Things[166].Text := 'File Crash, Save?';
  Things[166].Descrip := 'Displayed if transfer crashed, save partial file?';

Things[167].Text := 'Invalid Upload Name';
  Things[167].Descrip := 'Displayed if user enters an invalid filename to upload';

Things[168].Text := 'Already Entered Filename';
  Things[168].Descrip := 'Displayed if user enters a filename already in upload queue';

Things[169].Text := 'File Already Exists!';
  Things[169].Descrip := 'Displayed if user enters a filename that already exists';

Things[170].Text := 'Enter File Description';
  Things[170].Descrip := 'Enter File Description Prompt';

Things[171].Text := 'Extended Upload Setup';
  Things[171].Descrip := 'Valid Commands = [A]dd Password, [P]rivate, [D]esc., [Cr] Quit';

Things[172].Text := 'Re-Enter File Descrip.';
  Things[172].Descrip := 'Prompted after batch uploads if no description exists';

Things[173].Text := 'Notify if Downloaded';
  Things[173].Descrip := 'Prompted after downloads';

Things[174].Text := '50 Files Maximum';
  Things[174].Descrip := 'Displayed if user tries to add more then 50 files to batch';

Things[175].Text := 'You can''t download here';
  Things[175].Descrip := 'Displayed to a user who is not allowed to download from area';

Things[176].Text := 'File is already marked';
  Things[176].Descrip := 'Displayed to a user who tags a marked file';

Things[177].Text := 'Not enough File Points';
  Things[177].Descrip := 'Displayed when user tries to leech without enough file points';

Things[178].Text := 'File Area Password';
  Things[178].Descrip := 'When prompting for file area password.';

 NumThings := 178;

 For X := 1 to NumThings
   Do Things[X].TType:=TLstr;

End;

procedure assignptrs;
var cnt:integer;
    i:byte;

  procedure s (var q);
  begin
    cnt:=cnt+1;
    things[cnt].p:=@q
  end;

begin
  cnt:=0;
  s (strng.defprompt);
  s (strng.pausestring);
  s (strng.systempasswordstr);
  s (strng.whatsyouralias);
  s (strng.whatsyourpw);
  s (strng.sysopworkingstr);
  s (strng.enterchat);
  s (strng.exitchat);
  s (strng.sysopindos);
  s (strng.quotestartline);
  s (strng.quoteendline);
  s (strng.connectionstr);
  s (strng.lockedbaudstr);
  s (strng.ApplyAsNewStr);
  s (strng.GetNupStr);
  s (strng.ChatRequestStr);
  s (strng.LeaveFBStr);
  s (strng.quotetitle);
  s (strng.quotemessagestr);
  s (strng.Erase5MsgsStr);
  s (strng.ChangeBoardStr);
  s (strng.NewScanBoardStr);
  s (strng.EXTRA3);
  s (strng.EXTRA2);
  s (strng.PostOnBoardStr);
  s (strng.MsgTitleStr);
  s (strng.MsgToStr);
  s (strng.UploadMsgStr);
  s (strng.MsgAnonStr);
  s (strng.SlashStr);
  s (strng.EXTRA7);
  s (strng.NewScanningStr);
  s (strng.ChangeFileAreaStr);
  s (strng.LogOffStr);
  s (strng.ChangeAutoMsgStr);
  s (strng.NewUserNamestr);
  s (strng.CreateAPassword);
  s (strng.SysOpIsIn);
  s (strng.SysOpIsOut);
  s (Strng.HeaderStr);
  s (Strng.EXTRA7);
  s (Strng.CurFileArea);
  s (Strng.QuoteTop);
  s (Strng.QuoteBottom);
  s (strng.NewScanDateStr);
  s (Strng.AddBatchPrompt);
  s (Strng.ViewArchivePrompt);
  s (Strng.GetInfoPrompt);
  s (Strng.TypeFilePrompt);
  s (Strng.UploadFileStr);
  s (Strng.DownloadStr);
  s (Strng.ListRange);
  s (Strng.ContinueStr);
  s (Strng.ConfPrompt);
  s (Strng.AreaMsgNewScan);
  s (Strng.ListUsers);
  s (Strng.Ask_One_Liner);
  s (STrng.Enter_One_Liner);
  s (Strng.ReEnter_Password);
  s (Strng.Enter_RealName);
  s (Strng.Enter_UserNote);
  s (Strng.Enter_Number);
  S (Strng.Enter_Number_Header);
  S (Strng.Welcome_NewUser);
  S (Strng.Your_UserNum);
  S (Strng.Your_Current_Prompt);
  S (Strng.Design_New_Prompt);
  S (STrng.Want_HotKeys);
  S (Strng.Want_Rumors);
  s (Strng.User_Not_Found);
  s (Strng.Infoform_Prompt);
  s (Strng.NewInfoForm_Prompt);
  s (Strng.ViewWhichForm);
  s (Strng.Checking_PhoneNum);
  s (Strng.Checking_User_Base);
  s (Strng.Name_Already_Used);
  s (Strng.Invalid_UserName);
  s (Strng.Sys_PW_Is);
  s (Strng.You_Are_Not_Validated);
  s (Strng.You_Have_Mail);
  s (Strng.Read_Mail_Now);
  s (Strng.Delete_Notice);
  s (Strng.There_Is_Feedback);
  s (Strng.Read_Feedback);
  s (Strng.Login_Now);
  s (Strng.New_Users_Are_Waiting);
  S (Strng.Vote_On_NewUsers);
  s (Strng.AddBBS_Name);
  s (Strng.AddBBS_Number);
  s (Strng.AddBBS_Baud);
  s (Strng.AddBBS_Type);
  s (Strng.AddBBS_Upload);
  S (Strng.BBS_Added);
  s (Strng.View_Extended_BBS);
  s (Strng.Joined_Msg_Conf);
  s (Strng.Joined_File_Conf);
  s (Strng.NUV_Voting_On);
  s (Strng.NUV_Yes_Votes);
  s (Strng.NUV_No_Votes);
  s (Strng.NUV_Comment_Header);
  s (Strng.Enter_NUV_Comment);
  s (Strng.NUV_Vote_Prompt);
  s (Strng.NUV_Yes_Cast);
  s (Strng.NUV_No_Cast);
  s (Strng.No_NUV_Pending);
  s (Strng.Get_Rumor_Title);
  s (Strng.Add_Rumor_Anon);
  s (Strng.Level_To_See_Rumor);
  s (Strng.Enter_Your_Rumor);
  s (Strng.Rumor_Added);
  s (Strng.Get_Rumor_List);
  s (Strng.Send_Mail_To_Who);
  s (Strng.Carbon_Copy_To);
  s (Strng.Mail_Notify);
  s (Strng.Announce_Prompt);
  s (Strng.SysOp_Not_Here);
  s (Strng.Chat_Request_Will_Cost);
  s (Strng.Still_Wanna_Chat);
  s (Strng.No_Chat_No_FP);
  s (Strng.Use_C_to_Stop_Chat);
  s (Strng.Use_C_To_Start_Chat);
  s (Strng.Feedback_Sent);
  s (Strng.U_Have_Read_Mail);
  s (Strng.Delete_Mail_Now);
  s (Strng.Current_Mail_None);
  s (Strng.List_Current_Mail);
  s (Strng.Pick_This_Header);
  s (Strng.Show_Title_Or_Range);
  s (Strng.No_More_Titles_To_List);
  s (Strng.List_Messages_For_You);
  s (Strng.Sub_No_Exist);
  s (Strng.Msg_NewScan_Aborted);
  s (Strng.Msg_NewScan_Prompt);
  s (Strng.Msg_Reading_Prompt);
  s (Strng.Current_Board_NewScan);
  s (Strng.Jump_To_Msg_Number);
  s (Strng.Adding_Msg_Qwk);
  s (Strng.Total_QWK_Sent);
  s (Strng.Sending_QWK_Packet);
  s (Strng.EXTRA8);
  s (Strng.EXTRA9);
  s (Strng.EXTRA10);
  s (Strng.Thread_Which_Way);
  S (Strng.Auto_Validate_File);
  s (strng.Value_Of_File);
  s (Strng.Granting_You_FP);
  s (STrng.File_Does_Not_Exist);
  s (Strng.Crashed_File);
  s (Strng.Bad_Baud_Rate);
  s (Strng.UNValidated_File);
  s (Strng.Special_File);
  s (Strng.No_Downloads_Here);
  s (strng.Private_File);
  s (Strng.Passworded_File);
  s (Strng.Wrong_Password);
  s (Strng.File_List_Prompt);
  s (Strng.Bad_File_Selection);
  s (Strng.Untagging_File);
  s (Strng.file_NewScan_Prompt);
  s (Strng.File_Extract_Prompt);
  s (Strng.Bad_UD_Ratio);
  s (Strng.Bad_UDK_Ratio);
  s (Strng.Bad_K_Limit);
  s (Strng.Giving_FP_Credit);
  s (Strng.Good_Download);
  s (Strng.Crash_Save_File);
  s (Strng.Invalid_Upload_Name);
  s (Strng.You_Already_Entered_FN);
  s (Strng.File_Already_Online);
  s (Strng.File_Description);
  s (Strng.Extended_File_Setup);
  s (Strng.ReEnter_Descrip);
  s (Strng.Notify_Download);
  s (Strng.Can_Only_Tag_50);
  s (Strng.You_Cannot_Download);
  s (Strng.File_Already_Marked);
  s (Strng.Not_Enough_FP);
  s (Strng.Enter_Area_Password);

  if cnt<>numthings then begin
    writeln ('Error in number of items of STRINGS.DAT');
    writeln ('Expected: ',numthings);
    writeln ('Actual..: ',cnt);
    halt
  end
end;

procedure getinput (n:integer; editit:boolean);
var y:integer;
    inp:lstr;
    t:thing;
    pu:pointer;
    p:ptrset absolute pu;

  procedure reshow;
  begin
    gotoxy (dcol,y);
    writevar (n)
  end;

  procedure dostr;
  begin
    if (inp='N') or (inp='n') then inp:='';
    p.l^:=inp
  end;

begin
  t:=things[n];
  pu:=t.p;
  gotopage (whichpage(n));
  y:=whichline(n);
  begin
    gotoxy (1,25);
    case t.ttype of
      tsstr:buflen:=15;
      tmstr:buflen:=30;
      tlstr:buflen:=80;
    end;
    gotoxy (dcol,y);
    setcolor(normalcolor);
    clreol;
    if editit then setdefaultinput (varstr(n));
    readln (inp);
  end;
  if length(inp)<>0 then
    case t.ttype of
      tsstr,tmstr,tlstr:dostr;
    end;
  reshow;
  t.p:=pu;
  things[n]:=t
end;

procedure changenum (ns:integer; editit:boolean);
var n:integer;
begin
  n:=ns+top-1;
  if (n<1) or (n>numthings) then exit;
  getinput (n,editit)
end;

Procedure CreateStrings;
var f:File of StringRec;
    s,w:integer;
Begin
  Writeln('Creating Strings.DAT');
  assign (f,'STRINGS.DAT');
  reset (f);
  if ioresult=0 then begin
    close (f);
    exit;
  end;
  fillchar (strng,sizeof(strng),0);
  FormatStrings;
  Rewrite(F);
  Write(F,Strng);
  Close(F);
end;

Procedure ReadStrings;
Var F:File Of StringRec;
Begin
  Assign(F,'STRINGS.DAT');
  Reset(F);
  If IoResult<>0 Then Begin
    Close(F);
    CreateStrings;
    Exit;
  End;
  Read(F,Strng);
  Close(F);
End;

Procedure ReadConfig;
Var F:File Of ConfigSetType;
Begin
  Assign(F,'CONFIG.BBS');
  Reset(F);
  If IoResult<>0 Then Begin
    Close(F);
    TextAttr:=15;
    Writeln('You must run CONFIG.EXE to configure ViSiON/2 before running STRINGS');
    Halt;
  End;
  Read(F,Cfg);
  Close(F);
End;

Procedure UNCRUNCH (var Addr1,Addr2; BlkLen:Integer);
BEGIN
  iNLiNE ($1E/$C5/$B6/Addr1/$C4/$BE/Addr2/$8B/$8E/BlkLen/$8B/$D7/
          $B4/$00/$AC/$3C/$10/$73/$07/$80/$E4/$F0/$0A/$E0/$EB/$44/
	  $3C/$18/$74/$13/$73/$19/$2C/$10/$02/$C0/$02/$C0/$02/$C0/
	  $02/$C0/$80/$E4/$0F/$0A/$E0/$EB/$2D/$81/$C2/$A0/$00/$8B/
	  $FA/$EB/$25/$3C/$1A/$75/$0B/$AC/$49/$51/$32/$ED/$8A/$C8/
	  $AC/$EB/$0D/$90/$3C/$19/$75/$11/$AC/$51/$32/$ED/$8A/$C8/
	  $B0/$20/$0B/$C9/$74/$03/$AB/$E2/$FD/$59/$49/$AB/$0B/$C9/
	  $74/$02/$E2/$AA/$1F);
END;

{$I LOGO.PAS}

procedure byebye;
begin
  setcolor(1);
  clearwindow (14);
  DrawLogo;
  WriteCenter(24,14,0,'ViSiON/2 (c) is a production of Ruthless Enterprises');
  Cursor(1);
  halt
end;

procedure abortyn;
var w3:window;
    yesn:boolean;
    k:char;
begin
  yesn:=true;
  openwindow(w3,28,10,52,15,78,78);
  setcurwindow(w3);
  setcolor(79);gotoxy(2,1);write('Abort Without Saving?');
  repeat
  gotoxy(3,3); setcolor(78); if yesn then setcolor(118);
  write(' Yes ');setcolor(78);gotoxy(17,3); if not yesn then setcolor(118);
  write(' No ');
  k:=BiosKey;
  if (k=#205) or (K=#131) then yesn:=not yesn else
  if (k=#203) or (k=#130) then yesn:=not yesn;
  if (k='y') or (k='Y') then yesn:=true else
  if (k='n') or (k='N') then yesn:=false;
  until (k=#27) or (k=#13);
  If K in [#27,#132] then yesn:=false;
  closewindow;
  if yesn then byebye;
end;

var command:sstr;
    i:integer;
    check:boolean;
    p:promptrecptr;
    ps:promptset;
begin
  textmode (CO80);
  DrawLogo;
  Readdata;
  Assignptrs;
  ReadConfig;
  ReadStrings;
  i:=ioresult;
  numpages:=whichpage(numthings);
  page:=0;
  initscrnunit;
  curwindowptr^.normalcolor:=normalcolor;
  curwindowptr^.boldcolor:=boldcolor;
  curwindowptr^.barcolor:=barcolor;
  curwindowptr^.inputcolor:=inputcolor;
  curwindowptr^.choicecolor:=choicecolor;
  curwindowptr^.datacolor:=datacolor;
  Eraseline:=False;
  gotopage (1);
  setcolor(1);
  Cursor(0);
  Repeat
    i:=useprompts(prompt);
    Gotoxy(23,1);
    SetColor(31); Write(' '+strr(i+top-1)+'  ');
    GotoXy(1,24);
    SetColor(11); ClrEOL; IF i>0 then writecenter(24,13,0,things[i+top-1].descrip);
    if (bioslook in [#32..#126])
      then Begin Cursor(2);
           changenum (i,false);
           Cursor(0);
      End
      else case bioskey of
        #133,#187:begin
            Cursor(1);
            changenum (i,true);
            Cursor(0);
        end;
        #189:Begin Gotoxy(1,24); SetColor(30); ClrEol; End;
        #196:begin writestrings; byebye; end;
        #27:abortyn;
        #13:BEGIN
            Cursor(1);
            changenum (i,false);
            Cursor(0);
            END;
        #209:GotoPage(Page+1);
        #201:GotoPage(Page-1);
      end;
  until 0=1
end.