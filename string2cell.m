function cell=string2cell(string,delimiter)
if iscell(string)
    cell=string;
elseif not(isempty(string))
    if nargin>1
        cell=textscan(string,'%s','delimiter',delimiter);
    else
        cell=textscan(string,'%s');
    end
    cell=cell{1};
else
    cell='';
end