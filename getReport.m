function s=getReport(FileName,spaceFile,askForInput)
if nargin<1
    [FileName,PathName]=uigetfile('*.txt;*.mat;*.xls;*.xlsx;*.csv;*.json','First row must be column labels; _word [_context] _data1...','');
else
    [PathName,FileName]=file2pathName(FileName);
end
if nargin>=2 & length(spaceFile)>0
    if isstruct(spaceFile)
        s=spaceFile;
    else
        s=getNewSpace(spaceFile);
    end
else
    s=getSpace('s');
end

if nargin<3
    askForInput=s.par.askForInput;
end


if FileName==0; return; end
fprintf('Opening report file: %s \n',[PathName FileName]);
%fprintf('Opening report file: %s using languagfile: %s and datafile: %s\n',[PathName FileName],s.languagefile, s.datafile);
global reportFilename
Name=regexprep(regexprep(regexprep(regexprep(FileName,'\.mat',''),'\.txt',''),'\.xlsx',''),'\.xls','');

reportFilename=[PathName Name];
if not(isempty(findstr(FileName,'.mat')))
    load(reportFilename);
    if not(exist('r')) | not(isfield(r,'spacefile'))
        fprintf('This is not a report file: %s\n', reportFilename );
        s=[];
        return
    else
        s=getSpace('',[],[PathName r.spacefile]);
    end 
    reportFilename=[PathName Name];
    global reportCommand
    try;reportCommand=r.reportCommand;end
    
    s.par=getPar;

    try
        text=textscan(s.par.variableToCreateSemanticRepresentationFrom,'%s');text=text{1}{1};
        if isempty(text) text='_text'; end
        N=size(r.d);
        if isempty(find(strcmpi(text,r.d(1,:))))
            for i=1:N(2)
                if isnumeric(r.d{2,i}) | strcmpi(r.d{1,i},'_identifier')
                    j(i)=0;
                elseif not(isnan(str2double(r.d{2,i})))
                    j(i)=0;
                else
                    j(i)=1;
                end
            end
            j=find(j);
            if askForInput
                setPar.variableToCreateSemanticRepresentationFrom=questdlg('Choose variable to create semantic representation from','Choose variable to create semantic representation from','cancel',r.d{1,j(1)},r.d{1,j(min(2,length(j)))},'cancel');
            else
                setPar.variableToCreateSemanticRepresentationFrom=r.d{1,j(1)}; %questdlg('Choose variable to create semantic representation from','Choose variable to create semantic representation from','cancel',r.d{1,j(1)},r.d{1,j(min(2,length(j)))},'cancel');
            end
            if not(strcmpi(setPar.variableToCreateSemanticRepresentationFrom,'cancel'))
                getPar(setPar,'persistent');
                s.par.variableToCreateSemanticRepresentationFrom=setPar.variableToCreateSemanticRepresentationFrom;
            end
        end
    end
    handles=getHandles;
    set(handles.report,'Data',r.d);
    [Nrow Ncol]=size(r.d);
    set(handles.report,'ColumnEditable',true(1,Ncol+1));
else
    %s=getSpace('s');
    [words, data, col, all_labels]=textread2([PathName FileName],0);
    %s.datafile=regexprep(FileName,'.xlsx','');
    if not(isfield(s,'datafile'))
        s.datafile=[];
    end
    s.par.askForInput=askForInput;
    s=set_word_property_from_variables(s,words, data, col,all_labels,Name);
end
printSpaceInfo(s);
