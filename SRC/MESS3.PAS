{$R-,S-,I-,D-,F+,V-,B-,N-,L+,O+ }

Unit Mess3;
                          {/ low level message area routines /}
Interface

Uses GenTypes;

Procedure FixNewScan;
procedure togglenewscan;

Implementation

Uses Dos, MNET, GenSubs, Windows, Subs1, Subs2, Mainr2, Mess0, Mess1;

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
      Writeln(^O'อออออออออออออออออออออออออ[ '^P'Message NewScan Config'^O' ]อออออออออออออออออออออออออออ');
    End;

    Procedure Draw20;
    Var X,Y : Byte;
    Begin
      AnsiReset;
      AnsiCls;
      TopLines;
      Start := Index[Page] + 1;
      Last := Start + 19;
      If Last > Size
        Then Last := Size;
      Y := 3;
      For X := Start To Last Do Begin
          Inc(y);
          GoXy(8,Y);
          Write(^R'['^A);
          Tab(Strr(X),2);
          Write(^R'] ');
        If HaveAccess(X-1) Then Begin
          If CurBoardNum in NScan.NewScanConfig
            Then Write('  '^S)
            Else Write('๛ '^S);
          Tab(CurBoard.BoardName,30);
          Write(^R' Base Type'^A': '^S);
          If CurBoard.EchoType < 1
            Then Write('Local')
            Else Write(CurBoard.NetName);
        End Else
          Write(^R'  No Area Exists                 Base Type'^A': '^S'N/A');
      End;
    End;

    Procedure Tag;
    Begin
      If HaveAccess(i + Index[Page] - 1) Then Begin
        With NScan Do Begin
          If CurBoardNum In NewScanConfig Then Begin
            NewScanConfig := NewScanConfig-[CurBoardNum];
            Write(^R'] ๛');
            Write(B_(3));
          End Else Begin
            NewScanConfig := NewScanConfig+[CurBoardNum];
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
      Size := FileSize(BDFile);
      TotalPages := Size DiV 20 + 1;
      Back := CurBoardNum;
      Page := 1;
      i := 1;
      Draw20;
      PlaceBar(true);
      Repeat
        K := ArrowKey(False);
        K := Upcase(K);
        Case K Of
          #32  : Tag;
          ^D,^A: Up;
          ^C,^B: Down;
          '+'  : PageDown;
          '-'  : PageUp;
        End;
      Until (K='Q') or (HungUpOn);
      CurBoardNum := Back;
      Seekbdfile (CurBoardNum);
      NRead (BDFile,CurBoard);
      AnsiReset;
      AnsiCls;
    End;

  procedure togglenewscan;
  begin
    write (^P'Newscan this board'^O': ');
    if curboardnum in nscan.newscanconfig
      then
        begin
          writeln (^U'Yes');
          nscan.newscanconfig:=nscan.newscanconfig-[curboardnum]
        end
      else
        begin
          writeln (^U'No');
          nscan.newscanconfig:=nscan.newscanconfig+[curboardnum]
        end
  end;

begin
end.