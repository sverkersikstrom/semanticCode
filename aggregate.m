function aggregate(id,file)
%Aggregate data in report and save to text file
h=getHandles;
d=h.report.Data;%data to be aggregated taken from the report.
labels=d(1,:);%First columns are labels

if nargin<1 %Aggregates over identifers
    id={'_Country','_time'};
end

if nargin<2 %Output file
    file='aggregate.txt';
end

%Create unique items to aggreaget over
for j=1:length(id)
    i(j)=find(strcmpi(labels,id{j}));
    if j==1
        agg=d(2:size(d),i(j));
    else
        for k=1:size(d,1)-1
            agg{k}=[agg{k} num2str(d{k+1,i(j)})];
        end
    end
end
u=unique(agg(2:end));

%Aggregate
for j=1:length(u)
    index=find(strcmp(agg,u(j)))+1;
    if index(1)==1; index=index(2:end);end
    for k=1:size(d,2)
        fprintf('.')
        if isnumeric(d{2,k})
            d2{j,k}=nanmean(cell2num(d(index,k)));
        else
            d2{j,k}=cell2string(d(index,k)');
        end
    end
end
fprintf('.')

%Save to file
cell2file(d2,file,labels)



