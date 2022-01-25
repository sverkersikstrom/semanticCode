function [r p res resText]=nancorr2(a,b,N);
if nargin>2
    [tmp index]=sort(N);
    resText=[];
    for m=1:5
        index2=index(fix(length(index)*(m-1)/5+1):fix(length(index)*m/5));
        [r(m) p(m)]=nancorr(a(index2),b(index2));
        N2(m)=mean(N(index2));
        resText=[resText 'r=' num2str(r(m)) ' p=' num2str(p(m)) ' N(words)='  num2str(N2(m)) char(9) ];
    end
    res=num2str(r);    
    return
end
[r p]=nancorr(a,b);

