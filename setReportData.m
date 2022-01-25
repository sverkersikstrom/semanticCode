function setReportData(handles,d);
w=get(handles,'ColumnWidth');
[rmax Nc]=size(d);
set(handles,'ColumnEditable',true(1,Nc));
w(length(w)+1:Nc)={100};
try
set(handles,'Data',d);
catch
    fprintf('error')
end
set(handles,'ColumnWidth',w);
