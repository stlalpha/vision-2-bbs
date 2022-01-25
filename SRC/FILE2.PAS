{$R-,S-,I-,D-,F+,V-,B-,N-,L+,O+ }

Unit File2;
                          {/ newscan configuration /}
Interface

Uses GenTypes;

Procedure FixNewScan;

Implementation

Uses MNet, ConfigRt, GenSubs, Windows, Subs1, Subs2, File0, File1;

{/
  Procedure UpdateNewScan;
  Begin
    WriteScanRec(NScan,FileConf);
  End;
/}

  Procedure FixNewScan;
  Const Index : Array[1..10] of Byte = (0,20,40,60,80,100,120,140,160,180);
  Var Back,Page,i : Byte;
      TotalPages : Byte;
      Start,Last : Byte;
      Size : Integer;
      K : Char;

    Procedure PlaceBar(Hi : Boolean);
    Begin
      If Hi
        Then ansicolor(urec.color7)
        Else ansicolor(urec.color6);
      GoXy(9,i + 3);
      Tab(Strr( i + Index[Page]),2);
    End;

    Procedure TopLines;
    Begin
      GoXy(1,1);
      Writeln(^R'Current Page'^A': '^S+Strr(Page)+^R' of '^S+Strr(TotalPages)+
              +^R'   ['^A'๛'^R'] On ['^A'+'^R'] PageDn ['^A'-'^R'] PageUp ['^A'Arrows'^R'] Move ['^A'Q'^R'] Quit');
      Writeln(^O'ออออออออออออออออออออออออ[ '^P'File Area NewScan Config'^O' ]ออออออออออออออออออออออออออ');
    End;

    Procedure Draw20;
    Var X,Y : Byte;
    Begin
      AnsiReset;
      AnsiCls;
      TopLines;
      ClearBreak;
      NoBreak := True; {21}
      Start := Index[Page] + 1;
      Last := Start + 19; {40}
      If Last > Size
        Then Last := Size;
      Y := 3;
      For X := Start To Last Do Begin
        Inc(y);
        GoXy(8,Y);
        SeekAFile(X);
        nRead(Afile,Area);
        Write(^R'['^A);
        Tab(Strr(X),2);
        Write(^R'] ');
        If Allowed_in_Area(X,False,Area) Then Begin
          If (X) in NScan.FileNewScan
            Then Write('  '^S)
            Else Write('๛ '^S);
          If (Area.Password<>'') and (Not (X in EnterPw))
            Then Tabul('[ Password Protected ]',30)
            Else Tabul(Area.Name,30);
          Write(^R' Uploads'^A': '^S);
          Tab(YesNo(Area.Uploads),3);
          Write(^R' Downloads'^A': '^S);
          Tab(YesNo(Area.Downloads),3);
        End Else
          Write(^R'  No Area Exists                 Uploads'^A':     '^R'Downloads'^A':');
      End;
    End;

    Procedure Tag;
    Begin
      SeekAFile(i + Index[Page]);
      nRead(Afile,Area);
      If Allowed_in_Area(i + Index[Page],False,Area) Then Begin
        With NScan Do Begin
          If (i + Index[Page]) In FileNewScan Then Begin
            FileNewScan := FileNewScan-[i+Index[Page]];
            Write(^R'] ๛');
            Write(B_(3));
          End Else Begin
            FileNewScan := FileNewScan+[i+Index[Page]];
            Write(^R']  ');
            Write(B_(3));
          End;
        End;
      End;
    End;

    Procedure Down;
    Begin
      If (Page=TotalPages) and (i + Index[Page] = Size)
        Then Exit;
      PlaceBar(False);
      Inc(i);
      If (i + Index[Page]) > Last Then Begin
        i := 1;
        Inc(Page);
        Draw20;
        PlaceBar(True);
        Exit;
      End;
      PlaceBar(True);
    End;

    Procedure Up;
    Begin
      If (Page=1) and (i=1)
        Then Exit;
      PlaceBar(False);
      Dec(i);
      If i = 0 Then Begin
        i := 20;
        Dec(Page);
        Draw20;
        PlaceBar(True);
        Exit;
      End;
      PlaceBar(True);
    End;

    Procedure PageUp;
    Begin
      If (Page=1)
        Then Exit;
      Dec(Page);
      i:=1;
      Draw20;
      PlaceBar(True);
    End;

    Procedure PageDown;
    Begin
      If (Page>=TotalPages)
        Then Exit;
      Inc(Page);
      i:=1;
      Draw20;
      PlaceBar(True);
    End;

    Begin
      Size := FileSize(AFile);
      TotalPages := Size DiV 20 + 1;
      Back := CurArea;
      Page := 1;
      i := 1;
      Draw20;
      PlaceBar(true);
      Repeat
        K := ArrowKey(False);
        K := Upcase(K);
        Case K Of
          #32  : Tag;
          ^D,^A,'8': Up;
          ^C,^B,'2': Down;
          '+','9'  : PageDown;
          '-','3'  : PageUp;
        End;
      Until (K='Q') or (HungUpOn);
      CurArea := Back;
      SetArea(CurArea,True);
      AnsiReset;
      AnsiCls;
    End;

begin
end.