function [indexOk,m]= getMedianSplit(r)
index1=r<nanmedian(r);
index2=r<=nanmedian(r);
if abs(nanmean(index1)-.5)<abs(nanmean(index2)-.5)
    indexOk=index1;
else
    indexOk=index2;
end
m=nanmedian(r);
