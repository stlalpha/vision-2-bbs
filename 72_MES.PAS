{$I- V-}

Program MesFix;

Uses Dos, Crt, GenTypes, ConfigRt, General;

Type BulRec71 = Record
       Title,
       Leftby,
       Sentto,
       Status,
       Realname : Mstr;
       When,
       Line : Longint;
       Anon,
       Recieved,
       V2_Net,
       FidoNet : Boolean;
       Plevel,
       Repnumber : Integer;
       Origin1,
       Origin2 : Lstr;
       Replies : Byte;
       Id : Word
     End;

     BulRec = Record
       Title,
       Leftby,
       Sentto,
       Status,
       Realname : Mstr;
       When,
       Line : Longint;
       Anon,
       Recieved,
       V2_Net,
       FidoNet,
       Scanned : Boolean;
       Plevel,
       Repnumber : Integer;
       Origin1,
       Origin2 : Lstr;
       Replies : Byte;
       Id : Word
     End;

Var
  OldFile : File Of BulREC71;
  NewFile : File Of BulREC;
  AFile   : File of BoardREC;
  Area    : BoardREC;
  Old     : BulREC71;
  New     : BulREC;
  X,Y     : Integer;

  Procedure Convert_Area(Which,Conf : Byte);
  Var F : File;
      X : Byte;
      I : Word;
  Begin
    Writeln('Converting Message Area: ',Area.BoardName);
    If Not Exist(Cfg.BoardDir + Area.ShortName + '.' + Strr(Conf))
      Then Exit;
    Assign(F,Cfg.BoardDir + Area.ShortName + '.'+Strr(Conf));
    Rename(F,Cfg.BoardDir + 'TEMP');
    I := IoResult;
    Close(OldFile);
    Assign(OldFile,Cfg.BoardDir + 'TEMP');
    Reset(OldFile);
    I := IoResult;
    Assign(Newfile,Cfg.BoardDir + Area.ShortName + '.' + Strr(Conf));
    ReWrite(NewFile);
    I := IoREsult;
    For X := 1 to FileSize(OldFile)
    Do Begin
      Seek(OldFile,X-1);
      Read(OldFile,Old);
      FillChar(New,SizeOf(New),0);
      NEW.Title := OLD.Title;
      NEW.Leftby := OLD.LeftBy;
      NEW.Sentto := OLD.SentTo;
      NEW.Status := OLD.Status;
      NEW.Realname := OLD.RealName;
      NEW.When := OLD.When;
      NEW.Line := OLD.Line;
      NEW.Anon := OLD.Anon;
      NEW.Recieved := OLD.Recieved;
      NEW.V2_Net := OLD.V2_NET;
      NEW.FidoNet := OLD.FIDONET;
      NEW.Scanned := TRUE;
      NEW.Plevel := OLD.PLevel;
      NEW.Repnumber := OLD.RepNumber;
      NEW.Origin1 := OLD.Origin1;
      NEW.Origin2 := OLD.Origin2;
      NEW.Replies := OLD.Replies;
      NEW.Id := OLD.ID;
      Write(NewFile,New);
    End;
    Close(NewFile);
    Close(OldFile);
    Erase(OldFile);
    I := IoResult;
  End;

Var I : Word;
Begin
  ClrScr;
  ReadCfg;
  TextAttr := 9;
  Writeln('ViSiON/2 Message HEADER Convertor - (v69-71x to v72A)');
  Writeln('Only Run This Program ONCE!');
  Write('Hit Enter to Continue or Ctrl-Break Now: ');
  Readln;

  X := 1;
  Repeat
    If Exist(Cfg.BoardDir + 'BOARDDIR.'+Strr(X))
    Then Begin
      Assign(AFile,Cfg.BoardDir + 'BOARDDIR.'+Strr(X));
      Reset(AFile);
      For Y := 1 to FileSize(AFile)
      Do Begin
        Seek(AFile,Y-1);
        Read(AFile,Area);
        Convert_Area(Y,X);
      End;
      Close(AFile);
    End;
    Inc(X);
  Until (X > 20);

End.