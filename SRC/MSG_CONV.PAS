{$R-,S+,I-,D+,F-,V-,B-,N-,L+ }
{$M 20048,0,1024}

Program NewMsgs;          (* Text Conversion Program v1.0á *)
                          (* Written By: Crimson Blade *)

Uses Dos,
     Crt,
     ConfigRt,
     GenTypes,
     StatRet,
     MDosIO,
     General;

Var TextFile : File Of Lstr;
    MailFile : File Of MailPtrRec;
    LastMailFile,
    LastTextFile : Lstr;

  Procedure AssignName(Txt,MailName : Sstr);
  Var CurTextFile,
      CurMailFile : Lstr;
  Begin
    CurTextFile := Cfg.TextDir + Txt;
    CurMailFile := Cfg.Textdir + MailName;
    If (CurTextFile <> LastTextFile) Or (CurMailFile <> LastMailFile)
    Then Begin
      Assign(TextFile,CurTextFile);
      If Not Dos_Exists(CurTextFile)
        Then Rewrite(TextFile)
        Else Reset(TextFile);
      Assign(MailFile,CurMailFile);
      If Not Dos_Exists(CurMailFile)
        Then Rewrite(MailFile)
        Else Reset(MailFile);
    End;
    LastTextFile := CurTextFile;
    LastMailFile := CurMailFile;
  End;

  Function MakeText (Txt,MailName : SStr; OverRide : Lstr) : LongInt;
  Var Size : Longint;
      X,Line : Byte;
      Temp : Word;
      T : Text;
      S : String;
      L : LStr;
      TooLong : Boolean;
      Mail : MailPtrRec;
  Begin

    AssignName(Txt,MailName);

    MakeText := -1;

    FillChar(Mail,SizeOf(Mail),0);

    Size := FileSize(TextFile);
    Mail.TextPtr := Size;

    Seek(TextFile,Size);

      TooLong := False;
      Mail.TotalLines := 0;

      If Not Dos_Exists(OverRide)
        Then Exit;

      Assign(T,OverRide);
      Reset(T);

      While Not Eof(T) Do Begin
        Readln(T,S);
        TooLong := Length(S) > 80;
        L := S;
        Write(TextFile,L);
        Inc(Mail.TotalLines);
      End;

      Close(T);

      If TooLong Then
        Writeln(^M'The maximum line length is 80 characters!'^M);

    Size := FileSize(MailFile);
    Seek(MailFile,Size);
    Write(MailFile,Mail);

    MakeText := Size;
  End;

  Function FName(Sector : LongInt) : Sstr;
  Var N : Sstr;
  Begin
    Str(Sector,N);
    FName := N + '.MSG';
  End;

  Procedure Change_Base( Name : Mstr; CurFileName : Sstr; Conf : Byte );
  Var BulFile : File Of BulRec;
      Bul : BulRec;
      X,Y : Word;
      S1,S2 : Lstr;
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

    Writeln('þ Converting Base: ',Name);

    S1 := CurFileName + '.T' + Strr(Conf);
    S2 := CurFileName + '.M' + Strr(Conf);

    For X := 0 To ( FileSize(BulFile) - 1 )
    Do Begin
      Seek(BulFile,X);
      Read(BulFile,Bul);
      Bul.Line := MakeText(S1,S2,Cfg.TextDir + FName(Bul.Line));
      Seek(BulFile,X);
      Write(BulFile,Bul);
    End;
    Close(BulFile);
    Close(TextFile);
    Close(MailFile);
  End;

  Procedure Change_Message_Bases( Conf : Byte );
  Var BDFile : File Of BoardRec;
      Board : BoardRec;
      X : Word;
  Begin
    If Not Dos_Exists(Cfg.BoardDir + 'BOARDDIR.' + Strr(Conf))
      Then Exit;
    Assign(BDFile,Cfg.BoardDir + 'BOARDDIR.' + Strr(Conf));
    Reset(BDFile);
    For X := 1 to FileSize(BDFile)
    Do Begin
      Seek(BDFile,X - 1);
      Read(BDFile,Board);
      Change_Base(Board.BoardName,Board.ShortName,Conf);
    End;
    Close(BDFile);
  End;

  Procedure Change_All_Conferences;
  Var X : Byte;
  Begin
    Writeln('Packing Message Bases, Conference #1');
    If Cfg.MaxMsgConf < 1
      Then Change_Message_Bases(1)
      Else For X := 1 to Cfg.MaxMsgConf
      Do Begin
        If X > 1
          Then Writeln('Packing Message Bases, Conference #'+Strr(X));
        Change_Message_Bases(X);
      End
  End;

  Procedure Change_EMail;
  Var EMailFile : File Of MailRec;
      EMail : MailRec;
      X,Y : Word;
  Begin
    If Not Dos_Exists(Cfg.DataDir + 'MAIL.')
      Then Exit;
    Assign(EMailFile,Cfg.DataDir + 'MAIL.');
    Reset(EMailFile);
    If FileSize(EMailFile) <= 0 Then Begin
      Close(EMailFile);
      Exit;
    End;
    Writeln('þ Converting E-Mail...');
    For X := 1 To ( FileSize(EMailFile) - 1 )
    Do Begin
      Seek(EMailFile,X);
      Read(EMailFile,EMail);
      Email.Line := MakeText('EMAIL.TXT','EMAIL.MAP',Cfg.TextDir + FName(EMail.Line));
      Seek(EMailFile,X);
      Write(EMailFile,EMail);
    End;
    Close(EMailFile);
    Close(TextFile);
    Close(MailFile);
  End;

  Procedure Change_FeedBack;
  Var EMailFile : File Of MailRec;
      EMail : MailRec;
      X,Y : Word;
  Begin
    If Not Dos_Exists(Cfg.DataDir + 'FEEDBACK.')
      Then Exit;
    Assign(EMailFile,Cfg.DataDir + 'FEEDBACK.');
    Reset(EMailFile);
    If FileSize(EMailFile) <= 0 Then Begin
      Close(EMailFile);
      Exit;
    End;
    Writeln('þ Converting Feedback...');
    For X := 0 To ( FileSize(EMailFile) - 1 )
    Do Begin
      Seek(EMailFile,X);
      Read(EMailFile,EMail);
      Email.Line := MakeText('FEEDBACK.TXT','FEEDBACK.MAP',Cfg.TextDir + FName(EMail.Line));
      Seek(EMailFile,X);
      Write(EMailFile,EMail);
    End;
    Close(EMailFile);
    Close(TextFile);
    Close(MailFile);
  End;

  Procedure Change_News;
  Var NewsFile : File Of NewsRec;
      News : NewsRec;
      X,Y : Word;
  Begin
    If Not Dos_Exists(Cfg.DataDir + 'NEWS.')
      Then Exit;
    Assign(NewsFile,Cfg.DataDir + 'NEWS.');
    Reset(NewsFile);
    If FileSize(NewsFile) <= 0
    Then Begin
      Close(NewsFile);
      Exit;
    End;
    Writeln('þ Converting News...');
    For X := 0 To ( FileSize(NewsFile) - 1 )
    Do Begin
      Seek(NewsFile,X);
      Read(NewsFile,News);
      News.Location := MakeText('NEWS.TXT','NEWS.MAP',Cfg.TextDir + FName(News.Location));
      Seek(NewsFile,X);
      Write(NewsFile,News);
    End;
    Close(NewsFile);
    Close(TextFile);
    Close(MailFile);
  End;

  Procedure Nuke_AutoMess;
  Var SFile : File Of StatRec;
      Stat : StatRec;
  Begin
    If Not Dos_Exists(Cfg.VisionDir + 'STATUS.DAT')
      Then Exit;
    Assign(SFile,Cfg.VisionDir + 'STATUS.DAT');
    Reset(SFile);
    Read(SFile,Stat);
    Stat.ToNext := -1;
    Seek(SFile,0);
    Write(SFile,Stat);
    Close(SFile);
  End;

  Procedure Nuke_Forms;
  Var UFile : File Of UserRec;
      U : UserRec;
      X,Y : Byte;
  Begin
    If Not Dos_Exists(Cfg.DataDir + 'USERS.')
      Then Exit;
    Assign(UFile,Cfg.DataDir + 'USERS.');
    Reset(UFile);
    Writeln('þ One Moment...');
    For X := 1 to FileSize(UFile) - 1
    Do Begin
      Seek(UFile,X);
      Read(UFile,U);
      For Y := 1 to 5
        Do U.Infoform[y] := -1;
      U.EmailAnnounce := -1;
      Seek(UFile,X);
      Write(UFile,U);
    End;
    Close(UFile);
  End;

  Procedure Nuke_BBS;
  Var F : File;
  Begin
    Assign(F,Cfg.Datadir + 'BBSLIST.DAT');
    Erase(F);
  End;

Var F : File;
Begin
  Writeln('Text Conversion Program, 0.69 -> 0.70á');
  Writeln('For use with ViSiON/2 BBS Only!');
  Writeln('Written By Crimson Blade'#10#13);
  Writeln;
  ReadCfg;
  LastTextFile := '';
  Change_All_Conferences;
  Change_EMail;
  Change_Feedback;
  Change_News;
  Nuke_AutoMess;
  Nuke_Forms;
  Nuke_BBS;
  Assign(F,'MSG_CONV.EXE');
  Erase(F);
End.