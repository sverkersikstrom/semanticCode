function [text indexWord]=getText(s,index,semVar,conCatinated)
index=word2index(s,index);
if nargin<3
    semVar=[];
end
if isempty(semVar)
    semVar=s.par.variableToCreateSemanticRepresentationFrom;
end 
if nargin<4
    conCatinated=1;
end
if length(index)>1
    text='';
    indexWord=[];
    for i=1:length(index)
        [text1 indexWord1]=getText(s,index(i),semVar);
        if conCatinated
            text=[text ' ' text1];
        else
            text{i}=text1;
        end
        indexWord=[indexWord indexWord1];
    end
    if conCatinated
        text=text(2:end);
    end
    return
end
if length(semVar)>0
    semVar=string2cell(semVar);
end
text='';
indexWord=[];
if isempty(index) | isnan(index)
    return
elseif length(semVar)==0;
    semVar{1}='_context';
    if isnan(index) | index==0 | length(s.fwords)<index
        if length(s.fwords)<index
            fprintf('\nWarning: fwords < index\n')
        end
        text='';
        return
    elseif not(isfield(s,'info')) | length(s.info)<index | not(isfield(s.info{index},'context'))
        text=s.fwords{index};
        indexWord=index;
        return
    end
end
for j=1:length(semVar)
    [~, semVarFix]=fixpropertyname(semVar{j},s);
    if strcmpi(semVarFix,'text') & not(isfield(s.info{index},semVarFix)) 
        semVarFix='context';
    end
    if isfield(s.info{index},semVarFix)
        tmp=s.info{index}.(semVarFix);
    elseif length(s.fwords{index})>=1 & not(s.fwords{index}(1)=='_') & j==1
        tmp=s.fwords{index};
    else
        tmp='';
    end
    if isnumeric(tmp)
        tmp=num2str(tmp);
    end
    if j>1
        text=[text ' '];
    end
    text=[text tmp];
end
if nargout>1
    if not(isfield(s.info{index},'index'))
        indexWord=text2index(s,text);
    else
        indexWord=s.info{index}.index;
    end
end
