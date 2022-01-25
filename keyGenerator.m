function key=keyGenerator(varargin)
key=0;
for i=1:length(varargin)
    if ischar(varargin{i}) | isnumeric(varargin{i})
        if size(varargin{i},1)>size(varargin{i},2) varargin{i}=varargin{i}'; end
        key=key+nansum(varargin{i})+nansum([varargin{i} 1].* [2 varargin{i}]);
        %key=key+nansum(varargin{i});
    else
        key=key+nansum(struct2text(varargin{i}));
    end
end
%key=num2str(key);