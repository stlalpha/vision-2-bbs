{$R-,S-,I-,D-,F+,V-,B-,N-,L+,O+ }

Unit Mess4;
                          {/ QWK routines .. /}
Interface

Uses GenTypes;

Procedure ProcessRep;
Procedure MakeQwk;
Procedure GetMaxQwk;

Implementation

Uses Dos, Crt, MNet, ConfigRT, GenSubs, Windows, Subs1, Subs2, Mess0,
     StatRet, UserRet, Flags, TextRet, Mainr1, Protocol;

Var Index : Real;
    IndexRot : Integer;
    IndexArray : Array[1..300] Of Real;
    TextFile : File;

Procedure Create_Index (CurArea : Integer);
Type BSingle = Array [0..3] of Byte;
Var Preal : Real;
    R : Array [0..5] of byte absolute preal;
    S : SStr;
    T : File Of Byte;
    Z : Byte;
    B : BSingle;
    X : Integer;
Begin
  S := Strr(CurArea);
  While Length(S) < 3 Do
    Insert('0',S,1);
  Assign(T,Cfg.VisionDir + S +'.NDX');
  Rewrite(T);
  For X := 1 To IndexRot Do Begin
    Preal := IndexArray[x];
    Seek(T,FileSize(T));
    B[3] := R[0];
    Move (R[3],B[0],3);
    For Z := 0 to 3
      Do Write(T,B[Z]);
    Z := Ord(Char(CurArea));
    Write(T,Z);
  End;
  Close(T);
End;

Procedure AddToDat(B : BulRec; M : Message; CurArea,MsgNum,Rot : Integer);
TYPE String128 = String[128];
VAR Done : Boolean;
    TotalBlocks,X,A : Integer;
    F : Byte;
    S : String128;
    St : Array[1..63] of String128;

    Function Strip_Pipe(Str:Lstr):Lstr;
    VAR St:Lstr; X:Byte; Done:Boolean;
    BEGIN
      Done:=False;
      St:='';
      X:=1;
      While X <= Length(Str)
      Do Begin
        If Str[x] = '|' Then Begin
          If (Valu(Str[X+1]+Str[X+2])>0) or
          (Str[X+1] in ['B','C']) And ( Valu(Str[X+2]) > 0 )
            Then Inc(X,2);
        End Else
        St := St + Str[X];
        Inc(X);
      End;
      Strip_Pipe := St;
    END;

    Function Fill(Str:String; Spaces:Byte):String;
    Var St:String;
        X:Byte;
    Begin
      St[0] := #0;
      For X:=1 to Spaces
        Do St:=St+' ';
      If Length(Str) > Spaces
        Then Str[0] := Chr(Spaces);
      St := Str;
      If (Length(St)<Spaces) Then
        For X := 1 to Spaces - Length(St)
          Do St := St + ' ';
      If Length(St) > Spaces
        Then St[0] := Chr(Spaces);
      Fill := St;
    End;

    Procedure WriteText(S : String128);
    Var Err : Word;
        A : Array[1..128] Of Char;
    Begin
      If Length(S) < 128
        Then S := Fill(S,128);
      For Err := 1 to 128
        Do A[Err] := S[Err];
      Seek(TextFile,FileSize(TextFile));
      BlockWrite(TextFile,A,1,Err);
    End;

    Procedure MakeTxt;
    VAR A,Z,C,L,N:Byte;
        Temp:Lstr;
    Begin
      FillChar(St,SizeOf(St),#32);
      C := 1;
      L := 1;
      N := M.Numlines;
      If N > 100
        Then N := 100;
      For A:=1 to N
      Do Begin
        If M.Text[A]<>''
        Then Begin
          Temp := Strip_Pipe(M.Text[A]);
          For Z := 1 to Length(Temp)
          Do Begin
            St[L][C]:=Temp[Z];
            Inc(C);
            If C >= 129
            Then Begin
              C:=1;
              Inc(L);
            End;
          End;
          St[L][C]:=#227;
          Inc(C);
          If C >= 129
          Then Begin
            C:=1;
            Inc(L);
          End;
        End Else Begin
          St[L][C]:=#227;
          Inc(C);
          If C >= 129 Then Begin
            C:=1;
            Inc(L);
          End;
        End;
      End;
      TotalBlocks := L;
    End;

Var Err,CB : Word;
    Wow : Byte;
    Ax : Array[1..128] Of Char;
Begin
  If Index = 2 Then Begin
    Assign(TextFile,Cfg.VisionDir+'MESSAGES.DAT');
    Rewrite(TextFile,128);
    S := Fill('Produced by ViSiON/2 "The REVision" (c) Ruthless Ent'+
              'erprises 1993',128);
    WriteText(S);
  End;
  Seek(TextFile,FileSize(TextFile));

  MakeTxt;
  S[0] := #0;

    If B.Recieved Then
      S:='-' Else S:=' ';
    S:=S+Fill(Strr(MsgNum),7);
    S:=S+Fill(TDateStr(B.When),8);
    S:=S+Fill(TimeStr_24(B.When),5);
    S:=S+Fill(B.SentTo,25);
    S:=S+Fill(B.LeftBy,25);
    S:=S+Fill(B.Title,25);
    S:=S+'            ';                 {Password is unused by ViSiON/2}
    S:=S+Fill(Strr(B.RepNumber),8);
    S:=S+Fill(Strr(TotalBlocks+1),6);
    S:=S+#225;
    S:=S+Char(CurArea)+' ';
    S:=S+'  ';
    S:=S+' ';

    If Length(S)<>128 then Begin
      If Length(S) > 128
        Then S[0] := #128 Else
      If Length(S) < 128
        Then S := Fill(S,128);
    End;

    WriteText(S);

    For Wow := 1 To TotalBlocks Do Begin
      For Cb := 1 to 128
        Do Ax[cb] := St[Wow][Cb];
      BlockWrite(TextFile,Ax,1,Err);
    End;

    Inc(IndexRot);
    IndexArray[IndexRot] := Index;
    Index := Index + TotalBlocks + 1;
End;

Procedure ProcessRep;
VAR T : File Of Char;
    S : String[128];
    Temp : String[1];
    Temp1 : Mstr;
    Blocks, Line, A, X, Where, Total : Byte;
    B : BulRec;
    M : Message;
    K : Char;

    Function LowerCase(S:Mstr):Mstr;
    VAR X:Byte;
        Temp:Mstr;
    BEGIN
      X:=1;
      Temp:='';
      While X<=Length(S) Do Begin
        If S[X] in ['A'..'Z'] Then Begin
          If (X = 1) or (S[X-1]=#32) Then Temp:=Temp+S[X]
          Else Temp:=Temp+Char(Ord(S[X])+32);
        End Else Temp:=Temp+S[X];
        Inc(X);
      End;
      X:=Pos('  ',Temp);
      If X>0 then Temp:=Copy(Temp,1,X-1);
      Lowercase:=Temp;
    END;

    Procedure Nuke(S:STRING);
    VAR F : FILE;
    BEGIN
      If Not Exist(S) Then EXIT;
      Assign(F,S);
      Erase(F);
    END;

Var Trans : Integer;
BEGIN
  WriteHdr('QWK Reply Packet Processor');
  Writeln(^R'Note'^A': '^S'ViSiON/2 assumes the PKZipped Reply Packet is called '+cfg.qwkname+Strr(MsgConf)+'.REP,');
  WRiteln('      and that the actual QWK File is called '+cfg.qwkname+Strr(MsgConf)+'.MSG'^M);
  WriteStr(^R^P'Press <CR> To Send Packet via Zmodem ['^S'Q'^P']uits: *');
  If Upcase(inpt[1])='Q' Then Exit;
  If Not Local Then Begin

    Nuke(Cfg.UploadDir+cfg.qwkname+Strr(MsgConf)+'.REP');
    Nuke(Cfg.UploadDir+cfg.qwkname+Strr(MsgConf)+'.MSG');

    Trans := ExecProto(1,Cfg.UploadDir + cfg.qwkname+Strr(MsgConf)+'.REP','');
    If Exist(Cfg.UploadDir + cfg.qwkname+Strr(MsgConf)+'.REP')
    Then WriteHdr('QWK Packet Received!')
      Else
      Begin
        Writeln(^M^S'QWK Packet was not successfully received..'^G);
        Exit;
      End;
    ExecuteWithSwap
    ('PKUNZIP.EXE',' -o '+Cfg.UploadDir+cfg.qwkname+Strr(MsgConf)+'.REP '+Cfg.UploadDir,False);

    Assign(T,Cfg.UploadDir+cfg.qwkname+Strr(MsgConf)+'.MSG');
  End Else Begin
    Writeln(^M^S'Local QWK Processing...'^M^P);
    Writeln(Cfg.Sysopname,', make sure you have '+cfg.qwkname+Strr(MsgConf)+'.MSG in you ViSiON/2 Dir!');
    Assign(T,Cfg.VisionDir+cfg.qwkname+Strr(MsgConf)+'.MSG');
  End;
  If NOT EXIST(Cfg.UploadDir + cfg.qwkname+Strr(MsgConf)+'.MSG')
    THEN BEGIN
      Writeln('Uh Oh.. File '+cfg.qwkname+Strr(MsgConf)+'.MSG Not Found!'^G);
      Exit;
    END;
  RESET(T);
  Writeln(^M'QWK Packet Receive was successful!'^M);
  Writelog(0,0,'Uploaded a QWK Packet');
  HoldScreen;
  AnsiCls;
  Reset(T);
  For X:=1 to 128 Do Begin
    Read(T,K);
    S[X]:=K;
  End;
  If Not POS(cfg.qwkname+Strr(MsgConf),S) > 0 Then Begin
    Writeln('Uh Oh.. This Reply packet was not created for ViSiON/2!');
{    Close(T);
    Exit; }
  End;
  Total:=0;
  Writeln;
  WriteHdr('Processing QWK Packet');
  Repeat
    Line:=1;
    For X:=1 to 128 Do Begin
      Read(T,K);
      S[X]:=K;
    End;
    B.When:=Now;
    Temp1[0]:=#0;
    For A:=22 to 22 + 25 Do
      If S[A] <> #0 Then Temp1:=Temp1+S[a];
    B.SentTo:=LowerCase(Temp1);
    B.LeftBy:=Unam;
    Temp1[0]:=#0;
    For A:=72 to 72+25 Do
      If S[A] <> #0
        Then Temp1 := Temp1+S[A];
    B.Title := LowerCase(Temp1);
    Temp1[0]:=Chr(0);
    For A := 109 to 116
      Do If Valu(S[A])<>0
        Then Temp1:=Temp1+S[A];
    B.RepNumber:=Valu(Temp1);
    B.Replies:=0;
    B.RealName:=Urec.RealName;
    B.Anon:=False;
    B.Recieved:=False;
{    If CurBoard.EchoType < 2 Then Begin
      B.Origin1 := Strng^.Origin1;
      B.Origin2 := Strng^.Origin2;
    End Else Begin }
      B.Origin1 := FidoSIG;
      B.Origin2 := ' * Origin: '+CurBoard.OriginLine+' ('+CurBoard.Address+')';
{    End; }
    B.Status:=Urec.SysopNote;
    B.Plevel:=Urec.Level;
    Temp1[0]:=#0;
    For A:=117 to 122 Do Begin
      If Valu(S[A])<>0 Then Temp1:=Temp1+S[A];
    End;
    Blocks:=Valu(Temp1);
    Temp1[0]:=#0;
    Where:=Pred( Ord(S[124]) );
    M.Title:=B.Title;
    M.SendTo:=B.SentTo;
    M.Anon:=False;
    M.Note:=Urec.SysopNote;
    Line:=1;
    FillChar(M.Text,Sizeof(M.Text),0);
    For X:=1 to Blocks-1 Do Begin
      For A:=1 to 128 Do Begin
        Read(T,K);
        If K=#227 then Inc(Line);
        If (K<>#227) and (Length(M.Text[Line])<80)
          then M.Text[Line]:=M.Text[Line]+K
      End;
    End;
    M.Numlines:=Line;
    If HaveAccess(Where) Then Begin
      Inc(Total);
      CurBoardName:=CurBoard.Shortname;
      OpenBFile;

      Sr.C[1] := 'TO'; Sr.S[1] := Strr(Total);
      Sr.C[2] := 'BN'; Sr.S[2] := CurBoard.BoardName;

      MultiColor(Strng^.Adding_Msg_Qwk);
      Writeln;

      TrimMessage(M);
      B.Line:=MakeText(CurBFile1,CurBFile2,M,'');
      AddBul(B);
      inc(Status.newposts);
      inc(Status.totalmsgs);
      inc(Log.Posts);
      inc(unreadnewmsgs);
      inc(urec.nbu);
      writeurec;
    End;
  Until Eof(T);
  Close(T);
  Sr.C[1] := 'TO'; Sr.S[1] := Strr(Total);
  Writeln;
  MultiColor(Strng^.Total_QWK_Sent);
  Writeln;
End;

Procedure MakeQwk;
Label Xfer;
Var CB, It, Totalconf : Integer;
    M : Message;
    A : Set Of Byte;

    Procedure DeleteIndex;
    VAR Index:SearchRec;
        Str:Lstr;
        F:File;
    Begin
      Str:=Cfg.ViSiONDir+'*.NDX';
      FindFirst(Str,Anyfile,Index);
      If DosError<>0 Then Exit;
      While DosError=0 Do Begin
        Assign(F,Cfg.ViSiONDir+Index.Name);
        Erase(F);
        Close(F);
        FindNext(Index);
      End;
    End;

    Procedure Create_Door;
    Var F : Text;
    Begin
      Assign(F,Cfg.VisionDir+'DOOR.ID');
      ReWrite(F);
      Writeln(F,'DOOR = V2-QWK');
      Writeln(F,'VERSION = vo.84');
      Writeln(F,'SYSTEM = ViSiON/2 vo.84');
      Writeln(F,'MIXEDCASE = YES');
      TextClose(F);
    End;

    Procedure Create_Control;
    Var F : Text;
        CB : Integer;
    Begin
      Assign(F,Cfg.VISIONDir+'CONTROL.DAT');
      Rewrite(F);
      Writeln(F,Cfg.LongName);
      Writeln(F,'ViSiON/2 vo.72 (C) Ruthless Enterprises 1992');
      Writeln(F,Cfg.BoardPhone);
      Writeln(F,Cfg.SysOpName);
      Writeln(F,'00084,'+cfg.qwkname+Strr(MsgConf));
      Writeln(F,TDateStr(Now)+','+TimeStr_24(Now)+':00');
      Writeln(F,Urec.Handle);
      Writeln(F,'');
      Writeln(F,'0');
      Writeln(F,Strr(It));
      Writeln(F,Strr(TotalConf - 1));
      For Cb:=0 to FileSize(BdFile)-1 Do Begin
        If CB in A Then Begin
          CurBoardName := CurBoard.ShortName;
          OpenBFile;
          Writeln(F,Strr(CB+1));
          If HaveAccess(CB)
            Then Writeln(F,CurBoard.BoardName)
            Else Writeln(F,'Not Applicable');
        End
      End;
      Writeln(F,'HELLO');
      WRiteln(F,'NEWS');
      Writeln(F,'HASTA');
      TextClose(F);
    End;

    Procedure Create_Messages;
    Var CB : Integer;
        ShowLine : Boolean;
        Temp,Temp2 : Real;
        T,OldT,StartBul,X : Integer;
        Msgs : Word;
    Begin
      A:=[];
      ShowLine := False;
      For CB := 0 to FileSize(BDFile) - 1
      Do Begin
        If (Haveaccess(CB)) And (Not (CB In NScan.NewScanConfig))
           AND (POS('*PRIV*',CurBoard.BoardName)=0)
        Then Begin
          FillChar(IndexArray,SizeOf(IndexArray),0);
          IndexRot := 0;
          OldT := 0;
          If ShowLine = False Then Begin
            Writeln;
            Writeln(^R'Area #  Current Area Name           Start #  End #   Status');
            Writeln(^O'컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�');
            ShowLine := True;
          End;
          A := A + [CB];
          Inc(TotalConf);
          CurBoardName := Curboard.Shortname;
          CurBoardNum := CB;
          OpenBFile;
          GetLastReadNum;

          If (NumBuls - CurBul) > Urec.MaxQwk Then Begin
            If Urec.MaxQwk > 0 Then
              NScan.LastRead[CurBoardNum] := NumBuls - (Urec.MaxQwk + 1);
          End;

          LastReadNum := NScan.LastRead[CurBoardNum];

          Curbul := LastReadNum + 1;
          Msgs := NumBuls - Curbul + 1;
          Write(^P);
          Tab(Strr(Cb+1),8);
          Write(^S);
          Tab(CurBoard.Boardname,28);
          Tab(Strr(CurBul),9);
          Tab(Strr(Numbuls),8);
          If (Numbuls = 0) or (CurBul > Numbuls)
          Then Writeln(^S' No New Messages..')
          Else Begin
            If HungUpOn Then Exit;
            Write(^Z);
            For X := 1 to 25 do Write('�');
            Write(B_(25));
            StartBul := CurBul;
            While Curbul <= NumBuls Do Begin
              If HungUpOn Then Exit;
              Temp := Percentage(Curbul - StartBul,(Numbuls - StartBul));
              T := Round(Temp);
              Temp2 := T * 25/100;
              T := Round(Temp2);
              GetBRec;
              ReloadText(CurBFile1,CurBFile2,B.Line,M);
              Inc(it);
              If T > OldT Then
                For X:=OldT To T - 1 Do If WhereX < 79
                  Then Write(^B + #32);
              AddToDAt(B,M,CB+1,CurBul,It);
              NScan.LastRead[CurBoardNum] := CurBul;
              Curbul := NScan.LastRead[CurBoardNum] + 1;
              OldT := T;
            End;
            AnsiReset;
            While WhereX < 79
              Do Write(^B + #32);
            Write(B_(25));
            Write(^S' Creating Index File..'+#27+'[K');
            Create_Index(Cb + 1);
            Write(B_(22));
            Write(^P' Complete!'+#27+'[K');
            Writeln;
          End
        End
      End;
      Close(TextFile);
    End;

    Procedure Nuke_Files(All : Boolean);

      Procedure Check(FileName : Sstr);
      Var F : File;
      Begin
        If Exist(Cfg.ViSiONDir + FileName)
          Then Begin
            Assign(F,Cfg.ViSiONDir + FileName);
            Erase(F);
          End
      End;

    Begin
      DeleteIndex;
      If All
        Then Check(cfg.qwkname+Strr(MsgConf)+'.QWK');
      Check('MESSAGES.DAT');
      Check('DOOR.ID');
      Check('CONTROL.DAT');
    End;

Var Trans : Integer;
Begin
  WriteUrec;
  Index := 2;
  Nuke_Files(True);
  It := 0;
  Totalconf := 0;
  GetScanRec(NScan,Msgconf);
  Writehdr ('Compiling QWK Mail Packet');
  NoBreak := True;
  Create_Messages;
  If Not Exist(Cfg.ViSiONDiR+'MESSAGES.DAT') Then Begin
    Writeln(^M'No Messages Found!');
    Exit;
  End;
  If HungUpOn Then Exit;
  WriteLog(0,0,'Started Compiling a QWK Packet');
  Create_Control;
  Create_Door;
  Writeln;
  WriteHdr('Demon Tasker: Zipping QWK Packet');
  ExecuteWithSwap('PKZIP.EXE',cfg.qwkname+Strr(MsgConf)+'.QWK CONTROL.DAT MESSAGES.DAT DOOR.ID *.NDX HELLO. HASTA.',False);
  If Not Exist(Cfg.VisionDir + cfg.qwkname+Strr(MsgConf)+'.QWK') Then Begin
    Writeln('Uh Oh, PKZIP was unsuccessful!');
    GetScanRec(NScan,MsgConf);
    Exit;
  End;
  Xfer :
  If Not Local then Begin
    WriteStr(Strng^.Sending_Qwk_Packet);
    If Upcase(inpt[1])='Q' Then Begin
      GetScanRec(NScan,MsgConf);
      Exit;
    End;
    Trans := ExecProto(2,Cfg.VisionDir + cfg.qwkname+Strr(MsgConf)+'.QWK','');
    If Trans = -1 Then  { if aborted }
      Begin
        GetScanRec(Nscan,MsgConf);
        Exit;
      End;
    If Trans>0 then Begin
      Writeln;
      HoldScreen;
      WriteStr('Transfer unsuccessful! Try Again? !');
      If Yes then Goto Xfer else GetScanRec(NScan,MsgConf);;
    End Else Begin
      Writeln;
      WriteLog(0,0,'Downloaded QWK Packet');
      HoldScreen;
      WriteUrec;
    End;
  End
    Else Writeln(^M^M^A'Local QWK Packet is located in the DIR '+Cfg.VisionDir);
  WriteScanRec(NScan,MsgConf);
  Nuke_Files(False);
End;

Procedure GetMaxQwk;
Begin
  WriteHdr('Maximum QWK Messages per Area');
  Write(^R^R'Old Value'^A': '^S);
  If Urec.MaxQwk = 0 Then
    Writeln ('No Limit.') else
    Writeln (Strr(Urec.MaxQwk));
  WriteStr(^M^P'New Value (0 for no limit)'^O': *');
  If (Valu(inpt)>0) or (inpt='0') then Begin
    Urec.MaxQwk:=Valu(inpt);
    Writeln(^M^S'Value changed..');
  End;
End;

begin
end.
