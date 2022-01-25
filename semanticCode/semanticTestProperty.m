function [out s]=semanticTestProperty(s,oinput1,oinput2,index1,index2,label1,label2)
if isfield(oinput1,'index')
    indexData1=oinput1.index;
else
    indexData1=oinput1;
end
if isfield(oinput2,'index')
    indexData2=oinput2.index;
else
    indexData2=oinput2;
end
if isfield(oinput1,'input_clean') & nargin<7
    label1=oinput1.input_clean;
    label2=oinput2.input_clean;
end

[d1nan, ~ ,s]=getProperty(s,index1,indexData1);
[d2nan, ~, s]=getProperty(s,index2,indexData2);

if length(s.par.covariateProperties)>0
    tmp=covariates(s,[d1nan'; d2nan'],s.par.covariateProperties,[indexData1 indexData2])';
    d1nan=tmp(1:length(indexData1));
    d2nan=tmp(length(indexData1)+1:end);
end

d1=d1nan(find(not(isnan(d1nan))));
d2=d2nan(find(not(isnan(d2nan))));
d1=d1(find(not(isinf(d1))));
d2=d2(find(not(isinf(d2))));

%ttest
if s.par.match_paired_test_on_subject_property ; %match on subject proproperty (needs debugging)
    subjectProperty=fixpropertyname(s.par.semanticTestMatchProperty);
    fprintf('Matching paired test on subject property: %s\n',subjectProperty);    
    [subject1,~,s]=getProperty(s,subjectProperty,indexData1);
    [subject2,~,s]=getProperty(s,subjectProperty,indexData2);
    d=[];
    for i=1:length(subject1)
        j=find(subject1(i)==subject2);
        if not(isempty(j))
            d=[d d1(i)-d2(j)];
        end
    end    
    [h,significance,ci,stats] = ttest(d,0);
    out.testtype='paired';
else
    try
        [h,significance,ci,stats] = ttest2(d1,d2,0.05,0);
    catch
        h=NaN;significance=NaN;ci=NaN;stats.tstat=NaN;
    end
end
out.p=significance;
out.t=stats.tstat;

%Correlations & paired test
dord1=nan(1,s.N);
dord2=nan(1,s.N);
dord1(indexData1)=d1nan;
dord2(indexData2)=d2nan;
include=find(not(isnan(dord1)) & not(isnan(dord2)));
if not(isempty(include))
    [r p]=nancorr(shiftdim(dord1(include),1),shiftdim(dord2(include),1));
    out.pCorrelation=p;
    out.r=r;
    [h,significance,ci,stats] = ttest(dord1(include)-dord2(include),0);
    out.ppaired=significance;
    out.tpaired=stats.tstat;
    out.Ncorr=length(include);
end

%Group over subjects.
try
    [group,~,s]=getProperty(s,['_' s.par.groupingProperty],indexData1);
    uniqueGroup=unique(group);
    for i=1:length(uniqueGroup)
        indexGroup=find(uniqueGroup(i)==group & not(isnan(d1nan+d2nan)));
        rGroup(i)=nancorr(d1nan(indexGroup)',d2nan(indexGroup)');
    end
catch
    rGroup=NaN;
    uniqueGroup=NaN;
    fprintf('Could not do group analysis\n')
end

if nargin>6
    out.label1=label1;
    out.label2=label2;
end

out.m1=mean(d1);
out.m2=mean(d2);
out.std1=std(d1);
out.std2=std(d2);
out.N1=length(d1);
out.N2=length(d2);
out.Nmissing1=length(d1nan)-length(d1);
out.Nmissing2=length(d2nan)-length(d2);
out.property1=index2word(s,index1);
out.property2=index2word(s,index2);
out.NGroups=length(uniqueGroup);
[h out.pTtestRGroup]=ttest(rGroup,0,.05);
% if length(unique(d1))==2 & 0 %Not used....
%     d1U=unique(d1);
%     [h p2]=ttest2(d2nan(find(d1nan==d1U(1) & not(isnan(d1nan)) )),d2nan(find(d2nan==d1U(2)  & not(isnan(d2nan)) )));
%     %[h p2]=ttest2(d2nan(find(d1nan==d1U(1) & not(isnan(d1nan+d2nan)) )),d2nan(find(d1nan==d1U(2)  & not(isnan(d1nan+d2nan)) )));
% end
out.covariates=s.par.covariateProperties;

out.results=regexprep(struct2text(out,[],0),'par.','');
out.x1=d1nan;
out.x2=d2nan;

fprintf('%s\n',out.results);


