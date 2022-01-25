% --- Executes on button press in commandOrData.
function commandOrData_Callback(hObject, eventdata, handles,ver)
% hObject    handle to commandOrData (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if nargin<4; ver='';end
global reportCommand;
persistent savedData;
global reportFilename
try
    a=findstr(reportFilename,'/');
    if isempty(a) a=' ';end
    set(handles.reportFile,'string',reportFilename(a(end)+1:length(reportFilename)));
end
hObject=handles.commandOrData;
if strcmpi(get(hObject,'String'),'Command')
    if strcmpi(ver,'Command');return;end
    set(hObject,'String','Data')
    savedData=get(handles.report,'Data');
    if sum(size(reportCommand)<size(savedData))
        [Nr Nc]=size(savedData);
        reportCommand{Nr,Nc}=[];
    end
    set(handles.report,'Data',reportCommand);
else
    reportCommand=get(handles.report,'Data');
    set(hObject,'String','Command');
    set(handles.report,'Data',savedData);
end
