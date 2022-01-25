{$R-,S-,I-,D-,F-,V-,B-,N-,L+ }

Unit TextRet;

Interface

Uses GenTypes;

Procedure ReloadText (Sector : LongInt; VAR Q : Message);
Procedure DeleteText (Sector : LongInt);
Function MakeText (VAR Q : Message; OverRide : Lstr) : LongInt;
Function CopyText (Sector : LongInt) : LongInt;
Procedure PrintText (Sector : LongInt);

Var CurTextFile,
    CurMailFile,
    LastTextFile,
    LastMailFile : Lstr;

Implementation

Uses Dos, MNet, ConfigRt, GenSubs, Subs1;

Type MailPtrRec = Record
       TextPtr : Longint;
       BytesLong : Longint;
       Deleted : Boolean;
       TotalLines : Integer;
       LineLength : Array[1..999] Of Byte;
     End;

Var TextFile : File;
    MailFile : File Of MailPtrRec;
    Mail     : MailPtrRec;

Procedure AssignName;
Begin
  If (CurTextFile <> LastTextFile) Or (CurMailFile <> LastMailFile)
  Then Begin
    Assign(TextFile,CurTextFile);
    If Not Exist(CurTextFile)
      Then Rewrite(TextFile,256)
      Else Reset(TextFile,256);
    Assign(MailFile,CurMailFile);
    If Not Exist(CurMailFile)
      Then Rewrite(MailFile)
      Else Reset(MailFile);
  End;
  LastTextFile := CurTextFile;
  LastMailFile := CurMailFile;
End;

Function MakeText (Var Q : Message; OverRide : Lstr) : Longint;
Var Size : Longint;
    X,Line : Byte;
    Temp : Word;
Begin

  AssignName;

  MakeText := -1;

  FillChar(Mail,SizeOf(Mail),0);

  Size := FileSize(TextFile);
  Mail.TextPtr := Size;

  Seek(TextFile,Size);

  Size := 0;
  For X := 1 To Q.NumLines Do Begin
    Line := Length(Q.Text[X]);
    Mail.LineLength[X] := Line;
    Inc(Size,Line);
    BlockWrite(TextFile,Q.Text[X],1,Temp);
  End;

  Mail.BytesLong := Size;
  Mail.TotalLines := Q.NumLines;

  Size := FileSize(MailFile);
  Seek(MailFile,Size);
  NWrite(MailFile,Mail);

  MakeText := Size;
End;

Procedure ReloadText (Sector : LongInt; VAR Q : Message);
Var X,Loop : Byte;
    Temp : Word;
Begin
  AssignName;

  FillChar(Q,SizeOf(Q),0);

  If Sector > FileSize(MailFile)
    Then Exit;

  Seek(MailFile,Sector);
  NRead(MailFile,Mail);

  If Mail.TextPtr > FileSize(TextFile)
    Then Exit;

  Loop := Mail.TotalLines;
  If Loop > 200
    Then Loop := 200;

  Seek(TextFile,Mail.TextPtr);

  For X := 1 to Loop Do
    BlockRead(TextFile,Q.Text[X],1,Temp);

  Q.NumLines := Loop;

End;

Procedure PrintText (Sector : LongInt);
Var X : Integer;
    S : String;
    Temp : Word;
Begin

  AssignName;

  If Sector > FileSize(MailFile)
    Then Begin
      Writeln(^M^S'Mail Error! (Message pointer out of range)'^M);
      Exit;
    End;

  Seek(MailFile,Sector);
  NRead(MailFile,Mail);

  If Mail.TextPtr > FileSize(TextFile)
    Then Begin
      Writeln(^M^S'Mail Error! (Text pointer out of range)'^M);
      Exit;
    End;

  Seek(TextFile,Mail.TextPtr);

  For X := 1 to Mail.TotalLines Do Begin
    S[0] := Chr(Mail.LineLength[X]);
    BlockRead(TextFile,S,1,Temp);
    MultiColor(S);
    Writeln;
  End;

  Writeln;

End;

Function CopyText (Sector : LongInt) : LongInt;
Begin
End;

Procedure DeleteText (Sector : LongInt);
Begin
End;

Begin
End.