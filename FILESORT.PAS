{$R-,S-,I-,D-,F+,V-,B-,N-,L+,O+ }

Unit FileSort;
                          {/ file sort routines /}
Interface

Uses GenTypes;

Procedure SortArea;

Implementation

Uses Dos, Crt, MNET, GenSubs, Windows, Subs1, Subs2, File0, File1;

  Procedure SortArea;
  VAR A,Mark:Integer;
      k:Char;
      DoAll:Boolean;

  Const BeenAborted : Boolean = False;

  Function Aborted : Boolean;
  Begin
    If BeenAborted Then Begin
      Aborted := True;
      Exit
    End;
    Aborted := XPressed Or Hungupon;
    If XPressed Then Begin
      Beenaborted := True;
      WriteLn(^B'Newscan Aborted..')
    End
  End;

  procedure filesizesort(Left,Right:integer);
  label
     Again;
  var
     Pivot:integer;
     P,Q:integer;
     tp1,tp2,tp3,tp4:udrec;

     begin
        P:=Left;
        Q:=Right;
        Pivot:=(Left+Right) div 2;
        GoXy(44,5);
        Write(^S+Strr(pivot)+' ');
        Seek(udfile,pivot);
        nRead(udfile,tp1);
        While P<=Q do
        begin
         Seek(udfile,p);
         nRead(udfile,tp2);
         while tp2.filesize<tp1.filesize do begin
               inc(p);
	       Seek(udfile,p);
               nRead(udfile,tp2);
         end;
           Seek(udfile,q);
           nRead(udfile,tp3);
           while tp1.filesize<tp3.filesize do begin
                 dec(Q);
                 Seek(udfile,q);
                 nRead(udfile,tp3);
           end;
           if P>Q then goto Again;
           tp4:=tp3;
           tp3:=tp2;
           tp2:=tp4;
           Seek(udfile,p);
           nWrite(udfile,tp2);
           Seek(udfile,q);
           nWrite(udfile,tp3);
           inc(P);
           dec(Q);
	   end;

        Again:
        if Left<Q  then filesizesort(left,Q);
        if P<Right then filesizesort(P,Right);
  end;

  Procedure filenamesort(Left,Right:integer);
  label
     Again;
  var
     Pivot:integer;
     P,Q:integer;
     tp1,tp2,tp3,tp4:udrec;

     begin
        P:=Left;
        Q:=Right;
        Pivot:=(Left+Right) div 2;
        GoXy(44,5);
        Write(^S+Strr(pivot)+' ');
        Seek(udfile,pivot);
        nRead(udfile,tp1);
        while P<=Q do
        begin
         Seek(udfile,p);
         nRead(udfile,tp2);
         While (UpString(tp2.filename)<(UpString(tp1.filename))) Do Begin
               inc(p);
	       Seek(udfile,p);
               nRead(udfile,tp2);
         end;
           Seek(udfile,q);
           nRead(udfile,tp3);
           while (UpString(tp1.filename)<(UpString(tp3.filename))) do begin
                 dec(Q);
                 Seek(udfile,q);
                 nRead(udfile,tp3);
           end;
           if P>Q then goto Again;
           tp4 := tp3;
           tp3 := tp2;
           tp2:=tp4;
           Seek(udfile,p);
           nWrite(udfile,tp2);
           Seek(udfile,q);
           nWrite(udfile,tp3);
           inc(P);
           dec(Q);
	   end;

        Again:
        if Left<Q  then filenamesort(left,Q);
        if P<Right then filenamesort(P,Right);
  end;

  procedure filedatesort(Left,Right:integer);
  label
     Again;
  var
     Pivot:integer;
     P,Q:integer;
     tp1,tp2,tp3,tp4:udrec;

     begin
        P:=Left;
        Q:=Right;
        Pivot:=(Left+Right) div 2;
        GoXy(44,5);
        Write(^S+Strr(pivot)+' ');
        Seek(udfile,pivot);
        nRead(udfile,tp1);
        while P<=Q do
        begin
         Seek(udfile,p);
         nRead(udfile,tp2);
         while tp2.when<tp1.when do begin
               inc(p);
	       Seek(udfile,p);
               nRead(udfile,tp2);
         end;
           Seek(udfile,q);
           nRead(udfile,tp3);
           while tp1.when<tp3.when do Begin
                 dec(Q);
                 Seek(udfile,q);
                 nRead(udfile,tp3);
           end;
           if P>Q then goto Again;
           tp4:=tp3;
           tp3:=tp2;
           tp2:=tp4;
           Seek(udfile,p);
           nWrite(udfile,tp2);
           Seek(udfile,q);
           nWrite(udfile,tp3);
           inc(P);
           dec(Q);
	   end;

        Again:
        if Left<Q  then filenamesort(left,Q);
        if P<Right then filenamesort(P,Right);
  end;

      Procedure DoSort;
      Begin
        Mark := NumUDS-1;
        If Mark > 0 Then Begin
        GoXy(1,1);
          Write(Direct,#27+'[27C'); Writeln(^R'ีอออออออออออออออออออออออออออออธ');
          Write(Direct,#27+'[27C'); Writeln(^R'ณ    '^S'ViSiON/2 File Sorter     '^R'ณ');
          Write(Direct,#27+'[27C'); Write  (^R'ณ '^P'Area'^O': '^A); Tab(Copy(area.name,1,22),22); Writeln(^R'ณ');
          Write(Direct,#27+'[27C'); Write  (^R'ณ '^P'Sorting Method'^O': '^A);
          Case K of 'F':Tab('By Name',12);
                    'D':Tab('By Date',12); 'S':Tab('By Size',12); End; Writeln(^R'ณ');
          Write(Direct,#27+'[27C'); Writeln(^R'ณ '^P'Current File #'^O':             '^R'ณ');
          Write(Direct,#27+'[27C'); Write(^R'ณ '^P'Total Files'^O': '^A); Tab(Strr(NumUds),15); Writeln(^R'ณ');
          Write(Direct,#27+'[27C'); Writeln(^R'ิอออออออออออออออออออออออออออออพ');
          Case K of
            'F':filenamesort(0,Mark);
            'D':filedatesort(0,Mark);
            'S':filesizesort(0,Mark);
          End
        End
        End;

  Begin
    Writehdr('File Sorting...');
    DoAll:=False;
    WriteStr(^R'Sort All Areas? !');
    DoALL := Yes;
    Inpt[0] := #0;
    writestr(^R'Sort By ['^S'F'^R']ilename ['^S'D'^R']ate'+
    ' ['^S'S'^R']ize ['^S'Q'^R']uits :*');
    K := Upcase(inpt[1]);
    If K=''
      Then K:='Q';
    If K='Q'
      Then Exit;
    writelog(16,6,'');
    AnsiCls;
    If DoALL Then
    For a:=1 To numareas Do Begin
      setarea(a,false);
      DoSort;
      If aborted Then exit
    End Else DOSort;
    Writeln(^M^M);
    WriteHDR('Sort Complete');
  End;

begin
end.