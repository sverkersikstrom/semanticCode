function d=printAssociates(s,index1,index2,scale)
type='';
bonferroni=0;

[x1 f1]=index2x(s,index1);
[x2 f2]=index2x(s,index2);
[p1 q qRev]=chi2testArray(f1,f2);

d.WordH=mkList(s,p1,f1+f2,+qRev,bonferroni,'descend');

d.WordL=mkList(s,p1,f1+f2,-qRev,bonferroni,'descend');
if nargin>=4
    m=nansum(scale.*(f1+f2))/sum(f1+f2);
    
    qRoot=qRev.^.5;
    qRoot(find(qRev<0))=0;
    d.WordHighPositive=mkList(s,p1,f1+f2,+qRoot.*max(0,  scale-m) ,bonferroni,'descend');
    d.WordHighNegative=mkList(s,p1,f1+f2, qRoot.*max(0,-(scale-m)),bonferroni,'descend');
    
    qRoot=qRev.^.5;
    qRoot(find(qRev>0))=0;
    d.WordLowPositive=mkList(s,p1,f1+f2,+qRoot.*max(0,  scale-m) ,bonferroni,'descend');
    d.WordLowhNegative=mkList(s,p1,f1+f2, qRoot.*max(0,-(scale-m)),bonferroni,'descend');

end

% if bonferroni
%     pCorrection=length(find((f1+f2)>0 & qRev<0));
% else
%     [~,pCorrection]=sort(f1+f2,'descend');
% end
% 
% [~,indexL]=sort(qRev,'ascend');
% indexL=indexL(1:length(find(p1<.05./pCorrection)));
% d.wordL='';
% for k=1:min(10,length(indexL));d.wordL=[d.wordL sprintf('%s ',s.fwords{indexL(k)})];end;


function list=mkList(s,p1,f12,qRev,bonferroni,order)
if bonferroni
    pCorrection=length(find((f12)>0 & qRev>0));
else
    [~,pCorrection]=sort(f12,'descend');
end
[~,indexH]=sort(qRev,order);
indexH=indexH(1:length(find(p1<.05./pCorrection)));
d.wordH='';
for k=1:min(10,length(indexH));d.wordH=[d.wordH sprintf('%s ',s.fwords{indexH(k)})];end;
list=d.wordH;


