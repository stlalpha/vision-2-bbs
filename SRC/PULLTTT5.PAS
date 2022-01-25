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
		     {       Unit:  PullTTT5          }
		     {--------------------------------}


{$S-,R-,V-}
{$IFNDEF DEBUG}
{$D-}
{$ENDIF}
{Change History:    4/01/89   5.01   Added DOS errorlevel of 12 on fatal
				     error - line 186
			      5.01   Changed type def of Sub_Menu to
				     Max_Pull_Width - line 144
			      5.01   Changed error message 6  - line 180
			      5.01a  Removed references to VER50 and added
				     DEBUG compiler directive
               5.01b removed a '+' from string expression to enable compile
                     with Quick Pascal (!)
}
unit PullTTT5;

Interface

Uses CRT, DOS, FastTTT5, WinTTT5, KeyTTT5;

Const
    Max_Pull_Topics = 60;
    Max_Pull_Width  = 30;
type
    Pull_Array = array [1..Max_Pull_Topics] of string[Max_Pull_Width];
    {$IFNDEF VER40}
     Pull_Hook = Procedure(var Ch: char; Main, Sub :byte);
    {$ENDIF}
    MenuDisplay = record
		     TopX:byte;
		     TopY:byte;
		     Style:byte;
		     FCol: byte;       {normal option foreground color}
		     BCol: byte;       {normal option background color}
		     CCol: byte;       {color of first Character}
		     MBCol: byte;      {highlight bgnd col for main pick when sub-menu displayed}
		     HFCol: byte;      {highlighted option foreground}
		     HBCol: byte;      {highlighted option background}
		     BorCol: byte;     {border foreground color}
		     Gap   : byte;     {Gap between Picks}
		     LeftChar    : char;     {left-hand topic highlight character}
		     RightChar   : char;     {right-hand topic highlight character}
		     AllowEsc    : boolean; {is Escape key operative}
		     RemoveMenu  : boolean;{clear screen on exit}
		     AlwaysDown : boolean;
		     {$IFNDEF VER40}
		     Hook         : Pull_hook;
		     {$ENDIF}
		  end;
Const
    Max_MainPicks = 8;
    Max_Subpicks  = 15;
    MainInd = '\';           {symbol that indicates main menu description}

Var
  PTTT : MenuDisplay;

  {$IFDEF VER40}
  PM_UserHook : pointer;
  {$ENDIF}

{$IFNDEF VER40}
Procedure No_Hook(var Ch: char; Main, Sub :byte);
{$ENDIF}

Procedure Pull_Menu( Definition:Pull_Array; var PickM, PickS:byte);


Implementation

  {$IFNDEF VER40}
  {$F+}
  Procedure No_Hook(var Ch: char; Main, Sub :byte);
  {}
  begin
  end; {of proc No_Hook}
  {$F-}
  {$ENDIF}

   {$IFDEF VER40}
   Procedure CallFromPM(var Ch: char; Main, Sub :byte);
	  Inline($FF/$1E/PM_UserHook);
   {$ENDIF}

   Procedure Default_Settings;
   begin
       {$IFDEF VER40}
       PM_UserHook := nil;
       {$ENDIF}
       With PTTT do
       begin
	   {$IFNDEF VER40}
	   Hook := No_Hook;
	   {$ENDIF}
	   TopY := 1;
	   TopX := 1;
	   Style := 1;
	   Gap := 2;
	   LeftChar := #016;
	   RightChar := #017;
	   AllowEsc := true;
	   RemoveMenu := true;
	   AlwaysDown := true;
	   If BaseOfScreen = $b000 then {monochrome}
	   begin
	       FCol  := lightgray;
	       BCol  := black;
	       CCol  := white;
	       MBCol  := lightgray;
	       HFCol  := black;
	       HBCol  := lightgray;
	       BorCol := lightgray;
	   end
	   else                    {color}
	   begin
	       FCol  := yellow;
	       BCol  := blue;
	       CCol  := lightcyan;
	       MBCol  := red;
	       HFCol  := yellow;
	       HBCol  := red;
	       BorCol := cyan;
	   end;
      end;
  end; {Proc Default_Settings}


Procedure Pull_Menu(Definition: Pull_Array; var PickM, PickS:byte);
const
    CursUp = #200  ;  CursDown = #208  ;  CursLeft = #203  ;   CursRight = #205;
    HomeKey = #199 ;  Endkey   = #207  ;  Esc      = #027  ;   Enter     = #13;
    F1      = #187 ;

type
   Sub_details = record
		    Text:  Array[0..Max_SubPicks] of string[Max_Pull_Width];     {5.01}
		    Total: byte;
		    Width: byte;
		    LastPick: byte;
		 end;
var
  Submenu  : array [1..Max_MainPicks] of Sub_Details;
  Tot_main : byte;              {total number of main picks}
  Main_Wid : byte;              {width of main menu box}
  Finished,                     {has user selected menu option}
  Down     : boolean;           {indicates if sub-menu displayed}
  ChM,ChT      : char;          {keypressed character}
  X1, Y1, X2, Y2 : byte;        {lower menu borders}
  Cap,Count      : byte;        {used to check if letter pressed = first char}
  Saved_Screen : Pointer;
  I                 : integer;
  TLchar,           {border submenu upper left char}
  TRchar,           {border submenu upper right char}
  BLchar,           {border submenu bottom left char}
  BRchar,           {border submenu bottom right char}
  Joinchar,         {border joining character}
  Joindownchar,     {border joining character}
  JoinleftChar,     {border joining character}
  VertChar,         {border vert character}
  Horizchar:char;   {border horiz char}


    Procedure PullError(No : byte);
    var M : string;
    begin
	Case No of
	1 : M := 'Menu definiton must start with a Main ("\") description';
	2 : M := 'Main menu definition must be at least 1 character';
	3 : M := 'Too many main menu picks.';
	4 : M := 'Too many sub-menu picks.';
	5 : M := 'No end of menu indicator found';
	6 : M := 'Must be at least two main menu picks';   {5.01}
	7 : M := 'Main menu will not fit in 80 characters';
	8 : M := 'No memory to save screen';
	end; {case}
	Writeln;
	Writeln(M);
	Halt(12);           {5.01}
    end; {Abort}

    Procedure Set_Style;
    {Sets variables for the box characters based on defined style}
    begin
	Case PTTT.Style of
	1  :  begin
		  TLchar := #218;
		  TRchar := #191;
		  BLchar := #192;
		  BRchar := #217;
		  Joinchar := #194;
		  Joindownchar := #193;
		  JoinleftChar := #180;
		  VertChar := #179;
		  Horizchar := #196;
	      end;
	2  :  begin
		  TLchar := #219; {201}
		  TRchar := #219; {187}
		  BLchar := #219; {200}
		  BRchar := #219; {188}
		  Joinchar := #203;
		  Joindownchar := #202;
		  JoinleftChar := #185;
		  VertChar := #219;    {186}
		  Horizchar := #220;   {205}
	      end;
	else
	     begin
		  TLchar := ' ';
		  TRchar := ' ';
		  BLchar := ' ';
		  BRchar := ' ';
		  Joinchar := ' ';
		  Joindownchar := ' ';
		  JoinleftChar := ' ';
		  VertChar := ' ';
		  Horizchar := ' ';
	      end;
	end; {Case}
    end;  {Proc Set_Style}

    Procedure Save_Screen;
    {saved part of screen overlayed by menu}
    begin
	If MaxAvail < DisplayLines*160 then
	   PullError(8)
	else
	begin
	    GetMem(Saved_Screen,DisplayLines*160);
	    PartSave(1,1,80,DisplayLines,Saved_Screen^);
	end;
    end; {of proc Save_Screen}

    Procedure PartRestoreScreen(X1,Y1,X2,Y2:byte);
    {Move from heap to screen, part of saved screen}
    Var
       I,width     : byte;
       ScreenAdr   : integer;
    begin
	Width := succ(X2- X1);
	For I :=  Y1 to Y2 do
	begin
	    ScreenAdr   := Pred(I)*160 + Pred(X1)*2;
	    MoveToScreen(Mem[Seg(Saved_Screen^):ofs(Saved_Screen^)+SCreenAdr],
			 Mem[BaseOfScreen:ScreenAdr],
			 width);
	end;
    end;

      Procedure Restore_Screen;
      {saved part of screen overlayed by menu}
      begin
	  PartRestore(1,1,80,DisplayLines,Saved_Screen^);
      end;

      Procedure Dispose_Screen;
      {}
      begin
	  FreeMem(Saved_Screen,DisplayLines*160);
      end;

    Procedure Load_Menu_Parameters;
    { converts the MenuDesc array into the Sub_menu array, and
      determines Tot_main
    }
    var
      I, Maj, Min, Widest : integer;
      Instr : string[30];
      Finished : Boolean;
    begin
	FillChar(Submenu,sizeof(Submenu),#0);
	Tot_main := 0;
	If Definition[1][1] <> '\' then PullError(1);
	Maj := 0;
	Widest := 0;
	I := 0;
	Finished := false;
	While (I < Max_Pull_Topics) and (Finished=false) do
	begin
	    Inc(I);
	    If Definition[I] <> '' then
	    begin
		Instr := Definition[I];
		If Instr[1] = MainInd then
		begin
		    If Maj <> 0 then           {update values for last sub menu}
		    begin
			SubMenu[Maj].Total := Min;
			SubMenu[Maj].Width := widest;
		    end;
		    If length(Instr) < 2 then PullError(2);
		    If Instr = Mainind + mainind then   {must have loaded all data}
		    begin                               {note number of main menu }
			Tot_main := Maj;                   {picks and exit}
			Finished := true;
		    end;
		    Maj := succ(Maj);
		    If Maj > Max_mainpicks then PullError(3);
		    delete(Instr,1,1);
		    SubMenu[Maj].text[0] := Instr;
		    Min := 0;                      {reset values for next sub heading}
		    Widest := 0;
		end
		else         {not a main menu heading}
		begin
		    Min := succ(Min);
		    If Min > Max_SubPicks then PullError(4);
		    SubMenu[Maj].text[Min] := Instr;
		    If length(Instr) > widest then
		       widest := length(Instr);
		end;   {if main heading}
	    end;
	end; {while}
	If Tot_main = 0 then PullError(5);
	If Tot_main < 2 then PullError(6);
   end; {sub-proc Load_Menu_Parameters}

   Function First_Capital(InStr:string; Var StrPos:byte):char;
   {returns the first capital letter in a string and Character position}
   begin
       StrPos := 1;
       While (StrPos <= length(InStr))  and ((InStr[StrPos] in [#65..#90]) = false) do
	      StrPos := Succ(StrPos);
       If StrPos > length(InStr) then
       begin
	   StrPos := 0;
	   First_Capital := ' ';
       end
       else
	  First_Capital := InStr[StrPos];
   end;   {First_Capital}

   Procedure Display_Main_Picks(No : byte; Col : byte);
   { displays main heading for menu pick 'No', if Col = 1 then
     PTTT.HFCol and PTTT.MBCol cols are used without arrows, else PTTT.FCol and PTTT.BCol
     colors are used}
   var
     ChT : Char;
     X, I, B : byte;
   begin
       X := 1;
       If No = 1 then
	  X := X + PTTT.TopX + PTTT.Gap
       else
       begin
	   For I := 1 to No - 1 do
	       X := X + length(Submenu[I].Text[0]) + PTTT.Gap;
	   X := X + PTTT.TopX  + PTTT.Gap ;
       end;
       If Col > 0 then
	  Fastwrite(X,PTTT.TopY+ord(PTTT.Style>0),attr(PTTT.HFCol,PTTT.MBCol),
		    Submenu[No].Text[0])
       else
       begin
	   Fastwrite(X,PTTT.TopY+ord(PTTT.Style>0),attr(PTTT.FCol,PTTT.BCol),
		     Submenu[No].Text[0]);
	   ChT := First_Capital(Submenu[No].Text[0],B);
	   If B <> 0 then
	      FastWrite(pred(X)+B,PTTT.TopY+ord(PTTT.Style>0),
			attr(PTTT.CCol,PTTT.BCol),ChT);
       end;
       GotoXY(X,PTTT.TopY+Ord(PTTT.Style>0));
   end; {Display Main Header}

   Procedure Display_Main_Menu;
   {draws boxes, main menu picks and draws border}
   var I : byte;
   begin
       {draw the box}
       Main_Wid := succ(PTTT.Gap) ;           {determine the width of the main menu}
       For I := 1 to Tot_Main do
	   Main_Wid := Main_Wid + PTTT.Gap + length(Submenu[I].text[0]);
       If Main_Wid + PTTT.TopX - 1 > 80 then PullError(7);
       If PTTT.Style = 0 then
	  ClearText(PTTT.TopX,PTTT.TopY,PTTT.TopX + Main_Wid,PTTT.TopY,PTTT.BorCol,PTTT.BCol)
       else
	  Fbox(PTTT.TopX,PTTT.TopY,PTTT.TopX + Main_Wid,PTTT.TopY + 2,PTTT.BorCol,PTTT.BCol,PTTT.Style);
       For I := 1 to ToT_Main do
	   Display_Main_Picks(I,0);
       Display_Main_Picks(PickM,1);
   end;  {Display_Main_Menu}

   Procedure Remove_Sub_Menu;
   var a : integer;
   begin
       Fastwrite(X1,PTTT.TopY+2,attr(PTTT.BorCol,PTTT.BCol),horizchar);
       Fastwrite(X2,PTTT.TopY+2,attr(PTTT.BorCol,PTTT.BCol),horizchar);
       PartRestoreSCreen(PTTT.TopX, succ(PTTT.TopY)+2*ord(PTTT.Style>0), 80, DisplayLines);
       If (PTTT.Style > 0 ) and (X2 >= PTTT.TopX + Main_wid) then
       begin
	   A := PTTT.TopX +Main_Wid + 1;
	   PartRestoreScreen(A, PTTT.TopY + 2, 80, PTTT.TopY + 2);
	   Fastwrite(A - 1, PTTT.TopY+2, attr(PTTT.BorCol,PTTT.BCol),BRchar);
       end;
       SubMenu[PickM].LastPick := PickS;
   end;

   Procedure Display_Sub_Picks(No : byte; Col : byte);
   { displays sub  menu pick 'No', if Col = 1 then
     PTTT.HFCol and PTTT.HBCol cols are used and arrows, else PTTT.FCol and PTTT.BCol
     colors are used}
   var
     ChT : Char;
     B : Byte;
   begin
       If Col = 1 then
	  Fastwrite(X1 + 1, succ(PTTT.TopY)+ord(PTTT.Style>0) + No ,
		    attr(PTTT.HFCol,PTTT.HBCol),
		    PTTT.LeftChar + Submenu[PickM].Text[No] + PTTT.Rightchar)
       else
       begin
	  Fastwrite(X1 + 1, succ(PTTT.TopY)+Ord(PTTT.Style>0) + No ,
		    attr(PTTT.FCol,PTTT.BCol),
		    ' '+Submenu[PickM].Text[No]+' ');
	  ChT := First_Capital(SubMenu[PickM].Text[No],B);
	  If B <> 0 then
	     FastWrite(X1+1+B,succ(PTTT.TopY)+Ord(PTTT.Style>0) + No ,
		       attr(PTTT.CCol,PTTT.BCol),ChT);
       end;
       GotoXY(X1+1,succ(PTTT.TopY)+ord(PTTT.Style>0)+ No);
   end;


   Procedure Display_Sub_Menu(No :byte);
   var
     BotLine : string;
     I : byte;
   begin
       If (Submenu[pickM].Total = 0) then
	   exit
       else
	   Down := true;
       X1 := pred(PTTT.TopX);                    {determine box coords of sub menu}
       If No <> 1 then
       begin
	   For I := 1 to pred(No) do
	       X1 := X1 + PTTT.Gap + length(Submenu[I].text[0]);
	   X1 := pred(X1) + PTTT.Gap ;
       end
       else
	  X1 := X1 + 2;
       X2 := X1 + Submenu[No].width + 3;
       If X2 > 80 then
       begin
	   X1 := 80 - (X2 - X1) ;
	   X2 := 80;
       end;
       Y1 := succ(PTTT.TopY) + ord(PTTT.Style>0);
       Y2 := Y1 + 1 + Submenu[No].total;
       Fbox(X1,Y1,X2,Y2,PTTT.BorCol,PTTT.BCol,PTTT.Style);
       Fastwrite(X1,succ(PTTT.TopY)+ord(PTTT.Style>0),attr(PTTT.BorCol,PTTT.BCol),Joinchar);
       If X2 < PTTT.TopX + Main_wid then
	  Fastwrite(X2,succ(PTTT.TopY)+ord(PTTT.Style>0),attr(PTTT.BorCol,PTTT.BCol),Joinchar)
       else
       If X2 = PTTT.TopX + Main_wid then
	  Fastwrite(X2,succ(PTTT.TopY)+ord(PTTT.Style>0),attr(PTTT.BorCol,PTTT.BCol),Joinleftchar)
       else
       begin
	   Fastwrite(X2,PTTT.TopY+2,attr(PTTT.BorCol,PTTT.BCol),TRchar);
	   Fastwrite(PTTT.TopX+Main_wid,succ(PTTT.TopY)+ord(PTTT.Style>0),attr(PTTT.BorCol,PTTT.BCol),Joindownchar);
       end;
       For I := 1 to Submenu[PickM].total do
	   Display_Sub_Picks(I,2);
       PickS := SubMenu[PickM].LastPick;
       If not (PickS in [1..Submenu[PickM].Total]) then
	  PickS := 1;
       Display_Sub_Picks(PickS,1);
   end;  {proc Display_Sub_Menu}

begin     {Main Procedure Display_menu}
    Set_Style;
    Load_Menu_Parameters;
    Save_Screen;
    Finished := false;
    If (PickM < 1) then
       PickM := 1;
    Display_Main_Menu;
    For I := 1 to Tot_main do
	Submenu[I].lastPick := 1;
    SubMenu[PickM].LastPick := PickS;
    If PickS <> 0 then
    begin
	Display_Sub_Menu(PickM);
	Down := true;
    end
    else
	Down := false;
    Repeat
	  ChM := GetKey;
	  {$IFDEF VER40}
	  If PM_UserHook <> nil then
	     If Down then
		CallFromPM(ChM,PickM,PickS)
	     else
		CallFromPM(ChM,PickM,0);
	  {$ENDIF}
	  {$IFNDEF VER40}
	     If Down then
		PTTT.Hook(ChM,PickM,PickS)
	     else
		PTTT.Hook(ChM,PickM,0);
	  {$ENDIF}
	  Case upcase(ChM) of
	  'A'..'Z'   : If down then    {check if letter is first letter of menu option}
		       begin
			   Count := 0;
			   Repeat
				Count := succ(count);
				ChT := First_Capital(Submenu[PickM].Text[count],Cap);
				If ChT  = upcase(ChM) then
				begin
				    Finished := true;
				    Display_Sub_Picks(PickS,0);
				    PickS := Count;
				    Display_Sub_Picks(PickS,1);
				end;
			   Until (Finished) or (count = submenu[PickM].Total);
		       end
		       else      {down false}
		       begin
			   Count := 0;
			   Repeat
				Count := succ(count);
				ChT := First_Capital(Submenu[Count].Text[0],Cap);
				If ChT = upcase(ChM) then
				begin
				    Display_Main_Picks(PickM,0);
				    PickM := Count;
				    Down := true;
				    Display_Main_Picks(PickM,2);
				    If not (PickS in [1..Submenu[PickM].Total]) then
				       PickS := 1;
				    Display_Sub_Menu(PickM);
				end;
			   Until (Down) or (count = Tot_Main);
		       end;
	  #133,          {Mouse Enter}
	  Enter      : If Down or (Submenu[PickM].Total = 0) then
		       begin
			  Finished := true;
			  If Submenu[PickM].Total = 0 then PickS := 0;
		       end
		       else
		       begin
			   Down := true;
			   Display_Main_Picks(PickM,2);
			   Display_Sub_Menu(PickM);
		       end;
	  #132,        {Mouse Esc}
	  Esc       :  EXIT; {If Down then
		       begin
			   IF not PTTT.AlwaysDown then
			   begin
			       Down := false;
			       Remove_sub_menu;
			       Display_Main_menu;
			   end
			   else
			   begin
			      If PTTT.AllowEsc then
			      begin
				  Finished := true;
				  PickM := 0;
			      end;
			   end;
		       end
		       else
			   If PTTT.AllowEsc then
			   begin
			       Finished := true;
			       PickM := 0;
			   end;}
	  #0        :      begin
			   end;
	  #131      :  If PickM < ToT_main then
		       begin
			   Display_main_picks(PickM,0);  {clear highlight}
			   If Down then
			      Remove_Sub_Menu;
			   PickM := succ(PickM);
			   Display_Main_Picks(PickM,1);
			   If down then
			      Display_Sub_Menu(PickM);
		       end;
	  CursRight :  begin
			   Display_main_picks(PickM,0);  {clear highlight}
			   If Down then
			      Remove_Sub_Menu;
			   If PickM < ToT_main then
			      PickM := PickM + 1
			   else
			      PickM := 1;
			   Display_Main_Picks(PickM,1);
			   If down then
			       Display_Sub_Menu(PickM);
		       end;
	  #130      :  If PickM > 1 then    {MouseLeft}
		       begin
			   Display_main_picks(PickM,0);  {clear highlight}
			   If Down then
			      Remove_Sub_Menu;
			   PickM := pred(PickM);
			   Display_Main_Picks(PickM,1);
			   If down then
			       Display_Sub_Menu(PickM);
		       end;

	  CursLeft  :  begin
			   Display_main_picks(PickM,0);  {clear highlight}
			   If Down then
			      Remove_Sub_Menu;
			   If PickM > 1 then
			      PickM := pred(PickM)
			   else
			      PickM := Tot_Main;
			   Display_Main_Picks(PickM,1);
			   If down then
			       Display_Sub_Menu(PickM);
		       end;
	  #129       : If (Submenu[PickM].Total <> 0) then
		       begin
			   If Not Down then    {Mouse Down}
			   begin
			       Down := true;
			       Display_Main_Picks(PickM,2);
			       Display_Sub_Menu(PickM);
			   end
			   else
			      If PickS < Submenu[PickM].Total then
			      begin
				  Display_Sub_Picks(PickS,0);
				  PickS := succ(PickS);
				  Display_Sub_Picks(PickS,1);
			      end;
		       end;
	  CursDown   : If (Submenu[PickM].Total <> 0) then
		       begin
			   If Not Down then
			   begin
			       Down := true;
			       Display_Main_Picks(PickM,2);
			       Display_Sub_Menu(PickM);
			   end
			   else
			   begin
			       Display_Sub_Picks(PickS,0);
			       If PickS < Submenu[PickM].Total then
				  PickS := succ(PickS)
			       else
				  PickS := 1;
			       Display_Sub_Picks(PickS,1);
			   end;
		       end;
	  #128       : If down and (Picks > 1) and (Submenu[PickM].Total <> 0) then  {fix 4.01}
		       begin
			   Display_Sub_Picks(PickS,0);
			   PickS := pred(PickS);
			   Display_Sub_Picks(PickS,1);
		       end;
	  CursUp     : If (Submenu[PickM].Total <> 0) then
		       begin
			   If down then
			   begin
			       Display_Sub_Picks(PickS,0);
			       If PickS <> 1  then
				  PickS := pred(PickS)
			       else
				  PickS := Submenu[PickM].Total;
			       Display_Sub_Picks(PickS,1);
			   end;
		       end;
	  EndKey    :  If (Submenu[PickM].Total <> 0) then
		       begin
			   If Down then
			   begin
			       Display_Sub_Picks(PickS,0);
			       PickS := Submenu[PickM].Total;
			       Display_Sub_Picks(PickS,1);
			   end
			   else
			   begin
			       Display_main_picks(PickM,0);  {clear highlight}
			       PickM := ToT_Main;
			       Display_main_picks(PickM,1);
			   end;
		       end
		       else
		       begin
			   Display_main_picks(PickM,0);  {clear highlight}
			   PickM := ToT_Main;
			   Display_main_picks(PickM,1);
			   If Down then
			   begin
			       Display_Main_Picks(PickM,2);
			       Display_Sub_Menu(PickM);
			   end;
		       end;
	  HomeKey   :  If (Submenu[PickM].Total <> 0) then
		       begin
			   If Down then
			   begin
			       Display_Sub_Picks(PickS,0);
			       PickS := 1;
			       Display_Sub_Picks(PickS,1);
			   end
			   else
			   begin
			       Display_main_picks(PickM,0);  {clear highlight}
			       PickM := 1;
			       Display_main_picks(PickM,1);
			   end;
		       end
		       else
		       begin
			   Display_main_picks(PickM,0);  {clear highlight}
			   PickM := 1;
			   Display_main_picks(PickM,1);
			   If Down then
			   begin
			       Display_Main_Picks(PickM,2);
			       Display_Sub_Menu(PickM);
			   end;
		       end;
	  end; {endcase}
 Until Finished;
 If PTTT.RemoveMenu Then
    Restore_Screen;
 Dispose_Screen;
 end;  {end of main procedure Display_Menu}

begin
    Horiz_Sensitivity := 4;   {cursors left and right before mouse returns}
    Default_Settings;
end.
