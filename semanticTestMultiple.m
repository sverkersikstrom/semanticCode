function semanticTestMultiple(s,odic1,par,odic2)
if nargin<1
    s=getSpace('s');
end
if nargin<2
    [odic1, s,par]=getWordMany(s,'Choice words to compare','*');
end
if nargin<4
    odic2=odic1;
end

if length(odic1)<2 return; end;

r2='';        
for i1=1:length(odic1)
    for i2=i1+1:length(odic1)
        fprintf('.');
        [out,s]=semanticTest(s,odic1{i1},odic1{i2},odic1{i1}.input_clean,odic1{i2}.input_clean,[],[],par{i1},par{i2});
        r2=[r2 sprintf('%s\n',out.results)];
        p(i2,i1)=out.p;
        z(i2,i1)=out.cohensD;
        outSave{i2,i1}=out;
        outSave{i1,i2}=out;
    end
    fprintf('\n');
    p(i1,i1)=1;
    outSave{i1,i1}.t=NaN;
    outSave{i1,i1}.p=1;
    outSave{i1,i1}.cohensD=NaN;
end
s=getSpace('set',s);

r=[sprintf('Summary, p-values\n\t')];
for i1=1:length(odic1)
    r=[r sprintf('%s\t',odic1{i1}.input_clean)];
end
for i1=1:length(odic1)
    r=[r sprintf('\n%s\t',odic1{i1}.input_clean)];
    for i2=1:length(odic1)
        r=[r sprintf('%.4f\t',outSave{i1,i2}.p)];
    end
end
r=[r sprintf('\n')];

r=[r sprintf('Summary, t-values\n\t')];
for i1=1:length(odic1)
    r=[r sprintf('%s\t',odic1{i1}.input_clean)];
end
for i1=1:length(odic1)
    r=[r sprintf('\n%s\t',odic1{i1}.input_clean)];
    for i2=1:length(odic1)
        r=[r sprintf('%.4f\t',outSave{i1,i2}.t)];
    end
end
r=[r sprintf('\n')];

r=[r sprintf('Summary, Cohen''s d\n\t')];
for i1=1:length(odic1)
    r=[r sprintf('%s\t',odic1{i1}.input_clean)];
end
for i1=1:length(odic1)
    r=[r sprintf('\n%s\t',odic1{i1}.input_clean)];
    for i2=1:length(odic1)
        try
            r=[r sprintf('%.4f\t',outSave{i1,i2}.cohensD)];
        catch
            r=[r sprintf('%.4f\t',NaN)];
        end
    end
end
r=[r sprintf('\n')];

r=[r sprintf('Summary, semantic distance (one-leave out)\n\t')];
for i1=1:length(odic1)
    r=[r sprintf('%s\t',odic1{i1}.input_clean)];
end
for i1=1:length(odic1)
    r=[r sprintf('\n%s\t',odic1{i1}.input_clean)];
    for i2=1:length(odic1)
        try
            if i1<i2
                r=[r sprintf('%.4f\t',nanmean(outSave{i1,i2}.x1))];
            else
                r=[r sprintf('%.4f\t',nanmean(outSave{i1,i2}.x2))];
            end
        catch
            r=[r sprintf('%.4f\t',NaN)];
        end
    end
end
r=[r sprintf('\n')];

r=[r sprintf('Summary, p-vales of one-sample Kolmogorov-Smirnov test for normal distribtion (one-leave out)\n\t')];
for i1=1:length(odic1)
    r=[r sprintf('%s\t',odic1{i1}.input_clean)];
end
for i1=1:length(odic1)
    r=[r sprintf('\n%s\t',odic1{i1}.input_clean)];
    for i2=1:length(odic1)
        try
            if i1<i2
                r=[r sprintf('%.4f\t',mean(outSave{i1,i2}.pKS1))];
            else
                r=[r sprintf('%.4f\t',mean(outSave{i1,i2}.pKS2))];
            end
        catch
            r=[r sprintf('%.4f\t',NaN)];
        end
    end
end
r=[r sprintf('\n')];
r=[r r2];
showOutput({r},'Semantic test(s)');