function plotCircle(x0,y0,xsize,ysize,linewidth,col)
if nargin<3
    xsize=.15;
end
if nargin<4
    ysize=xsize;
end
if nargin<5
    linewidth=2;
end
if nargin<6
    col='r';
end
x=0:.2:2*pi+.2;hold on
plot(xsize*sin(x)+x0,ysize*cos(x)+y0,col,'linewidth',linewidth);
