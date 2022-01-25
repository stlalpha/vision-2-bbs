{--------------------------------------------------------------------------}
{                         TechnoJock's Turbo Toolkit                       }
{                                                                          }
{                              Version   5.02                              }
{                                                                          }
{                                                                          }
{              Copyright 1986, 1989 TechnoJock Software, Inc.              }
{                           All Rights Reserved                            }
{                          Restricted by License                           }
{--------------------------------------------------------------------------}

                     {--------------------------------}                                       
                     {       Unit:  MiscTTT5          }
                     {--------------------------------}


{$S-,R-,V-}       
{$IFNDEF DEBUG}
{$D-}
{$ENDIF}

Unit MiscTTT5;
{Change History : April 1, 1989    Modified Printer Status and added global
                                   LPTport 
                           5.01a   Removed references to VER50 and added
                                   DEBUG compiler directive                                
}
Interface

Uses CRT, DOS, FastTTT5, Strnttt5;

TYPE
   Dates = word;   {change to longint for greater date ranges}

CONST
   MMDDYY   = 1;   {Date formats}
   MMDDYYYY = 2;
   MMYY     = 3;
   MMYYYY   = 4;
   DDMMYY   = 5;
   DDMMYYYY = 6;

VAR
   LPTport,     {0=lpt1, 1=lpt2, 2=lpt3}
   ClockX,
   ClockY,
   ClockF,
   ClockB : byte;

Function  Exist(Filename:string):boolean;
Function  CopyFile(SourceFile, TargetFile:string): byte;
Function  File_Size(Filename:string): longint;
{$IFNDEF VER40}
Function  File_Drive(Full:string): string;
Function  File_Directory(Full:string): string;
Function  File_Name(Full:string): string;
Function  File_Ext(Full:string): String;
{$ENDIF}
Function  Time: string;
Procedure Clock;
Function  Date: String;
Procedure PrintScreen;
Procedure Beep;
function  Printer_Status:byte;
Function  Alternate_Printer_Status:byte;
Function  Printer_ready:boolean;
Procedure FlushKeyBuffer;
Procedure Reset_Printer;
Function  DMY_to_String(D,M,Y:word;format:byte): string;
Function  Date_To_Julian(InDate:string;format:byte): dates;
Function  Julian_to_Date(J:dates;format:byte):string;
Function  Today_in_Julian: dates;
Function  Date_Within_Range(Min,Max,Test:dates):boolean;
Function  Valid_Date(Indate:string;format:byte): boolean;
Function  Future_Date(InDate:string;format:byte;Days:word): string;
Function  Unformatted_date(InDate:string): string;

Implementation

Const
    LastYearNextCentuary = 78;

Function Exist(Filename:string):boolean;
{returns true if file exists}
var Inf: SearchRec;
begin
    FindFirst(Filename,AnyFile,Inf);
    Exist := (DOSError = 0);
end;  {Func Exist}

Function CopyFile(SourceFile, TargetFile:string): byte;
{return codes:  0 successful
                1 source and target the same
                2 cannot open source
                3 unable to create target
                4 error during copy
}
var
  Source,
  Target : file;
  BRead,
  Bwrite : word;
  FileBuf  : array[1..2048] of char;
begin
    If SourceFile = TargetFile then
    begin
        CopyFile := 1;
        exit;
    end;
    Assign(Source,SourceFile);
    {$I-}
    Reset(Source,1);
    {$I+}
    If IOResult <> 0 then
    begin
        CopyFile := 2;
        exit;
    end;
    Assign(Target,TargetFile);
    {$I-}
    Rewrite(Target,1);
    {$I+}
    If IOResult <> 0 then
    begin
        CopyFile := 3;
        exit;
    end;
    Repeat
         BlockRead(Source,FileBuf,SizeOf(FileBuf),BRead);
         BlockWrite(Target,FileBuf,Bread,Bwrite);
    Until (Bread = 0) or (Bread <> BWrite);
    Close(Source);
    Close(Target);
    If Bread <> Bwrite then
       CopyFile := 4
    else
       CopyFile := 0;
end; {of func CopyFile}

 Function File_Size(Filename:string): longint;
 {returns  -1   if file not found}
 var
    F : file of byte;
 begin
     Assign(F,Filename);
     {$I-}
     Reset(F);
     {$I+}
     If IOResult <> 0 then
     begin
        File_Size := -1;
        exit;
     end;
     File_Size := FileSize(F);
     Close(F);
 end; {of func File_Size}

{$IFNDEF VER40}
 Function File_Split(Part:byte;Full:string): string;
 {used internally}
 var
    D : DirStr;
    N : NameStr;
    E : ExtStr;
 begin
     FSplit(Full,D,N,E);
     Case Part of
     1 : File_Split := D;
     2 : File_Split := N;
     3 : File_Split := E;
     end;
 end; {of func File_Split}

 Function File_Drive(Full:string): string;
 {}
 var
   Temp : string;
   P : byte;
 begin
     Temp := File_Split(1,Full);
     P := Pos(':',Temp);
     If P <> 2 then
        File_Drive := ''
     else
        File_Drive := upcase(Temp[1]);
 end; {of func File_Drive}

 Function File_Directory(Full:string): string;
 {}
 var
   Temp : string;
   P : byte;
 begin
     Temp := File_Split(1,Full);
     P := Pos(':',Temp);
     If P = 2 then
        Delete(Temp,1,2);                 {remove drive}
     If (Temp[length(Temp)]  ='\') and (temp <> '\') then
        Delete(temp,length(Temp),1);      {remove last backslash}
     File_Directory := Temp;
 end; {of func File_Directory}

 Function File_Name(Full:string): string;
 {}
 begin
     File_Name := File_Split(2,Full);
 end; {of func File_Name}

 Function File_Ext(Full:string): String;
 {}
 var
   Temp : string;
 begin
     Temp := File_Split(3,Full);
     If (Temp = '') or (Temp = '.') then
        File_Ext := temp
     else
        File_Ext := copy(Temp,2,3);
 end; {of func File_Ext}
{$ENDIF}
function time: string;
var
  hour,min,sec:     string[2];
  H,M,S,T : word;
begin
    GetTime(H,M,S,T);
    Str(H,Hour);
    Str(M,Min);
    Str(S,Sec);
    if S < 10 then            {pad a leading zero if sec is < 10 }
      sec := '0'+sec;
    if M < 10 then            {pad a leading zero if min is < 10 }
        min := '0'+min;
    if H > 12 then           { assign an a.m. or p.m. string }
    begin
       str(H - 12,hour);
       IF length(hour) = 1 then Hour := ' '+hour;
          time := hour+':'+min+':'+sec+' p.m.'
    end
    else
       time := hour+':'+min+':'+sec+' a.m.';
    if H = 12 then
       time := hour+':'+min+':'+sec+' p.m.';
end;

{$F+}
Procedure Clock;
{}
begin
    Fastwrite(ClockX,ClockY,attr(ClockF,ClockB),Time);
end; {of proc Clock}
{$F-}

function Date: String;
type
  WeekDays = array[0..6]  of string[9];
  Months   = array[1..12] of string[9];
const
    DayNames   : WeekDays  = ('Sunday','Monday','Tuesday','Wednesday',
                              'Thursday','Friday','Saturday');
    MonthNames : Months    = ('January','February','March','April','May',
                              'June','July','August','September',
                              'October','November','December');
var
 Y,
 M,
 D,
 DayOfWeek : word;
 Year   : string;
 Day    : string;
begin
    GetDate(Y,M,D,DayofWeek);
    Str(Y,Year);
    Str(D,Day);
    Date := DayNames[DayOfWeek]+' '+MonthNames[M]+' '+Day+', '+Year;
end;

Procedure PrintScreen;
var Regpack : registers;
begin
    intr($05,regpack);
end;

procedure Beep;
begin
    sound(800);Delay(150);
    sound(600);Delay(100);
    Nosound;
end;

Function Printer_Status:byte;
{Credits: Robert W. Lewis, VA thanks! Special masking employed for non-
          standard printers, e.g. daisy wheels!!! }
var Recpack : registers;
begin
    with recpack do
    begin
        Ah := 2;
        Dx := LPTport;
        intr($17,recpack);
        If (Ah and $B8) = $90 then
           Printer_Status := 0           {all's well}
        else
           If (Ah and $20) = $20 then
              Printer_Status := 1        {no Paper}
        else
           If (Ah and $10) = $00 then
              Printer_Status := 2        {off line}
        else
           If (Ah and $80) = $00 then
              Printer_Status := 3        {busy}
        else
           If (Ah and $08) = $08 then
              Printer_Status := 4;       {undetermined error}
    end;
end;

Function Alternate_Printer_Status:byte;
var Recpack : registers;
begin
    with recpack do
    begin
        Ah := 2;
        Dx := LPTport;
        intr($17,recpack);
        If (Ah and $20) = $20 then
              Alternate_Printer_Status := 1        {no Paper}
        else
           If (Ah and $10) = $00 then
              Alternate_Printer_Status := 2        {off line}
        else
           If (Ah and $80) = $00 then
              Alternate_Printer_Status := 3        {busy}
        else
           If (Ah and $08) = $08 then
              Alternate_Printer_Status := 4        {undetermined error}
        else
            Alternate_Printer_Status := 0           {all's well}
    end;
end;


function printer_ready :boolean;
begin
    Printer_ready := (Printer_Status = 0);
end;

Procedure FlushKeyBuffer;
var Recpack : registers;
begin
    with recpack do
    begin
        Ax := ($0c shl 8) or 6;
        Dx := $00ff;
    end;
    Intr($21,recpack);
end;

Procedure Reset_Printer;
var address: integer absolute $0040:$0008;
             portno,delay : integer;
begin
    portno := address + 2;
    port[portno] := 232;
    for delay := 1 to 2000 do {nothing};
    port[portno] := 236;
end;

{++++++++++++++++++++++++++++++++++}
{                                  }
{    D A T E    R O U T I N E S    }
{                                  }
{++++++++++++++++++++++++++++++++++}

(*
 Note that the Julian date logic applied in these routines is that day 1 is
 January 1, 1900. All subsequent dates are represented by the number of
 days elapsed since day 1. The INTERFACE section includes a declaration of
 type DATES - this is set equal to type word, but it could be changed to
 type longint to provide a much greater date range. 

 Throughout these procedures and functions a date "format" must be passed. The
 format codes are:

                  1  MM/DD/YY
                  2  MM/DD/YYYY
                  3  MM/YY
                  4  MM/YYYY
                  5  DD/MM/YY {International format}
                  6  DD/MM/YYYY   {   "    }

 When passing dates in string form the "separators" are not significant. For
 example, the following strings are all treated alike:

                     120188
                     12/01/88
                     12-01-88
                     12-01/88
                     12----01----88
 Only the numerical digits are significant, the alphas are ignored.

*)
  Function Nth_Number(InStr:string;Nth:byte) : char;
  {Returns the nth number in an alphanumeric string}
  var
     Counter : byte;
     B, Len : byte;
  begin
      Counter := 0;
      B := 0;
      Len := Length(InStr);
      Repeat
           Inc(B);
           If InStr[B] in ['0'..'9'] then
              Inc(Counter);
      Until (Counter = Nth) or (B >= Len);
      If (Counter >= Len) and ( (InStr[Len] in ['0'..'9']) = false) then
         Nth_Number := #0
      else
         Nth_Number := InStr[B];
  end; {of func Nth_Number}

 Function Day(DStr:string;Format:byte): word;
 {INTERNAL}
 var
    DayStr: string;
 begin
     Case Format of
     MMDDYY,
     MMDDYYYY :  DayStr := Nth_Number(DStr,3)+Nth_Number(DStr,4);
     DDMMYY,
     DDMMYYYY :  DayStr := Nth_Number(DStr,1)+Nth_Number(DStr,2);
     else     DayStr := '01';
     end;
     Day := Str_To_Int(DayStr);
 end; {of func Day}

 Function Month(DStr:string;Format:byte): word;
 {INTERNAL}
 var
    MonStr: string;
 begin
     Case Format of
     MMDDYY,
     MMDDYYYY,
     MMYY,
     MMYYYY    :  MonStr := Nth_Number(DStr,1)+Nth_Number(DStr,2);
     DDMMYY,
     DDMMYYYY  :  MonStr := Nth_Number(DStr,3)+Nth_Number(DStr,4);
     end;
     Month := Str_To_Int(MonStr);
 end; {of func Month}

 Function Year(DStr:string;Format:byte): word;
 {INTERNAL}
 var
    YrStr   : string;
    TmpYr   : word;
 begin
     Case Format of
     MMDDYY,
     DDMMYY   :  YrStr := Nth_Number(DStr,5)+Nth_Number(DStr,6);
     MMDDYYYY,
     DDMMYYYY :  YrStr := Nth_Number(DStr,5)+Nth_Number(DStr,6)+
                     Nth_Number(DStr,7)+Nth_Number(DStr,8);
     MMYY     :  YrStr := Nth_Number(DStr,3)+Nth_Number(DStr,4);
     MMYYYY   :  YrStr := Nth_Number(DStr,3)+Nth_Number(DStr,4)+
                     Nth_Number(DStr,5)+Nth_Number(DStr,6);
     end;
     TmpYr := Str_To_Int(YrStr);
     If TmpYr < LastYearNextCentuary then
        TmpYr := 2000 + TmpYr
     else
        If Tmpyr < 1000 then
           TmpYr := 1900 + TmpYr;
     Year := TmpYr;
 end; {of func Year}

 Function DMY_to_String(D,M,Y:word;format:byte): string;
 {INTERNAL}
 const
     PadChar = '/';
 var
    DD,MM,YY : string[4];
 begin
     DD := Int_to_Str(D);
     If D < 10 then
        DD := '0'+DD;
     MM := Int_to_Str(M);
     If M < 10 then
        MM := '0'+MM;
     If Format in [MMDDYY,MMYY,DDMMYY] then
     begin
         If Y > 99 then
            If Y > 2000 then
               Y := Y - 2000
            else
               If Y > 1900 then
                  Y := Y - 1900
               else
                  Y := Y Mod 100;
     end
     else
     begin
         If Y < 1900 then
            If Y < LastYearNextCentuary then
               Y := Y + 2000
            else
               Y := Y + 1900;
     end;
     YY := Int_to_Str(Y);
     If Y < 10 then
        YY := '0'+YY;
     Case Format of
     MMDDYY,
     MMDDYYYY: DMY_to_String := MM+PadChar+DD+Padchar+YY;
     MMYY,
     MMYYYY  : DMY_to_String := MM+Padchar+YY;
     DDMMYY,
     DDMMYYYY: DMY_to_String := DD+PadChar+MM+Padchar+YY;
     end; {case}
 end; {of func DMY_to_String}

 Function Date_To_Julian(InDate:string;format:byte): dates;
 {Does not check the date is valid. Passed a date string and
  returns a julian date}
 var
    D,M,Y :  word;
    Temp : dates;
 begin
     D := Day(Indate,format);
     M := Month(Indate,format);
     Y := Year(Indate,format);
     If  (Y=1900)
     and (M <= 2) then
     begin
         If M = 1 then
            Temp := pred(D)
         else
            Temp := D+30;
     end
     else
     begin
         If M > 2 then
            M := M - 3
         else
         begin
             M := M + 9;
             dec(Y);
         end;
         Y := Y - 1900;
         Temp := (1461*longint(Y) div 4) +
                 (153*M+2) div 5 +
                 D + 58;
     end;
     Date_to_Julian := Temp;
 end; {of func Date_To_Julian}

 Function Julian_to_Date(J:dates;format:byte):string;
 {}
 var
    D,M,Y : word;
    Remainder,Factored : longint;
 begin
     If J = 0 then
     begin
         Case Format of
         DDMMYY,MMDDYY :   Julian_to_date := '  /  /  ';
         DDMMYYYY,MMDDYYYY:Julian_to_date := '  /  /    ';
         MMYYYY:           Julian_to_Date := '  /    ';
         else              Julian_to_date := '  /  ';
         end;
         exit;
     end;
     If J <= 58 then
     begin
         Y := 1900;
         If J <= 30 then
         begin
             M := 1;
             D := succ(J);
         end
         else
         begin
             M := 2;
             D := J - 30;
         end;
     end
     else
     begin
         Factored := 4*LongInt(J) - 233;
         Y := Factored div 1461;
         Remainder := (Factored mod 1461 div 4 * 5) + 2;
         M := Remainder div 153;
         D := succ((Remainder mod 153) div 5);
         Y := Y + 1900;
         If M < 10 then
            M := M + 3
         else
         begin
             M := M - 9;
             Inc(Y);
         end;
     end;
     Julian_to_date := DMY_to_String(D,M,Y,format);
 end; {of proc Julian_to_Date}

 Function Date_Within_Range(Min,Max,Test:dates):boolean;
 {}
 begin
     Date_Within_Range := ((Test >= Min) and (Test <= Max));
 end; {of func Date_Within_Range}

 Function Valid_Date(Indate:string;format:byte): boolean;
 {}
 var
   D,M,Y : word;
   OK : Boolean;
 begin
     OK := true;  {positive thinking!}
     If format in [MMYY,MMYYYY] then
        D := 1
     else
        D := Day(Indate,format);
     M := Month(Indate,format);
     Y := Year(Indate,format);
     If (D < 1)
     or (D > 31)
     or (M < 1)
     or (M > 12)
     or ((Y > 99) and (Y < 1900))
     or (Y > 2078)
     then 
        OK := False
     else
        Case M of
        4,6,9,11:         OK :=   (D <= 30);
        2:                OK :=   (D <= 28)
                               or (
                                        (D = 29) 
                                    and (Y <> 1900) 
                                    and (Y <> 0)
                                    and (Y mod 4 = 0)
                                  )
        end; {case}
     Valid_Date := OK;
 end; {of func Valid_Date}

 Function Today_in_Julian: dates;
 {}
 var
 Y,
 M,
 D,
 DayOfWeek : word;
 Year   : string;
 Day    : string;
 begin
     GetDate(Y,M,D,DayofWeek);
     Today_in_Julian := Date_to_Julian(DMY_to_String(D,M,Y,1),1);
 end; {of func Today_in_Julian}

 Function Future_Date(InDate:string;format:byte;Days:word): string;
 {}
 var J : dates;
 begin
     Future_date := Julian_to_date(Date_to_Julian(InDate,Format)+Days,Format);
 end; {of func Future_Date}

 Function Unformatted_date(InDate:string): string;
 {strips all non numeric characters}
 var I : Integer;

           Function digit(C:char): boolean;
           {}
           begin
               Digit := C in ['0'..'9'];
           end; {of func digit}

 begin
     I := 1;
     Repeat
          If (digit(Indate[I]) = false) and (length(Indate) > 0) then
             Delete(Indate,I,1)
          else
             I := succ(I);
     Until (I > length(Indate)) or (Indate = '');
     Unformatted_Date := Indate;
 end; {of func Unformatted_date}


begin
    ClockX := 67;
    ClockY := 1;
    ClockF := white;
    ClockB := black;
    LPTport := 0;  {LPT1}
end.
