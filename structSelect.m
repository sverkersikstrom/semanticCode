% Select subset of a struct
function structObj = structSelect(structObj,indexToKeep,requiredLength)
if nargin < 3
    requiredLength = 0;
end

columns = fieldnames(structObj);
for i=1:length(columns);
    try
        if eval(['ischar(structObj.' columns{i} ')'])
            1;
        else
            dim = eval(['size(structObj.' columns{i} ')']);
            
            if requiredLength > 0
                if eval(['length(structObj.' columns{i} ')==requiredLength'])
                    eval(['structObj.' columns{i} ...
                        '=structObj.' columns{i} '(indexToKeep,1:dim(2));']);
                end
            else
                try
                    eval(['structObj.' columns{i} ...
                        '=structObj.' columns{i} '(1:dim(1),indexToKeep);']);
                catch
                    eval(['structObj.' columns{i} ...
                        '=structObj.' columns{i} '(indexToKeep,1:dim(2));']);
                end
            end
        end
    end
end
end
