Program Reg;

Uses Crt,Dos,Gentypes;

Const RegKey=8682025;

Var RegFile:File Of Byte;
    SysOp:String[30];
    BBS:String[80];
    All:String;
    Cnt:Byte;
    K:Byte;

Begin
  ClrScr;
  TextAttr:=15;
  Writeln('ViSiON/2 Registration Utility');
  TextAttr:=7;
  Writeln('(c) 1993 Ruthless Enterprises');
  TextAttr:=8;
  Writeln('Un-Authorized Use Prohibited!');
  Writeln;
  TextAttr:=5;
  Write('NOTE');
  Textattr:=13;
  Write(':');
  TextAttr:=9;
  Writeln(' Registration is Case Sensitive!');
  Writeln;
  TextAttr:=13;
  Write('SysOp Name');
  TextAttr:=5;
  Write(': ');
  TextAttr:=14;
  Readln(SysOp);
  TextAttr:=13;
  Write('BBS Name');
  TextAttr:=5;
  Write(': ');
  TextAttr:=14;
  Readln(BBS);
  All:=SysOp+BBS;
  Assign(RegFile,'REGDATA');
  Rewrite(RegFile);
  RandSeed:=RegKey;
  Cnt:=0;
  Repeat
    Inc(Cnt);
    K:=Ord (All[Cnt]) Xor Random(255);
    Write(RegFile,K);
  Until Cnt>=Length(All);
  Writeln;
  Writeln('All Done! ');
  Writeln;
  TextAttr:=9;
  Writeln('You have created a registration file for:');
  TextAttr:=13;
  Writeln;
  Writeln('SysOp: '+SysOp);
  Writeln('BBS..: '+Bbs);
  Writeln;
  Close(RegFile);
End.
