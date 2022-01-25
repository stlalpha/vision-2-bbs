{$R-,S-,I-,D-,F+,V-,B-,N-,L+}
{$M 65520,0,65520}

Program Alot;

Uses Dos, Gentypes, General;

Var X : Byte;
    AFile : File Of AreaRec;
    A : AreaRec;

Begin
  Assign(AFile,'AREADIR.1');
  If Exist('AREADIR.1')
    Then Reset(AFile)
    Else Rewrite(AFile);
  Seek(Afile,FileSize(AFile));
  For X := 1 to 20 Do
    Begin
      FillChar(A,SizeOf(A),0);
      A.Name := 'Area # '+Strr(X);
      A.XmodemDir := 'C:\';
      A.Sponsor := 'Crimson Blade';
      A.Level := 10;
      A.Leech := False;
      A.Password := '';
      A.Flag := '';
      A.UpFlag := '';
      A.DownFlag := '';
      A.Uploads := True;
      A.Downloads := True;
      A.TotalUDs := 0;
      Write(AFile,A);
    End;
End.
