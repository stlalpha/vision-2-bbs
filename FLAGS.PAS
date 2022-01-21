{$R-,S-,I-,D-,F-,V-,B-,N-,L+ }

unit flags;

interface

uses gentypes;

const accessstr:array [accesstype] of string[8]=
        ('By level','Keep out','Let in','');

Procedure GetScanRec(VAR N:NewScanRec; C:Byte);
Procedure WriteScanRec(N:NewScanRec; C:Byte);
procedure setuseraccflag (var n:newscanrec; bn:integer; ac:accesstype);
function getuseraccflag (var n:newscanrec; bn:integer):accesstype;
Procedure Setallflags (bn:integer; ac:accesstype);
Procedure Setalluserflags (var n:newscanrec; ac:accesstype);
Procedure PromptFlag(VAR Flags:Mstr);
Procedure GetFlag(VAR Flags:Mstr);
Function CheckFlags(HisFlags,Flags:Mstr):Boolean;
Procedure WriteFlags(F:Mstr);

implementation

uses Dos,MNeT,configrt,gensubs,subs1,subsovr,subs2;

Procedure GetScanRec(VAR N:NewScanRec; C:Byte);
Begin
  Assign(ScanFile,Cfg.DataDir+'SCANDATA.'+Strr(C));
  Reset(ScanFile);
  FillChar(N,SizeOf(N),0);
  N.NewScanConfig:=[];
  N.Access1:=[];
  N.Access2:=[];
  If IoResult<>0 Then Begin
    Close(ScanFile);
    Exit;
  End;
  If Unum<=FileSize(ScanFile) Then Begin
    Seek(ScanFile,Unum);
    NRead(ScanFile,N);
  End;
  Close(ScanFile);
End;

Procedure DeleteScanRec(Num:Integer);
VAR N:NewScanRec;
Begin
  Assign(ScanFile,Cfg.DataDir+'SCANDATA.1');
  Reset(ScanFile);
  FillChar(N,SizeOf(N),0);
  Seek(ScanFile,Num);
  NWrite(ScanFile,N);
  Close(ScanFile);
End;

Procedure WriteScanRec(N:NewScanRec; C:Byte);
VAR X:Integer;
    Temp:NewScanRec;
Begin
  If Unum<1 Then Exit;
  Assign(ScanFile,Cfg.DataDir+'SCANDATA.'+Strr(C));
  Reset(ScanFile);
  If IoResult<>0 Then Begin
    FillChar(Temp,SizeOf(Temp),0);
    Rewrite(ScanFile);
    NWrite(ScanFile,Temp);
  End;
  If Unum>FileSize(ScanFile) Then Begin
    Seek(ScanFile,FileSize(ScanFile));
    For X:=FileSize(ScanFile)+1 to UNum Do Begin
      FillChar(Temp,SizeOf(Temp),0);
      NWrite(ScanFile,Temp);
    End;
  End;
  N.Name:=Urec.Handle;
  Seek(ScanFile,Unum);
  NWrite(ScanFile,N);
  Close(ScanFile);
End;

procedure setuseraccflag (var n:newscanrec; bn:integer; ac:accesstype);
begin
  if (ord(ac) and 1)=1
    then n.access1:=n.access1+[bn]
    else n.access1:=n.access1-[bn];
  if (ord(ac) and 2)=2
    then n.access2:=n.access2+[bn]
    else n.access2:=n.access2-[bn]
end;

function getuseraccflag (var n:newscanrec; bn:integer):accesstype;
var ac:accesstype;
begin
  getuseraccflag:=accesstype(ord(bn in n.access1) or
                             (ord(bn in n.access2) shl 1))
end;

procedure setallflags (bn:integer; ac:accesstype);
var cnt:integer;
    u:userrec;
    N:NewScanRec;
begin
  Assign(ScanFile,Cfg.DataDir+'NEWSCAN.DAT');
  Reset(ScanFile);
  for cnt:=1 to filesize(ScanFile)-1 do begin
    seek (scanfile,cnt);
    NRead (scanfile,n);
    setuseraccflag (n,bn,ac);
    seek (scanfile,cnt);
    NWrite (scanfile,n)
  end
end;

procedure setalluserflags (var n:NewScanRec; ac:accesstype);
var b1,b2:byte;
begin
  b1:=(ord(ac) and 1)*255;
  b2:=((ord(ac) and 2) shr 1)*255;
  fillchar (n.access1,32,b1);
  fillchar (n.access2,32,b2)
end;

Procedure PromptFlag(VAR Flags:Mstr);
Var OldFlags:Mstr;
    I,B:Byte;
Begin
  OldFlags:=Flags;
  WRite(^P'[A-Z / "-" + Letter = NOT]: ');
  NoCrInput('',15);
  For B:=1 to Length(Inpt) Do If Not (inpt[B] in ['-','A'..'Z','a'..'z'])
    Then Begin
      Ansicolor(117);
      For I:=1 to Length(inpt) Do Write(^H);
      WriteStr(inpt[B]+': Invalid Flag! &');
      Flags:=OldFlags;
      Exit;
    End;
  Flags:=inpt;
End;

Procedure GetFlag(VAR Flags:Mstr);
VAR K:Char;
    P,I:Byte;
    Done:Boolean;
Begin
  Done:=False;
  For K:='A' to 'Z' Do
  If Pos(K,Flags)>0 then Write(K) Else Write('-');
  Write(Direct,#27+'[27D');
  Repeat
  K:=WaitForChar(False);
  K:=UpCase(K);
  If K in ['A'..'Z'] then Begin
    I:=Ord(K)-39;
    Write(Direct,#27+'['+Strr(I-25)+'C');
    P:=Pos(K,Flags);
    If P>0 then Begin
      Delete(Flags,P,1);
      Write('-');
    End Else Begin
      Flags:=Flags+K;
      Write(K);
    End;
    Write(Direct,#27+'['+Strr(I-24)+'D');
  End Else If K=#32 Then Done:=True;
  Until (Done) or  (HungUpOn);
End;

Function CheckFlags(HisFlags,Flags:Mstr):Boolean;
VAR I:Byte;
    B,Neg:Boolean;
Begin
  B:=True;
  If Flags<>'' then Begin;
  i:=0;
  Repeat
    Neg:=False;
    inc(i);
    If Flags[i]='-' then Begin
      inc(i);
      neg:=true;
    End;
    If (Pos(Upcase(Flags[i]),HisFlags)=0) And (Not(Neg)) then Begin
      CheckFlags:=False;
      Exit;
    End Else
    If (Pos(Upcase(Flags[i]),HisFlags)>0) And (Neg) then Begin
      CheckFlags:=False;
      Exit;
    End;
    If Flags[i]=#32 then inc(i);
  Until (i=Length(Flags)) or hungupon;
  End;
  CheckFlags:=B;
End;

Procedure WriteFlags(F:Mstr);
VAR K:Char;
Begin
  For K:='A' to 'Z' Do
    If pos(K,F)>0
      Then Write(K)
      Else Write('-');
End;


begin
end.
