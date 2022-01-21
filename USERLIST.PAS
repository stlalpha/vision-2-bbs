{$R-,S-,I-,D-,F-,V-,B-,N-,L+,O+}

Unit UserList;

Interface

Procedure UserListUtils;

Implementation

Uses Crt, MNeT, Dos, GenTypes, ConfigRt, Gensubs, Subs1, Subs2;

Procedure UserListUtils;

Type Use = Record
       Handle : Mstr;
       Unum   : Integer;
     End;

     UseArray = Array[1..500] Of Use;

     WhichWayType = (Forward,Backward,EqualTo,Null);

Var U       : UserRec;
    BoardAC,
    S       : String[3];
    T,
    Start,
    Finish,
    Tot,
    Level   : Integer;
    Users   : UseArray;
    Who     : Mstr;
    AC      : String[4];
    Which   : WhichWayType;


  Procedure Alphabetize(VAR U:UseArray; N:Integer);
  Var
    I, J, Bottom, Top, Middle : Integer;
    Temp : Use;

  Begin
    For i := 2 to N Do
    Begin
      Temp := U[i];
      Bottom := 1;
      Top := i - 1;
      While Bottom <= Top Do
      Begin
        Middle := (Bottom + Top) Div 2;
        If Temp.Handle < U[Middle].Handle
          Then Top := Middle - 1
          Else Bottom := Middle + 1;
      End;
      For j := i - 1 DownTo Bottom
        Do U[j + 1] := U[j];
      U[Bottom] := Temp;
    End
  End;

  Procedure Get_List_Setup;
  Var K : Char;

    Procedure ShowStats;
    Begin
      Write(^S'N'^R'ame Search : '^S);
      If Who <> ''
        Then Writeln(Who)
        Else Writeln('Any..');
      Write(^S'A'^R'rea Code   : '^S);
      If AC <> ''
        Then Writeln(AC)
        Else Writeln('Any..');
      Write(^S'B'^R'y Level    : '^S);
      If Level < 1
        Then Writeln('All')
        Else Begin
          Case Which Of
            Forward  : Write('Greater Than ');
            Backward : Write('Less Than ');
            EqualTo  : Write('Equal To ');
          End;
          Writeln(Level);
        End
      End;

      Procedure GetName;
      Begin
        WriteStr(^R'Partial/Full Name to Search For ('^S'Cr/All'^R') : *');
        Who := Inpt;
      End;

      Procedure GetAC;
      Begin
        WriteStr(^R'Area Code to Search For ('^S'Cr/All'^R') : *');
        AC := Inpt;
      End;

      Procedure GetLevel;
      Begin
        Which := Null;
        WriteStr('Level to Search For ('^S'Cr/All'^R') : *');
        Level := Valu(Inpt);
        If Level < 1
          Then Exit;
        Repeat
          WriteStr(^S'G'^R'reater, '^S'L'^R'ess then or '^S'E'^R'qual To '+Strr(Level)+'? : *');
          Case UpCase(Inpt[1]) Of
            'G' : Which := Forward;
            'L' : Which := Backward;
            'E' : Which := EqualTo;
          End;
        Until (HungUpOn) Or (Which <> Null);
      End;

  Begin
    Repeat
      ShowStats;
      Write(^M^R'Selection ('^S'Cr'^R'/'^S'Continue'^R') : ');
      K := Upcase(WaitForChar(True));
      Writeln(K);
      Case K Of
        'N' : GetName;
        'A' : GetAC;
        'B' : GetLevel;
      End;
    Until (HungUpOn) Or (K = #13);
  End;

  Procedure LoadList;
  Var Cnt, Endnum : Integer;
      Perc : Sstr;
  Begin
    Tot:=0;
    Write(^M^R'Alphabetizing User List; ('^S'%'^R') Complete'^A': '^S);
    NoBreak := True;
    ClearBreak;
    Endnum := FileSize(UFile) - 1;
    If Endnum > 499 Then Endnum := 499;
    For Cnt := 1 to Endnum
    Do Begin
      Perc := Streal (Percentage(cnt,t)) + '%';
      Write(Direct,Perc);
      Write(Direct,B_(Length(Perc)));
      Seek(Ufile,cnt);
      NRead(UFile,U);
      If U.Handle<>'' Then Begin
        Inc(Tot);
        Users[Tot].Handle := UpString(U.Handle);
        Users[Tot].Unum   := Cnt;
      End;
    End;
    NoBreak := False;
    Finish := Tot;
    Alphabetize(Users,Tot);
    Writeln;
    Reset(UFile);
  End;

  Function Ok_To_List : Boolean;
  Begin
    Ok_To_List := False;
    If Length(U.Handle) < 1
      Then Exit;
    If (Who <> '') And (Pos(UpString(Who),UpString(U.Handle)) = 0)
      Then Exit;
    If (AC <> '') And (S = '') Then Exit;
    If (AC <> '') And (Pos(S,AC) = 0)
      Then Exit;
    If Level > 0 Then
      Case Which Of
        Forward  : If U.Level <= Level Then Exit;
        BackWard : If U.Level >= Level Then Exit;
        EqualTo  : If U.Level <> Level Then Exit;
      End;
    Ok_To_List := True;
  End;

Var Top, NumLd, Cnt : Integer;

Begin

  Who[0] := #0;
  AC[0]  := #0;
  Level  := 0;
  Which  := Null;

  For Top := 1 to NumUsers
    Do Users[Top].Unum := Top;

  Top := 0;

  Start := 1;
  Finish := FileSize(UFile);
  T := FileSize(UFile)-1;

  Get_List_Setup;

  Buflen := 1;

  WriteStr(Strng^.ListUsers);

  Writeln;

  If (Upcase(Inpt[1])='Q')
    Then Exit;

  If (Upcase(inpt[1])='A')
    Then Inpt := 'Y';

  If Yes
  Then LoadList
  Else Begin
   ParseRange(Finish - 1,Start,Finish,'User Listing');
   If Start <= 0
     Then Exit;
  End;

  BoardAC := Copy(Cfg.BoardPhone,1,3);

  ListingFile(Cfg.TextFileDir + 'USERLIST.TOP',True);

  Tot   := 0;
  NumLD := 0;

  For Cnt := Start to Finish Do
  Begin
    Seek (UFile,Users[cnt].unum);
    NRead (UFile,U);

    S := COPY(U.PhoneNum,1,3);

    If Ok_To_List
    Then Begin

      Inc(Tot);

      Sr.C[1] := 'UH'; Sr.S[1] := U.Handle; Sr.T[1] := 28;

      Sr.C[2] := 'LV';
        If U.Level < Cfg.LogonLevel
          Then Sr.S[2] := 'New' Else
        If U.Level = Cfg.SysOpLevel
          Then Sr.S[2] := 'CoSys' Else
        If U.Level > Cfg.SysOpLevel
          Then Sr.S[2] := 'SysOp' Else
        Sr.S[2] := Strr(U.Level);  Sr.T[2] := 5;

      Sr.C[3] := 'CA'; Sr.S[3] := Strr(U.Numon); Sr.T[3] := 4;
      Sr.C[4] := 'PC'; Sr.S[4] := Streal(Percentage(U.Nbu,U.NumOn)); Sr.T[4] := 3;
      Sr.C[5] := 'UN'; Sr.S[5] := U.SysOpNote; Sr.T[5] := 30;

      If U.PhoneNum = '' Then S := '---';
      If BoardAC <> S
        Then Inc(NumLD);
      Sr.C[6] := 'AC'; Sr.S[6] := S; Sr.T[6] := 3;

      If Break
        Then Exit;

      ListingFile(Cfg.TextFileDir + 'USERLIST.MID',False);

      If Break
        Then Exit;

      End
    End;

    If Tot > 0
      Then ListingFile(Cfg.TextFileDir + 'USERLIST.BOT',False);

    Writeln;

    If ( (NumLd > 0) and (Tot > 0) ) Then Begin
      Write(^B^R'Out of the '^A+Strr(Tot)+^R' users listed, '^A+Strr(NumLd)+^R+' ');
      If ( (NumLd > 0) and (Tot > 0) )
        Then Write(^B'['^S+Strr(Round(NumLD / Tot * 100))+'%'^R'] ')
        Else Write(^B'['^S'0%'^R'] ');
      Writeln(^B'are long distance callers.');
    End;

    Reset(UFile);

    WriteLog(0,0,'Viewed User Listing')

End;

Begin
End.