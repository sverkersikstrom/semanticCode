function c=covariance(c,remove)
%Remove covariance of factor remove in covariance matrix (c)
N=size(c,1);
for i=remove
    Ni=1:N;
    c(Ni,Ni)=c(Ni,Ni)-c(Ni,i)*c(Ni,i)'/c(i,i);
end

