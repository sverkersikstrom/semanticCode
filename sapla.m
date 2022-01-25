function [r s]=sapla(s,inputwords)
if 0
    %Exmple call to 'sapl'
    s=[];
    [r s]=sapla(s,'warm greek german');
end
if nargin<1 | isempty(s)
    %load('/Users/sverkersikstrom/Documents/Dokuments/Artiklar_in_progress/Semantic_spaces/ngram/english/spaceEnglish.mat')
    load('/Users/sverkersikstrom/Dropbox/ngram/spaceEnglish.mat')
%   load('/Users/sverkersikstrom/Documents/Dokuments/Artiklar_in_progress/Semantic_spaces/ngram/english/spaceEnglishSUM.mat')
    try;
        try
            s=sSUM;
        end
        fil='/Users/sverkersikstrom/Documents/Dokuments/Artiklar_in_progress/Semantic_spaces/ngram/english/qualitysandberg.txt';
        testSpaceQuality(s,fil,0,s.Ndim,1);
        clear sSUM;
    end
end
if nargin>=2
    r=saplaString(s,inputwords);
    return
end

if 0
    f=s.f;
    f(isnan(f))=0;
    [tmp indexF]=sort(f,'descend');
    maxF=3000;
    maxF=length(indexF);
    for i=1:min(3000,maxF)
        fprintf('%s ',s.fwords{indexF(i)});
    end
    fprintf('\n')
    pr=0;
end

while 1
    inputwords = input('What do people think about SCALE WORD1 WORD2: ','s');
    saplaString(s,inputwords);
end

function r=saplaString(s,inputWords)
r.text='';
words=cell2string(inputWords);
N=length(words);
r.missing=[];
for i=1:N
    index(i)=word2index(s,words{i});
    if isnan(index(i)) %| indexF(index(i))>maxF
        r.missing=[r.missing sprintf('%s ',words{i})];
        if not(isnan(index(i)))
            fprintf('SAKNAS: %d ',indexF(index(i)));
        end
        ok(i)=0;
    else
        ok(i)=1;
        [sim indexS]=semanticSearch(s.x,s.x(index(i),:));
        fprintf('%s\n',cell2string(s.fwords(indexS(1:10))));
    end
end
if length(r.missing)>0
    fprintf('Missing word(s): %s',r.missing);
end

k=0;
for i=1:N
    for j=i+1:N
        k=k+1;
        if ok(i) & ok(j) | 1
            if isnan(index(i)) | isnan(index(j))
                d(k)=NaN;
            else
                d(k)=sum(s.x(index(i),:).*s.x(index(j),:));
                %fprintf('%s %s %.2f\n',words{i},words{j},d(k));
            end
        end
    end
end

if d(1)>d(2); sign='>'; else sign='<'; end
if length(words)>=3 & sum(ok)==3
    r.text=sprintf('%s: %s %.2f %s %.2f %s',words{1},words{2},d(1),sign,d(2),words{3});
    fprintf('%s\n',r.text);
end
fprintf('\n')

filename='saplaHistory.txt';
f=fopen(filename,'a');
fprintf(f,'%s\t%s\t%s\n',inputWords,r.text,datestr(now));
fclose(f);
