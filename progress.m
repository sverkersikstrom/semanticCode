function progress(s,func,step,i,N);
if nargin<4
    i=1;N=1;
end
persistent d;
if even(i,10) | i==1 
    p='';
    if isempty(d)
        d.func=func;
        d.step=step;
        d.i=i;
    end
    if not(strcmpi(d.func,func))
        d.func=func;
        d.i=i;
        p=[p char(13) func];
    end
    if not(strcmpi(d.step,step))
        d.step=step;
        d.i=i;
        p=[p step];
    end
    if length(p)>0
        %try
        f=fopen('progress.txt','w');
        fprintf(f,'%s',p);
        fclose(f);
        %end
    end
    if (i-d.i)/N>.1
        d.i=i;
        p=[p '.'];
    end
    fprintf('%s',p);
end
    
