function s=cell2string(c,seperator)
if nargin<2
    seperator=' ';
end
s='';
for i=1:size(c,1)
    for j=1:size(c,2)
        if isnumeric(c{i,j})
            s=[s seperator num2str(c{i,j})];
        else
            s=[s seperator c{i,j}];
        end
    end
    if size(c,1)>i
        s=[s char(13) ]; %c{i,j}
    end
end
if nargin>1 & length(c)>0
    s=s(2:end);
end