function r=getReportCommand(r,c)
global reportCommand
[Nr Nc]=size(reportCommand);
if Nr>=r & Nc>=c
    r=reportCommand{r,c};
else
    r=[];
end
