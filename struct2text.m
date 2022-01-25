function t=struct2text(par,fieldName,limit,newline)
if nargin<2
    fieldName=[];
end
if isempty(fieldName)
    fieldName='par';
end
if nargin<3
    limit=150;
end
if nargin<4
    newline=0;
end
t='';
if isempty(par)
    return
end

f=fields(par);
for i=1:length(f)
    d=eval(['par' '.' f{i}]);
    if isstruct(d)
        t=[t struct2text(d,[fieldName '.' f{i}],limit,newline)];
    else
        t=[t fieldName '.' f{i} '='];
        t=[t  datatype2string(d,fieldName,f{i},limit,newline)];
        t=[t ';' char(13)];
    end
end
1;

function t=datatype2string(d,fieldName,f,limit,newline)
if nargin<5; limit=0;end
if nargin<5; newline=0;end
try
    if isstr(d)
        if not(newline)
            d=regexprep(d,char(10),[char(9) char(9)]);
        end
        d=regexprep(d,'''','''''');
        t=['''' d ''''];
    elseif isnumeric(d) | islogical(d)
        s1=size(d); 
        d2='';
        if s1(1)==0
            t='[]';
        else
            if limit>0 & limit<s1(1)
                s1(1)=limit;
            end
            for i=1:s1(1)
                d2=[d2 num2str(d(i,:))];
                if s1(1)>1 & i<s1(1)
                    d2=[d2 '; '];
                end
            end
            if length(d)>1;b1='[';b2=']';
            else b1='';b2=''; end
            t=[ b1 d2 b2 ];
        end
    elseif iscell(d)
        t='{';
        for i=1:length(d)
            t=[t  datatype2string(d{i},fieldName,f,limit,newline)  ];
            if i<length(d)
                t=[t '; '];
            end
        end
        t=[t '}'];
    elseif isstruct(d)
        t=[ struct2text(d,f,limit)];
    else
        t='';'Can not conver to string:'
        d
    end
catch
    t=[ '''error'''];
end
newlines=max(1,length(strfind(t,char(10))));%Per line...
if length(t)>newlines*limit & limit>0
    t=[t(1:limit) ' %...TRUNCATED REMOVING ' num2str(length(t)-limit) ' CHARACTERS' ];%Truncate long strings...
end
