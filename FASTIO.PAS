{

   Enclosed is a unit I wrote which does random i/o on a TP text file.  It can
be used to help understand that whole process, although it is tailored to a
fixed-length record file.  It would be a fairly simple matter to modify it to
"parse" variable-length text file records - a la stream i/o.

}

unit FASTIO;                 { Fast Sequential I/O routines 920122 }
interface

uses DOS;
type  BLKTYP = array[1..65521] of char;

var   NR,BCT       : Word;                { # Records, Block Count }
      FRPB,C       : Word;                  { Max. Blocking Factor }
      CBRC         : Word;            { Current Block Record Count }
      NREC,CREC,FS : LongInt; { # Records, Current Record #, FileSize }
      RS,RST       : Byte;                { RecSize, Total RecSize }
      RSC          : char;                     { RecSize character }
      FASTEOF      : boolean;              { EOF flag for Fast I/O }
      FN           : string[60];                        { Filename }
      S            : string;
      FW           : file;
      B            : ^BLKTYP;                     { buffer for i/o }

procedure FAST_INIT;               { Initialize Fast Text file I/O }
procedure FAST_WINDUP;                { Windup Fast I/O Processing }
procedure REWIND;                       { Restart File @ beginning }

function UNBLOCK : string;          { Unblock a record from buffer }

implementation

procedure FAST_IO;              { read a block of file & check EOF }
begin
  BlockRead (FW,B^,FRPB,NR); Inc (BCT);
  C := 1; CBRC := 0;                             { read next block }
end;  { FAST_IO }

procedure REWIND;                       { Restart File @ beginning }
begin
  Seek (FW,0); C := 1; CREC := 0; BCT := 0; CBRC := 0; NR := 0;
  FASTEOF := false
end;  { REWIND }

procedure FAST_INIT;            { Initialize Fast RP Text file I/O }
var F : Text;
begin
  FN := 'INPUT.DAT';                             { assign filename }
  Assign (F,FN);
  Reset (F);
  readln (F,S);
  Close (F);                       { compute RecSize }
  RS := Length(S);
  RST := RS+2;
  RSC := Chr(RS);
  FRPB := 65521 div RST;
  Assign (FW,FN);
  Reset (FW,1);
  FS := FileSize (FW);
  Close (FW);
  NREC := FS div RST;                             { # file records }
  S[0] := RSC;             { set up string length & starting point }
  Assign(FW,FN);
  Reset(FW,RST);
  New(B);           { open data file }
  REWIND;
  FAST_IO;                                { read 1st block }
end;  { FAST_INIT }

function UNBLOCK : string;          { Unblock a record from buffer }
begin
  if CBRC < NR then
    begin
      Move (B^[C],S[1],RS);
      Inc (CREC);
      Inc (C,RST);
      Inc (CBRC)
    end;
  if CBRC >= NR then                               { end of block }
    begin
      FAST_IO;
      FASTEOF := EOF (FW)
    end;
  UNBLOCK := S
end;  { UNBLOCK }

procedure FAST_WINDUP;               { Windup Fast I/O Processing }
begin
  Close (FW); Dispose (B);
end;  { FAST_WINDUP }

begin
  CREC := 0; BCT := 0; FASTEOF := false;   { unit initializations }
end.