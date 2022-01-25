function plotDifference(s,ow,ow1,ow2,propertyX,ow3,ow4,propertyY,normalDist,addLabels);
if nargin<4
    propertyX='';
end
if nargin<5
    ow3=[];
end
if nargin<6
    ow3=[];
end
if nargin<7
    propertyY='';
end
if nargin<8
    normalDist=0;
end
if nargin<9
    addLabels=0;
end

for i=1:length(ow)
    [x{i} rx{i} xdiff s]=semanticDiffOneLeaveOut(s,ow1,ow2,ow{i},propertyX);
end
col='rbgymcwkmcrgbwkymcrgbwky';
marker='+xosd^.<>ph';

if not(isempty(ow3))
    
    figure;hold on

    for i=1:length(ow)
        [y{i} temp{i} ydiff s]=semanticDiffOneLeaveOut(s,ow3,ow4,ow{i},propertyY);
        %y{i}=y_1{i}-y_2{i};
        
        plot(x{i},y{i},[marker(i) col(i)])%Plot words
        
        co(i)=nancorr(shiftdim(x{i},1),shiftdim(y{i},1));
        fprintf('label %s, r=%.3f mean(x)=%.3f mean(y)=%.3f std(x)=%.3f std(y)=%.3f\n', ow{i}.input_clean,co(i),nanmean(x{i}),nanmean(y{i}),nanstd(x{i}),nanstd(y{i}))

        leg{i}=ow{i}.input_clean;
    end
    fprintf('Semantic distances between axis= %.3f\n',sum(xdiff.*ydiff));
    legend(leg);
    
    for i=1:length(ow)
        plot(nanmean(x{i}),nanmean(y{i}),[marker(i) col(i)],'LineWidth',5,'MarkerSize',20)%Plots centroid 1
    end
    ylabel(['distance to (' ow3.input_clean ' minus ' ow4.input_clean ')']);
else 
    figure;hold on
    [a b]=hist(x_1{1},11);
    for i=1:length(ow)
        plot(x{i},rx{i},[marker(i) col(i)])%Plot words
    end    
    legend({ow1.input_clean,ow2.input_clean})
    for i=1:length(ow)
        plot(mean(x{i}),mean(rx{i}),[marker(i) col(i)],'LineWidth',15)%Plots centroid
    end    
    ylabel('distance to all conditions prototype');
end

set(gcf,'Color',[1 1 1]);
xlabel(['distance to (' ow1.input_clean ' minus ' ow2.input_clean ')']);

if  normalDist
    for i=1:length(ow)
        [a b]=hist(x_1{i},11);
        tmp=normpdf(b,mean(x{i}),std(x{i}));
        plot(b,max(rx{i})*tmp/sum(tmp)+1,col(i))%Plots normal distribution
    end
end

if addLabels
    for i=1:length(ow)
        text(x{i},y{i},ow{i}.word_clean)
    end
end
