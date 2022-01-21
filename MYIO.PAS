{$A+,B+,D-,E+,F+,I+,L+,N-,O+,R-,S+,V-}

Unit Myio;

Interface

Uses
  Crt, Dos, Overlay;

Const
  Infield_Seperators : Set of Char = [' ','\','.'];
  VidSeg : Word = $B800;
  IsMono : Boolean = FALSE;

Type
  WindowRec = Array[0..4003] of Byte;
  Infield_Special_Function_Proc_Rec = Procedure(C : Char);

Const
  Infield_Only_Allow_On : Boolean = False;
  Infield_Arrow_Exit : Boolean = False;
  Infield_Arrow_Exited : Boolean = False;
  Infield_Arrow_Exited_Keep : Boolean = False;
  Infield_Special_Function_on : Boolean = False;
  Infield_Arrow_Exit_Typedefs : Boolean = False;
  Infield_Normal_Exit_Keydefs : Boolean = False;
  Infield_Normal_Exited : Boolean = False;
  Infield_Out_Fgrd : Byte = 15;
  Infield_Out_Bkgd : Byte = 1;
  Infield_Inp_Fgrd : Byte = 15;
  Infield_Inp_Bkgd : Byte = 1;

Var
  Infield_Last_Arrow,
  Infield_Last_Normal : Byte;
  Infield_Only_Allow : String;
  Infield_Special_Function_Proc : Infield_Special_Function_Proc_Rec;
  Infield_Special_Function_Keys : String;
  Infield_Arrow_Exit_Types : String;
  Infield_Normal_Exit_Keys : String;

procedure cursoron(b:boolean);
procedure infield1(x,y:byte; var s:string; len:byte);
procedure infielde(var s:string; len:byte);
procedure infield(var s:string; len:byte);
function l_yn:boolean;
function l_pynq(s:string):boolean;
procedure cwrite(s:string);
procedure cwriteat(x,y:integer; s:string);
function cstringlength(s:string):integer;
procedure cwritecentered(y:integer; s:string);
procedure box(linetype,TLX,TLY,BRX,BRY:integer);
procedure checkvidseg;
procedure savescreen(var wind:windowrec; TLX,TLY,BRX,BRY:integer);
procedure setwindow(var wind:windowrec; TLX,TLY,BRX,BRY,tcolr,bcolr,boxtype:integer);
procedure removewindow(wind:windowrec);
procedure removewindow1(wind:windowrec);
procedure movewindow(wind:windowrec; TLX,TLY:integer);

implementation

procedure cursoron(b:boolean);
var reg:registers;
begin
  with reg do begin
    if (b) then begin
      ch:=$07;
      cl:=$08;
    end else begin
      ch:=$09;
      cl:=$00;
    end;
    ah:=1;
    intr($10,reg);
  end
end;

Procedure InField1(X,Y : Byte; Var S : String; Len : Byte);
Var Os : String;
    Sta, Sx, Sy,z,i,p:integer;
    c:char;
    ins,done,nokeyyet:boolean;

  procedure gocpos;
  begin
    gotoxy(x+p-1,y);
  end;

  procedure exit_w_arrow;
  var i:integer;
  begin
    infield_arrow_exited:=TRUE;
    infield_last_arrow:=ord(c);
    done:=TRUE;
    if (infield_arrow_exited_keep) then begin
      z:=len;
      for i:=len downto 1 do
        if (s[i]=' ') then dec(z) else i:=1;
      s[0]:=chr(z);
    end else
      s:=os;
  end;

  procedure exit_w_normal;
  var i:integer;
  begin
    infield_normal_exited:=TRUE;
    infield_last_normal:=ord(c);
    done:=TRUE;
    if (infield_arrow_exited_keep) then begin
      z:=len;
      for i:=len downto 1 do
        if (s[i]=' ') then dec(z) else i:=1;
      s[0]:=chr(z);
    end else
      s:=os;
  end;

begin
  sta:=textattr; sx:=wherex; sy:=wherey;
  os:=s;
  ins:=FALSE;
  done:=FALSE;
  infield_arrow_exited:=FALSE;
  gotoxy(x,y);
  textattr:=(infield_inp_bkgd*16)+infield_inp_fgrd;
  for i:=1 to len do write(' ');
  for i:=length(s)+1 to len do s[i]:=' ';
  gotoxy(x,y); write(s);
  p:=1; {  p:=length(s)+1;}
  gocpos;
  nokeyyet:=TRUE;
  repeat
    repeat c:=readkey
    until ((not infield_only_allow_on) or
           (pos(c,infield_special_function_keys)<>0) or
           (pos(c,infield_normal_exit_keys)<>0) or
           (pos(c,infield_only_allow)<>0) or (c=#0));

    if ((infield_normal_exit_keydefs) and
        (pos(c,infield_normal_exit_keys)<>0)) then exit_w_normal;

    if ((infield_special_function_on) and
        (pos(c,infield_special_function_keys)<>0)) then
      infield_special_function_proc(c)
    else begin
      if (nokeyyet) then begin
        nokeyyet:=FALSE;
        if (c in [#32..#255]) then begin
          gotoxy(x,y);
          for i:=1 to len do begin write(' '); s[i]:=' '; end;
          gotoxy(x,y);
        end;
      end;
      case c of
         #0:begin
              c:=readkey;
              if ((infield_arrow_exit) and (infield_arrow_exit_typedefs) and
                  (pos(c,infield_arrow_exit_types)<>0)) then exit_w_arrow
              else
              case c of
                #72,#80:if (infield_arrow_exit) then exit_w_arrow;
                #75:if (p>1) then dec(p);
                #77:if (p<len+1) then inc(p);
                #71:p:=1;
                #79:begin
                      z:=1;
                      for i:=len downto 2 do
                        if ((s[i-1]<>' ') and (z=1)) then z:=i;
                      if (s[z]=' ') then p:=z else p:=len+1;
                    end;
                #82:ins:=not ins;
                #83:if (p<=len) then begin
                      for i:=p to len-1 do begin
                        s[i]:=s[i+1];
                        write(s[i]);
                      end;
                      s[len]:=' '; write(' ');
                    end;
                #115:if (p>1) then begin
                       i:=p-1;
                       while ((not (s[i-1] in infield_seperators)) or
                             (s[i] in infield_seperators))
                             and (i>1) do
                         dec(i);
                       p:=i;
                     end;
                #116:if (p<=len) then begin
                       i:=p+1;
                       while ((not (s[i-1] in infield_seperators)) or
                             (s[i] in infield_seperators))
                             and (i<=len) do
                         inc(i);
                       p:=i;
                     end;
                #117:if (p<=len) then
                       for i:=p to len do begin
                         s[i]:=' ';
                         write(' ');
                       end;
              end;
              gocpos;
            end;
         #27:begin
               s:=os;
               done:=TRUE;
             end;
        #13:begin
              done:=TRUE;
              z:=len;
              for i:=len downto 1 do
                if (s[i]=' ') then dec(z) else i:=1;
              s[0]:=chr(z);
            end;
        #8:if (p<>1) then begin
             dec(p);
             s[p]:=' ';
             gocpos; write(' '); gocpos;
           end;
      else
            if ((c in [#32..#255]) and (p<=len)) then begin
              if ((ins) and (p<>len)) then begin
                write(' ');
                for i:=len downto p+1 do s[i]:=s[i-1];
                for i:=p+1 to len do write(s[i]);
                gocpos;
              end;
              write(c);
              s[p]:=c;
              inc(p);
            end;
      end;
    end;
  until done;
  gotoxy(x,y);
  textattr := (infield_out_bkgd*16)+infield_out_fgrd;
  for i:=1 to len do write(' ');
  gotoxy(x,y);
  write(s);
  gotoxy(sx,sy);
  textattr:=sta;

  infield_only_allow_on:=FALSE;
  infield_special_function_on:=FALSE;
  infield_normal_exit_keydefs:=FALSE;
end; 

procedure infielde(var s:string; len:byte);
begin
  infield1(wherex,wherey,s,len);
end;

procedure infield(var s:string; len:byte);
begin
  s:=''; infielde(s,len);
end;

function l_yn:boolean;
var c:char;
begin
  repeat c:=upcase(readkey) until (c in ['Y','N',#13,#27]);
  if (c='Y') then begin
    l_yn:=TRUE;
    writeln('Yes');
  end else begin
    l_yn:=FALSE;
    writeln('No');
  end;
end;

function l_pynq(s:string):boolean;
begin
  textcolor(4); write(s); textcolor(11);
  l_pynq:=l_yn;
end;

procedure color(fg,bg:integer);
begin
  textcolor(fg);
  textbackground(bg);
end;

procedure cwrite(s:string);
var i:integer;
    c:char;
    lastb,lastc:boolean;
begin
  lastb:=FALSE; lastc:=FALSE;
  for i:=1 to length(s) do begin
    c:=s[i];
    if ((lastb) or (lastc)) then begin
      if (lastb) then
        textbackground(ord(c))
      else
        if (lastc) then
          textcolor(ord(c));
      lastb:=FALSE; lastc:=FALSE;
    end else
      case c of
        #2:lastb:=TRUE;
        #3:lastc:=TRUE;
      else
           write(c);
      end;
  end;
end;

procedure cwriteat(x,y:integer; s:string);
begin
  gotoxy(x,y);
  cwrite(s);
end;

function cstringlength(s:string):integer;
var len,i:integer;
begin
  len:=length(s); i:=1;
  while (i<=length(s)) do begin
    if ((s[i]=#2) or (s[i]=#3)) then begin dec(len,2); inc(i); end;
    inc(i);
  end;
  cstringlength:=len;
end;

procedure cwritecentered(y:integer; s:string);
begin
  cwriteat(40-(cstringlength(s) div 2),y,s);
end;

{*
 *  ÚÄÄÄ¿   ÉÍÍÍ»   °°°°°   ±±±±±   ²²²²²   ÛÛÛÛÛ   ÖÄÄÄ·  ÕÍÍÍ¸
 *  ³ 1 ³   º 2 º   ° 3 °   ± 4 ±   ² 5 ²   Û 6 Û   º 7 º  ³ 8 ³
 *  ÀÄÄÄÙ   ÈÍÍÍ¼   °°°°°   ±±±±±   ²²²²²   ÛÛÛÛÛ   ÓÄÄÄ½  ÔÍÍÍ¾
 *}
procedure box(linetype,TLX,TLY,BRX,BRY:integer);
var i,j:integer;
    TL,TR,BL,BR,hline,vline:char;
begin
  window(1,1,80,25);
  case linetype of
    1:begin
        TL:=#218; TR:=#191; BL:=#192; BR:=#217;
        vline:=#179; hline:=#196;
      end;
    2:begin
        TL:=#201; TR:=#187; BL:=#200; BR:=#188;
        vline:=#186; hline:=#205;
      end;
    3:begin
        TL:=#176; TR:=#176; BL:=#176; BR:=#176;
        vline:=#176; hline:=#176;
      end;
    4:begin
        TL:=#177; TR:=#177; BL:=#177; BR:=#177;
        vline:=#177; hline:=#177;
      end;
    5:begin
        TL:=#178; TR:=#178; BL:=#178; BR:=#178;
        vline:=#178; hline:=#178;
      end;
    6:begin
        TL:=#219; TR:=#219; BL:=#219; BR:=#219;
        vline:=#219; hline:=#219;
      end;
    7:begin
        TL:=#214; TR:=#183; BL:=#211; BR:=#189;
        vline:=#186; hline:=#196;
      end;
    8:begin
        TL:=#213; TR:=#184; BL:=#212; BR:=#190;
        vline:=#179; hline:=#205;
      end;
  else
      begin
        TL:=#32; TR:=#32; BL:=#32; BR:=#32;
        vline:=#32; hline:=#32;
      end;
  end;
  gotoxy(TLX,TLY); write(TL);
  gotoxy(BRX,TLY); write(TR);
  gotoxy(TLX,BRY); write(BL);
  gotoxy(BRX,BRY); write(BR);
  for i:=TLX+1 to BRX-1 do begin
    gotoxy(i,TLY);
    write(hline);
  end;
  for i:=TLX+1 to BRX-1 do begin
    gotoxy(i,BRY);
    write(hline);
  end;
  for i:=TLY+1 to BRY-1 do begin
    gotoxy(TLX,i);
    write(vline);
  end;
  for i:=TLY+1 to BRY-1 do begin
    gotoxy(BRX,I);
    write(vline);
  end;
  if (linetype>0) then window(TLX+1,TLY+1,BRX-1,BRY-1)
                  else window(TLX,TLY,BRX,BRY);
end;

procedure checkvidseg;
begin
  if (mem[$0000:$0449]=7) then vidseg:=$B000 else vidseg:=$B800;
  ismono:=(vidseg=$B000);
end;

procedure savescreen(var wind:windowrec; TLX,TLY,BRX,BRY:integer);
var x,y,i:integer;
begin
  checkvidseg;

  wind[4000]:=TLX; wind[4001]:=TLY;
  wind[4002]:=BRX; wind[4003]:=BRY;

  i:=0;
  for y:=TLY to BRY do
    for x:=TLX to BRX do begin
      inline($FA);
      wind[i]:=mem[vidseg:(160*(y-1)+2*(x-1))];
      wind[i+1]:=mem[vidseg:(160*(y-1)+2*(x-1))+1];
      inline($FB);
      inc(i,2);
    end;
end;

procedure setwindow(var wind:windowrec; TLX,TLY,BRX,BRY,tcolr,bcolr,boxtype:integer);
var i:integer;
begin
  savescreen(wind,TLX,TLY,BRX,BRY);        { save under window }
  window(TLX,TLY,BRX,BRY);                 { set window size }
  color(tcolr,bcolr);                      { set window colors }
  clrscr;                                  { clear window for action }
  box(boxtype,TLX,TLY,BRX,BRY);            { Set the border }
end;

procedure removewindow(wind:windowrec);
var TLX,TLY,BRX,BRY,x,y,i:integer;
begin
  checkvidseg;

  window(1,1,80,25);
  color(14,0);

  TLX:=wind[4000]; TLY:=wind[4001];
  BRX:=wind[4002]; BRY:=wind[4003];

  i:=0;
  for y:=TLY to BRY do
    for x:=TLX to BRX do begin
      inline($FA);
      mem[vidseg:(160*(y-1)+2*(x-1))]:=wind[i];
      mem[vidseg:(160*(y-1)+2*(x-1))+1]:=wind[i+1];
      inline($FB);
      inc(i,2);
    end;
end;

procedure removewindow1(wind:windowrec);
var oldx1,oldy1,oldx2,oldy2,sx,sy,sz:byte;
begin
  sx:=wherex; sy:=wherey; sz:=textattr;
  oldx1:=lo(windmin); oldy1:=hi(windmin);
  oldx2:=lo(windmax); oldy2:=hi(windmax);

  removewindow(wind);

  window(oldx1,oldy1,oldx2,oldy2);
  gotoxy(sx,sy); textattr:=sz;
end;

procedure movewindow(wind:windowrec; TLX,TLY:integer);
var BRX,BRY,x,y,i:integer;
begin
  checkvidseg;

  window(1,1,80,25);
  color(14,0);

  BRX:=wind[4002]; BRY:=wind[4003];
  inc(BRX,TLX-wind[4000]); inc(BRY,TLY-wind[4001]);

  i:=0;
  for y:=TLY to BRY do
    for x:=TLX to BRX do begin
      inline($FA);
      mem[vidseg:(160*(y-1)+2*(x-1))]:=wind[i];
      mem[vidseg:(160*(y-1)+2*(x-1))+1]:=wind[i+1];
      inline($FB);
      inc(i,2);
    end;
end;

end.
