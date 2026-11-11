function pAdj=holmAdjust(p)
% Holm's step-down correction for multiple comparisons.
% Returns the adjusted p-values in the same order as p, capped at 1. A test is significant
% at level alpha when its adjusted p-value is at most alpha. NaN values are not counted
% as tests and stay NaN.
pAdj=nan(size(p));
ok=find(not(isnan(p)));
m=length(ok);
if m==0
    return
end
[ps,order]=sort(p(ok));
adj=min(1,cummax((m-(1:m)+1).*reshape(ps,1,[])));
pAdj(ok(order))=adj;
