{$R-,S-,I-,D-,F+,V-,B-,N-,L+,O+ }

Unit Protocol;
                          {/ protocol selection/execution routines /}
Interface

Uses GenTypes;

Function ExecProto (X:Byte; Fn:AnyStr; UploadDir:Lstr) : Integer;

Implementation

Uses Dos, Crt, Mnet, GenSubs, ConfigRt, Windows, StatRet, Modem, Fossil,
     Subs1, Subs2;

  Function PickProto(X:Byte) : String;
  Label Retry;
  Const Filez : Array[1..4] Of String[6] =
        ('PROT_R','PROT_S','PROT_U','PROT_D');
  Var P : ProtoRec;
      FP: File Of ProtoRec;
      K : String[15];
      E : Boolean;
  Begin
    PickProto := '';
    If Not Exist(Cfg.DataDir + Filez[x] + '.DAT') Then Begin
      Writeln(^M^G^R'Protocol File '^A+Filez[x]+'.DAT'^R' not found!');
      Exit;
    End;
    ASSiGN(FP,Cfg.DataDir + Filez[x] + '.DAT');
    Reset(FP);
    K[0] := #0;
    E := Exist(Cfg.TextFileDir + Filez[x] + '.ANS');
    Seek(FP,0);
    While Not Eof(Fp) Do Begin
      nRead(FP,P);
      If Not E Then
        Writeln(^R'['^A+P.Letter+^R'] '^S+P.Desc);
      K := K + Upcase(P.Letter);
    End;
    Retry :
      Inpt[0] := #0;
      Buflen := 1;
      If Not E Then
        WriteStr(^M^R'Protocol Selection; ['^A'Q'^R']uit; '+
        +'['^A'Cr/'+Urec.DefProto+^R']: *')
        Else
          InputFile(Cfg.TextFileDir+Filez[x]+'.ANS');

      If Inpt = ''
        THEN IF POS(Urec.DefProto,K) > 0
          Then Inpt[1] := Upcase(Urec.DefProto)
          Else Inpt[1] := 'Q';

      If Upcase(Inpt[1]) = 'Q' Then Begin
         PickProto := '';
         Close(Fp);
         AnsiCls;
         Writeln(^M^S'Aborted...');
         Exit;
      End;

      If Not Pos(Upcase(Inpt[1]),K) > 0 Then Begin
        DefYes := True;
        WriteStr(^S^R^M'Invalid Selection; Try Again? !');
        If Yes Then Goto Retry;
        Close(Fp);
        PickProto := '';
        Exit;
      End;

    Seek(Fp, (Pos(Upcase(Inpt[1]),K)) - 1);
    nRead(Fp,P);
    Close(Fp);
    PickProto := P.ProgName + #32 + P.CommFmt;
  End;

  Function ExecProto (X:Byte; Fn:AnyStr; UploadDir:Lstr) : Integer;
  Var S : String;
      Blah : Boolean;
      Result : Word;

      Procedure MakeCommandLine(Tp:String);
      Var Bd,Cb : Sstr;
          Ct : Byte;
          C : Char;
      Begin
        Bd := Strlong(BaudRate);
        Cb := Strlong(ConnectBaud);
        Ct:=0;
        S[0] := #0;
        While Ct<>Length(Tp) do
           Begin
             Inc(Ct);
             If Tp[Ct]<>'%' then S:=S+Tp[Ct]
             Else if Ct<Length(Tp) then
               Begin
                 Inc(Ct);
                 C:=Tp[Ct];
                 Case C of
                   '1' : S := S + Strr(Cfg.UseCoM);
                   '2' : S := S + Bd;
                   '5' : S := S + Cb;
                   '4' : S := S + Cfg.DszLog;
                   '3' : S := S + Fn;
                   '6' : S := S + UploadDir;
                 End;
               End;
             End;
        End;

        Procedure Execute(S : String);
        Begin
          SwapVectors;
          Exec(GetEnv('COMSPEC'),'/C '+S);
          SwapVectors;
        End;

        Procedure WriteStats;
        Var U,D : Longint;
        Const Which : Array[1..4] Of Sstr
             = ('Upload','Download','Batch Upload','Batch Download');
        Begin
          ClrScr;
          GotoXy(1,1);
          TextAttr := 31;
          ClrEol;
          U := Urec.KUp;
          D := Urec.KDown;
          Writeln(Usr,Unam + ' - '+Which[x]+'; ULs: '+Strr(Urec.Uploads)+
          +' ('+Strlong(U)+'K) DLs: '+Strr(Urec.Downloads)+' ('+Strlong(D)+'K)');
          TextAttr:=1;
          Execute('TOPLINE.COM');
        End;

  Begin
    S := PickProto(x);
    If S = '' Then Begin
      ExecProto := -1;
      Exit;
    End;
    MakeCommandLine(s);
    WriteStats;
    StartTimer(Status.NumMinsXfer);
    {If Cfg.Use_Fos Then}
      ClosePort;
    Execute(S);
    Result := DosEXITCode;
{    If Cfg.Use_Fos Then Begin }
      Blah := Install_Fossil(Cfg.UseCom);
      SetParam(Cfg.UseCom,BaudRate,False);
{    End; }
    StopTimer(Status.NumMinsXfer);
    StartTimer(Status.NumMinsUsed);
    Execute('TOPLINE.COM');
    AnsiReset;
    ANSiCLS;
    SetUpBottom;
    BottomLine;
    {If Not Cfg.Use_Fos Then}
      SetParam(Cfg.UseCom,BaudRate,False);
    ExecProto := Result;
  End;

begin
end.
