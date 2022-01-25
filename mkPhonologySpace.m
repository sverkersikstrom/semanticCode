function mkPhonologySpace(s)
if nargin<1
    s=getSpace;
end
file=[regexprep(s.filename,'\.mat','') 'Phonology.txt'];
file=regexprep(file,'space','');
f=fopen(file,'w');
for i=1:10%length(s.fwords)
    if not(s.fwords{i}(1)=='_') 
        p=word2phonology(s.fwords{i});
        fprintf(f,'%s\n',p);
    end
end
fclose(f);
