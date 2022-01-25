function r=strcmp2(s,i,j,word,wordIndex)
global ij;
if isnumeric(word) 
    if i==word 
        ij=j;r=1; 
    elseif j==word 
        ij=i;r=1; 
    else
        r=0;
    end
elseif 1 %ischar(word)
    if isnan(j)
        r=0;
    elseif strcmpi(s.fwords{i},word)
        ij=word2index(s,j);
        r=not(isnan(ij));
    elseif strcmpi(s.fwords{j},word)
        ij=word2index(s,i);
        r=not(isnan(ij));
    else
        r=0;
    end
else %if ischar(word)
    if isnumeric(i)
        i=s.fwords{i};
    end
    if isnumeric(j) & not(isnan(j))
        j=s.fwords{j};
    end
    if strcmpi(i,word)
        ij=word2index(s,j);
        r=not(isnan(ij));
    elseif strcmpi(j,word)
        ij=word2index(s,i);
        r=not(isnan(ij));
    else
        r=0;
    end
end
