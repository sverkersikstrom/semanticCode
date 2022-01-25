function s=createSpaceFromContext(s,ver,index,name,synonymfile);
%wordset=getWord(s,'_doc*');
%createSpace(s,wordset.index,'test.txt');
if nargin<1 
    s=getSpace;
end
if nargin<2
    ver='Report';
end
if nargin<3 & not(strcmpi(ver,'Report'))
    [wordset s]=getWordFromUser(s,'Select a set of words');
    index=wordset.index;
end
if nargin<4
    d.file=inputdlg3('Name of new space',regexprep(s.filename,'\.mat',''));
else
    d.file=name;
end
d.file=[d.file '.txt'];
if nargin<5
    synonymfile='';
end


f=fopen(d.file,'w','n','UTF-8');    
if strcmpi(ver,'Report')
    data=get(s.handles.report,'Data');
    for i=1:size(data,1)
        for j=1:size(data,2)
            if not(isnumeric(data{i,j}))
                if not(length(data{i,j})>0 & data{i,j}=='_')
                    fprintf(f,'%s\n',data{i,j});
                end
            end
        end
    end
else
    for i=1:length(index)
        fprintf(f,'%s\n',getText(s,index(i)));
    end
end
fclose(f);

s=createSpace(d.file,synonymfile);
