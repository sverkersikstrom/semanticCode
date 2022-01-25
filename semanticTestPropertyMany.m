function [results out s]=semanticTestPropertyMany(s,data,index,label,data2,index2,label2);
%data (index),index,label (text) are cell arrays including
%if data2,properites2,label2 are not used as input, then make the matrix squared
if nargin<5
    squared=1;
    data2=data;
else
    squared=0;
end


if nargin<6
    index2=index;
end
if nargin<5
    label2=label;
end

N=length(data);
N2=length(data2);

results='';
for j1=1:N
    for j2=1:N2
        if nargin<4
            label{j1}=[data{min(j1,length(data))}.input_clean '(' s.fwords{index(ji)} ')'];%min(j1,length(index))
        end
        if j1==j2 & squared & N>1
        %elseif j1>j2 %& squared
        %    out{j2,j1}=out{j1,j2};
        else
            [out{j1,j2} s]=semanticTestProperty(s,data{j1},data2{j2},index(j1),index2(j2),label{j1},label2{j2});
            results=[results char(13) out{j1,j2}.results];
        end
    end
end

if length(s.par.resultsVariables)==0;
    N3=size(out);
    if isfield(out{1,N3(2)},'pCorrelation')
        s.par.resultsVariables='r pCorrelation';
    else
        s.par.resultsVariables='p';
    end
end
r=sprintf('%s\t',s.par.resultsVariables);
for j1=1:N2
    r=[r sprintf('%s\t',label2{j1})];
end
r=[r sprintf('\n')];


for j1=1:N
    r=[r sprintf('%s\t',label{j1})];
    for j2=1:N2
        if j1==j2 & squared
            r=[r sprintf('-\t')];
        else
            %if j1<j2
            [tmp tmp resultsString]=resultsVariables(out{j1,j2},s.par.resultsVariables);
            r=[r sprintf('%s\t',resultsString)];
            %else
            %    [tmp tmp resultsString]=resultsVariables(out{j2,j1},s.par.resultsVariables);
            %    r=[r sprintf('%s\t',resultsString)];
            %end
        end
    end
    r=[r sprintf('\n')];
end
results=[r sprintf('\n') results];
%fprintf('%s',r);
showOutput({r},'Semantic test(s)');
1;
