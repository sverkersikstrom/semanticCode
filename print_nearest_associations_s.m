function [d, index,text,out,neighbours]=print_nearest_associations_s(s,type,x,order,header,o1,o2);
if nargin<4
    order='descend';
end
if nargin<5
    header='';
end
if nargin<6
    o1=NaN;
end
if nargin<7
    o2=NaN;
end

N=s.par.number_of_ass2;


if ischar(x)
    [tmp,s]=getWord(s,x);x=tmp.x;
end

x=average_vector(s,x);
dorg=shiftdim(s.x(1:s.N,1:size(x,2))*shiftdim(x,1),1);

[d index]=sort(dorg,order);
neighbours=sum(max(0,dorg).^5);

printDistance=s.par.printDistance;

if length(s.par.semanticSelectWords)>0
    if isnumeric(s.par.semanticSelectWords)
        indexSelectedWords=s.par.semanticSelectWords;
        selected=zeros(1,s.N);
        selected(indexSelectedWords)=1;
    else
        indexSelectedWords=text2index(s,s.par.semanticSelectWords);
        selected=zeros(1,s.N);
        selected(indexSelectedWords(find(not(isnan(indexSelectedWords)))))=1;
    end
else
    selected=ones(1,s.N);
end
selected=selected & not(isnan(dorg));

out.indexClose=[];
out.dClose=[];
text='';

if strcmpi(type,'closest') | strcmpi(type,'noprint')  | strcmpi(type,'print') | length(type)==0
    if length(header)>0 header=[': ' header];end
    text=[text sprintf('%s',header)];
    j=1;i=1;
    if isfield(s.par,'associatesStart')
        i=s.par.associatesStart;
        j=i;N=N+i-1;
    end
    while i<=N & j<=length(index)
        if selected(index(j)) & not(s.par.remove_underscore_words & s.fwords{index(j)}(1)=='_') & not(s.par.remove_normal_words & not(s.fwords{index(j)}(1)=='_')) & abs(d(j)-1)>1e-6
            out.indexClose=[out.indexClose index(j)];
            text=[text sprintf('%s ',s.fwords{index(j)})];
            out.dClose(i)=d(j);
            if printDistance
                text=[text sprintf('%.2f ',d(j))];
            end
            i=i+1;
        end
        j=j+1;
    end
end
out.indexFurthest=[];
if strcmpi(type,'furthest') | strcmpi(type,'print') | length(type)==0
    text=[text sprintf('\nFURTHEST %s: ',header)];
    j=1;i=1;
    while i<=N & j<=length(index)
        k=index(length(index)+1-j);
        word=[s.fwords{k} ' '];
        if selected(k) & not(s.par.remove_underscore_words & word(1)=='_') & not(s.par.remove_normal_words & not(word(1)=='_')) & abs(d(j)-1)>1e-6
            out.indexFurthest=[out.indexFurthest k];
            out.dFurthest(i)=d(length(index)+1-j);
            text=[text sprintf('%s ',s.fwords{k})];
            if printDistance
                text=[text sprintf('%.2f ',d(length(index)+1-j))];
            end
            i=i+1;
        end
        j=j+1;
    end
end
if strcmpi(type,'print')
    fprintf([text '\n']);
end


