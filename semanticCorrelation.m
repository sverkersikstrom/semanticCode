function [out s]=semanticCorrelation(s,index1,index2)
if nargin<1
    s=getSpace;
end
if nargin<2
    [wordset1 s]=getWordFromUser(s,'Choose set1 text identifier for semantic correlation');
    index1=wordset1.index;
    out.texts=s.par.variableToCreateSemanticRepresentationFrom;
end
d1=getX(s,index1);
if nargin<3
    [wordset2 s]=getWordFromUser(s,'Choose set2 text identifier for semantic correlation');
    index2=wordset2.index;
    out.texts=[out.texts ' - ' s.par.variableToCreateSemanticRepresentationFrom];
end
d2=getX(s,index2);
if not(length(index1)==length(index2))
    info.results=sprintf('Error. Length of the text identifier must match!\n');
    fprintf('%s\n',info.results);
    return
end

%Pariwise semantic similarities
out.algorithm=s.par.semanticCorrelationAlgorithm;
if strcmpi(s.par.semanticCorrelationAlgorithm,'similarity')
    sim=sum(d1.x'.*d2.x');
    
    %Random pairwise semantic similarities
    for i=1:100
        [~,indexRand]=sort(rand(1,length(index1)));
        simRand(i,:)=sum(d1.x'.*d2.x(indexRand,:)');
    end
    m=    nanmean(sim);
    mRand=nanmean(simRand);
    t=(m-nanmean(mRand))/nanstd(mRand);
    
    out.comment1='Descriptive statistics';
    out.n=length(index1);
    out.MeanSemanticScaleSet1=m;
    out.MeanSemanticScaleSet2=nanmean(mRand);
    out.StdSemanticScaleSet2=nanstd(mRand);
    
    [h,p,ci,stats] = ttest(-mRand,-m);%,'Tail','right'
    out.comment2='Inferential statistics and related information';
    out.p=p;
    out.t=stats.tstat;
    out.cohensD=t;
    out.df=stats.df;
elseif strcmpi(s.par.semanticCorrelationAlgorithm,'canonical')
    indexOk=not(isnan(mean(d1.x'+d2.x')));
    [A,B,r,U,V,statsCC] = canoncorr(d1.x(indexOk,:),d2.x(indexOk,:));
    r=sprintf('\nCanonical correlation:\nDimensions\tp\tF\n');
    for i=1:min(40,length(r))
        r=[r sprintf('%d\t%.4f\t%.4f\n',i,statsCC.p(i),statsCC.F(i))];
    end
    out.results=r;
else    
    [r,p]=nancorr(reshape(d1.x,[size(d1.x,1)*size(d1.x,2),1]),reshape(d2.x,[size(d2.x,1)*size(d2.x,2),1]));
    out.comment1='Descriptive statistics';
    out.r=r;
    out.p=p;
    out.n=size(d1.x,1)*size(d1.x,2);
end

out.results=regexprep(struct2text(out,[],0),'par.','');
out.results=addComments(out.results);

if not(s.par.excelServer)
    fprintf('%s',out.results)
end

