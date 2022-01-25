function translateFile(file,outFile,destLanguage,sourceLanguage,columns,wordByWord);
%translateFile('_StudiesAll.txt','_StudiesAllSwedish.txt','sv','en');
%translateFile('StudiesAllData.txt','StudiesAllDataSwedish.txt','sv','en');
%translateFile('DATA Semantic Affect Question.txt','DATA Semantic Affect Question Swedish.txt','sv','en');
if nargin<1
    [file,PathName,FilterIndex] = uigetfile('*.txt','Open file to translate language from');
    if file==0 return; end
    file=[PathName file];
end
if nargin<2
    [outFile,PathName,FilterIndex] = uiputfile('*.txt','Name of the translated file',['translated' file]);
    if outFile==0 return; end
    outFile=[PathName outFile];
end
if nargin<3
    destLanguage=inputdlg2('Code of destination language','Code of destination language',1,{'sv'});
    destLanguage=destLanguage{1};
end
if nargin<4
    sourceLanguage=inputdlg2('Code of source file language','Code of source file language',1,{'en'});
    sourceLanguage=sourceLanguage{1};
end
if nargin<5
    columns=[];
end
if nargin<6
    wordByWord=0;
end

f=fopen(file,'r','n', 'UTF-8');
fout=fopen(outFile,'w','n', 'UTF-8');
i=0;tTranslated='';
if findstr(file,'.xlsx')
    [a, data, dim, labels]=textread2(file);
    fprintf(fout,'%s\n',cell2string(labels',char(9)));
    for i=1:size(a,1)
        if not(isempty(columns))
            for j=columns
                a{i,j}=convertCharacter(a{i,j});
                a{i,j} = gtranslate([],a{i,j}, destLanguage, sourceLanguage,[],wordByWord);
            end
            t=regexprep(cell2string(a(i,:),char(9)),char(10),'');
            tTranslated=convertCharacter(t);
        else
            t=regexprep(cell2string(a(i,:),char(9)),char(10),'');
            t=convertCharacter(t);
            tTranslated = gtranslate([],t, destLanguage, sourceLanguage,[],wordByWord);
        end
        fprintf(fout,'%s\n',tTranslated);
        if even(i,50); fprintf('.');end
    end
else
    
    while not(feof(f))
        if 1
            t=fgets(f);
        else
            t=[];
            while not(feof(f)) & length(t)<600
                t=[t fgets(f)];
            end
        end
        i=i+1;if even(i,50); fprintf('.');end
        %t(find(t==65533))=' ';
        t=regexprep(t,char(10),' ');
        t=regexprep(t,char(13),' ');
        if i==1960
            1;
        end
        if 0
            fprintf(fout,'%s\t%d\n',t,i);
        else
            tTranslated = gtranslate([],t, destLanguage, sourceLanguage,[],wordByWord);
            fprintf(fout,'%s\n',tTranslated);
        end
    end
end
fclose(f);
fclose(fout);
fprintf('Done\n')

