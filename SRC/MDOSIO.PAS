
(*
 * Copyright 1987, 1989 Samuel H. Smith;  All rights reserved
 *
 * This is a component of the ProDoor System.
 * Do not distribute modified versions without my permission.
 * Do not remove or alter this notice or any other copyright notice.
 * If you use this in your own program you must distribute source code.
 * Do not use any of this in a commercial product.
 *
 *)

(*
 * mdosio - library for interface to DOS v3 file access functions (3-1-89)
 *
 *)

{$i prodef.inc}

unit MDosIO;

interface

   uses Dos;

   type
      dos_filename = string[64];
      dos_handle   = word;

      long_integer = record
         lsw: word;
         msw: word;
      end;

      seek_modes = (seek_start {0},
                    seek_cur   {1},
                    seek_end   {2});

      open_modes = (open_read  {h40},     {deny_nothing, allow_read}
                    open_write {h41},     {deny_nothing, allow_write}
                    open_update{h42});    {deny_nothing, allow_read+write}

      dos_time_functions = (time_get,
                            time_set);

   const
      dos_error    = $FFFF; {file handle after an error}

   var
      dos_regs:         registers;
      dos_name:         dos_filename;
      dos_write_err:    boolean;

   type
      dos_functions = (_open,  _creat,
                       _close, _times,
                       _read,  _write,
                       _rseek, _lseek,
                       _lock,  _unlock);

   const
      function_names:  array[dos_functions] of string[5] =
                      ('OPEN', 'CREAT',
                       'CLOSE','TIMES',
                       'READ', 'WRITE',
                       'RSEEK','LSEEK',
                       'LOCK', 'UNLCK');
                       

   procedure dos_check_error(fun: dos_functions);

   procedure dos_call(fun: dos_functions);

   function dos_open(name:      dos_filename;
                     mode:      open_modes):  dos_handle;

   function dos_create(name:    dos_filename): dos_handle;

   function dos_read( handle:   dos_handle;
                      var       buffer;
                      bytes:    word): word;

   procedure dos_write(handle:  dos_handle;
                       var      buffer;
                       bytes:   word);

   procedure dos_lseek(handle:  dos_handle;
                       offset:  longint;
                       method:  seek_modes);

   procedure dos_rseek(handle:  dos_handle;
                       recnum:  word;
                       recsiz:  word;
                       method:  seek_modes);

   function dos_tell: longint;

   procedure dos_find_eof(fd:   dos_handle);

   procedure dos_close(handle:  dos_handle);

   procedure dos_unlink(name:   dos_filename);

   procedure dos_file_times(fd:       dos_handle;
                            func:     dos_time_functions;
                            var time: word;
                            var date: word);

   function dos_jdate(time,date: word): longint;

   function dos_exists(name: dos_filename): boolean;

   function dos_lock(handle:  dos_handle;
                     offset:  longint;
                     bytes:   word): boolean;

   procedure dos_unlock(handle:  dos_handle;
                        offset:  longint;
                        bytes:   word);

   procedure dos_time(var ms: longint);
   procedure dos_delay(ms: longint);


implementation

(* -------------------------------------------------------- *)
procedure dos_check_error(fun: dos_functions);
var
   msg:  string;
begin
   if (dos_regs.flags and Fcarry) <> 0 then
   begin
      case dos_regs.ax of
         2:   msg := 'FILE NOT FOUND';
         3:   msg := 'DIR NOT FOUND';
         4:   msg := 'TOO MANY OPEN FILES';
         5:   msg := 'ACCESS DENIED';
         else str(dos_regs.ax,msg);
      end;
{$I-}
      writeln(' DOS error ['+msg+'] on file ['+dos_name+'] during ['+function_names[fun]+']');
{$i+}
      dos_regs.ax := dos_error;     {return standard failure code}
   end;
end;


(* -------------------------------------------------------- *)
procedure dos_call(fun: dos_functions);
begin
   msdos(dos_regs);
   dos_check_error(fun);
end;


(* -------------------------------------------------------- *)
procedure prepare_dos_name(name: dos_filename);
begin
   while (name <> '') and (name[length(name)] <= ' ') do
      dec(name[0]);

   if name = '' then
      name := 'Nul';

   dos_name := name;
   dos_name[length(dos_name)+1] := #0;
   dos_regs.ds := seg(dos_name);
   dos_regs.dx := ofs(dos_name)+1;
end;


(* -------------------------------------------------------- *)
function dos_open(name:    dos_filename;
                  mode:    open_modes):  dos_handle;
var
   try: integer;
const
   retry_count = 5;

begin
   for try := 1 to retry_count do
   begin
      dos_regs.ax := $3d00 + ord(mode);
      if lo(DosVersion) >= 3 then
         inc(dos_regs.ax,$40);

      prepare_dos_name(name);
      msdos(dos_regs);

      {return to caller immediately if no errors were detected}
      if (dos_regs.flags and Fcarry) = 0 then
      begin
         dos_open := dos_regs.ax;
         exit;
      end;

      {return to caller if file-not-found}
      if dos_regs.ax = 2 then
      begin
         dos_open := dos_error;
         exit;
      end;

      {report other errors and attempt to retry}
      dos_check_error(_open);
      dos_delay(3000)
   end;

   dos_open := dos_error;
end;


(* -------------------------------------------------------- *)
function dos_create(name:    dos_filename): dos_handle;
begin
   dos_regs.ax := $3c00;
   prepare_dos_name(name);
   dos_regs.cx := 0;   {attrib}
   dos_call(_creat);
   dos_create := dos_regs.ax;
end;


(* -------------------------------------------------------- *)
function dos_read( handle:  dos_handle;
                   var      buffer;
                   bytes:   word): word;
begin
   dos_regs.ax := $3f00;
   dos_regs.bx := handle;
   dos_regs.cx := bytes;
   dos_regs.ds := seg(buffer);
   dos_regs.dx := ofs(buffer);
   dos_call(_read);
   dos_read := dos_regs.ax;
end;


(* -------------------------------------------------------- *)
procedure dos_write(handle:  dos_handle;
                    var      buffer;
                    bytes:   word);
begin
   dos_regs.ax := $4000;
   dos_regs.bx := handle;
   dos_regs.cx := bytes;
   dos_regs.ds := seg(buffer);
   dos_regs.dx := ofs(buffer);
   dos_call(_write);
   dos_regs.cx := bytes;
   dos_write_err := dos_regs.ax <> dos_regs.cx;
end;


(* -------------------------------------------------------- *)
procedure dos_lseek(handle:  dos_handle;
                    offset:  longint;
                    method:  seek_modes);
var
   pos:  long_integer absolute offset;

begin
   dos_regs.ax := $4200 + ord(method);
   dos_regs.bx := handle;
   dos_regs.cx := pos.msw;
   dos_regs.dx := pos.lsw;
   dos_call(_lseek);
end;


(* -------------------------------------------------------- *)
procedure dos_rseek(handle:  dos_handle;
                    recnum:  word;
                    recsiz:  word;
                    method:  seek_modes);
var
   offset: longint;
   pos:    long_integer absolute offset;

begin
   offset := longint(recnum) * longint(recsiz);
   dos_regs.ax := $4200 + ord(method);
   dos_regs.bx := handle;
   dos_regs.cx := pos.msw;
   dos_regs.dx := pos.lsw;
   dos_call(_rseek);
end;


(* -------------------------------------------------------- *)
function dos_tell: longint;
  {call immediately after dos_lseek or dos_rseek}
var
   pos:  long_integer;
   li:   longint absolute pos;
begin
   pos.lsw := dos_regs.ax;
   pos.msw := dos_regs.dx;
   dos_tell := li;
end;


(* -------------------------------------------------------- *)
procedure dos_find_eof(fd: dos_handle);
   {find end of file, skip backward over ^Z eof markers}
var
   b: char;
   n: word;
   i: word;
   p: longint;
   temp: array[1..128] of char;

begin
   dos_lseek(fd,0,seek_end);
   p := dos_tell-1;
   if p < 0 then
      exit;

   p := p and $FFFF80;   {round to last 'sector'}
   {search forward for the eof marker}
   dos_lseek(fd,p,seek_start);
   n := dos_read(fd,temp,sizeof(temp));
   i := 1;

   while (i <= n) and (temp[i] <> ^Z) do
   begin
      inc(i);
      inc(p);
   end;

   {backup to overwrite the eof marker}
   dos_lseek(fd,p,seek_start);
end;


(* -------------------------------------------------------- *)
procedure dos_close(handle:  dos_handle);
begin
   dos_regs.ax := $3e00;
   dos_regs.bx := handle;
   msdos(dos_regs);  {dos_call;}
end;


(* -------------------------------------------------------- *)
procedure dos_unlink(name:    dos_filename);
   {delete a file, no error message if file doesn't exist}
begin
   dos_regs.ax := $4100;
   prepare_dos_name(name);
   msdos(dos_regs);
(****
   if (dos_regs.flags and Fcarry) = 0 then
      writeln('[unlink ',name,']');
***)
end;


(* -------------------------------------------------------- *)
procedure dos_file_times(fd:       dos_handle;
                         func:     dos_time_functions;
                         var time: word;
                         var date: word);
begin
   dos_regs.ax := $5700 + ord(func);
   dos_regs.bx := fd;
   dos_regs.cx := time;
   dos_regs.dx := date;
   dos_call(_times);
   time := dos_regs.cx;
   date := dos_regs.dx;
end;


(* -------------------------------------------------------- *)
function dos_jdate(time,date: word): longint;
begin

(***
     write(' d=',date:5,' t=',time:5,' ');
     write('8',   (date shr 9) and 127:1); {year}
     write('/',   (date shr 5) and  15:2); {month}
     write('/',   (date      ) and  31:2); {day}
     write(' ',   (time shr 11) and 31:2); {hour}
     write(':',   (time shr  5) and 63:2); {minute}
     write(':',   (time shl  1) and 63:2); {second}
     writeln(' j=', (longint(date) shl 16) + longint(time));
 ***)

   dos_jdate := (longint(date) shl 16) + longint(time);
end;


(* -------------------------------------------------------- *)
function dos_exists(name: dos_filename): boolean;
var
   DirInfo:     SearchRec;

begin
   prepare_dos_name(name);
   FindFirst(dos_name,AnyFile,DirInfo);
   dos_exists := (DosError = 0);
end;


(* -------------------------------------------------------- *)
function dos_lock(handle:  dos_handle;
                  offset:  longint;
                  bytes:   word): boolean;
var
   pos:    long_integer absolute offset;

begin
   dos_regs.ax := $5c00;
   dos_regs.bx := handle;
   dos_regs.cx := pos.msw;
   dos_regs.dx := pos.lsw;
   dos_regs.si := 0;
   dos_regs.di := bytes;
   msdos(dos_regs);

   dos_lock := false;
   if ((dos_regs.flags and Fcarry) = 0) or (dos_regs.ax = 1) then
      dos_lock := true
   else
      case dos_regs.ax of
         5,    {access denied}
         32,   {sharing violation}
         33:   {lock violation}
            ;
         else
            dos_check_error(_lock);
      end;
end;


(* -------------------------------------------------------- *)
procedure dos_unlock(handle:  dos_handle;
                     offset:  longint;
                     bytes:   word);
var
   pos:    long_integer absolute offset;

begin
   dos_regs.ax := $5c01;
   dos_regs.bx := handle;
   dos_regs.cx := pos.msw;
   dos_regs.dx := pos.lsw;
   dos_regs.si := 0;
   dos_regs.di := bytes;
   msdos(dos_regs);

   if (dos_regs.flags and Fcarry) <> 0 then
   case dos_regs.ax of
      1,    {invalid function}
      5,    {access denied}
      32,   {sharing violation}
      33:   {lock violation}
         ;
      else
         dos_check_error(_unlock);
   end;
end;


(* -------------------------------------------------------- *)
procedure dos_time(var ms: longint);
var
   reg:  registers;
begin
   reg.ax := 0;
   intr($1a,reg);
   ms := ((reg.cx shl 16) + reg.dx) * 55;
end;


(* -------------------------------------------------------- *)
procedure dos_delay(ms: longint);
var
   time,start:  longint;
begin
   dos_time(start);
   repeat
      dos_time(time);
   until (time > (start+ms)) or (time < start);
end;

end.
