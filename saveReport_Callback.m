%NOT USED --------------------------------------------------------------------
function saveReport(hObject, eventdata, handles,AskForFile)
% hObject    handle to saveReport (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
commandOrData_Callback(hObject, eventdata, handles,'Command'); 
global reportFilename 
if length(reportFilename)==0 & nargin>3
    return
end
d=get(handles.report,'Data');
r.d=d;
global reportCommand;
r.reportCommand=reportCommand;
s=saveSpace(getSpace);
r.spacefile= s.datafile;
if isempty(reportFilename) | AskForFile
    [FileName,PathName] =uiputfile('*','Save report');
    if FileName==0; return;end
    reportFilename=[PathName FileName];
end
fprintf('Saving report %s\n',reportFilename);
save(reportFilename,'r');
f=fopen([reportFilename '.txt'],'w');
%xlswrite([reportFilename '.xls'],d)
[Nr Nc]=size(d);
for r=1:Nr
    for c=1:Nc
        if isnumeric(d{r,c})
            fprintf(f,'%s\t',num2str(d{r,c}));
            d{r,c}=num2str(d{r,c});
        else
            fprintf(f,'%s\t',regexprep(d{r,c},char(9),char(32)));
        end
    end
    fprintf(f,'\n');
end
fclose(f);
