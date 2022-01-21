                                                                                {
              [ ViSiON/2 - The REViSiON Written By: Crimson Blade ]
              [ Started from FORUM-PC v2.1 Source Code on: 7/1/92 ]
              [ NewScan,TopTen Rewritten from old ViSiON Source   ]
              [ Compiled with Turbo Pascal v6.0                   ]
              [ ViSiON/2 (C) 1992 - [R]uthless [E]nterprises      ]             }


                               PROGRAM ViSiON;
                                                                                {
                             COMPILER DIRECTIVES


 Code    Directive          State          Note                                  }

{$A+}
{$B-}
{$E-}
{$R-        Range checking  Off            Don't change }
{$S-        Stack checking  Off            Makes code larger/slower }
{$I-          I/O checking  Off            Don't change }
{$D-     Debug information  Off            Makes code larger/slower }
{$F+       Force far calls  On             Makes code larger/slower }
{$V-   Var-string checking  Relaxed        Don't change }
{$B-    Boolean evaluation  Short Cicuit   Don't change }
{$N-    Numeric processing  Software       Change if you have an 8087 }
{$L+           Link buffer  Memory         Change if yo have enough memory }
{$O+      Use Overlay File  On             Don't change }

{$M 65520,1024,30000}

{$DEFINE OVERLAYS}
                                                                                {
                                 ViSiON/2 UNITS                                 }

Uses
  SwapUNIT,    { Spawning Routines }
  Open,        { Opening Display Screen }
  Crt,         { Turbo Pascal CRT library }
  Dos,         { Turbo Pascal DOS library }
  Printer,     { Turbo Pascal Printer library }
  Overlay,     { Turbo Pascal Overlay library }
  OvrCall,     { Calls the overlay files }

  DosMem,      { Heap Memory Allocation Unit }
  MNET,        { File Sharing }
  GenTypes,    { All type and constant declarations }
  ConfigRt,    { Configuration declarations / procedures }
  Fossil,      { Fossil Routines   }
  Modem,       { Fossil -> ViSiON/2 Interface }
  Statret,     { System status declarations / procedures }
  GenSubs,     { General subroutines: lowest level }
  Subs1,       { First subroutine library }
  Windows,     { Routines to manage the split screen }
  SubsOvr,     { Misc Sub-Routines -> OVR }
  ChatStuf,    { SysOp Local Menu / Config Chat Routines }
  Subs2,       { Second subroutine library: higer level I/O }
  TextRet,     { Message handling routines }
  MailRet,     { E-Mail handling routines }
  UserRet,     { User file handling routines }
  Flags,       { Board access flag / User Flag routines }
  Mainr1,      { High-level routines, set one }
  Ansiedit,    { ANSi Graphics Full-Screen editor }
  Lineedit,    { Line editor }
  Protocol,    { Protocol Execution/Selection}
  Mainr2,      { High-level routines, set two }
  OverRet1,    { High-level routines, set three }
  TopUser,     { Top Five/Ten User Display }

  Rumors,      {          Rumors Section }
  Mess0,
  Mess1,
  Mess2,
  Mess3,
  Mess4,
  Bulletin,    {        Bulletin section }
  MessSys0,
  Configur,    {   Configuration section }
  Doors,       {            Door section }
  Email0,
  Group,
  Group1,
  Email,       { Electronic mail section }
  Viewer,      { Archive/Protocol Stuff  }
  Archive,     { ZIP/ARJ/LHA Viewing     }
  ACS,         { ACS System              }
  File0,       { Low Level File Xfer     }
  File1,       { Change File Areas       }
  File2,       { File NewScan Config     }
  File3,       { File Upload             }
  Filexfer,    { File transfer section   }
  Voting,      { Voting section }
  Mycomman,    { junk }
  BBSList,     { BBS Listing Routines }
  NUV,         { New User Voting }
  {ZIPLab, }     { ViSiON/2 ZIP Lab }
  FileSort,    { File Sort Routines }
  FileSys0,    { File SysOp Low Level }
  FileSys1,    { File SysOp Misc }
  FileSys2,    { More File SysOp Misc }
  New_FS,      { File Area Sysop Stuff }
  UserList,    { User Listing Routines }
  NodeChat,    { Multi-Node Chatting Stuff }
  Chat,        { Fake Chat Routines! }

  Feedback,
  MainMenu,    { Main menu commands }
  NewMain,     { Menu routines }
  Waitcall,    { Waiting for calls }
  Login2,
  Getlogin,    { Log-in procedure }
  Init;        { Initialization routines }

{$IFDEF OVERLAYS}
{$O INIT}
{$O PROTOCOL}
{$O OVERRET1}
{$O WAITCALL}
{$O GETLOGIN}
{$O LOGIN2}
{$O CONFIGUR}
{$O DOORS}
{$O VOTING}
{$O MYCOMMAN}
{$O NUV}
{$O EMAIL0} {$O GROUP} {$O GROUP1}
{$O EMAIL}
{$O VIEWER}
{$O ARCHIVE}
{$O FILE0}
{$O FILE1} {$O FILE2} {$O FILE3}
{$O FILEXFER}
{$O FILESORT} {$O FILESYS0} {$O FILESYS1} {$O FILESYS2}
{$O NEW_FS}
{$O TOPUSER}
{$O WAITCALL}
{$O MESS0} {$O MESS1} {$O MESS2} {$O MESS3} {$O MESS4}
{$O BULLETIN}
{$O MESSSYS0}
{$O LINEEDIT}
{$O ANSIEDIT}
{$O FEEDBACK}
{$O RUMORS}
{$O USERLIST}
{$O NODECHAT}
{$O CHAT}
{$O BBSLIST}
{$O SUBSOVR}
{$O CHATSTUF}
{$O MAINMENU}
{$O NEWMAIN}
{$ENDIF}

                                                                              {
 ! [ ViSiON/2 MAIN BEGIN-END BLOCK ] !                                         }

Var GotoVisionTerm : Boolean;
    Temp : Byte;

Const No_Modem : Boolean = False;

Begin

  For Temp := 1 to EnvCount Do
    If (UpString(ParamStr(Temp)) = '/M-') Or (UpString(ParamStr(Temp)) = '/L')
      Then Begin
        Null_Modem;
        No_Modem := True;
      End;

  If (Cfg.UseCom = 0) AND (No_Modem = False)
    Then Begin
      Null_Modem;
      No_Modem := True;
    End;

  TextAttr := 1;  Write(usr,'þ ');
  TextAttr := 9;  Writeln(usr,'Scanning Configuration Variables...');

  Dos_GetMem(Strng,SizeOf(Strng^) + 1);
  ReadStrings;

  ValidConfiguration;

  InitViSiON(True);

  If Not No_Modem Then
{  If Cfg.Use_Fos Then Begin }

    If Not Install_Fossil(Cfg.UseCom) Then
    Begin
      ClrScr;
      TextAttr:=14; Write(usr,#13#10'ERROR: ');
      TextAttr:=9; Writeln(usr,'FOSSIL Driver not present...');
      Writeln;
      TextAttr:=15; Write(usr,'þ');
      TextAttr:=7; Writeln(usr,' Run BNU or X00 before running ViSiON/2!'#13);
      TextAttr:=15; Write(usr,'þ');
      TextAttR:=7; Writeln(usr,' Make sure you have the right COM Port set!'#13);
      Halt (4);
    End;
    TextAttr:=1;  Write(usr,'þ ');
    TextAttr:=9;  Writeln(usr,'Fossil Driver Recognized...');
    SetParam(Cfg.UseCom,Cfg.DefBaudRate,False);

{

  End Else Begin
    TextAttr := 1; Write(usr,'þ ');
    Textattr := 9; Writeln(Usr,'Opening Internal Com Routines..');
    OpenComPort;
  End;

}

  CheckBreak := False;

  AnsiEditInUse:=False;

  FromDoor := Paramcount >= 3;

  If (FromDoor) and (Local) then Begin
    MsgConf := 1;
    FileConf := 1;
    KeepQuite := True;
    ConnectStr := 'Local Login';
  End;

  Repeat
    GotoVisionTerm := False;
    ReturnFromDoor;
    If Not Fromdoor Then
      Begin
        GotoVisionTerm := WaitForACall;
        If Not GotoVisionTerm Then GetLoginProc
      End;

    If Not GotoVisionTerm Then Begin
      Do_Menu_System;
      FromDoor := False;
      If Not Disconnected
        Then Disconnect;
      Ensureclosed;
      Clrscr;

      If SysNext Then Begin
        DontAnswer;
        Halt(4)
      End;

      InitVision(false)
    End

  Until Not GotoVisionTerm;

  DontAnswer;
  ClosePort;

  Halt(0)

End.
