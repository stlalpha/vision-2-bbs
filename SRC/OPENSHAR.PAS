
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
 * OpenShare - TPAS 5.0 unit for shared text files (3-1-89)
 *
 * Use AssignText instead of Assign to create a text file
 * with full DOS 3.x file sharing (as implemented for binary
 * files by MDosIO)
 *
 *)

 {$i prodef.inc}
   {$L+,D+}

unit OpenShare;

interface

   Uses Dos,MdosIO;

   Procedure AssignText(var F:  Text; FileName:  dos_filename);
      (* use instead of Assign() for shared text files *)


implementation

{$F+}

(* -------------------------------------------------------- *)
function text_read(var F:  TextRec):  word;
begin
  {dos_name := F.Name;}
   F.BufEnd := dos_read(F.Handle,F.BufPtr^,F.BufSize);
   F.BufPos := 0;
   text_read := 0;
end;


(* -------------------------------------------------------- *)
function text_write(var F:  TextRec):  word;
begin
  {dos_name := F.Name;}
   dos_write(F.Handle,F.BufPtr^,F.BufPos);
   F.BufPos := 0;
   F.BufEnd := 0;
   text_write := 0;
end;


(* -------------------------------------------------------- *)
function text_close(var F:  TextRec):  word;
begin
  {dos_name := F.Name;}
   dos_close(F.Handle);
   F.BufPos := 0;
   F.BufEnd := 0;
   text_close := 0;
end;


(* -------------------------------------------------------- *)
function do_nothing(var F:  TextRec):  word;
begin
   do_nothing := 0;
end;


(* -------------------------------------------------------- *)
function text_open(var F:  TextRec):  word;
var
   fname: dos_filename;

begin
   F.CloseFunc := @text_close;       {Set close function}
   F.FlushFunc := @do_nothing;       {Set Flush function}
   fname := F.Name;
   fname[0] := chr(pos(#0,fname)-1);

   if F.Mode = fmInput then
   begin
      F.Handle := dos_open(fname,open_read);    {reset}
      F.InOutFunc := @text_read;     {Set Input function}
   end
   else 
   
   if F.Mode = fmOutput then
   begin
      F.Handle := dos_create(fname);           {rewrite}
      F.InOutFunc := @text_write;    {Set Output function}
   end
   else

   begin
      F.Handle := dos_open(fname,open_update);  {append}
      if F.Handle = dos_error then
         F.Handle := dos_create(fname)          {automatic rewrite}
      else
         dos_find_eof(F.Handle);

      F.Mode := fmOutput;            {Set Output Only mode}
      F.InOutFunc := @text_write;    {Set Output function}
   end;

   F.BufPos := 0;                   {Reset buffer ptr to 1st char.}
   F.BufEnd := 0;                   {Buffer is now empty}

   if F.Handle = dos_error then
      text_open := dos_regs.AX
   else
      text_open := 0;
end;


(* -------------------------------------------------------- *)
procedure AssignText(var F:  text; FileName:  dos_filename);
   (* use instead of Assign() for shared text files *)
var
   I:  integer;
   P:  TextRec absolute F;

begin
   P.Handle   := $FFFF;
   P.Mode     := fmClosed;               {Indicate the file is not yet open}
   P.BufSize  := SizeOf(P.Buffer);       {Set size of default buffer (128)}
   P.BufPtr   := @P.Buffer;              {Set up pointer to default buffer}
   P.OpenFunc := @text_open;             {Set up pointer to OPEN function}

   dos_name := FileName;
   for I := 1 to length(dos_name) do     {Set up asciiz filename}
      P.Name[I-1] := dos_name[I];

   for I := length(dos_name) to sizeof(P.Name)-1 do
      P.Name[I] := Chr(0);
end;


end.

