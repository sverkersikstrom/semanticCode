function [h out]=plotSemanticDistance(s,words)
out=[];h=[];
if nargin<1
    file='/Users/sverkersikstrom/Dropbox/ngram/spaceenglish.mat';
    file='/Users/sverkersikstrom/Dropbox/ngram/spaceswedish2.mat';
    s=getSpace('',[],file);  %Get space named 'space_allmansum3'
end
if nargin<2
    words='woman girl love model volvo saab stockholm';
    words='mamma pappa ?gon stockholm';
    words='wine sweden france spain portugal';
end
[index t]=text2index(s,words);
indexOk=index(find(index>0));
t=t(find(index>0));
if length(indexOk)==0
    out.error='Error, no matching words\n';
    fprintf('%s\n',out.error);
    return
else
    %if isfield(s,'upper')
    %    N=length(s.upper);
    %else
    N=s.N;
    %end
    [sim index]=semanticSearch(s.x(indexOk(1),:),s.x(1:N,:));
    if length(indexOk)>1
        H=1;d=[];
        try;close(H);end
        h=figure(H);
        
        plotCircle;
        
        
        N=length(indexOk)-1;
        for i=1:length(indexOk)
            indexN(i)=find(indexOk(i)==index);
            l(i)=(indexN(i)-1)/length(index);
        end
        %l=l/max(l);
        scale=.4;
        lim=scale*max(l);
        set(gca,'Xlim',[-lim lim])
        set(gca,'Ylim',[-lim lim])
        
        for i=1:length(indexOk)
            
            if i==1
                c='r';size=20;
            else
                c='k';size=16;
            end
            x=scale*l(i)*sin(i/N*2*pi);
            y=scale*l(i)*cos(i/N*2*pi);
            h1=text(x,y,s.fwords{indexOk(i)},'fontsize',size,'color',c,'HorizontalAlignment','center');
            d=findEmptySpace(d,h1);
            line([x,h1.Position(1)],[y,h1.Position(2)],'linestyle','-','color','k','linewidth',3);
            if i>1
                h1=text(x/2,y/2,sprintf('%.3f',sim(indexN(i))),'fontsize',9,'color',c,'HorizontalAlignment','center');
            end
            line([0,x],[0,y],'linestyle','--','color','k');
        end
        axis off
    else
        try;close(2);end
        h=figure(2);
        %plotCircle
        Nplot=10;
        [tmp irand]=sort(rand(1,Nplot));
        for i=1:Nplot
            l=(i-1)/Nplot;
            if i==1
                c='r';size=20;
            else
                c='k';size=16;
            end
            x(i)=(1-sim(i))*sin(irand(i)/Nplot*2*pi);
            y(i)=(1-sim(i))*cos(irand(i)/Nplot*2*pi);
            text(x(i),y(i),s.fwords{index(i)},'color',c,'fontsize',size,'HorizontalAlignment','center');
            line([0,x(i)],[0,y(i)],'linestyle','--','color','k');
            
        end
        set(gca,'Xlim',[-1 1])
        set(gca,'Ylim',[-1 1])
        axis off
        
    end
end


function plotCircle
step=.1;
for i=0:step:2*pi
    line(.05*[sin(i) sin(i+step)],.05*[cos(i) cos(i+step)],'color',[.8 .8 .8],'linestyle','--');
end
