Procedure DrawMain;
const
  IMAGEDATA : array [1..951] of Char = (
    #9 ,#17,'�',' ',#14,'V','i','S','i','O','N','/','2',' ','B','B','S',
    ' ','C','o','n','f','i','g','u','r','a','t','i','o','n',' ',#0 ,'�',
    ' ',#9 ,'R','u','t','h','l','e','s','s',' ','E','n','t','e','r','p',
    'r','i','s','e','s',' ','1','9','9','2',' ',#0 ,'�',' ',#7 ,'[',#15,
    'E','S','C',#7 ,']',' ',#15,'E','x','i','t','s',' ','P','r','o','g',
    'r','a','m',' ',#9 ,'�',#24,#24,#8 ,#16,'[',' ',#15,'S','y','s','t',
    'e','m',' ','S','p','e','c','i','f','i','c','a','t','i','o','n','s',
    ' ',#8 ,']',#24,'[',' ',#15,'P','a','t','h','n','a','m','e','s',#25,
    #12,#8 ,']',#24,'[',' ',#15,'M','o','d','e','m',' ','T','e','x','t',
    #25,#11,#8 ,']',#25,#3 ,#12,'�',#25,#5 ,'�',#25,#27,#6 ,'�','�','�',
    #20,'�',#12,'�','�',#22,'�',#16,'�','�','�',#24,#8 ,'[',' ',#15,'S',
    'u','p','p','o','r','t','e','d',' ','B','a','u','d',' ','R','a','t',
    'e','s',' ',' ',#8 ,']',#25,#3 ,#12,#20,'�',#16,'�',#25,#3 ,'�',#25,
    #23,'�',' ',' ',#4 ,'�',#6 ,'�',#4 ,'�','�',#25,#2 ,'�','�',#6 ,'�',
    #12,#22,'�',#16,'�','�',#24,#8 ,'[',' ',#15,'D','o','w','n','l','o',
    'a','d',' ','B','a','u','d',' ','R','a','t','e','s',#25,#2 ,#8 ,']',
    #25,#4 ,#12,#20,'�',#16,#25,#2 ,#4 ,'�',#12,'�',' ',#14,'�','�',' ',
    #12,'�','�','�','�',' ',#14,'�',' ',' ',#12,'�','�',#25,#2 ,#20,'�',
    #16,'�','�',#25,#3 ,'�',#25,#7 ,#4 ,'�',#20,' ',#12,'�',#22,'�',#16,
    '�','�',#24,#8 ,'[',' ',#15,'D','e','f','a','u','l','t',' ','C','o',
    'l','o','r','s',#25,#7 ,#8 ,']',#25,#2 ,#1 ,'�','�',#4 ,'�','�',#1 ,
    '�',#4 ,'�',#12,#20,'�',#16,' ','�','�',#1 ,'�',#4 ,'�',#12,#20,'�',
    #1 ,#16,'�','�','�',#12,'�','�',#1 ,'�',#12,'�','�','�',#20,'�',#16,
    '�',#1 ,'�',#4 ,'�',#12,#20,'�','�',#16,'�',#1 ,'�','�',#12,'�',#4 ,
    '�',#1 ,'�','�',#9 ,'�',#1 ,'�','�',#4 ,'�','�','�',#6 ,#20,'�',#12,
    #22,'�',#20,'�',#16,'�',#1 ,'�','�',#24,#8 ,'[',' ',#15,'D','e','f',
    'a','u','l','t',' ','U','s','e','r',' ','A','c','c','o','u','n','t',
    's',' ',#8 ,']',#25,#4 ,#1 ,'�',#4 ,'�',#8 ,'�',#20,'�',#16,'�',#4 ,
    '�','�',#12,'�',#1 ,'�','�',#4 ,'�',#12,'�',#20,'�',#16,'�',#1 ,'�',
    #12,#20,'�',#4 ,#16,'�',#12,'�',#4 ,'�',#1 ,'�','�',#4 ,'�','�','�',
    '�','�','�','�',#1 ,'�',#4 ,'�','�',#1 ,'�','�','�',#4 ,'�',#20,' ',
    #6 ,'�',#12,'�','�',#16,'�','�',#1 ,'�','�',#24,#8 ,'[',' ',#15,'M',
    'a','t','r','i','x',' ','S','e','t','u','p',#25,#9 ,#8 ,']',#25,#6 ,
    '�','�',' ',#20,'�','�',#16,#25,#4 ,'�',#20,'�',#4 ,#16,'�',#8 ,'�',
    #20,'�',#16,' ',#20,'�',#16,'�',' ','�','�','�',#20,'�',#16,' ',' ',
    #20,'�','�','�',#16,#25,#2 ,#4 ,'�',#6 ,#20,'�',#12,'�','�','�',#16,
    '�','�','�','�','�',#20,'�','�',#16,'�','�','�',#24,#8 ,'[',' ',#15,
    'I','n','f','o','r','m','a','t','i','o','n',' ','F','o','r','m','s',
    #25,#4 ,#8 ,']',#25,#10,'�',#25,#3 ,'�','�','�',' ','�',#25,#2 ,'�',
    '�','�',' ',' ','�',#25,#2 ,'�',#25,#4 ,#6 ,#20,'�',#12,'�','�','�',
    '�','�','�',#4 ,#16,'�','�',#24,#8 ,'[',' ',#15,'R','e','q','u','i',
    'r','e','d',' ','L','e','v','e','l','s',#25,#6 ,#8 ,']',#25,#13,'�',
    '�',#25,#23,#4 ,#26,#3 ,'�',#24,#8 ,'[',' ',#15,'S','y','s','t','e',
    'm',' ','P','a','s','s','w','o','r','d','s',#25,#5 ,#8 ,']',#24,'[',
    ' ',#15,'F','i','l','e',' ','S','e','c','t','i','o','n',#25,#9 ,#8 ,
    ']',#24,'[',' ',#15,'M','e','s','s','a','g','e',' ','S','e','c','t',
    'i','o','n',#25,#6 ,#8 ,']',#24,'[',' ',#15,'L','o','o','k',' ','a',
    'n','d',' ','F','e','e','l',#25,#8 ,#8 ,']',#24,'[',' ',#15,'N','e',
    'w',' ','U','s','e','r',' ','V','o','t','i','n','g',#25,#6 ,#8 ,']',
    #24,'[',' ',#15,'L','o','o','k','/','F','e','e','l',' ',']','[',#25,
    #9 ,#8 ,']',#24,'[',' ',#15,'M','e','n','u',' ','N','a','m','e','s',
    #25,#11,#8 ,']',#24,'[',' ',#15,'U','s','e','r',' ','T','i','m','e',
    ' ','P','e','r',' ','D','a','y',#25,#4 ,#8 ,']',#24,'[',' ',#15,'S',
    'h','e','l','l',' ','T','o',' ','D','O','S',#25,#9 ,#8 ,']',#24,'[',
    ' ',#15,'Q','u','i','t',' ','P','r','o','g','r','a','m',#25,#9 ,#8 ,
    ']',#24,#24,#9 ,#17,'�',#25,#10,#0 ,'�',#25,'A',#9 ,'�',#24,#24);
Begin
  Uncrunch(ImageData,ScreenAddr[0],951);
End;