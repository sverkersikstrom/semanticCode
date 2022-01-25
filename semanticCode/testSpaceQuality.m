function [q s]=testSpaceQuality(s,file,update,dim,ver);
q.optimalQuality=NaN;
q.quality=NaN;
q.optimalDim=NaN;
s.q=q; 
if nargin<1
    s=getSpace;
end
if nargin<2
    fprintf('Input: synonym-file with the first and the second representing high associates\n')
    [fil,PathName]=uigetfile2('*.txt','Choice synonymfile (two columns with associates)','synonymer_10k.txt');
    file=[PathName fil];
    if file(1)==0; return; end
end
if exist(file)==0 
    fprintf('Missing synonym-file: %s, aborting\n',file)
    return; 
end

if nargin<3
    update=0;
end
if nargin<4
    dim=[];
end
[s.N s.Ndim]=size(s.x);
if isempty(dim)
    dim=2.^[0:7];
    for i=1:9
        dim=[dim dim(end)+64];
    end
    dim=dim(find(dim<=s.Ndim));
    dim(length(dim)+1)=s.Ndim;
end
if nargin<5
    ver=0;
end

fprintf('Synonymfile: %s, version=%d\n',file,ver)
fprintf('Output (mean or median of): rank order of the associates divided by the the total number of words\n')
fprintf('A low scorce represent a high quality of the space.\nMedian number is typically lower than mean:\n')

f=fopen(file,'r');
i=0;
while not(feof(f))
    i=i+1;
    try
        ass{i}=string2cell(fgets(f));
        ass1{i}=ass{i}{1};
        ass2{i}=ass{i}{2};
    catch
        fprintf('Error reading file at row %d\n',i)
    end
end
fclose(f);

fprintf('\nCheck if these assocations looks ok:\n')
for i=1000:1003
    printAss(s,i);
end    
printAss(s,word2index(s,'london'));
fprintf('\n')
index=find(sum(abs(s.x'))==0);
s.x(index,:)=NaN;

smax=s.N;%15000;
s1=nan(1,length(ass));
s2=nan(1,length(ass));
indexNoNan=find(not(isnan(mean(s.x'))));
missing=[];
for k=1:length(dim)
    Ndim=dim(k);
    x=normalizeSpace(s.x(:,1:Ndim));
    j=0;
    order=[];order2=[];
    q.qualityWord=nan(1,length(ass));
    for i=1:length(ass)
        i1=word2index(s,lower(ass{i}{1}));
        if not(isempty(i1)) & i1<=smax
            i2=word2index(s,lower(ass{i}{2}));
            if not(isempty(i2)) & i2<=smax %Testing selected high frequency words!
                if ver==1
                    i3=word2index(s,lower(ass{i}{3}));
                    if not(isempty(i3)) & i3<=smax %Testing selected high frequency words!
                        [s1(i) index ]=semanticSearch(x(i1,1:Ndim),x(i2,1:Ndim));
                        [s2(i) index ]=semanticSearch(x(i1,1:Ndim),x(i3,1:Ndim));
                        if s1(i)==0 | s2(i)==0 | isnan(s1(i)+s2(i)); 
                            s1(i)=NaN;res='X';
                        else
                            if s1(i)<s2(i); 
                                res='<'; 
                                q.qualityWord(i)=1;
                            else
                                res='>'; 
                                q.qualityWord(i)=0;
                            end
                        end
                        if Ndim==max(dim)
                            fprintf('%s (%d)\t%s (%d)\t%.2f\t%s\t%.2f\t%s (%d)\n',ass{i}{1},not(isnan(i1)),ass{i}{2},not(isnan(i2)),s1(i),res,s2(i),ass{i}{3},not(isnan(i3)))
                        end
                    end
                else
                    if not(isnan(mean(x(i1,1:Ndim))) |  isnan(mean(x(i2,1:Ndim))))
                        j=j+1;
                        [s1 index ]=semanticSearch(x(indexNoNan,1:Ndim),x(i1,1:Ndim));
                        [order(j) order2(j)]=find(indexNoNan(index)==i2);
                        q.qualityWord(i)=order2(j)/length(indexNoNan);
                    end
                end
            else
                missing=[missing ' ' ass{i}{2}];
            end
        else
            missing=[missing ' ' ass{i}{1}];
        end
        if even(i,100) fprintf('.'); end
        if even(i,500000) | i==length(ass1)
            if ver==1
                index=find(not(isnan(s1+s2)));
                j=length(index);
                NnoNan=length(index);
                test=1.*(s1<=s2);
                test(find(isnan(s1+s2)))=NaN;
                quality=nanmean(s1(index)<=s2(index));
                qualityMean=NaN;
                fprintf('z=%.2f\n',(nanmean(s1)-nanmean(s2))/nanstd(s1-s2));
            else
                quality=nanmedian(order2)/length(indexNoNan);
                qualityMean=nanmean(order2)/length(indexNoNan);
            end
            q.qualityDim(k)=quality;
            q.Ndim(k)=Ndim;
            if Ndim==s.Ndim
                s.q.quality=quality;
            end
            fprintf('Quality of space %s is: median=%.5f, mean=%.3f, Ndimensions=%d,NWordInTest=%d NFoundWords=%d, NnotNaN=%d\n',s.filename,quality,qualityMean,Ndim, length(ass),j,length(indexNoNan))
        end
    end
end
if length(missing)>200; missing=[missing(1:200) '...AND MORE... N = ' num2str(length(missing))];end
fprintf('Missing words: %s\n',missing);

beep2

[tmp index]=min(q.qualityDim);
q.optimalDim=q.Ndim(index);
q.optimalQuality=q.qualityDim(index);

if update
    s.Ndim=q.optimalDim;
    s.x=normalizeSpace(s.x(:,1:s.Ndim));
    q.quality=q.optimalQuality;
    for i=1000:1003
        printAss(s,i);
    end
    fprintf('Optimizing the number of dimenesions to: %d, %.5f\n',q.optimalDim,q.optimalQuality)
else
    q.quality=q.qualityDim(end);
end

if isfield(s,'handles')
    s=getSpace('set',s);
end
s.quality=q.quality;
if ver==1
    s.qVer2=q;
else
    s.q=q;
end

function printAss(s,word);
try
    if isnumeric(word)
        i=word;
    else
        i=word2index(s,word);
    end
    if not(isnan(i))
        [similiarty index]=semanticSearch(s.x,s.x(i,:));
        fprintf('%s\n',cell2string(s.fwords(index(1:10))))
    end
end

function test
load('/Users/sverkersikstrom/Documents/Dokuments/Artiklar_in_progress/Semantic_spaces/ngram/english/spaceEnglish.mat')
%testSpaceQuality(s,'englishFiles/qualitysandberg.txt',0,[],1)
r=[];
r.SVDHistoryOne=nan(length(s.qSVDHistoryOne{1}.qualityWord),length(s.qSVDHistory));
r.SVDHistory=nan(length(s.qSVDHistoryOne{1}.qualityWord),length(s.qSVDHistory));
r.qVer2HistoryOne=nan(16,length(s.qSVDHistoryOne));
r.qVer2History=nan(16,length(s.qSVDHistoryOne));
'REMOVE 1 - 24'
for i=1:length(s.qSVDHistory)
    if not(isempty(s.qSVDHistoryOne{i}))
        r.SVDHistoryOne(:,i)=s.qSVDHistoryOne{i}.qualityWord;
        r.SVDHistory(:,i)=s.qSVDHistory{i}.qualityWord;
        try
            r.qVer2HistoryOne(:,i)=s.qVer2HistoryOne{i}.qualityWord(1:16);
            r.qVer2History(:,i)=s.qVer2History{i}.qualityWord(1:16);
        end
    end
end
nanstd(r.SVDHistoryOne')
nanstd(r.SVDHistory')
nanmedian(r.SVDHistoryOne')
nanmedian(r.SVDHistory')

nanstd(r.qVer2HistoryOne')
nanstd(r.qVer2History')
nanmean(r.qVer2HistoryOne')
nanmean(r.qVer2History')




