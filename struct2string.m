function string=struct2string(struct,seperator);
if nargin<2
    seperator=' ';
end
string='';
for i=1:length(struct)
    string=[string  struct{i} seperator];
end
end