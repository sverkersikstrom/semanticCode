function s=fixStringLength(s,N)
if nargin<2
    N=20;
end
s=[s ones(1,max(0,N-length(s)))*32];