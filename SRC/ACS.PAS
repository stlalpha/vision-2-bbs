{$R-,S-,I-,D-,F-,V-,B-,N-,L+}

unit ACS;

interface

Uses Dos, ConfigRT, Gentypes, GenSubs, Subs1, Subs2;

function check_ACS(u:userrec; un:integer; s:string) : boolean;
function ACSPass(s:string) : boolean;

implementation

Function Check_ACS(u:userrec; un:integer; s:string) : Boolean;

VAR s1,s2     : String;
    p1,p2,i,j : Integer;
    c,c1,c2   : Char;
    B         : Boolean;

  Procedure GetRest;
  BEGIN
    s1 := c;
    p1 := i;
    if ((i<>1) and (s[i-1]='!'))
      then begin
        s1 := '!' + s1;
        dec(p1);
      end;
    if (c in ['C','F','G','I','R','V','X','Z'])
      then begin
        s1 := s1 + s[i+1];
        inc(i);
      end else begin
        j := i+1;
        repeat
          if (s[j] in ['0'..'9'])
            then begin
              s1 := s1 + s[j];
              inc(j);
            end;
        until ((j>length(s)) or (not (s[j] in ['0'..'9'])));
        i := j-1;
      end;
    p2 := i;
  END;

  function pcr_pass(pcr:integer) : boolean;
  var x    : integer;
  begin
   pcr_pass := true;
   if (pcr = 0) or (issysop) or (ulvl>=cfg.exemptlevel) then exit;
   x := ratio(urec.nbu,urec.numon);
   if x < pcr then pcr_pass := false;
  End;

  Function ArgStat(S:String) : Boolean;
  Var Vs   : String;
      T1,T2:Sstr;
      year,month,day,dayofweek,hour,minute,second,sec100 : Word;
      vsi  : integer;
      boolstate,res:boolean;
  BEGIN
    BoolState := (s[1] <> '!');
    If (not boolstate)
      then s := copy(s,2,length(s)-1);
    vs := copy(s,2,length(s)-1);
    vsi:= valu(vs);
    case s[1] of
      'A':res := ANSIGraphics IN U.CONFIG;
      'B':res := (connectbaud >= valu(vs+'00')) or Local;
      'C':res := vsi = msgconf;
      'D':res := (u.udlevel>=vsi);
      'E':if vs <> ''
            then res := pcr_pass(vsi)
            else res := pcr_pass(urec.pcr);
      'F':res := Pos(Upcase(Vs[1]),U.Flags) > 0;
      'H':begin
            gettime(hour,minute,second,sec100);
            res:=(hour=vsi);
          end;
      'I':res := UpString(VS) = UpString(Inpt);
      'L':res := local;
      'P':res := (u.udpoints>=vsi);
      'S':res := (u.level>=vsi);
      'T':res := (timeleft >= vsi);
      'U':res := (un=vsi);
      'V':res := u.level >= cfg.logonlevel;
      'W':begin
            getdate(year,month,day,dayofweek);
            res:=(dayofweek=ord(s[1])-48);
          end;
      'X': res := vsi = fileconf;
      'Y': begin
             t1 := copy(vs,1,pos('/',vs)-1);
             t2 := copy(vs,pos('/',vs)+1,length(vs));
             res := withintime(t1,t2);
           end;
      'Z': res := Pos(UpString(VS),UpString(U.PrivateNote)) > 0;
    end;
    if (not boolstate) then res:=not res;
    argstat := res;
  end;

begin
  s:=upstring(s);
  i:=0;
  while (i<length(s)) do begin
    inc(i);
    c:=s[i];
    if (c in ['A'..'Z']) and (i<>length(s)) then begin
      getrest;
      b:=argstat(s1);
      delete(s,p1,length(s1));
      if (b) then s2:='^' else s2:='%';
      insert(s2,s,p1);
      dec(i,length(s1)-1);
    end;
  end;
  s:='('+s+')';
  while (pos('&',s)<>0) do delete(s,pos('&',s),1);
  while (pos('^^',s)<>0) do delete(s,pos('^^',s),1);
  while (pos('(',s)<>0) do begin
    i:=1;
    while ((s[i]<>')') and (i<=length(s))) do begin
      if (s[i]='(') then p1:=i;
      inc(i);
    end;
    p2:=i;
    s1:=copy(s,p1+1,(p2-p1)-1);
    while (pos('|',s1)<>0) do begin
      i:=pos('|',s1);
      c1:=s1[i-1]; c2:=s1[i+1];
      s2:='%';
      if ((c1 in ['%','^']) and (c2 in ['%','^'])) then begin
        if ((c1='^') or (c2='^')) then s2:='^';
        delete(s1,i-1,3);
        insert(s2,s1,i-1);
      end else
        delete(s1,i,1);
    end;
    while(pos('%%',s1)<>0) do delete(s1,pos('%%',s1),1);   {leave only "%"}
    while(pos('^^',s1)<>0) do delete(s1,pos('^^',s1),1);   {leave only "^"}
    while(pos('%^',s1)<>0) do delete(s1,pos('%^',s1)+1,1); {leave only "%"}
    while(pos('^%',s1)<>0) do delete(s1,pos('^%',s1),1);   {leave only "%"}
    delete(s,p1,(p2-p1)+1);
    insert(s1,s,p1);
  end;
  check_acs:=(not (pos('%',s)<>0));
end;

function acspass(s:string):boolean;
begin
  acspass:=check_acs(urec,unum,s);
end;

begin
end.