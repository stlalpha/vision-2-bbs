Unit OvrCall;
{$O+,F+}

Interface

Uses Dos, Crt, Overlay, Configrt;

Implementation

Var X : Byte;
Begin
  For x := 1 to EnvCount Do
    If Copy(ParamStr(x),1,2) = '/$'
      Then ConfigFile := Copy(ParamStr(x),3,$FF);
  GotoXy(1,3);
  TextAttr:=1; Write('þ ');
  TextAttr:=9; Writeln('Reading in external configuration...');
  ReadCfg;
  Textattr:=1; Write('þ ');
  TextAttr:=9; Writeln('Initializing Overlay...');
  OvrInit('VISION.OVR');
  If Cfg.UseEMS
    Then OvrInitEms;
  if (OvrResult <> OvrOK) and cfg.UseEMS then begin
    Writeln('Not enough EMS to put Overlay into memory!');
    Halt(4);
  end;
  If OvrResult <> OvrOK then
  Begin
    WriteLn('Oh No... VISION.OVR is not found or invalid');
    Halt(4);
  End;
End.