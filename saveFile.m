function saveFile(reportFilename,d,UTF)
fprintf('Saving report %s\n',reportFilename);
%f=fopen([reportFilename '.txt'],'w','n', 'Macintosh');%'UTF-8'
if nargin<3
    UTF= 'UTF-8';
end
f=fopen([reportFilename '.txt'],'w','n', UTF);%'UTF-8'
%xlswrite([reportFilename '.xls'],d)
[Nr Nc]=size(d);
isLIWC=find(strcmpi(d(1,:),'_liwcall'));
if not(isempty(isLIWC))
    [~,labels]=getLIWC(getSpace,1);
    d{1,isLIWC}=cell2string(labels,char(9));
    for i=2:size(d,1)
        d{i,isLIWC}=regexprep(d{i,isLIWC},' ',char(9));
    end
end
tmp2='';
for r=1:Nr
    for c=1:Nc
        tmp=str2double(d{r,c});
        if isnumeric(d{r,c})
            fprintf(f,'%f\t',d{r,c});
        elseif not(isnan(tmp))
            fprintf(f,'%f\t',tmp);
            d{r,c}=tmp;
        else
            tmp=d{r,c};
            if length(tmp)>0
                if not(isLIWC==c)
                    tmp=regexprep(tmp,char(9),char(32));
                end
                tmp=regexprep(tmp,char(10),char(32));
                tmp=regexprep(tmp,char(13),char(32));
            end
            if 0 & length(tmp)>32000 
                tmp2=tmp(32001:end);
                tmp=tmp(1:32000);
                fprintf('Placing large texts (32k>) in the last column!\n')
            end
            fprintf(f,'%s\t',tmp);
        end
    end
    while length(tmp2)>1
        fprintf(f,'%s\t',tmp2(1:min(end,32000)));
        tmp2=tmp2(min(end,32000):end);
    end
    fprintf(f,'\n');
end
fclose(f);
par=getPar;
if par.save2json
    savejson('data',d,[reportFilename '.json']);
end
