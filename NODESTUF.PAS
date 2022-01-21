{$R-,S-,I-,D-,F-,V-,B-,N-,L+,O+}

Unit NodeStuf;
                     (* ViSiON/2 Multi-Node Stuff *)
Interface

Procedure MultiNode_Chat;

Implementation

Uses Dos, MNeT, Crt, Configrt, General, Gentypes, Subs1, Modem, Windows,
     Subs2, Mainr1, Mainr2, OpenShare;

Const MaxNodes = 10;

Type Chat_Rec = Record
       Active : Boolean;
       Color  : Byte;
       StartY : Byte;
       EndY   : Byte;
       Name   : Mstr;
     End;

Const Invalid : Set Of Char = [#0..#31,'"',']','[',':','\','>','<','/','?',
  '*','|','+','=',';', ','];

Var ChatFile    : File Of Chat_Rec;
    Chat        : Chat_Rec;
    TotalActive : Byte;
    WhichActive : Array[1..MaxNodes] Of Boolean;
    Who         : Array[1..MaxNodes] Of Chat_Rec;
    Save_Str    : Array[1..MaxNodes] Of String[255];
    Dirs        : Array[1..MaxNodes] Of DirStr;
    NNum        : Byte;
    Lock        : Boolean;

Procedure Get_Dirs;
Var T : Text;
    S : Lstr;
    P,Num : Byte;

  Function Dir_Exists(Dir : Lstr) : Boolean;
  Var I : Integer;
      F : File;
  Begin
    Assign(F,Dir + 'CON');
    Reset(F);
    I := IoResult;
    Dir_Exists := I = 0;
    Close(F);
  End;

  Procedure IsPath (Var X : Lstr; Name : Lstr);
  Var Lc : Char;
      Cur : Lstr;
      N : Integer;
  Begin
    If Not Dir_Exists(X)
    Then Begin
      Writeln (^S + name + ' = Path Bad: '+x);
      Writeln(^R'Creating Directory...');
      Lc := X[ Length(X) ];
      If (Length(X) <> 1)
      Then If (Lc <> ':') and (Lc <> '\')
        Then X := X + '\';
      If X [ Length(X) ] = '\'
        Then X[0] := Pred(x[0]);
      GetDir (0,Cur);
      ChDir (x);
      n:=ioresult;
      ChDir (Cur);
      If N = 0 Then Begin Writeln('Error!'); Exit; End;
      MkDir(x);
      If IoResult <> 0 Then Writeln('Error creating directory: ');
   End;
  End;

    Procedure Process;
    Var P : Byte;
        Temp : String[60];
    Begin
      Num := 0;
      P := Pos('NODE #',UpString(S));
      If P < 1
        Then Exit;
      P := P + 6;
      Num := Valu(S[P]);
      If Num < 1
        Then Begin
          Writeln('Bad Node Value: ',Num);
          Exit;
        End;
      Inc(P);
      Temp := Copy(S,P,255);

      While Temp[1] = #32
        Do Delete(Temp,1,1);

      While Temp[ Length(Temp) ] = #32
        Do Temp[0] := Pred(Temp[0]);

      If Temp[ Length(Temp) ] <> '\'
        Then Temp := Temp + '\';
      Dirs[Num] := Temp;
      IsPath(Dirs[Num],'Multi-Node Chat Dir # '+Strr(Num));
    End;

Var X : Byte;
Begin
  Writeln('Reading In Directories');
  FillChar(Dirs,SizeOf(Dirs),0);
  Assign(T,Cfg.VisionDir + 'NODE.DIR');
  Reset(T);
  While Not Eof(T) Do Begin
    ReadLn(T,S);
    Writeln('Processing ',S);
    If (S[1] <> ';') And (S <> '')
      Then Process;
    Writeln('Done.');
  End;
  TextClose(T);
  For X := 1 to Cfg.TotalNodes Do Begin
    If Dirs[X] = '' Then
      Writeln('Error: Node #'+Strr(X)+' directory not defined!');
  End;
  Writeln('Done');
End;

Procedure Add_User;
Var X : Byte;
Begin

  FillChar(Chat,SizeOf(Chat),0);
  Assign(ChatFile,Cfg.DataDir + 'NODECHAT.DAT');
  If Not Exist(Cfg.DataDir + 'NODECHAT.DAT')
  Then Begin
    Rewrite(ChatFile);
    For X := 1 to Cfg.TotalNodes
      Do nWrite(ChatFile,Chat);
  End Else
    Reset(ChatFile);

{  Lock := LockFile(ChatFile,MNLock); }

  Seek(ChatFile,NNum - 1);
  Chat.Active := True;
  Chat.Name   := Unam;
  Chat.Color  := 15;
  Chat.StartY := 1;
  Chat.EndY   := 10;
  nWrite(ChatFile,Chat);

{  Lock := LockFile(ChatFile,MNUnLock); }

  Close(ChatFile);

End;

Procedure Outta_Here;
Begin
  Assign(ChatFile,Cfg.DataDir + 'NODECHAT.DAT');
  Reset(ChatFile);
{  Lock := LockFile(ChatFile,MNLock); }
  Seek(ChatFile,NNum - 1);
  FillChar(Chat,SizeOf(Chat),0);
  NWrite(ChatFile,Chat);
{  Lock := LockFile(ChatFile,MNUnLock); }
  Close(ChatFile);
End;

Procedure Update_Who;
Var X : Byte;
    Temp : Chat_Rec;
Begin

  TotalActive := 0;
  FillChar(WhichActive,SizeOf(WhichActive),0);

  Assign(ChatFile,Cfg.DataDir + 'NODECHAT.DAT');
  Reset(ChatFile);

{  Lock := LockFile(ChatFile,MNLock); }

  For X := 1 to Cfg.TotalNodes
  Do Begin

    Seek(ChatFile,X-1);
    nRead(ChatFile,Temp);
    FillChar(Who[x],SizeOf(Who[x]),0);

    If Temp.Active Then Begin
      Who[x].Active := True;
      Who[x].Name := Temp.Name;
      Who[x].Color := Temp.Color;
      Who[x].StartY := Temp.StartY;
      Who[x].EndY := Temp.EndY;
      Inc(TotalActive);
      WhichActive[x] := True;
    End

  End;

{  Lock := LockFile(ChatFile,MNUnLock); }

  Close(ChatFile);

End;

Function NextKey(X : Byte) : Char;
Var S : SearchRec;
    F : File;
    L : Lstr;
    K : Char;
Begin
  L := Dirs[NNum] + '??.' + Strr(X);
  FindFirst(L,AnyFile,S);
  If DosError <> 0
    Then Begin
      NextKey := #0;
      Exit;
    End;
  K := S.Name[1];
  If S.Name[2] = '1' Then
    Case S.Name[1] Of
      'A'..'Z' : K := Char( Ord(K) + 32);
      #200 : K := #8;
      #201 : K := #13;
      #202 : K := #32;
      #203 : K := #46;
      #204 : K := #64
      Else K := S.Name[1];
    End;
  NextKey := K;
  Assign(F,Dirs[NNum] + S.Name);
  Erase(F);
  If IoResult <> 0
    Then Writeln('Error Deleteing: '+Dirs[NNum] + S.Name);
End;

Procedure Display(K : Char);
Begin
  Case K Of
    #8  : Write(Direct,^H + #32 + ^H);
    #13 : Writeln;
    Else Write(Direct,K);
  End
End;

Procedure CheckKeys;
Var X : Byte;
    K : Char;
Begin
  For X := 1 To Cfg.TotalNodes
    Do If (WhichActive[X]) And (X <> NNum) Then Begin
      K := NextKey(X);
      If K <> #0 Then Begin
        AnsiColor(Who[x].Color);
        Display(K);
      End
    End
End;

Procedure Write_Char(X : Byte);
Var K : Char;
    F : File;

  Function Still_There : Boolean;
  Var S : SearchRec;
      L : Lstr;
  Begin
    L := Dirs[X] + '??.' + Strr(NNum);
    FindFirst(L,AnyFile,S);
    Still_There := DosError = 0;
  End;

Var Name : String[2];
Begin
  If Not Still_There Then Begin
    K := Save_Str[X][1];
    Delete(Save_Str[X],1,1);
    Name[0] := #0;
    Case K Of
      'a'..'z' : Name := K + '1';
      #8  : Name := #200 + '1';
      #13 : Name := #201 + '1';
      #32 : Name := #202 + '1';
      #46 : Name := #203 + '1';
      #63 : Name := #204 + '1';
      Else If Not (K In Invalid)
        Then Name := K + '0';
    End;
    Assign(F,Dirs[X] + Name + '.' + Strr(NNum));
    Rewrite(F);
    If IoREsult <> 0
      Then Writeln('Error rewriting: '+Dirs[X] + NAME + '.' + Strr(NNum));
    Close(F);
  End;
End;

Procedure Check_Up;
Var X : Byte;
Begin
  For X := 1 to Cfg.TotalNodes
    Do If (WhichActive[X]) And (X <> NNum)
    Then If Length(Save_Str[X]) > 0
      Then Write_Char(X);
End;

Procedure Add_Char(C : Char);
Var X : Byte;
Begin
  For X := 1 to Cfg.TotalNodes
    Do If (WhichActive[X]) And (X <> NNum)
      Then Save_Str[X] := Save_Str[X] + C;
End;

Procedure Do_Update;
Var S : SearchRec;
    L : Lstr;
    F : File;
Begin
  L := Dirs[NNum] + 'UPDATE';
  FindFirst(L,AnyFile,S);
  If DosError <> 0
    Then Exit;
  Update_Who;
  Assign(F,Dirs[NNum] + 'UPDATE');
  Erase(F);
End;

Procedure I_Am_Here;
Var F : File;
    X : Byte;
Begin
  For X := 1 to Cfg.TotalNodes Do
    If (WhichActive[X]) And (X <> NNum)
    Then Begin
      Assign(F,Dirs[X] + 'UPDATE');
      Rewrite(F);
      Close(F);
    End
End;

Procedure Do_Some_Chatting;
Var K : Char;
    X : Byte;
Begin
  FillChar(Save_Str,SizeOf(Save_Str),0);
  Repeat
    Check_Up;
    CheckKeys;
    Check_Up;
    K := #0;
    If (KeyPressed) Or (NumChars > 0)
      Then Begin
        If KeyPressed
          Then K := BiosKey
          Else K := GetChar;
        If K <> ^Z
          Then Begin
            Display(K);
            Add_Char(K);
          End;
      End;
    Do_Update;
  Until (HungUpOn) Or (K = ^Z);
End;

Procedure MultiNode_Chat;
Var X : Byte;
Begin
  If Not Exist(Cfg.VisionDir + 'NODE.DIR') Then Begin
    Writeln(Cfg.VisionDir + 'NODE.DIR not found.. exiting..');
    Exit;
  End;
  NNum := Cfg.NodeNum;
  AnsiCls;
  Writeln(^R'þ '^S'ViSiON/2 Qwik Multi-Node Chat v1.0á - '^R'('^A'^Z'^R') Exits'^M);
  Get_Dirs;
  Add_User;
  Update_Who;
  I_Am_Here;
  Writeln(^R'þ '^S'Who''s in Chat...');
  For X := 1 to Cfg.TotalNodes Do Begin
    If WhichActive[X]
      Then Writeln(^A + '  ' + Who[X].Name);
  End;
  Writeln;
  ClearBreak;
  Inpt[0] := #0;
  Do_Some_Chatting;
  Outta_Here;
End;

Begin
End.