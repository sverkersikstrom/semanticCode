function [d s]=reportUpdateRow(s,d,r,word,update)
if nargin<5; update=1;end
handles=s.handles;
if isempty(d)
    d=get(s.handles.report,'Data');
end
[rmax Nc]=size(d);
if isnan(r)
   r=find(strcmpi(d(:,1),word));
   if isempty(r); 
       r=find(strcmpi(d(2:rmax,1),''))+1;
       if isempty(r);
           r=rmax ;
       end
   end
   r=max(2,r(1));
   d{r,1}=word;
   d{rmax+1,1}='';
end

for col=2:Nc
    if length(d{1,col})>0 && length(d{r,1})>0
        [~,text, s]=getProperty(s,d{r,1},d{1,col},getReportCommand(r,col));%d{r,col},
        d{r,col}=text{1};
    end
end
if update
    setReportData(handles.report,d);
end