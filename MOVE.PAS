{$I-}
{$M 4000,0,5000}
program move;

uses crt,dos;

type
    anystr = string[255];
    pathtype  = string[62];
    drivetype = string[2];

var
   fname,dirname,nname,rname  : anystr;
   SourceDrive,DestDrive: pathtype;
   DestName:anystr;
   SourcePath:Anystr;
   F: File;
   DirInfO: SearchRec;
   Count: Integer;

function match (s1,s2:anystr):boolean;
var cnt:integer;
begin
  match:=false;
  if length(s1)<>length(s2) then exit;
  for cnt:=1 to length(s1) do
    if upcase(s1[cnt])<>upcase(s2[cnt])
      then exit;
  match:=true
end;

function currentdrive: drivetype;
var
   w   : drivetype;
   reg : registers;

begin
  reg.ax:=$1900;
  intr($21,reg);
  W := 'A:';
  W[1] := Chr(ord(w[1])+lo(reg.ax));
  CurrentDrive := W
end;

procedure rename(x,y:pathtype);

var
   wx,wy : pathtype;
   reg   : registers;

begin
  TextAttr := 7;

  Wx := X + #0;
  Wy := Y + #0;

  If Wx[2] <> ':'
    Then Wx := CurrentDrive + Wx;

  reg.ax := $5600;
  reg.ds := seg(wx[1]);
  reg.dx := ofs(wx[1]);
  reg.es := seg(wy[1]);
  reg.di := ofs(wy[1]);

  intr($21,reg);

  if (reg.flags and 1) <> 0 then
  begin
    writeln('Path not found.');
    Writeln;
    halt;
  end

end;

function PathPart(s:string):string;
var x: integer;
begin
   PathPart:='';
   for x:= length(s) downto 1 do
      if S[x]='\' then begin
         PathPart:=copy(s,1,x);
         exit;
      end;
end;

Procedure Help;
begin
  TextAttr := 5;
  WRITELN(#13#10 + 'MOVE.EXE (c) Ryec 1992. A fast file move utility. ');
  TextAttr := 14;
  WRITELN(#13#10 + 'Syntax:   Move <fname> [Drive]<\path>');
  TextAttr := 3;
  WRITELN('      Where <fname>  is the file to move,');
  Writeln('            [Drive]  is the optional destination drive,');
  WRITELN('            <\path>  is the destination directory.');
  WRITELN;
  Writeln('      If you leave out the <\path> variable then the program');
  Writeln('      will use the current directory as the destination dir.');
  Writeln(#13#10);
  TextAttr := 7;
  NormVideo;
  Halt(1);
end;

Begin {main}

   Count := 0;
   FName := ParamStr(1);

   If Fname[ length(fname) ] = '\'
     Then FName := FName + '*.*';

   RName := paramstr(2);

   If RName = ''
     Then RName := FExpand( FSearch('.','') );

   If (Length(fname) = 0) or (fname='/?')
   or (fname='?') or Match(FName,RName)
     Then Help;

   If FName = '.'
     Then FName:='*.*';

   If FName[2] = ':'
     Then SourceDrive := Copy(FName,1,2)
     Else SourceDrive := CurrentDrive;

   if RName[2]=':'
     Then DestDrive := Copy(RName,1,2)
     Else DestDrive := CurrentDrive;

   TextAttr := 7;

   If Not Match(SourceDrive,DestDrive) Then Begin

     SourcePath := PathPart(fname);
     FName := FExpand(FName);
     RName := FExpand(RName);

     Exec(getenv('COMSPEC'),'/C COPY '+fname+' '+rname+' >NUL');
     If (DosExitCode<>0) or (DosError<>0) or (IoResult<>0)
       Then Writeln('An error has occured during file copy. Unable to move file(s).')
       Else Begin

         FindFirst(FName,$27,DirInfo);

         While DosError = 0 Do Begin
            Inc(Count);
            Assign(f,fexpand(fsearch(dirinfo.name,Sourcepath)));
            Erase(f);
            FindNext(DirInfo);
         End;

         Writeln('        ',Count,' file(s) moved');
      End;
   End
   Else Begin
     SourcePath:=PathPart(fname);
     FindFirst(fname,$27,dirinfo);

     While (DOSError = 0) Do Begin

       Inc(Count);
       If (RName[ length(rname) ] = '\')
         Then DestName := Rname + dirinfo.name
         Else Destname := RName + '\' + dirinfo.name;
       Rename(fexpand(fsearch(dirinfo.name,SourcePath)),destname);
       FindNext(dirinfo);

     End;
     Writeln('        ',Count,' file(s) moved');
   End;

   NormVideo;
   Writeln;
end.
