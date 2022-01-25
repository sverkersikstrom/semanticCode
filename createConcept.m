function createConcept(s,words);
if nargin<1
    s=getSpace;
end
if nargin<2
    [o, s]=getWordFromUser(s,'Startword');
    words{1}=o.input;
end
if ischar(words)
    words{1}=words;
end

cont=1;
number_of_ass2=s.par.number_of_ass2;
s.par.number_of_ass2=200;
remove=[]; removeWords='';
while cont
    [~,b,s]=getProperty(s,'_associates',words);
    index=text2index(s,b{1});
    
    index=index(find(not(isnan(index))));
    i=1;
    while i<length(index) & (not(isempty(find(index(i)==o.index))) | not(isempty(find(index(i)==remove))))
        i=i+1;
    end
    s.par.number_of_ass2=i+200;
    feedback=questdlg(['Add word ' s.fwords{index(i)}],'Create concept','Yes','No','Cancel','Yes');
    if strcmpi(feedback,'Yes')
        words{1}=[words{1} ' ' s.fwords{index(i)} ];
        o.index=[o.index index(i)];
    elseif strcmpi(feedback,'No')
        remove=[remove index(i)];
        removeWords=[removeWords ' ' s.fwords{index(i)}];
    elseif strcmpi(feedback,'Cancel')
        cont=0;
    end
    fprintf('Keep: %s\nRemove: %s\n',words{1},removeWords)
end
s.par.number_of_ass2=number_of_ass2;

1;

