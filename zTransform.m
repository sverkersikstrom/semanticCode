function x=zTransform(x)
x=(x-nanmean(x))/nanstd(x);