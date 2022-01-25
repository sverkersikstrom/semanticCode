function newReport_Callback(hObject, eventdata, handles)
if nargin<=2
    handles=getHandles;
end
commandOrData_Callback(hObject, eventdata, handles,'Command');
global reportFilename 
global reportCommand;
reportCommand=[];
reportFilename=[];
for i=1:30    
    d{i,1}='';
end
for i=1:12    
    d{1,i}='';
end
d{1,1}='_identifier';
d{1,2}='_text';
try
    set(handles.report,'Data',d);
catch
    fprintf('Warning...\n')
end 
