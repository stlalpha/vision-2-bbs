Unit F_Modem;

Interface

Uses Fossil, Configrt;

Procedure SetParam (ComPort:Byte; BaudRate:LongInt; Parity:Boolean);
Procedure ClosePort;
Function  NumChars:Word;
Procedure DontAnswer;
Procedure DoAnswer;
Procedure NukeInput;
Procedure NukeOutput;

Var SendChar   : Procedure (K:Char);
    GetChar    : Function : Char;
    Ring       : Function : Boolean;
    Carrier    : Function : Boolean;
    Hangup     : Procedure;

Implementation

Procedure SetParam (ComPort:Byte; BaudRate:LongInt; Parity:Boolean);
Var K : Char;
    Com : Integer;
Begin
  Case Parity of
   True : K := 'E';
   False: K := 'N';
  End;
  Com := ComPort;
  Set_FOSSIL (Com,BaudRate,8,K,1);
End;

Procedure ClosePort;
Begin
  Close_FOSSIL (cfg.UseCom);
End;

Function NumChars:Word;
Begin
  NumChars := Ord(FOSSIL_Chars);
End;

Procedure DontAnswer;
Begin
  FOSSIL_Dtr (Cfg.UseCom,False);
End;

Procedure DoAnswer;
Begin
  FOSSIL_Dtr (Cfg.UseCom,True);
End;

Procedure NukeInput;
Begin
  Fossil_Nuke_Input(Cfg.UseCom);
End;

Procedure NukeOutPut;
Begin
  Fossil_Nuke_Output(Cfg.UseCom);
End;

Begin
  SendChar:=FOSSIL.SendChar;
  GetChar:=FOSSIL.GetChar;
  Ring:=FOSSIL.Ring;
  Carrier:=FOSSIL.FOSSIL_Carrier;
  Hangup:=FOSSIL.Hangup;
End.