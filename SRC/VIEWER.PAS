{$R-,S-,I-,D-,F+,V-,B-,N-,L+,O+ }

unit Viewer;

interface

uses dos,MNeT,gentypes,configrt,modem,gensubs,subs1,windows,subs2;

Procedure listxmodem;
Procedure ViewTransLog;
Procedure ListHelp;
Procedure AdDSZLog(Cps : Sstr; FName : Sstr; Send : Boolean; Size : Longint);
{procedure leechzmodem(filezp:mstr);}
procedure addzipcomment(pathname:lstr;path,name:mstr);
{ Procedure ProtoEditor; }

implementation

Procedure listxmodem;
  Var cnt:Integer;
    u:userrec;
  Begin
    Seek(ufile,1);
    Header('Name                          Lvl Pts       ');
    For cnt:=1 To numusers Do Begin
      Read(ufile,u);
      If u.handle<>'' Then
        If u.udlevel>0 Then Begin
          tab(^S+u.handle,30);
          tab(^A+strr(u.udlevel),4);
          WriteLn(^P+Strr(u.udpoints));
          If break Then exit
        End
    End
  End;

Procedure ListHelp;
Begin
  Writeln;
  WriteHdr('File Listing Help');
  If usebars in urec.config then Begin
    Goxy(1,24);
    Writeln(^U);
    Writeln(^O'['^P'Left/Right Arrows, 4/6'^O'] '^R'Moves Bottom Bar');
    Writeln(^O'['^P'Up/Down Arrows, 8,2'^O']    '^R'Moves Numbered Bar');
    Writeln(^O'['^P'SPACE'^O']  '^R'Toggles Highlighted Numbered File in Batch List');
    Writeln(^O'['^P'ENTER'^O']  '^R'Activates Highlighted Bottom Bar:');
    Writeln(^O'  -Next'^P':     '^R'Check out next group of files');
    Writeln(^O'  -Download'^P': '^R'Download Batch Que/Single File');
    Writeln(^O'  -Type'^P':     '^R'Type any TEXT File');
    Writeln(^O'  -View'^P':     '^R'View the files of any ARCHIVED files');
    Writeln(^O'  -Quit'^P':     '^R'Aborts Listing..');
  End Else Begin
    Writeln(^O'['^P'ENTER'^O'] '^R'Check out next group of files');
    Writeln(^O'['^P'+'^O']     '^R'Add A File To Batch Que');
    Writeln(^O'['^P'R'^O']     '^R'Remove a Files From Batch Que');
    Writeln(^O'['^P'D'^O']     '^R'Download Batch Que/Single File');
    Writeln(^O'['^P'T'^O']     '^R'Type any TEXT File');
    Writeln(^O'['^P'V'^O']     '^R'View the files of any ARCHIVED Files');
    Writeln(^O'['^P'Q'^O']     '^R'Aborts Listing...');
  End;
  HoldScreen;
End;

Procedure ViewTransLog;
VAR T:Text;
    B:Byte;
    S:String;
Begin
  Assign(T,Cfg.DATADIR+'TRANS.'+Strr(FileConf));
  Reset(T);
  If IoResult<>0 then Begin
    Writeln(^S+Cfg.DATADIR+'TRANS.'+Strr(FileConf)+' doesn''t exist!');
    Exit;
  End;
  B:=0;
  While (Not Eof(T)) or (HungUpOn) Do Begin
    Inc(B);
    Readln(T,S);
    Writeln(S);
    If B>23 then Begin
      HoldScreen;
      B:=0;
    End;
 End;
 TextClose(T);
End;

Procedure AdDSZLog(Cps : Sstr; FName : Sstr; Send : Boolean; Size : Longint);
var f:file of byte;
     t:text;
     fse:longint;
     A,B,C:Sstr;

Procedure WriteTop;
Begin
  Assign(t,cfg.DATADIR+'Trans.'+Strr(FileConf));
  ReWrite(t);
  Writeln(T,'[40m[2J[0;34mÚÄÄÄúú[Cú[C[1;37mV/2[CTransfer[CLog[C[0;34mú[CúúÄ[s');
  Writeln(T,'[uÄÄÄÄúú[Cú[2C[1;37m(c)[CRuthless[CEnterprises[C1993[2C[0;34mú[s');
  Writeln(T,'[u[CúúÄÄÄ¿³[C[37mFile[CName[5CFile[CSize[2CCPS[CRate[3CWhen[7C[s');
  Writeln(T,'[uTransferred[CBy[16C[34m³ÀÄÄÄúúú[CúúÄÄÄÄÄÄÄÄÄÄÄÄúú[Cúú[CúúÄÄÄÄÄÄÄ[s');
  Writeln(T,'[uÄÄÄÄÄúú[Cú[2Cú[CúúÄÄÄÄÄÄÄÄÄÄÄÄúú[Cú[4Cú[CúúÄÄÄÙ[1;33m');
  TextClose(t);
End;


begin
  fse:=0;
  if exist(cfg.DATADir+'Trans.'+Strr(FileConf)) then begin
    assign(F,cfg.DATADir+'Trans.'+Strr(FileConf));
    reset(f);
    Fse := filesize(f);
    Close(f);
  End;

  If (fse=0) or (fse>(1024+(10*1024)))
    then WriteTop;

  Assign(T,Cfg.DATADIR+'TRANS.'+Strr(FileConf));
  Append(T);

  Write(T,#32#32 + Copy(FName,0,12));
  For Fse := 1 to 12-length(fname)
    Do Write(t,#32);

  Write(T,'  '+copy(strr(size div 1024)+'k ',0,8));
  For Fse := 1 To 8 - Length(Strr(Size Div 1024))
    Do Write(T,#32);

  Write(t,Cps + ' Cps');
  For Fse := 1 to 6-Length(CPS)
    Do Write(T,#32);

  Write(T,DateStr(Now));
  For Fse := 1 to 11 - Length(DateStr(Now))
    Do Write(T,#32);

  If Send
    Then Write(T,'Dl''d by ')
    Else Write(T,'Ul''d by ');

  Writeln(t,Unam);

  Textclose(t);
end;

(*

 procedure leechzmodem(filezp:mstr);
 var fn:text;
     i:integer;
 begin
 AnsiCls;
 writehdr('Leech Z-Modem Detected!');
 writeln(^M^S'Leech Z-Modem has been detected with this file transfer! The');
 writeln(^S'File points will be subtracted and the sysop WILL be notified!');
 write(^M^R'Notifying Sysop...');
 assign(fn,Cfg.visiondir+'Notices.BBS');
 if not exist(Cfg.visiondir+'Notices.BBS') then rewrite(fn) else reset(fn);
 append(fn);
 writeln(fn,^M^S'ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ');
 writeln(fn,^R'                         Leech Z-Modem Detected');
 writeln(fn,^S'ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ');
 writeln(fn,^M^S+urec.handle+' was downloading on '+timestr(now)+'/'+datestr(now)+' when he');
 writeln(fn,^S'attempted to use Leech Z-Modem on '+filezp+'. The Points were');
 writeln(fn,^S'charged for this file.');
 textclose(fn);
 end;

*)

   procedure addzipcomment(pathname:lstr; path,name:mstr);
    begin
    end;

(*
      if pos('.ZIP',upstring(name))>0 then begin
      If Cfg.ZipComment Then
      exec(getenv('Comspec'),'/C PKZIP -z '+pathname+' < '+Cfg.TextfileDir+'ZCOMMENT.TXT > nul');
      if Cfg.ZipFileAdd<>'' then
         exec(getenv('Comspec'),'/C PKZIP '+pathname+' '+Cfg.ZipFileAdd+' > nul');
         writeln('Done!');
      end else
      If pos('.ARJ',Upstring(Name))>0 then Begin
        If Cfg.ZipFileAdd<>'' then
        exec(GetEnv('COMSPEC'),'/C ARJ A '+PathName+' '+Cfg.Zipfileadd);
        Writeln('Done!');
      End;
    end;*)


(*
CONST DFILE ='PROT_S.DAT';
      UFILE ='PROT_R.DAT';
      BDFILE='PROT_D.DAT';
      BUFILE='PROT_U.DAT';

Procedure Edit(A:Byte);
VAR AllPrec:Array[1..30] Of ProtoRec;
    PRec:ProtoRec;
    PFile:File Of ProtoRec;
    Size,Cnt:Byte;
    Whichfile:Lstr;
    St:AnyStr;
    K:Char;
    Done:Boolean;

    Procedure LoadProtos;
    Begin
      Case A Of
        1:WhichFile:=Cfg.DataDir+Dfile;
        2:WhichFile:=Cfg.DataDir+UFile;
        3:WhichFile:=Cfg.DataDir+BDFile;
        4:WhichFile:=Cfg.DataDir+BUFile;
      End;
    Assign(PFile,WhichFile);
    Reset(PFile);
    If Ioresult<>0
      then Rewrite(PFile);
    Size:=FileSize(PFile);
    Reset(PFile);
    If Size>0 then Begin
      Cnt:=0;
      Repeat
        Inc(Cnt);
        nRead(PFile,Prec);
        AllPRec[Cnt]:=PRec;
      Until Eof(PFile);
     Close(PFile);
     End;
    End;

    Procedure EditProto(P:Byte);
    Var Cnt:Byte;
        Done:Boolean;
    Begin
      AnsiCls;
      Writeln(^R'[ '^S'Protocol Editor '^R']'^M);
      Writeln(^P'['^O'L'^P'] '^R'Letter.......: '^A+AllPRec[P].Letter);
      Writeln(^P'['^O'D'^P'] '^R'Description..: '^A+AllPrec[P].Desc);
      Writeln(^P'['^O'F'^P'] '^R'File Name....: '^A+UpString(AllPrec[P].ProgName));
      Writeln(^P'['^O'C'^P'] '^R'Command Line.: '^A+AllPRec[P].Commfmt+^M);
      Write(^R'Change? '^P'['^O'Q'^P']uits [ ]'+B_(2));
      Done:=False;
      Repeat
        Buflen:=1;
        WriteStr('&');
        K:=Upcase(inpt[1]);
      Case K Of
        'L':Begin
              Goxy(20,3);
              InputBox(1);
              If inpt<>'' then AllPrec[P].Letter:=inpt[1];
              Goxy(20,3);
              Write(^A+AllPrec[P].Letter);
            End;
        'D':Begin
              Goxy(20,4);
              InputBox(30);
              If inpt<>'' then AllPrec[P].Desc:=inpt;
              Goxy(20,4);
              Write(^A+#27+'[K');
              Write(AllPrec[P].Desc);
             End;
        'F':Begin
              Goxy(20,5);
              InputBox(12);
              If inpt<>'' then AllPrec[P].ProgName:=inpt;
              Goxy(20,5);
              Write(^A+#27+'[K');
              Write(AllPrec[P].ProgName);
            End;
        'C':Begin
              Goxy(1,7);
              Write(^P'Params.'^O': '^S'%1 COM Port %2 Locked Baud %3 Filename %4 DSZLOG Name %5 Connect Baud');
              Goxy(20,6);
              InputBox(60);
              If inpt<>'' then AllPrec[P].CommFmt:=inpt;
              Goxy(20,6);
              Write(^A+#27+'[K');
              Write(AllPrec[P].CommFmt);
              Goxy(1,7);
              Write(^A+#27+'[K');
            End;
        'Q':Done:=True;
          End;
      Goxy(18,8);
      Until Done;
      Writeln;
      If P>Size then Inc(Size);
    End;

    Procedure CreateProto;
    VAR Cnt:Byte;
    Begin
      If Size>29 then Begin
        Writeln(^S'You can only have 30 protocols!');
        Exit;
      End;
      AnsiCls;
      WriteHdr('Protocol Creater');
      Writeln;
      Write(^P'Letter/Number Choice'^O': ');
      InputBox(1);
      If inpt<>'' then Begin
        For Cnt:=1 to Size Do
          If inpt[1]=AllPRec[Cnt].Letter Then Begin
            Writeln(^P'Hey! that character is already being used!');
            Exit;
          End;
        AllPrec[Size+1].Letter:=inpt[1];
      End Else Exit;
      Write(^P'Description of Protocol'^O': ');
      InputBox(30);
      If inpt<>'' then AllPrec[Size+1].Desc:=inpt Else Exit;
      Write(^P'Executable Progam Name '^O'('^P'Ex: DSZ.EXE'^O') : ');
      NoCRInput('DSZ.EXE',12);
      If inpt<>'' then AllPrec[Size+1].ProgName:=inpt Else AllPrec[Size+1].ProgName:='DSZ.EXE';
      Writeln(^P'Params.'^O': '^S'%1 COM Port %2 Locked Baud %3 Filename %4 DSZLOG Name %5 Connect Baud');
      InputBox(60);
      AllPrec[Size+1].CommFmt:=inpt;
      WriteLog(0,0,'Created Protocol "'+AllPrec[Size+1].Desc+'"');
      EditProto(Size+1);
    End;

    Procedure DeleteProto;
    Var Cnt,N:Byte;
    Begin
      WriteStr(^P'Delete Which Protocol? '^O'['^S'1..'+strr(Size)+^O']: &');
      N:=Valu(inpt);
      if (n<1) or (N>Size) then exit;
      WriteStr(^M^P'Delete '+AllPrec[N].Desc+'? !');
      if not yes then exit;
      for cnt:=n+1 to size do begin
       AllPrec[CNT-1]:=AllPrec[CNT];
      end;
      Dec(Size);
    writelog (0,0,'Deleted Protocol "'+AllPrec[N].Desc+'"');
  end;

Begin
  LoadProtos;
  AnsiCls;
  Case A Of
    1:St:='Download Protocols';
    2:St:='Upload Protocols';
    3:St:='Batch Download Protocols';
    4:St:='Batch Upload Protocols';
  End;
  Repeat
  WriteHdr(ST);
  Writeln;
  For Cnt:=1 to Size Do Begin
    Tab(^P'['^O+Strr(Cnt)+^P'] '^S+AllPRec[Cnt].Desc+^A,35);
    Writeln(^A'('^S+UpString(AllPrec[Cnt].ProgName)+^A')');
  End;
  Writeln;
  Repeat
    Buflen:=1;
    Write(^P'['^O'N'^P']ew Protocol, ['^O'E'^P']dit, ['^O'D'^P']elete,'+
          ' ['^O'Q'^P']uit [ ]'+B_(2));
    WriteStr('&');
    K:=Upcase(inpt[1]);
  Until K in ['N','E','D','Q'];
  Done:=False;
  Case K Of
    'N':CreateProto;
    'E':Begin
         WriteStr(^P'Edit Which? '^O'['^S'1..'+strr(Size)+^O']: &');
         If (Valu(inpt)>0) and (Valu(inpt)<=Size) Then
         EditProto(Valu(inpt));
        End;
    'D':DeleteProto;
    'Q':Done:=True;
  End;
  Until Done;
  Assign(PFile,WhichFile);
  Rewrite(PFile);
  For Cnt:=1 to Size Do nWrite(Pfile,AllPrec[Cnt]);
  Close(Pfile);
End;

Procedure EditWhich;
VAR K:Char;
    Done:Boolean;
Begin
  Done:=False;
  Repeat
  WriteHdr('Protocol Editing');
  Writeln;
  Writeln(^P'['^O'1'^P'] '^S'Edit Download Protocols');
  Writeln(^P'['^O'2'^P'] '^S'Edit Upload Protocols');
  Writeln(^P'['^O'3'^P'] '^S'Edit Batch Download Protocols');
  Writeln(^P'['^O'4'^P'] '^S'Edit Batch Upload Protocol'^M);
  Repeat
    BufLen:=1;
    Write(^R'Edit Which Protocols? '^P'['^O'Q'^P']uits [ ]'+B_(2));
    WriteStr('&');
    K:=Upcase(inpt[1]);
  Until K in ['1'..'4','Q'];
  Case K Of
    '1'..'4':Edit(Valu(K));
    'Q':Done:=True;
  End;
  Until Done;
End;

Procedure ProtoEditor; {AN INTERNAL PROTO EDITOR IS MUCH BETTER!}
Begin
  Writelog(0,0,'Entered Protcol Editor');
  EditWhich;
End;
*)

begin
end.
