function fileRepeated(file,outFile,colMatch,colSplit)
%Merge two data files and match them on
if nargin<1
    file='results-one_week2.xlsx';
end
if nargin<2
    outFile='results-one_week3.txt';
end
[words, data, col, all_labels]=textread2(file,0);
if nargin<3
    colMatch='ProlificID';
end
colMatch=find(strcmp(all_labels,colMatch));
if nargin<4
    colSplit='time';
end
colSplit=find(strcmp(all_labels,colSplit));
set=zeros(1,size(words,1));
set(find(not(data(:,colSplit)==1)))=1;
%set=[zeros(1,117) ones(1,90)];

words2=words(find(not(set)),:);
for i=find(not(set))
    j=find(strcmp(words{i,colMatch},words(:,colMatch)));
    if length(j)>1
        j=j(2);
        words2(i,size(words,2)+1:size(words,2)+size(words,2))=words(j,:);
    end
end

for i=1:length(all_labels);
    all_labels2{i,1}=[all_labels{i} '2'];
end
all_labels3=[all_labels ; all_labels2];
cell2file(words2,outFile,all_labels3)
