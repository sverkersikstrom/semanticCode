function [par error]=setPar(varargin)
error='';
par=varargin{1};
skip=0;
for i=2:length(varargin)
    if skip %parameter already taken care of...
        skip=0;
    elseif i==length(varargin)
        error=['Missing variable following ''' varargin{i} '''.']
    else isfield(par,varargin{i})
        if isnumeric(eval(['par.' varargin{i}]))
            if not(isnumeric(varargin{i+1}))
                error=[error 'Variable following ''' varargin{i} ''' should be numeric.'];
                skip=1;
            else
                eval(['par.' varargin{i} '=' num2str(varargin{i+1}) ';']);
                skip=1;
            end
        elseif islogical(eval(['par.' varargin{i}]))
            if not(islogical(varargin{i+1})) & not(varargin{i+1})==0 & not(varargin{i+1})==1
                error=['Variable following ''' varargin{i} ''' should be logical.'];
                skip=1;
            else
                eval(['par.' varargin{i} '=' num2str(varargin{i+1}) '==1;']);
                skip=1;
            end
        elseif ischar(eval(['par.' varargin{i}]))
            if not(ischar(varargin{i+1}))
                error=[error 'Variable following ''' varargin{i} ''' should be a string.'];
                skip=1;
            else
                eval(['par.' varargin{i} '=''' varargin{i+1} ''';']);
                skip=1;
            end
        end
    end
    if skip & i<length(varargin)
        allowed={'logistic','regression','ridge'};
        if strcmpi(varargin{i},'model') & isempty(find(strcmpi(varargin{i+1},allowed)))
            error=[error 'model can only take these values:',cell2string(allowed)];
        end
    end
end
par.error=error;