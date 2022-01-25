function [value s]=getInfo(s,indexWord,property,newValue,info)
if isnan(property)
    value=NaN(1,length(indexWord));
    return
elseif isnumeric(property)
    [property property2]=fixpropertyname(s.fwords{property},s);
else
    [property property2]=fixpropertyname(property,s);
end

if s.par.variables
    if not(isfield(s,'var'))
        s.var.hash=java.util.Hashtable;
        s.var.data=sparse(10,0);
        s.var.name=[];
    end
    indexVar=s.var.hash.get(lower(property));
    if indexVar>=length(s.var.name) | not(isempty(indexVar)) & not(strcmp(property,s.var.name{indexVar}))
        indexVar=find(strcmpi(s.var.name,property));
    end
    indexWord=word2index(s,indexWord);
    if nargin<4 %get property
        if isempty(indexVar)
            value=NaN(1,length(indexWord));
        else
            try
                value=full(s.var.data(indexWord,indexVar));
                value(find(value==0))=NaN;
                value(find(value==-9e+9))=0;
            catch
                value=NaN;
            end
            return
        end
    else %set property
        if ischar(newValue)
            try
                newValue2=eval(regexprep(newValue,char(10),' '));
            catch
                fprintf('Error in calculating: %s\n',newValue);
                newValue2=NaN;
            end
        else
            newValue2=newValue;
        end
        if isnumeric(newValue2)
            if isempty(indexVar)
                indexVar=size(s.var.data,2)+1;
                s.var.hash.put(lower(property),indexVar);
                s.var.name{indexVar}=property;
            end
            value=newValue2;
            if newValue2==0;
                newValue2=-9e+9;
            end
            if not(isnan(indexWord(1)))
                s.var.data(indexWord,indexVar)=newValue2(1);
            end
            return
        end
    end
end


i=word2index(s,indexWord);
if nargin<4 %get property
    value=nan(1,length(i));
    for j=1:length(i)
        if not(isnan(i(j))) & isfield(s.info{i(j)},property2)
            tmp=eval(['s.info{i(j)}.' property2 ';' ]);
            if ischar(tmp)
                try
                    if not(isnan(str2double(tmp)));
                        value(j)=str2double(tmp);
                    else
                        if j==1; clear value;end
                        value{j}=tmp;
                    end
                catch
                    value(j)=str2double(tmp);
                end
            else
                value(j)=tmp;
            end
        end
    end
else %set property
    if isempty(newValue) newValue=NaN;end
    if ischar(newValue);
        N=1;
    else
        N=min(length(i),length(newValue));
    end
    for j=1:N
        if isnumeric(newValue(j))
            newValueString=num2str(newValue(j));
        else
            newValueString=newValue ;
        end
        if not(isempty(property2))
            if s.par.fastAdd2Space==1
                info=s.info{i(j)};
                prefix='info.';
            elseif not(isnan(i(j)))
                prefix='s.info{i(j)}.';
            end
            try
                eval([prefix property2 '=' regexprep(newValueString,char(10),'') ';']);
            catch
                fprintf('Error parsing string: %s\n',newValueString)
                newValueString=regexprep(newValueString,'''',' ');
                try
                    eval([prefix property2 '=' regexprep(newValueString,char(10),'') ';']);
                end
            end
            if s.par.fastAdd2Space==1
                w=index2word(s,i(j));
                s=addX2space(s,w{1},s.x(i(j),:),info);
            end
        end
    end
    value=newValue;
end
