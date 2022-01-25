function [x N Ntot t index s]=text2space(s,texts,indexText)
if nargin<3; indexText=NaN;end
if iscell(texts)
    x(length(texts),s.Ndim)=NaN;
    index=[];t=[];
    for i=1:length(texts);
        [xone N(i) Ntot(i) t1 index1 s]=text2space(s,texts{i});
        index=[index index1];
        t=[t t1];
        x(i,:)=xone;
        if even(i,1000); fprintf('.'); end
    end
    N=sum(N);Ntot=sum(Ntot);
    return
end

if isnumeric(texts)
    texts=num2str(texts);
    fprintf('Warning a numerical value is found where text data is expected!\n')
end

[index t s]=text2index(s,texts);

x=zeros(length(index),size(s.x,2));

Ntot=length(t);
N=0;
if length(index)==0
    index=[];
elseif 1
    indexOk=index>0 & not(isnan(index)) & index<=s.N;
    x(indexOk,:)=s.x(index(indexOk),:);
    [x, tmp, s, N]=average_vector(s,x,index,[],indexText);
% else %Old code 2018-04-27
%     for j=1:length(index)
%         if not(isnan(index(j))) & index(j)<=s.N & index(j)>0
%             N=N+1;
%             x(N,:)=s.x(index(j),:);
%         else
%             index(j)=0;
%         end
%     end
%     [x, tmp, s, N]=average_vector(s,x(1:N,:),index,[],indexText);
end


