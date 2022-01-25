function translateFile(file,outFile,destLanguage,sourceLanguage);
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

f=fopen(file,'r','n', 'UTF-8');
fout=fopen(outFile,'w','n', 'UTF-8');
i=0;
while not(feof(f))
    t=[];
    while not(feof(f)) & length(t)<600
        t=[t fgets(f)];
    end
    i=i+1;if even(i,50); fprintf('.');end
    t(find(t==65533))=' ';
    tTranslated = gtranslate([],t, destLanguage, sourceLanguage,[],1);
    fprintf(fout,'%s\n',tTranslated);
end
fprintf('Done\n')

