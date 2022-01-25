function varargout = inputwords(varargin)
% INPUTWORDS M-file for inputwords.fig 
%      INPUTWORDS, by itself, creates a new INPUTWORDS or raises the existing
%      singleton*.
%
%      H = INPUTWORDS returns the handle to a new INPUTWORDS or the handle to
%      the existing singleton*.
%
%      INPUTWORDS('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in INPUTWORDS.M with the given input arguments.
%
%      INPUTWORDS('Property','Value',...) creates a new INPUTWORDS or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before inputwords_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to inputwords_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help inputwords

% Last Modified by GUIDE v2.5 28-Jun-2019 18:22:29

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
warning('off','MATLAB:dispatcher:InexactMatch');
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @inputwords_OpeningFcn, ...
                   'gui_OutputFcn',  @inputwords_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    warning off;
    gui_State.gui_Callback = str2func(varargin{1});
    warning on
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before inputwords is made visible.
function inputwords_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to inputwords (see VARARGIN)

% Choose default command line output for inputwords
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes inputwords wait for user response (see UIRESUME)
% uiwait(handles.figure1);

global out
global f 
f=[regexprep(varargin{1},' ','_') '_'];
f=regexprep(f,'(','');
f=regexprep(f,'\.','');
f=regexprep(f,'!','');
f=regexprep(f,')','');
f=regexprep(f,'*','');
f=regexprep(f,',','');
f=regexprep(f,'=','');
f=regexprep(f,'-','');
if length(f)>63
    f=f(1:63);
end

if exist('default.mat')
    load('default');
    if isfield(d,f)
         eval(['out2=d.' f ';']);
         if isfield(out2,'word')
             set(handles.edit1,'String',out2.word);
             set(handles.condition,'Value',out2.condition);
             set(handles.condition_string,'string',out2.condition_string);
         end
         if isfield(d,'handles')
             set(handles.parameterCategory,'Value',d.handles.parameterCategory.Value)
             set(handles.listbox2,'Value',d.handles.listbox2.Value)
             
             try
                 set(handles.parameter,'Value',d.handles.parameter.Value)
             end
         end
    end
end

out.reportWord=0;
out.context_words=get(handles.context_words,'Value');
out.context_include=get(handles.context_include,'Value');
out.context_list=get(handles.context_list,'String');
%out.start_date=datenum(get(handles.start_date,'String'),'yyyy-mm-dd');
%out.end_date=datenum(get(handles.end_date,'String'),'yyyy-mm-dd');
out.newWord='';

if length(varargin)>=4
    [tmp, categories]=getIndexCategory;

    set(handles.listbox2,'String',categories)

    s=varargin{4};
    id=getIndexCategory(get(handles.listbox2,'Value'),s);

    set(handles.popupmenu2,'String',id)
    
    updatePar(handles);
end

if length(varargin)>=2
    set(handles.figure1,'Name',varargin{1})
end
if length(varargin)>=3 %defaults
    if isfield(varargin{3},'time_period')
        set(handles.time_period,'Value',varargin{3}.time_period);
    end
    if isfield(varargin{3},'single_words')
        set(handles.single_words,'Value',varargin{3}.single_words);
    end
    if isfield(varargin{3},'default')
        out.default=1;%delete(handles.figure1)
    end
end

%out.time_period=get(handles.time_period,'Value');
out.condition=get(handles.condition,'Value');
out.condition_string=get(handles.condition_string,'string');
out.single_words=get(handles.single_words,'Value');
out.subtract_word=0;
out.subtract_this_word='';
out.cancel=0;
out.converge=0;
out.wordclass=0;

p=get(hObject,'position');
p(1)=1;
p(4)=25;
set(hObject,'position',p);
%set(handles.uipanel2,'Visible','off')

if length(varargin)>=3 %defaults
end

% --- Outputs from this function are returned to the command line.
function varargout = inputwords_OutputFcn(hObject, eventdata, handles) 
% Get default command line output from handles structure
par=getPar;
if not(par.generalUseDefaultSettings)
    uiwait
else
    fprintf('Using the default settings. Turn this off by: Analyse/Set parameters/Various Settings/Use default settings=0\n');
    ok_Callback(hObject, eventdata, handles)
end
global out;
out.words=string2cell(out.word);
out.labels=regexprep(regexprep(out.words,'*',''),'_','');
varargout{1} = out;

function edit1_Callback(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit1 as text
%        str2double(get(hObject,'String')) returns contents of edit1 as a double


% --- Executes during object creation, after setting all properties.
function edit1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in file.
function file_Callback(hObject, eventdata, handles)
% hObject    handle to file (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[file,PathName]=uigetfile('*.txt','Fil','');
if not(file(1)==0)
    global out;
    out.word=file;
    delete(handles.figure1)
end


% --- Executes on button press in ok.
function ok_Callback(hObject, eventdata, handles)
% hObject    handle to ok (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%parameterInput_Callback(hObject, eventdata, handles)
%d=updatePar(handles);
global out;
if exist('default.mat')
    load('default');
else
    d=[];
end
global f
out.word=get(handles.edit1,'String');
eval(['d.' f '=out;']);
d.handles.parameterCategory.Value=handles.parameterCategory.Value;
d.handles.listbox2.Value=handles.listbox2.Value;

d.handles.parameter.Value=handles.parameter.Value;

saveDefault('default',d)
delete(handles.figure1)
refresh 
drawnow
1;




% --- Executes on button press in single_words.
function single_words_Callback(hObject, eventdata, handles)
% hObject    handle to single_words (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global out;
out.single_words=get(handles.single_words,'Value');



% --- Executes on button press in condition.
function condition_Callback(hObject, eventdata, handles)
% hObject    handle to condition (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global out;
out.condition=get(handles.condition,'Value');

% Hint: get(hObject,'Value') returns toggle state of condition



function condition_string_Callback(hObject, eventdata, handles)
% hObject    handle to condition_string (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global out;
out.condition_string=get(handles.condition_string,'string');

% Hints: get(hObject,'String') returns contents of condition_string as text
%        str2double(get(hObject,'String')) returns contents of condition_string as a double


% --- Executes during object creation, after setting all properties.
function condition_string_CreateFcn(hObject, eventdata, handles)
% hObject    handle to condition_string (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end




% --- Executes on selection change in listbox2.
function listbox2_Callback(hObject, eventdata, handles)
id=getIndexCategory(get(handles.listbox2,'Value'));

if get(handles.chooseAll,'Value')
    s=getSpace;
    [text b index]=getIndexCategory(get(handles.listbox2,'Value'),s);
    
    set(handles.edit1,'string',[get(handles.edit1,'string') ' ' cell2string(s.fwords(index))])

end

set(handles.popupmenu2,'String',id)

% --- Executes during object creation, after setting all properties.
function listbox2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listbox2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in context_words.
function context_words_Callback(hObject, eventdata, handles)
global out;
out.context_words=get(handles.context_words,'Value');




% --- Executes on button press in context_include.
function context_include_Callback(hObject, eventdata, handles)
global out;
out.context_include=get(handles.context_include,'Value');

function context_list_Callback(hObject, eventdata, handles)
global out;
out.context_list=get(handles.context_list,'string');

function context_list_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end





function sort_word_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end





% --- Executes during object creation, after setting all properties.
function subtract_this_word_CreateFcn(hObject, eventdata, handles)
% hObject    handle to subtract_this_word (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end




% --- Executes on button press in cancel.
function cancel_Callback(hObject, eventdata, handles)
% hObject    handle to cancel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global out;
out.word='';
out.cancel=1;
delete(handles.figure1)




% --- Executes on button press in converge_by_frequency.
function converge_by_frequency_Callback(hObject, eventdata, handles)
% hObject    handle to converge_by_frequency (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of converge_by_frequency
global out;
out.converge=get(handles.converge_by_frequency,'Value');




% --- Executes during object creation, after setting all properties.
function wordclass_CreateFcn(hObject, eventdata, handles)
% hObject    handle to wordclass (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



% --- Executes on button press in more.
function more_Callback(hObject, eventdata, handles)
% hObject    handle to more (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%fprintf('More is disabled\n')
%return

%p=get(gcf,'position');
%p(4)=0;
string=get(handles.uipanel2,'Visible');
if strcmp(string,'off') %0 | p(4)>30 | p(4)<1; %This always occurs, ok?
    %p(4)=25;%15*1;
    set(handles.more,'String','Less');
    set(handles.uipanel2,'Visible','on')
else
    set(handles.uipanel2,'Visible','off')
    set(handles.more,'String','More')
end
%set(gcf,'position',p);
%set(hObject,'position',p);
%set(hObject,'Visible','on')
%drawnow
%refresh 



% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: delete(hObject) closes the figure
global out;
out.word='';
out.cancel=1;
delete(hObject);



function newWord_Callback(hObject, eventdata, handles)
% hObject    handle to newWord (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of newWord as text
%        str2double(get(hObject,'String')) returns contents of newWord as a double
global out
out.newWord=get(handles.newWord,'String');


% --- Executes during object creation, after setting all properties.
function newWord_CreateFcn(hObject, eventdata, handles)
% hObject    handle to newWord (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



% --- Executes on button press in reportWords.
function reportWords_Callback(hObject, eventdata, handles)
% hObject    handle to reportWords (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global out;
%out.reportWord=1;
s=getSpace;
d=get(s.handles.report,'Data');
[Nr Nc]=size(d);
wordSet=d(2:Nr,1);
inword=cell2string(wordSet');
out.word=inword;
%out.reportWord=0;
set(handles.edit1,'String',out.word);
1;
%delete(handles.figure1)


% --- Executes on selection change in popupmenu2.
function popupmenu2_Callback(hObject, eventdata, handles)
contents = get(hObject,'String');
try
    contents=contents{get(hObject,'Value')};
    t=findstr(contents,':');
    if not(isempty(t))
        contents=contents(1:t-1);
    end
    set(handles.edit1,'string',[get(handles.edit1,'string') ' ' contents])
end


% --- Executes during object creation, after setting all properties.
function popupmenu2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



% --- Executes on button press in chooseAll.
function chooseAll_Callback(hObject, eventdata, handles)
% hObject    handle to chooseAll (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of chooseAll


% --- Executes on selection change in parameterCategory.
function parameterCategory_Callback(hObject, eventdata, handles)
% hObject    handle to parameterCategory (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns parameterCategory contents as cell array
%        contents{get(hObject,'Value')} returns selected item from parameterCategory
[par d]=getPar;
contents = get(hObject,'String');
contents=contents{get(hObject,'Value')};
index=find(strcmpi(contents,d.category));
if handles.parameter.Value>length(index)
    set(handles.parameter,'Value',1);
end
updatePar(handles);


% --- Executes during object creation, after setting all properties.
function parameterCategory_CreateFcn(hObject, eventdata, handles)
% hObject    handle to parameterCategory (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



% --- Executes on selection change in parameter.
function parameter_Callback(hObject, eventdata, handles)
% hObject    handle to parameter (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns parameter contents as cell array
%        contents{get(hObject,'Value')} returns selected item from parameter
d=updatePar(handles);
[par d]=getPar([]);%persistent


% --- Executes during object creation, after setting all properties.
function parameter_CreateFcn(hObject, eventdata, handles)
% hObject    handle to parameter (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in parametersOn.
function parametersOn_Callback(hObject, eventdata, handles)
% hObject    handle to parametersOn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of parametersOn



function parameterInput_Callback(hObject, eventdata, handles)
v=get(handles.parameterInput,'String');
d=updatePar(handles);
if strcmp(d.datatype{d.i},'string') 
    eval(['setPar.' d.field{d.i} '=''' regexprep(v,'''','''''') ''';']);
else
    if not(isnan((str2double(v))))
        eval(['setPar.' d.field{d.i} '=[' v '];']);
    elseif not(isnan((str2double(v(1:min(length(v),1))))))
        eval(['setPar.' d.field{d.i} '=[' v '];']);
    elseif isempty(v)
        eval(['setPar.' d.field{d.i} '=[];']);
    else
        eval(['setPar.' d.field{d.i} '=' v ';']);
    end
end
setPar.persistent=1;
[par d]=getPar(setPar);
d=updatePar(handles);


%setPar
% hObject    handle to parameterInput (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of parameterInput as text
%        str2double(get(hObject,'String')) returns contents of parameterInput as a double


% --- Executes during object creation, after setting all properties.
function parameterInput_CreateFcn(hObject, eventdata, handles)
% hObject    handle to parameterInput (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function d=updatePar(handles)
[par d]=getPar;
set(handles.parameterCategory,'String',unique(upper(d.category)));

contents = get(handles.parameterCategory,'String');
contents=contents{get(handles.parameterCategory,'Value')};

d.index=find(strcmpi(contents,d.category));
d.i=1;

a=get(handles.parameter);
d.i=d.index(a.Value);
if iscell(d.options{d.index(a.Value)})
    set(handles.parameterListbox,'Visible','On')
    set(handles.parameterInput,'Visible','Off')
    d.listbox=d.options{d.i};
    d.listbox=d.listbox;%{1}';
    set(handles.parameterListbox,'String',d.listbox');
    set(handles.parameterListbox,'Value',find(strcmpi(d.listbox',num2str(d.value{d.i}))));
else
    set(handles.parameterListbox,'Visible','Off')
    set(handles.parameterInput,'Visible','On')    
end
if iscell(d.value{d.index(a.Value)})
    d2.tmp=d.value{d.index(a.Value)};
    set(handles.parameterInput,'String',regexprep(struct2text(d2),'par.tmp=',''))
else
    set(handles.parameterInput,'String',num2str(d.value{d.index(a.Value)}))
end
set(handles.parameter,'String',d.commentValue(d.index))

% --- Executes on button press in ClearParameters.
function ClearParameters_Callback(hObject, eventdata, handles)
par.clear=1;
getPar(par);
updatePar(handles);
% hObject    handle to ClearParameters (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in LoadParameters.
function LoadParameters_Callback(hObject, eventdata, handles)
file=uigetfile('*.mat');
if not(file==0)
    load(file)
    try
        getPar(setParPersistent);
        d=updatePar(handles);
    catch
        fprinft('Unable to set parameters from file\n')
    end
end
1;
% hObject    handle to LoadParameters (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in saveParameters.
function saveParameters_Callback(hObject, eventdata, handles)
file=uiputfile('*.mat');
d=updatePar(handles); 
setParPersistent=d.setParPersistent;
save(file,'setParPersistent');

% hObject    handle to saveParameters (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on selection change in parameterListbox.
function parameterListbox_Callback(hObject, eventdata, handles)
% hObject    handle to parameterListbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns parameterListbox contents as cell array
%        contents{get(hObject,'Value')} returns selected item from parameterListbox
value=get(handles.parameterListbox,'Value');
d=updatePar(handles);
set(handles.parameterListbox,'Value',value);
dataString=d.listbox{value};
dataNum=str2double(dataString);
if not(isnan(dataNum))
    eval(['setPar.' d.field{d.i} '=' dataString ';']);
else
    eval(['setPar.' d.field{d.i} '=''' dataString ''';']);
end
setPar.persistent=1;
[par d]=getPar(setPar);
d=updatePar(handles);


% --- Executes during object creation, after setting all properties.
function parameterListbox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to parameterListbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


