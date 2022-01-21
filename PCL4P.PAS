unit PCL4P;

interface

const
   (* COMM Ports *)
   COM1 = 0;
   COM2 = 1;
   COM3 = 2;
   COM4 = 3;
   (* Baud Rate Codes *)
   NORESET  = -1;
   Baud300  = 0;
   Baud600  = 1;
   Baud1200 = 2;
   Baud2400 = 3;
   Baud4800 = 4;
   Baud9600 = 5;
   Baud19200  = 6;
   Baud38400  = 7;
   Baud57600  = 8;
   Baud115200 = 9;
   (* Parity Codes *)
   NoParity  = 0;
   OddParity = 1;
   EvenParity= 3;
   (* Stop Bit Codes *)
   OneStopBit  = 0;
   TwoStopBits = 1;
   (* Word Length Codes *)
   WordLength5 = 0;
   WordLength6 = 1;
   WordLength7 = 2;
   WordLength8 = 3;
   (* Buffer Size Codes *)
   Size8    = 0;
   Size16   = 1;
   Size32   = 2;
   Size64   = 3;
   Size128  = 4;
   Size256  = 5;
   Size512  = 6;
   Size1024 = 7;
   Size2048 = 8;
   Size4096 = 9;
   Size8192 =  10;
   Size16384 = 11;
   Size32768 = 12;
   Size1K = 7;
   Size2K = 8;
   Size4K = 9;
   Size8K = 10;
   Size16K = 11;
   Size32K = 12;
   (* Line Status Masks *)
   TransBufferEmpty = $20;
   BreakDetect  = $10;
   FramingError = $08;
   ParityError  = $04;
   OverrunError = $02;
   DataReady    = $01;
   (* Modem Status Masks *)
   DCD = $80;
   RI  = $40;
   DSR = $20;
   CTS = $10;
   DeltaDCD = $08;
   DeltaRI  = $04;
   DeltaDSR = $02;
   DeltaCTS = $01;
   (* Break Signal Commands *)
   ASSERT = 'A';
   CANCEL = 'C';
   DETECT = 'D';
   (* SioDTR & SioRTS Commands *)
   SETON = 'S';
   CLEAR = 'C';
   READ  = 'R';
   (* FIFO level codes *)
   LEVEL_1 =  0;
   LEVEL_4 =  1;
   LEVEL_8 =  2;
   LEVEL_14 = 3;
   (* Primary / Secondary IRQ codes *)
   PRIMARY   = 0;
   SECONDARY = 1;

function SioBaud(Port, BaudCode : Integer) : Integer;
function SioBrkKey : Boolean;
function SioBrkSig(Port : Integer; Cmd : Char) : Integer;
function SioCTS(Port : Integer) : Integer;
function SioDCD(Port : Integer) : Integer;
function SioDelay(Tics : Integer) : Integer;
function SioDone(Port : Integer) : Integer;
function SioDSR(Port : Integer) : Integer;
function SioDTR(Port : Integer; Cmd : Char) : Integer;
function SioError(Code : Integer) : Integer;
function SioFIFO(Port, Code : Integer) : Integer;
function SioGetc(Port, Tics : Integer) : Integer;
function SioIRQ(Port, Code : Integer) : Integer;
function SioLine(Port : Integer) : Integer;
function SioLoopBack(Port : Integer) : Integer;
function SioModem(Port : Integer; Mask : Char) : Integer;
function SioParms(Port, ParityCode, StopBitsCode, WordLengthCode : Integer) : Integer;
function SioPutc(Port : Integer; Ch : Char) : Integer;
function SioReset(Port, BaudCode : Integer) : Integer;
function SioRI(Port : Integer) : Integer;
function SioRTS(Port : Integer; Cmd : Char ) : Integer;
function SioRxBuf(Port, BufferOfs, BufferSeg, SizeCode : Integer) : Integer;
function SioRxFlush(Port : Integer) : Integer;
function SioRxQue(Port : Integer) : Integer;
function SioTimer : LongInt;
function SioUART(Port, Address : Integer) : Integer;
function SioUnGetc(Port : Integer; Ch : Byte ) : Integer;


implementation

{$L PCL4PLIB}

function SioBaud ; external;
function SioBrkKey ; external;
function SioBrkSig ; external;
function SioCTS ; external;
function SioDCD ; external;
function SioDelay ; external;
function SioDone ; external;
function SioDSR ; external ;
function SioDTR ; external;
function SioError ; external;
function SioFIFO ; external;
function SioGetc ; external;
function SioIRQ ; external;
function SioLine ; external;
function SioLoopBack ; external;
function SioModem ; external;
function SioParms ; external;
function SioPutc ; external;
function SioReset ; external;
function SioRI ; external;
function SioRTS ; external;
function SioRxBuf ; external;
function SioRxFlush ; external;
function SioRxQue ; external;
function SioTimer ; external;
function SioUART ; external;
function SioUnGetc ; external;
end.