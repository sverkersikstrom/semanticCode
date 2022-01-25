function d=findEmptySpace(d,h);
cont=1;
H.Extent=get(h,'Extent');
x=0;
y=0;
z=0;
if not(isfield(d,'Extent'))
    d.Extent=[];
    d.h=[];
    d.xscale2=get(gca,'Xlim');d.xscale3=(d.xscale2(2)-d.xscale2(1));
    d.yscale2=get(gca,'Ylim');d.yscale3=(d.yscale2(2)-d.yscale2(1));
end
step0=min(d.yscale3/30,.01);
step=step0;
Nmax=0;
xscale=1;
yscale=.6;
if length(d.Extent)==0
    if not(isfield(d,'x')) d.x=0;end
    if not(isfield(d,'y')) d.y=0;end
    if not(isfield(d,'z')) d.z=0;end
    x=d.x;
    y=d.y;
    z=d.z;
elseif 1 %Fast & new
    cont=[];
    angle=0:.1:2*3.1415;
    N=length(angle);
    Extent1=repmat(d.Extent(:,1),1,N);
    N2=size(Extent1);
    Extent2=repmat(d.Extent(:,2),1,N);
    Extent13=repmat(d.Extent(:,1)+d.Extent(:,3),1,N);
    Extent4=repmat(d.Extent(:,4),1,N);
    x0=sin(angle);
    x0=repmat(x0,length(d.Extent(:,1)),1);
    y0=cos(angle);
    y0=repmat(y0,length(d.Extent(:,1)),1);
    while isempty(cont) & Nmax<150;%2000/31.415
        Nmax=Nmax+1;
        x=x0*step +d.x;
        y=y0*step +d.y;
        step=step*1.03+step0;
        cont2=not(x+xscale*(H.Extent(1)+H.Extent(3))<Extent1 | x+xscale*H.Extent(1)>(Extent13) | y+H.Extent(2)+yscale*H.Extent(4)<Extent2 | y+H.Extent(2)>(Extent2+yscale*Extent4));
        if N2(1)==1
            cont=(cont2)>0 ;
        else
            cont=sum(cont2)>0;
        end
        cont=find(not(cont));
    end
    if isempty(cont)
        fprintf('Could not find empty location\n');
        N=size(x);
        cont=fix(rand*N(2))+1;
    end
    x=x(1,cont(1));y=y(1,cont(1));z=d.z;
else %OLd and slow
    angle=0;
    while cont & length(d.Extent)>0
        Nmax=Nmax+1;
        if cont
            angle=angle+.1;
            x=sin(angle)*step;
            y=cos(angle)*step;
            if angle>2*pi;
                step=step*1.03+.01;
                %step=step*1.02+.004;
                angle=0;
            end
        end
        cont2=not(x+xscale*(H.Extent(1)+H.Extent(3))<d.Extent(:,1) | x+xscale*H.Extent(1)>(d.Extent(:,1)+d.Extent(:,3)) | y+H.Extent(2)+yscale*H.Extent(4)<d.Extent(:,2) | y+H.Extent(2)>(d.Extent(:,2)+yscale*d.Extent(:,4)));
        cont=sum(cont2)>0 & Nmax<20000;
    end
end
H.Position=get(h,'Position');
if isfield(d,'plotDrawCross') & d.plotDrawCross>0
    hold on
    Color=get(h,'Color');
    if d.plotDrawCross==2 %Draw lines 
        plot([d.x x+H.Position(1)], [d.y y+H.Position(2)],'Color',Color);
    end
    plot(d.x, d.y,'x','Color',Color,'linewidth',2);%Draw cross nearby words
end
set(h,'position',[x+H.Position(1) y+H.Position(2) z+H.Position(3)])
H2.Extent=get(h,'Extent'); 

d.Extent=[d.Extent ; H2.Extent ];
d.h=[d.h h];

