{$R-,S-,I-,D-,F-,V-,B-,N-,L+,O+}

unit email0;

interface

uses gentypes;

procedure readcatalogs(re_init:boolean);

var lastread:integer;
    m:mailrec;
    incoming,outgoing:^catalogrec;

Implementation

uses dosmem, mnet, gensubs, subs1;

  procedure addcatalog (var c:catalogrec; var m:mailrec; fpos:integer);
  begin
    m.fileindex:=fpos;
    if c.nummail=maxcatalogsize
      then c.additional:=c.additional+1
      else begin
        c.nummail:=c.nummail+1;
        c.mail[c.nummail]:=m
      end
  end;

  procedure init_mem;
  begin
    if incoming = nil then
      {dos_}getmem(incoming,sizeof(catalogrec));
    if outgoing = nil then
      {dos_}getmem(outgoing,sizeof(catalogrec));
    fillchar(incoming^,sizeof(catalogrec),0);
    fillchar(outgoing^,sizeof(catalogrec),0);
  end;

  procedure deinit_mem;
  begin
    if incoming <> nil then
      {dos_}freemem(incoming,sizeof(catalogrec));
    incoming := nil;
    if outgoing <> nil then
      {dos_}freemem(outgoing,sizeof(catalogrec));
    outgoing := nil;
  end;

  procedure readcatalogs(re_init:boolean);
  var m:mailrec;
      cnt:integer;
  begin
    if re_init then deinit_mem;
    if incoming <> nil then exit;
    init_mem;
    seek (mfile,1);
    incoming^.nummail:=0;
    incoming^.additional:=0;
    outgoing^.nummail:=0;
    outgoing^.additional:=0;
    for cnt:=1 to filesize(mfile)-1 do begin
      nread (mfile,m);
      if m.sentto=unum
        then addcatalog (incoming^,m,cnt);
      if match(m.sentby,unam)
        then addcatalog (outgoing^,m,cnt)
    end
  end;

begin
end.