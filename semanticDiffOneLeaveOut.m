function [x1_1 ry1_ xdiff s]=semanticDiffOneLeaveOut(s,axPlus,axNeg,data,property);
if nargin<3
    data=axPlus;
end
if nargin<4
    data=axPlus;
end

if nargin<5
    property=[];
end

if not(isempty(property)) & isnan(word2index(s,property))
    s=addX2space(s,property,[],[]);
end

x1_1=nan(1,length(data.index));
ry1_=x1_1;
xdiff=nan(1,s.Ndim);

if 1 %Faster code
    N=10;
    group=fix(N*(1:length(data.index))/length(data.index));
    resetRandomGenator(s);
    [~, indexRand]=sort(rand(1,length(data.index)));
    group=group(indexRand);
    if not(isfield(s.par,'semanticTestkeepDuplicates'))
        s.par.semanticTestkeepDuplicates=1;
    end
    for i=0:N
        remove=find(group==i);
        index=ones(1,length(axPlus.index));
        
        for j=1:length(remove)
            indexRemove=find(axPlus.index==data.index(remove(j)));
            if s.par.semanticTestkeepDuplicates & length(indexRemove)>1
                indexRemove=indexRemove(1);
            end
            index(indexRemove)=0;
        end
        axPlus.x1=average_vector(s,axPlus.x(find(index),:));%Remove the i'th index from 1
        axPlus.x1(isnan(axPlus.x1))=0;
        
        index=ones(1,length(axNeg.index));
        for j=1:length(remove)
            indexRemove=find(axNeg.index==data.index(remove(j)));
            if s.par.semanticTestkeepDuplicates & length(indexRemove)>1
                indexRemove=indexRemove(1);
            end
            index(indexRemove)=0;            
        end
        axNeg.x1=average_vector(s,axNeg.x(find(index),:));
        axNeg.x1(isnan(axNeg.x1))=0;
        
        if isempty(axNeg.x1) | isempty(axPlus.x1)
            return
        end
        xdiff=axPlus.x1-axNeg.x1;
        denominator=sum(xdiff.^2)^.5;
        if denominator==0
            xdiff=NaN;
        else
            xdiff=xdiff/denominator;
        end
        
        for j=1:length(remove);
            j2=remove(j);
            x1_1(j2)=sum(xdiff.*data.x(j2,:));%Distance to centroid 1
            if length(property)>1 & not(isnan(data.index(j2)))
                eval(['s.info{data.index(j2)}.' property(2:length(property)) '=x1_1(j2);']);
            end
            ry1_(j2)=sum((axPlus.x1/2+axNeg.x1/2).*data.x(j2,:));%Distance to centroid 1+2
        end
    end
else
    for i=1:length(data.index)
        index=find(not(axPlus.index==data.index(i)));
        axPlus.x1=average_vector(s,axPlus.x(index,:));%Remove the i'th index from 1
        index=find(not(axNeg.index==data.index(i)));
        axNeg.x1=average_vector(s,axNeg.x(index,:));
        
        xdiff=axPlus.x1-axNeg.x1;
        denominator=sum(xdiff.^2)^.5;
        if denominator==0
            xdiff=NaN;
        else
            xdiff=xdiff/denominator;
        end
        x1_1(i)=sum(xdiff.*data.x(i,:));%Distance to centroid 1
        if length(property)>1
            eval(['s.info{data.index(i)}.' property(2:length(property)) '=x1_1(i);']);
        end
        
        ry1_(i)=sum((axPlus.x1/2+axNeg.x1/2).*data.x(i,:));%Distance to centroid 1+2
    end
end

if not(isempty(property)) & isnan(word2index(s,property))
    s=addX2space(s,property,[],[]);
end
