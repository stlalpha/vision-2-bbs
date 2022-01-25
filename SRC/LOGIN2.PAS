{$R-,S-,I-,D-,F+,V-,B-,N-,L+,O+ }

Unit Login2;
                          {/ old misc. login routines /}
Interface

Uses GenTypes;

procedure randomwelcome;
procedure randomstat;
procedure check_waiting_mail;
procedure check_feedback;
procedure check_notices;
procedure show_automessage;
procedure shownewusers;
procedure showlastfive;
procedure one_liners;
procedure check_newnuv;

Implementation

Uses Crt, MNet, ConfigRt, GenSubs, Subs1, MainR1, MailRet, Subs2,
     Group, Email, StatRet, TextRet, Feedback, NUV;

procedure randomwelcome;
begin
  randomize;
  printfile (cfg.textfiledir+'WELCOME.'+strr(random(cfg.numwelcomes)+1));
end;

procedure randomstat;
begin
  randomize;
  printfile (cfg.textfiledir+'MAINSTAT.'+strr(random(cfg.numstats)+1));
end;

procedure check_waiting_mail;
var cnt : integer;
begin
  cnt := getnummail(unum);
  if cnt > 0 then begin
    defyes := true;
    writeln;
    sr.c[1] := 'MA'; sr.s[1] := strr(cnt);
    MultiColor(Strng^.You_Have_Mail);
    Writeln;
    Sr.C[1] := 'MA'; Sr.S[1] := Strr(Cnt);
    WriteStr(Strng^.Read_Mail_Now);
    If Yes
      Then If Init_EMail Then MailRead(False);
  end;
end;

procedure check_feedback;
begin
  If (Ulvl >= Cfg.SysopLevel) Then Begin
    If NumFeedback > 0 Then Begin
      Writeln(^B^R);
      Sr.C[1] := 'FB'; Sr.S[1] := Strr(NumFeedback);
      MultiColor(Strng^.There_Is_FeedBack);
      Writeln;
      Sr.C[1] := 'FB'; Sr.S[1] := Strr(NumFeedback);
      DefYes := True;
      WriteStr(Strng^.Read_Feedback);
      If Yes Then If Init_Feedback
        Then QuickFeedbackRead(False);
    end;
  end;
end;

procedure check_notices;
var f : text; tmp : string;
begin
    If Exist(Cfg.DataDir+'NOTICE.'+Strr(Unum)) then Begin
      LineCount       := 1;
      CheckPageLength := True;
      Writeln;
      Assign(F,Cfg.DataDir+'NOTICE.'+Strr(Unum));
      Reset(F);
      Readln(F,Tmp);
      If Pos(UpString(Urec.Handle),UpString(Tmp)) = 0 Then
      Begin
        Erase(F);
        TextClose(F);
      End Else Begin
        While Not(Eof(F)) Do Begin
          Readln(F,Tmp);
          Writeln(Tmp);
        End;
        TextClose(F);
        WriteStr(Strng^.Delete_Notice);
      End;
      If Yes then Begin
        Assign(F,Cfg.DataDir+'NOTICE.'+Strr(Unum));
        Erase(F);
        TextClose(F);
      End;
      CheckPageLength := False;
      LineCount := 1;
    End;
end;

procedure show_automessage;
begin
  If (Status.ToNext>-1)
  Then Begin
    Writehdr ('Auto Message by '+Status.AMAuthor);
    PrintText ('AUTOMESS.TXT','AUTOMESS.MAP',Status.ToNext);
    Writeln;
    HoldScreen;
  End;
end;

function numbernuvnew : integer;
var n : nuvrec;
    nuvfile : file of nuvrec;
    cnt : byte;
    numbernew : integer;

    function alreadyvoted : byte;
    var x : byte;
    begin
      alreadyvoted := 0;
      for x := 1 to N.TotalVoters do
        If N.Voters[X]=Urec.Handle then Begin
          AlreadyVoted:=X;
          Exit;
        End;
    end;

begin
  NumberNew := 0;
  numbernuvnew := 0;
  If Not Exist(Cfg.DataDir+'NUV.DAT') Then Exit;
  Assign(NuvFile,Cfg.DataDir + 'NUV.DAT');
  Reset(NuvFile);
  Cnt := FileSize(NuvFile);
  If Cnt < 1
    Then Begin
      Close(NuvFile);
      Exit;
    End;
  for cnt := 0 to (Cnt-1) do begin
    seek(NuvFile,Cnt);
    nread(NuvFile,N);
    if alreadyvoted = 0 then inc(numbernew);
  end;
  close(nuvfile);
  numbernuvnew := numbernew;
end;

   Procedure ShowNewUsers;
   var numbernew : byte;
   Var N : NuvRec;
       NuvFile : File Of NuvRec;
       Cnt,A:byte;

      Function AlreadyVoted : Byte;
      VAR X:Byte;
      BEGIN
        AlreadyVoted:=0;
        For X:=1 to N.TotalVoters DO Begin
          If N.Voters[X]=Urec.Handle then Begin
            AlreadyVoted:=X;
            Exit;
          End;
        End;
      END;

   Begin
    NumberNew := 0;

    If Not Exist(Cfg.DataDir+'NUV.DAT')
      Then Exit;

    Assign(NuvFile,Cfg.DataDir + 'NUV.DAT');
    Reset(NuvFile);

    Cnt := FileSize(NuvFile);

    If Cnt < 1
      Then Begin
        Close(NuvFile);
        Exit;
      End;

    NoBreak:=True;

    ListingFile(Cfg.TextFileDir + 'NEWUSERS.TOP',True);

    For Cnt := 0 to ( Cnt - 1 ) Do Begin

      Seek(NuvFile,Cnt);
      nRead(NuvFile,N);

      If AlreadyVoted = 0
        Then Inc(NumberNew);

        Sr.C[1] := 'NU'; Sr.S[1] := Strr(Cnt + 1); Sr.T[1] := 2;
        Sr.C[2] := 'NA'; Sr.S[2] := N.Who; Sr.T[2] := 28;
        Sr.C[3] := 'DA'; Sr.S[3] := DateStr(N.When); Sr.T[3] := 9;
        Sr.C[4] := 'TI'; Sr.S[4] := TimeStr(N.When); Sr.T[4] := 9;

        ListingFile(Cfg.TextFileDir + 'NEWUSERS.MID',False);

     End;

     Close(NuvFile);
     ListingFile(Cfg.TextFileDir + 'NEWUSERS.BOT',False);
     NoBreak:=False;
   End;

   Procedure ShowLastFive;
   Var F : File Of LastRec;
       L : LastRec;
       Start, Size:Integer;
       Cnt,A:Byte;

   Begin
     If Not Exist(Cfg.DataDir+'CALLERS')
       Then Exit;

     Assign(F,Cfg.DataDir+'CALLERS');
     Reset(F);

     Size := FileSize(F);

     If Size < 1 Then Begin
       Close(F);
       Exit;
     End;

     If Size > 6
       Then Size := 6;

     If (Local) And (KeepQuite)
       Then Begin
         Start := 0;
         Dec(Size);
         If Size < 1
           Then Exit;
       End
       Else Start := 1;

     NoBreak:=True;
     ListingFile(Cfg.TextFileDir + 'LASTFIVE.TOP',True);

     For Cnt := Start To Size - 1 Do Begin
       Seek(F,Cnt);
       nRead(F,L);
       
       Sr.C[1] := 'NU'; If (Local) And (KeepQuite)
                          then Sr.S[1] := Strr(Cnt + 1)
                          else Sr.S[1] := Strr(Cnt);
                          Sr.T[1] := 2;
       Sr.C[2] := 'UN'; Sr.S[2] := L.Name; Sr.T[2] := 28;
       Sr.C[3] := 'AC'; Sr.S[3] := L.Ac; Sr.T[3] := 3;
       Sr.C[4] := 'CA'; Sr.S[4] := Strr(L.CallNum); Sr.T[4] := 5;
       Sr.C[5] := 'DA'; Sr.S[5] := DateStr(L.When); Sr.T[5] := 9;
       Sr.C[6] := 'TI'; Sr.S[6] := TimeStr(L.When); Sr.T[6] := 8;
       Sr.C[7] := 'MO'; Sr.S[7] := Strr(L.MinsOn); Sr.T[7] := 4;
       Sr.C[8] := 'BA'; Sr.S[8] := Copy(L.Baud,1,16); Sr.T[8] := 16;

       ListingFile(Cfg.TextFileDir + 'LASTFIVE.MID',False);

     End;

     Close(F);
     ListingFile(Cfg.TextFileDir + 'LASTFIVE.BOT',False);
     NoBreak := False;
   End;

   Procedure One_Liners;
   Const None = 'No one liners exist right now!';
   Var T : Text;
       One_Array : Array[1..18] Of Lstr;
       Total,X : Byte;
       New : Boolean;
       Str : String;
   Begin
     If Not Cfg.Use_One_Liners
       Then Exit;
     Assign(T,Cfg.DataDir + 'ONELINER.DAT');
     New := False;
     If Exist(Cfg.DataDir + 'ONELINER.DAT')
       Then Reset(T)
       Else Begin
         Rewrite(T);
         New := True;
       End;
     Total := 0;
     FillChar(One_Array,SizeOf(One_Array),0);
     If Not New Then
       While (Eof(T) = False)
       Do Begin
         Inc(Total);
         Readln(T,Str);
         If Total < 19
           Then One_Array[Total] := Str;
       End;
     TextClose(T);
     If Total < 1 Then Begin
       Total := 1;
       One_Array[1] := None;
     End;
     If Total > 18
       Then Total := 18;
     ListingFile(Cfg.TextFileDir + 'ONELINER.TOP',False);
     For X := 1 to Total Do Begin
       Sr.C[1] := 'NU'; Sr.S[1] := Strr(X);      Sr.T[1] := 2;
       Sr.C[2] := 'OL'; Sr.S[2] := One_Array[X]; Sr.T[2] := 60;
       ListingFile(Cfg.TextFileDir + 'ONELINER.MID',False);
     End;
     ListingFile(Cfg.TextFileDir + 'ONELINER.BOT',False);
     WriteStr(Strng^.Ask_One_Liner);
     If Not Yes
       Then Exit;
     Buflen := 75;
     WriteStr(Strng^.Enter_One_Liner);
     If Inpt <> '' Then Begin
       If Total > 17
       Then For X := 2 to Total
         Do One_Array[X - 1] := One_Array[X]
       Else Inc(Total);
       If (Total = 2) And (One_Array[1] = None)
         Then Dec(Total);
       One_Array[Total] := Inpt;
       Assign(T,Cfg.DataDir + 'ONELINER.DAT');
       Rewrite(T);
       For X := 1 to Total
         Do Writeln(T,One_Array[X]);
       TextClose(T);
     End
   End;

procedure check_newnuv;
var numbernew : integer;
begin
   numbernew := numbernuvnew;
   If NumberNew > 0 then
     If ( Urec.Level >= Cfg.NuvUseLevel ) and ( Cfg.UseNuv )
     Then Begin
       Writeln(^M);
       Sr.C[1] := 'NE'; Sr.S[1] := Strr(NumberNew);
       MultiColor(Strng^.New_Users_Are_Waiting);
       Writeln;
       DefYes:=True;
       Sr.C[1] := 'NE'; Sr.S[1] := Strr(NumberNew);
       WriteStr(Strng^.Vote_On_NewUsers);
       If Yes
         Then If Init_Nuv Then Nuv.NewScan(true);
     End;
end;

begin
end.