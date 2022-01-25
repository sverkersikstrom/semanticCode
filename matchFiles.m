function matchFiles(file1,file2,matchColumn1,matchColumn2)
if nargin<1
    file1='emotionsCleared.xlsx';
end
if nargin<2
    file2='Limesurvey Semantic Affect Measure Facebook Rawdata 20161229.xlsx';
end
if nargin<3
    matchColumn1='surveyUserId';
end
if nargin<4
    matchColumn2='participantcode';
end

[d1, data1, dim1, labels1]=textread2(file1);
[d2, data2, dim2, labels2]=textread2(file2);
i1=find(strcmpi(labels1,matchColumn1));
i2=find(strcmpi(labels2,matchColumn2));
N1=size(d1);
N2=size(d2);
k=1;
dout=[labels1' labels2'];
for i=1:N2(1)
    if isnumeric(d2{i,i2})
        d2{i,i2}=num2str(d2{i,i2});
    end
end

for i=1:N1(1)
    if isnumeric(d1{i,i1})
        d1{i,i1}=num2str(d1{i,i1});
    end
    j=find(strcmpi(d1{i,i1},d2(:,i2)));
    if length(j)>1
        fprintf('File: %s, duplicate rows %d %d\n',file2,j(1),j(2))
        j=j(1);
    end
    if not(isempty(j))
        k=k+1;
        dout(k,:)=[d1(i,:) d2(j,:)];
    end
end
Nout=size(dout);
outfile=regexprep(['Matched-' file1 '-' file2],'.xlsx','');

fprintf('File: %s\t\trow=%d\tcol=%d\n',file1,N1(1),N1(2))
fprintf('File: %s\t\trow=%d\tcol=%d\n',file2,N2(1),N2(2))
fprintf('File: %s\t\trow=%d\tcol=%d\n',outfile,Nout(1),Nout(2))
saveFile(outfile,dout,'UTF-8')
