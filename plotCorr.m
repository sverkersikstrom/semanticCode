function plotCorr(rVall,label,dataCultureLabels,file)
%Plot multiple correlations and save to to file
try;close(1);end
figure(1)
colormap('hot')
[U,S,V] = svd(rVall);%U2=U;U2(:,size(U2,2):size(U2,2))=0;X = U2*S*V';
[~,xindex]=sort(U(:,1));
[U,S,V] = svd(rVall');
[~,yindex]=sort(U(:,1));
imagesc(rVall(xindex,yindex))
set(gca,'Xtick',1:length(label))
set(gca,'XtickLabel',regexprep(label(yindex),'_',''))
for i=1:length(dataCultureLabels);dataCultureLabelsShort{i}=dataCultureLabels{i}(1:min(10,length(dataCultureLabels{i})));end
set(gca,'Ytick',1:length(dataCultureLabelsShort))
set(gca,'YtickLabel',dataCultureLabelsShort(xindex))
title(regexprep(file,'_',''));
colorbar;
set(gca,'XTickLabelRotation',90)
if nargin>=3
    saveas(1,file,'png');
end