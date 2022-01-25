
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
 * MiniCrt - simplified version of Borland's CRT unit.
 * Does not EVER do direct video.  The standard crt unit
 * locks up multi-taskers with its direct video checking before
 * the user program can turn it off.
 *
 * (3-1-89)
 *
 *)

{$i prodef.inc}

unit MiniCrt;

interface

   uses Dos;

   var
      stdout:  text;  {output through dos for ANSI compatibility}

   const
      scroll_line: byte = 23;
      window_y1  : byte = 1;
      window_y2  : byte = 25;
      TextAttr   : byte = $07;
      key_pending: char = #0;
      directVideo: boolean = true;

   procedure StdWrite(var s; len: integer);

   function KeyPressed: Boolean;
   function ReadKey: Char;

   procedure Window(X1,Y1,X2,Y2: Byte);  {only partial support}
   procedure SetScrollPoint(Y2: Byte);
   procedure FullScreen;

   procedure GotoXY(X,Y: Byte);
   function WhereX: Byte;
   function WhereY: Byte;

   procedure ClrScr;
   procedure ClrEol;

   procedure NormalVideo;
   procedure LowVideo;
   procedure ReverseVideo;
   procedure BlinkVideo;

   procedure push_bp; inline($55);
   procedure pop_bp; inline($5D);



   (* -------------------------------------------------------- *)
   procedure ScrollUp;
   {$F+} function ConFlush(var F: TextRec): integer; {$F-}
   {$F+} function ConOutput(var F: TextRec): integer; {$F-}
   {$F+} function ConOpen(var F: TextRec): Integer; {$F-}


(* -------------------------------------------------------- *)

implementation


   (* -------------------------------------------------------- *)
   procedure StdWrite(var s; len: integer);
   begin
      {call fastest bios method if 'directVideo' is enabled}
      if directVideo then
         Inline(
           $55/                   {    push bp}
           $8B/$4E/<len/          {    mov cx,[bp+<len]}
           $C4/$76/<s/            {    les si,[bp+<s]}
           $41/                   {    inc cx}
           $E9/$0A/$00/           {    jmp first}
                                  {next:}
           $26/$AC/               {    es: lodsb}
           $51/                   {    push cx}
           $56/                   {    push si}
           $06/                   {    push es}
           $CD/$29/               {    int $29}
           $07/                   {    pop es}
           $5E/                   {    pop si}
           $59/                   {    pop cx}
                                  {first:}
           $E2/$F4/               {    loop next}
                                  {exit:}
           $5D)                   {    pop bp}

      else  {otherwise use simple write to stdout}
         Inline(
           $B8/$00/$40/           {    mov ax,$4000}
           $BB/$01/$00/           {    mov bx,1}
           $8B/$4E/<len/          {    mov cx,[bp+<len]}
           $1E/                   {    push ds}
           $C5/$56/<s/            {    lds dx,[bp+<s]}
           $CD/$21/               {    int $21}
           $1F);                  {    pop ds}
   end;


   (* -------------------------------------------------------- *)
   function ReadKey: Char;
   var
      reg: registers;
   begin
      if key_pending <> #0 then
      begin
         ReadKey := key_pending;
         key_pending := #0;
         exit;
      end;

      reg.ax := $0000;   {wait for character}
      intr($16,reg);
      if reg.al = 0 then
         key_pending := chr(reg.ah);

      ReadKey := chr(reg.al);
   end;


   (* -------------------------------------------------------- *)
   function KeyPressed: Boolean;
(********
   var
      reg: registers;
   begin
      reg.ax := $0100;   {check for character}
      intr($16,reg);
      KeyPressed := ((reg.flags and FZero) = 0) or (key_pending <> #0);
*********)
   begin
      Inline(
        $B8/$00/$01/                {mov ax,$0100}
        $CD/$16/                    {int $16}
        $B0/$01/                    {mov al,1}
        $75/$09/                    {jnz exit}
        $80/$3E/>key_pending/$00/   {cmp byte [>key_pending],0}
        $75/$02/                    {jnz exit}
        $B0/$00/                    {mov al,0}
                               {exit:}
        $88/$46/<KeyPressed);       {mov [bp+<KeyPressed],al}
   end;


   (* -------------------------------------------------------- *)
   procedure Window(X1,Y1,X2,Y2: Byte);
   begin
      window_y1 := y1;
      window_y2 := y2;
   end;

   procedure FullScreen;
   begin
      window_y1 := 1;
      window_y2 := scroll_line+2;
   end;

   procedure SetScrollPoint(Y2: Byte);
   begin
      window_y1 := 1;
      window_y2 := Y2;
   end;


   (* -------------------------------------------------------- *)
   procedure GotoXY(X,Y: Byte);
   begin
      Inline(
        $B4/$02/               {mov ah,2}
        $31/$DB/               {xor bx,bx}
        $8A/$76/<y/            {mov dh,[bp+<y]}
        $FE/$CE/               {dec dh}
        $8A/$56/<x/            {mov dl,[bp+<x]}
        $FE/$CA/               {dec dl}
        $55/                   {push bp}
        $CD/$10/               {int $10}
        $5D);                  {pop bp}
   end;


   (* -------------------------------------------------------- *)
   function WhereX: Byte;
   begin
      Inline(
        $B4/$03/               {mov ah,3}
        $30/$FF/               {xor bh,bh}
        $55/                   {push bp}
        $CD/$10/               {int $10}
        $5D/                   {pop bp}
        $FE/$C2/               {inc dl}
        $88/$56/<WhereX);      {mov [bp+<WhereX],dl}
   end;

   function WhereY: Byte;
   begin
      Inline(
        $B4/$03/               {mov ah,3}
        $30/$FF/               {xor bh,bh}
        $55/                   {push bp}
        $CD/$10/               {int $10}
        $5D/                   {pop bp}
        $FE/$C6/               {inc dh}
        $88/$76/<WhereY);      {mov [bp+<WhereY],dh}
   end;


   (* -------------------------------------------------------- *)
   procedure ClrScr;
   begin
      Inline(
        $55/                   {push bp}
        $B8/$00/$06/           {mov ax,$0600}
        $31/$C9/               {xor cx,cx}
        $8A/$36/>window_y2/    {mov dh,[>window_y2]}
        $FE/$CE/               {dec dh}
        $B2/$4F/               {mov dl,79}
        $8A/$3E/>TextAttr/     {mov bh,[>TextAttr]}
        $CD/$10/               {int $10}
        $B4/$02/               {mov ah,2}
        $31/$DB/               {xor bx,bx}
        $31/$D2/               {xor dx,dx}
        $CD/$10/               {int $10}
        $5D);                  {pop bp}
   end;


   (* -------------------------------------------------------- *)
   procedure ClrEol;
   begin
      Inline(
        $B4/$03/               {mov ah,3}
        $31/$DB/               {xor bx,bx}
        $55/                   {push bp}
        $CD/$10/               {int $10}
        $B8/$00/$06/           {mov ax,$0600}
        $89/$D1/               {mov cx,dx}
        $B2/$4F/               {mov dl,79}
        $8A/$3E/>TextAttr/     {mov bh,[>TextAttr]}
        $CD/$10/               {int $10}
        $5D);                  {pop bp}
   end;


   (* -------------------------------------------------------- *)
   procedure NormalVideo;
   begin
      TextAttr := $0F;
   end;

   procedure LowVideo;
   begin
      TextAttr := $07;
   end;

   procedure ReverseVideo;
   begin
      TextAttr := $70;
   end;

   procedure BlinkVideo;
   begin
      TextAttr := $F0;
   end;


   (* -------------------------------------------------------- *)
   procedure ScrollUp;
   begin
      Inline(
        $B8/$01/$06/           {mov ax,$0601;}
        $31/$C9/               {xor cx,cx}
        $8A/$36/>window_y2/    {mov dh,[>window_y2]}
        $FE/$CE/               {dec dh}
        $B2/$4F/               {mov dl,79}
        $8A/$3E/>TextAttr/     {mov bh,[>TextAttr]}
        $55/                   {push bp}
        $CD/$10/               {int $10}
        $5D);                  {pop bp}
   end;


   (* -------------------------------------------------------- *)
   {$F+} function ConFlush(var F: TextRec): integer; {$F-}
   var
      P:    Word;
      reg:  registers;
      x,y:  byte;
      ch:   char;

   begin
      if F.BufPos > 0 then
      begin
         {get present cursor position}
         Inline(
           $B4/$03/               {mov ah,3}
           $31/$DB/               {xor bx,bx}
           $55/                   {push bp}
           $CD/$10/               {int $10}
           $5D/                   {pop bp}
           $FE/$C6/               {inc dh}
           $88/$76/<y/            {mov [bp+<y],dh}
           $FE/$C2/               {inc dl}
           $88/$56/<x);           {mov [bp+<x],dl}

         {process each character in the buffer}
         for P := 0 to F.BufPos-1 do
         begin
            ch := F.BufPtr^[P];

            case ch of
               #7:  {$i+} write(stdout,ch); {$i-}
               #8:  if x > 1 then dec(x);       {backspace}
               #9:  x := (x+8) and $F8;         {tab}

              #10:  if y {>}= window_y2 then    {scroll when needed}
                       ScrollUp
                    else
                       inc(y);

              #13:  x := 1;                     {c/r}

            else
               begin
                  Inline(
                    $B4/$09/               {mov ah,9}
                    $8A/$46/<ch/           {mov al,[bp+<ch]}
                    $B9/$01/$00/           {mov cx,1}
                    $8A/$1E/>TextAttr/     {mov bl,[>TextAttr]}
                    $30/$FF/               {xor bh,bh}
                    $55/                   {push bp}
                    $CD/$10/               {int $10}
                    $5D);                  {pop bp}

                  if x = 80 then   {line wrap?}
                  begin
                     x := 1;
                     if y >= window_y2 then   {scroll during wrap?}
                        ScrollUp
                     else
                        inc(y);
                  end
                  else
                     inc(x);
               end;
            end;

            {position physical cursor}
            Inline(
              $B4/$02/               {mov ah,2}
              $31/$DB/               {xor bx,bx}
              $8A/$76/<y/            {mov dh,[bp+<y]}
              $FE/$CE/               {dec dh}
              $8A/$56/<x/            {mov dl,[bp+<x]}
              $FE/$CA/               {dec dl}
              $55/                   {push bp}
              $CD/$10/               {int $10}
              $5D);                  {pop bp}
         end;

         F.BufPos:=0;
      end;

      ConFlush := 0;
   end;


   (* -------------------------------------------------------- *)
   {$F+} function ConOutput(var F: TextRec): integer; {$F-}
   begin
      ConOutput := ConFlush(F);
   end;


   {$F+} function ConOpen(var F: TextRec): Integer; {$F-}
   begin
      F.InOutFunc := @ConOutput;
      F.FlushFunc := @ConFlush;
      F.CloseFunc := @ConFlush;
      F.BufPos := 0;
      ConOpen := 0;
   end;



(* -------------------------------------------------------- *)
begin
   if GetEnv('OVCRT') <> '' then
      directVideo := false;

   {determine scroll line if ega/vga in >25 line modes}
   if directVideo then
   Inline(
     $31/$DB/                 {xor bx,bx}
     $8E/$C3/                 {mov es,bx}
     $26/$F6/$06/$87/$04/$08/ {test byte es:[$487],8}
     $75/$13/                 {jnz noega}
     $B8/$30/$11/             {mov ax,$1130}
     $8A/$16/>scroll_line/    {mov dl,[>scroll_line]}
     $FE/$C2/                 {inc dl}
     $55/                     {push bp}
     $CD/$10/                 {int $10}
     $5D/                     {pop bp}
     $FE/$CA/                 {dec dl}
     $88/$16/>scroll_line);   {mov [>scroll_line],dl}
                            {noega:}

   FullScreen;

   with TextRec(output) do
   begin
      BufPos := 0;
      InOutFunc := @ConOutput;
      FlushFunc := @ConFlush;
      OpenFunc  := @ConOpen;
   end;

   {$i-}
   assign(stdout,'');
   rewrite(stdout);
   {$i+}

end.

