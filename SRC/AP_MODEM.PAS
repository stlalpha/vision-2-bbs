Unit AP_Modem;

Interface

Uses OOCom,ApPort,ConfigRt,GenTypes,Crt;

Procedure SetParam(ComPort:Byte; BaudRate:LongInt; Parity:Boolean);
Procedure ClosePort;
Procedure DontAnswer;
Procedure DoAnswer;
Procedure HangUp;
Procedure SendChar(K:char);
Procedure OpenComPort;
Function  GetChar:Char;
Function  Carrier:Boolean;
Function  Ring : Boolean;
Function  NumChars:Word;
Procedure NukeInput;
Procedure NukeOutput;

procedure IntOff;
procedure IntOn;

Var P : UartPortPtr;

Implementation

Var Current_Baud : Longint;

Procedure SetParam(ComPort:Byte; BaudRate:LongInt; Parity:Boolean);
Const Par : Array[False..True] Of Char = ('N','E');
Begin
  Current_Baud := BaudRate;
  P^.ChangeBaud(BaudRate);
  If Parity Then
    P^.ChangeParity(EvenParity)
  Else
    P^.ChangeParity(NoParity);
End;

Procedure SendChar(K:char);
Begin
  While (Current_Baud < 9600 ) And (Not P^.CheckCTS)
    Do If Not Carrier Then Exit;
  P^.PutCharTimeOut (K,182);
End;

Function GetChar : Char;
Var K:Char;
Begin
  P^.GetCharTimeOut(k,182);
  GetChar := K;
End;

Function Carrier : Boolean;
Begin
  Carrier := P^.CheckDcd;
End;

Function Ring : Boolean;
Begin
  Ring := P^.CheckRi;
End;

Procedure ClosePort;
Begin
  Dispose(P,Done);
End;

Procedure DontAnswer;
Begin
  P^.SetDtr (False)
End;

Procedure DoAnswer;
Begin
  P^.SetDtr (True)
End;

Function NumChars : Word;
Begin
  NumChars := P^.InBuffUsed;
End;

procedure IntOff; Begin inline($9C/$FA); End;
procedure IntOn; Begin inline($9D/$FB); End;

Procedure OpenComPort;
Const ComArray:Array [1..8] of ComNameType=
     (Com1,Com2,Com3,Com4,Com5,Com6,Com7,Com8);
Begin
Current_Baud := Cfg.DefBaudRate;
New(P,InitCustom(
    ComArray[cfg.usecom],
    Cfg.DefBaudRate,
    NoParity,
    8,
    1,
    (2 * 1024),
    (2 * 1024),
    defportoptions));
End;

Procedure HangUp;
procedure elite(ss:mstr);
var cnt,ptr:integer;
    k:char;
begin
  ptr:=0;
  while ptr<length(ss) do
    begin
      Inc(ptr);
      k:=ss[ptr];
      case k of
        '|':sendchar (^M);
        '~':delay (500);
        '^':begin
              Inc(ptr);
              if ptr>length(ss)
                then k:='^'
                else k:=upcase(ss[ptr]);
              if k in ['A'..'Z']
	        then sendchar (chr(ord(k)-64))
		else sendchar(k)
            end;
	else sendchar (k)
      end;
      delay (50);
    end;
  cnt:=0;
end;

Var cnt:byte;
begin
  cnt:=0;
  While Carrier and (Cnt<5) do begin
    dontanswer;
    delay(500);
    elite(cfg.modemhangupstr);
    delay(500);
    doanswer;
    inc(cnt);
  End;
End;

Procedure NukeInput;
Begin
  P^.FlushInBuffer;
End;

Procedure NukeOutput;
Begin
  P^.FlushOutBuffer;
End;

Begin
End.
