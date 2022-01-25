function a=struct2Tabel(info,fields,labels)
a=sprintf('\t');
for i=1:length(labels)
    a=[a sprintf('%s\t',labels{i})];
end
a=[a sprintf('\n')];
a='';
for i=1:length(fields)
    a=[a sprintf('%s\t%s\n',fields{i},structFields2string(info,fields{i}))];
end
a=regexprep(a,[char(9) '0.'],[char(9) '.']);
fprintf('%s',a);

