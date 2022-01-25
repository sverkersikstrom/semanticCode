function [o,s]=getWord(s,inword,out,condition,removeMissing)
%[o s]=getWord(s,'_study6a*')
if nargin<3
    out=[];
end
o.out=out;
if nargout<2 
    fprintf('This function must have two outputs!\n')
end

%if nargin<3
%    inword=out.words{1};
%else
o.out.words{1}=inword;
%end
if nargin<4 
    out.condition_string='';
end
if nargin>=4 & not(isempty(condition))
    out.condition=1;
    out.condition_string=condition;
end
if nargin<5
    removeMissing=0;
end

if isfield(out,'condition')
    o.condition= out.condition;
    o.condition_string=out.condition_string;
end

[x, x1, word, ok ,index]=wordstring2vector(s,inword);
[N tmp]=size(x);
s=updateContext(s,index);

if not(isnan(index))
    x=s.x(index,:);
end

%Context word - not used
if isfield(out,'context_words') & out.context_words %contex extractions....
    [N tmp]=size(x);
    context_list=string2cell(out.context_list);
    for i=1:N
        list=[];
        if isfield(s.info{index(i)},'words')
            include=0;
            for k=1:length(s.info{index(i)}.words)
                f=find(strcmpi(s.fwords,s.info{index(i)}.words{k}));
                in_list=not(isempty(find(strcmpi(context_list,s.info{index(i)}.words{k}))));
                if in_list
                    include=1;
                end
                if not(isempty(f)) & ~(k==16) & not(in_list)
                    list=[list f];
                end
            end
            if out.context_include==1
                if include==0; list=[];end
            else
                if include==1; list=[];end
            end
            x(i,:)=average_vector(s,s.x(list,:));
        else
            x(i,:)=NaN(1,s.Ndim);
        end
    end
    select=~isnan(x(:,1));
    x=x(select,:);
    x1=average_vector(s,x);
    word=word(select);
    index=index(select);
    ok=not(isempty(index));
end

%Time period - not used
if isfield(out,'time_period') & out.time_period & length(index)>0
    for i=1:length(index)
        include(i)=0;
        if isfield(s.info{index(i)},'time')
            if s.info{index(i)}.time>=out.start_date & s.info{index(i)}.time<=out.end_date
                include(i)=1;
                o.time(i)=s.info{index(i)}.time;
            end
        end
    end
    select=find(include);
    x=x(select,:);
    x1=average_vector(s,x);
    if isempty(select) o.time=[]; else o.time=o.time(select); end
    word=word(select);
    index=index(select);
    ok=not(isempty(index));
end

%Select condition (used)
if isfield(out,'condition') & out.condition
    select=getCondition(s,index,out.condition_string);
    x=x(select,:);
    x1=average_vector(s,x);
    word=word(select);
    index=index(select);
    ok=not(isempty(index));
end

%Select unique words
if s.par.semanticRepOnUniqueWords 
    f=sparse(1,s.N);
    for i=1:length(index)
        [s,f,f2]= mkfreq(s,index(i),f);
    end
    index=word2index(s,s.fwords(find(f>0)));
    select=index(not(isnan(index)));
    x=s.x(select,:);
    x1=average_vector(s,x);
    word=s.fwords(select);
    index=select;
    ok=not(isnan(index));
elseif s.par.semanticRepWords
    %Select all words
    index2=[];
    for i=1:length(index)
        if isfield(s.info{index(i)},'index');
            index2=[index2 s.info{index(i)}.index];
        else
            index2=[index2 index(i)];
        end
    end
    select=index2(not(isnan(index2)) & index2>0);
    x=s.x(select,:);
    x1=average_vector(s,x);
    word=s.fwords(select);
    index=select;
    ok=not(isnan(index));
end

%Sort by a property
s.par.sortIdentifier=string2cell(s.par.sortIdentifier);    
if length(s.par.sortIdentifier)>0
    p=getProperty(s,s.par.sortIdentifier{1},index);
    p(isnan(p))=min(p)-1;
    [tmp select]=sort(p,'descend');
    x=x(select,:);
    x1=average_vector(s,x);
    word=word(select);
    index=index(select);
    ok=not(isempty(index));
end

%Map to single words
o.input=inword;
o.input2=string2cell(o.input);
if 0
    if isfield(out,'single_words') & out.single_words & not(isempty(index))
        if length(out.words)>1
            %fprintf('The multiple word opition can only be used for a single word, ignoring this option!\n')
        else
            if isfield(s.info{index(1)},'index') & length(index)==1
                index=s.info{index}.index;
                x=s.x(index,:);
                word=s.fwords(index);
            end
            x1=x;
            ok=not(isnan(x(:,1)));
            o.input2=word;
        end
    end
end

%Subtract word
if isfield(out,'subtract_word') & out.subtract_word
    [xsub N Ntot t indexWc]=text2space(s,out.subtract_this_word);
    if N<0
        fprintf('Word %s not found, ignoring subtraction of words\n',out.subtract_this_word)
    else
        for j=1:length(index)
            x(j,:)=x(j,:)-xsub;
            x(j,:)=x(j,:)/sum(x(j,:).^2)^.5;
        end
        x1=average_vector(s,x);
    end
end

%Converge to a representation
if isfield(out,'converge') & out.converge
    o.x1=x1;
    i=0;diff=0;
    fprintf('Converging: ');
    while diff<1 & i<50
        i=i+1;
        xlast=x1;
        d=s.x*shiftdim(x1,1);
        [tmp index1]=sort(d,'descend');
        x1=average_vector3(s,s.x(index1(1:50),:),index1(1:50),1);
        diff=sum(xlast.*x1);
        fprintf('%.3f ',diff);
    end
    fprintf('word: %s\n',s.fwords{index1(1)});
end

%Finish up
o.x1=x1;
o.ok=ok;

N2=size(x);
if length(ok)>0
    ok=ok(1);
end
select=not(isnan(index));
o.x=x(select,:);
o.word=word(select);
o.index=index(select);
select=find(ok==0);
if isfield(out,'noprint') return; end;
if not(isempty(select))
    fprintf('missing word(s): ');
    for i=1:min(length(word),length(select))
        fprintf('%s ',word{select(i)});
    end
    fprintf('\n');
end
o.N=length(o.word);

for i=1:length(o.word)
    o.word_clean{i}=regexprep(o.word{i},'_',' ');
end
o.input_clean=regexprep(o.input,'_',' ');
if isfield(out,'condition') & out.condition
    o.input_clean=[o.input_clean ' (' regexprep(out.condition_string,'_',' ') ')'];
end
if not(isfield(o,'condition_string')) o.condition_string='';end
if o.N==0
    fprintf('%d word(s) selected. Failed finding: %s, using condition_string: %s\n',o.N,o.input, o.condition_string);
else    
    fprintf('%d word(s) selected: ',o.N);
end
for i=1:min(5,length(o.word));
    fprintf('%s ',o.word{i});
end

if isfield(out,'newWord') & length(out.newWord)>0
    info.worddef=o.out;
    info.specialword=0;
    newword=fixpropertyname(out.newWord);
    s=addX2space(s,newword,average_vector(s,o.x1),info);
    out.newWord='';
    out.words=newword;
    out.condition=0;
    [o s]=getWord(s,newword,out);
    1;
end
o.par=s.par;
o.fwords=o.word;

if length(word)>5
    fprintf('...\n');
else
    fprintf('\n');
end


