{$R-,S-,I-,D-,F-,V-,B-,N-,L+,O+}

Unit NodeChat;
                                   (* Cheesy Real Time Chat Routines *)
Interface                          (* Written By Crimson Blade 7/93  *)

Procedure MultiNode_Chat;

Implementation

Uses Dos, MNeT, Crt, Configrt, General, Gentypes, Subs1, Modem,
     Windows, SubsOvr, Subs2, MailRet, Mainr1, Mainr2, MyComman;

Const Max_Nodes        = 5;
      Max_ChatFileSize = $4000;
      NodeFile         = 'NODECHAT.';

      Last_Spoken      : Mstr = '';
      Last_Color       : Byte = 0;
      Active           : Word = 0;
      Non_Active       : Word = 1;

Var  FileMarker   : Array[1..Max_Nodes] Of Word;
     ChatFile     : Array[1..Max_Nodes] Of File;
     Node_In_Chat : Array[1..Max_Nodes] Of Boolean;
     Names        : Array[1..Max_Nodes] Of Mstr;
     BufStr       : Lstr;

  Procedure Set_Node_Names; { (X:Byte); }
  Var M : MultiNodeRec; X : Byte;
  Begin
    If Not IsOpen(MNFile) Then Begin
      Assign(MNFile,Cfg.DataDir + 'MULTNODE.DAT');
      Reset(MNFile);
    End;
    For X := 1 to FileSize(MNFile) Do
      Begin
        Seek(MNFile,X-1);
        NRead(MNFile,M);
        Names[X] := M.Name;
      End
  End;

  procedure reformat_file(x:byte);
  var filler : array[1..512] of byte;
      xx : byte;
      result : word;
  begin
    fillchar(filler,sizeof(filler),0);
    seek(chatfile[x],0);
    for xx := 1 to 32 do
      nblockwrite(chatfile[x],filler,sizeof(filler),result);
  end;

  Procedure DeActivate_Node(X:Byte);
  Var Result : Word;
  Begin
    Seek(ChatFile[x],0);
    NBlockWrite(ChatFile[X],Non_Active,2,Result);
  End;

  Procedure Activate_Node(X:Byte);
  Var Result : Word;
  Begin
    Seek(ChatFile[x],0);
    NBlockWrite(ChatFile[X],Active,2,Result);
    Node_In_Chat[X] := True;
    FileMarker[X] := 2;
  End;

  Function Find_Seek(X : Byte) : Word;
  Var TwoBytes, Temp : Word;
  Begin
    Find_Seek := 0;
    If FileSize(ChatFile[x]) < Max_ChatFileSize
      Then Exit;
    Seek(ChatFile[x],0);
    NBlockRead(ChatFile[x],TwoBytes,2,Temp);
    Find_Seek := TwoBytes;
  End;

  Procedure Open_File(X : Byte);
  Begin
    Assign(ChatFile[x],Cfg.DataDir + NodeFile + Strr(X));
    Reset(ChatFile[x],1);
    FileMarker[X]   := Find_Seek(X);
    Node_In_Chat[X] := FileMarker[X] <> 1;
  End;

  Procedure Open_Rewrite_Node(X : Byte);
  Var Null   : Array[1..Max_ChatFileSize] Of Byte;
      Result : Word;
      I      : Integer;
  Begin
    FillChar(Null,SizeOf(Null),0);
    Assign(ChatFile[X],Cfg.DataDir + NodeFile + Strr(X));
    Rewrite(ChatFile[X],1);
    I := IoResult;
    If I <> 0
      Then Writeln('Error Opening Node Chat File(s).');
    NBlockWrite(ChatFile[X],Null,Max_ChatFileSize,Result);
    DeActivate_Node(X);
  End;

  Procedure Open_Existing_Nodes;
  Var X : Byte;
  Begin
    For X := 1 to Cfg.TotalNodes Do If NOT
      Exist(Cfg.DataDir + NodeFile + Strr(X))
        Then Open_Rewrite_Node(X);
    For X := 1 to Cfg.TotalNodes Do
      Open_File(X);
  End;

  Procedure Close_Existing_Nodes;
  Var X : Byte;
  Begin
    For X := 1 to Cfg.TotalNodes Do
      Close(ChatFile[x]);
  End;

  Procedure Init_Things;
  Begin
    FillChar(FileMarker,SizeOf(FileMarker),0);
    FillChar(Node_In_Chat,SizeOf(Node_In_Chat),0);
    FillChar(Names,SizeOf(Names),0);
    Set_Node_Names;
    BufStr[0] := #0;
  End;

  Procedure Write_Char(K:Char);
  Var Where, Result : Word;
  Begin
    Where := Find_Seek(Cfg.NodeNum) + 1;
    If (Where > (Max_ChatFileSize - 2)) Or (Where < 2)
      Then Where := 2;
    Seek(ChatFile[Cfg.NodeNum],Where);
    NWrite(ChatFile[Cfg.NodeNum],K);
    Seek(ChatFile[Cfg.NodeNum],0);
    NBlockWrite(ChatFile[Cfg.NodeNum],Where,2,Result);
  End;

  Function Get_Char(X:Byte) : Char;
  Var Where, Result : Word;
      Temp : Char;
  Begin
    Get_Char := #0;
    Where := Find_Seek(X);
    If Where = 1 Then Begin
      Writeln(^M^R'þ '^S+Names[X]+' has left chat! '^R'þ');
      Names[X] := '';
      Node_In_Chat[X] := False;
      Exit;
    End;
    IF (Where > 1) And (FileMarker[X] < 2)
      Then FileMarker[X] := 2;
    If (Where = FileMarker[X] - 1) Or (Where < 2) Then exit;
    Seek(ChatFile[X],FileMarker[X]);
    NRead(ChatFile[X],Temp);
    Inc(FileMarker[X]);
    If FileMarker[X] > Max_ChatFileSize - 2
      Then FileMarker[X] := 2;
    Get_Char := Temp;
  End;

  Procedure Check_For_New;
  Var X : Byte;
  Begin
    For X := 1 to Cfg.TotalNodes Do
      If Not Node_In_Chat[X] Then
      Begin
        If Find_Seek(X) <> 1 Then Begin
          Set_Node_Names;
          Activate_Node(X);
          Writeln(^B^M^R'þ '^S+Names[X]+' has entered chat! '^R'þ');
        End
      End
  End;

  Procedure Right_Color(X:Byte);
  Const Colors : Array[1..5] of byte = (15,11,9,12,13);
  Begin
    If Last_Color = Colors[x] Then Exit;
    Last_Color := Colors[x];
    If WhereX <> 1 Then Writeln;
    ansicolor(urec.color1);
    Write(direct,Names[x]);
    ansicolor(urec.color3);
    write(direct,'> ');
    AnsiColor(Colors[x]);
  End;

  Procedure Node_Help;
  Begin
    Writeln(^M^R'['^S'^L'^R'] - List Nodes');
    Writeln(^R'['^S'^P'^R'] - Send Private Message');
    Writeln(^R'['^S'^G'^R'] - Send Beep');
    Writeln(^R'['^S'^Z'^R'] - EXIT Node Chat');
  End;

  Procedure Perform_NodeChat;
  Var K : Char; X : Byte;
  Begin
    ANSICLS;
    Node_Listing;
    Writeln;
    WriteHDR('Hit ^K For Chat Help!');
    Repeat
      Check_For_New;
      K := #0;
      For X := 1 to Cfg.TotalNodes
        Do If (Node_In_Chat[X]) OR (X = Cfg.NodeNum) Then Begin
          K := Get_Char(X);
          Case K Of
            #0 :;
            ^M : Begin
                   Last_Color := 0;
                   Writeln(Direct);
                 End;
            ^H : Write(Direct,^H+#32+^H);
            Else Begin
              Right_Color(X);
              If X <> Cfg.NodeNum Then BufStr[0] := #0;
              Write(Direct,K);
            End
          End
        End;
      If CharReady Then Begin
        K := WaitForChar(True);
        Case K Of
          ^Z :;
          ^L : Node_Listing;
          ^P : Send_Node_Message(False);
          ^K : Node_Help;
          ^G : SendChar(^G);
          ^H : If BufStr <> '' Then Begin
                 Write_Char(K);
                 BufStr[0] := Pred(BufStr[0]);
               End;
          ^M : Begin
                 Write_Char(K);
                 Last_Color := 0;
                 BufStr := '';
               End;
          ^A..^Z:;
          Else Begin
            If Length(BufStr) > (80 - (Length(Urec.Handle)+4)) Then
              Begin
                Write_Char(^M);
                BufStr := '';
              End;
            BufStr[0] := Succ(BufStr[0]);
            BufStr[Length(BufStr)] := K;
            Write_Char(K);
          End
        End;
      End;
    Until (K = ^Z) or (HungUpOn);
    Reformat_File(Cfg.NodeNum);
    Deactivate_Node(Cfg.NodeNum);
  End;

Procedure MultiNode_Chat;
Begin
  Open_Rewrite_Node(Cfg.NodeNum);
  Close(ChatFile[Cfg.NodeNum]);
  Init_Things;
  Open_Existing_Nodes;
  Reformat_File(Cfg.NodeNum);
  Activate_Node(Cfg.NodeNum);
  WriteLog(0,0,'Entered Multi-Node Chat');
  UpdateNode('Multi-Node Chat!');
  NoBreak := True;
  Perform_NodeChat;
  Close_Existing_Nodes;
  WriteLog(0,0,'Exited Multi-Node Chat');
  UpdateNode('');
  ClearChain;
End;

Begin
End.
