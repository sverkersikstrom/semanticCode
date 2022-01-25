function translateSpace(file,outFile,destLanguage,sourceLanguage);
%translateFile('lang _StudiesAll.mat','lang _StudiesAllSwedish.txt','sv','en');
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

s=getNewSpace(file);
step=100;
for i=1:step:s.N
    index=i:min(s.N,i+step);
    words=s.fwords(index);
    if 0
        words=regexprep(words,' ','_');
        words=regexprep(words,'-','_');
        [trans trans2] = gtranslate([],cell2string(words), destLanguage, sourceLanguage,[],1);
        trans3=string2cell(trans);
    else
        [trans trans2] = gtranslate([],words, destLanguage, sourceLanguage,[],1);
    end
    for i=1:length(trans2)
        if not(s.fwords{index(i)}(1)=='_')
            fprintf('%d\t%s\t%s\n',index(i),s.fwords{index(i)},trans2{i});
            s.fwords{index(i)}=trans2{i};
        end
    end
end
s.languageCode=destLanguage;
saveSpace(s,outFile,1);
fprintf('Done\n')