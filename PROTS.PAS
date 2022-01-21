{$V-,I-,B-,R-}

Program Prot_Edit;

Uses Dos,Crt,ConfigRt,IoTTT5,KeyTTT5;

Type ProtoRec=Record
       Letter : Char;
       Desc : String[30];
       Progname : String[12];
       Commfmt : String[60];
     End;

     ScreenType = Array[0..3999] of Byte;

Const Files : Array[1..4] Of String[12]
      = ('PROT_S.DAT','PROT_R.DAT','PROT_D.DAT','PROT_U.DAT');

Var CurFile : File Of ProtoRec;
    Total : Byte;
    Prot : Array[1..15] Of ProtoRec;
    ScreenAddr:ScreenType Absolute $B800:$0000;

  Procedure UnCrunch (var Addr1,Addr2; BlkLen:Integer);
  Begin
    InLine
     ($1E/$C5/$B6/Addr1/$C4/$BE/Addr2/$8B/$8E/BlkLen/$8B/$D7/
      $B4/$00/$AC/$3C/$10/$73/$07/$80/$E4/$F0/$0A/$E0/$EB/$44/
      $3C/$18/$74/$13/$73/$19/$2C/$10/$02/$C0/$02/$C0/$02/$C0/
      $02/$C0/$80/$E4/$0F/$0A/$E0/$EB/$2D/$81/$C2/$A0/$00/$8B/
      $FA/$EB/$25/$3C/$1A/$75/$0B/$AC/$49/$51/$32/$ED/$8A/$C8/
      $AC/$EB/$0D/$90/$3C/$19/$75/$11/$AC/$51/$32/$ED/$8A/$C8/
      $B0/$20/$0B/$C9/$74/$03/$AB/$E2/$FD/$59/$49/$AB/$0B/$C9/
      $74/$02/$E2/$AA/$1F);
  End;

  {$I PROTO.INC}

  Procedure LoadFile( X : Byte );
  Var A : Byte;
  Begin
    Assign(CurFile,Cfg.DataDir+Files[x]);
    Reset(CurFile);
    If IoResult <> 0 Then Begin
      Rewrite(CurFile);
      Total := 0;
      Exit;
    End;
    A := 0;
    While Not Eof(CurFile) Do Begin
      Inc(a);
      Read(CurFile,Prot[a]);
    End;
    Close(CurFile);
    Total := A;
  End;

  Procedure WriteFile(X : Byte);
  Var A : Byte;
  Begin
    Assign(CurFile,Cfg.DataDir+Files[x]);
    Rewrite(CurFile);
    For A := 1 to Total Do
        Write(CurFile,Prot[a]);
    Close(CurFile);
  End;

  Procedure Edit(X : Byte);
  Var Cur,A : Byte;
      Let : String[1];
  Begin
    LoadFile(X);
    Cur := 1;
    While A <> 0 Do Begin
      TextAttr:=13;
      GotoXy(41,11);
      Write(Files[x]+' Record #',Cur,' of ',Total);
      Let[1] := Prot[Cur].Letter;
      Create_Fields(4);
      Allow_Beep(False);
      Allow_ESC(True);
      Define_Colors(15,4,14,0,15,1);
      Add_Field(1,4,2,4,2,27,13);
      Add_Field(2,1,3,1,3,33,14);
      Add_Field(3,2,4,2,4,35,15);
      Add_Field(4,3,1,3,1,36,16);
      String_Field(1,Let,'@');
      String_Field(2,Prot[Cur].ProgName,'************');
      String_Field(3,Prot[Cur].Desc,'*******************************');
      String_Field(4,Prot[Cur].CommFmt,'*******************************************');
      A := Process_Input(1);
      Case A Of
        10 : If Cur < Total
              Then Inc(Cur);
        20 : If Cur > 1
              Then Dec(Cur);
        30 : If Total < 15 Then Begin
              Inc(Total);
              FillChar(Prot[Total],SizeOf(Prot[1]),0);
              Cur := Total;
             End;
        40 : If Total > 0 Then Begin
               For A:=Cur to Total Do
                 Prot[A] := Prot[A+1];
               FillChar(Prot[Total],SizeOf(Prot[1]),0);
               Dec(Total);
               Cur := 1;
             End;
        50 : Begin
              WriteFile(x);
              A:=0;
             End;
      End;
      Dispose_Fields;
    End;
  End;

  Procedure Pick;
  Const Bars : Array[1..4] Of String[30]
               = (' Upload Protocols         ',' Download Protocols       ',
                  ' Batch Upload Protocols   ',' Batch Download Protocols ');
  Var X : Byte;
      Finished : Boolean;

    Procedure PlaceBar(Hi:Boolean);
    Begin
      If Hi
        Then TextAttr:=31
        Else TextAttr:=9;
      GotoXy(4,X + 2);
      Write(Bars[X]);
    End;

  Begin
    TextAttr:=1;
    ClrScr;
    DrawScreen;
    X := 1;
    Finished := False;
    PlaceBar(True);
    REPEAT
    CASE GetKey OF
    #128,#200:Begin       {UP}
         PlaceBar(false);
         dec(x);
         IF x<=0 Then x:=4;
         PlaceBar(true);
         End;
    #129,#208:Begin       {DOWN}
         PlaceBar(false);
         inc(x);
         IF x>=5 Then x:=1;
         PlaceBar(true);
         End;
    #133,#13: Begin
          Edit(x);
          DrawScreen;
          PlaceBar(true)
         End;
    #132,#27:Finished:=True;
    End;
    UNTIL Finished;
    TextAttr:=9;
    ClrScr;
    Writeln('ViSiON/2 Protocol Editor v1.0á');
    Writeln('(C) Ruthless Enterprises 1993');
  End;

Begin
  ReadCfg;
  Pick;
End.