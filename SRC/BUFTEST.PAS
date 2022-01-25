
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
 * test driver for BUFIO and MDOSIO units
 *
 *)

{$r-,s-}
{$m 8000,0,0}

uses mdosio,bufio;

const
   nbuf = 600;
   nout = 1000;
   siz = 400;
   fn1 = 't1';
   fn2 = 't2';

type
   rec = array[1..siz] of byte;

var
   inf:     buffered_file;
   outf:    buffered_file;
   v:       rec;
   i,j:     integer;

procedure iocheck;
begin
   if dos_write_err then
   begin
      writeln(^G'Write failure!  (disk full?) AX=',dos_regs.ax,' CX=',dos_regs.cx);
      halt;
   end;
end;

begin
   for i := 1 to siz do
      v[i] := 0;

   writeln('sequential write:');
   If Not Dos_Exists(Fn1) Then
     bcreate(fn1);
   bopen(outf,fn1,nbuf,sizeof(rec));
   BSeek(outf,0);
   for j := 1 to nout do
   begin
      bwrite(outf,v);
      iocheck;
   end;
   bclose(outf);

   writeln('sequential seek write:');
   bopen(outf,fn1,nbuf,sizeof(rec));
   for j := 1 to nout do
   begin
      bseek(outf,j-1);
      bwrite(outf,v);
      iocheck;
   end;
   bclose(outf);

   writeln('sequential read:');
   bopen(inf,fn1,nbuf,sizeof(rec));
   j := 0;
   while not beof(inf) do
   begin
      inc(j);
      bread(inf,v);
   end;
   writeln('   ',j,' records');
   bclose(inf);

   writeln('sequential seek read:');
   bopen(inf,fn1,nbuf,sizeof(rec));
   for j := 1 to nout do
   begin
      bseek(inf,j-1);
      bread(inf,v);
   end;
   bclose(inf);

   writeln('sequential copy:');
   If Not Dos_Exists(Fn2) Then
     bcreate(fn2);
   bopen(outf,fn2,nbuf,sizeof(rec));
   bopen(inf,fn1,nbuf,sizeof(rec));
   j := 0;
   while not beof(inf) do
   begin
      inc(j);
      bread(inf,v);
      bwrite(outf,v);
      iocheck;
   end;
   writeln('   ',j,' records');
   bclose(inf);
   bclose(outf);

   writeln('sequential seek copy:');
   bopen(outf,fn2,nbuf,sizeof(rec));
   bopen(inf,fn1,nbuf,sizeof(rec));
   for j := 1 to nout do
   begin
      bseek(inf,j-1);
      bread(inf,v);
      if btell(inf) <> j then writeln('tell error 1');
      bseek(outf,j-1);
      bwrite(outf,v);
      iocheck;
      if btell(outf) <> j then writeln('tell error 2');
   end;
   bclose(inf);
   bclose(outf);

   writeln('reverse sequential seek copy:');
   bopen(outf,fn2,nbuf,sizeof(rec));
   bopen(inf,fn1,nbuf,sizeof(rec));
   for j := nout downto 1 do
   begin
      bseek(inf,j-1);
      bread(inf,v);
      if btell(inf) <> j then writeln('tell error 1');
      bseek(outf,nout-j);
      bwrite(outf,v);
      iocheck;
      if btell(outf) <> (nout-j+1) then writeln('tell error 2');
   end;
   bclose(inf);
   bclose(outf);
end.

