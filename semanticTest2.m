function [out s]=semanticTest2(s,o1,o2,property,index1,index2)
if not(isfield(o1,'x'))
    warning off;
    o1.x=o1;o1.index=index1;
    o2.x=o2;o2.index=index2;
    warning on
end

if nargin<4; property='';end
[x1 ry1_ xdiff1 s]=semanticDiffOneLeaveOut(s,o1,o2,o1,property);
[x2 ry1_ xdiff2 s]=semanticDiffOneLeaveOut(s,o1,o2,o2,property);

if length(x1)<2 | length(x2)<2
    p=NaN;
else
    [tmp p CI stats]=ttest2(x1,x2,.05,'right');
end

reg=([ones(1, length(x1)) zeros(1,length(x2))]');
try
    index=[o1.index o2.index];
catch
    index=[o1.index; o2.index]';
end


i1=find(not(isnan(x1)));
i2=find(not(isnan(x2)));


out.comment1='Descriptive statistics';
out.n1=length(find(not(isnan(x1))));
out.n2=length(find(not(isnan(x2))));
out.MeanSemanticScaleSet1=nanmean(x1);
out.MeanSemanticScaleSet2=nanmean(x2);
out.StdSemanticScaleSet1=nanstd(x1);
out.StdSemanticScaleSet2=nanstd(x2);
out.SemanticSimilarity=similarity(average_vector(s,o1.x),average_vector(s,o2.x));

out.comment2='Inferential statistics and related information';
out.p=p;
out.t=NaN;
out.cohensD=(out.MeanSemanticScaleSet1-out.MeanSemanticScaleSet2)/(nanvar(x1)+nanvar(x2))^.5;
out.df=out.n1+out.n2-2;

out.comment3='Supplementary aspects of the results';

reg=covariates(s,reg,s.par.covariateProperties,index);
if isempty([x1 x2]')
    out.r=NaN;
else
    [out.r pcovariate]=nancorr([x1 x2]',reg,'tail','right');
end
m12=mean([out.MeanSemanticScaleSet1 out.MeanSemanticScaleSet1]);
out.correct=nanmean([x1>=m12 x2<=m12] );
out.semanticTestMethod='';
out.associates='';
out.associatesFurthest='';
out.modelname='';
out.x1=NaN;
out.x2=NaN;
out.x=NaN;

if length(s.par.covariateProperties)>0
    out.pcovariates=pcovariate;
else
    out.pcovariates=NaN;    
end


out.t=(out.MeanSemanticScaleSet1-out.MeanSemanticScaleSet2)/(nanvar(x1)/out.n1+nanvar(x2)/out.n2)^.5;


out.x1=x1;
out.x2=x2;
out.x=xdiff1;
try
    notNan1=find(not(isnan(out.x1)));
    notNan2=find(not(isnan(out.x2)));
    [h1,out.pKS1,ksstat1,cv1] = kstest((out.x1(notNan1)-mean(out.x1((notNan1))))/std(out.x1((notNan1))));
    [h2,out.pKS2,ksstat2,cv2] = kstest((out.x2(notNan2)-mean(out.x2((notNan2))))/std(out.x2((notNan2))));
catch
    out.pKS1=NaN;
    out.pKS2=NaN;
    %fprintf('Can not calculate normal distribution test\n');
end
