function saveReport(s,datafile)
if nargin<1
    s=getSpace;
end
if nargin==2
    s.datafile=datafile;
end
%if nargin<2
AskForFile=0;
%end
global reportFilename 

handles=getHandles;
d=get(handles.report,'Data');
r.d=d;
global reportCommand;
r.reportCommand=reportCommand;
if isempty(reportFilename) | AskForFile
    fprintf('Input name of the REPORT file!\n')
    [FileName,PathName] =uiputfile('*','Save report');
    if FileName==0; return;end
    reportFilename=[PathName FileName];
end
if length(s.datafile)==0
    i=findstr(reportFilename,'/');
    if length(i)>0
        file=reportFilename(i(end)+1:end);
        path=reportFilename(1:i(end));
    else
        file=reportFilename;
        path='';
    end
    file=regexprep(file,'.csv','');
    file=['space ' file];
    if s.par.askForInput
        s.datafile = questdlg('Name of space file','Space file name',file,'Change',file);
    else
        s.datafile =file;
    end
    if strcmpi('Change',s.datafile)
        [datafile,PathName] =uiputfile('*.mat','Name of space-file');
        if datafile==0
            return
        else
            s.datafile=datafile;
        end
    end
end
s=saveSpace(s,s.datafile);
r.spacefile= s.datafile;


save(reportFilename,'r');
saveFile(reportFilename,d)


