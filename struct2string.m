function string=struct2string(struct,seperator);
if nargin<2
    seperator=' ';
end
string='';
%Text that is already a string, or a single value, needs no joining
if ischar(struct)
    string=struct;
    return
elseif not(iscell(struct))
    struct={struct};
end
for i=1:length(struct)
    string=[string  num2str2(struct{i}) seperator];
end
end

function t=num2str2(t)
if not(ischar(t))
    t=num2str(t);
end
end