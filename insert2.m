function status = insert2(varargin)
status=[];
    if(nargin < 5)        
        varargin{5} = 0;
    end    
    [Nc,~] = size(varargin{4});   
        
    if(Nc > varargin{5} && varargin{5} > 0) 
        % This optimizes the insert procedure for large inputs by 
        % didviding them into smaller chuncks
        for i=1:varargin{5}:Nc
            if rand<.1; 
                fprintf('.');
            end
            %%% Recursively call this function with selected chunk size %%%
            status = ...
                insert2(varargin{1},varargin{2},varargin{3},varargin{4}(i:min(Nc,i+varargin{5}-1),:));
        end
    else
        %%% CREATE FAST INSERT STATEMENT %%%
        fields = '';        
        for(i=1:length(varargin{3}))
            fields = [fields varargin{3}{i} ','];       
        end
        fields = fields(1:length(fields)-1);% remove last comma

        [rows,~] = size(varargin{4});
        data = '(';
        k = length(data);
        for(j=1:rows)
            d = '';
            for(i=1:length(varargin{3}))
                if(isnumeric(varargin{4}{j,i})) 
                    if(isnan(varargin{4}{j,i}))
                        % Replace Nan with null
                        d1 = 'null';
                    else   
                        d1 = num2str(varargin{4}{j,i}); 
                    end
                    d = [d d1 ','];
                else
                    d1 = varargin{4}{j,i};
                    % Fixe for quotes written to in strings!
                    d1 = regexprep(d1,'''','''''');
                    d = [d '''' d1 ''','];
                end 
            end
            % Remove last comma
            d = [d(1:length(d)-1) '),('];
            if(length(data) < length(d) + k)
                % Pre-allocates size of data for speed!
                data(200+length(data)*2) = ' ';
            end
            data(k+1:k+length(d)) = d;
            k = k+length(d);
        end
        % Remove last paranthesis
        data = [data(1:k-2) ]; 
        
        %%% EXECUTE FAST INSERT %%%
        table = [ varargin{2}];  %varargin{1}.Instance '.'      
        query = ['INSERT INTO `' table '` (' fields ') VALUES ' data ';'];
        status=exec(varargin{1},query,0);
        if length(status.Message)>0
            fprintf('%s\n',status.Message)
        end
    end
    
    % Memory optimization
    data = [];
    fields = [];
    d = [];
    d1 = [];
    varargin = [];
    query = [];
end