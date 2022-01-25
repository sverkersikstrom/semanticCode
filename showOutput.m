function varargout = showOutput(varargin)
% SHOWOUTPUT MATLAB code for showOutput.fig
%      SHOWOUTPUT, by itself, creates a new SHOWOUTPUT or raises the existing
%      singleton*.
% 
%      H = SHOWOUTPUT returns the handle to a new SHOWOUTPUT or the handle to
%      the existing singleton*.
%
%      SHOWOUTPUT('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in SHOWOUTPUT.M with the given input arguments.
%
%      SHOWOUTPUT('Property','Value',...) creates a new SHOWOUTPUT or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before showOutput_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to showOutput_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help showOutput

% Last Modified by GUIDE v2.5 05-Apr-2016 21:18:04

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @showOutput_OpeningFcn, ...
                   'gui_OutputFcn',  @showOutput_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before showOutput is made visible.
function showOutput_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to showOutput (see VARARGIN)

% Choose default command line output for showOutput
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);
if length(varargin)==3 
    saveResult(varargin{3},handles);
    return
end
if length(varargin)>1
    hObject.Name=varargin{2};
    fprintf('%s\n',varargin{2});
end


%Clear current data
N=size(handles.uitable1.Data);
tmp2{1,1}='';
handles.uitable1.Data=tmp2;

% for i=1:N(1)
%     for j=1:N(2)
%         tmp{i,j}='';
%     end; 
% end
% handles.uitable1.Data=tmp;

varargin{1}{1}=regexprep(varargin{1}{1},char(10),char(13));
if length(varargin{1}{1})>1000000 %Limit to 1M bytes
    varargin{1}{1}=varargin{1}{1}(1:1000000);
end
row=findstr(varargin{1}{1},char(13));
if isempty(row) row=length(varargin{1}{1});end
lrow=1;
tic
Data{length(row),1}=' ';
for i=1:min(10000,length(row))
    text=varargin{1}{1}(lrow:min(end,row(i)));
    col=findstr([text char(9)],char(9));
    lcol=1;
    for j=1:length(col)
        tmp=regexprep(text(lcol:col(j)-1),char(13),' ');
        %handles.uitable1.Data{i,j}=tmp;
        Data{i,j}=tmp;
        lcol=col(j)+1;
    end
    lrow=row(i);
end
handles.uitable1.Data=Data;
%toc

w=get(handles.uitable1,'ColumnWidth');
[rmax Nc]=size( handles.uitable1.Data);
set(handles.uitable1,'ColumnEditable',true(1,Nc));
w(rmax+1:Nc)=100;
N=size(handles.uitable1.Data);
%set(handles.uitable1,'ColumnWidth',100);%*ones(1,N(2)));

s=getSpace;
if s.par.printOutputToScreen
    fprintf('%s\n',varargin{1}{1});
end
if s.par.saveResults2File
    f=fopen(['results '  datestr(now,'yyyy-mm-dd') '.txt'],'a') ;
    if length(varargin)>1
        fprintf(f,'%s%s\n',varargin{2},datestr(now,'yyyy-mm-dd HH:MM'));
    end
    fprintf(f,'%s %s',varargin{1}{1});
    fclose(f);
end
1;

%set(handles.uitable1,'Data',Data);

% UIWAIT makes showOutput wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = showOutput_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --------------------------------------------------------------------
function Save_Callback(hObject, eventdata, handles)
[file path]=uiputfile('*.txt');
if not(file==0)
    saveResult([path file],handles)
end
% hObject    handle to Save (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

function saveResult(file,handles);
    warning off
    f=fopen(file,'w','n','UTF-8');
    warning on
    text=handles.uitable1.Data;
    N=size(text);
    for i=1:N(1)
        for j=1:N(2)
            fprintf(f,'%s\t',text{i,j});
        end
        fprintf(f,'\n');
    end
    fclose(f);
