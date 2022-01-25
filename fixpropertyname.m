function [a2 a]=fixpropertyname(a,s)
if 0 & nargin>=2 & isfield(s.par,'useUnderScoreInName')
    useUnderScoreInName=s.par.useUnderScoreInName;
else
    global useUnderScoreInName
    if isempty(useUnderScoreInName)
        useUnderScoreInName=0;
    end
end
if isnumeric(a);a=num2str(a);end
%a=regexprep(lower(a),'[^A-Za-z0-9]','');
if useUnderScoreInName
    a=regexprep(a,'[^A-Za-z0-9_]','');
else %Do not used '_'
    a=regexprep(a,'[^A-Za-z0-9]','');
end
if length(a)>0 & a(1)>='0' & a(1)<='9';a=['num' a];end
if length(a)>63 a=a(1:63); end
if length(a)>0 & a(1)=='_'
    a=a(2:end);
end
a2=['_' a];
