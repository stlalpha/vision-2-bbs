Unit Modem;

Interface

Uses ConfigRt, F_Modem;

Var SendChar   : Procedure (K:Char);
    GetChar    : Function : Char;
    Carrier    : Function : Boolean;
    NumChars   : Function : Word;
    ClosePort  : Procedure;
    Ring       : Function : Boolean;
    HangUp     : Procedure;
    DoAnswer   : Procedure;
    DontAnswer : Procedure;
    NukeInput  : Procedure;
    NukeOutput : Procedure;
    SetParam   : Procedure (ComPort:Byte; BaudRate:Longint; Parity:Boolean);
    OpenComPort: Procedure;

Procedure Null_Modem;

Implementation

Procedure Null_Proc;
Begin
End;

Function Null_NumChars : Word;
Begin
  Null_NumChars := 0;
End;

Function Null_Boolean_Func : Boolean;
Begin
  Null_Boolean_Func := False;
End;

Function Null_Char_Func : Char;
Begin
End;

Procedure Null_SendChar (K : Char);
Begin
End;

Procedure Null_SetParam (ComPort:Byte; BaudRate:Longint; Parity:Boolean);
Begin
End;

Procedure Null_Modem;
Begin
  GetChar    := Null_Char_Func;
  SendChar   := Null_SendChar;
  Carrier    := Null_Boolean_Func;
  NumChars   := Null_NumChars;
  ClosePort  := Null_Proc;
  Ring       := Null_Boolean_Func;
  HangUp     := Null_Proc;
  DoAnswer   := Null_Proc;
  DontAnswer := Null_Proc;
  NukeInput  := Null_Proc;
  NukeOutput := Null_Proc;
  SetParam   := Null_SetParam;
  OpenComPort := Null_Proc;
End;

Begin
{  If Cfg.Use_Fos Then Begin }
    GetChar    := F_Modem.GetChar;
    SendChar   := F_Modem.SendChar;
    Carrier    := F_Modem.Carrier;
    NumChars   := F_Modem.NumChars;
    ClosePort  := F_Modem.ClosePort;
    Ring       := F_Modem.Ring;
    HangUp     := F_Modem.HangUp;
    DoAnswer   := F_Modem.DoAnswer;
    DontAnswer := F_Modem.DontAnswer;
    NukeInput  := F_Modem.NukeInput;
    NukeOutput := F_Modem.NukeOutPut;
    SetParam   := F_Modem.SetParam;
    OpenComPort := Null_Proc;
{  End Else Begin
  End; }
  (*
    GetChar    := AP_Modem.GetChar;
    SendChar   := AP_Modem.SendChar;
    Carrier    := AP_Modem.Carrier;
    NumChars   := AP_Modem.NumChars;
    ClosePort  := AP_Modem.ClosePort;
    Ring       := AP_Modem.Ring;
    HangUp     := AP_Modem.HangUp;
    DoAnswer   := AP_Modem.DoAnswer;
    DontAnswer := Ap_Modem.DontAnswer;
    NukeInput  := AP_Modem.NukeInput;
    NukeOutput := AP_Modem.NukeOutPut;
    SetParam   := AP_Modem.SetParam;
    OpenComPort := AP_Modem.OpenComPort;
  *)
End.
