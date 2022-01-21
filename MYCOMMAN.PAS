{$R-,S-,I-,D-,F-,V-,B-,N-,L+,O+}

Unit Mycomman;

Interface

Uses GenTypes;

Procedure TextToFile(Txt,Mail : Sstr; Sector:Longint; Title,SendTo,From:Mstr);
{ Procedure OtherBBS; }
{ Procedure NodeLists; }
{ Procedure SysopConf; }
Procedure ChangeConf(Msg:Boolean; Force:Byte);
Procedure DemonRaid(M:Mstr; Take:Integer; VAR I:Integer);
Procedure OpenNodeRec;
Procedure ConfigFileListings;
Procedure Add_Auto_Sig;
Procedure Pick_Emulation;

Implementation

Uses Dos,MNeT,Crt,Configrt,General,Subs1,Windows,
     Subs2,TextRet,Flags,Mainr1,Mainr2,UserRet;

Type ConfRec = Record
       Name,Password:Lstr;
       Flags:String[26];
       Minlevel,Maxlevel:integer;
       OpenTime,CloseTime:Sstr;
     End;

Procedure TextToFile(Txt,Mail : Sstr; Sector:Longint; Title,SendTo,From:Mstr);
VAR T:Text;
    Name:Lstr;
    X:Byte;
    M:Message;
Begin
  ReloadText(Txt,Mail,Sector,M);
  WriteStr(^M^R'Save to what filename? *');
  Name:=Inpt;
  If Name='' Then Exit;
  Assign(T,Name);
  Rewrite(T);
  If IoResult<>0 Then Begin
    Writeln(^M^S'Could not create '^A+UpString(Name));
    Close(T);
    Exit;
  End;
  Writeln(^M^S'Writing to File: '^P+UpString(Name));
  Writeln(T,'ViSiON/2 (C) RE 1992 þ Message Grabber');
  Writeln(T,'');
  DefYes:=True;
  WriteStr(^R'Include Author/Receiver/Title? !');
  If Yes Then Begin
    Writeln(T,'Message Title: '+Title);
    Writeln(T,'Message From : '+From);
    Writeln(T,'Message To   : '+SendTo);
    Writeln(T,'');
  End;
  For X:=1 to M.Numlines Do Writeln(T,M.Text[X]);
  TextClose(T);
  Writeln(^R'File saved as'^A': '^S+Name);
End;


(*

procedure nodelists;
Var Node:NodeNetRec;
    FN:File of NodeNetRec;
    I,J,CNT:Integer;
    C:Char;

    Procedure ShowNode;
    Begin
      WriteHdr('Node Info...');
      WriteLn(^R'Node #'^S,I);
      Tab(^R+'Node Password',20);
      WriteLn(^A':'^S,Node.Pass);
      Tab(^R+'Node Name',20);
      WriteLn(^A':'^S,Node.Name);
      Tab(^R+'Node Phone Number',20);
      WriteLn(^A':'^S,Node.Phone);
      Tab(^R+'Node Baud Rate',20);
      WriteLn(^A':'^S,Node.Baud);
      Tab(^R+'Node ID Number',20);
      WriteLn(^A':'^S,Node.Node);
      Tab(^R+'Last NET Date',20);
      Writeln(^A':'^S,DateStr(Node.LastDate));
      Tab(^R+'Last NET Time',20);
      Writeln(^A':'^S,TimeStr(Node.LastDate));
      Tab(^R'Networked Bases',20);
      Write(^A':');
      Cnt:=1;
      Repeat
          If Node.BaseSelection[Cnt] then Write(Strr(Cnt)+',');
          Inc(Cnt);
      Until (Cnt=256) or HungUpOn;
      Writeln;
    End;

    Procedure DisplayNodeInformation;
    Begin
         If FileSize(Fn)=0 then Exit;
         Seek(Fn,0);
         I:=0;
         While Not Eof(Fn) do
           Begin
             Inc(I);
             nRead(Fn,Node);
             ShowNode;
           End;
         WriteStr(^M^P'Press '^R'[Return]: *');
    End;

    Procedure InitializeThisStuff;
    Begin
      Assign(Fn,Cfg.ViSiONDir+'NODELIST.BBS');
      Reset(FN);
      If IoResult<>0 Then Rewrite(FN);
    End;

    Procedure AddNode;
    Begin
         AnsiCls;
         WriteHdr('Add a node');
         FillChar(Node,SizeOf(Node),0);
         Write(^P'Enter the Node Password'^O': ');
         NoCRInput('Hasta!',25);
         If inpt='' then Exit;
         Node.Pass:=inpt;
         Write(^P'Enter the Node Name'^O': ');
         NoCRInput('Aborted..',30);
         If inpt='' then Exit;
         Node.Name:=inpt;
         WriteLn(^M^S'Do NOT include any "-"''s or "("''s for the phone number!'^M);
         Write(^P'Enter the Node Phone Number'^O': ');
         NoCRInput('Opps..',10);
         If inpt='' then Exit;
         Node.Phone:=inpt;
         Write(^P'Enter the Node''s Baud Rate ("1200"-"38400")'^O': ');
         NoCRInput('38400',5);
         If inpt='1200' then Node.baud:=1200;
         If inpt='2400' then Node.baud:=2400;
         If inpt='4800' then Node.baud:=4800;
         if inpt='9600' then Node.Baud:=9600;
         If inpt='19200' then Node.Baud:=19200;
         If inpt='38400' then Node.baud:=38400;
         If Node.Baud=0 then Node.Baud:=38400;
         Writeln(^M^S'Now enter the Main Conference in which the message are to be added');
         Writeln('This does not mean sub-conference (an actual message base area) but the');
         Writeln('main conferences you create via the ''C'' sysop command.'^M);
         WriteStr(^P'Conference (CR/1): *');
         If Inpt='' Then Inpt:='1';
         If Valu(Inpt)>0 Then Node.Conference:=Valu(Inpt) Else Exit;
         WriteLn(^M^S'The Node ID address is your NETWORK ID. It will be something like');
         WriteLn(^S'1:100, or something along those lines. (NOTE: Hub ID is same as each Node)'^M);
         WriteStr(^P'Enter Node ID Address: *');
         If inpt='' then Exit;
         Node.Node:=inpt;
         WriteLn(^S'Now we are going to pick the Base ID''s to be networked. Each message base');
         WriteLn(^S'That is networked will have a UNIQUE Base ID. This ID tells ViSiON Which Bases');
         WriteLn(^S'to network. Enter each base ID, when you are done, enter a "0".'^M);
         Repeat
               WriteStr(^P'Base ID: *');
               I:=Valu(inpt);
               If (I>0) and (I<256) then Node.BaseSelection[I]:=True
                  Else
               If I<>0 then WriteLn(^M^S^G'Invalid Range! Valid Ranges are from 1-255!'^M);
         Until (I=0) or HungUpOn;
         Write(^M'Adding Node to List...');
         Seek(Fn,FileSize(Fn));
         nWrite(Fn,Node);
         WriteLn('Completed!');
         HoldScreen;
    End;

    Procedure DeleteNode;
    Begin
         WriteStr('Which Node to Delete [1-'+strr(FileSize(Fn))+']: *');
         I:=Valu(inpt);
         If (I<1) or (I>FileSize(Fn)) then Exit;
         Write(^M'Deleting Node...');
         Dec(i);
         Cnt:=I;
         While Cnt<FileSize(Fn)-1 Do
         Begin
           Seek(Fn,Cnt+1);
           nRead(Fn,Node);
           Seek(Fn,Cnt);
           nWrite(Fn,Node);
           Inc(Cnt);
         End;
         Seek(Fn,FileSize(Fn)-1);
         Truncate(Fn);
         Close(Fn);
         Assign(Fn,Cfg.ViSiONDir+'NodeList.BBS');
         Reset(Fn);
         WriteLn('Deleted!');
         HoldScreen;
    End;

    Procedure EditNode;
    Var NodeNum:Integer;

    Procedure GetPhoneNum;
    Begin
         WriteStr('Enter the New Phone Number: *');
         If inpt<>'' then Node.Phone:=inpt;
    End;

    Procedure GetBaud;
    Begin
         WriteStr('Enter the NEW baud rate for this board: *');
         If inpt='1200' then Node.Baud:=1200
            Else
         if inpt='2400' then Node.baud:=2400
            Else
         If inpt='4800' then Node.Baud:=4800
            Else
         If inpt='9600' then Node.Baud:=9600
            Else
         If inpt='19200' then Node.baud:=19200
            Else
         If inpt='38400' then Node.Baud:=38400;
    End;

    Procedure GetName;
    Begin
      WriteStr('Enter the New Node Name: *');
      If inpt<>'' then Node.Name:=inpt;
    End;

    Procedure NodePassword;
    Begin
      WriteStr('Enter the New Node Password: *');
      If inpt<>'' then Node.Pass:=inpt;
    End;

    Procedure NodeIdNumber;
    Begin
      WriteStr('Enter the NEW Node ID Number: *');
      If inpt<>''
        then Node.Node:=inpt;
    End;

    Procedure GetNodeDate;
    Begin
      WriteStr('Enter NEW Last NET Date: *');
      If DateVal(inpt)<>0 Then
      Node.LastDate:=DateVal(inpt)+TimePart(Node.LastDate)
      Else Writeln('Invalid Date!');
    End;

    Procedure GetConf;
    VAR X:Byte;
    Begin
      Writeln(^M^R'Note'^A': '^S'If you are not using conferences then press enter.'^M);
      WriteStr(^P'Main Conference to put messages in (CR/1): *');
      If Inpt='' Then X:=1 Else
      X:=Valu(inpt);
      If X>0 then Begin
        If X in [1..99] then Node.Conference:=X Else
        Writeln('Not a valid Conference! (Setup in the Config)');
      End;
    End;

    Procedure GetNodeTime;
    Begin
      WriteStr('Enter NEW Last NET Time: *');
      If TimeVal(inpt)<>0 then
      Node.LastDate:=TimeVal(inpt)+DatePart(Node.LastDate)
      Else Writeln('Invalid Time!');
    End;

    Procedure NetBases;
    Begin
      WriteLn(^S'To change the status of a networked base, enter the BASE ID that you wish');
      WriteLn(^S'to change. I.e. if Base 1 was networked, and you wish to not carry it anymore');
      WriteLn(^S'then you would enter a "1". Enter a "0" when you are done.'^M);
      Repeat
        WriteStr('Base ID to Change: *');
        I:=Valu(inpt);
               If (I>0) and (I<256) then
                  Begin
                    Node.BaseSelection[I]:=Not Node.BaseSelection[I];
                    If Node.BaseSelection[I] then Writeln('Base ID:',I,' WILL be networked.')
                    Else
                    WriteLn('Base ID:',i,' will NOT be networked.');
                  End;
         Until (I=0) or HungUpOn;
    End;

    Begin
         WriteStr(^R'Enter the Node to Edit ['^A'1-'+strr(FileSize(Fn))+^R']: *');
         I:=Valu(inpt);
         If (I<1) or (I>FileSize(Fn)) then Else
          Begin
               Seek(Fn,I-1);
               nRead(Fn,Node);
               NodeNum:=I-1;
                 Repeat
                   WriteHdr('Node Editing');
                   WriteLn(^P'[P] Phone Number....: '^S+Node.Phone);
                   Writeln(^P'[B] Baud Rate.......: '^S+Strlong(Node.Baud));
                   Writeln(^P'[N] Node Name.......: '^S+Node.Name);
                   WriteLn(^P'[W] Node Password...: '^S+Node.Pass);
                   Writeln(^P'[I] Node ID Number..: '^S+Node.Node);
                   Writeln(^P'[D] Last Date Used..: '^S+DateStr(Node.LastDate));
                   Writeln(^P'[T] Last Time Used..: '^S+TimeStr(Node.LastDate));
                   Writeln(^P'[C] Conference #....: '^S+Strr(Node.Conference));
                   WriteLn(^P'[S] Net bases');
                   Writeln(^P'[Q] Quit Editing'^M);
                   WriteStr('Choice: *');
                   If inpt='' then inpt:='Q';
                   C:=UpCase(inpt[1]);
                   Case C Of
                     'C':GetConf;
                     'P':GetPhoneNum;
                     'B':GetBaud;
                     'N':GetName;
                     'V':ShowNode;
                     'W':NodePassword;
                     'I':NodeIDNumber;
                     'S':NetBases;
                     'D':GetNodeDate;
                     'T':GetNodeTime;
                   End;
                 Until (C='Q') or HungUpOn;
               Seek(Fn,NodeNum);
               nWrite(Fn,Node);
          End;
          C:='U';
         End;

VAR Q:Integer;
Begin
     InitializeThisStuff;
     Repeat
       Q:=Menu('Node Maintenance','NODE','SEDAQ');
       Case Q of
         1:DisplayNodeInformation;
         2:EditNode;
         3:DeleteNode;
         4:AddNode;
       End;
     Until (Q=5) or HungUpOn;
     Close(Fn);
End;

Procedure SwitchBoard;
Type Names=Record
       Name:Mstr;
       Number:Byte;
     End;
     NameArray=Array[1..20] Of Names;
Var ConRec:ConfRec;
    Confile:File Of ConRec;
    MsgArray,FileArray:NameArray;
    MsgTotal,FileTotal:Byte;
    K:Char;
    X:Byte;

    Procedure LoadList(FileName:Sstr; Var Arry:NameArray; Var Total:Byte);
    VAR X,Y:Integer;
    Begin
      FillChar(Arry,SizeOf(Arry),0);
      Total:=0;
      Assign(ConFile,Cfg.DataDir+FileName);
      Reset(Confile);
      If Ioresult<>0 Then Exit;
      X:=FileSize(ConFile);
      If X>20 Then X:=20;
      For Y:=1 to X Do Begin
        Seek(ConFile,X-1);
        nRead(Confile,ConRec);
        With ConRec Do
         If (Urec.Level>=MinLevel) And (Urec.Level<=MaxLevel)
         And (WithinTime(OpenTime,CloseTime)) And (CheckFlags(Urec.Flags,Flags))
         Then Begin
          Inc(Total);
          Arry[Total].Name:=ConRec.Name;
          Arry[total].Number:=Total;
         End;
      End;
    End;

    Procedure SetupScreen;
    Var X:Byte;
    Begin
      AnsiCls;
      Writeln(^R'Message Conferences           ³        File Conferences');
      Writeln(^R'                              ³');
      If MsgTotal=0 Then PrintXy(1,4,'No Message Conferences!')
      Else
      For X:=1 To MsgTotal Do Begin
        GoXy(2,X+4);
        Write('[ ]');
        If MsgConf=X Then Write(' û') Else Write('  ');
        Tab(MsgArray[X].Name,31);
        Write('³');
      End;
      If FileTotal=0 Then PrintXy(33,4,'No File Conferences!')
      Else
      For X:=1 to FileTotal Do Begin
        GoXy(33,X+4);
        Write('[ ]');
        If FileConf=X Then Write(' û') Else Write(' ');
        Writeln('[ ]  '+FileArray[X].Name);
      End;

Begin
  WriteHdr('Conference Configuration');
  Writeln(^R'Scanning Conference Data...');
  LoadList('MSGCONF.DAT',Msgarray,MsgTotal);
  LoadList('XFERCONF.DAT',FileArray,FileTotal);


Procedure SysopConf;
VAR ConRec:ConfRec;
    Confile:File of ConfRec;
    X:Byte;

    Procedure EditConf(Which:Byte; Msg:Boolean);
    VAR Done:Boolean;
        Name:Mstr;
    Begin
      Seek(Confile,Which-1);
      nRead(Confile,ConRec);
      Done:=False;
      Repeat
        Writeln;
        If Which>5 then Header('Editing File Conference #'+Strr(Which-5))
        Else Header('Editing Message Conference #'+Strr(Which));
        Writeln(^O'['^P'N'^O']  Conference Name      : '^S+ConRec.Name);
        Writeln(^O'['^P'L'^O']  Conference Min. Level: '^S+strr(Conrec.MinLevel));
        Writeln(^O'['^P'X'^O']  Conference Max Level : '^S+Strr(ConRec.MaxLevel));
          Write(^O'['^P'F'^O']  Conference Flags     : '^S); WriteFlags(Conrec.Flags);
        Writeln(^M^O'['^P'P'^O']  Conference Password  : '^S+ConRec.Password);
        Writeln(^O'['^P'O'^O']  Conference Open Time : '^S+ConRec.OpenTime);
        Writeln(^O'['^P'C'^O']  Conference Close Time: '^S+ConRec.CloseTime);
        Writeln;
        WriteStr(^R'Edit Which? '^A'['^R'Q'^A']uit [ ]'+B_(2)+'*');
        Case Upcase(inpt[1]) of
        'N':Begin
              Write('Conference Name'^A': ');
              InputBox(30);
              If Inpt<>'' Then ConRec.Name:=Inpt;
            End;
        'O':Begin
              WriteStr(^R'New Conference Open Time (hh:mm pm/am)'^A': *');
              If Inpt<>'' Then ConRec.OpenTime:=Inpt;
            End;
        'C':Begin
              WriteStr(^R'New Conference Close Time (hh:mm pm/am)'^A': *');
              If Inpt<>'' Then ConRec.CloseTime:=Inpt;
            End;
        'L':Begin
             WriteStr(^R'New Conference Minimum Level'^A': *');
             If Valu(inpt)>0 then Conrec.MinLevel:=Valu(inpt);
            End;
        'X':Begin
             WriteStr(^R'New Conference Maximum Level'^A': *');
             If Valu(Inpt)>0 Then ConRec.MaxLevel:=Valu(Inpt);
            End;
        'F':Begin
             Writeln;
             Write(^R'['^A'A-Z'^R'] Toggle ['^A'Space'^R'] Quits  ');
             GetFlag(ConRec.Flags);
            End;
        'P':Begin
             WriteStr('New Conference Password: *');
             ConRec.Password:=inpt;
            End;
        'Q':Done:=True;
        End;
     Until (Done) or HungUpOn;
     Seek(ConFile,Which-1);
     nWrite(Confile,ConRec);
     inpt:='M';
   End;

   Procedure DeleteConf;
   VAR X:Byte;
       Temp,I:Integer;
       F:File;
       C:ConfRec;
   Begin
     Temp:=FileSize(ConFile);
     WriteStr(^M'Delete a Conference (Q/uit) [1-'+Strr(Temp)+']: *');
     I:=Valu(Inpt);
     If (I<=0) or (I>Temp) Then Exit;
     FillChar(C,SizeOf(C),0);
     Seek(ConFile,I-1);
     nWrite(ConFile,C);
     Reset(ConFile);
     Assign(F,Cfg.DataDir+'SCANDATA.'+Strr(I));
     Reset(F);
     If IoResult<>0 then Erase(F);
     Close(F);
   End;

{
     For X:=I+1 to Temp Do Begin
       Seek(ConFile,X);
       Read(ConFile,C);
       Seek(ConFile,X-1);
       Write(Confile,C);
     End;
     Seek(ConFile,Temp-1);
     Truncate(Confile);
     Assign(F,Cfg.DataDir+'SCANDATA.'+Strr(I));
     Reset(F);
     If IoResult=0 Then Erase(F);
     Close(F);
     For X:=I+1 to Temp Do Begin
       Assign(F,Cfg.DataDir+'SCANDATA.'+Strr(X));
       Reset(F);
       If IoResult=0 Then Rename(F,Cfg.DataDir+'SCANDATA.'+Strr(X+1));
       Close(F);
     End;
   Reset(ConFile);
   End;
}


   Procedure AddConf(Msg:Boolean);
   Label Done;
   VAR S,X:Integer;
       Temp:Sstr;
   Begin
     WriteStr(^R'Add a New Conference? !');
     If Not Yes Then EXiT;
     For X:=1 to FileSize(ConFile) Do Begin
       Seek(ConFile,X-1);
       nRead(ConFile,ConRec);
       If ConRec.Name='' Then Begin S:=X; Goto Done; End;
     End;
     S:=FileSize(ConFile)+1;
     Done:
     If Msg Then Temp:='Message' Else Temp:='File';
     WriteHdr('Creating '+Temp+' Conference #'+Strr(S));
     Write(^R'Conference Name'^A': ');
     InputBox(30);
     If Inpt='' Then Exit;
     ConRec.Name:=Inpt;
     Write(^M^R'Lowest Level Allowed'^A': ');
     NoCRInput(Strr(Cfg.LogonLevel),6);
     If Inpt='' Then ConRec.MinLevel:=Cfg.LogonLevel Else
       ConRec.MinLevel:=Valu(Inpt);
     Write(^M^R'Highest Level Allowed'^A': ');
     NoCrInput('32767',6);
     If Inpt='' Then ConRec.MaxLevel:=32767 Else ConRec.MaxLevel:=Valu(Inpt);
     Write(^M^R'Conference Flags; ['^A'Space'^R'] Quits  ');
     ConRec.Flags[0]:=#0;
     GetFlag(ConRec.Flags);
     Write(^M^R'Conference Password'^A': ');
     NoCRInput('None',30);
     ConRec.Password:=Inpt;
     Write(^M^R'Conference Open Time (hh:mm: am/pm)'^A': ');
     NoCRInput('4:00 am',8);
     If Inpt='' then Inpt:='4:01 am';
     ConRec.OpenTime:=Inpt;
     Write(^M^R'Conference Close Time (hh:mm am/pm)'^A': ');
     NoCrInput('4:00 am',8);
     If Inpt='' then Inpt:='4:00 am';
     ConRec.Closetime:=Inpt;
     Seek(ConFile,S-1);
     nWrite(ConFile,ConRec);
     Reset(ConFile);
   End;

    Procedure PickConf(Msg:Boolean);
    Label ReList;
    VAR X:Byte;
        K:Char;
    Begin
      If Msg Then Assign(Confile,Cfg.DataDir+'MSGCONF.DAT') Else
        Assign(Confile,Cfg.DataDir+'XFERCONF.DAT');
      Reset(Confile);
      If IoResult<>0 Then Begin
        Rewrite(ConFile);
        If Msg Then ConRec.Name:='General Message Conference'
        Else ConRec.Name:='General File Conference';
        ConRec.Flags[0]:=#0;
        ConRec.MinLevel:=Cfg.LogonLevel;
        ConRec.MaxLevel:=32767;
        ConRec.Password[0]:=#0;
        ConRec.OpenTime:='4:01 am';
        ConRec.CloseTime:='4:00 am';
        Write(Confile,ConRec);
        Reset(ConFile);
      End;
      Relist:
      Writeln;
      Header('#.   Conference Name              Min. Level  Max Level  Password');
      For X:=1 to FileSize(ConFile) Do Begin
        Seek(ConFile,X-1);
        nRead(Confile,ConRec);
        If ConRec.Name<>'' Then Begin
        Write(^S);
        Tab(Strr(X)+':',5);
        Write(^U);
        Tab(ConRec.Name,30);
        Write(^P);
        Tab(Strr(ConRec.MinLevel),12);
        Tab(Strr(ConRec.MaxLevel),13);
        If ConRec.Password<>'' then Writeln(ConRec.Password) Else Writeln('None..');
        End;
      End;
      Writeln;
      Repeat
      Repeat
        Buflen:=2;
        Inpt[0]:=#0;
        WriteStr(^R'Conference Editing; ('^A'Edit'^R': '^A'1..'+Strr(FileSize(ConFile))+
           +^R') ('^A'A/dd'^R') ('^A'D/elete'^R') ('^A'Q/uit'^R') [  ]'+B_(3)+'*');
        X:=Valu(Inpt);
      Until (HungUpOn) or (Upcase(Inpt[1]) in ['A','D','Q']) or
            (X>0) and (X<=FileSize(ConFile));
      K:=Upcase(Inpt[1]);
      If X>0 Then Begin
        EditConf(X,Msg);
      End Else
      Case Upcase(Inpt[1]) Of
        'A':AddConf(Msg);
        'D':DeleteConf;
      End;
        If K in ['A','D'] Then Goto ReList;
      Until (Upcase(Inpt[1])='Q') or (HungUpOn);
      Inpt:='M';
    End;

BEGIN
  WriteHdr('Message/File Conference Editor');
  Writeln(^R'Note'^A': '^S'You can have up to 99 Conferences with 255 Sub-Conferences in each.'^M);
  Repeat
    Buflen:=1;
    Inpt[0]:=#0;
    WriteStr(^R'Edit Which Conference? ['^A'M'^R']essage or ['^A'F'^R']ile [ ]'+B_(2)+'*');
    If Inpt='' Then Inpt:='Q';

    Case Upcase(inpt[1]) of
      'M':PickConf(True);
      'F':PickConf(False);
    End;

    Writeln;
  Until (Not (Upcase(inpt[1]) in ['M','F'])) or HungUpOn;
  Close(ConFile);
End;

*)

Procedure ChangeConf(Msg:Boolean; Force:Byte);

Const Names : Array[0..1] Of String[8] = ('XFERCONF','MSGCONF');

Var CurFile,Auto,NoInpt:Sstr;
    K : Byte;
    ConRec : ConfRec;
    ConFile : File Of ConfRec;
    Ok, Message, ANSi : Boolean;
    OkSet, PWSet : Set Of Byte;
    Total : Byte;

    Procedure Display( K : Byte);
    Begin
      If Ansi
        Then Exit;
      With ConRec Do Begin
        Sr.C[1] := 'NU'; Sr.S[1] := Strr(K); Sr.T[1] := 2;
        Sr.C[2] := 'NA'; Sr.S[2] := Name; Sr.T[2] := 30;
        Sr.C[3] := 'MI'; Sr.S[3] := Strr(MinLevel); Sr.T[3] := 5;
        Sr.C[4] := 'MA'; Sr.S[4] := Strr(MaxLevel); Sr.T[4] := 5;
      End;
      ListingFile(Cfg.TextFileDir + Names[Ord(Message)] + '.MID',False);
    End;

    Function ConfPassword(Password:Mstr) : Boolean;
    Begin
      Writeln(^M^R'A Password is required for Conference ['^A+Strr(K)+^R']');
      Dots := True;
      WriteStr(^M^R'Conference Password'^A': *');
      Dots := False;
      If Not Match(Inpt,Password)
        Then Begin
          ConfPassword := False;
          Writeln(^M^S'Invalid Password!');
        End
        Else ConfPassword := True;
    End;

    Procedure Assign_Conference;
    Begin
      Sr.C[1] := 'NA'; Sr.S[1] := ConRec.Name;
      Sr.C[2] := 'NU';
      If Msg
        Then Sr.S[2] := Strr(MsgConf)
        Else Sr.S[2] := Strr(FileConf);
      If Msg
      Then Begin
        MsgConf := K;
        MultiColor(Strng^.Joined_Msg_Conf);
        Writeln;
        Urec.DefMsgConf := MsgConf;
      End
      Else Begin
        FileConf := K;
        MultiColor(Strng^.Joined_File_Conf);
        Writeln;
        Urec.DefFileConf := FileConf;
      End
    End;

    Procedure ListConferences;
    Var K : Byte;
    Begin
      If Ansi
        Then Exit;
      ListingFile(Cfg.TextFileDir + Names[ Ord(Message) ] + '.TOP',True);
      For K := 1 To FileSize(ConFile) Do Begin
        Seek(ConFile,K-1);
        nRead(ConFile,ConRec);
        If ConRec.Name <> '' Then
        With ConRec Do
          If (Urec.Level>=MinLevel)
          And (Urec.Level<=MaxLevel)
          And (WithinTime(OpenTime,CloseTime))
          And (CheckFlags(Urec.Flags,Flags))
          Then Begin
            Ok := True;
            Write(^R);
            OkSet := OkSet + [K];
            Inc(Total);
            Display(K);
            If ConRec.Password <> ''
              Then PwSet := PwSet + [K];
          End
      End;
      ListingFile(Cfg.TextFileDir + Names[ Ord(Msg) ] + '.BOT',False);
    End;

Var KK : Char;
Begin
  Auto[0] := #0;
  Message := Msg;
  Total := 0;

  CurFile := Names[ Ord(Msg) ] + '.DAT';

  Assign(ConFile,Cfg.DataDir+CurFile);
  Reset(ConFile);

  If IoResult<>0 Then Begin
    Rewrite(ConFile);
    If Msg Then ConRec.Name:='Message Conference #1'
      Else ConRec.Name:='File Conference #1';
    ConRec.Flags[0]:=#0;
    ConRec.MinLevel:=Cfg.LogonLevel;
    ConRec.MaxLevel:=32767;
    ConRec.Password[0]:=#0;
    ConRec.OpenTime:='4:01 am';
    ConRec.CloseTime:='4:00 am';
    Write(Confile,ConRec);
    Reset(ConFile);
  End;

  Ansi := Exist(Cfg.TextFileDir + Names[ Ord(Message) ] + '.ANS');

  If Force <> 0 Then Inpt := 'I' + Strr(Force);

  If Length(Inpt) > 1 Then Begin
    Auto := Copy(Inpt,2,255);
    K := Valu(Auto);
    If (K > 0) and ( K <= FileSize(ConFile)) Then Begin
      Seek(ConFile,K-1);
      nRead(ConFile,ConRec);
      With ConRec Do
        If (Urec.Level>=MinLevel) And (Urec.Level<=MaxLevel)
        And (WithinTime(OpenTime,CloseTime)) And (CheckFlags(Urec.Flags,Flags))
        Then Begin
         If (ConRec.Password='') or
         ( (ConRec.Password<>'') and (ConfPassword(ConRec.Password)) )
         Then Begin
           Close(ConFile);
           Assign_Conference;
           Exit;
         End
        End
    End
  End;

  OkSet := [];
  PwSet := [];

  If Not ANSi Then
    Ok := False;

  ListConferences;

  If Not Ok Then Begin
    Writeln(^S'Apparently you don''t have access to any conferences...');
    Writeln('Talk to your SysOp to straighten out this descrepancy!');
    Close(Confile);
    If Msg
      Then MsgConf := -1
      Else FileConf := -1;
    Exit;
  End;

  K := 1;

  If Msg Then Begin
    If Urec.DefMsgConf in OkSet
      Then NoInpt := Strr(Urec.DefMsgConf)
      Else NoInpt := '0';
  End Else Begin
    If Urec.DefFileConf in OkSet
    Then NoInpt := Strr(URec.DefFileConf)
    Else NoInpt := '0';
  End;

  Repeat
    If ANSi
      Then Begin
        InputFile(Cfg.TextFileDir + Names[ Ord(Msg) ] + '.ANS');
        AnsiReset;
        AnsiCls
      End
      Else Begin
        Sr.C[1] := 'DE'; Sr.S[1] := NoInpt;
        MultiColor(Strng^.ConfPrompt);
        KK := WaitForChar(True);
        If KK = #13
          Then Inpt := NoInpt
          Else Inpt := KK;
        Writeln(KK);
        If KK = '?'
          Then ListConferences;
      End;
  Until (Upcase(Inpt[1]) = 'Q') or (Valu(Inpt) in OkSet) or (HungUpOn);

  If Upcase(Inpt[1]) = 'Q' Then Begin
    Close(ConFile);
    Exit;
  End;

  K := Valu(Inpt);

  Seek(ConFile,K - 1);
  NRead(ConFile,ConRec);

  If K in PwSet Then Begin
    If Not (ConfPassword(ConRec.Password)) Then Begin
      If Msg
        Then MsgConf := -1
        Else FileConf := -1;
      Close(ConFile);
      Exit;
    End
  End;

  Assign_Conference;
  Close(ConFile);
End;

Procedure DemonRaid(M:Mstr; Take:Integer; VAR I:Integer);
Var X,Y : Byte;
Begin
  If Not Urec.UseDemons
    Then Exit;
  X := Random (100) + 1;
  If X > Urec.DemonChance
    Then Exit;
  NoBreak := True;
  ClearBreak;
  PrintFile(Cfg.TextFileDir+'DEMON.ANS');
  AnsiReset;
  Writeln(^P);
  Writeln(^R'Harry has stolen '^A+Strr(take)+^R' of your '^S+m+^R'!');
  i := i - Take;
  if i < 0
    then i := 0;
  Writeln(^R'You now have '^A+Strr(i)+^R' '+m+'...');
  Writeln;
  HoldScreen;
  NoBreak := False;
End;

Procedure OpenNodeRec;
Const DefRec : MultiNodeRec = (Name:'[ Open Line ]';Status:'Waiting For Call';
                               AC:'N/A';Baud:'None');
Var X : Byte;
Begin
  Assign(MNFile,Cfg.DataDir+'MULTNODE.DAT');
  Reset(MNFile);
  If IoResult <> 0 Then Begin
    Rewrite(MNFile);
    For X:=1 to Cfg.TotalNodes Do
      NWrite(MNFile,DefRec);
  End;
End;

Procedure ConfigFileListings;

Const Sizes : Array[1..8] Of Byte = (8,6,7,6,48,12,4,20);

Type ScreenCords = Array[1..2] Of Byte;

     XyRec = Record
       Mark : Array[1..8] Of ScreenCords;
       MarkChar,UnMarkChar : Char;
       Num_Used,
       Example,
       Prompt : ScreenCords;
       Mark_Hi,
       Mark_Lo,
       Example_Col,
       Num_Used_Col : Byte;
     End;

Var K    : Char;
    I, X : Byte;
    Done : Boolean;
    Xy : XyRec;

  Procedure Load_XyRec;
  Const Name = 'CONFIG_F.NFO';
  Var T : Text;
      S : String;

      Procedure AssignXy(VAR What : ScreenCords);
      Var X,Y:Byte;
          Temp:Sstr;
      Begin
        Temp := S[3];
        If S[4]<>',' Then Temp := Temp + S[4];
        X := Valu(Temp);
        If S[5] <> ',' Then Begin
          Temp := S[5];
          If Length(S) > 5 then Temp:=Temp+S[6];
        End Else Begin
          Temp:=S[6];
          If Length(S) > 6 Then Temp:=Temp+S[7];
        End;
        Y := Valu(Temp);
        What[1] := X;
        What[2] := Y;
      End;

      Procedure Assign_Color(VAR What : Byte);
      Var X,Len : Byte;
      Begin
        Len := Length(S);
        For X := Len Downto 1
          Do If (Not (S[x] in ['0'..'9'])) Then
            Delete(S,X,1);
        What := Valu(S);
      End;

  Begin
    FillChar(Xy,SizeOf(Xy),0);
    If Not Exist(Cfg.TextFileDir + Name)
      Then Begin
        Writeln('Critical File Missing : ',Name);
        Exit;
      End;
    Assign(T,Cfg.TextFileDir + Name);
    Reset(T);
    While Not Eof(T) Do Begin
      Readln(T,S);
      S := UpString(S);
      If Pos('UNTAG_CHAR=',S) > 0
        Then Xy.UnMarkChar := S[Length(S)] Else
      If Pos('TAG_HI_COLOR=',S) > 0
        Then Assign_Color(Xy.Mark_Hi) Else
      If Pos('TAG_LO_COLOR=',S) > 0
        Then Assign_Color(Xy.Mark_Lo) Else
      If Pos('EXAMPLE_COLOR=',S) > 0
        Then Assign_Color(Xy.Example_Col) Else
      If Pos('TOTAL_COLOR=',S) > 0
        Then Assign_Color(Xy.Num_Used_Col) Else
      If Pos('TAG_CHAR=',S) > 0
        Then Xy.MarkChar := S[Length(S)] Else
      If (S[1] in ['1'..'8','T','E','@'])
        Then Case S[1] Of
          '1'..'8' : AssignXy(Xy.Mark[Valu(S[1])]);
          'T' : AssignXy(Xy.Num_Used);
          'E' : AssignXy(Xy.Example);
          '@' : AssignXy(Xy.Prompt);
        End;
    End;
    TextClose(T);
  End;

  Procedure UpdateLine;
  Var Line : Lstr;

    Procedure Add(S : Lstr);
    Begin
      Line := Line + S;
    End;

  Begin
    If Xy.Example[1] < 1
      Then Exit;

    GoXy(Xy.Example[1],Xy.Example[2]);
    AnsiColor(Xy.Example_Col);

    Line := '1: ';

    With Urec do Begin
      If FileList[1] then Add('V2-71-B');
      If FileList[2] then Add('.ZIP');
      If FileList[3] then Add('  Free');
      If FileList[4] then Add('  435K');
      If FileList[5] then Add('  ViSiON/2 BBS Software "The ReVision"!...      ');
      If FileList[6] then Add('  '+DateStr(Now));
      If FileList[7] then Add('  100');
      If FileList[8] then Add('  Crimson Blade');
    End;
    While Length(Line) < 75
      Do Add(#32);
    Write(Direct,Line);
  End;

  Procedure DrawFileLister;
  Begin
   PrintFile(Cfg.TextFileDir + 'CONFIG_F.ANS');
  End;

  Procedure Update_Num_Used;
  Begin
    If Xy.Num_Used[1] < 1
      Then Exit;
    GoXy(Xy.Num_Used[1],Xy.Num_Used[2]);
    AnsiColor(Xy.Num_Used_Col);
    If i < 10
      Then Write('0'+strr(i))
      Else Write(Strr(i));
  End;

  Procedure PlaceBlocks;
  Var i:byte;
  Begin
    AnsiColor(Xy.Mark_Hi);
    For i:=1 to 8 do Begin
      If Urec.FileList[i] then Begin
        GoXy(Xy.Mark[i][1],Xy.Mark[i][2]);
        Write(Direct,Xy.MarkChar);
      End;
    End;
  End;

  Function Calculate : Boolean;
  Var O : Byte;
  Begin
   O := Sizes[x];
   O := I + O;
   Calculate := True;
   If O > 77
     Then Calculate := False;
  End;

  Procedure Alternate(VAR B:Boolean; X : Byte);
  Begin
    If (I > 77) And (B)
      Then Exit;
    GoXy(Xy.Mark[x][1],Xy.Mark[x][2]);
    B := Not B;
    If B
      Then AnsiColor(Xy.Mark_Hi)
      Else AnsiColor(Xy.Mark_Lo);
    If B
      Then Write(Direct,Xy.MarkChar)
      Else Write(Direct,Xy.UnMarkChar);
  End;

  Procedure Addemup;
  Var a,b:byte;
  Begin
    A := 0;
    For B := 1 to 8 Do
      If Urec.FileList[b]
        Then A := A + Sizes[b];
    I := A;
  End;

Begin
  Ansicls;
  Load_XyRec;
  DrawfileLister;
  i:=0;

  AddemUp;

  If i > 77
  Then Begin
    For X := 5 to 8 Do
      Urec.FileList[x]:=False;
    I := 0;
    AddemUp;
  End;

  X:=1;

  Done := False;

  UpdateLine;
  Update_Num_Used;
  PlaceBlocks;
  
  Repeat

    GoXy(Xy.Prompt[1],Xy.Prompt[2]);

    K := WaitForChar(False);

    if K in ['1'..'8'] then begin
      X := Valu(k);
      If (Not(Urec.FileList[x]) and (i<77) and (Calculate)) or (Urec.FileList[x])
      Then Begin
        AlterNate(Urec.FileList[x],X);
        UpdateLine;
        AddEmUp;
        Update_Num_Used;
      End;
    End Else
      If Upcase(K) = 'Q'
        Then Done := True;

  Until (Done) Or (hungupon);

  AnsiReset;
  AnsiCls;
  WriteUrec;
End;

Procedure Add_Auto_Sig;
Var A : AutoSig;
    Last,X : Byte;
    Me : Message;

    Procedure Redo_Sig;
    Var T : Longint;
    Begin
     If Urec.AutoSig > -1
        Then ReloadText ('AUTOSIG.TXT','AUTOSIG.MAP',Urec.AutoSig,Me)
        Else FillChar(Me,SizeOf(Me),0);

      Me.Title := 'Auto-Signature';
      Me.Anon := False;
      Me.SendTo := 'All';
      Me.Add_AutoSig := False;

      OkForTitle := False;
      If ReEdit (Me,True)
      Then Begin
        Writelog (0,0,'Changed Auto-Signature');
        Deletetext ('AUTOSIG.TXT','AUTOSIG.MAP',Urec.AutoSig);
        Urec.AutoSig := Maketext ('AUTOSIG.TXT','AUTOSIG.MAP',Me,'');
        WriteUrec;
        if Urec.AutoSig < 0 Then
          Writeln (^M'Nothing Saved..');
      End;
      OkForTitle := True;
    End;

    Procedure Nuke_Sig;
    Begin
      If Urec.AutoSig > -1
      Then Begin
        DeleteText('AUTOSIG.TXT','AUTOSIG.MAP',Urec.AutoSig);
        Urec.AutoSig := -1;
        WriteUrec;
        Writeln(^S'Auto-Signature has been deleted..');
      End Else
        Writeln(^S'You don''t have an Auto-Signature to delete!');
    End;

Begin
  WriteHdr('Auto-Signature');
  Writeln(^R'An Auto-Signature is appended to the end of any message you type.'^M);
  Repeat
    Return_AutoSig(A);
    Last := 0;
    For X := 1 To 5
      Do If A[x] <> ''
        Then Last := X;
    If Last < 1
    Then Writeln(^S'You currently do not have an Auto-Signature.')
    Else Begin
      Writeln(^S'Your current Auto-Signature is...'^M);
      For X := 1 To Last
        Do Begin
          Subs1.MultiColor(A[x]);
          Writeln;
        End;
    End;
    WriteStr(^M^A'C'^R'hange/create '^A'D'^R'elete '^A'Q'^R'uit : *');
    If Inpt = ''
      Then Inpt := 'Q';
    Case Upcase(Inpt[1]) Of
      'C' : Redo_Sig;
      'D' : Nuke_Sig;
    End;
  Until (HungUpOn) or (Upcase(Inpt[1]) = 'Q');
End;

Procedure Pick_Emulation;
Var X : Byte;

  Function Return_Actual_Loc(X:Byte) : Byte;
  Var T : Byte;
  Begin
    For T := 1 to FileSize(EMUFile) Do Begin
      Seek(EMUFile,T-1);
      NRead(EMUFile,Emul);
      If EMul.Identity = X
        Then Begin
          Return_Actual_Loc := T;
          Exit;
        End
    End;
    Return_Actual_Loc := 0;
  End;

Begin
  Assign(EMUFile,Cfg.DataDir + 'EMULATE.DAT');
  Reset(EMUFile);

  If IoRESULT <> 0 Then Begin
    Close(EMUFile);
    ReWrite(EMUFile);
    EMul.Name      := 'ViSiON/2';
    EMul.TextDir   := Cfg.TextFileDir;
    EMul.AllowBars := True;
    EMul.MaxLevel  := 32767;
    Emul.Identity  := 1;
    NWrite(EMUFile,Emul);
  End;

  InputFile(Cfg.TextFileDir + 'EMULATE.ANS');

  If Valu(Inpt) < 1 Then Begin
    Close(EMUFile);
    Exit;
  End;

  If Valu(Inpt) > 0 Then Begin
    X := Return_Actual_Loc(Valu(Inpt));
    Close(EMUFile);
    AnsiRESET;
    AnsiCLS;
    If X < 1 Then
      WriteHdr('Emulation Selection #'+Inpt+' does not exist.')
    Else Begin
      WriteHdr('Emulation: '+Emul.Name);
      Urec.Graphics := X;
      Load_Emulation(Urec.Graphics);
    End
  End
End;

Begin
End.
