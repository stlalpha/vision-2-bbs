
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
 * Bufio - Buffered File I/O Unit (3-1-89)
 *
 * This unit provides both read and write buffering on block oriented
 * random-access files.  It is optimized for sequential reads or writes,
 * but will function properly with fully random files.
 *
 *)

{$i prodef.inc}

unit BufIO;

interface
   uses DosMem, MdosIO;

   const
      maxbufsiz = $FE00;         {largest file buffer to allocate}

   type
      bufarray = array[0..maxbufsiz] of char;

      buffered_file = record     {buffered file description record}
         pathname:   dos_filename;  {full name of the file}
         handle:     dos_handle; {handle for dos calls}
         maxrec:     word;       {maximum number of records}
         recsiz:     word;       {record size}
         bufsiz:     word;       {size of the data buffer}
         buffer:     ^bufarray;  {the data buffer}
         fptr:       word;       {base record in file for buffer}
         fnext:      word;       {next record position in buffer (0=first)}
         fcount:     word;       {count of records in buffer}
         dirty:      boolean;    {unsaved changes in buffer?}
         reverse:    boolean;    {reading backwards?}
      end;


   var
      berr: boolean;       {true if buffered read or write fails}


   procedure bcreate(name:    dos_filename);
      {create an empty file; use with bopen to open output files}

   procedure bopen(var bfd:   buffered_file; {file variable}
                   name:      dos_filename;  {name of file}
                   maxrecn:   word;          {number of records to buffer}
                   recsize:   word);         {size of each record}
      {open a buffered file}                 {sets 'bErr' if not ok}

   procedure bflush(var bfd:  buffered_file);
      {write buffer, force re-read on next access}
      
   procedure bseek(var bfd:   buffered_file;
                   recn:      word);
      {set position of buffered file}
   
   procedure bseekeof(var bfd:   buffered_file);
      {set position of buffered file to end-of-file}
   
   function btell(var bfd:    buffered_file): word;
      {tell current record number in buffered file}

   function beof(var bfd:     buffered_file): boolean;
      {check for eof on buffered file}

   procedure bread(var bfd:   buffered_file;
                   var dest);
      {buffered read}
   
   procedure bwrite(var bfd:   buffered_file;
                    var src);
      {buffered write}

   procedure bclose(var bfd:  buffered_file);
      {close a buffered file}



implementation

(* -------------------------------------------------------- *)
   procedure bcreate(name:    dos_filename);
      {create an empty file}
   begin
      dos_close(dos_create(name));
   end;


(* -------------------------------------------------------- *)
   procedure bopen(var bfd:   buffered_file;
                   name:      dos_filename;
                   maxrecn:   word;
                   recsize:   word);
      {open a buffered file}
   var
      limrec:  word;
   begin
      {reduce buffer records if needed to avoid exceeding buffer size limit}
      limrec := maxbufsiz div recsize;
      if maxrecn > limrec then
         maxrecn := limrec;

      {initialize the file buffer variables}
      bfd.maxrec := maxrecn;
      bfd.recsiz := recsize;
      bfd.bufsiz := maxrecn*recsize;
      bfd.fcount := 0;
      bfd.fnext := 0;
      bfd.fptr := 0;
      bfd.dirty := false;
      bfd.reverse := true;
      bfd.pathname := name;

      {open the file and allocate a buffer for it}
      bfd.handle := dos_open(name, open_update);
      berr := bfd.handle = dos_error;
      if berr then
         bfd.buffer := nil
      else
         dos_getmem(bfd.buffer, bfd.bufsiz);

(****
   writeln('bopen: handle=',bfd.handle,
                  ' path=',bfd.pathname,
                  ' buf@',seg(bfd.buffer^),':',ofs(bfd.buffer^),
                  ' bfd@',seg(bfd),':',ofs(bfd));
 *****)
   end;


(* -------------------------------------------------------- *)
   procedure bflush(var bfd:  buffered_file);
      {save changes in buffer, force re-read on next access}
   begin
      {if file has been written, write buffer contents}
      if bfd.dirty then
      begin
         dos_rseek(bfd.handle, bfd.fptr, bfd.recsiz, seek_start);
         dos_write(bfd.handle, bfd.buffer^, bfd.recsiz*bfd.fcount);
{writeln('...write ',bfd.fcount,' fptr=',bfd.fptr,' name=',bfd.pathname);}
         bfd.dirty := false;
         berr := dos_write_err;
      end
      else
         berr := false;

      {adjust physical position in file and empty the buffer}
      inc(bfd.fptr, bfd.fnext);
      bfd.fnext := 0;
      bfd.fcount := 0;
      dos_rseek(bfd.handle, bfd.fptr, bfd.recsiz, seek_start);
   end;


(* -------------------------------------------------------- *)
   procedure bseek(var bfd:   buffered_file;
                   recn:      word);
      {set position of buffered file}
   begin
      {reposition within buffer, if possible}
      if (recn >= bfd.fptr) and (recn <= bfd.fptr+bfd.fcount) then
         bfd.fnext := recn - bfd.fptr
      else
      begin
         {save changes, if any}
         if bfd.dirty then
            bflush(bfd);

         bfd.reverse := recn < bfd.fptr;

         {perform the physical seek}
         bfd.fptr := recn;
         bfd.fnext := 0;
         bfd.fcount := 0;
         dos_rseek(bfd.handle, recn, bfd.recsiz, seek_start);
      end;
   end;
   

(* -------------------------------------------------------- *)
   procedure bseekeof(var bfd:   buffered_file);
      {set position of buffered file to end-of-file}
   begin
      {save changes, if any}
      if bfd.dirty then
         bflush(bfd);

      dos_lseek(bfd.handle, 0, seek_end);
      bfd.fptr := dos_tell div longint(bfd.recsiz);
      bfd.fnext := 0;
      bfd.fcount := 0;
   end;
   

(* -------------------------------------------------------- *)
   function btell(var bfd:    buffered_file): word;
      {tell current record number in buffered file}
   begin
      btell := bfd.fptr+bfd.fnext;
   end;


(* -------------------------------------------------------- *)
   function beof(var bfd: buffered_file): boolean;
      {check for eof on buffered file}
   var
      cr:   word;
      nr:   word;
   begin
      {read next block if buffer is empty or exhausted}
      if bfd.fnext >= bfd.fcount then
      begin

         {if reading backwards read "lower" in the file than needed}
         if bfd.reverse and (bfd.fcount = 0) then
         begin
            cr := bfd.fptr;            {current base position}
            nr := bfd.maxrec div 4;    {new position for reverse-read}
            if cr > nr then
               bseek(bfd,cr-nr)
            else
               bseek(bfd,0);

            bfd.fnext := 0;
            bfd.fcount :=
                  dos_read(bfd.handle, bfd.buffer^, bfd.bufsiz) div bfd.recsiz;
            bseek(bfd,cr);
         end
         else

         begin
            {save changes if buffer has been written}
            if bfd.dirty then
               bflush(bfd);

            inc(bfd.fptr,bfd.fcount);
            bfd.fnext := 0;
            bfd.fcount := dos_read(bfd.handle, bfd.buffer^, bfd.bufsiz) div bfd.recsiz;
   {writeln('...read ',bfd.fcount,' fptr=',bfd.fptr,' name=',bfd.pathname);}
         end;
      end;
      
      {eof if no records left}
      beof := bfd.fcount = 0;
   end;
         

(* -------------------------------------------------------- *)
   procedure bread(var bfd:   buffered_file;
                   var dest);
      {buffered read}
   begin
      {check for end of file; read next block when needed}
      berr := beof(bfd);
      if berr then
         exit;

      {copy from buffer to user variable}
      move(bfd.buffer^[bfd.fnext*bfd.recsiz], dest, bfd.recsiz);
      inc(bfd.fnext);
   end;
   

(* -------------------------------------------------------- *)
   procedure bwrite(var bfd:   buffered_file;
                    var src);
      {buffered write (call dos_write_err to check status)}
   begin
      dos_write_err := false;

      {save changes if not yet writing or if buffer is full of changes}
      if (not bfd.dirty) or (bfd.fnext >= bfd.maxrec) then
         bflush(bfd)
      else
         berr := false;

      {save user variable in buffer and flag it as 'dirty'(unsaved)}
      move(src, bfd.buffer^[bfd.fnext*bfd.recsiz], bfd.recsiz);
      inc(bfd.fnext);
      if bfd.fcount < bfd.fnext then
         inc(bfd.fcount);
      bfd.dirty := true;
   end;


(* -------------------------------------------------------- *)
   procedure bclose(var bfd:  buffered_file);
      {close a buffered file}
   begin
      if bfd.buffer = nil then
         exit;

      bflush(bfd);
      dos_close(bfd.handle);              {low-level file close}

(****
    writeln('bclose: handle=',bfd.handle,
                  ' path=',bfd.pathname,
                  ' buf@',seg(bfd.buffer^),':',ofs(bfd.buffer^),
                  ' bfd@',seg(bfd),':',ofs(bfd));
 ****)

      dos_freemem(bfd.buffer);    {release buffer memory}
   end;


{unit initialization}
{begin}
end.

