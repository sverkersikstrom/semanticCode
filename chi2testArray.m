function [p2 q2 qReversed]=chi2testArray(f1,f2)
if length(f1)<2 
    p2=NaN;q2=NaN;
    return
end

sum1=nansum(f1);
sum2=nansum(f2);
y(:,1,1)=f1;
y(:,2,1)=f2;
y(:,1,2)=sum1-f1;
y(:,2,2)=sum2-f2;
N=nansum([sum1 sum2]);
nidot2=sum(y,3);
ndotj2=sum(y,2);
pdotj2 = squeeze(ndotj2./N);

q2=nan(1,length(f1));

%if 1
clear NP2;
NP2(1,1,:)=nidot2(:,1).*pdotj2(:,1);
NP2(1,2,:)=nidot2(:,1).*pdotj2(:,2);
NP2(2,1,:)=nidot2(:,2).*pdotj2(:,1);
NP2(2,2,:)=nidot2(:,2).*pdotj2(:,2);
y=shiftdim(y,1);
tmp=(y-NP2).^2;
q2=sum(sum((tmp(:,:,:))./NP2(:,:,:)));
q2=squeeze(q2)';

% else
%     for i=1:length(f1)
%         NP2=nidot2(i,:)'*pdotj2(i,:);
%         q2(i)=sum(sum(((shiftdim(y(i,:,:),1)-NP2).^2)./NP2));
%     end
% end
%q2(i)=sum(sum(((squeeze(y(i,:,:))-NP2).^2)./NP2));

df=1;

%if 1
p2=1-chi2cdf(q2,df);

if nargout>=3
    reverse=f1/sum(f1)<f2/sum(f2);
    qReversed=q2;
    qReversed(reverse)=-qReversed(reverse);
    qReversed(isnan(qReversed))=0;
end
% elseif df==1 %& q>.1
%     persistent qsave;
%     m=25;
%     maxN=1500;
%     if isempty(qsave)
%         qsave=nan(1,maxN+2);
%         for i=0:maxN+1
%             qsave(i+1)=chi2cdf(i/m,df);
%         end
%         qsave(length(qsave))=1;
%     end
%     i=fix(q2*m);
%     w=q2*m-i;
%     i=min(maxN,i);
%     p2=1-(w.*qsave(i+2)+(1-w).*qsave(i+1));
% else
%     for i=1:length(f1)
%         p2(i)=1-chi2cdf(q(i),df);
%     end
% end

% if 0
%     %f1=f1(1:10);
%     %f2=f2(1:10)
%     i=1;
%     for i=1:length(f1)
%         Y(1,1)=f1(i);Y(2,1)=f2(i);Y(1,2)=sum1-f1(i);Y(2,2)=sum2-f2(i);
%         [p(i) q(i)]=chi2test(Y);
%     end
%
%     % Compute total number of trials
%     N=sum(sum(Y));
%
%     % Compute the totals for Attribute A (Gender)
%     nidot=sum(Y,2);
%
%     % Compute the totals for Attribute B (College)
%     ndotj=sum(Y);
%
%     % Compute the relative frequencies (probability estimates)
%     % for Attribute B
%     pdotj = ndotj/N;
%
%     % Compute the expected frequencies  (an outer product)
%     NP=nidot*pdotj;
%
%     % Compute the relative frequencies (probability estimates)
%     % for Attribute A
%     pidot = nidot/N;
%
%     % Compute the chi-square statistic for the test of
%     % independence of attributes
%     q=sum(sum(((Y-NP).^2)./NP));
%
%     [n1 n2]=size(Y);
%     df=(n1-1)*(n2-1);
%     p=1-chi2cdf(q,df);
%end
