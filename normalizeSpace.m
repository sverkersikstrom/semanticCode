function x=normalizeSpace(x)
N=size(x);
for i=1:N(1)
    x1=x(i,:);%-xmean;
    l=sum(x1.*x1)^.5;
    if l==0
        x(i,:)=x1*NaN;
    else
        x(i,:)=x1/l;
    end
end
end
