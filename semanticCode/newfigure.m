function [h col]=newfigure(s)
persistent hsave;
persistent colnr;
h=hsave;
col='rbgy';
if s.par.time_new_graf
    try 
        figure(h);colnr=colnr+1; 
    catch; 
        h=figure;    colnr=1;
    end
else
    colnr=1;
    h=figure;
end
if colnr>length(col); colnr=1;end
col=col(colnr);
hsave=h;

