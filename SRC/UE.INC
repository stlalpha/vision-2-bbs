Procedure DrawUserEditor;
const
  IMAGEDATA_WIDTH=80;
  IMAGEDATA_DEPTH=25;
  IMAGEDATA_LENGTH=842;
  IMAGEDATA : array [1..842] of Char = (
    #9 ,#17,'�',' ',#15,'V','i','S','i','O','N','/','2',' ','U','s','e',
    'r',' ','E','d','i','t','o','r',' ',#9 ,'�',' ',#11,'[','F','1',']',
    ' ','E','d','i','t',' ','F','l','a','g','s',' ',#9 ,'�',' ',#11,'[',
    'E','S','C',']',' ','E','x','i','t',' ','N','o',' ','S','a','v','e',
    ' ',#9 ,'�',' ',#11,'[','F','1','0',']',' ','S','a','v','e','s',#25,
    #3 ,#9 ,'�',#24,#24,#16,' ',#8 ,'[',#15,'A','l','i','a','s',#8 ,']',
    #5 ,':',#25,#39,#8 ,'[',#15,'T','i','m','e',' ','i','n',' ','B','a',
    'n','k',#8 ,']',#5 ,':',#24,' ',#8 ,'[',#15,'R','e','a','l',' ','N',
    'a','m','e',#8 ,']',#5 ,':',#25,'#',#8 ,'[',#15,'M','e','s','s','a',
    'g','e',' ','H','e','a','d','e','r',#8 ,']',#5 ,':',#24,' ',#8 ,'[',
    #15,'P','a','s','s','w','o','r','d',#8 ,']',#5 ,':',#25,'$',#8 ,'[',
    #15,'A','l','l','o','w',' ','i','n',' ','N','e','t',#8 ,']',#5 ,':',
    #24,' ',#8 ,'[',#15,'P','h','o','n','e',' ','#',#8 ,']',#5 ,':',#25,
    '%',#8 ,'[',#15,'C','a','n',' ','R','e','q','u','e','s','t',' ','C',
    'h','a','t',#8 ,']',#5 ,':',#24,' ',#8 ,'[',#15,'M','a','i','n',' ',
    'L','e','v','e','l',#8 ,']',#5 ,':',#25,'"',#8 ,'[',#15,'C','a','n',
    ' ','S','e','n','d',' ','M','a','i','l',#8 ,']',#5 ,':',#24,' ',#8 ,
    '[',#15,'F','i','l','e',' ','L','e','v','e','l',#8 ,']',#5 ,':',#25,
    '"',#8 ,'[',#15,'F','u','l','l',' ','S','c','r','e','e','n',' ','E',
    'd','i','t','o','r',#8 ,']',#5 ,':',#24,' ',#8 ,'[',#15,'F','i','l',
    'e',' ','P','t','s',#8 ,']',#5 ,':',#25,'$',#8 ,'[',#15,'H','o','t',
    ' ','K','e','y','s',#8 ,']',#5 ,':',#24,' ',#8 ,'[',#15,'R','e','q',
    'u','i','r','e','d',' ','U','D',' ','R','a','t','i','o',#8 ,']',#5 ,
    ':',#25,#27,#8 ,'[',#15,'U','s','e',' ','A','r','r','o','w',' ','K',
    'e','y','s',#8 ,']',#5 ,':',#24,' ',#8 ,'[',#15,'R','e','q','u','i',
    'r','e','d',' ','U','D',' ','K',' ','R','a','t','i','o',#8 ,']',#5 ,
    ':',#25,#25,#8 ,'[',#15,'S','h','o','w',' ','R','u','m','o','r','s',
    #8 ,']',#5 ,':',#24,' ',#8 ,'[',#15,'D','a','i','l','y',' ','K','i',
    'l','o','b','y','t','e',' ','L','i','m','i','t',#8 ,']',#25,#25,'[',
    #15,'C','o','l','o','r',' ','#','1',#8 ,']',#5 ,':',#24,' ',#8 ,'[',
    #15,'R','e','q','u','i','r','e','d',' ','P','C','R',#8 ,']',#5 ,':',
    #25,' ',#8 ,'[',#15,'C','o','l','o','r',' ','#','2',#8 ,']',#5 ,':',
    #24,' ',#8 ,'[',#15,'R','e','q','u','i','r','e','d',' ','M','s','g',
    '.',' ','L','e','n','g','t','h',#8 ,']',#5 ,':',#25,#24,#8 ,'[',#15,
    'C','o','l','o','r',' ','#','3',#8 ,']',#5 ,':',#24,' ',#8 ,'[',#15,
    'T','o','t','a','l',' ','C','a','l','l','s',#8 ,']',#5 ,':',#25,'!',
    #8 ,'[',#15,'C','o','l','o','r',' ','#','4',#8 ,']',#5 ,':',#24,' ',
    #8 ,'[',#15,'U','p','l','o','a','d','s',#8 ,']',#5 ,':',#25,'%',#8 ,
    '[',#15,'C','o','l','o','r',' ','#','5',#8 ,']',#5 ,':',#24,' ',#8 ,
    '[',#15,'D','o','w','n','l','o','a','d','s',#8 ,']',#5 ,':',#25,'#',
    #8 ,'[',#15,'C','o','l','o','r',' ','#','6',#8 ,']',#5 ,':',#24,' ',
    #8 ,'[',#15,'U','p','l','o','a','d','e','d',' ',#39,'K',#39,#8 ,']',
    #5 ,':',#25,' ',#8 ,'[',#15,'C','o','l','o','r',' ','#','7',#8 ,']',
    #5 ,':',#24,' ',#8 ,'[',#15,'D','o','w','n','l','o','a','d','e','d',
    ' ',#39,'K',#39,#8 ,']',#5 ,':',#24,' ',#8 ,'[',#15,'T','o','t','a',
    'l',' ','P','o','s','t','s',#8 ,']',#5 ,':',#24,' ',#8 ,'[',#15,'P',
    'r','o','m','p','t',#8 ,']',#5 ,':',#24,' ',#8 ,'[',#15,'U','s','e',
    'r',' ','N','o','t','e',#8 ,']',#5 ,':',#24,' ',#8 ,'[',#15,'P','r',
    'i','v','a','t','e',' ','N','o','t','e',#8 ,']',#5 ,':',#24,#24,#9 ,
    #17,'�',#25,#7 ,'�',#25,'D','�',#24);
Begin
  Uncrunch(ImageData,ScreenAddr[0],842);
end;