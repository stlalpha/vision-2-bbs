procedure showlastcallers;
var qf:file of lastrec;
    cnt,A:integer;
    l:lastrec;
    temp,temp1:String;
    SpaceChar:Char;
    AddSpaces:Boolean;

      Procedure Fill(Len:Byte; Str:Mstr);
      Var X:Byte;
      Begin
        Temp:=Temp+Str;
        If AddSpaces Then Begin
          For X:=Length(Str) To Len-1 Do Temp:=Temp+SpaceChar;
        End;
      End;

Var BoardAc:String[3];
begin
  assign (qf,Cfg.DATADIR+'Callers');
  reset (qf);
  if ioresult=0 then begin
    AnsiCls;
    break:=false;
    BoardAc:=Copy(Cfg.BoardPhone,1,3);
    MultiColor(Strng.LastCallerHdr);
    Writeln;
    for cnt:=0 to filesize(qf)-1 do
      if not break then begin
          nRead(Qf,L);
          SpaceChar:=#32;
          AddSpaces:=False;
          A:=1;
          Temp[0]:=#0;
          Temp1:=Strng.LastCallerLine;
          While A<=Length(Temp1) Do Begin
           If Temp1[A]='^' Then Begin
             Inc(A);
             Case Upcase(Temp1[A]) Of
               '=':Begin
                     Inc(A);
                     SpaceChar:=Temp1[A];
                   End;
               '@':AddSpaces:=True;
               '&':AddSpaces:=False;
               '#':Fill(2,Strr(Cnt+1));
               'N':Fill(30,L.Name);
               'A':Fill(3,L.Ac);
               'C':Fill(5,Strr(L.CallNum));
               'D':Fill(9,DateStr(L.When));
               'T':Fill(8,TimeStr(L.When));
               'M':Fill(4,Strr(L.MinsOn));
               'B':Fill(16,Copy(L.Baud,1,16));
               #0..#255:Temp:=Temp+'^'+Temp1[a];
             End;
           End Else Temp:=Temp+Temp1[A];
           inc(A);
          End;
          While Temp[Length(Temp)]=#32 Do Temp[0]:=Pred(Temp[0]);
          MultiColor(Temp);
          Writeln;
        End;
  end;
  Writeln;
  Writelog(0,0,'Viewed Recent Callers');
  close (qf)
end;