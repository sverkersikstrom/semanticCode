function [r p]=nancorr(varargin);
a=varargin{1};b=varargin{2};
global correlationType
if length(correlationType)>0
    varargin{end+1}='type';
    varargin{end+1}=correlationType;
end
index=find(not(isnan(a+b)));
if isempty(index)
    r=NaN;p=NaN;
else
    if length(varargin)>2
        [r p]=corr(a(index),b(index),varargin{3:end});
    else
        [r p]=corr(a(index),b(index));
    end
end