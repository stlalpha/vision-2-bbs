{ TPBoard 4.2 Copyright (c) 1987,88 by Jon Schneider & Rick Petersen  
  Portions Copyright (c) 1986,87 by Steve Fox and Les Archambault  
  
  Last modified  ::  9-13-88 8:20 pm 
}

{$R-}                             {Range checking off}
{$B-}                             {Boolean complete evaluation off}
{$S-}                             {Stack checking off}
{$I+}                             {I/O checking on}
{$N-}                             {No numeric coprocessor}

Unit KeyStuff;

Interface

Implementation

  {==========================================================================}

const
  BufSeg          = $40;
  BufHeadAddr     = $1A;
  BufTailAddr     = $1C;
  BufBegAddr      = $1E;
  BufEndAddr      = $3C;
  
  
  function StuffChar(Ch : Char)      : Boolean;
    {  This procedure inserts a single character into the keyboard buffer. }
  var
    Tail, Head      : Integer;
    NextPos         : Integer;
    Ch2             : Char;
    
  begin
    inline($fa);                  {disable int's}
    Head := MemW[BufSeg:BufHeadAddr]; { get current head of buffer }
    Tail := MemW[BufSeg:BufTailAddr]; { get current tail of buffer }
    NextPos := Tail+2;
    if NextPos > BufEndAddr then
      NextPos := BufBegAddr;
    if NextPos <> Head then
      begin
        if Ord(Ch) > $7f then
          begin
            Ch2 := Chr(Ord(Ch)-$80);
            Ch := Chr(0);
          end
        else
          Ch2 := Chr(1);
        Mem[BufSeg:Tail] := Ord(Ch); { put character in }
        Mem[BufSeg:Tail+1] := Ord(Ch2); { put harmless scan code in }
        Tail := NextPos;          { increment the tail pointer }
        MemW[BufSeg:BufTailAddr] := Tail; { update actual keyboard tail }
        inline($fb);              { enable int's }
        StuffChar := True;
      end
    else
      begin
        inline($fb);              { enable int's }
        StuffChar := False;
      end;
  end;

var b: boolean;

begin
  b := StuffChar(#32);
end.                              { UNIT KbdStuff }
