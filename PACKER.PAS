{$R-,S+,I-,D+,F-,V-,B-,N-,L+ }
{$M 30720,0,1024}

Program Packer;           (* Message Packing Utility v1.0á *)
                          (* Written By: Crimson Blade *)

Uses Dos,
     Crt,
     ConfigRt,
     GenTypes,
     StatRet,
     MDosIO,
     General,
     MNET;

Type Pack_What = Record
       Messages,
       EMail,
       Feedback,
       News,
       BBSList,
       Forms    : Boolean;
       MsgConference : Array[1..99] Of Boolean;
     End;

Var TFile,
    OldTFile : File Of Lstr;
    MFile,
    OldMFile : File Of MailPtrRec;
    S : Lstr;
    M : MailPtrRec;
    SaveX,SaveY : Byte;
    PackRec : Pack_What;

  Procedure Show(S : String);
  Begin
    TextAttr := 8;
    Write('þ ');
    TextAttr := 15;
    Write(S);
  End;

  Procedure UpDatePercent(A,B:Integer);
  Var Percent : Real;
  Begin
    Inc(A);
    If (A>0) and (B>0)
      Then Percent := (A/B) * 100
      Else Percent := 0;
    GotoXy(SaveX,SaveY);
    TextAttr := 3;
    Write('[');
    TextAttr := 15;
    Write(Percent:0:0);
    TextAttr := 11;
    Write('%');
    TextAttr := 3;
    Write(']');
    TextAttr := 9;
  End;

  Procedure SaveXY;
  Begin
    SaveX := WhereX;
    SaveY := WhereY;
  End;

  Function AssignFiles(Name : Sstr; Conf : Byte) : Boolean;
  Var Ext1,Ext2 : String[4];
  Begin
    Ext1 := '.TXT';
    Ext2 := '.MAP';
    If Conf > 0 Then Begin
      Ext1 := '.T' + Strr(Conf);
      Ext2 := '.M' + Strr(Conf);
    End;
    AssignFiles := False;
    If (Not Dos_Exists(Cfg.TextDir + Name + Ext1))
    Or (Not Dos_Exists(Cfg.TextDir + Name + Ext2))
      Then Exit;
    Assign (OldTFile,Cfg.TextDir + Name + Ext1);
    Reset  (OldTFile);
    Assign (OldMFile,Cfg.TextDir + Name + Ext2);
    Reset  (OldMFile);
    Assign (TFile,Cfg.TextDir + Name + '.1');
    Rewrite(TFile);
    Assign (MFile,Cfg.TextDir + Name + '.2');
    Rewrite(MFile);
    AssignFiles := True;
  End;

  Procedure Do_Names(Name : SStr; Conf : Byte);
  Var Ext1,Ext2 : String[4];
  Begin
    Ext1 := '.TXT';
    Ext2 := '.MAP';
    If Conf > 0 Then Begin
      Ext1 := '.T' + Strr(Conf);
      Ext2 := '.M' + Strr(Conf);
    End;
    Close(OldTFile);
    Close(OldMFile);
    Erase(OldTFile);
    Erase(OldMFIle);
    Close(TFile);
    Close(MFile);
    Rename(TFile,Cfg.TextDir + Name + Ext1);
    Rename(MFile,Cfg.TextDir + Name + Ext2);
  End;

  Procedure Pack_EMail;
  Var EMailFile : File Of MailRec;
      EMail : MailRec;
      X,Y,Size : Word;
  Begin

    If Not PackRec.EMail
      Then Exit;

    If Not Dos_Exists(Cfg.DataDir + 'MAIL.')
      Then Exit;

    Assign(EMailFile,Cfg.DataDir + 'MAIL.');
    Reset(EMailFile);

    If FileSize(EMailFile) <= 0 Then Begin
      Close(EMailFile);
      Exit;
    End;

    If Not AssignFiles('EMAIL',0)
      Then Begin
        Close(EMailFile);
        Exit;
      End;

    Size := FileSize(EMailFile);

    Show('Packing E-Mail...');
    SaveXy;

    For X := 1 To ( FileSize(EMailFile) - 1 ) { Account #0 is a filler }
    Do Begin

      UpdatePercent(X,Size);
      Seek(EMailFile,X);              { Seek Record X in EMail File }
      NRead(EMailFile,EMail);          { Read into variable EMail    }

      If (Email.Line >= 0)
      And (Email.Line < FileSize(OldMFile))  { Check Range }
      Then Begin
        Seek(OldMFile,Email.Line);        { Seek OldMailFile }
        NRead(OldMFile,M);                 { Read MailPtr Record }
        Email.Line := FileSize(MFile);    { Reset Mail File Ptr }
        Seek(EMailFile,X);                { Seek Mail Record }
        NWrite(EMailFile,EMail);           { Write New Record Over Old }
        Seek(OldTFile,M.TextPtr);         { Seek Old TextFile }
        M.TextPtr := FileSize(TFile);
        For Y := 1 to M.TotalLines        { Transfer Text }
        Do Begin
          NRead(OldTFile,S);
          NWrite(TFile,S);
        End;
        Seek(MFile,FileSize(MFile));      { Update Mail Ptr Rec }
        NWrite(MFile,M);
      End;

    End;
    Close(EMailFile);
    Do_Names('EMAIL',0);
    Writeln;
  End;

  Procedure Pack_AutoMes;
  Var SFile : File Of StatRec;
      Stat : StatRec;
      X : Word;
  Begin
    If Not Dos_Exists(Cfg.VisionDir + 'STATUS.DAT')
      Then Exit;

    Assign(SFile,Cfg.VisionDir + 'STATUS.DAT');
    Reset(SFile);
    NRead(SFile,Stat);

    If Stat.ToNext < 0
      Then Begin
        Close(SFile);
        Exit;
      End;

    If Not AssignFiles('AUTOMESS',0)
      Then Begin
        Close(SFile);
        Exit;
      End;

    Show('Packing Auto-Message...');

    Seek(OldMFile,Stat.ToNext);
    NRead(OldMFile,M);

    Stat.ToNext := 0;
    Seek(OldTFile,M.TextPtr);

    For X := 1 to M.TotalLines
    Do Begin
      NRead(OldTFile,S);
      NWrite(TFile,S);
    End;

    M.TextPtr := 0;

    Seek(MFile,0);
    NWrite(MFile,M);

    Seek(SFile,0);
    NWrite(SFile,Stat);

    Close(SFile);
    Do_Names('AUTOMESS',0);
    Writeln;
  End;

  Procedure Pack_FeedBack;
  Var FeedbackFile : File Of MailRec;
      Feedback : MailRec;
      X,Y,Size : Word;
  Begin

    If Not PackRec.Feedback
      Then Exit;

    If Not Dos_Exists(Cfg.DataDir + 'FEEDBACK.')
      Then Exit;

    Assign(FeedbackFile,Cfg.DataDir + 'FEEDBACK.');
    Reset(FeedbackFile);

    If FileSize(FeedBackFile) <= 0 Then Begin
      Close(FeedBackFile);
      Exit;
    End;

    If Not AssignFiles('FEEDBACK',0)
      Then Begin
        Close(FeedBackFile);
        Exit;
      End;
    
    Show('Packing Feedback...');
    SaveXY;

    Size := FileSize(FeedBackFile);

    For X := 0 To ( FileSize(FeedBackFile) - 1 ) { Account #0 is a filler }
    Do Begin

      UpdatePercent(X,Size);
      Seek(FeedbackFile,X);              { Seek Record X in FB File }
      NRead(FeedbackFile,Feedback);       { Read into variable EMail    }

      If (FeedBack.Line >= 0)
      And (FeedBack.Line < FileSize(OldMFile))  { Check Range }
      Then Begin
        Seek(OldMFile,FeedBack.Line);     { Seek OldMailFile }
        NRead(OldMFile,M);                 { Read MailPtr Record }
        FeedBack.Line := FileSize(MFile); { Reset Mail File Ptr }
        Seek(FeedBackFile,X);             { Seek Mail Record }
        NWrite(FeedBackFile,Feedback);     { Write New Record Over Old }
        Seek(OldTFile,M.TextPtr);         { Seek Old TextFile }
        M.TextPtr := FileSize(TFile);
        For Y := 1 to M.TotalLines        { Transfer Text }
        Do Begin
          NRead(OldTFile,S);
          NWrite(TFile,S);
        End;
        Seek(MFile,FileSize(MFile));      { Update Mail Ptr Rec }
        NWrite(MFile,M);
      End;

    End;
    Close(FeedBackFile);
    Do_Names('FEEDBACK',0);
    Writeln;
  End;

  Procedure Pack_Base( Name        : Mstr;
                       CurFileName : Sstr;
                       Conf        : Byte;
                       Auto_Del    : Integer );

  Var BulFile : File Of BulRec;
      Bul     : BulRec;
      X,Y,
      Size,
      Start   : Word;
      ReMap   : Boolean;

      Procedure Auto_Delete;
      Var X,A: Integer;
      Begin
        TextAttr := 12; Write(' (');
        TextAttr := 4;  Write('Auto-Deleting');
        TextAttr := 12; Write(')');
        X := 0;
        For A := Start to (FileSize(BulFile) - 1)
        Do Begin
          Seek(BulFile,A);
          NRead(BulFile,Bul);
          Seek(BulFile,X);
          NWrite(BulFile,Bul);
          Inc(X);
        End;
        Seek(BulFile,X);
        Truncate(BulFile);
      End;

  Begin
    If Not Dos_Exists(Cfg.BoardDir + CurFileName + '.' + Strr(Conf))
      Then Exit;

    Assign(BulFile,Cfg.BoardDir + CurFileName + '.' + Strr(Conf));
    Reset(BulFile);

    If FileSize(BulFile) <= 0
      Then Begin
        Close(BulFile);
        Exit;
      End;

    If Not AssignFiles(CurFileName,Conf)
      Then Begin
        Close(BulFile);
        Exit;
      End;

    Show('Packing Base: '+Name+'...');
    SaveXY;

    Size := FileSize(BulFile);

    ReMap := False;

    If (Size-1) > Auto_Del
      Then Begin
        Start := (Size - Auto_Del + 1);
        ReMap := True;
      End
      Else Start := 0;

    For X := Start To ( FileSize(BulFile) - 1 )
    Do Begin
      UpdatePercent(X,Size);
      Seek(BulFile,X);
      NRead(BulFile,Bul);

      If (Bul.Line >= 0)
      And (Bul.Line < FileSize(OldMFile))
      Then Begin
        Seek(OldMFile,Bul.Line);
        NRead(OldMFile,M);
        Bul.Line := FileSize(MFile);
        Seek(BulFile,X);
        NWrite(BulFile,Bul);
        Seek(OldTFile,M.TextPtr);
        M.TextPtr := FileSize(TFile);
        For Y := 1 to M.TotalLines
        Do Begin
          NRead(OldTFile,S);
          NWrite(TFile,S);
        End;
        Seek(MFile,FileSize(MFile));
        NWrite(MFile,M);
      End;
    End;

    If ReMap Then Auto_Delete;

    Close(BulFile);
    Do_Names(CurFileName,Conf);
    Writeln;
  End;

  Procedure Pack_Message_Bases( Conf : Byte );
  Var BDFile : File Of BoardRec;
      Board : BoardRec;
      X : Word;
  Begin
    If Not PackRec.MsgConference[Conf]
      Then Exit;
    If Not Dos_Exists(Cfg.BoardDir + 'BOARDDIR.' + Strr(Conf))
      Then Exit;
    Assign(BDFile,Cfg.BoardDir + 'BOARDDIR.' + Strr(Conf));
    Reset(BDFile);
    For X := 1 to FileSize(BDFile)
    Do Begin
      Seek(BDFile,X - 1);
      NRead(BDFile,Board);
      Pack_Base(Board.BoardName,Board.ShortName,Conf,Board.AutoDel);
    End;
    Close(BDFile);
  End;

  Procedure Pack_All_Conferences;
  Var X : Byte;
  Begin
    TextAttr := 13;
    Show('Packing Message Bases - Conference #1');
    Writeln;
    If Cfg.MaxMsgConf < 1
      Then Pack_Message_Bases(1)
      Else For X := 1 to Cfg.MaxMsgConf
      Do Begin
        If X > 1 Then Begin
          TextAttr := 13;
          Show('Packing Message Bases - Conference #'+Strr(X));
          Writeln;
        End;
        Pack_Message_Bases(X);
      End
  End;

  Procedure Pack_Infoforms;
  Var UFile : File Of UserRec;
      User : UserRec;
      X,Y,Cur,Size : Word;
  Begin

    If Not PackRec.Forms
      Then Exit;

    If Not Dos_Exists(Cfg.DataDir + 'USERS.')
      Then Exit;

    Assign(UFile,Cfg.DataDir + 'USERS.');
    Reset(UFile);

    If FileSize(UFile) < 1
      Then Begin
        Close(UFile);
        Exit;
      End;

    If Not AssignFiles('FORMS',0)
      Then Begin
        Close(UFile);
        Exit;
      End;

    Show('Packing Infoforms...');
    SaveXY;

    Size := FileSize(UFile);

    For X := 1 To ( FileSize(UFile) - 1 )
    Do Begin

      UpdatePercent(X,Size);
      Seek(UFile,X);
      NRead(UFile,User);


      For Cur := 1 to 5 Do Begin

        If (User.InfoForm[Cur] > 0)
        And (User.InfoForm[Cur] < FileSize(OldMFile))
        Then Begin
          Seek(OldMFile,User.Infoform[Cur]);
          NRead(OldMFile,M);
          User.Infoform[Cur] := FileSize(MFile);
       {   Seek(UFile,X);
          NWrite(UFile,User); }
          Seek(OldTFile,M.TextPtr);
          M.TextPtr := FileSize(TFile);
          For Y := 1 to M.TotalLines
          Do Begin
            NRead(OldTFile,S);
            NWrite(TFile,S);
          End;
          Seek(MFile,FileSize(MFile));
          NWrite(MFile,M);
        End;
      End;

      Seek(UFile,X);
      NWrite(UFile,User);

    End;
    Close(UFile);
    Do_Names('FORMS',0);
    Writeln;
  End;

  Procedure Pack_News;
  Var NewsFile : File Of NewsRec;
      News : NewsRec;
      X,Y,Size : Word;
  Begin

    If Not PackRec.News
      Then Exit;

    If Not Dos_Exists(Cfg.DataDir + 'NEWS.')
      Then Exit;

    Assign(NewsFile,Cfg.DataDir + 'NEWS.');
    Reset(NewsFile);

    If FileSize(NewsFile) <= 0 Then Begin
      Close(NewsFile);
      Exit;
    End;

    If Not AssignFiles('NEWS',0)
      Then Begin
        Close(NewsFile);
        Exit;
      End;

    Show('Packing News...');
    SaveXY;

    Size := FileSize(NewsFile);

    For X := 0 To ( FileSize(NewsFile) - 1 )
    Do Begin

      UpdatePercent(X,Size);
      Seek(NewsFile,X);
      nRead(NewsFile,News);

      If (News.Location >= 0)
      And (News.Location < FileSize(OldMFile))
      Then Begin
        Seek(OldMFile,News.Location);
        nRead(OldMFile,M);
        News.Location := FileSize(MFile);
        Seek(NewsFile,X);
        nWrite(NewsFile,News);
        Seek(OldTFile,M.TextPtr);
        M.TextPtr := FileSize(TFile);
        For Y := 1 to M.TotalLines
        Do Begin
          nRead(OldTFile,S);
          nWrite(TFile,S);
        End;
        Seek(MFile,FileSize(MFile));
        nWrite(MFile,M);
      End;

    End;
    Close(NewsFile);
    Do_Names('NEWS',0);
    Writeln;
  End;

  Procedure Pack_BBSList;
  Var BBSFile : File Of BBSRec;
      BBS : BBSRec;
      X,Y,Size : Word;
  Begin

    If Not PackRec.BBSList
      Then Exit;

    If Not Dos_Exists(Cfg.DataDir + 'BBSLIST.DAT')
      Then Exit;

    Assign(BBSFile,Cfg.DataDir + 'BBSLIST.DAT');
    Reset(BBSFile);

    If FileSize(BBSFile) <= 0 Then Begin
      Close(BBSFile);
      Exit;
    End;

    If Not AssignFiles('BBSANSI',0)
      Then Begin
        Close(BBSFile);
        Exit;
      End;

    Show('Packing BBS List ANSi''s...');
    SaveXY;

    Size := FileSize(BBSFile);

    For X := 0 To ( FileSize(BBSFile) - 1 )
    Do Begin

      UpdatePercent(X,Size);
      Seek(BBSFile,X);
      nRead(BBSFile,BBS);

      If (BBS.Extended >= 0)
      And (BBS.Extended < FileSize(OldMFile))
      Then Begin
        Seek(OldMFile,BBS.Extended);
        nRead(OldMFile,M);
        BBS.Extended := FileSize(MFile);
        Seek(BBSFile,X);
        nWrite(BBSFile,BBS);
        Seek(OldTFile,M.TextPtr);
        M.TextPtr := FileSize(TFile);
        For Y := 1 to M.TotalLines
        Do Begin
          nRead(OldTFile,S);
          nWrite(TFile,S);
        End;
        Seek(MFile,FileSize(MFile));
        nWrite(MFile,M);
      End;

    End;
    Close(BBSFile);
    Do_Names('BBSANSI',0);
    Writeln;
  End;

  Procedure Help;
  Const Space = '                        ';
  Begin
    ClrScr;
    Writeln;
    TextAttr := 15;
    Writeln(Space+'ViSiON/2 Text Packer Help'#13#10);
    Writeln(Space+'ALL Nodes should be down when packing!');
    TextAttr := 3;
    Writeln(Space+'/M  - No Message Packing');
    Writeln(Space+'/E  - No E-Mail Packing');
    Writeln(Space+'/F  - No Feedback Packing');
    Writeln(Space+'/N  - No News Packing');
    Writeln(Space+'/B  - No BBS List Packing');
    Writeln(Space+'/I  - No INFOFORM Packing');
    Writeln(Space+'/xx - Don''t Pack Message Conference # XX');
    Writeln;
    Halt(0);
  End;

  Procedure No_Use(VAR B : Boolean; S : String);
  Begin
    B := FALSE;
    TextAttr := 8;
    Write('þ ');
    TextAttr := 15;
    Writeln(S + ' will not be packed.');
  End;

Var X : Byte;
    SS : String;
Begin
  FillChar(PackRec,SizeOf(PackRec),1);
  TextAttr := 8;
  ClrScr;
  For X := 1 to 79
    Do Write(#196);
  Writeln;
  TextAttr := 15;
  Writeln('ViSiON/2 Text Storage Packer  þ  Written By Crimson Blade  þ  Version 1.3á');
  TextAttr := 3;
  Writeln('(C) RE 1993.  All jams and jellies preserved.  Use Parameter "/?" for Help');
  TextAttr := 8;
  For X := 1 to 79
    Do Write(#196);
  Writeln;
  Window(1,5,80,24);

  For X := 1 to ParamCount Do Begin
    SS := ParamStr(X);
    If SS[1] = '/' Then Begin
      Case Upcase(SS[2]) Of
        '?' : Help;
        'M' : No_Use(PackRec.Messages,'All Messages');
        'E' : No_Use(PackRec.EMail,'E-Mail');
        'F' : No_Use(PackRec.FeedBack,'FeedBack');
        'N' : No_Use(PackRec.News,'News');
        'B' : No_Use(PackRec.BBSList,'BBS Listings');
        'I' : No_Use(PackRec.Forms,'Infoforms');
        Else Begin
          Delete(SS,1,1);
          If Valu(SS) > 0
            Then No_Use(PackRec.MsgConference[Valu(SS)],
                       'Message Conference #'+SS);
        End
      End
    End;
  End;

  ReadCfg;
  Pack_EMail;
  Pack_Feedback;
  Pack_News;
  Pack_AutoMes;
  Pack_InfoForms;
  Pack_BBSList;
  Pack_All_Conferences;
  Window(1,1,80,25);
  ClrScr;
  TextAttr := 3;
  Write('þ ');
  TextAttr := 15;
  Writeln('All text has been Compressed, '+Cfg.SysOpName);
  TextAttr := 3;
  Write('þ ');
  TextAttr := 15;
  Writeln('Thanks for choosing The Revision!');
End.