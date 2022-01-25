function s=set_word_property_from_variables(s,words, data, col, all_labels,prefix)

indexTemp=find(strcmpi(all_labels,'_context'));
if not(isempty(indexTemp)) all_labels{indexTemp}='_text';end
indexTemp=find(strcmpi(all_labels,'_word'));
if not(isempty(indexTemp)) all_labels{indexTemp}='_identifier';end


for i=1:length(all_labels)
    all_labels{i}=regexprep(all_labels{i},char(229),'aa');;
    all_labels{i}=regexprep(all_labels{i},char(228)','ae');;
    all_labels{i}=regexprep(all_labels{i},char(246),'o');;
    if isnan(word2index(s,all_labels{i})) | not(isnan(word2index(s,['_' all_labels{i}])))
        all_labels{i}=fixpropertyname(all_labels{i});
    end
end

N=size(data);
if N(2)>length(all_labels)
    for i=length(all_labels)+1:N(2)
        all_labels{i}=['Column' num2str(i)];
    end
end
fprintf('\nCheck if any of these columns have excel-function, which should be converted to text: %s\n',cell2string(all_labels(find(mean(isnan(data))))'));

if strcmp(lower(all_labels{1}),'_identifier')==0%'_word'
    %skip=1;
    %if skip | strcmp('Yes',questdlg2(['Missing _identifier column, add this column? Word labels ' prefix '+Number?'],'_identifier?','Yes','No','No'))
    %all_labels(2:end+1)=all_labels(2:end);
    all_labels(2:end+1)=all_labels;
    all_labels{1}='_identifier';%'_word'
    N=size(data);
    col=col+1;
    data(:,2:end+1)=data;
    words(:,2:end+1)=words;
    for i=1:N(1)
        words{i,1}=[prefix num2str(i)];
    end
    %end
end

for j=1:length(words(:,1))
    words{j,1}=fixpropertyname(words{j,1});
    if isnan(word2index(s,words{j,1}))
        if length(words{j,1})>0 & not(words{j,1}(1)=='_')
            fprintf('Word: %s does not exist (row  %d), omitting this row!\n',words{j,1},j)
            words{j,1}='';
        else
            words{j,1}=fixpropertyname(words{j,1});
        end
    end
end


if length(all_labels)==0
    all_labels=inputdlg3('Choice one, or several, word properities to set',all_labels,1);
    all_labels=sting2cell(all_labels);
end

if s.par.askForInput
    s.par.openNormFile=questdlg2('Identifier','Open file as text (default), norm, LIWC','text','norm','liwc','text');
end

try
    if isempty(find(strcmp(lower(all_labels),s.par.variableToCreateSemanticRepresentationFrom))) %isempty(find(strcmp(lower(all_labels),'_text'))) & 
        for i=1:length(all_labels)
            j(i)=ischar(words{2,i}) & not(strcmpi(all_labels{i},'_identifier'));
        end
        j=find(j);
        if s.par.askForInput
            variableToCreateSemanticRepresentationFrom=questdlg('Choose variable to create semantic representation from','Choose variable to create semantic representation from','cancel',all_labels{j(1)},all_labels{j(min(2,length(j)))},'cancel');
        else
            variableToCreateSemanticRepresentationFrom=all_labels{j(1)};
        end
        if not(strcmpi(variableToCreateSemanticRepresentationFrom,'cancel'))
            setPar.variableToCreateSemanticRepresentationFrom=variableToCreateSemanticRepresentationFrom;
            getPar(setPar,'persistent');
            s.par.variableToCreateSemanticRepresentationFrom=variableToCreateSemanticRepresentationFrom;
        end
    end
end


fastAdd2Space=1;
[Nrows Ncol]=size(words);
for m=1:Ncol
    all_labels{m}=fixpropertyname(all_labels{m});
    label=all_labels{m};
    fprintf('%s ',label);
    s.par.fastAdd2Space=fastAdd2Space;
    for i=1:Nrows
        info=[];
        info.par=[];
        info.specialword=9;
        if isnumeric(words{i,m}) & s.par.variables
            s.par.fastAdd2Space=0;
        else
            s.par.fastAdd2Space=1;
        end
        if s.par.openNormFileMultipel & m==1
            words{i,1}=fixpropertyname([words{i,1} label]);
        end
        [s, ~,newIndex]=setProperty(s,words{i,1},label,words{i,m},info);
        if even(i,500)
            s.par.fastAdd2Space=2;
            s=addX2space(s);
            s.par.fastAdd2Space=fastAdd2Space;
        end
        if ischar(words{i,m}) %Remove new lines
            words{i,m}=regexprep(words{i,m},char(10),' ');
        end
    end
    info.specialword=12;%Variable...
    s=addX2space(s,label,[],info);

    s.par.fastAdd2Space=2;
    s=addX2space(s);
    if strcmpi(s.par.openNormFile,'norm')
        s.par.updateNorms=1;
        for i=1:Nrows
            s=updateContext(s,word2index(s,words{i,1}));
        end
        s.par.updateNorms=0;
    end
end
k=word2index(s,words(:,1));
for i=1:Nrows
    s.info{k(i)}.par.contextVariables='';
end
k=word2index(s,all_labels);
for i=1:length(all_labels)
    s.info{k(i)}.par.contextVariables='';
end

s=getSpace('set',s);
Ncol=Ncol+1;
words{Nrows,Ncol}='';
if length(all_labels)<Ncol;all_labels{Ncol}='';end
handles=getHandles;
try
    set(handles.report,'Data',[shiftdim(all_labels,1); words]);
catch
    set(handles.report,'Data',[shiftdim(all_labels,0); words]);
end
set(handles.report,'ColumnEditable',true(1,Ncol+1));
fprintf('\nDone.\n')

