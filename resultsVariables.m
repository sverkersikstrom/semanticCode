function [resultsNumber resultString resultsStringAlways]=resultsVariables(out,resultsVariables,default)
resultsNumber=NaN;
resultString='';
if length(resultsVariables)==0
    if ischar(default)
        resultString=default;
    else
        resultsNumber=default;
    end
else
    v=string2cell(resultsVariables);
    resultString='';
    for i=1:length(v)
        if isfield(out,v{i})
            d=eval(['out.' v{i} ';']);
            if strcmpi(v{i}(1),'p')
                d=sprintf('%.4f',d);
            end
            if strcmp(v{i},'none')
            elseif length(v)==1 & isnumeric(d)
                resultsNumber=d;
            elseif length(v)==1
                resultString=[resultString  num2str(d) ];
            else
                resultString=[resultString v{i} '=' num2str(d) ';'];
            end
        else
            resultString=[v{i} ' is not a valid output variable, try: ' struct2string(fields(out))];
        end
    end
end
if isempty(resultString); 
    resultsStringAlways=num2str(resultsNumber);
else; 
    resultsStringAlways=resultString;
end
