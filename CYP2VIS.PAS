z{$R-,S-,I-,D-,F-,V-,B-,N-}

Program Cyper_2_ViSiON;

Uses Dos,Crt,ConfigRt,GenTypes;

Type
     MsgArray  = Array [1..MaxMessageSize] of Lstr;
     VoteArry  = Array [1..10] of Byte;
     InfoArry  = Array [1..5] of Integer;
     LastArry  = Array [0..40,1..40] of Word;

     Cypher_UserRec = Record
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

Var User:UserRec;
    UserFile:File Of UserRec;
    C_User:Cypher_UserRec;
    C_UserFile:File Of Cypher_UserRec;
    X,Temp:Byte;
    K:Char;
    F:File Of Mstr;

    Procedure AddName;
    Begin
      Assign(F,Cfg.DataDir+'USERINDX.');
      Reset(F);
      Seek(F,FileSize(F));
      Write(F,User.Handle);
      Close(F);
    End;

Begin
  ReadCfg;
  ReadStrings;
  ClrScr;
  TextAttr:=15;
  Writeln('ViSiON/2 vo.69 "The REVision" (c) Ruthless Enterprises 1992');
  Writeln;
  TextATTR:=11;
  Writeln('Cypher -2- ViSiON/2 User Convertor');
  TextAttr:=3;
  Writeln('Brought to you by Crimson Blade');
  Writeln;
  Writeln;
  TextAttr:=14;
  Assign(C_UserFile,'USERS.');
  Reset(C_UserFile);
  If IoResult<>0 Then Begin
    Writeln('Error: Opening Cypher User Records (Must Be in: '+Cfg.ViSiONDir+')');
    Close(C_UserFile);
    Halt;
  End;
  Write('Cypher User Record found and opened, continue? [Y/n]: ');
  TextAttr:=15;
  K:=ReadKey;
  If K=#13 then K:='Y';
  K:=Upcase(K);
  If K<>'Y' then Begin
    Writeln('Aborted');
    Close(C_UserFile);
    Halt;
  End Else
  Writeln('Yep');
  Assign(F,Cfg.DataDir+'USERINDX.');
  Rewrite(F);
  Close(F);
  Assign(UserFile,Cfg.DataDir+'USERS.');
  Rewrite(UserFile);
  FillChar(User,SizeOf(User),0);
  AddName;
  Write(UserFile,User);          { Add Dummmy Account #0 }
  For X:=0 To FileSize(C_UserFile)-1 Do Begin
    Seek(C_UserFile,X);
    Read(C_UserFile,C_User);
    If C_User.Handle<>'' Then Begin
      GotoXy(1,10);
      ClrEol;
      TextAttr:=9;
      Write('Converting User: ');
      TextAttr:=15;
      Write(C_User.Handle);
      FillChar(User,SizeOf(User),0);
      User.Handle      := C_User.Handle;
      User.Level       := C_User.Level;
      User.UDLevel     := C_User.UDLevel;
      User.UDPoints    := C_User.UDPoints;
      User.RealName    := C_User.RealName;
      User.Password    := C_User.Password;
      User.SysOpNote   := C_User.Note;
      User.PhoneNum    := C_User.VoiceNum;
      If C_User.UpK>1024
        Then User.KUp  := Round(C_User.Upk Div 1024)
        Else User.Kup  := 0;
      If C_User.DownK>1024
        Then User.KDown:= Round(C_User.DownK Div 1024)
        Else User.KDown:= 0;
      User.DefFileConf := 1;
      User.DefMsgConf  := 1;
      User.Uploads     := C_User.Uploads;
      User.Downloads   := C_User.Downloads;
      User.Flags       := C_User.Flags;
      User.FileList[1] := (C_User.File_Config_Bits and 1)=1;
      User.FileList[2] := User.FileList[1];
      User.FileList[3] := (C_User.File_Config_Bits and 2)=2;
      User.FileList[4] := (C_User.File_Config_Bits and 4)=4;
      User.FileList[5] := (C_User.File_Config_Bits and 64)=64;
      User.FileList[6] := (C_User.File_Config_Bits and 32)=32;
      User.FileList[8] := (C_User.File_Config_Bits and 8)=8;
      User.Color1      := Cfg.DefColor1;
      User.Color2      := Cfg.DefColor2;
      User.Color3      := Cfg.DefColor3;
      User.Color4      := Cfg.DefColor4;
      User.Color5      := Cfg.DefColor5;
      User.Color6      := Cfg.DefColor6;
      User.Color7      := Cfg.DefColor7;
      User.Prompt      := Strng.DefPrompt;
      User.UDKRatio    := Cfg.DefUdKRatio;
      User.UDFRatio    := Cfg.DefUDRatio;
      User.Pcr         := Cfg.DefPcr;
      User.DefProto    := 'Z';
      User.EmailAnnounce:=-1;
      User.Numon       := 2;
      User.DisplayLen  :=24;
      If (C_User.Level>1) and (C_User.Level<101)
        Then User.TimeToday:=Cfg.Usertime[C_User.Level]
        Else User.TimeToday:=999;
      For Temp:=1 to 5 Do User.Infoform[Temp]:=-1;
      User.Config:=[lowercase,eightycols,linefeeds,postprompts,fseditor,
                    asciigraphics,ansigraphics,usebars,showrumors];
      Seek(UserFile,FileSize(UserFile));
      Write(UserFile,User);
      AddName;
    End;
  End;
  Writeln;
  TextAttr:=14;
  Writeln;
  Writeln('Okay, Conversion is complete!');
  Close(UserFile);
  Close(C_UserFile);
End.