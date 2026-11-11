function key=keyGenerator(varargin)
key=0;
for i=1:length(varargin)
    if ischar(varargin{i}) | isnumeric(varargin{i})
        %A row or a column gives the same key as before. A matrix with several rows used to fail.
        v=varargin{i}(:)';
        key=key+nansum(v)+nansum([v 1].* [2 v]);
        %key=key+nansum(varargin{i});
    else
        key=key+nansum(struct2text(varargin{i}));
    end
end
%key=num2str(key);