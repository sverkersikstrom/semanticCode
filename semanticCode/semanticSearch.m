function [similiarty index]=semanticSearch(xspace,xsearch)
d=xsearch*xspace';
indexNaN=find(isnan(d));
d(indexNaN)=-1e10;
[similiarty index]=sort(d,'descend');
similiarty(index(indexNaN))=NaN;