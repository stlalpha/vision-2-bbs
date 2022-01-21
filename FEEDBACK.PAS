{$R-,S-,I-,D-,F-,V-,B-,N-,L+,O+ }

unit feedback;

interface

uses gentypes;

const curfeedback : integer = 0;

var fback : mailrec;

procedure writecurfeedback;
procedure delfeedback;
procedure editfeedbackuser;
procedure feedbackinfoform;
procedure nextfeedback;
procedure readagain;
procedure replyfeedback;
procedure listfeedback;
procedure quickfeedbackread (newonly : boolean);
function init_feedback : boolean;

implementation

uses dos, mnet, gensubs, configrt, subs1, textret, subsovr, subs2,
     userret, mainr2, mycomman, overret1;

  function nummessages:integer;
  begin
    nummessages:=filesize(ffile)
  end;

  function checkcur:boolean;
  begin
    {if length(inpt) > 1 then curfeedback:=valu(copy(inpt,2,255));}
    if (curfeedback<1) or (curfeedback>nummessages) then begin
      writeln (^M'Feedback out of range!');
      curfeedback:=0;
      checkcur:=true
    end else begin
      checkcur:=false;
      seek (ffile,curfeedback-1);
      nread (ffile,fback)
    end
  end;

  procedure readnum (n:integer);
  begin
    curfeedback:=n;
    inpt:='';
    if checkcur then exit;
    Sr.C[1] := '|N'; Sr.S[1] := Strr(CurFeedback);     Sr.T[1] := 2;
    Sr.C[2] := '|T'; Sr.S[2] := fback.Title;           Sr.T[2] := 30;
    Sr.C[3] := '|D'; Sr.S[3] := DateStr(fback.When);   Sr.T[3] := 9;
    Sr.C[4] := '|W'; Sr.S[4] := TimeStr(fback.When);   Sr.T[4] := 8;
    Sr.C[5] := '|S'; Sr.S[5] := fback.SentBy;          Sr.T[5] := 30;
    Sr.C[6] := '|N'; Sr.S[6] := YesNo(fback.Read);     Sr.T[6] := 3;
    Sr.C[7] := '|A'; Sr.S[7] := Strr(Nummessages);     Sr.T[7] := 2;
    DataFile(Cfg.TextFileDir + 'FBHDR.ANS');
    if break then exit;
    printtext ('FEEDBACK.TXT','FEEDBACK.MAP',fback.line);
    If fback.Return Then Begin
      fback.Return:=False;
      Notice(fback.SentBy,'Your feedback "'+fback.Title+'" was read...');
      Seek(FFile,CurFeedback-1);
      NWrite(FFile,FBack);
    End
  end;

  procedure writecurfeedback;
  begin
    if (curfeedback<1) or (curfeedback>nummessages) then curfeedback:=0;
    write (^B^M^R'Current msg: '^S);
    if curfeedback=0 then write ('None') else begin
      seek (ffile,curfeedback-1);
      nread (ffile,fback);
      write (fback.title,' by ',fback.sentby)
    end
  end;

  procedure delfeedback;
  var cnt:integer;
  begin
    if checkcur then exit;
    deletetext ('FEEDBACK.TXT','FEEDBACK.MAP',fback.line);
    for cnt:=curfeedback to nummessages-1 do begin
      seek (ffile,cnt);
      NRead (ffile,fback);
      seek (ffile,cnt-1);
      NWrite (ffile,fback)
    end;
    seek (ffile,nummessages-1);
    truncate (ffile);
    curfeedback:=curfeedback-1
  end;

  procedure editfeedbackuser;
  var n:integer;
  begin
    if checkcur then exit;
    n:=lookupuser (fback.sentby);
    if n=0
      then writeln ('User disappeared!')
      else edituser (n)
  end;

  procedure feedbackinfoform;
  begin
    if checkcur then exit;
     WriteStr(^R'Show which infoform? '^O'['^P'1 - 5'^O']:*');
     If (valu(inpt)>0) and (valu(inpt)<6) then
    showinfoforms (fback.sentby,valu(inpt))
  end;

  procedure nextfeedback;
  begin
    inc(curfeedback);
    if curfeedback>nummessages then begin
      Writeln (^M^R'That was the last feedback.');
      curfeedback:=0;
      exit
    end;
    readnum (curfeedback)
  end;

  procedure readagain;
  begin
    if checkcur then exit;
    readnum (curfeedback)
  end;

  procedure replyfeedback;
  begin
    if checkcur then exit;
    Quoting.AllowQuote := True;
    Quoting.MsgNum := fback.Line;
    Quoting.MsgSec := False;
    Quoting.Anon := fback.Anon;
    Quoting.From := fback.SentBy;
    Quoting.SendTo:= 'Managment';
    Quoting.Title:= fback.Title;
    Quoting.When := fback.When;
    Quoting.TxtFile := 'FEEDBACK.TXT';
    Quoting.MailFile := 'FEEDBACK.MAP';
    sendmailto (fback.sentby,false);
    Quoting.AllowQuote := False
  end;

  procedure listfeedback;
  var cnt:integer;
  begin
    if nummessages=0 then exit;
    thereare (nummessages,'piece of feedback','pieces of feedback');
    if break then exit;
    Header('#   Title                          Author ');
    seek (ffile,0);
    for cnt:=1 to nummessages do begin
      NRead (ffile,fback);
      Write(^S);
      tab (strr(cnt),4);
      if break then exit;
      Write(^A);
      tab (fback.title,31);
      Write(^R);
      writeln (fback.sentby);
      if break then exit
    end
  end;

  procedure write_to_file;
  begin
    writeln(^S^R^M);
    if not issysop then begin
      writeln('That command requires sysop access.');
      exit;
    end;
    if (curfeedback < 1) or (curfeedback > nummessages)
      then exit;
    with fback do
      TextToFile('EMAIL.TXT','EMAIL.MAP',Line,Title,SentBy,
                  LookUpUName(SentTo));
  end;

  procedure quickfeedbackread (newonly : boolean);

    Const Names : Array[1..9] Of String[10] =
      (' Next ',' Kill ',' Reply ',' Again ',' Jump ',
       ' List ',' Edit ',' Form ',' Quit ');

    Return : Array[1..9] Of Char = ('N','K','R','A','J','L','E','F','Q');

  Var X : Byte;

    Procedure GetInput;

      Procedure PlaceBar(Hi:Boolean);
      Const Cols : Array[1..9] Of Byte = (2,8,14,21,28,34,40,46,52);
      Begin
        If Hi
          Then Ansicolor(Urec.Color7)
          Else Ansicolor(Urec.Color3);
        Write(Direct,#13);
        Write(Direct,#27 + '[' + Strr(Cols[X] - 1) + 'C');
        Write(Names[x]);
      End;

    Var K : Char;
        Done : Boolean;
    Begin
      If Not BARS_OK Then Begin
        Write(^R'('^S'Feedback'^R') ');
        WriteStr(^S'K'^P'ill '^S'N'^P'ext '^S'R'^P'eply '^S'A'^P'gain '+
        ^S+'J'^P'ump '^S'L'^P'ist '^S'E'^P'dit '^S'F'^P'orm '^S'Q'^P'uit : *');
        Exit;
      End;
      Done := False;
      NoBreak:=True;
      ClearChain;
      Inpt[0]:=#0;
      Write(^B^O+Cfg.BarChar[1]+' '^P'Next  Kill  Reply  Again  Jump  List  Edit  Form  Quit '^O+Cfg.BarChar[2]);
      If NewOnly
        Then Write(^R' ('^S'New Feedback'^R')')
        Else Write(^R' ('^S'All Feedback'^R')');
      PlaceBar(True);
      Repeat
        K := Upcase(ArrowKey(True));
        Case K Of
         ^A,^D,'8','4':
            Begin
              Nobreak:=True;
              PlaceBar(False);
              Dec(x);
              If X < 1
                Then X := 9;
              PlaceBar(True);
              NoBreak := False;
             End;
         #32,^B,^C,'6','2':
             Begin
               NoBreak:=True;
               PlaceBar(False);
               Inc(x);
               If X > 9
                 Then X := 1;
               PlaceBar(True);
               NoBreak:=False;
              End;
         'K','N','R','A','J','L','E','F','Q','+' :
              Begin
                Done:=True;
                Inpt := K;
              End;
         #13 : Begin
               Inpt := Return[X];
               Done := True;
             End;
         End;
      Until (HungUpOn) Or (Done);
      Writeln(^S);
    End;

  Var Done : Boolean;
      TotalRead : Byte;
  Begin
    CurFeedback := 0;
    Done := False;
    TotalRead := 0;
    Repeat
      inc(curfeedback);
      writeln;
      If CurFeedback > NumMessages
      Then Begin
        CurFeedback := 0;
        If (NewOnly) And (TotalRead < 1)
          Then Writeln(^M^S + 'No new feedback found!');
        Exit
      End;
      If NOT CheckCur Then
      If (NewOnly = False) Or ( (NewOnly) And (FBack.Read = False) )
      Then Begin
        Inc(TotalRead);
        X := 1;
        ReadNum (CurFeedback);
        Repeat
          GetInput;
          If Inpt = ''
            Then Inpt := 'N';
          Case Upcase(Inpt[1]) Of
            'R' : ReplyFeedback;
            'A' : ReadNum(CurFeedback);
            'K' : Begin
                    Writeln(^S^R);
                    DelFeedback;
                    Dec(CurFeedback);
                    Inpt := 'N';
                  End;
            'J' : Begin
                    Writeln(^R^S);
                    Write(^R'Mail # to Jump to ');
                    WriteStr('('^A'1-'+Strr(NumMessages)+^R') : *');
                    If (Valu(Inpt)>0) And (Valu(Inpt) <= NumMessages)
                      Then CurFeedback := Valu(Inpt) - 1;
                    Inpt := 'N';
                  End;
            'L' : ListFeedback;
            'E' : EditFeedbackUser;
            'F' : FeedbackInfoform;
            '+' : Write_To_File;
            'Q' : Done := True;
          End;

          If NumMessages < 1
            Then Exit;

        Until (Match(Inpt,'N')) or (Done) or hungupon;
        If Done
          Then Exit;
      End
    Until hungupon;
  End;

  function init_feedback : boolean;
  begin
    init_feedback := true;
    if not exist(cfg.datadir + 'FEEDBACK')
      then begin
        writeln('There is currently no feedback.');
        init_feedback := false;
        exit;
      end;
    if isopen(ffile) then exit;
    close_them_all(ffile);
    assign(ffile,cfg.datadir + 'FEEDBACK');
    reset(ffile);
    curfeedback := 0;
  end;

begin
end.

(*

Var Q : Integer;
label exit;
begin
  assign (ffile,Cfg.datadir+'FEEDBACK');
  reset (ffile);
  if ioresult<>0 then rewrite (ffile);
  curfeedback:=0;
  Quoting.AllowQuote := False;
  Quoting.MsgSec := False;
  repeat
    if nummessages=0 then begin
      writeln ('Sorry, no feedback!');
      goto exit
    end;
    writecurmsg;
    q:=menu ('Feedback','FEED','Q#DEIR_AL+');
    if q<0
      then readnum (-q)
      else case q of
        3:delfeedback;
        4:editusr;
        5:infoform;
        6:replyfeedback;
        7:nextfeedback;
        8:readagain;
        9:listfeedback;
       10:If (curfeedback>0) and (curfeedback<=Nummessages) Then
            TextToFile('FEEDBACK.TXT','FEEDBACK.MAP',fback.Line,fback.Title,fback.SentBy,'SysOp''s')
          Else Writeln('You are not reading a piece of feedback!');
      end
  until (q=1) or hungupon;
  exit:
  close (ffile)
end;

*)