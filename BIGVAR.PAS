*--*  12-20-92  -  12:06:43  *--*
Again
 þ Pascal Lessons National Echo#4334
Dt: 12-20-92 10:55     (Received)
By: Mike Copeland
To: George Ham
Re: large vars.


 GH>       I want to create a type of text editor.. what would be some 
 GH>efficient ways to load a text file into memory.. creating a pointer 
 GH>(like a dynamic array) of string, but the only problem is what if it is 
 GH>some huge .DOC file and is like 150k? thanks..

   You can certainly do this - just use Pointer Arrays (arrays of pointer
variables, in which array element is a pointer to some Heap data).  There are
several ways to code this, depending on whether you are working with variable
strings or fixed-length data.  Here's a sample:

{$M 8192,0,655360}
Var PA : array[1..10000] of Pointer;  { up to 10,000 data records }
    P  : Word;
    S  : string;
    F  : Text;
    
begin
  Assign (F,'myfile.dat'); Reset (F); P := 0;
  while not EOF (F) do
    begin
      readln (F,S); Inc(P);              { read, inc. index to PA }
      GetMem (PA,Length(S)+1);         { allocate Heap for record }
      PA[P]^ := S                           { move record to Heap }
    end;
  Close (F);

   Then, you can access any record in the stored file via a pointer in the
Pointer Array: PA[15]^ accesses the 15th record, etc.
   Changing the data records is a little tricky: if you replace one with a
larger record, you need to allocate new Heap space and change the pointer
(because the above code allocate only enough Heap for each specific record,
and there's no expansion in those areas).  Making the records smaller is no
problem, though...
   Then, when you've completed the "editing", just loop through the PA, and
write the records out to the new output file.
   Note that this example limits you to about 16K records, and you'd probably
want to enhance the i/o with SetTextBuf, and some other things.  There are
many improvements over this, but I'm just showing you the idea...  8<}}

--- msged 2.07
 * Origin: Hello, Keyboard, my old friend... (1:114/18.10)
SEEN-BY: 114/5 17 18 313/1 8 396/1


(A)gain, (N)ext, (L)ast, (R)eply, (E)nter, (S)top: Next
 þ Pascal Lessons National Echo#4475
Dt: 12-19-92 21:43    
By: Vince Laurent
To: Stephen Maxwell
Re: The Draw


SM> in TheDraw you can have it output an ansi screen as TurboPASCAL output
SM>both in compressed or uncompressed forms. How can I use these in a
SM>program to display an ANSI screen that I have drawn in TDraw? Can anyone
SM>lend a hand with a code fragment or two? (I am a beginner programmer- be
SM>gentle <g>)

The documents that come with THEDRAW have code...

Other than that, are you trying to do something for a LOCAL screen or
is your ultimate goal to get it to go over a modem? The pascal code
is a bit different...
___
 * SLMR 2.0 * Digital circuits are made from analog parts.

--- Maximus 2.01wb
 * Origin: Connect America (1:382/10)
SEEN-BY: 114/5 17 18 313/1 8 396/1

More(Y/n/continuous)?


(A)gain, (N)ext, (L)ast, (R)eply, (E)nter, (S)top: Next
 þ Pascal Lessons National Echo#4476
Dt: 12-19-92 15:59    
By: BRIAN ROGGE
To: MIKE AUSTIN
Re: oop's


MA>->  MA> Functions in Turbo Pascal 6.0;  I am also
MA>->  MA> Interested in forming a group
MA>->  MA> to help each other learn about oop's (which I am barley begginni
MA>->  MA> understand myself).

What do you mean by oop's?

Brian
---
 þ OLX 2.1 TD þ Hacking-More than just spitting a hairball.
--- GOMail v1.1 [DEMO] 01-05-93
 * Origin: The City Lights 612-633-1366 (1:282/108)
SEEN-BY: 114/5 17 18 313/1 8 396/1


(A)gain, (N)ext, (L)ast, (R)eply, (E)nter, (S)top: 