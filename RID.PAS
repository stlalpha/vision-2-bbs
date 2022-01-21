Program Rid;

Uses Dos;

Var F : File;
    S : SearchRec;

Begin
  FindFirst('AREA*.*',$17,S);
  While DosError = 0
    Do Begin
       Assign(F,S.Name);
       Reset(F,1);
       If FileSize(F) < 1 Then Begin
         Close(F);
         Erase(F);
       End
       Else Close(F);
       Findnext(S);
    End;
End.