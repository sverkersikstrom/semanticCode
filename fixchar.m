function s=fixchar(s)
s = regexprep(s,'Ã¶', 'ö');
s = regexprep(s,'Ã¤', 'ä');
s = regexprep(s,'Ã¥', 'å');
s = regexprep(s,'Ã…', 'Å');
s = regexprep(s,'Ã„', 'Ä');
s = regexprep(s,'Ã–', 'Ö');

