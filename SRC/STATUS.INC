Procedure DrawStatus;
const
  IMAGEDATA : array [1..627] of Char = (
    #1 ,#16,'�',#26,'M','�','�',#24,'�',#8 ,'[',#15,'U','s','e','r',' ',
    'O','n','l','i','n','e',#8 ,']',':',#25,#24,'[',#15,'T','i','m','e',
    ' ','L','e','f','t',#8 ,']',':',#25,#6 ,'[',#15,'M','i','n','u','t',
    'e','s',' ','O','n',#8 ,']',':',#25,#6 ,#1 ,'�',#24,'�',#8 ,'[',#15,
    'U','s','e','r',' ','N','o','t','e',#8 ,']',' ',' ',':',#25,'?',#1 ,
    '�',#24,'�',#8 ,'[',#15,'U','s','e','r',' ','L','e','v','e','l',#8 ,
    ']',' ',':',#25,#24,'[',#15,'T','i','m','e',' ','N','o','w',#8 ,']',
    ' ',':',#25,#6 ,'[',#15,'D','a','t','e',' ','N','o','w',#8 ,']',':',
    #25,#8 ,#1 ,'�',#24,'�',#8 ,'[',#15,'F','i','l','e',' ','L','e','v',
    'e','l',#8 ,']',' ',':',#25,#24,'[',#15,'F','i','l','e',' ','P','t',
    's',#8 ,']',' ',':',#25,#6 ,'[',#15,'P','o','s','t','s',#8 ,']',':',
    #25,#11,#1 ,'�',#24,'�',#8 ,'[',#15,'F','l','a','g','s',#8 ,']',#25,
    #5 ,':',#25,#24,'[',#15,'C','a','l','l','s',#8 ,']',#25,#3 ,':',#25,
    #6 ,'[',#15,'P','C','R',#8 ,']',' ',' ',':',#25,#11,#1 ,'�',#24,'�',
    #25,'M','�',#24,'�',#8 ,'[',#15,'I','n','l','o','c','k',#8 ,']',':',
    #25,#4 ,'[',#15,'O','u','t','L','o','c','k',#8 ,']',':',#25,#4 ,'[',
    #15,'T','e','x','t','T','r','a','p',#8 ,']',':',#25,#4 ,'[',#15,'T',
    'e','m','p',' ','S','y','s','O','p',#8 ,']',':',#25,#4 ,'[',#15,'T',
    'i','m','e',' ','L','o','c','k',#8 ,']',':',#25,#2 ,#1 ,'�',#24,'�',
    #25,'M','�',#24,'�',#8 ,'[',#15,'C','h','a','t',' ','S','t','a','t',
    'u','s',#8 ,']',':',#25,'?',#1 ,'�',#24,'�',#25,'M','�',#24,'�','[',
    #9 ,'A','l','t','-','B',#1 ,']',':',' ',#12,'T','o','g','g','l','e',
    ' ','T','h','i','s',' ','S','c','r','e','e','n',#25,#10,#1 ,'[',#9 ,
    'A','l','t','-','T',#1 ,']',':',' ',#12,'T','e','m','p',' ','S','y',
    's','O','p',#25,#20,#1 ,'�',#24,'�','[',#9 ,'A','l','t','-','Z',#1 ,
    ']',':',' ',#12,'C','r','e','a','t','e',' ','L','i','n','e',' ','N',
    'o','i','s','e',#25,#11,#1 ,'[',#9 ,'A','l','t','-','E',#1 ,']',':',
    ' ',#12,'T','o','g','g','l','e',' ','T','e','x','t',' ','T','r','a',
    'p',#25,#14,#1 ,'�',#24,'�','[',#9 ,'F','9',#1 ,']',#25,#2 ,':',' ',
    #12,'L','o','c','k',' ','M','o','d','e','m',' ','I','n','p','u','t',
    #25,#12,#1 ,'[',#9 ,'A','l','t','-','A',#1 ,']',':',' ',#12,'T','o',
    'g','g','l','e',' ','C','h','a','t',' ','S','t','a','t','u','s',#25,
    #12,#1 ,'�',#24,'�','[',#9 ,'F','1','0',#1 ,']',' ',' ',':',' ',#12,
    'L','o','c','k',' ','M','o','d','e','m',' ','O','u','t','p','u','t',
    #25,#11,#1 ,'[',#9 ,'A','l','t','-','M',#1 ,']',':',' ',#12,'G','i',
    'v','e',' ','M','o','r','e',' ','T','i','m','e',#25,#16,#1 ,'�',#24,
    '�',#26,'M','�','�',#24,#24,#24,#24,#24,#24,#24,#24,#24,#24);
Begin
  Uncrunch(ImageData,ScreenAddr[25*160],627);
End;
