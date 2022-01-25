function s=translateBack(s,languageFile,index)
%Print missing words (
persistent s2;
if isempty(s2) | not(strcmpi(s2.languagefile,languageFile))
    s2=getNewSpace(languageFile);
end
[x N Ntot t index s]=text2space(s,getText(s,textsSE.index));
missing=t(isnan(index))';
found=t(not(isnan(index)))';
fprintf('%s\n',cell2string(missing));
[xlatedString ,tTranslated]=gtranslate(s,missing,s2.languageCode,s.languageCode,[],1)
indexMatch=word2index(s2,tTranslated);
indexFound=find(not(isnan(indexMatch)));
fprintf('Missing=%d Match%d\n',length(find(isnan(indexMatch))),length(find(not(isnan(indexMatch)))))
fprintf('Missing: %s\n',cell2string(tTranslated(find(isnan(indexMatch))),', '))
fprintf('Found: %s\m',  cell2string(tTranslated(indexFound),', '))

for i=indexFound
    fprintf('%s\t%s\n',s.fwords{i},s2.fwords{i})
    info=s.info{indexMatch(i)};
    info.normalword=0;
    [s,N,word]=addX2space(s,missing{i},s.x(indexMatch(i),:),info);
end
s=updateContext(s,N);
