function d=similiarity(x1,x2);
if ischar(x1)
    s=getSpace;
    x1=s.x(word2index(s,x1),:);
    x2=s.x(word2index(s,x2),:);
end
d=x1*x2';