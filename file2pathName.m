function [path,file,ext,fileNoExtentsion]=file2pathName(pathFile);
i=findstr(pathFile,'/');
if isempty(i); i=0;end
path=pathFile(1:i(end));
file=pathFile(i(end)+1:end);
j=findstr(pathFile,'.');
ext=pathFile(j+1:end);
fileNoExtentsion=pathFile(i(end)+1:j-1);

