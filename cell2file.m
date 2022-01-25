function cell2file(cell,file,labels)
f=fopen(file,'w','n','utf-8');

if nargin>=3
    for i=1:length(labels)
        fprintf(f,'%s\t',labels{i});
    end
    fprintf(f,'\n');
end

for row=1:size(cell,1)
    for col=1:size(cell,2)
        if isnumeric(cell{row,col})
            if cell{row,col}-round(cell{row,col})==0
                fprintf(f,'%d\t',cell{row,col});
            else
                fprintf(f,'%f\t',cell{row,col});
            end
        else
            tmp=regexprep(regexprep(cell{row,col},char(9),' '),char(10),' ');
            if length(cell{row,col})>30000
                fprintf('Row %d col %d-%s exceedes 30000 limit\n',row,col,labels{col})
                fprintf(f,'%s\t',tmp(1:30000));
            else
                fprintf(f,'%s\t',tmp);
            end
        end
    end
    fprintf(f,'\n');
end
fclose(f);
