function s=fixchar(s)
s = regexprep(s,'ö', '�');
s = regexprep(s,'ä', '�');
s = regexprep(s,'å', '�');
s = regexprep(s,'Å', '�');
s = regexprep(s,'Ä', '�');
s = regexprep(s,'Ö', '�');

