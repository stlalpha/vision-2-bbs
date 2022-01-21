
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
 * crc32 - Quick 32-bit crc calculation unit
 *
 * Written by Samuel Smith, 20-Mar-89
 *
 *)

{$S-,R-}
{$D+,L+}

unit CRC32;

interface

   var
      crc_out: longint;

   const
      crc_seed : longint = $cbcbcbcb;

   procedure crcstr(var src;
                    var crcout: longint;
                    len: integer);
      {calculate crc-32 of a buffer}


implementation

   {$L crc32.obj}

   procedure crcstr(var src;
                    var crcout: longint;
                    len: integer);
   external;
end.
