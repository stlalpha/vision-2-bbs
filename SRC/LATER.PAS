{$R-,S-,I-,D-,F-,V-,B-,N-,L+ }

Unit Later;

Interface

Uses Dos,Crt,ConfigRt,StatRet,{Fossil,}Modem,Subs1,UserRet;

Procedure DisConnect;

Implementation

procedure sendmodemstr (ss:string; endifcarrier:boolean);
var cnt,ptr:integer;
    k:char;
label exit;
begin
  ptr:=0;
  while ptr<length(ss) do
    begin
      if keyhit or (carrier=endifcarrier) then goto exit;
      ptr:=ptr+1;
      k:=ss[ptr];
      case k of
        '|':sendchar (^M);
        '~':delay (500);
        '^':begin
              ptr:=ptr+1;
              if ptr>length(ss)
                then k:='^'
                else k:=upcase(ss[ptr]);
              if k in ['A'..'Z']
                then sendchar (chr(ord(k)-64))
                else sendchar (k)
            end;
        else sendchar (k)
      end;
      delay (75);
      {while numchars>0 do writecon (getchar)}
    end;
  cnt:=0;
  repeat
    while numchars>0 do begin
      cnt:=0;
      {writecon (getchar)}
    end;
    cnt:=cnt+1
  until (cnt=1000) or keyhit or (carrier=endifcarrier);
  exit:
  break:=keyhit
end;

procedure hangupmodem;
var tries:integer;
begin
  tries:=0;
  if local then begin
    closeport;
    ensureclosed;
    halt(2);
  end Else
  while carrier and (tries<5) do begin
    hangup;
    sendmodemstr (Cfg.modemhangupstr,false);
    tries:=tries+1
  end;
  setparam (Cfg.usecom,baudrate,parity)
end;

procedure disconnect;
begin
  If unum>0 then Begin
   urec.lastnummsgs:=Status.totalmsgs;
   urec.lastnumfiles:=Status.totalfiles;
   {addlastcaller(unam);}
  End;
  WriteStatus;
  if online then hangupmodem;
  online:=true;
  writelog (0,3,'');
  if (unum>0) and not disconnected then updateuserstats (true);
  disconnected:=true
end;

Begin
End.