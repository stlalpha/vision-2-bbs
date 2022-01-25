{$I-,V-,R-,S-}
{$M $AAAA,0,0}

Program Import;

Uses Dos, Crt, GenTypes, ConfigRt, General;

Var AF    : File of UDREC;
    UD    : UDREC;
    INF   : File of UDIndexREC;
    Index : UDIndexREC;
    TF    : Text;
    I     : Integer;
    S     : String;

    Procedure AddFile;
    Begin
      UD.IndexPTR := FileSize(INF);
      Seek(AF,FileSize(AF));
      Write(AF,UD);
      I := IoResult;
      If I <> 0 Then Writeln('IO ERROR! Writing to NEWAREA.DAT');
      Seek(INF,FileSize(INF));
      Write(INF,Index);
      I := IoResult;
      If I <> 0 Then Writeln('IO ERROR! Writing to AREAINDX.1')
    End;

    Function GetFileName : SStr;
    Var X : Byte; Temp : Sstr;
    Begin
      Temp[0] := #0;
      X := 1;
      While (S[1] = #32) And (S[0] > #0)
        Do Delete(S,1,1);
      While (S[x] <> #32) And (S[0] > #0)
        Do Begin
          Temp := Temp + S[x];
          Inc(X);
        End;
      GetFileName := Temp;
      Delete(S,1,X);
    End;

    Function Size : Longint;
    Var F : File;
    Begin
      Assign(F,UD.Path + UD.FileName);
      Reset(F,1);
      If IOResult = 0
        Then Size := FileSize(F)
        Else Size := -1;
      Close(F);
    End;

    Function GetDescrip : Lstr;
    Var X : Byte;
    Begin
      X := 1;
      GetDescrip := '';
      While (S[1] = #32) And (Length(S) > 0)
        Do Delete(S,1,1);
      While (Length(S) > 48) And (Pos(#32,S) > 0)
        Do Delete(S,1,Pos(#32,S) + 1);
      GetDescrip := S;
    End;

BEGIN
  ReadCFG;
  If Paramcount < 1
    Then Begin
      Writeln('You must supply me with the FILES.TXT to import!');
      Halt;
    End;
  Assign(TF,ParamStr(1));
  Reset(TF);
  I := IOResult;
  If I <> 0 Then Begin
    Close(TF);
    Writeln('Error Opening '+ParamStr(1));
    Halt;
  End;
  Assign(AF,Cfg.DataDir + 'NEWAREA.DAT');
  Rewrite(AF);
  I := IORESULT;
  Assign(INF,Cfg.DataDir + 'AREAINDX.1');
  Reset(INF);
  I := IORESULT;
  While Not Eof(TF)
    Do Begin
      FillChar(Index,Sizeof(Index),0);
      FillChar(UD,Sizeof(UD),0);
      Readln(TF,S);
      UD.FileName := GetFileName;
      UD.Path     := 'C:\PASCAL\';
      If EXIST(UD.Path + UD.FileNAME)
        THEN BEGIN
          Writeln('Adding '+UD.FileName);
          UD.When            := Now;
          UD.WhenRated       := Now;
          UD.FileSize        := Size;
          Index.Descrip[1]   := GetDescrip;
          Index.SentBy       := Cfg.SysOpName;
          Index.Points       := 1;
          Index.Return       := False;
          AddFile;
        END
    End;
  Close(TF);
  Close(INF);
  Close(AF);
END.

