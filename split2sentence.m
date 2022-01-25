function  splitword=split2sentence(context);
splitword=[];
split=[];
splitchar='.,!?';
for j=1:length(splitchar)
    split=[split findstr(context,splitchar(j))];
end
split=sort(split);
jlast=1;
if length(split)==0
    splitword{1}=context;
else
    for j=1:length(split)
        splitword{j}=context(jlast:split(j));
        jlast=split(j)+1;
    end
end