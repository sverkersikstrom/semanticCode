function [par error]=setParText(par,text);
varargin{1}=par;
sep=findstr(text,',');
start=1;
for i=1:length(sep)+1
    if i==length(sep)+1
        varargin{i+1}=text(start:length(text));
    else
        varargin{i+1}=text(start:sep(i)-1);
        start=sep(i)+1;
    end
    num=str2double(varargin{i+1});
    if not(isnan(num))
        varargin{i+1}=num;
    else
        if not(varargin{i+1}(1)=='''')
            error='Missing ''';
        else not(varargin{i+1}(end)=='''')
            varargin{i+1}=varargin{i+1}(2:end-1);
        end
    end
end
[par error]=setPar(varargin{:});
1;