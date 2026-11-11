function par=structCopy(par,setPar,checkDataType);
if nargin<3
    checkDataType=0;
end
if not(isempty(setPar))
    f=fields(setPar);
    for i=1:length(f)
        if checkDataType
            if isfield(par,f{i}) 
                if isnumeric(par.(f{i})) & not(isnumeric(setPar.(f{i})))
                   if ischar(setPar.(f{i}))
                       tmp=str2num(setPar.(f{i}));
                       eval(['setPar.' f{i} '=tmp;']);
                   else
                       fprintf('Data conversion problem for par.%s\n',f{i})
                   end
                end
            end
        end
        eval(['par.' f{i} '=setPar.' f{i} ';']);
    end
end