function [s j o]=binary_cluster(s,data,index,a,b,c)
if nargin>3 
    [s j o]=binary_clusterOLD(s,data,index,a,b,c);
    return
end
persistent row
if not(isfield(data,'j'))
    fprintf('Binary cluster\n');
    data.row=0;
    data.j=0;
    col=0;
    index=1:length(data.index);
    try;close(1);end
    figure(1);
    hold on
end
[y c1]=kmeansErrorSafe(data.x(index,:));
index1=index(find(y==1));
index2=index(find(y==2));
data.j=data.j+1;
data.cluster(data.j,index1)=1;

row1=row;
col1=col;
if length(index1)>2
    [s j data]=binary_cluster(s,data,index1);
else
    data.row=data.row+1;
    text(col,row,data.word{index1(1)});
    if length(index1)>1
        data.row=data.row+1;
        text(col,data.row,data.word{index1(2)});
    end
end
plot([col1 col1]-0.02,[row1 row]);
o.col1=col1;o.col2=col1;o.row1=row1;o.row2=row;
global xdiff;

if length(index2)>2
    [s j data]=binary_cluster(s,data,index2);
else
    data.row=data.row+1;
    text(col,data.row,data.word{index2(1)});
    if length(index2)>1
        data.row=data.row+1;
        text(col,data.row,data-word{index2(2)});
    end
end
col2=get(gca,'Xlim');
set(gca,'Xlim',[-.2 max(col2(2), col)]);
set(gca,'Ylim',[0 row]);


function [y c1]=kmeansErrorSafe(x);
y=[];c1=[];
error=1;i=1;
while error & i<20
    try
        [y c1]=kmeans(x,2,'Maxiter',500,'distance','cosine');
        error=0;
    catch
        i=i+1;
        error=1;
    end
end

%OLD
function [s j o]=binary_clusterOLD(s,data,x,word,j,col)
persistent row
if j==0
    fprintf('Binary cluster\n');
    row=0;
    col=0;
    try;close(1);end
    figure(1);
    hold on
end

[y c1]=kmeansErrorSafe(x);
index1=find(y==1);
index2=find(y==2);
j=j+1;
data.cluster(j,index1)=1;
if 0 %Print
    fprintf('Binarycluster %dA:\n',j);
    for i=1:length(index1);fprintf('%s+',word{index1(i)});end
    fprintf('\n');
    
    fprintf('Binarycluster %dB:\n',j);
    for i=1:length(index2);fprintf('%s+',word{index2(i)});end
    fprintf('\n\n');
end


row1=row;
col1=col;
if length(index1)>2
    [s j data]=binary_cluster(s,data,x(index1,:),word(index1),j,col+.5);
else
    row=row+1;
    text(col,row,word{index1(1)});
    if length(index1)>1
        row=row+1;
        text(col,row,word{index1(2)});
    end
end
plot([col1 col1]-0.02,[row1 row]);
o.col1=col1;o.col2=col1;o.row1=row1;o.row2=row;
global xdiff;

if length(index2)>2
    [s j data]=binary_cluster(s,data,x(index2,:),word(index2),j,col+.5);
else
    row=row+1;
    %  semanticSearch(x(index2(1),:),x(index221),:))
    text(col,row,word{index2(1)});
    if length(index2)>1
        row=row+1;
        text(col,row,word{index2(2)});
    end
end
col2=get(gca,'Xlim');
set(gca,'Xlim',[-.2 max(col2(2), col)]);
set(gca,'Ylim',[0 row]);

