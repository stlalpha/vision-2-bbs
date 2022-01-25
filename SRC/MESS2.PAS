{$R-,S-,I-,D-,F+,V-,B-,N-,L+,O+ }

Unit Mess2;
                          {/ message area changing routines /}
Interface

Uses GenTypes;

procedure listboards;
procedure setfirstboard;
procedure setactive (nn:sstr; Show:Boolean);
procedure activeboard;
procedure nextsubboard(Forward:Boolean);

Implementation

Uses Dos, MNET, ConfigRT, Gensubs, StatRet, Subs1, Subs2, Mainr1,
     Mainr2, Mess0, Mess1;

  procedure listboards;
  var cnt,oldcurboard,Total : Integer;
      printed:boolean;
      A : Byte;
  begin
    OldCurBoard := CurBoardNum;
    Total := 0;

      ListingFile(Cfg.TextFileDir + 'MSGAREA.TOP',True);

      if break then exit;

      For Cnt := 0 to FileSize( BDFile ) - 1 Do
        If HaveAccess( Cnt ) Then
          With CurBoard Do Begin

            Sr.C[1] := 'NU'; Sr.S[1] := ShortName; Sr.T[1] := 2;
            Sr.C[2] := 'AN'; Sr.S[2] := BoardName; Sr.T[2] := 30;
            Sr.C[3] := 'TY'; If UseNet
                               Then Sr.S[3] := NetName
                               Else Sr.S[3] := 'Local'; Sr.T[3] := 15;
            Sr.C[4] := 'LV'; Sr.S[4] := Strr(Level); Sr.T[4] := 5;
            Sr.C[5] := 'NM'; Sr.S[5] := Strr(Messages); Sr.T[5] := 3;
            Sr.C[6] := 'NS'; If CurBoardNum in NScan.NewScanConfig
                              Then Sr.S[6] := #32
                              Else Sr.S[6] := 'û'; Sr.T[6] := 1;

          Inc(Total,Messages);

          ListingFile(Cfg.TextFileDir + 'MSGAREA.MID',False);

          If Break
            Then exit

        End;

      CurBoardnum := Oldcurboard;
      SeekBDFile (Curboardnum);

      Sr.C[1] := 'NM'; Sr.S[1] := Strlong(Total); Sr.T[1] := 1;
      ListingFile(Cfg.TextFileDir + 'MSGAREA.BOT',False);

      Status.TotalMsgs := Total;
      NRead (bdfile,curboard)
  End;

  procedure setactive (nn:sstr; Show:Boolean);
  var per:real;

      Procedure ConfigEnterArea;
      var per:real;
      BEGIN
        per:=round(percentage(lastreadnum,numbuls));
        Sr.C[1] := '|B'; Sr.S[1] := CurBoard.Boardname;
        Sr.C[2] := '|T'; If CurBoard.UseNet
                           Then Sr.S[2] := CurBoard.NetName
                           Else Sr.S[2] := 'Local';
        Sr.C[3] := '|S'; Sr.S[3] := CurBoard.Sponsor;
        Sr.C[4] := '|L'; Sr.S[4] := Strr(Curboard.Level);
        Sr.C[5] := '|N'; Sr.S[5] := Strr(Numbuls);
        Sr.C[6] := '|R'; Sr.S[6] := Strr(LastReadNum);
        Sr.C[7] := '|P'; Sr.S[7] := Streal(Per);
        Sr.C[8] := '|D'; Sr.S[8] := DateStr(Now);
        Sr.C[9] := '|W'; Sr.S[9] := TimeStr(Now);
        Sr.C[10] := '|C'; Sr.S[10] := Strr(MsgConf);
        DataFile(Cfg.TextFileDir+'MSGAREA.HDR');
      end;

    Procedure DoSwitch;
    Var A : Word;
    begin
      openbfile;
      curbul:=lastreadnum;
      If Show Then
      If exist(Cfg.textfiledir+'MSGAREA.HDR') then ConfigEnterArea Else
        Writeln(^G'No MSGAREA.HDR Exists in your TextFile''s DIR!!');
      CurBoard.Messages := NumBuls;
      WriteCurBoard;
    end;

    procedure tryswitch;
    var n,s:integer;

      procedure denyaccess;
      var b:bulrec;
      begin
        reqlevel (curboard.level);
        setfirstboard
      end;

    begin
      curboardname:=nn;
      curboardnum:=searchboard(nn);
      if haveaccess(curboardnum)
        then doswitch
        else denyaccess
    end;

  var b:bulrec;
  begin
    curbul:=0;
    if isopen(bfile) then
      close (bfile);
    curboardname:=nn;
    if boardexist(nn) then tryswitch else begin
      {writeln (^S'Sorry, no such board'^A': ',curboardname,'!');}

      Sr.C[1] := 'SU'; Sr.S[1] := CurBoardName;
      MultiColor(Strng^.Sub_No_Exist);
      Writeln;

      if issysop
        then
          begin
            writestr (^R'Create '^S+curboardname+^R' now? !');
            if yes
              then
                begin
                  makeboard;
                  setactive (curboardname,true)
                end
              else setfirstboard
          end
        else setfirstboard
    end
  end;

  procedure activeboard;
  begin
    if length(inpt)>1
      then inpt:=copy(inpt,2,255)
      else
        Repeat
          Listboards;
          Writestr (Strng^.ChangeBoardStr);
          Writeln;
        Until (inpt<>'?') or hungupon;
    if hungupon or (length(inpt)=0) then exit;
    if inpt[1]='*' then inpt:=copy(inpt,2,255);
    if validbname(inpt)
      then setactive (inpt,true)
      else
        begin
          writeln (^M'Invalid board name!');
          setfirstboard
        end
  end;

  procedure setfirstboard; { FORWARD }
  var fbn:sstr;
  begin
    if filesize(bdfile)=0 then exit;
    if not haveaccess(0)
      then error ('User can''t access first board','','');
    seek (bifile,0);
    nread (bifile,fbn);
    setactive (fbn,false)
  end;

  procedure nextsubboard(Forward:Boolean);
  var cb:integer;
      obn:sstr;
  Const WhichWay:Array [False..True] Of SStr = ('First','Last');
  Label Later;
  begin
    obn:=curboardname;
    cb:=curboardnum;
    while (cb<filesize(bdfile)-1) or ((Forward=False) and (Cb<=FileSize(BDFile)-1)) do begin
      If Forward then inc(Cb) else Begin
        Dec(Cb);
        If Cb<0 then Goto Later Else
      End;
      if haveaccess (cb) then begin
        seek (bifile,cb);
        nread (bifile,obn);
        setactive (obn,true);
        exit
      end
    end;
    Later:
    writeln('This is the '+WhichWay[Forward]+' sub-board!');
  end;

begin
end.