function s=setInfo(s,N,word,value,info)
if nargin==5
    [~, s]=getInfo(s,N,word,value,info);
else
    [~, s]=getInfo(s,N,word,value);
end
