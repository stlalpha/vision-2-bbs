{$R-,S+,I-,D+,F-,V-,B-,N-,L+ }
{$M $DDDD,1200,8000}

Uses Dos,
     Crt,
     DosMem,
     MNET,
     GenSubs,
     ConfigRt,
     GenTypes;

Type FidoRec = Record
              FromUserName : array[1..36] of char;
              ToUsername   : array[1..36] of char;
              subject      : array[1..72] of char;
              DateTime     : array[1..20] of char;
              TimesRead,
              DestNode,
              OrigNode,
              cost,
              OrigNet,
              DestNet      : integer;
              fill         : array[1..4] of integer;
              ReplyTo      : integer;
              Attrib       : word;
              NextReply    : integer;
          End;

Const Status    : Array[1..12] Of String[3] = ('Jan','Feb','Mar','Apr','May',
                  'Jun','Jul','Aug','Sep','Oct','Nov','Dec');

Const FilesOpen : Boolean = FALSE;

Type BufArray = Array[1..$3000] Of Char;

Var FidoMail : File of FidoRec;
    Header   : Fidorec;
    FHeader  : Fidorec;
    Infile   : String[79];
    Bul      : Bulrec;
    Board    : Boardrec;
    M        : Message;
    Mess     : Text;
    BDFile   : File Of Boardrec;
    BFile    : File Of Bulrec;
    Conf     : Integer;
    TFile    : SStr;
    MFile    : SStr;
    Filter   : Boolean;
    ForceLF  : Boolean;
    Suppress : Boolean;

Var LastTextFile,
    LastMailFile : Lstr;
    MailFile : File Of MailPtrRec;
    TextFile : File Of Lstr;
    Buf : ^BufArray;

    Procedure ShowStats;
    Begin
      GotoXy(1,6);
      ClrEol;
      TextAttr:=5;  Write('þ ');
      TextAttr:=15; Write('Processing Area: ');
      TextAttr:=9;  Writeln(Board.BoardName);
      ClrEol;
      If Suppress Then Exit;
      TextAttr:=5;  Write('þ ');
      TextAttr:=15; Write('Tossing; Current: ');
    End;

Procedure AssignName(Txt,MailName : Sstr);
Var CurTextFile,
    CurMailFile : Lstr;
Begin
  CurTextFile := Cfg.TextDir + Txt;
  CurMailFile := Cfg.Textdir + MailName;
  If (CurTextFile <> LastTextFile) Or (CurMailFile <> LastMailFile)
  Then Begin
    If FilesOPEN THEN BEGIN
      Close(TextFile);
      Close(MailFile);
    END;
    Assign(TextFile,CurTextFile);
    If Not Exist(CurTextFile)
      Then Rewrite(TextFile)
      Else Reset(TextFile);
    Assign(MailFile,CurMailFile);
    If Not Exist(CurMailFile)
      Then Rewrite(MailFile)
      Else Reset(MailFile);
    FilesOPEN := TRUE;
  End;
  LastTextFile := CurTextFile;
  LastMailFile := CurMailFile;
End;

Procedure Fidoin;
Var Mess : File;

  Function NumBuls : Integer;
  Begin
    Numbuls := Filesize(BFile)
  End;

  Procedure SeekBFile (n:integer);
  Var I : Integer;
  Begin
    Seek (BFile,N - 1);
    I := IoRESULT;
  End;

  Procedure Addbul (var b:bulrec);
  Var b2 : Bulrec;
  Begin
    If Numbuls = 0
      Then b.id := 1
    Else Begin
      Seekbfile (NumBuls);
      nRead (BFile,b2);
      If b2.id = 65535
        Then b.id := 1
      Else B.id := b2.id+1
    End;
    B.SCANNED := TRUE;
    SeekBFile (Numbuls + 1);
    nWrite (bfile,b);
  end;

  Procedure Fix(VAR Str:String);
  Begin
    While (Str[ Length(Str) ] = #0) And (Length(Str) > 1)
      Do Str[0] := Pred( Str[0] );
    While (Str[ Length(Str) ] = #1) And (Length(Str) > 1)
      Do Str[0] := Pred( Str[0] );
  End;

Var BaseName,
    Marker,
    CurMsg,
    Nt,
    Cnt : Integer;
    W,Z : String[255];
    L   : Lstr;
    Total : Word;
    CurrentChar : Longint;
    BufPos,
    EndBuf : Word;

    Procedure CheckBuf;
    Begin
      If BufPos > EndBuf Then Begin
        BufPos := 1;
        NBlockRead(Mess,Buf^,$3000,EndBuf);
        If Buf^[EndBuf] = #26
        Then Begin
          Buf^[EndBuf] := #0;
          Dec(EndBuf);
        End
      End
    End;

    Function Get_Next_Line : String;
    Var S : String;
        Done : Boolean;
        K : Char;
    Begin
      S[0] := #0;
      Done := False;
      Repeat
        Done := EndBuf = 0;
        If Done
          Then K := #10
          Else K := Buf^[BufPos];
        Inc(BufPos);
        CheckBuf;
        Case K Of
          #13 : Done := True;
          #10 :;
          Else S := S + K;
        End;
        Done := Done Or (EndBuf = 0);
      Until (Done);
      Get_Next_Line := S;
    End;

Var X    : Byte;
    K    : Char;
    Mail : MailPtrRec;
    Size : LongInt;
    
Begin
    Dos_GetMem(Buf,$3000);

    TextAttr:=5;
    Write('þ ');
    TextAttr:=15;
    WriteLn('Import Messages Requested...');

    BaseName:=0;
    Total:=0;

    Assign(BdFile,Cfg.BoardDir + 'BOARDDIR.' + Strr(Conf));
    Reset(BdFile);

    Repeat
      Seek(BdFile,BaseName);
      NRead(BdFile,Board);
      TextColor(9);

      If (Board.EchoType = 2) AND (Length(Board.Fido_Dir) > 0) Then
      Begin

        ShowStats;

        TFile := Board.ShortName + '.T' + Strr(Conf);
        MFile := Board.ShortName + '.M' + Strr(Conf);

        AssignName(TFile,MFile);

        If Board.Fido_Dir[ Length(Board.Fido_Dir) ] <> '\'
          Then Board.Fido_Dir := Board.Fido_Dir + '\';
        Assign(Bfile,Cfg.BoardDir + Board.ShortName + '.' + Strr(Conf));
        Reset(BFile);

        CurMsg := 1;

        While Exist(Board.Fido_Dir + Strr(CurMsg + 1) + '.MSG') Do
        Begin

          FillChar(Mail,SizeOf(Mail),0);

          Size := FileSize(TextFile);
          Mail.TextPtr := Size;

          Seek(TextFile,Size);

          Nt := 0;
          CurrentChar := 1;

          If Not Suppress Then Begin
            GotoXy(21,7);
            TextAttr:=14;
            Write(Strr(CurMsg+1)+'.MSG -> ViSiON/2');
          End;

          Inc(Total);
          Assign(Mess,Board.Fido_Dir+Strr(CurMsg+1)+'.MSG');
          Reset(Mess,1);

          EndBuf := 0;
          BufPos := 1;

          CheckBuf;

          Z := '';
          For X := 1 to 36 Do Begin
            Z := Z + Buf^[BufPos];
            Inc(BufPos);
            CheckBuf;
          End;
          Bul.Leftby := Z;
          Fix(Bul.LeftBy);

          Z := '';
          For X := 1 to 36 Do Begin
            Z := Z + Buf^[BufPos];
            Inc(BufPos);
            CheckBuf;
          End;

          Bul.SenTto := Z;
          Fix(Bul.SentTo);

          Z := '';
          For X := 1 to 30 Do Begin
            Z := Z + Buf^[BufPos];
            Inc(BufPos);
            CheckBuf;
          End;

          Bul.Title := Z;
          Fix(Bul.Title);

          While Buf^[BufPos] <> #13 Do Begin
            Inc(BufPos);
            CheckBuf;
          End;

          Inc(BufPos);
          CheckBuf;

          If Buf^[BufPos] <> #10
            Then Begin
              If BufPos > 1
                Then Dec(BufPos);
            End;

          Bul.Status   := 'Unknown';
          Bul.When     := Now;
          Bul.Origin1  := '';
          Bul.Origin2  := '';
          Bul.Anon     := False;
          Bul.Recieved := False;
          Bul.SCANNED  := TRUE;

          While (EndBuf > 0) Do
          Begin
            W := Get_Next_Line;
            If Not (Copy(W,1,1) = #1) And
               Not (Copy(W,1,7) = 'SEEN-BY') And
               Not (Copy(W,1,4) = '--- ') And
               Not (Copy(W,2,9) = '* Origin:') AND
               Not (Pos(^A+'PID',W)>0) AND
               Not (Pos(^A+'EPID',W)>0) AND
               Not (Pos(^A+'EID',W)>0) AND
               Not (Pos(^A+'MSGID',W)>0)
            Then Begin
              While (Length(W) > 79) Do
              Begin
                Marker := 69;
                Repeat
                  Inc(Marker);
                Until (Marker>78) or (W[Marker]=' ') or (W[Marker]=#27);
                If (W[Marker]=#27)
                  Then Dec(Marker);
                Inc(NT);
                Delete( W, 1, Marker );
              End;

              L := W;
              If (Mail.TotalLines > 0) Then Begin
                Inc(Mail.TotalLines);
                NWrite(TextFile,L);
              End Else If L > '' Then Begin
                Inc(Mail.TotalLines);
                NWrite(TextFile,L);
              End;

            End Else
            Begin
              If (Copy(W,1,4)='--- ') Then Bul.Origin1 := W Else
              If (Copy(W,1,9)=' * Origin') then Bul.Origin2 := W Else
              If (Copy(W,2,8)='USERNOTE') then Begin
                Bul.Status := (Copy(W,11,30));
                Fix(Bul.Status);
              End
            End
          End;

          If Mail.TotalLines > 0 Then
          Begin
            If (Length(Bul.Origin1) < 1) Then Bul.Origin1 := '';
            
            Size := FileSize(MailFile);
            Seek(MailFile,Size);
            NWrite(MailFile,Mail);

            Bul.Line     := Size;
            Bul.PLevel   := 0;
            Bul.V2_Net   := False;
            Bul.Fidonet  := True;
            Bul.RealName := Bul.LeftBy;

            AddBul(Bul);

          End;

          Inc(CurMsg);

          Close(Mess);
          Erase(Mess);
        End;

        Close(BFile);
        WriteLn;
      End;

      Board.LastScan := Now;
      Seek(BDFile,basename);
      NWrite(BDFile,Board);
      Inc(BaseName);

    Until EOF(BDFile);

    Close(BDFile);
    TextAttr:=9;
    Dos_FreeMem(Buf);
    Write(#13#10+'A Total Of ['); TextAttr:=15;
    Write(Total); TextAttr:=9;
    Writeln('] Messages Were Imported.');
End;

Procedure FidoOut;
Var Node,Net,Zone:Integer;
    NodeA,NetA,ZoneA:String[10];
    EndOL : String[2];

Procedure SplitUp;
Var INA,INB : Integer;
Begin
    Ina   := Pos(':',Board.Address);
    inb   := Pos('/',Board.Address);
    ZoneA := Copy(Board.Address,1,ina-1);
    Zone  := Valu(ZoneA);
    NetA  := Copy(Board.Address,Ina+1,(Inb-Ina-1));
    Net   := Valu(NetA);
    NodeA := Copy(Board.Address,(Inb+1),(Length(Board.Address)-Inb));
    Node  := Valu(NodeA);
End;

Function PadRight(Str:string;Size:byte;Pad:char):string;
var
  temp : string;
  L : integer;
begin
    Fillchar(Temp[1],Size,Pad);
    Temp[0] := chr(Size);
    L := length(Str);
    If L <= Size then
       Move(Str[1],Temp[succ(Size - L)],L)
    else
       Move(Str[1],Temp[1],size);
    PadRight := Temp;
End;

Function Last(N:byte;Str:string):string;
var Temp : string;
begin
    If N > length(Str) then
       Temp := Str
    else
       Temp := copy(Str,succ(length(Str) - N),N);
    Last := Temp;
end;  {Func Last}

Function MsgDateStamp : String;  { Creates Fido standard- 01 Jan 89 21:05:18 }
Var h,m,s,hs          : Word;    { Standard message header time/date stamp   }
    y,mo,d,dow        : Word;
    Tmp,
    o1,o2,o3          : String;
Begin
  o1 := '';
  o2 := '';
  o3 := '';
  tmp := '';
  GetDate(y,mo,d,dow);
  GetTime(h,m,s,hs);
  o1 := PadRight(Strr(d),2,'0');
  o2 := Status[mo];
  o3 := Last(2,Strr(y));
  Tmp := Concat( o1,' ',o2,' ',o3,'  ');
  o1 := PadRight(Strr(h),2,'0');
  o2 := PadRight(Strr(m),2,'0');
  o3 := PadRight(Strr(s),2,'0');
  Tmp := Tmp + Concat(o1,':',o2,':',o3);
  MsgDateStamp := Tmp;
End;

Function PadLeft(Str:string;Size:byte;Pad:char):string;
var temp : string;
begin
    Fillchar(Temp[1],Size,Pad);
    Temp[0] := chr(Size);
    If Length(Str) <= Size then
       Move(Str[1],Temp[1],length(Str))
    else
       Move(Str[1],Temp[1],size);
    PadLeft := Temp;
end;

function netmessage : string;
Var Hdr:string;
    Attr:Word;
    Name:Mstr;
Begin
  {If Board. Then Name:=Bul.RealName
    Else}
  Name:=Bul.LeftBy;
  Attr:=($0100);
  Hdr := '';
  Hdr := PadLeft(Name,36,#0);
  Hdr := Hdr + PadLeft(Bul.Sentto,36,#0)
             + PadLeft(Bul.Title,72,#0)
             + PadRight(msgdatestamp,19,' ')+ #0
             + Chr(Lo(0))+Chr(Hi(0))            {TimesRead}
             + Chr(Lo(1))+Chr(Hi(1))            {DestNode }
             + Chr(Lo(Node))+Chr(Hi(Node))      {OrigNode }
             + Chr(Lo(0))+Chr(Hi(0))            {Cost     }
             + Chr(Lo(Net))+Chr(Hi(Net))        {OrigNet  }
             + Chr(Lo(1))+Chr(Hi(1))            {DestNet  }
             + #0#0#0#0#0#0#0#0
             + Chr(Lo(0))+Chr(Hi(0))            {ReplyTo  }
             + Chr(Lo(Attr))+Chr(Hi(Attr))      {Attr     }
             + Chr(Lo(0))+Chr(Hi(0));           {NextReply}

  NetMessage := Hdr;
End;

Function IsOpen (Var FF) : Boolean;
Var FI : Fib Absolute FF;
Begin
  IsOpen := Fi.Handle <> 0
End;

Procedure Textclose (Var F:Text);
Var N  : Integer;
    FI : Fib Absolute F;
begin
  If IsOpen(f)
    Then System.Close (f);
  FI.Handle := 0;
  N := IoResult
end;

Procedure PrintText (Sector : Longint);
Var N, MM : Integer;
    P, B  : Byte;
    S, A, CS, SB : String;
    WorkStr : Lstr;
    Mail : MailPtrRec;
Begin

  AssignName(TFile,MFile);

  Seek(MailFile,Sector);
  NRead(MailFile,Mail);

  Seek(TextFile,Mail.TextPtr);

  Write(Mess,EndOL);

  N := 1;

  Repeat

   nRead(TextFile,WorkStr);

   MM := 0;
   Repeat
     If Length(WorkStr) > 0
     Then Begin

       P := 0;
       Inc(MM);

       S := Copy(WorkStr,MM,1);

       {
       If S = '|'
         Then P := MM
         Else P := 0;

        If P > 0 Then
        Begin
          CS := Copy(WorkStr[N],P+1,1);
          SB := Copy(WorkStr[N],P+2,1);
          A := (Upcase(CS[1])) + (Upcase(SB[1]));
          If Valu(A) > 0 Then Begin
            If Filter
              Then Delete(WorkStr,P+1,2)
              Else Begin
                Write(Mess,'|' + A);
                Inc(MM,2);
              End
          End Else Begin
            Write(Mess,'|' + A);
            Inc(MM,2);
          End
        End
          Else}

        Write(Mess,S);
    End;

    Until MM >= Length(WorkStr);

    Write(Mess,EndOL);
    Inc(N);

  Until (N > Mail.TotalLines);

End;

Var BaseName : Integer;
    BDFile   : File of BoardRec;
    BFile    : File Of BulRec;
    CurMsg,
    CNT,
    NT       : Integer;
    Total    : Word;

begin
    TextAttr:=5;  Write('þ ');
    TextAttr:=15; Writeln('Message Export Requested... ');
    basename:=0;
    total:=0;
    Assign(bdfile,Cfg.BoardDir + 'BOARDDIR.'+strr(conf));
    Reset(bdfile);
    EndOL := #13;
    If ForceLF
      Then EndOL := #13 + #10;
    Repeat
        Seek(bdfile,basename);
        NRead(bdfile,board);
        Curmsg := 0;
        if  (board.echotype > 1)
        and (length(board.Fido_Dir) > 0) then begin
            ShowStats;
            TFile := Board.ShortName + '.T' + Strr(Conf);
            MFile := Board.ShortName + '.M' + Strr(Conf);
            If Board.Fido_Dir[ Length(Board.Fido_Dir) ] <> '\'
              Then Board.Fido_Dir := Board.Fido_Dir + '\';
            Assign(Bfile,Cfg.BoardDir+board.shortname+'.'+strr(conf));
            Reset(Bfile);
            Cnt := 0;
            Nt := 0;

            For CNT := 0 TO (FileSize(BFile) - 1)
            Do BEGIN
                Seek(Bfile,CNT);
                NRead(Bfile,Bul);

                IF NOT BUL.SCANNED THEN
                BEGIN

                    Bul.Scanned := TRUE;
                    Seek(BFile,CNT);
                    NWrite(BFile,Bul);

                    Inc(NT);

                    If Not Suppress Then Begin
                      GotoXy(21,7);
                      TextAttr := 14;
                      Write(Strr(Nt)+' -> '+Strr(nt+1)+'.MSG');
                    End;

                    Inc(Total);
                    Assign(Mess,Board.Fido_Dir + Strr(NT + 1) + '.MSG');
                    Rewrite(Mess);
                    Write(mess,netmessage);
                    Write(mess,'MSGID: '+board.address+'.0');
                    Write(mess,'PID: ViSiON/2 vo.72á');
                    Write(mess,EndOL);
                    Write(mess,'USERNOTE:'+Bul.Status+'');
                    Write(mess,#13);
                    PrintTEXT(bul.line);
                    Writeln(Mess,'');
                    Writeln(mess,'--- ViSiON/2 FidoLink v2.0á');
                    If Board.OriginLine <> '' THEN
                      Writeln(mess,' * Origin: '+board.originline+' ('+Board.Address+')');
                    TextClose(Mess);

                END;

            END;
            Writeln('');
            Close(bfile);
        END;

        Board.LastScan := NOW;
        Seek(BDFile,BaseName);
        NWrite(BDFile,board);
        Inc(basename);

    Until EOF (Bdfile);

    Close(Bdfile);
    TextAttr := 9;
    Write(#13#10+'A Total Of [');
    TextAttr := 15;
    Write(Total);
    TextAttr := 9;
    Writeln('] Messages Were Exported.');
END;

Procedure FidoPur;
var basename:integer;
    bdfile:File of Boardrec;
    cnt:integer;
    found:boolean;
    F : File;

    Procedure DeleteRange(S_Dir : String);
    VAR Index:SearchRec;
        Str:Lstr;
        F:File;
    Begin
      Str:=S_Dir + '*.MSG';
      FindFirst(Str,Anyfile,Index);
      If DosError <> 0 Then Exit;
      While DosError = 0 Do Begin
    {    If Index.Name <> '1.MSG' Then BEGIN }
          Assign(F,S_Dir + Index.Name);
          Erase(F);
    {    END; }
        FindNext(Index);
      End;
    End;

begin
    textattr:=5;  Write('þ ');
    textattr:=15; Writeln('Looking for FidoNet Files to Purge!');
    basename:=0;
    Assign(bdfile,Cfg.BoardDir+'BOARDDIR.' + Strr(Conf));
    Reset (bdfile);
    repeat
      seek(bdfile,basename);
      NRead(bdfile,board);
      if (board.echotype > 1) and (length(board.fido_dir) > 0) then begin
        GotoXy(1,6);
        TextAttr:=5;
        Write('þ ');
        textattr:=15;
        write('Scanning '+Board.BoardName+'.. ');
        DeleteRange(Board.Fido_Dir);
      end;
      inc(basename);
    until EOF(Bdfile);
    close(Bdfile);
end;

Procedure HelpScreen;
Begin
  Sound(1000);
  Delay(50);
  NoSound;
  TextAttr:=5;  Write('þ ');
  TextAttr:=15; Writeln('V2MAIL.EXE needs a little more information!');
  TextAttr:=5;  Write('þ ');
  TextAttr:=15; Writeln('Required Format: V2MAIL [option] [conference(s) (default = 1)] ');
  TextAttr:=5;  Write('þ ');
  TextAttr:=15; Writeln('Valid Command Line Options Are As Follows...');
  Writeln;
  TextAttr:=3;  Write('  IN   - ');
  TextAttr:=11; Writeln('Imports Messages From Fido Directories into ViSiON/2');
  TextAttr:=3;  Write('  OUT  - ');
  TextAttr:=11; Writeln('Export''s New Messages From ViSiON/2 FidoNet bases into Fido Dir''s');
  TextAttr:=3;  Write('  KILL - ');
  TextAttr:=11; Writeln('Kills Message Files in the Fido Directories');
  TextAttr:=3;  Write('  /F   - ');
  TextAttr:=11; Writeln('Turns Bar Color Filter On (Default = Off)');
  TextAttr:=3;  WritE('  /L   - ');
  TextAttr:=11; Writeln('Force Linefeeds in outgoing messages');
  TextAttr:=3;  Write('  /S   - ');
  TextAttr:=11; Writeln('Suppress screen output (for Net Distortion)');
  Writeln;
End;

Var Total : Array[1..99] Of Byte;
Var X,By,TotalConf : Byte;
    W : Word;
    Which : Byte;
begin
    ClrScr;
    LastTextFile[0] := #0;
    LastMailFile := 'BLAH!';
    FillChar(Total,SizeOf(Total),0);
    TextAttr:=8;
    For By:=1 to 79
      Do Write('Ä');
    Writeln;
    Filter  := False;
    ForceLF := False;
    Suppress:= False;
    Textattr:=15; Write('ViSiON/2 Net-Mail Utility v2.0 Beta');
    TextAttr:=7;  Write('  ù  ');
    TextAttr:=15; Writeln('(C)opyright 1993 Ruthless Enterprises');
    TextAttr:=8;
    For By:=1 to 79
      Do Write('Ä');
    Writeln;
    Writeln;
    Readcfg;
    If Conf < 1
      Then Conf := 1;
    Conf := 2;
    TotalConf := 0;
    By := 1;

    Which := 0;

    While ParamStr(By) <> '' Do Begin
      If UpString(ParamStr(By)) = '/F'
        Then Filter := True
        Else If UpString(ParamStr(By)) = '/S'
        Then Suppress := True
        Else If UpSTring(ParamStr(By)) = '/L'
        Then ForceLF := True
        Else If UpString(ParamStr(By)) = 'IN'
        Then Which := 1
        Else If UpString(ParamStr(By)) = 'OUT'
        Then Which := 2
        Else If UpString(ParamStr(By)) = 'KILL'
        Then Which := 3
        Else If Valu(ParamStr(By)) > 0
        Then Begin
          Total[Conf - 1] := Valu(ParamStr(By));
          Inc(Conf);
          Inc(TotalConf);
        End;
        Inc(By);
      End;

    If TotalConf <= 0 Then Begin
      Total[1] := 1;
      TotalConf := 1;
    End;

    Case Which Of
      1 : Begin
            For X := 1 to TotalConf
            Do Begin
              Conf := Total[X];
              FidoIN;
            End
          End;
      2 : Begin
            For X := 1 to TotalConf
            Do Begin
              Conf := Total[X];
              FidoOut;
            End
          End;
      3 : Begin
            For X := 1 to TotalConf
            Do Begin
              Conf := Total[X];
              FidoPur;
            End
          End;

      Else Begin
        HelpScreen;
        Halt(1);
      End;
    End;

    Writeln;
    Halt(0);
End.