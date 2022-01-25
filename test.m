function test

try
    asdfasd
catch err
    1;
end
    
1/0
asdfadf

d.Ncol=10000;
s.N=120000;
tic;
c.count=sparse(s.N,d.Ncol*250);
i=0;
while 1
    i=i+1;
    j1=fix(s.N*rand)+1;
    j2=fix(d.Ncol*250*rand)+1;
    if even(i,5000)
        toc
        tic;
        fprintf('%d \n',i);%datestr(now));
        print_mem;
    end
    c.count(j1,j2)=c.count(j1,j2)+1;
end
