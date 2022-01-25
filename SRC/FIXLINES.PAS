{$I-}
{$M 65520,0,0}

Program FixLines;

Uses Dos,Crt,MDosIO;

Type Mstr = String[30];

Var Name : NameStr;
    WorkFile : String;
    Return : Byte;

  Function Strr (N : Integer) : Mstr;
  Var Q : Mstr;
  Begin
    Str (N,Q);
    Strr := Q
  End;

  Procedure AssignName;
  Var Temp : ExtStr;
      Temp1: String;
  Begin

   FSplit(WorkFile,Temp1,Name,Temp);
   Name := Temp1 + Name;

  End;

  Function RenameFile : Boolean;
  Var F : File;
  Begin
    RenameFile := True;
    Exit; {Temp}
  End;
(*
    AssignName;

    If Not Dos_Exists(WorkFile)
      Then Begin
        TextAttr := 14;
        Writeln;
        Writeln('File ',WorkFile,' is not found!');
        Writeln;
        RenameFile := False;
        Exit;
      End;

    If Dos_Exists(Name + '.BAK')
      Then Begin
        Assign(F,Name + '.BAK');
        Erase(F);
      End;

    Assign(F,WorkFile);
    Rename(F, Name + '.BAK');

    RenameFile := True;
  End;
  *)

  Procedure TruncateTextFile;
  Var T : Text;
      X,Where,MaxLines : Byte;
      B : Array[1..200] of String;
      Total : Word;
      K : Char;
      Find : String[7];
      Blank : String[4];

      Procedure GetMaxLines;
      Var Temp  : String;
          Error : Word;
      Begin
        TextAttr := 3;
        Write('Total Lines in (');
        Textattr := 11;
        Write(WorkFile);
        TextAttr := 3;
        Write(') : ');
        TextAttr := 14;
        Writeln(MaxLines);
        TextAttr := 3;
        Write('Enter Line # to Stop File at (0 to Abort) (');
        TextAttr := 11;
        Write('Cr');
        TextAttr := 8;
        Write('/');
        TextAttr := 11;
        Write(MaxLines);
        TextAttr := 3;
        Write(') : ');
        TextAttr := 5;
        Readln(Temp);
        If Temp = ''
          Then Temp := Strr(MaxLines);
        Val(Temp,MaxLines,Error);
        If Error <> 0
          Then MaxLines := 0;
      End;

  Begin

    Find := #27 + '[255D';
    Blank := #27 + '[0m';

    FillChar(B,SizeOf(B),0);

    Assign(T,WorkFile);
    Reset(T);

    X := 1;
    Total := 0;

    While (Not Eof(T)) and (X < 201) Do Begin
      Readln(T,B[X]);
      Inc(X);
      Inc(Total);
    End;

    MaxLines := 0;

    While (MaxLines = 0) And (X > 0)
    Do Begin
      If (B[x] = '') Or (B[x] = Blank + Find)
        Then Dec(X)
        Else MaxLines := X;
    End;

    GetMaxLines;

    If MaxLines = 0 Then Begin
      Textattr := 4;
      Writeln('Function Aborted!');
      Exit;
    End;

    Total := MaxLines;

    For X := 1 to Total Do Begin
      Where := Pos(Find,B[x]);
      If Where > 0
        Then Delete(B[x],Where,6);
    End;

    Rewrite(T);

    For Total := 1 to Total
      Do Writeln(T,B[Total]);

    Close(T);
  End;

  Procedure GetInput;
  Begin
  Repeat
    TextAttr := 9;
    Writeln;
    Writeln('Enter Work File(s) - Wildcards are okay.. - [Q]uits'#13#10);
    TextAttr := 13;
    Write('Filename(s) ');
    TextAttr := 5;
    Write(': ');
    TextAttr := 15;
    Readln(WorkFile);
    Writeln;
    If WorkFile = ''
      Then Begin
        Textattr := 14;
        Writeln('Enter Something!');
      End;
  Until WorkFile <> '';
  End;

  Procedure Do_It;
  Var Index : SearchRec;
      Str : String;
      WildCard, Ok : Boolean;
      K : Char;

  Begin
    Repeat

      GetInput;

      If (WorkFile = 'Q') Or (WorkFile = 'q')
        Then Exit;

      Str := WorkFile;

      WildCard := (Pos('*',WorkFile) > 0) Or (Pos('?',WorkFile) > 0);

      FindFirst(Str,Anyfile,Index);

      If DosError <> 0
        Then Begin
          Writeln('No match found!');
          Exit;
        End;

      While DosError = 0
      Do Begin

        If WildCard Then Begin
          TextAttr := 10;
          Write('Match Found (');
          TextAttr := 15;
          Write(Index.Name);
          TextAttr := 10;
          Write(') Process? ');
          K := Upcase(ReadKey);
          TextAttr := 14;
          Writeln(K);
        End
          Else K := 'Y';

        If K <> 'N' Then Begin
          WorkFile := Index.Name;
          Ok := RenameFile;
          If Ok
            Then TruncateTextFile;
        End;

        FindNext(Index);
      End

      Until True = False;
  End;

  Procedure CB_Write(S : String);
  Begin
    TextAttr := 3;
    Write('þ ');
    TextAttr := 15;
    Writeln(S);
  End;

Var Ok : Boolean;
    X : Byte;
Begin
  ClrScr;

  TextAttr := 8;
  For X := 1 to 79
    Do Write(#196);

  TextAttr := 15;
  Writeln(#13#10'  ANSI File Utility (c) Ruthless Enterprises 1993; Written By Crimson Blade');
  TextAttr := 7;
  Writeln('                        1. Nukes unwanted extra lines');
  Writeln('                        2. Removes unwanted ANSI Codes');

  TextAttr := 8;
  For X := 1 to 79
    Do Write(#196);

  Window(1,6,80,25);

  Repeat
    Do_It;
  Until (WorkFile = 'Q') or (Workfile = 'q');

  Window(1,1,80,25);
  ClrScr;

  CB_Write('ANSi Fixer for ViSiON/2 Config Listings');
  CB_Write('(C) Copyright Ruthless Enterprises 1993');
  CB_Write('Written By Crimson Blade');
  CB_Write('For use by people to lazy to do this via a text editor!');

  Writeln;
End.