function [out,s]=semanticTest(s,index1,index2,label1,label2,subject1,subject2,par1,par2)
if nargin==0
    %Do multiple semantic-test
    s=getSpace;
    [wordset s]=getWordFromUser(s,'Choose text identifier to predict from','_price_dp7');
    if wordset.N==0; return; end
    
    [propertyPredict s]=getWordFromUser(s,'Choice identifier(s) to predict','_doc*');
    if propertyPredict.N==0; return; end
    index=wordset.index;
    for i=1:length(propertyPredict.index)
        [yTmp,~,s]=getProperty(s,propertyPredict.index(i),index');
        split1=yTmp>median(yTmp);
        split2=yTmp<median(yTmp);
        if abs(length(index)/2-length(find(split1)))<abs(length(index)/2-length(find(split2)))
            split=split1;
        else
            split=split2;
        end
        index1=index(split);index2=index(not(split));         
        label1=[s.fwords{propertyPredict.index(i)} 'high'];
        label2=[s.fwords{propertyPredict.index(i)} 'low'];
        subject1=[];
        subject2=[];
        [out{i},s]=semanticTestNew(s,index1,index2,label1,label2,subject1,subject2,s.par,s.par);
    end
    fprintf('Variable\tp\n')
    for i=1:length(out)
        fprintf('%s\t%.4f\n',s.fwords{propertyPredict.index(i)},out{i}.p)
    end
    1;
else
    if isfield(index1,'index');
        if nargin<8
            par1=index1.par;
        end
        label1=index1.input_clean;
        index1=index1.index;
    end
    if isfield(index2,'index');
        if nargin<9
            par2=index2.par;
        end
        label2=index2.input_clean;
        index2=index2.index;
    end

    if nargin<4
        label1='set1';
    end
    if nargin<5
        label2='set2';
    end
    if nargin<6
        subject1=[];
    end
    if nargin<7
        subject2=[];
    end
    if nargin<8
        par1=[];
    end
    if nargin<9
        par2=[];
    end
    [out,s]=semanticTestNew(s,index1,index2,label1,label2,subject1,subject2,par1,par2);
end


function [out, s]=semanticTestNew(s,index1,index2,label1,label2,subject1,subject2,par1,par2)

[o1,s]=getX(s,index1,par1);
[o2,s]=getX(s,index2,par2);
o1.input_clean=label1;
o2.input_clean=label2;

out=[];
out.comment1='Descriptive statistics';
out.m1=NaN;
out.m2=NaN;
out.s1=NaN;
out.s2=NaN;
out.n1=NaN;%length(o1.index);
out.n2=NaN;%length(o2.index);
out.comment2='Inferential statistics and related information';
out.p=NaN;
out.z=NaN;
out.cohensD=NaN;
out.t=NaN;
out.correct=NaN;
out.x1=NaN;
out.x2=NaN;
out.results='';
out.x=[];
p=NaN;
z=NaN;

xmean1=average_vector(s,o1.x,o1.index);
xmean2=average_vector(s,o2.x,o2.index);

type='noprint';

property=fixpropertyname(regexprep(regexprep(['_diff_' o1.input_clean '_' o2.input_clean],'*',''),'__','_'));

info.specialword=7;
if s.par.excelServer
    xmean1(isnan(xmean1))=0;
    xmean2(isnan(xmean2))=0;
end
x=xmean1-xmean2;
x=x/sum(x.*x)^.5;
if isfield(s.par,'saveSemanticScale') & s.par.saveSemanticScale==0
    if not(s.par.excelServer)
        fprintf('Not saving semanticScale\n');
        property='';
    end
elseif length(property)>0
    s=addX2space(s,property,x,info,0);
    propertyCrossvalidation=['_crossvalidation' property(2:end)];
    info.specialword=12;
    s=addX2space(s,propertyCrossvalidation,x,info,0);
end

paired=s.par.paired_semantic_difference;
t=NaN;
if paired
    out.semanticTestMethod='Paired';
    if s.par.match_paired_test_on_subject_property ; %match on subject proproperty (needs debugging)
        subjectProperty=regexprep(s.par.semanticTestMatchProperty,'_','');
        out.semanticTestMethod=[out.semanticTestMethod sprintf('. Matching on subject property: %s\n',subjectProperty)];
        
        subject1=getInfo(s,o1.index,subjectProperty);
        subject2=getInfo(s,o2.index,subjectProperty);
        index=zeros(1,length(o1.index));
        for i=1:length(o1.index)
            subject=find(subject1(i)==subject2);
            if isempty(subject)
                index(i)=0;
            else
                if length(subject)>1
                    fprintf('Warning more than one paired matching on word: %s, using first match!\n',s.fwords{o1.index(i)})
                end
                index(i)=subject(1);
            end
        end
        if not(length(index(find(index>0)))==sum(subject2(index(find(index>0))) ==subject1((find(index>0)))))
            fprintf('error!!!\n');beep2
        end
        o1.index=o1.index(find(index>0));
        o2.index=o2.index(index(find(index>0)));
        if isempty(o1.index) | isempty(o2.index)
            out.error='No matching subjects, aborting!';
            fprintf('%s\n',out.error)
            return
        end
    end
    
    if not(length(o1.index)==length(o2.index))
        out.error='Unequal number of words, pair test can not be done!';
        out.results=out.error;
        return;
    end
    xdiff=o1.x-o2.x;
    bootStrap=0;
    if bootStrap %Not used
        xm=nanmean(xdiff);
        dist=nansum(xm.^2)^.5;
        Nw=length(o1.index);
        xdiffr=NaN;
        myprint(sprintf('paired semantic test: calculating %d bootstraps',s.par.n_bootstraps),[],1);
        for j=1:s.par.n_bootstraps
            r=2*((rand(1,Nw)<.5)-.5);
            for i=1:Nw
                xdiffr(i,:)=xdiff(i,:)*r(i);
            end
            xmr=nanmean(xdiffr);
            rdist(j)=sum(xmr.^2)^.5;
        end
        std1=std(rdist);
        out.t=(dist-mean(rdist))/std(rdist);
        out.df=length(o1.index)+length(o2.index);
        out.pbootstrap=mean(dist<rdist);
        out.p=tcdf(-out.cohensD,out.df-1);
        out.bootstrap=sprintf('done.\nBootstrap method: Dist(cmp) %.5f Dist(boot) %.5f std %.5f z %2.3f Effect size %.3f p %.3f p_bs %.3f df %d Nboot %d\n',dist,mean(rdist),std1,out.cohensD,out.t,out.p,out.pbootstrap,out.df,s.par.n_bootstraps);
    else
        %Calculate semantic scale for each item
        for i=1:length(o1.index)
            x1=xdiff(i,:)/sum(xdiff(1,:).^2)^.5;%Normalize i to length 1
            x2=nanmean(xdiff(find(not(i==1:length(o1.index))),:));%Summarize all other vectors
            x2=x2/sum(x2.^2)^.5;%Normalize all other to length of 1
            outX1(i)= sum(x1.*x2);%The semantic distance between i and all others
            outX2(i)=-sum(x1.*x2);
            if length(property)>1
                s=setInfo(s,o1.index(i),property(2:length(property)),outX1(i));
                s=setInfo(s,o2.index(i),property(2:length(property)),outX2(i));
            end
        end
        [h out.p CL stats]=ttest(outX1,0,0.05,'right');
        out.m1=nanmean(outX1);
        out.m2=nanmean(outX2);
        out.s1=nanstd(outX1);
        out.s2=nanstd(outX2);
        out.n1=length(find(not(isnan(outX1))));
        out.n2=length(find(not(isnan(outX2))));
        
        %I think this is right:
        out.t=out.m1/(nanvar(outX1)/stats.df)^.5;
        out.cohensD=(out.m1)/(nanvar(outX1))^.5;
        
        %And this is wrong, because the variance of x1 and x2 are the same!:
        %out.t=(out.m1-out.m2)/(nanvar(outX1)/out.n1+nanvar(outX2)/out.n2)^.5;
        %out.cohensD=(out.m1-out.m2)/(nanvar(outX1)+nanvar(outX2))^.5;
        try
            tmp=(outX1-out.m1)/out.s1;
            if not(isnan(nanmean(tmp))) & length(tmp)>0
                [h1,out.pKS1,ksstat1,cv1] = kstest(tmp);
            end
            tmp=(outX2-out.m2)/out.s2;
            if not(isnan(nanmean(tmp))) & length(tmp)>0
                [h1,out.pKS2,ksstat1,cv1] = kstest(tmp);
            end
        catch
        end
        out.x1=outX1;
        out.x2=outX2;
        
        out.correct=mean(outX1>=0);
    end
    
else %Un-paired test
    %Word subtraction method (new)
    
    if s.par.match_paired_test_on_subject_property
        info=fprintf(' Summarizing data on based on subject property!\n');
        otmp1=o1;
        o1=avaregeSub(s,o1,subject1);
        o1.input_clean=otmp1.input_clean;
        otmp2=o2;
        o2=avaregeSub(s,o2,subject2);
        o2.input_clean=otmp2.input_clean;
        [out s]=semanticTest2(s,o1,o2);
    else
        [out s]=semanticTest2(s,o1,o2,property);
        info='';
    end
    p=out.p;
    out.semanticTestMethod=['Word subtraction' info];
    
end
if not(s.par.excelServer) & s.par.saveCrossValidationData %Remove for speed
    [d, index,out.associates]=print_nearest_associations_s(s,type,xmean1-xmean2,'descend','',o1,o2);
    [d, index,out.associatesFurthest]=print_nearest_associations_s(s,type,xmean2-xmean1,'descend','',o2,o1);
    try
        index12=[index1 index2];
        x12=[out.x1 out.x2];
        for i=1:length(index12)
            s=setInfo(s,index12(i),propertyCrossvalidation(2:end),x12(i));
        end
    end
end
out.modelname=property;
out.results=regexprep(struct2text(out,[],0),'par.','');
out.results=addComments(out.results);


function o=avaregeSub(s,o1,subject);
if nargin<3
    subject=[];
end
if isempty(subject)
    propertySub=regexprep(s.par.semanticTestMatchProperty,'_','');
    for i=1:length(o1.index)
        try;
            subject(i)=getInfo(s,o1.index(i),propertySub);
            %eval(['subject(i)=s.info{o1.index(i)}.' propertySub ';']);
        catch
            fprintf('missing %s property on %s\n',propertySub,s.fwords{o1.index(i)})
        end
    end
end
[unique_subject m n]=unique(subject);
for i=1:length(unique_subject)
    j=find(subject==unique_subject(i));
    x(i,:)=average_vector(s,o1.x(j,:));
end
o.x=x;
o.index=unique_subject;


