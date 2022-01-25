function file=json2txtfile(file)
if nargin<1
    file='customerSatisfactions_2018_07_19.json';
end
file=regexprep(file,'.json','');

try
    d=loadjson([file '.json']);
catch
    f=fopen([file '.json'],'r','n','UTF-8');
    fileout=[file 'ok.json'];
    fout=fopen(fileout,'w','n','UTF-8');
    s='';
    while not(feof(f))
        json=fgets(f);
        %fprintf('%s',json');
        if findstr(json,'ObjectId(')>0
            json=regexprep(json,'ObjectId(','');
            json=regexprep(json,')','');
        end
        fprintf(fout,'%s',json);
        s=[s json];
    end
    fclose(f);
    fclose(fout);
    
    d=loadjson(s);
end

f=fields(d{1});
fout=fopen([file '.txt'],'w','n','UTF-8');
for i=1:length(f);
    fprintf(fout,'%s\t',f{i});
end
fprintf(fout,'\n');

for i=1:length(d);
    if 1 | (isfield(d{i},'message') & length(d{i}.message)>0)
        s='';
        for j=1:length(f);
            try
                a=eval(['d{i}.' f{j}]);
                if isnumeric(a)
                    t=sprintf('%d\t',a);
                else
                    t=sprintf('%s\t',regexprep(a,char(10),' '));
                end
            catch
                t=sprintf('\t');
            end
            s=[s t];
        end
        fprintf(fout,'%s\n',s);
        %fprintf('%s\n',s);
    end
end
fclose(fout);
file=[file '.txt'];

