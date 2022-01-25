function [s,N,identifier] =addNorm(s,identifier,normText,comment,normSubtractionText,public)
if nargin<4
    comment='';
end
if nargin<5
    normSubtractionText='';
end
if nargin<6
    public=0;
end
x=text2space(s,normText);
info.comment=[comment char(13) 'Norm words:' normText ];
if length(normSubtractionText)>0
    info.comment=[info.comment  char(13) 'Subtraction words:' normSubtractionText ];
    xSub=text2space(s,normSubtractionText);
    x=x-xSub;
    x=x/sum(x.^2)^.5;
end
info.specialword=13;
info.context=normText;
[s N identifier]=addX2space(s,identifier,x,info);
if public & not(s.par.db2space)
    s.info{N}.persistent=1;
    saveSpace(s,s.filename,1);
end
