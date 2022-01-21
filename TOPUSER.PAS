{$R-,S-,I-,D-,F-,V-,B-,N-,L+,O+}

Unit TopUser;

Interface

Uses GenTypes;

Procedure ViewTopTen(Which:Byte);
Procedure ViewWhich;

Implementation

Uses Crt, DoS, MNet, PAVT150, ConfigRT, GenSubs, Modem, Windows,
     Subs1, SubsOvr, Subs2;


Procedure ViewTopTen(Which:Byte);
Type HighestPCR=record
        Name:mstr;
        PCR:longint;
     end;

    Tp=Array[1..10] of HighestPCR;

Var I:Byte;
    TopTen:File of Tp;
    TT:Tp;
    B:Boolean;

    Procedure ReadTopTen(What:Byte);
    Begin
      FillChar(Tt,SizeOf(tt),0);
      Assign(TopTen,Cfg.DataDir+'TOPTEN.DAT');
      Reset(Topten);
      Seek(Topten,What-1);
      nRead(TopTen,Tt);
      Close(TopTen)
    End;

    Procedure ShowSomething(T:Byte; ToSay,Header:Mstr);
    Var Cnt,R:Integer;

     Procedure ShowStats;
     Var F : Text;
         K : Char;
         C : String[2];
         Save : Byte;
     Begin
       Assign(F,Cfg.TextFileDir+'TOPTEN'+Strr(T)+'.ANS');
       Reset(F);
       If IoResult<>0 Then Begin
         TextClose(F);
         Exit;
       End;
       While Not(Eof(F)) Or (HungUpOn) Do Begin
         Read(F,K);
         Save:=0;
         If K='|' Then Begin
           Read(F,K);
           Case Upcase(K) Of
           '^':Begin
                C[0]:=#0;
                Save:=0;
                Repeat
                  Read(F,K);
                  If K in ['0'..'9'] Then C:=C+K;
                  Inc(Save);
                Until (Save>2) or (K=';');
                Save:=Valu(C);
                If (Save>0) and (Save<15) Then
                 ReadTopTen(Save);
               End;
           'U':Write(Direct,Urec.Handle);
           'T':Write(Direct,TimeStr(Now));
           'D':Write(Direct,DateStr(Now));
           'N':Begin
                 Read(F,K);
                 If (K='0') or ((Valu(K)>0) and (Valu(K)<10)) Then
                 Write(Direct,TT[Valu(K)+1].Name);
               End;
           'B':Begin
                 Read(F,K);
                 If (K='0') or ((Valu(K)>0) And (Valu(K)<10)) Then
                 PercentBar(Strlong(TT[1].PCR),Strlong(Tt[Valu(K)+1].Pcr));
               End;
           'V':Begin
                 Read(F,K);
                 If (K='0') or ((Valu(K)>0) And (Valu(K)<10)) Then
                 Write(Direct,Strlong(TT[Valu(K)+1].PCR));
               End;
           End;
         End Else Write(Direct,K);
         If ( (Online) And (NumChars>0) ) or (KeyHit) and (In_Command=False) Then Begin
           Break := True;
           TextClose(F);
           Exit;
         End;
       End;
       TextClose(F);
     End;

     Procedure Normal;
     Var X, A : Byte;
     Begin
       ListingFile(Cfg.TextFileDir + 'TOPFIVE.' + Strr(T) + 'T',True);

       A := Length( Strlong(TT[1].Pcr) );

       For X := 1 to 5 Do Begin
          LineCount := 1;
          Sr.C[1] := 'NU'; Sr.S[1] := Strr(X); Sr.T[1] := 1;
          Sr.C[2] := 'NA'; Sr.S[2] := Tt[X].Name; Sr.T[2] := 30;
          Sr.C[3] := 'VA'; Sr.S[3] := Strlong(TT[x].Pcr); Sr.T[3] := A;
          ListingFile(Cfg.TextFileDir + 'TOPFIVE.' + Strr(T) + 'M',False);
       End;

       ListingFile(Cfg.TextFileDir + 'TOPFIVE.' + Strr(T) + 'B',False);
     End;

     Procedure Box;
     Var Cnt:Byte;
     Begin
       Write(^O'ÚÄÄ');            {Â 194} {Ã 197} {Æ 198}
       Write(^P+' '+Header+' '^O);
       For Cnt:=1 to 70-Length(Header) Do Write(Direct,'Ä');
       Writeln('Ä¿');               {192;191;217;218}
       For Cnt:=1 to 5 Do
         Begin
           If Break Then Exit;
           Write(^O'³ ');
           TabUl(Tt[Cnt].Name+' ',28);
           AnsiColor(Urec.Color6);
           Tab(' '+Strlong(Tt[Cnt].PCR)+ToSay,10);
           PercentBar(Strlong(Tt[1].PCR),Strlong(Tt[Cnt].PCR));
           If WhereX<>77 Then Goxy(77,WhereY);
           Writeln(^O'³');
           If Break Then Exit;
         End;
       Write(^O'À');
       For Cnt:=1 to 75 Do Write(Direct,'Ä');
       Write('Ù');
       Writeln(^M);
     End;

     Procedure ShadowBox;
     Var Cnt:Byte;
     Begin
       Write(^O'ÚÂÄÄ');            {Â 194} {Ã 197} {Æ 198}
       Write(^P+' '+Header+' '^O);
       For Cnt:=1 to 70-Length(Header) Do Write(Direct,'Ä');
       Writeln('Â¿');               {192;191;217;218}
       Write('³Æ');
       For Cnt:=1 to 74 Do Write(Direct,'Í');
       Write('µ³');
       AnsiColor(8);
       Writeln('Û');
       For Cnt:=1 to 5 Do
         Begin
           If Break Then Exit;
           Write(^O'³³ ');
           TabUl(Tt[Cnt].Name+' ',28);
           AnsiColor(Urec.Color6);
           Tab(' '+Strlong(Tt[Cnt].PCR)+ToSay,10);
           PercentBar(Strlong(Tt[1].PCR),Strlong(Tt[Cnt].PCR));
           If WhereX<>77 Then Goxy(77,WhereY);
           Write(^O'³³');
           AnsiColor(8);
           Writeln('Û');
           If Break Then Exit;
         End;
       Write(^O'ÀÁ');
       For Cnt:=1 to 74 Do Write(Direct,'Ä');
       Write('ÁÙ');
       AnsiColor(8);
       Writeln('Û');
       Write('  ');
       For Cnt:=1 to 77 Do Write('ß');
       Writeln(^M);
     End;

     Begin
       ReadTopTen(T);
       Case Cfg.DefTopFive Of
         0:ShowStats;
         1:Normal;
         2:Box;
         3:ShadowBox;
       End;
     End;

Begin
    If (Which < 1) OR (Which>14) Then Exit;
    Break:=False;
    Case Which OF
     1 : ShowSomething(1,' Posts','Top Five Posters');
     2 : ShowSomething(2,' %','Top Five Post/Call Ratios');
     3 : ShowSomething(3,' Posts','Five Lowest Posters');
     4 : ShowSomething(4,' #','Five Lowest PCR');
     5 : ShowSomething(5,' UL''s','Top Five Uploaders');
     6 : ShowSomething(6, ' K','Top Five Uploaded K');
     7 : ShowSomething(7,' UL''s','Lowest Five Uploaders');
     8 : ShowSomething(8, ' K','Lowest Five Uploaders K');
     9 : ShowSomething(9,' DL''s','Top Five Downloaders');
     10: ShowSomething(10,' K','Top Five Downloaders K');
     11: ShowSomething(11,' DL''s','Lowest Five Downloaders');
     12: ShowSomething(12,' K','Lowest Five Downloaders K');
     13: ShowSomething(13,' Calls','Top Five Callers');
     14: ShowSomething(14,' Calls','Lowest Five Callers');
    End;
End;

Procedure ViewWhich;
VAR K:Char;
    i:Byte;
Begin
  Repeat
  NoBreak:=True;
  WriteHdr('High/Low Statistics');
  AnsiReset;
  Writeln(^O'['^P'1'^O'] '^S'Top Posters/PCR');
  Writeln(^O'['^P'2'^O'] '^S'Lowest Posters/PCR');
  Writeln(^O'['^P'3'^O'] '^S'Top Uploaders/K');
  Writeln(^O'['^P'4'^O'] '^S'Lowest Uploaders/K');
  Writeln(^O'['^P'5'^O'] '^S'Top Downloaders/K');
  Writeln(^O'['^P'6'^O'] '^S'Lowest Downloaders/K');
  Writeln(^O'['^P'7'^O'] '^S'Top Callers/Lowest Callers');
  Writeln;
  ClearChain;
  WriteStr(^O'['^P'#'^O'] '^R'Any '^A'A'^R'll '^A'Q'^R'uit :&');
  If inpt='' then inpt:='Q';
   K:=Upcase(inpt[1]);
   If (Valu(k)>0) and (valu(k)<8) then ViewTopTen(Valu(k)) Else
   If K='A' then For i:=1 to 7 do ViewTopTen(i) Else
   If K='' then K:='Q';
  Until (K='Q') or (HungUpOn);
  NoBreak:=False;
End;

begin
end.