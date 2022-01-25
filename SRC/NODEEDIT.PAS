Program NodeLists;

Uses Crt,Dos,Gentypes,Configrt,GenSubs,PullTTT5;

Var Node:Node_Net_Rec;
    Fn:File of Node_Net_Rec;
    Input:String;
    I,J,Cnt:Integer;
    C:Char;
    TheMenu:Pull_Array;
    Major,Minor:Byte;
    New : Boolean;

Procedure ShowNode;
Begin
  ClrScr;
  WriteLn('Node #',i);
  WriteLn('Node Password        : ',node.Pass);
  WriteLn('Node Name            : ',Node.Name);
  WriteLn('Node Phone Number    : ',Node.Phone);
  WriteLn('Node Baud Rate       : ',Node.Baud);
  WriteLn('Node ID Number       : ',Node.Node);
  Writeln('Conferences          : ',Node.Conference);
  Writeln('Dial Tries           : ',Node.Dial_Tries);
  Writeln('Seconds Between Tries: ',Node.Second_Delay);
  Writeln('Delay After Connect  : ',Node.Delay_Before_Send);
  Write('Call This Node       : ');
  If Node.Send
    Then Writeln('Yes')
    Else Writeln('No');
  WriteLn;
  WriteLn('Press Any Key to View Bases Netted.');
  C:=ReadKey;
  ClrScr;
  Writeln;
  For I:=1 to 255 Do
    If Node.BaseSelection[I] Then WriteLn('Base ID# ',I,' is NetWorked.');
  WriteLn;
  Write('Press Any Key to Continue.');
  C:=ReadKey;
  End;  (* End ShowNode *)

Procedure DisplayNodeInformation;
Begin
  ClrScr;
  Write('Which Node to List:[1-',filesize(Fn),']:');
  ReadLn(Input);
  I:=Valu(Input);
  If (I<1) or (I>(FileSize(Fn))) Then Else Begin
  Seek(Fn,I-1);
  Read(Fn,Node);
  ShowNode;
  End; (* End If then Begin *)
End; (* End DisplayNodeInformation *)

Procedure InitializeThisStuff;
Begin
  ReadCfg;
  Assign(Fn,Cfg.VisionDir+'NODELIST.BBS');
  If Exist (Cfg.VisionDir+'NODELIST.BBS') then
    Reset(Fn) Else ReWrite(Fn);
  ClrScr;
  TextAttr:=9;
  WriteLn('ViSiON/2 BBS Node Editor Version 1.00á');
  Writeln;
  TextAttr:=7;
  Write('Press Any Key To Continue');
  C:=ReadKey;
  ClrScr;
  FillChar(TheMenu,SizeOf(TheMenu),0);
  TheMenu[1]:='\Node Maintenance';
  TheMenu[2]:='List Nodes      ';
  TheMenu[3]:='Edit a Node     ';
  TheMenu[4]:='Delete a Node   ';
  TheMenu[5]:='Add a Node      ';
  TheMenu[6]:='About Node Edit ';
  TheMenu[7]:='\Quit Node Editor';
  TheMenu[8]:='\\';
  Major:=1;
  Minor:=1;
End;         (* End InitializeThisStuff *)

Procedure AboutNodeEdit;
Begin
  TextAttr:=9;
  ClrScr;
  WriteLn('ViSiON/2 Node Editor Version 1.00 is written using TechnoJocks Toolkit.');
  WriteLn('It was written for the implementation of NetWorking version 1.01 which is');
  WriteLn('A TRUE Bi-Directional NetMail routine.');
  GotoXy(24,23);
  TextAttr:=7;
  Writeln;
  Write('Press Any Key to Continue.');
  C:=ReadKey;
End;               (* End AboutNodeEdit *)

  Procedure GetPhoneNum;
  Begin
    TextAttr:=9;
    Writeln;
    If Not New
      Then Writeln('Old Phone Number : ',Node.Phone);
    Write('Enter the Phone Number for this Node (Numerals ONLY): ');
    TextAttr:=14;
    ReadLn(Input);
    If Input<>'' Then Node.Phone := Input;
  End;  (* End GetPhoneNum *)

  Procedure GetName;
  Begin
    TextAttr:=9;
    Writeln;
    If Not New
      Then Writeln('Old NAME For This Node : ',Node.Name);
    Write('Enter the Name for this Node : ');
    TextAttr:=14;
    ReadLn(Input);
    If Input<>'' then Node.Name:=Input;
  End; (* End GetName *)

  Procedure GetBaud;
  Begin
    TextAttr:=9;
    Writeln;
    If Not New
      Then Writeln('Old Baud Rate for this node : ',Node.Baud);
    Write('Enter the Baud Rate for this node : ');
    TextAttr:=14;
    ReadLn(Input);
    If Input='1200' then Node.Baud:=1200
      Else
    If Input='2400' then Node.baud:=2400
      Else
    If Input='4800' then Node.Baud:=4800
      Else
    If Input='9600' then Node.Baud:=9600
      Else
    If Input='19200' then Node.Baud:=19200
      Else
    If Input='38400' then Node.Baud:=38400;
  End; (* End GetBaud *)

  Procedure NodePassword;
  Begin
    TextAttr:=9;
    Writeln;
    If Not New
      Then Writeln('Old Node Password : ',Node.Pass);
    Write('Enter The Node Password : ');
    TextAttr:=14;
    ReadLn(Input);
    If Input<>'' then Node.Pass:=Input;
  End; (* End NodePassword *)

  Procedure NodeIDNumber;
  Begin
    TextAttr:=9;
    Writeln;
    If Not New
      Then Writeln('Old Node ID Number : ',Node.Node);
    Write('Enter the Node ID Number : ');
    TextAttr:=14;
    ReadLn(Input);
    If Input <> '' Then Node.Node:=Input;
  End; (* End NodeIDNumber *)

  Procedure Conference;
  Begin
    TextAttr:=9;
    Writeln;
    If Not New
      Then Writeln('Old Conferences Number : ',Node.Conference);
    Write('Enter the Conference Number : ');
    TextAttr:=14;
    Readln(Input);
    If Valu(Input) > 0 Then
      Node.Conference := Valu(Input);
  End;

  Procedure Get_Dial_Tries;
  Begin
    TextAttr := 9;
    Writeln;
    If Not New
      Then Writeln('Old Dial Tries : ',Node.Dial_Tries);
    Write('Enter Dial Tries (Cr/10) : ');
    TextAttr := 14;
    ReadLn(Input);
    If Valu(Input) > 0 Then
      Node.Dial_Tries := Valu(Input)
      Else Node.Dial_Tries := 10;
  End;

  Procedure Get_Second_Delay;
  Begin
    TextAttr := 9;
    Writeln;
    If Not New
      Then Writeln('Old Seconds Delay (Between tries) : ',Node.Second_Delay);
    Write('Enter Seconds Delay (Cr/60): ');
    TextAttr := 14;
    ReadLn(Input);
    If Valu(Input) > 0 Then
      Node.Second_Delay := Valu(Input)
      Else Node.Second_Delay := 60;
  End;

  Procedure Call_This_Node;
  Begin
    TextAttr := 9;
    Writeln;
    Write('Call this Node (for those who Hub AND Receive) [Y/n] : ');
    TextAttr := 14;
    Readln(Input);
    Node.Send := Upcase(Input[1]) <> 'N';
  End;

  Procedure Get_Delay_Before_Send;
  Begin
    TextAttr := 9;
    Writeln;
    If Not New
      Then Writeln('Old Delay Before Send (After Connect) : ',Node.Delay_Before_Send);
    Write('Delay Before Send (Cr/5) : ');
    TextAttr := 14;
    ReadLN(Input);
    If Valu(Input) > 0 Then
      Node.Delay_Before_Send := Valu(Input)
      Else Node.Delay_Before_Send := 5;
  End;

  Procedure Get_Last_Date;
  Begin
    TextAttr := 9;
    Writeln;
    If Not New
      Then Begin
        Writeln('Last Date NET Sent: '+DateStr(Node.LastDate));
        Writeln('Note: Setting this back can cause DUPLICATE messages!');
      End;
    Write('Last Send Date (Form: mm/dd/yy) : ');
    TextAttr := 14;
    ReadLN(Input);
    If (Input='') And (Not New)
      Then Exit;
    Node.LastDate := DateVal(Input);
  End;


Procedure AddNode;
Begin
  ClrScr;
  New := True;
  FillChar(Node,SizeOf(Node),0);
  TextAttr:=15;
  Writeln('Adding a NEW Node...');
  Writeln;

  GetName;
  If Input='' then Exit;

  NodePassword;
  If Input='' then Exit;

  GetPhoneNum;
  If Input='' then Exit;

  GetBaud;
  If Input='' then Exit;
  
  NodeIDNumber;
  If Input='' then Exit;

  Conference;
  If Valu(Input) = 0 Then Exit;

  Call_This_Node;
  Get_Dial_Tries;
  Get_Second_Delay;
  Get_Delay_Before_Send;
  Get_Last_Date;

  ClrScr;
  TextAttr:=15;

  WriteLn('Now we are going to pick the BASE ID''s to be networked.');
  WriteLn('Just enter the net ID''s that you WISH to pick up and then enter');
  WriteLn('A "0" when you are done.');
  Writeln;
   Repeat
     TextAttr:=9;
     Write('Base ID: ');
     TextAttr:=14;
     ReadLn(Input);
     I:=Valu(Input);
     If (I>0) and (I<256) then Node.BaseSelection[I]:=True;
     If (I>255) or (I<0) then WriteLn('Invalid range!');
   Until I=0; (* End Repeat Loop *)

   Write('Adding Node To List...');
   Seek(Fn,FileSize(Fn));
   Write(Fn,Node);
   WriteLn('Completed!');
   WriteLn('Press Any Key to Continue.');
   C:=ReadKey;
   New := False;
  End;               (* End AddNode *)

Procedure DeleteNode;
Begin
  ClrScr;
  Write('Whice Node to Delete [1-',filesize(Fn),']:');
  ReadLn(Input);
  I:=Valu(Input);
  If (I<1) or (I>FileSize(Fn)) then Exit;
  Write('Deleting Node...');
  Dec(I);
  For Cnt:=i to FileSize(Fn)-2 do Begin
    Seek(Fn,Cnt+1);
    Read(Fn,Node);
    Seek(Fn,Cnt);
    Write(Fn,Node);
  End;
  Seek(Fn,FileSize(Fn) - 1);
  Truncate(Fn);
  Close(Fn);
  Assign(Fn,Cfg.VisionDir+'NodeList.BBS');
  Reset(Fn);
  WriteLn('Deleted.');
  WriteLn;
  WriteLn('Press Any Key to Continue.');
  C:=ReadKey;
End; (* End DeleteNode *)

Procedure EditNode;
Var EditMenu:Pull_Array;
    EMajor,EMinor:Byte;
    NodeNum:Integer;

  Procedure InitEditor;
  Begin
    FillChar(EditMenu,SizeOf(EditMenu),0);
    EMajor:=1;
    Eminor:=1;
    EditMenu[1]:='\Editing ' + Node.Name;
    EditMenu[2]:='Phone Number    ';
    EditMenu[3]:='Baud Rate       ';
    EditMenu[4]:='Node Name       ';
    EditMenu[5]:='Show Node Info  ';
    EditMenu[6]:='Node Password   ';
    EditMenu[7]:='Node ID Number  ';
    EditMenu[8]:='Net Worked Bases';
    EditMenu[9]:='Conference #    ';
   EditMenu[10]:='Total Tries     ';
   EditMenu[11]:='Tries Delay     ';
   EditMenu[12]:='Connect Delay   ';
   EditMenu[13]:='Call This Node  ';
   EditMenu[14]:='Last Net Date   ';
    EditMenu[15]:='\Quit Editing   ';
    EditMenu[16]:='\\';
  End; (* End InitEditor *)

  Procedure NetBases;
  Begin
    TextAttr:=9;
    ClrScr;
    WriteLn('To Change the status of a base ID Number to network, just enter the');
    WriteLn('The Base Number to change. When you are finished, just enter a "0"');
    WriteLn;
    Repeat
      TextAttr:=9;
      Write('Base ID To Change : ');
      TextAttr:=14;
      ReadLn(Input);
      I:=Valu(Input);
      If (I>0) and (I<256) then Begin
         Node.BaseSelection[I]:=Not Node.BaseSelection[I];
         If Node.BaseSelection[I] then WriteLn('Base ID: ',i,' WILL be networked.')
         Else
         WriteLn('Base ID: ',I,' Will NOT be networked.');
      End; (* End Conditional Begin *)
    Until I=0; (* End Repeat Loop *)
  End; (* End NetBases *)

  Begin (* Begin Main EditNode Loop *)
    ClrScr;
    TextAttr:=9;
    Write('Enter the Node to Edit: [1-',filesize(Fn),']:');
    TextAttr:=14;
    ReadLn(Input);
    I:=Valu(Input);
    If (I<1) or (I>FileSize(Fn)) then Else Begin
      Seek(Fn,I-1);
      Read(Fn,Node);
      NodeNum := i - 1;
      InitEditor;
      Repeat  (* Begin Main Repeat Loop *)
        ClrScr;
        New := False;
        Pull_Menu(EditMenu,Emajor,Eminor);
        Case EMajor of
          1:Begin
            ClrScr;
            Case Eminor of
              1:GetPhoneNum;
              2:GetBaud;
              3:GetName;
              4:ShowNode;
              5:NodePassword;
              6:NodeIDNumber;
              7:NetBases;
              8:Conference;
              9:Get_Dial_Tries;
             10:Get_Second_Delay;
             11:Get_Delay_Before_Send;
             12:Call_This_Node;
             13:Get_Last_Date;
            End; (* End Eminor case *)
          End;
        End; (* End Case *)
      Until Emajor = 2; (* End Main Repeat Loop *)
    Seek(Fn,NodeNum);
    Write(Fn,Node);
  End; (* End Conditional IF Then *)
End; (* End EditNode *)


Begin
 InitializeThisStuff;
 Pttt.FCol := 15;
 Pttt.BCol := 5;
 Pttt.CCol := 7;
 Pttt.HFCol := 15;
 Pttt.HBCol := 1;
 Pttt.BorCol := 7;
 Pttt.Style := 1;
 Pttt.TopX := 1;
 Repeat
 ClrScr;
 Pull_Menu(TheMenu,Major,Minor);
 New := False;
 Case Major of
   1:Case Minor of
      1:DisplayNodeInformation;
      2:EditNode;
      3:DeleteNode;
      4:AddNode;
      5:AboutNodeEdit;
      End; (* End Case *)
 End;  (* End Case *)
 Until Major = 2;  (* End Repeat Loop *)
 ClrScr;
 TextAttr := 9;
 WriteLn('ViSiON/2 Internal Net Node Editor v1.0á');
 Writeln('(c) Ruthless Enterprises 1993');
 Close(Fn);
End.        (* End Program *)