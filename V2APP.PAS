{$V-,I-,B-,R-}
{$M 15000,1024,1024}

Program NewAPP;

Uses Dos,Crt,General,DispEdit,Video,Little;

{$R-,S+,I-,F-,V-,B-}

type tstr = string[71];

var a : array[1..25] of tstr;

Procedure Ask_Colors;
Begin
  PColor := 5 * 16 + 14;
  NormColor := 5 * 16 + 15;
  InColor := 14;
  Def_Fill := #32;
End;

Procedure Ask(X1,Y1,X2,Y2 : Byte;     { Where }
              Title       : tstr;     { Title of Box }
              Question    : tstr;     { Da Question }
              Len         : Byte;     { Max Input Length }
              VAR Result  : tstr);    { User Input }
Var S : Screens;
    K : Char;
    X : Byte;
Begin
  ReadScr(S);
  Ask_Colors;
  Color(5,15);
  GrowBOX(X1,Y1,X2,Y2);
  Color(13,15);
  GotoXy(X1 + 1,Y1 + 1);
  For X := (X1 - 1) to (X2 - 3)
    Do Write(#32);
  Center_Write(Title,Y1 + 1);
  GotoXy(X1 + 3,Y1 + 2);
  Raw_Editor(Edit,X1 + 3,Y1 + 3,Question,Result,Len,K,False,'',True);
  If K = ESC
    Then Result[1] := #27;
  WriteScr(S);
End;

procedure create_box(top,bottom:byte; title:tstr);
begin
  color(9,15);
  growbox(2,top,78,bottom);
  gotoxy(4,top);
  color(9,15);
  write('[');
  color(9,14);
  write(title);
  color(9,15);
  write(']');
end;

procedure do_input;
const maxentry = 23;
var pentry, entry : integer;
    k : char;
    savefile : string[12];
    i : integer;
    t : text;
    temp : string[80];

    procedure process_entry(func:edit_functions);
    begin
      if func = display then
        begin
          gotoxy(4,19);
          color(9,15);
          write('Comments');
        end;
      case entry of
        1 : edit_string(func,4,5,'Alias : ',a[1],30,k);
        2 : edit_string(func,43,5,'Affils. : ',a[2],24,k);
        3 : edit_string(func,4,7,'BBS Name : ',a[3],40,k);
        4 : edit_string(func,4,8,'BBS Phone # : ',a[4],15,k);
        5 : edit_string(func,43,8,'Total Nodes : ',a[5],5,k);
        6 : edit_string(func,4,9,'Total Users : ',a[6],5,k);
        7 : edit_string(func,43,9,'Total LD Users : ',a[7],5,k);
        8 : edit_string(func,4,10,'Current BBS Software : ',a[8],15,k);
        9 : edit_string(func,43,10,'Current Nets : ',a[9],19,k);
        10: edit_string(func,4,11,'Computer Type : ',a[10],22,k);
        11: edit_string(func,43,11,'Modem Type : ',a[11],21,k);
        12: edit_string(func,4,12,'Total HD Space : ',a[12],10,k);
        13: edit_string(func,43,12,'BBS ''Theme'' : ',a[13],20,k);
        14: edit_string(func,4,13,'BBS Affils. : ',a[14],24,k);
        15: edit_string(func,43,13,'BBS Age : ',a[15],10,k);
        16: edit_string(func,4,15,'Real Name : ',a[16],25,k);
        17: edit_string(func,43,15,'Age : ',a[17],10,k);
        18: edit_string(func,4,16,'Address : ',a[18],28,k);
        19: edit_string(func,43,16,'Phone # : ',a[19],15,k);
        20: edit_string(func,4,17,'City, ST. : ',a[20],26,k);
        21: edit_string(func,43,17,'Zip Code : ',a[21],15,k);
        22: edit_string(func,4,20,': ',a[22],71,k);
        23: edit_string(func,4,21,': ',a[23],71,k);
      end;
      select_next_entry(func,entry,maxentry,k);
    end;

    procedure def_colors;
    begin
      normcolor := 16 * 9 + 11;
      pcolor    := 16 * 9 + 15;
      incolor   := 16 * 15 + 0;
      def_fill  := #32;
    end;

begin
  create_box(3,23,'Application - ESC to Exit and Save');
  k := #0;
  def_colors;
  for entry := 1 to maxentry do process_entry(display);
  repeat
    process_entry(edit);
  until k=#27;
  savefile := '';
  ask(9,9,71,15,'Please try and match filename with your handle.',
                'Save to what file? (Cr/Aborts ESC/Edit) : ',8,savefile);
  if savefile[1] = #27 then do_input;
  if (savefile <> '') and (savefile[1] <> #27) then
    begin
      assign(t,savefile + '.APP');
      rewrite(t);
      temp[0] := #0;
      for i := 0 to 3999 do begin
        if not odd(i) then temp := temp + char(mem[$B800:i]);
        if length(temp) > 79 then begin
          temp[0] := #79;
          writeln(t,temp);
          temp[0] := #0;
        end
      end;
      close(t);
    end;
end;

procedure init_screen;
begin
  fill_screen('²',7,1);
  gotoxy(1,1);
  color(8,15);
  clreol;
  center_write('ViSiON/2 Bulletin Board System Application v1.1á',1);
  gotoxy(1,25);
  clreol;
  center_write('Written by Crimson Blade  (c) 1993 Ruthless Enterprises',25);
end;

begin
  hi_back_on;
  fillchar(a,sizeof(a),0);
  init_screen;
  do_input;
  hi_back_off;
  textattr := 15;
  clrscr;
  Writeln('Upload Applications to Theft of Services @ 505-622-6804');
  Writeln('ViSiON/2 Registration: $50 payable check or money order.');
  Writeln('Crimson Blade can be contacted on the above BBS, BLiTZNet,');
  Writeln('or via internet (crim@cyberspace.com).');
end.