{$i prodef.inc}

unit dispedit;

{$v-}

interface
   uses dos, crt, tools;

   type
      charset        = string[128];

      edit_functions = (display, edit, clear);

      border_styles  = (blank_border,          single_border,
                        double_border,         mixed_border,
                        taildouble_border,
                        solid_border,          evensolid_border,
                        thinsolid_border,      lohatch_border,
                        medhatch_border,       hihatch_border);

      display_image_type = array[1..2000] of record
         chr:  char;
         attr: byte;
      end;

      display_image_rec = record
         crt:  display_image_type;
         mode: word;
         attr: byte;
         wmin: word;
         wmax: word;
         x,y:  byte;
      end;

   var
      disp_mem:   ^display_image_type;


   const
      allchars:   charset = ' !"#$%&''()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\]^_`abcdefghijklmnopqrstuvwxyz{|}~';
      namechars:  charset = '!#$%&''()+-.0123456789:@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\]^_{}~';
      insert_mode:boolean = false;

      YES         = 'Y';      NO          = 'N';
      BACKSPACE   = #8;       TAB         = #9;
      NEWLINE     = #13;      ESC         = #27;
      F1          = #201;     F2          = #202;
      F3          = #203;     F4          = #204;
      F5          = #205;     F6          = #206;
      F7          = #207;     F8          = #208;
      F9          = #209;     F10         = #210;
      HOME        = #213;     UP          = #214;
      PGUP        = #215;     LEFT        = #217;
      RIGHT       = #219;     ENDK        = #221;
      DOWN        = #222;     PGDN        = #223;
      INS         = #224;     DEL         = #225;
      CTRL_F1     = #236;     CTRL_F2     = #237;
      CTRL_F3     = #238;     CTRL_F9     = #244;
      CTRL_F10    = #245;     CTRL_PGUP   = #18;
      CTRL_PGDN   = #4;       CTRL_LEFT   = #1;
      CTRL_RIGHT  = #2;       CTRL_HOME   = #5;
      CTRL_END    = #3;       SHIFT_TAB   = #157;
      ALT_D       = #174;     ALT_I       = #165;
      ALT_H       = #177;

      data_changed: boolean = false;

      py: integer = -1;
      px: integer = -1;

      traceopen: boolean = false;
      normcolor: byte = 15;
      incolor:   byte = 31;
      pcolor:    byte = 9;
      def_fill:  char = '°';

   var
      tracefd: text;


   procedure disp(s: string);
   procedure displn(s: string);
   procedure dispnl;

   function make_string(ch: char; size: byte): string;

   procedure display_border(topx,topy,
                            botx,boty: integer;
                            style:     border_styles);

   procedure beep;

   function get_key: char;

   procedure raw_editor( func:       edit_functions;
                         x,y:        integer;
                         prompt:     string;
                         var data:   string;
                         width:      integer;
                         var term:   char;
                         upper:      boolean;
                         legal:      charset;
                         tightexit:  boolean );

   procedure edit_string ( func:      edit_functions;
                           x,y:       integer;
                           prompt:    string;
                           var data:  string;
                           width:     integer;
                           var term:  char );

   procedure edit_fname ( func:      edit_functions;
                          x,y:       integer;
                          prompt:    string;
                          var data:  string;
                          width:     integer;
                          isdir:     boolean;
                          var term:  char );

   procedure edit_chars  ( func:      edit_functions;
                           x,y:       integer;
                           prompt:    string;
                           var data;
                           width:     integer;
                           var term:  char );

   procedure edit_integer( func:     edit_functions;
                           x,y:      integer;
                           prompt:   string;
                           var data: integer;
                           width:    integer;
                           min,max:  integer;
                           var term: char );

   procedure edit_byte   ( func:     edit_functions;
                           x,y:      integer;
                           prompt:   string;
                           var data: byte;
                           width:    integer;
                           min,max:  byte;
                           var term: char );

   procedure edit_word   ( func:     edit_functions;
                           x,y:      integer;
                           prompt:   string;
                           var data: word;
                           width:    integer;
                           min,max:  word;
                           var term: char );

   procedure edit_long( func:     edit_functions;
                        x,y:      integer;
                        prompt:   string;
                        var data: longint;
                        width:    integer;
                        min,max:  longint;
                        var term: char );

   procedure edit_real   ( func:     edit_functions;
                           x,y:      integer;
                           prompt:   string;
                           var data: real;
                           width:    integer;
                           deci:     integer;
                           var term: char );

   procedure edit_yesno(   func:      edit_functions;
                           x,y:       integer;
                           prompt:    string;
                           var data:  boolean;
                           var term:  char );

   procedure edit_baud( func     : edit_functions;
                        x,y      : integer;
                        prompt   : string;
                        var baud : word;
                        var term : char );

   procedure edit_funkey( func:      edit_functions;
                          x,y:       integer;
                          prompt:    string;
                          key:       char;
                          var term:  char );

   procedure select_next_entry( func:    edit_functions;
                                var en:  integer;
                                maxen:   integer;
                                var key: char);

   procedure clear_screen;

   procedure vscroll_bar(current, min, max: word;
                         x,y1,y2: byte);

   procedure hscroll_bar(current, min, max: word;
                         y,x1,x2: byte);

   procedure opentrace(name: string);
   procedure closetrace;

   procedure input(var line:  string;
                   maxlen:    integer);

   procedure save_display(var disp: display_image_rec);
   procedure restore_display(var disp: display_image_rec);
   procedure shadow_display;


implementation


   (* -------------------------------------------------- *)
   procedure disp(s: string);
   begin
      write(s);
    {  if traceopen then
         write(tracefd,s); }
   end;

   procedure dispnl;
   begin
      disp(^M^J);
   end;

   procedure displn(s: string);
   begin
      disp(s);
      dispnl;
   end;


   (* -------------------------------------------------- *)
   function make_string(ch: char; size: byte): string;
   var
      st: string;
   begin
      fillchar(st[1],size,ch);
      st[0] := chr(size);
      make_string := st;
   end;


   (* -------------------------------------------------- *)
   procedure display_border(topx,topy,
                            botx,boty: integer;
                            style:     border_styles);
      (* display a window border.  enter with desired color settingx*)
   var
      left:        string[80];
      right:       string[80];
      top:         string[80];
      bottom:      string[80];
      width:       integer;
      b:           string[8];
      i,j:         integer;

   const
     border_table:  array[blank_border..hihatch_border] of string[8] =
       ('        ',  { blank     }         'ÚÄ¿³³ÀÄÙ',  { single    }
        'ÉÍ»ººÈÍ¼',  { double    }         'ÕÍ¸³³ÔÍ¾',  { mixed     }
        'ÌÍ»ººÈÍ¼',  { taildouble}
        'ÛÛÛÛÛÛÛÛ',  { solid     }         'ÛßÛÛÛÛÜÛ',  { evensolid }
        'ÞßÝÞÝÞÜÝ',  { thinsolid }         '°°°°°°°°',  { lohatch   }
        '±±±±±±±±',  { medhatch  }         '²²²²²²²²'); { hihatch   }

      topleft  = 1;    {border character locations in border strings}
      tophor   = 2;
      topright = 3;
      leftver  = 4;
      rightver = 5;
      botleft  = 6;
      bothor   = 7;
      botright = 8;

      filler = ^@^H^J^@^H^J^@^H^J^@^H^J^@^H^J^@^H^J^@^H^J^@^H^J^@^H^J^@^H^J^@^H^J^@^H^J^@^H^J;

   begin
      b := border_table[style];
      width := botx - topx - 2;

   (* top and bottom of frame *)
      bottom[0]    := chr(width+2);
      top[0]       := chr(width+2);
      top[1]       := b[topleft];
      for i := 2 to width+1 do
         top[i] := b[tophor];
      top[width+2] := b[topright];

      bottom[0]       := chr(width+2);
      bottom[1]       := b[botleft];
      for i := 2 to width+1 do
         bottom[i] := b[bothor];
      bottom[width+2] := b[botright];


   (* sides of frame *)
      left := filler + filler;
      right := left;
      j := 1;
      for i := 2 to boty - topy do
      begin
         left[j]:= b[leftver];
         right[j]:= b[rightver];
         j := j + 3;
      end;
      left[0]:= chr (j - 1);
      right[0]:= left[0];

   (* draw the frame *)
      gotoxy(topx,topy);     disp(top);
      gotoxy(topx,topy+1);   disp(left);
      gotoxy(botx-1,topy+1); disp(right);
      gotoxy(topx,boty);     disp(bottom);
   end;


   (* -------------------------------------------------- *)
   procedure beep;
   var x : word;
   begin
     for x := 4200 to 4500
       do sound(x);
     nosound;
   end;

   (* -------------------------------------------------- *)
   function get_key: char;
   var
      c: char;
   begin
      c := readkey;
      if c = #0 then
         c := chr(ord(readkey) + 142);
      get_key := c;
   end;

   (* --------------------------------------------------- *)

   Procedure Cursor_Normal;
   Begin
     ASM
       MOV Ah,1h
       MOV Ch,6h
       MOV Cl,7h
       INT 10h
     END
   End;

   (* -------------------------------------------------- *)

   Procedure Cursor_Big;
   Begin
     ASM
       MOV Ah,1h
       MOV Ch,6h
       MOV Cl,1h
       INT 10h
     END
   End;

   (* -------------------------------------------------- *)
   procedure raw_editor( func:       edit_functions;
                         x,y:        integer;
                         prompt:     string;
                         var data:   string;
                         width:      integer;
                         var term:   char;
                         upper:      boolean;
                         legal:      charset;
                         tightexit:  boolean );
   var
      col:        integer;
      ch:         char;
      filler:     string;
      fillch:     char;
      typelame:   string[1];
      anything_goes:boolean;

      procedure update_cursor;
      begin
        if insert_mode
          then cursor_big
          else cursor_normal;
      end;

   begin

      anything_goes := length(legal) = 0;

      if length(data) > width then
         data[0] := chr(width);
      if upper then
         stoupper(data);

      update_cursor;

      case func of
         display:
            fillch := ' ';
         edit:
            fillch := def_fill;
         clear:
            begin
               fillch := ' ';
               data := '';
            end;
      end;

      filler := make_string( fillch, width - length(data) );

      textattr := pcolor;
      gotoxy( x, y );
      disp( prompt );

      If Func <> edit
        then textattr := normcolor
        else textattr := incolor;

      disp( copy( data, 1, width ) );

      if func <> edit then
         TextAttr := normcolor
         Else TextAttr := incolor;
      disp( filler );

   (* edit field contents only on edit calls *)

      if ( func <> edit ) then
         exit;

   (* general edit string function *)

      inc(x,length(prompt));
      col := 0;
      term := '0';

      Repeat
         TextAttr := incolor;
         GotoXY( X + Col, Y );
         ch := get_key;

         Case CH Of
            HOME: col := 0;

            ENDK: col := length(data);

            LEFT: if col > 0 then
                     dec(col)
                  else if not tightexit then
                     term := UP;

            RIGHT:
                  if col < length(data) then
                     inc(col)
                  else if not tightexit then
                     term := DOWN;

            DEL:  if col < length( data ) then
                  begin
                     delete( data, col + 1, 1 );
                     disp( copy( data, col + 1, width )+ fillch );
                     data_changed := true;
                  end;

            INS:  begin
                     insert_mode := not insert_mode;
                     update_cursor;
                  end;

            BACKSPACE:
                  if col > 0 then
                  begin
                     delete( data, col, 1 );
                     disp( ^H + copy( data, col, width )+ fillch );
                     dec(col);
                     data_changed := true;
                  end
                  else
                     beep;

            NewLine, ESC, ALT_H : Term := Ch;

            F1..F10, ESC,
            ALT_D, ALT_I,
            NEWLINE, UP, DOWN,
            PGUP, PGDN,
            CTRL_PGUP, CTRL_PGDN,
            CTRL_HOME, CTRL_END : If Not TightExit Then Term := Ch;

            else  begin
                     if upper then
                        ch := upcase(ch);

                     if (pos(ch,legal) > 0) or (anything_goes) then
                     begin

                        if col < width then
                        begin

                           if not insert_mode then begin
                             inc(col);
                             if col > length( data ) then
                                data := data + ch
                             else
                                data[ col ] := ch;
                             disp( ch );
                           end
                           else if length( data ) < width
                           then begin

                             inc(col);
                             if (col + 1) > length( data ) then begin
                               data := data + ch;
                               disp( ch );
                             end else begin
                               insert(ch,data,col);
                               disp(Copy(data,col,width));
                             end
                           end;

                           data_changed := true;
                        end
                        else
                           beep;
                     end
                  end;
         end;

      until term <> '0';
      cursor_normal;
      textattr := normcolor;
      gotoxy( x, y );
      disp( data );
      disp( make_string( ' ', width-length(data) ) );
   end;


   (* -------------------------------------------------- *)
   procedure edit_string( func:      edit_functions;
                          x,y:       integer;
                          prompt:    string;
                          var data:  string;
                          width:     integer;
                          var term:  char );
   begin
      raw_editor( func, x, y, prompt, data, width, term, false, '',false);
   end;


   (* -------------------------------------------------- *)
   procedure edit_fname ( func:      edit_functions;
                          x,y:       integer;
                          prompt:    string;
                          var data:  string;
                          width:     integer;
                          isdir:     boolean;
                          var term:  char );
   begin
      raw_editor( func, x, y, prompt, data, width, term, true, namechars,false);

      if isdir and (data[length(data)] <> '\') and (length(data) > 1) then
      begin
         inc(data[0]);
         data[length(data)] := '\';
      end;
   end;


   (* -------------------------------------------------- *)
   procedure edit_chars( func:      edit_functions;
                         x,y:       integer;
                         prompt:    string;
                         var data;
                         width:     integer;
                         var term:  char );
   var
      cdata:   array[1..255] of char absolute data;
      sdata:   string;
      i:       integer;

   begin
      for i := 1 to width do
         sdata[i] := cdata[i];
      sdata[0] := chr(width);
      while sdata[length(sdata)] = ' ' do
         dec(sdata[0]);

      raw_editor( func, x, y, prompt, sdata, width, term, false, allchars,false);

      sdata := ljust(sdata,width);
      for i := 1 to width do
         cdata[i] := sdata[i];
   end;


   (* -------------------------------------------------- *)
   procedure edit_integer( func:     edit_functions;
                           x,y:      integer;
                           prompt:   string;
                           var data: integer;
                           width:    integer;
                           min,max:  integer;
                           var term: char );
   var
      temp:       string;
      code:       integer;
      new_data:   integer;

   begin
      str(data,temp);      { convert data from float to string }

      repeat
         raw_editor( func, x, y, prompt, temp, width, term, false, '0123456789-',false);

         if func=edit then
            val( temp, new_data, code )
         else
            code := 0;              { convert string to int only when editing }

         if (func = edit) and (( new_data < min ) or ( new_data > max )) then
            code := 1;              { invalidate data data if out of range }

         if code <> 0 then
         begin
            beep;           { code is 0 if data is valid }
            str(data,temp);
            if (term >= F1) and (term <= F10) then
               exit;                { allow invalid data without change on F-keys}
         end;

      until ( code = 0 );

      if func=edit then
         data := new_data;
   end;


   (* -------------------------------------------------- *)
   procedure edit_byte   ( func:     edit_functions;
                           x,y:      integer;
                           prompt:   string;
                           var data: byte;
                           width:    integer;
                           min,max:  byte;
                           var term: char );
   var
      int:        integer;
   begin
      int := data;
      edit_integer(func,x,y,prompt,int,width,min,max,term);
      data := int;
   end;

   (* -------------------------------------------------- *)
   procedure edit_long( func:     edit_functions;
                           x,y:      integer;
                           prompt:   string;
                           var data: longint;
                           width:    integer;
                           min,max:  longint;
                           var term: char );
   var
      temp:       string;
      code:       integer;
      new_data:   longint;

   begin
      str(data,temp);      { convert data from float to string }

      repeat
         raw_editor( func, x, y, prompt, temp, width, term, false, '0123456789-',false);

         if func=edit then
            val( temp, new_data, code )
         else
            code := 0;              { convert string to int only when editing }

         if (func = edit) and (( new_data < min ) or ( new_data > max )) then
            code := 1;              { invalidate data data if out of range }

         if code <> 0 then
         begin
            beep;           { code is 0 if data is valid }
            str(data,temp);
            if (term >= F1) and (term <= F10) then
               exit;                { allow invalid data without change on F-keys}
         end;

      until ( code = 0 );

      if func=edit then
         data := new_data;
   end;


   (* -------------------------------------------------- *)
   procedure edit_word( func:     edit_functions;
                        x,y:      integer;
                        prompt:   string;
                        var data: word;
                        width:    integer;
                        min,max:  word;
                        var term: char );
   var
      temp:       string;
      code:       integer;
      new_data:   word;

   begin
      str(data,temp);      { convert data from float to string }

      repeat
         raw_editor( func, x, y, prompt, temp, width, term, false, '0123456789',false);

         if func=edit then
            val( temp, new_data, code )
         else
            code := 0;              { convert string to int only when editing }

         if (func = edit) and (( new_data < min ) or ( new_data > max )) then
            code := 1;              { invalidate data data if out of range }

         if code <> 0 then
         begin
            beep;           { code is 0 if data is valid }
            str(data,temp);
            if (term >= F1) and (term <= F10) then
               exit;                { allow invalid data without change on F-keys}
         end;

      until ( code = 0 );

      if func=edit then
         data := new_data;
   end;


   (* -------------------------------------------------- *)
   procedure edit_real   ( func:     edit_functions;
                           x,y:      integer;
                           prompt:   string;
                           var data: real;
                           width:    integer;
                           deci:     integer;
                           var term: char );
   var
      temp:       string;
      code:       integer;
      new_data:   real;

   begin
      str(data:0:deci,temp);      { convert data from float to string }

      repeat
         raw_editor( func, x, y, prompt, temp, width, term, true, '0123456789.E-',false);

         if func=edit then
            val( temp, new_data, code )
         else
            code := 0;              { convert string to int only when editing }

         if code <> 0 then
         begin
            beep;           { code is 0 if data is valid }
            str(data,temp);
            if (term >= F1) and (term <= F10) then
               exit;                { allow invalid data without change on F-keys}
         end;

      until ( code = 0 );

      if func=edit then
         data := new_data;
   end;


   (* -------------------------------------------------- *)
   procedure edit_yesno( func:      edit_functions;
                         x,y:       integer;
                         prompt:    string;
                         var data:  boolean;
                         var term:  char );
   var
      yesno:   string;

   begin
      if data then
         yesno := 'Y'
      else
         yesno := 'N';
      raw_editor( func, x, y, prompt, yesno, 1, term, true, 'YN',false);
      data := yesno[1] = 'Y';
   end;

   (* -------------------------------------------------- *)

   procedure edit_baud( func     : edit_functions;
                        x,y      : integer;
                        prompt   : string;
                        var baud : word;
                        var term : char );
   var temp : string;
   begin
     if func = edit then
     begin
       repeat
         gotoxy(x,y);
         textattr := pcolor;
         disp(prompt);
         textattr := incolor;
         str(baud,temp);
         disp(temp);
         textattr := pcolor;
         disp(#32);
         term := get_key;
         if term = #32 then
           case baud of
             1200 : baud := 2400;
             2400 : baud := 4800;
             4800 : baud := 9600;
             9600 : baud := 19200;
             19200: baud := 38400;
             38400: baud := 57600;
             57600: baud := 1200;
           end;
       until term <> #32;
     end;
     gotoxy(x,y);
     textattr := pcolor;
     disp(prompt);
     textattr := normcolor;
     str(baud,temp);
     disp(temp+#32);
   end;


   (* -------------------------------------------------- *)
   procedure edit_funkey( func:      edit_functions;
                          x,y:       integer;
                          prompt:    string;
                          key:       char;
                          var term:  char );
   begin
      if func = edit then
      begin
         gotoxy( x, y );
         textattr := pcolor;
         disp( prompt );

         term := get_key;
         if term = NEWLINE then
            term := key;
      end;

      gotoxy( x, y );
      textattr := normcolor;
      disp( prompt );
   end;


   (* -------------------------------------------------- *)
   procedure select_next_entry( func:    edit_functions;
                                var en:  integer;
                                maxen:   integer;
                                var key: char);
   begin
      if func = display then
         exit;

      case key of
         TAB, NEWLINE, DOWN:
            begin
               key := DOWN;
               if en < maxen then
                  inc(en)
               else
                  en := 1;
            end;

         UP:   if en > 1 then
                  dec(en)
               else
                  en := maxen;

         CTRL_HOME:
               begin
                  en := 1;
                  key := DOWN;
               end;

         CTRL_END:
               begin
                  en := maxen;
                  key := UP;
               end;
      end;
   end;

(* -------------------------------------------------- *)
   procedure clear_screen;
   begin
      clrscr;
      py := -1;
      px := -1;
   end;

(* -------------------------------------------------- *)
   procedure vscroll_bar(current, min, max: word;
                         x,y1,y2: byte);
   var
      y: integer;
      i: integer;
   begin
      y := ((current-min) * (y2-y1)) div (max-min) + y1;
      if y = py then
         exit;

      py := y;
      for i := y1 to y2 do
      begin
         gotoxy(x,i);
         if i = y then
            disp('Û')
         else
            disp('°');
      end;
   end;

(* -------------------------------------------------- *)
   procedure hscroll_bar(current, min, max: word;
                         y,x1,x2: byte);
   var
      x: integer;
      i: integer;
   begin
      x := ((current-min) * (x2-x1)) div (max-min) + x1;
      if x = px then
         exit;

      px := x;
      for i := x1 to x2 do
      begin
         gotoxy(i,y);
         if i = x then
            disp('Û')
         else
            disp('°');
      end;
   end;

   (* ------------------------------------------------------------ *)
   procedure input(var line:  string;
                   maxlen:    integer);
   var
      c:     char;

   begin
      line := '';

      repeat
         c := get_key;

         case c of
            ' '..#255:
               if length(line) < maxlen then
               begin
                  inc(line[0]);
                  line[length(line)] := c;
                  disp(c);
               end
               else
                  beep;

            ^H,#127:
               if length(line) > 0 then
               begin
                  dec(line[0]);
                  disp(^H' '^H);
               end;

            ^M:   ;

            ^C:   begin
                      displn('^C');
                      halt(99);
                  end;
         end;

      until (c = ^M);
   end;


(* -------------------------------------------------- *)
   procedure opentrace(name: string);
   begin
      assign(tracefd,name);
      rewrite(tracefd);
      traceopen := true;
   end;

   procedure closetrace;
   begin
      close(tracefd);
      traceopen := false;
   end;



(* -------------------------------------------------- *)
   procedure save_display(var disp: display_image_rec);
   begin
      disp.crt := disp_mem^;
      disp.mode := lastmode;
      disp.attr := textattr;
      disp.wmin := windmin;
      disp.wmax := windmax;
      disp.x := wherex;
      disp.y := wherey;
   end;

   procedure restore_display(var disp: display_image_rec);
   begin
      disp_mem^ := disp.crt;
      lastmode := disp.mode;
      textattr := disp.attr;
      windmin := disp.wmin;
      windmax := disp.wmax;
      gotoxy(disp.x,disp.y);
   end;


   procedure shadow_display;
   var
      i: integer;
   begin
      for i := 1 to 2000 do
         with disp_mem^[i] do
            attr := attr and 7;
   end;


(* -------------------------------------------------- *)
var
   Vmode: byte absolute $0040:$0049;   {Current video mode}
begin
   if (Vmode = 1{MDA}) or (Vmode = 7{VgaMono}) then
      disp_mem := ptr($B000,0)
   else
      disp_mem := ptr($B800,0);

   assignCrt(output);
   rewrite(output);
   directvideo := pos('/BIO',GetEnv('PCB')) = 0;
end.