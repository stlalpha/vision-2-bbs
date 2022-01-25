Program TopTen;

Uses Dos,MNeT,GenTypes,ConfigRt,Crt;

Var UFile : File Of UserRec;
    NumUsers : Integer;

procedure MakeTopTen;  { Top Ten Stuff, Base from OLD Lsd Source, which in
                         turn slavelord removed it from the havok source,
                         I hyped it up with a spiffy bar graph & Averages  }

 Type HighestPCR=record
        Name:mstr;
        PCR:longint;
     end;

 Tp=Array[1..10] of HighestPCR;

   Var
    Uploaders,
    LameUploaders,
    Downloaders,
    LameDownloaders,
    Posters,
    GoodUls,
    BadUls,
    GoodDls,
    BadDls,
    LamePosters,
    GoodPosts,
    BadPosts,
    GoodCalls,
    BadCalls : Tp;
    Done : boolean;
    TMPrec : userrec;
    TmpPost : highestpcr;
    X1,
    AverageCalls,
    AveragePosts,
    AverageUls,
    AverageDLs : Longint;
    AvCalls,
    AvPosts,
    AvUls,
    AvDls : Real;
    TopTen : File of Tp;

  Function Percentage(A,B:Integer):Real;
  Begin
    If (A>0) and (B>0) then Percentage:=(A/B)*100
    Else percentage:=0;
  End;

 Procedure InitIt;
 Var A,
     B,
     C,
     D,
     E,
     Cnt,
     UpToDown : LongInt;
     i : Byte;

     Procedure SortIt(Var ArofIt:Tp; Tempo:LongInt; UpOrDown:Boolean);
     Var Cnt,I,quick:Integer;
     Begin
     Quick:=10;
       Done:=False;
       For Cnt:=1 to quick Do
       Begin
         If UpOrDown then
           Begin
           If not Done and (Tempo>ArofIt[Cnt].Pcr) then
           Begin
             If Cnt<quick then
               For I:=quick-1 downto Cnt do ArofIt[I+1]:=ArofIt[I];
             ArofIt[Cnt].Name:=TmpRec.Handle;
             ArofIt[Cnt].PCR:=Tempo;
             Done:=True;
           End;
           End
         Else
           If Not Done and (Tempo<ArofIt[Cnt].PCR) then
           Begin
            If Cnt>1 then
              For I:=quick-1 downto cnt do ArofIt[I+1]:=ArofIt[I];
              ArofIt[Cnt].Name:=TmpRec.Handle;
              ArofIt[Cnt].PCR:=Tempo;
              Done:=True;
            End;
       End;
     End;

     begin
       for cnt:=1 to 10 do begin
        Posters[cnt].pcr:=0;
        posters[cnt].name:='Nobody';
        lamePosters[cnt].pcr:=0;
        lameposters[cnt].name:='Nobody';
        GoodPosts[Cnt].Name:='Nobody';
        GoodPosts[Cnt].PCR:=0;
        BadPosts[Cnt].Name:='Nobody';
        BadPosts[Cnt].Pcr:=0;
        GoodCalls[Cnt].Name:='Nobody';
        GoodCalls[Cnt].Pcr:=0;
        BadCalls[Cnt].Name:='Nobody';
        BadCalls[Cnt].Pcr:=0;
        Downloaders[cnt].pcr:=0;
        downloaders[cnt].name:='Nobody';
        lamedownloaders[cnt].pcr:=0;
        lamedownloaders[cnt].name:='Nobody';
        uploaders[cnt].pcr:=0;
        uploaders[cnt].name:='Nobody';
        lameuploaders[cnt].pcr:=0;
        lameuploaders[cnt].name:='Nobody';
        GoodUls[Cnt].Name:='Nobody';
        GoodUls[Cnt].PCR:=0;
        BadUls[Cnt].Name:='Nobody';
        BadUls[Cnt].PCR:=0;
        GoodDls[Cnt].Name:='Nobody';
        GoodDls[Cnt].PCR:=0;
        BadDls[Cnt].Name:='Nobody';
        BadDls[Cnt].PCR:=0;
       end;
       AvCalls:=0; AvPosts:=0; AvUls:=0; AvDls:=0;
       AverageCalls:=0; AveragePosts:=0; AverageUls:=0; Averagedls:=0;
     If NumUsers < 2
       Then Exit;
     for Cnt := 3 To NumUsers
     Do Begin
      Seek(UFile,Cnt - 1);
      NRead(UFile,TmpRec);
      If TmpRec.NumOn > 0 then
      Begin
        AvCalls:= AvCalls + tmprec.numon;
        AvPosts:= AvPosts + tmprec.nbu;
        AvUls  := AvUls   + tmprec.uploads;
        AvDls  := AvDls   + tmprec.downloads;
	D:=round(Percentage(TmpRec.Nbu,TmpRec.NumOn));
	Sortit(Posters,D,True);
	SortIt(LamePosters,D,False);
	d:=tmprec.KUp;
	SortIt(Uploaders,D,True);
	SortIt(LameUploaders,D,False);
	d:=tmprec.KDown;
	SortIt(Downloaders,D,True);
	SortIt(LameDownloaders,D,False);
	D:=TmpRec.Uploads;
	SortIt(GoodUls,D,True);
	SortIt(BadUls,D,False);
	D:=TmpRec.Downloads;
	SortIt(GoodDls,D,True);
	SortIt(BadDls,D,False);
	SortIt(GoodPosts,TmpRec.Nbu,True);
	SortIt(BadPosts,TmpRec.Nbu,False);
      End;
        SortIt(GoodCalls,TmpRec.NumOn,True);
	SortIt(BadCalls,TmpRec.NumOn,False);
      End;
      If AvCalls>0 then AverageCalls:=Round(AvCalls/(NumUsers-1));
      If AvPosts>0 then AveragePosts:=Round(AvPosts/(NumUsers-1));
      If AvUls>0 then AverageUls:=Round(AvUls/(NumUsers-1));
      If AvDls>0 then AverageDls:=Round(AvDls/(NumUsers-1));
     End;

Begin
  Initit;
  Assign(TopTen,Cfg.DataDir+'TOPTEN.DAT');
  Rewrite(TopTen);
  nWrite(TopTen,GoodPosts);
  nWrite(TopTen,Posters);
  nWrite(TopTen,BadPosts);
  nWrite(TopTen,LamePosters);
  nWrite(TopTen,GoodUls);
  nWrite(TopTen,Uploaders);
  nWrite(TopTen,BadUls);
  nWrite(TopTen,LameUploaders);
  nWrite(TopTen,GoodDls);
  nWrite(TopTen,Downloaders);
  nWrite(TopTen,BadDls);
  nWrite(TopTen,LameDownloaders);
  nWrite(TopTen,GoodCalls);
  nWrite(TopTen,BadCalls);
  BadCalls[1].Pcr := AverageCalls;
  BadCalls[2].Pcr := AveragePosts;
  BadCalls[3].Pcr := AverageULs;
  BadCalls[4].Pcr := AverageDLs;
  Close(TopTen);
End;

Begin
  TextAttr:=9;
  ClrScr;
  ReadCfg;
  Writeln('ViSiON/2 Top-Ten Statistics Creater v1.0á');
  Writeln('(c) Ruthless Enterprises 1993');
  Write('Processing... One Moment... ');
  Assign(UFile,Cfg.DataDir+'USERS');
  Reset(UFile);
  If IoResult <> 0
    Then NumUsers := 0
    Else NumUsers := FileSize(UFile);
  MakeTopTen;
  Close(Ufile);
  Writeln('Done!'#10#13);
End.