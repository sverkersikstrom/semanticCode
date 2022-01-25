function n=cell2num(c,type)
if nargin>1 %Two dimensions
    for i=1:size(c,1)
        for j=1:size(c,2)
            if isempty(c{i,j})
                n(i,j)=NaN;
            else
                n(i,j)=c{i,j};
            end
        end
    end
else %One dimensions (old)
    n(length(c))=0;
    for i=1:length(c)
        if isempty(c{i})
            n(i)=NaN;
        elseif ischar(c{i})
            n(i)=str2num(c{i});
        else
            n(i)=c{i};
        end
    end
end