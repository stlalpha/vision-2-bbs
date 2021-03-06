{$I-}
{$M 8000,0,0}

Program Make_Str;

Var To_,From : Text;
    D : Array[1..200] Of String[30];

  Procedure Set_Up;
  Begin
    FillChar(D,SizeOf(D),0);
    D[1] := 'ConnectionStr';
    D[2] := 'LockedBaudStr';
    D[3] := 'ApplyAsNewStr';
    D[4] := 'GetNupStr';
    D[5] := 'ChatRequestStr';
    D[6] := 'LeaveFBStr';
    D[7] := 'OriginStr1';
    D[8] := 'OriginStr2';
    D[9] := 'Erase5MsgsStr';
    D[10] := 'ChangeBoardStr';
    D[11] := 'NewScanBoardStr';
    D[12] := 'ViewTTAgainStr';
    D[13] := 'MsgNewScanStr';
    D[14] := 'PostOnBoardStr';
    D[15] := 'MsgTitleStr';
    D[16] := 'MsgToStr';
    D[17] := 'UploadMsgStr';
    D[18] := 'MsgAnonStr';
    D[19] := 'SlashStr';
    D[20] := 'FileNewScanStr';
    D[21] := 'NewScanningStr';
    D[22] := 'ChangeFileAreaStr';
    D[23] := 'LogOffStr';
    D[24] := 'ChangeAutoMsgStr';
    D[25] := 'NewUserNameStr';
    D[26] := 'CreateAPassword';
    D[27] := 'Pausestring';
    D[28] := 'Whatsyouralias';
    D[29] := 'Whatsyourpw';
    D[30] := 'Sysopworkingstr';
    D[31] := 'Sysopindos';
    D[32] := 'SystemPasswordStr';
    D[33] := 'Defprompt';
    D[34] := 'Enterchat';
    D[35] := 'Exitchat';
    D[36] := 'Origin1';
    D[37] := 'Origin2';
    D[38] := 'SysOpIsIn';
    D[39] := 'SysOpIsOut';
    D[40] := 'HeaderStr';
    D[41] := 'Infoform_Prompt';
    D[42] := 'NewInfoForm_Prompt';
    D[43] := 'User_Not_Found';
    D[44] := 'Design_New_Prompt';
    D[45] := 'Your_Current_Prompt';
    D[46] := 'Want_HotKeys';
    D[47] := 'Want_Rumors';
    D[48] := 'Your_UserNum';
    D[49] := 'Welcome_NewUser';
    D[50] := 'Enter_Number_Header';
    D[51] := 'SkipStats';
    D[52] := 'Enter_Number';
    D[53] := 'Enter_UserNote';
    D[54] := 'CurFileArea';
    D[55] := 'Enter_RealName';
    D[56] := 'ReEnter_Password';
    D[57] := 'QuoteTop';
    D[58] := 'QuoteBottom';
    D[59] := 'Ask_One_Liner';
    D[60] := 'Enter_One_Liner';
    D[61] := 'NewScanDateStr';
    D[62] := 'AddBatchPrompt';
    D[63] := 'ListUsers';
    D[64] := 'ViewArchivePrompt';
    D[65] := 'AreaMsgNewScan';
    D[66] := 'GetInfoPrompt';
    D[67] := 'MsgNewScanPrompt';
    D[68] := 'TypeFilePrompt';
    D[69] := 'ConfPrompt';
    D[70] := 'FileListPrompt';
    D[71] := 'UploadFileStr';
    D[72] := 'DownloadStr';
    D[73] := 'ListRange';
    D[74] := 'ContinueStr';
    D[75] := 'ViewWhichForm';
    D[76] := 'Checking_PhoneNum';
    D[77] := 'Checking_User_Base';
    D[78] := 'Name_Already_Used';
    D[79] := 'Invalid_UserName';
    D[80] := 'Sys_PW_Is';
    D[81] := 'You_Are_Not_Validated';
    D[82] := 'You_Have_Mail';
    D[83] := 'Read_Mail_Now';
    D[84] := 'Delete_Notice';
    D[85] := 'There_Is_Feedback';
    D[86] := 'Read_Feedback';
    D[87] := 'Login_Now';
    D[88] := 'New_Users_Are_Waiting';
    D[89] := 'Vote_On_NewUsers';
    D[90] := 'AddBBS_Name';
    D[91] := 'AddBBS_Number';
    D[92] := 'AddBBS_Baud';
    D[93] := 'AddBBS_Type';
    D[94] := 'AddBBS_Upload';
    D[95] := 'View_Extended_BBS';
    D[96] := 'Joined_Msg_Conf';
    D[97] := 'Joined_File_Conf';
    D[98] := 'BBS_Added';
    D[99] := 'NUV_Voting_On';
    D[100] := 'NUV_Yes_Votes';
    D[101] := 'NUV_No_Votes';
    D[102] := 'NUV_Comment_Header';
    D[103] := 'Enter_NUV_Comment';
    D[104] := 'NUV_Vote_Prompt';
    D[105] := 'NUV_Yes_Cast';
    D[106] := 'NUV_No_Cast';
    D[107] := 'No_NUV_Pending';
    D[108] := 'Get_Rumor_Title';
    D[109] := 'Add_Rumor_Anon';
    D[110] := 'Level_To_See_Rumor';
    D[111] := 'Enter_Your_Rumor';
    D[112] := 'Rumor_Added';
    D[113] := 'Get_Rumor_List';
    D[114] := 'Carbon_Copy_To';
    D[115] := 'Mail_Notify';
    D[116] := 'Send_Mail_To_Who';
    D[117] := 'Announce_Prompt';
    D[118] := 'SysOp_Not_Here';
    D[119] := 'Chat_Request_Will_Cost';
    D[120] := 'Still_Wanna_Chat';
    D[121] := 'No_Chat_No_FP';
    D[122] := 'Use_C_to_Stop_Chat';
    D[123] := 'Use_C_To_Start_Chat';
    D[124] := 'Feedback_Sent';
    D[125] := 'U_Have_Read_Mail';
    D[126] := 'Delete_Mail_Now';
    D[127] := 'Current_Mail_None';
    D[128] := 'List_Current_Mail';
    D[129] := 'Pick_This_Header';
    D[130] := 'Show_Title_Or_Range';
    D[131] := 'No_More_Titles_To_List';
    D[132] := 'List_Messages_For_You';
    D[133] := 'Sub_No_Exist';
    D[134] := 'Msg_NewScan_Aborted';
    D[135] := 'Msg_NewScan_Prompt';
    D[136] := 'Msg_Reading_Prompt';
    D[137] := 'Current_Board_NewScan';
    D[138] := 'Jump_To_Msg_Number';
    D[139] := 'Thread_Which_Way';
    D[140] := 'Adding_Msg_Qwk';
    D[141] := 'Total_QWK_Sent';
    D[142] := 'Sending_QWK_Packet';
    D[143] := 'Quick_Login';
    D[144] := 'You_Won_FP_Lot';
    D[145] := 'You_LOST_FP_Lot';
    D[146] := 'Show_Thread_Which_Way';
    D[147] := 'Auto_Validate_File';
    D[148] := 'Value_Of_File';
    D[149] := 'Granting_You_FP';
    D[150] := 'File_Does_Not_Exist';
    D[151] := 'Crashed_File';
    D[152] := 'Bad_Baud_Rate';
    D[153] := 'Unvalidated_File';
    D[154] := 'Special_File';
    D[155] := 'No_Downloads_Here';
    D[156] := 'Private_File';
    D[157] := 'Passworded_File';
    D[158] := 'Wrong_Password';
    D[159] := 'File_List_Prompt';
    D[160] := 'Bad_File_Selection';
    D[161] := 'Untagging_File';
    D[162] := 'File_NewScan_Prompt';
    D[163] := 'File_Extract_Prompt';
    D[164] := 'Bad_UD_Ratio';
    D[165] := 'Bad_UDK_Ratio';
    D[166] := 'Bad_K_Limit';
    D[167] := 'Giving_FP_Credit';
    D[168] := 'Good_Download';
    D[169] := 'Crash_Save_File';
    D[170] := 'Invalid_Upload_Name';
    D[171] := 'You_Already_Entered_FN';
    D[172] := 'File_Already_Online';
    D[173] := 'File_Description';
    D[174] := 'Extended_File_Setup';
    D[175] := 'ReEnter_Descrip';
    D[176] := 'Notify_Download';
    D[177] := 'Can_Only_Tag_50';
    D[178] := 'You_Cannot_Download';
    D[179] := 'File_Already_Marked';
    D[180] := 'Not_Enough_FP';
    D[181] := 'Enter_Area_Password';
  End;

Var X : Byte;
    S : String;
    Number : String[3];
Begin
  Assign(To_,'STRINGS.TXT');
  Reset(To_);
  If IoResult <> 0
    Then Exit;
  Assign(From,'STRINGS.NEW');
  Rewrite(From);
  X := 1;
  Set_Up;
  While Not Eof(To_) Do Begin
    Readln(To_,S);
    { Writeln(From,D[X] + ' := ''' + S + ''';'); }
    Str(X,Number);
    WriteLn(From,'D['+Number+'] := ''' + S + ''';');
    Inc(x);
  End;
  Close(From);
  Close(To_);
End.