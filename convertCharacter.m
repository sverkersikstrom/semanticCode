function s=convertCharacter(s,ver)
if nargin<2; ver='PC';end

if strcmpi(ver,'PC')
    s=regexprep(s,char([8730         214]),char(197));%å
    s=regexprep(s,char([8730         8226]),char(229));%å
    s=regexprep(s,char([8730         167]),char(228));%ä
    s=regexprep(s,char([8730         8706]),char(246));%ö
    s=regexprep(s,'_x000D_',' ');%ö
    s=regexprep(s,'&#39;','''');%ö
    s=regexprep(s,'&quot;','"');%ö
    
    
    
%     s=regexprep(s,char([65   204   138]) ,'1');%New
%     s=regexprep(s,char([69  204   129]) ,'2');%New
%     s=regexprep(s,char([65   204   136]) ,'3');%New
%     s=regexprep(s,char([ 111   204 136]) ,'4');%New
%     s=regexprep(s,char([ 97   204   136]) ,'5');%New
%     s=regexprep(s,char([ 229   177    72]) ,'6');%New

    %s=regexprep(s,'A?' ,'?');%New
%     s=regexprep(s,char([    79   204   136]) ,'7');%New
%     s=regexprep(s,char([    69   204   229]) ,'9');%New
%     s=regexprep(s,char([     69   204   129 ]) ,'9');%New
%     %s=regexprep(s,'O9','9');%New
%     s=regexprep(s,char(206),'9');%New
%     s=regexprep(s,char(143),'9');%New
%     s=regexprep(s,char(143),'9');%New
%     s=regexprep(s,char(148),'9');%New
%     s=regexprep(s,char(132),'9');%New
%     s=regexprep(s,char(138),'9');%New
%     s=regexprep(s,char(154),'9');%New
%     s=regexprep(s,char(129),'9');%New
%     s=regexprep(s,char(140),'9');%New
%     %s=fixchar(s);
else
    s = regexprep(s, '9','99');
    s = regexprep(s, '9','99');
    s = regexprep(s, '9','99');
    s = regexprep(s, '9','99');
    s = regexprep(s, '9','99');
    s = regexprep(s, '9','99');
end
