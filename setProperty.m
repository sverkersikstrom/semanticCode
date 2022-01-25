function [s newword index]=setProperty(s,word,property,data,info)
if nargin<5
    info=[];
end
if iscell(word)
    s.par.fastAdd2Space=1;%Temporarly store the new information in s.sTemp
    newword=[];
    for i=1:length(word)
        newword{i}=fixpropertyname(word{i});
    end
    nanIndex=word2index(s,newword);
    for i=1:length(word)
        if not(isnan(nanIndex(i))) & not(ischar(property)) & strcmpi(data{i},getText(s,word{i},property{i}))
            %newword{i}=fixpropertyname(word{i});
        elseif ischar(property)
            [s newword{i} index{i}]=setProperty(s,word{i},property,data{i},info{i});
        else
            [s newword{i} index{i}]=setProperty(s,word{i},property{i},data{i},info{i});
        end
    end
    s.par.fastAdd2Space=2;%Now store information in s!
    s=addX2space(s);
    index=word2index(s,newword);
    return
end

index=NaN;
newword=property;
if isempty(word) | isempty(property); return; end
propertyOrg=property;
[property property2]=fixpropertyname(property);


if not(isfield(s,'spaceid')) & isnan(word2index(s,property))  %Adding missing property word!
    if not(isfield(info,'specialword'))
        info.specialword=1;
    end
    if isfield(s,'sTemp') & not(isnan(word2index(s.sTemp,property)) )
    else
        s=addX2space(s,property,[],info);
    end
end

if strcmpi(property,'_context') | strcmpi(property,'_text') %Adding text representation
    index=word2index(s,word);
    if not(isempty(index)) & not(isnan(index))
        info=structCopy(s.info{index},info);
        if isfield(info,'par')
            info=rmfield(info,'par');
        end
    end
    [s index newword]=addText2space(s,data,word,info);
elseif strcmpi(property,'_word') | strcmpi(property,'_identifier')
    if isnan(word2index(s,strtrim(word)))
        if not(strcmpi(word,fixpropertyname(word)))
            newword=fixpropertyname(word);
        end
          [s,  ~, newword]=addX2space(s,word,[]);
    end
else
    if length(data)==0
        data1=' ';
    else
        data1=data(1);
    end
    if isnumeric(data)
        if isnan(data)
            return %Do not set nan values!
        else
            d=num2str(data);
        end
        %This is a problem because text starting wiht a number of . is
        %treated as a number!
    elseif ischar(data) & ((data1<'0' | data1>'9') & not(data1=='.') & not(data1=='-')) %Adding text
        d=['''' regexprep(regexprep(data,char(12),' '),'''',' ') ''''];
    elseif isnan(str2double(data)) %Adding text
        d=['''' regexprep(regexprep(data,char(12),' '),'''',' ') ''''];
    else %Adding number
        d=['[' num2str(data) ']'];
    end
    
    if s.par.fastAdd2Space & isfield(s,'sTemp')
        index2=word2index(s,word);
        if not(isempty(index2)) %& not(isnan(index2))
            if isfield(info,'specialword')
                s.info{index2}.specialword=info.specialword;
            end
            info=s.info{index2};
        end
        index=word2index(s.sTemp,word);
        if isnan(index)
            if not(isfield(info,'specialword'))
                info.specialword=9;
            end
            s.sTemp=addX2space(s.sTemp,word,[],info);
            index=word2index(s.sTemp,word);
        end
        if not(strcmpi(d,'''''')) & not(isnan(index)) %Adding string
            [value s.sTemp]=getInfo(s.sTemp,index(1), property,d);
        end
    else
        index=word2index(s,word);
        if not(strcmpi(d,'''''')) & not(isnan(index)) %Adding string
            [value s]=getInfo(s,index(1), property,d,info);
        end
    end
end
