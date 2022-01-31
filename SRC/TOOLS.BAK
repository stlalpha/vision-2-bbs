{$I PRODEF.INC}
{$D+,L+}

Unit Tools;

Interface

Uses Dos, MDosIO;

const
   namesizes = 50;      {size of filenames}

type
   filenames  = string[namesizes];  (* General String Declarations *)
   anystring  = string[128];
   longstring = string[255];

   string2   = string[2];
   string4   = string[4];
   string5   = string[5];
   string8   = string[8];
   string10  = string[10];
   string12  = string[12];
   string13  = string[13];
   string20  = string[20];
   string25  = string[25];
   string30  = string[30];
   string40  = string[40];
   string65  = string[65];
   string72  = string[72];
   string80  = string[80];
   string160 = string[160];
   string240 = string[240];
   string255 = string[255];

   char2  = array[1..2] of char;
   char3  = array[1..3] of char;
   char4  = array[1..4] of char;
   char5  = array[1..5] of char;
   char6  = array[1..6] of char;
   char7  = array[1..7] of char;
   char8  = array[1..8] of char;
   char9  = array[1..9] of char;
   char10 = array[1..10] of char;
   char11 = array[1..11] of char;
   char12 = array[1..12] of char;
   char13 = array[1..13] of char;
   char14 = array[1..14] of char;
   char15 = array[1..15] of char;
   char16 = array[1..16] of char;
   char19 = array[1..19] of char;
   char24 = array[1..24] of char;
   char25 = array[1..25] of char;
   char30 = array[1..30] of char;
   char39 = array[1..39] of char;
   char40 = array[1..40] of char;
   char32 = array[1..32] of char;
   char35 = array[1..35] of char;
   char45 = array[1..45] of char;
   char128 = array[1..128] of char;

Procedure determine_tasker;     {determine what multi-tasker is active, if any}
Procedure give_up_time;         {give up unused time under doubledos}
Const
   Tasker : (taskview,                  {taskview/omniview/topview/desqview}
             doubledos,                 {doubledos}
             notasker,                  {single task}
             unknown) = unknown;        {before first call}

Function ftoa(f: real; width,
              dec: integer): string20;     (* float to ascii conversion *)
Function atof (asc : anystring) : real;    (* ascii to float conversion *)
Function atoi (asc : anystring) : integer; (* ascii to integer conversions *)
Function atol (asc : anystring) : longint; (* ascii to long integer *)
Function atow (asc : anystring) : word;    (* ascii to word *)

Function itoa (int: integer): string8;     (* integer to ascii conversion *)
Function ltoa (int: longint): string8;     (* longint to ascii *)
Function wtoa (w: word): string8;          (* word to ascii *)

Type
  Single = Array[0..3] of byte;

function stof(B: single): real;            (* convert 4 byte single to real *)
procedure ftos(PasReal: real;
               var B: single);             (* convert real to 4 byte single *)
function stol(s: single): longint;         (* basic single to longint *)
procedure incs(var s: single; n: real);    (* increment basic single *)
procedure ltos(l: longint; var B: single); (* longint to basic single *)
procedure zeros(var B: single);

Type
  Double = Array[0..7] of byte;

function dtof(B: double): real;            (* convert 8 byte double to real *)
function dtol(B: double): longint;         (* convert 8 byte double to longint *)
procedure ftod(PasReal: real;
          var B: double);                  (* convert real to 8 byte double *)
procedure incd(var d: double; n: real);    (* increment basic double *)

function stoa(s: single): string10;        (* basic single to ascii *)
function dtoa(d: double): string10;        (* basic double to ascii *)

function itoh(i: longint): string8;        (* integer to hex conversion *)
function i_to_ur(i: integer): real;        (* integer to unsigned-real conversion *)
function ur_to_i(v: real): integer;        (* unsigned-real to integer conversion *)

Type
   Long_int = Record
     Case integer of
       1 : (b: array[1..4] of byte);
       2 : (lsw: integer;
            msw: integer);
   End;

function ltor(long: long_int): real;       (* longint to real conversion *)
procedure rtol(r: real;
               var long: long_int);        (* real to longint *)

function remove_path(name: filenames): filenames;  (* remove path *)
function path_only(name: filenames): filenames;    (* return path *)
function name_only(name: filenames): filenames;    (* return filename *)
function remove_ext(name: filenames): filenames;   (* remove extension *)
function ext_only(name: filenames): filenames;     (* return extension *)
procedure cons_path(var path: filenames;
                    dir,name: filenames);
procedure cons_name(var resu:          filenames;
                    name1,name2,ext:   filenames);
function is_wild(filename: anystring): boolean;    (* is filename a wildcard? *)

procedure stoupper(var st: string);  (* map string to upper case *)
procedure stolower(var st: string);  (* map string to lower case *)
procedure capstr(var s: string);     (* make string into 'Caps Format' *)
function file_size(name: string65): longint;  (* get size of a file *)
function wildcard_match (var pattern,
                         line:string65): boolean;

function strval (i: integer): string2;  (* return time/date values *)
function system_dd: string2;
function system_mm: string2;
function system_yy: string2;
function system_date: string8;  (* format: mm-dd-yy *)
function system_time: string8;  (* format: hh:mm *)
function get_time: real;
function lget_time: longint;
function lget_ms: longint;
function get_mins: integer;

procedure delay(ms: longint);
   (* delay a specified number of miliseconds; give up time while delaying *)

procedure delete_spaces(var line: string);  (* string manipulation *)
procedure delete_trailing_spaces(var line: string);
procedure delete_leading_spaces(var line: string);
procedure replace_string( var line: longstring; oldstr, newstr: string65);

function get_environment_var(id: string20): anystring;
function environment_on(id: string20): boolean;

Type
   varstring = ^longstring;

procedure releasestr( var str:  varstring);
   (* release the memory used by a varstring variable.  variable MUST
      be pre-allocated or the program may crash!!! *)

procedure savestr( var tostr: varstring;
                   from:      longstring);
   (* save a regular string in a varstring; new allocation of varstring *)

Const
   maxnumfiles =  200;
   null =         #0;

Type
   filearray =    array [1.. maxnumfiles] of varstring;

Var
   filetable:     filearray;
   filecount:     integer;

Procedure getfiles (pattern:       string65;
                    var fdir:      filearray;
                    var num:       integer);  (* expand wildcard file lists *)

function ljust(s: string80; w: integer): string80; (* left justify strings *)
function rjust(s: string80; w: integer): string80; (* right justify strings *)

const
   maxbit = 40;
type
   bitnumber = 0..39;
   bitmap = record
      bits:  array[0..4] of byte;       {bits 0..39}
   end;

function getbit(map: bitmap; bitnum: bitnumber): boolean;
   {return true/false for specified bit in a bitmap}
procedure setbit(var map: bitmap; bitnum: bitnumber; value: boolean);
   {set the specified bit in a bitmap}

function getflag(flag: byte; bitval: byte): boolean;
   {return true/false for specified is set}
procedure setflag(var flag: byte; bitval: byte; value: boolean);
   {set the specified bit in a flagbyte}
function toggleflag(var flag: byte; bitval: byte): boolean;
   {toggle the specified bit and return new setting}

procedure vappends(var line: varstring; s: anystring);

function disk_space(disk: char): word;  (* get disk free space; allows >32meg *)

procedure qWrite(x,y: integer; s: string);

Implementation

Uses MiniCRT, OpenShare;

procedure determine_tasker;
   {determine what multi-tasker is active, if any}
var
   reg:  registers;

begin
   reg.bx := 0;
   reg.ax := $1022;     {get topview/taskview version}
   intr($15,reg);
   tasker := taskview;
   if reg.bx <> 0 then
   begin
      directVideo := false;
      exit;
   end;

   reg.ax := $e400;     {return current program status, doubledos}
   msdos(reg);
   tasker := doubledos;
   if (reg.al = 1) or (reg.al = 2) then
      exit;

   {cannot detect a multi-tasker, disable give-up-time calls}
   tasker := notasker;
end;

(* ------------------------------------------------------------ *)

procedure give_up_time;
   {give up unused time under doubledos}
var
   reg:  registers;

begin

   {determine what multi-tasker is active, if any}
   if tasker = unknown then
      determine_tasker;
   
   {give up time with taskview/omniview/topview}
   if tasker = taskview then
   begin
      reg.ax := $1000;          {give up remainder of timeslice}
      intr($15,reg);
   end
   else

   {give up time with doubledos}
   if tasker = doubledos then
   begin
      reg.ax := $0001;           {give up 1 clock tick/slice}
      intr($fe,reg);
   end
end;

function ftoa(f: real; width,dec: integer): string20;
var
   buf: string20;
begin
   str(f:width:dec,buf);
   ftoa := buf;
end;

function atof (asc:anystring): real;
var
   code : integer;
   value : real;
begin
   while copy(asc,1,1) = ' ' do
      delete(asc,1,1);
   val(asc, value, code);
   atof := value;
end;

function atol (asc:anystring): longint;
var
   i : integer;
   value : longint;
   num : anystring;

begin
   num := '';
   for i := 1 to length(asc) do
      if (asc[i] >= '0') and (asc[i] <= '9') then
         num := num + asc[i];

   if length(num) = 0 then
      value := 0
   else
      val(num, value, i);

   atol := value;
end;

function atoi (asc:anystring): integer;
begin
   atoi := integer(atol(asc));
end;

function atow (asc:anystring): word;
begin
   atow := word(atol(asc) and $FFFF);
end;

function itoa (int: integer): string8;
var
   tstr: string8;
begin
   str(int, tstr);
   itoa := tstr;
end;

function ltoa (int: longint): string8;
var
   tstr: string8;
begin
   str(int, tstr);
   ltoa := tstr;
end;

function wtoa (w: word): string8;
var
   tstr: string8;
begin
   str(w, tstr);
   wtoa := tstr;
end;

function stof(B: single): real;
   {convert 4 byte single to real}
var
   PasReal:  real;
   R: array [0..5] of byte absolute PasReal;
begin
   R[0] := B[3];
   R[1] := 0;
   R[2] := 0;
   move(B[0],R[3],3);
   stof := PasReal;
end;

procedure ftos(PasReal: real; var B: single);
   {convert real to 4 byte single}
var
   R: array [0..5] of byte absolute PasReal;
begin
   B[3] := R[0];
   move(R[3],B[0],3);
end;

function stol(s: single): longint;
var
   f: real;
begin
   f := int(stof(s));
   if (f < -$7FFFFFFE) or (f > $7FFFFFFF) then
   begin
      {writeln(' f=',f:0:10);}
      f := 0;
   end;

   stol := trunc( f );
end;

procedure ltos(l: longint; var B: single);
begin
   ftos(l,B);
end;

procedure incs(var s: single; n: real);
begin
   ftos( trunc(stof(s)) + n, s );
end;

procedure zeros(var B: single);
begin
   ltos(0, B);
end;

function stoa(s: single): string10;
begin
   stoa := ftoa( stof(s), 0,0 );
end;

function dtoa(d: double): string10;
begin
   dtoa := ftoa( dtof(d), 0,0 );
end;

function dtof(B: double): real;
   {convert 8 byte double to real}
var
   PasReal:  real;
   R:        array [0..5] of byte absolute PasReal;
begin
   PasReal := 0;
   move(B[2],R[1],5);
   R[0] := B[7];
   dtof := PasReal;
end;

function dtol(B: double): longint;
   {convert 8 byte double to long integer}
begin
   dtol := trunc(dtof(B));
end;

procedure ftod(PasReal: real; var B: double);
   {convert real to 8 byte double}
var
   R: array [0..5] of byte absolute PasReal;
begin
   fillchar(B[0],8,0);
   B[7] := R[0];
   move(R[1],B[2],5);
end;

procedure incd(var d: double; n: real);
begin
   ftod( int(dtof(d)) + n, d );
end;

function itoh(i: longint): string8;   {integer to hex conversion}
var
   h:   string8;
   w:   word;

   procedure digit(ix: integer; ii: word);
   begin
      ii := ii and 15;
      if ii > 9 then 
         ii := ii + 7;
      h[ix] := chr(ii + ord('0'));
   end;

begin
   w := i and $FFFF;
   h[0] := chr(4);
   digit(1,w shr 12);
   digit(2,w shr 8);
   digit(3,w shr 4);
   digit(4,w);
   itoh := h;   
end;

function i_to_ur(i: integer): real;  {integer to unsigned-real conversion}
var
   u: word absolute i;
begin
   i_to_ur := u;
end;

function ur_to_i(v: real): integer;  {unsigned-real to integer conversion}
var
   i: integer;
   u: word absolute i;
begin
   u := trunc(v) and $FFFF;
   ur_to_i := i;
end;

function ltor(long: long_int): real;
var
   l: longint absolute long;
begin
   ltor := l;
end;

procedure rtol(r: real;
               var long: long_int);
var
   l: longint absolute long;
begin
   l := trunc(r);
end;

function remove_path(name: filenames): filenames;

{$IFDEF TP40}

var
   n: filenames;
   i: integer;

begin
   if (length(name) > 2) then
   begin
      if (name[2] <> ':') then
      begin
         remove_path := name;
         exit;
      end
      else
      if name[1] > '@' then
         delete(name,1,2);
   end;

   n := '';
   for i := 1 to length(name) do
      if name[i] = '\' then
         n := ''
      else
      begin
         inc(n[0]);
         n[length(n)] := name[i];
      end;

   remove_path := n;
end;

{$ELSE}

var
   d,n,e:   filenames;
begin
   if ((length(name) > 2) and (name[2] <> ':') and (name[1] <> '\')) or (name[1] < 'A') then
      remove_path := name
   else
   begin
      FSplit(name,d,n,e);
      remove_path := n + e;
   end;
end;

{$ENDIF}


(*
 * path_only - return pathname prefix from a filename
 *             (does NOT include trailing \!)
 *)

function path_only(name: filenames): filenames;

{$IFDEF TP40}

var
   n: filenames;
   i: integer;

begin

   {scan backwards looking for the last : or \ in the pathname}
   n := name;
   i := length(n);
   while (i > 0) and (name[i] <> ':') and (name[i] <> '\') do
      dec(i);

   n[0] := chr(i);

   {add a trailing "\" if needed}
   if (length(n) > 2) and (n[length(n)] <> '\') then
   begin
      inc(n[0]);
      n[length(n)] := '\';
   end;

   path_only := n;
end;

{$ELSE}  {TP 5.0}

var
   d,n,e:   filenames;

begin
   FSplit(name,d,n,e);
   if d[length(d)] = '\' then
      dec(d[0]);
   path_only := d;
end;

{$ENDIF}


(*
 * name_only - return name prefix from a filename (without path or .ext)
 *)

function name_only(name: filenames): filenames;
var
   d,n,e:  filenames;
begin
   FSplit(name,d,n,e);
   name_only := n;
end;


(*
 * remove_ext - remove filename .ext
 *
 *)

function remove_ext(name: filenames): filenames;
var
   n: filenames;
   i: integer;
begin
   n := name;
   i := length(n);
   while (i > 0) and (name[i] <> '.') do
      dec(i);

   if name[i] = '.' then
      n[0] := chr(i-1);

   remove_ext := n;
end;


(*
 * ext_only - return only the ext portion of a filename
 *
 *)

function ext_only(name: filenames): filenames;

{$IFDEF TP40}
var
   i: integer;
begin
   i := length(name);
   while (i > 0) and (name[i] <> '.') do
      dec(i);

   if name[i] = '.' then
      ext_only := copy(name,i,99)
   else
      ext_only := '';
end;

{$ELSE}  {TP 5.0}

var
   d,n,e: filenames;
begin
   FSplit(name,d,n,e);
   ext_only := e;
end;

{$ENDIF}


(*
 * cons_path - construct a pathname from a directory and a filename
 *
 *)
procedure cons_path(var path: filenames;
                    dir,name: filenames);
begin
   if dir[length(dir)] <> '\' then
   begin
      inc(dir[0]);
      dir[length(dir)] := '\';
   end;

   path := dir + name;
   stoupper(path);
end;


(*
 * cons_name - construct a filename from three parts
 *
 *)
procedure cons_name(var resu:          filenames;
                    name1,name2,ext:   filenames);
begin
   resu := name1 + name2 + ext;
   stoupper(resu);
end;

function is_wild(filename: anystring): boolean;
var
   i: integer;
begin

   for i := 1 to length(filename) do
      case filename[i] of
         '?','*':
            begin
               is_wild := true;
               exit;
            end;
      end;

   is_wild := false;
end;

{$F+} procedure stoupper(var st: string); {$F-}
begin

   Inline(
     $C4/$7E/$06/           {   les di,[bp]6         ;es:di -> st[0]}
     $26/                   {   es:}
     $8A/$0D/               {   mov cl,[di]          ;cl = length}
     $FE/$C1/               {   inc cl}

                            {next:}
     $47/                   {   inc di}
     $FE/$C9/               {   dec cl}
     $74/$12/               {   jz ends}

     $26/                   {   es:}
     $8A/$05/               {   mov al,[di]}
     $3C/$61/               {   cmp al,'a'}
     $72/$F4/               {   jb next}
     $3C/$7A/               {   cmp al,'z'}
     $77/$F0/               {   ja next}

     $2C/$20/               {   sub al,' '}
     $26/                   {   es:}
     $88/$05/               {   mov [di],al}
     $EB/$E9);              {   jmp next}

                            {ends:}
end;

{$F+} procedure stolower(var st: string); {$F-}
begin

   Inline(
     $C4/$7E/$06/           {   les di,[bp]6         ;es:di -> st[0]}
     $26/                   {   es:}
     $8A/$0D/               {   mov cl,[di]          ;cl = length}
     $FE/$C1/               {   inc cl}

                            {next:}
     $47/                   {   inc di}
     $FE/$C9/               {   dec cl}
     $74/$12/               {   jz ends}

     $26/                   {   es:}
     $8A/$05/               {   mov al,[di]}
     $3C/$41/               {   cmp al,'A'}
     $72/$F4/               {   jb next}
     $3C/$5A/               {   cmp al,'Z'}
     $77/$F0/               {   ja next}

     $04/$20/               {   add al,' '}
     $26/                   {   es:}
     $88/$05/               {   mov [di],al}
     $EB/$E9);              {   jmp next}

                            {ends:}
end;

procedure capstr(var s: string);
var
   i:    integer;
   sp:   boolean;
begin
   sp := true;
   stolower(s);
   for i := 1 to length(s) do
   begin
      if sp then
         s[i] := upcase(s[i]);
      sp := s[i] = ' ';
   end;
end;

function file_size(name: string65): longint;
var
   DirInfo: SearchRec;

begin
   FindFirst(name,$21,DirInfo);
   if (DosError <> 0) then
      file_size := 0
   else
      file_size := DirInfo.size;
end;

(*
 * pattern match function - matches a unix-style filename pattern.
 *      this recursive definition will accept *key* forms.
 *
 * S.H.Smith, rev. 04-Oct-87 (rev. 12-01-88)
 *
 *)

(* these static variables are part of a hack to speed up the recursive
   pattern matching operation.  *)

var
   PAT_pattern:        string13;
   PAT_pc:             integer;
   PAT_line:           string13;
   PAT_lc:             integer;


(* matching engine - uses pointers into static pattern and line strings *)

function PAT_match (patpos,
                    linpos:             integer): boolean;
const
   QUESTION =          63;    {ord('?')}
   STAR =              42;    {ord('*')}
   ENDSTR =            32;    {ord(' ')}
   
label 
   continue;

begin
   PAT_match := false;

(* do a "wildcard" filename scan *)
   
   repeat
continue :
      PAT_pc := ord (PAT_pattern [patpos]);  {get next pattern character}
      PAT_lc := ord (PAT_line [linpos]);     {get next line character}

(* end of pattern?  we might have a match if so *)
      
      if patpos > length(PAT_pattern) then
      begin
         PAT_match := PAT_lc = ENDSTR;
         exit;
      end
      else

(* does line match pattern?  step forward if so *)
      
      if (PAT_pc = PAT_lc) then
      begin
         inc(patpos);
         inc(linpos);
         goto continue;
      end
      else

(* end of line?  we missed a match if so *)
      
      if PAT_lc = ENDSTR then
         exit
      else

(* ? matches anything *)
      
      if (PAT_pc = QUESTION) then
      begin
         inc(patpos);
         inc(linpos);
         goto continue;
      end
      else

(* '*' matches 0 or more characters, anywhere in string *)
      
      if PAT_pc = STAR then
      begin
         
         if patpos = length(PAT_pattern) then
         begin
            PAT_match := true;
            exit;
         end;
         
         inc(patpos);
         
         repeat
            
            if PAT_match (patpos, linpos) then
            begin
               PAT_match := true;
               exit;
            end;
            
            inc(linpos);
            PAT_lc := ord (PAT_line [linpos]);
         until PAT_lc = ENDSTR;
         
         exit;
      end
      else
(* else no match is possible; terminate scan *)
         exit;

   until false;
end;

function wildcard_match (var pattern,
                         line:               string65): boolean;
                           {pattern must be upper case; line is not case 
                             sensitive}
begin

(* test for special case that matches all filenames *)
   
   if pattern[1] = '*' then
   begin
      if (pattern = '*.*') or
        ((pattern = '*.') and (pos('.',copy(line,1,9)) = 0)) then
      begin
         wildcard_match := true;
         exit;
      end;
   end;

   PAT_pattern := pattern;
   PAT_line := line;

(* force a space as end-of-string character to simplify *)
   
   if length(PAT_line) > 12 then
      PAT_line[0]:= chr (12);
   
   if PAT_line[length(PAT_line)] <> ' ' then
      PAT_line := PAT_line + ' ';

(* perform the match test *)
   
   stoupper(PAT_line);
   wildcard_match := PAT_match (1, 1);
end;   

procedure getfiles (pattern:       string65;
                    var fdir:      filearray;
                    var num:       integer);
var
   i:             integer;
   curdir:        string65;
   keyword:       string13;
   doscan:        boolean;    {can dos do this wildcard?}
   DirInfo:       SearchRec;

begin
   stoupper(pattern);

   curdir := path_only(pattern);
   if curdir = '' then
      curdir := '@:';

   if (length(curdir) = 2) and (curdir[2] = ':') then
      getdir(ord(curdir[1])-ord('@'),curdir);

   if (curdir[length(curdir)] <> '\') then
   begin
      inc(curdir[0]);
      curdir[length(curdir)] := '\';
   end;

   keyword := remove_path(pattern);

   doscan := true;
   i := pos('*',keyword);
   if i > 0 then
      if (keyword[i+1] <> '.') and (i < length(keyword)) then
         doscan := false;

   if doscan = false then
      pattern := curdir + '*.*';

   num := 0;
   FindFirst(pattern,$21,DirInfo);

   while (DosError = 0) and (num < maxnumfiles) do
   begin
         {best if $B-}
      if doscan or wildcard_match(keyword, DirInfo.name) then
      begin
         inc(num);
         savestr(fdir[num],curdir + DirInfo.name);
      end;

      FindNext(DirInfo);
   end;

{  if num >= maxnumfiles then
      writeln('Warning:  Files in excess of ', maxnumfiles, ' ignored.');
}
{writeln('getfile3 par=',pattern,
                 ' cd=',curdir,
                ' key=',keyword,
                ' can=',doscan,
                ' n=',num);}

end;                     {getfiles}

function strval (i: integer): string2;
begin
   strval := chr(((i div 10) mod 10) + ord('0')) +
             chr((i mod 10) + ord('0'));
end;

function system_dd: string2;
var
   reg:           registers;
begin
   reg.ax := $2a00;
   msdos(reg);
   system_dd := strval(lo(reg.dx));
end;

function system_mm: string2;
var
   reg:           registers;
begin
   reg.ax := $2a00;
   msdos(reg);
   system_mm := strval(hi(reg.dx));
end;

function system_yy: string2;
var
   reg:           registers;
begin
   reg.ax := $2a00;
   msdos(reg);
   system_yy := strval(reg.cx-1900);
end;

function system_date: string8;   {format: mm-dd-yy}
begin
   system_date := system_mm + '-' + system_dd + '-' + system_yy;
end;


function system_time: string8;   {format: hh:mm}
var
   reg:       registers;
begin
   reg.ax := $2c00;
   msdos(reg);
   system_time := strval(hi(reg.cx)) +  ':' + strval(lo(reg.cx));
end;

function get_time: real;
var
   h,m,s,s1: word;
begin
   GetTime(h,m,s,s1);
   get_time := int(s1)/ 100.0 +   {seconds/100}
               int(s) +           {seconds}
               int(m) * 60.0 +    {minutes}
               int(h) * 3600.0;   {hours}
end;

function lget_time: longint;
var
   h,m,s,s1: word;
begin
   GetTime(h,m,s,s1);
   lget_time := longint(s) +                  {seconds}
                longint(m) * longint(60) +    {minutes}
                longint(h) * longint(3600);   {hours}
end;

function lget_ms: longint;
var
   h,m,s,s1: word;
begin
   GetTime(h,m,s,s1);
   lget_ms  := longint(s1)* longint(10) +      {seconds/100}
               longint(s) * longint(1000) +    {seconds}
               longint(m) * longint(60000) +   {minutes}
               longint(h) * longint(3600000);  {hours}
end;

function get_mins: integer;
var
   h,m,s,s1: word;
begin
   GetTime(h,m,s,s1);
   get_mins := m + 60 * h;
end;

procedure delay(ms: longint);
   (* delay for a specified number of miliseconds; give up time while
      delaying *)
var
   finish:  longint;
   start:   longint;
   now:     longint;

begin
   start := lget_ms;
   finish := start + ms;

   repeat
      give_up_time;
      now := lget_ms;
   until (now > finish) or    {time elapsed}
         (now < start);       {midnight rolover!}
end;

procedure delete_spaces(var line: string);
var
   p: integer;
begin
   p := pos(' ',line);
   while p > 0 do
   begin
      delete(line,p,1);
      p := pos(' ',line);
   end;
end;

procedure delete_trailing_spaces(var line: string);
begin
   while (length(line) > 0) and (line[length(line)] <= ' ') do
      dec(line[0]);
end;

procedure delete_leading_spaces(var line: string);
begin
   while (length(line) > 0) and (line[1] <= ' ') do
      delete(line,1,1);
end;

procedure replace_string( var line: longstring; oldstr, newstr: string65);
   (* perform string replacement if possible *)
var
   k: integer;
   max: integer;
begin
   max := 10;
   k := pos(oldstr,line);
   while (k <> 0) and (max > 0) do
   begin
      line := copy(line,1,k-1) + newstr + copy(line,k+length(oldstr),255);
      k := pos(oldstr,line);
      dec(max);
   end;
end;

function get_environment_var(id: string20): anystring;


{$IFDEF TP40}
var
   envseg:  integer;
   i:       integer;
   env:     anystring;

begin
   envseg := memw[PrefixSeg:$2c];
   i := 0;

   repeat
      env := '';
      while mem[envseg:i] <> 0 do
      begin
         env := env + chr(mem[envseg:i]);
         inc(i);
      end;

      if copy(env,1,length(id)) = id then
      begin
         get_environment_var := copy(env,length(id)+1,255);
         exit;
      end;

      inc(i);
   until mem[envseg:i] = 0;

(* not found *)
   get_environment_var := '';
end;

{$ELSE}  {TP 5.0}

begin
   dec(id[0]);    {delete trailing =}
   get_environment_var := GetEnv(id);
end;

{$ENDIF}


function environment_on(id: string20): boolean;
var
   value:   string20;
begin
   value := GetEnv(id);
   stoupper(value);
   environment_on := (value = 'ON');
end;

procedure releasestr( var str:  varstring);
   (* release the memory used by a varstring variable.  variable MUST
      be pre-allocated or the program may crash!!! *)
var
   olen: integer;
   die : Byte;
begin
   die := 0;
   if str <> nil then
   begin
      olen := ord(str^[length(str^)+1]);
      if length(str^) <> olen then
      begin
(**
writeln(^G'release: [',str^,'] ',olen,^G^G^G);
**)
         olen := olen div die; {signal runtime error}
      end;
      
      freemem(str,length(str^)+2);
      str := nil;
   end;
end;


procedure savestr( var tostr: varstring;
                   from:      longstring);
   (* save a regular string in a varstring; new allocation of varstring *)
begin

   releasestr(tostr);
   if maxavail < length(from)+100 then
      {$i-} writeln('out of heap, savestr: [',from,']'); {$i+}

   getmem(tostr, length(from)+2);
   tostr^ := from;
   tostr^[length(from)+1] := chr(length(from));
end;

function ljust(s: string80; w: integer): string80;
begin
   if w > sizeof(s)-1 then
      w := sizeof(s)-1;
   repeat
      s := s + ' ';
   until length(s) >= w;

   ljust := copy(s,1,w);
end;

function rjust(s: string80; w: integer): string80;
begin
   if w > sizeof(s)-1 then
      w := sizeof(s)-1;
   while length(s) < w do
      s := ' ' + s;
   rjust := s;
end;

function getbit(map: bitmap; bitnum: bitnumber): boolean;
   {return true/false for specified bit 0..39 in a bitmap}
var
   byteno:  integer;
   bitno:   integer;
begin
   byteno := bitnum shr 3;    {0..4}
   bitno  := bitnum mod 8;    {0..7}
   getbit := odd(map.bits[byteno] shr bitno);
end;

procedure setbit(var map: bitmap; bitnum: bitnumber; value: boolean);
   {set the specified bit in a bitmap}
var
   byteno:  integer;
   bitno:   integer;
begin
   byteno := bitnum shr 3;    {0..4}
   bitno  := bitnum mod 8;    {0..7}
   if value then
      map.bits[byteno] := map.bits[byteno] or (1 shl bitno)
   else
      map.bits[byteno] := map.bits[byteno] and (255 - (1 shl bitno));
end;

function getflag(flag: byte; bitval: byte): boolean;
   {return true/false for specified is set}
begin
   getflag := (flag and bitval) <> 0;
end;

procedure setflag(var flag: byte; bitval: byte; value: boolean);
   {set the specified bit in a flagbyte}
begin
   if value then
      flag := flag or bitval
   else
      flag := flag and (255 - bitval);
end;

function toggleflag(var flag: byte; bitval: byte): boolean;
   {toggle the specified bit and return new setting}
var
   value:  boolean;
begin
   value := not getflag(flag,bitval);
   setflag(flag,bitval,value);
   toggleflag := value;
end;

procedure vappends(var line: varstring; s: anystring);
begin
   savestr(line,line^ + s);
end;

function disk_space(disk: char): word;
   {report space on drive in k bytes}
   {should work even wth partitions over 32meg}
   {dos.diskfree fails on large partitions as of tp5.0}

var
   reg:     registers;
   space:   longint;
   bpcl:    word;

begin
   reg.ah := $36;
   if disk = '\' then
      reg.dl := 0
   else
      reg.dl := ord(upcase(disk))-ord('@');
   msdos(reg);

   if reg.ax = $FFFF then
      space := 0
   else
   begin
      {ax=sectors per cluster, bx=free clusters, cx=bytes per sector}
      space := reg.bx;                 {clusters}
      bpcl := reg.ax * reg.cx;         {bytes per cluster}
      space := (space * bpcl) shr 10;
   end;

   if space > $7FFF then
      disk_space := $7FFF
   else
      disk_space := space;
end;

procedure qWrite(x,y: integer; s: string);
   {very fast dma string display}
var
  Vmode:       byte    absolute $0040:$0049;   {Current video mode}

{video modes}
const
  NoDisplay = $00;   VgaMono   = $07;
  MdaMono   = $01;   VgaColor  = $08;
  CgaColor  = $02;   DCC9      = $09;
  DCC3      = $03;   DCC10     = $0A;
  EgaColor  = $04;   McgaMono  = $0B;
  EgaMono   = $05;   McgaColor = $0C;
  PgcColor  = $06;   Unknown   = $FF;

type
   screenloc = record
      character: char;
      attribute: byte;
   end;

   videoram = array [1..2000] of screenloc;
   videoptr = ^videoram;

var
   disp_mem:   videoptr;
   i:          integer;
   bx:         integer;

begin
   case Vmode of
      MdaMono, VgaMono:
         disp_mem := ptr($B000,0);
      else
         disp_mem := ptr($B800,0);
   end;

   bx := 80*y+x-81;
   for i := 1 to length(s) do
      disp_mem^[bx+i].character := s[i];
end;

begin
   fillchar(filetable,sizeof(filetable),0);
end.

