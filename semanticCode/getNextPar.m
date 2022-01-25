function par=getNextPar(par,move)
if nargin<1
    par=[];
end
if nargin<2
    move=1;
end
for i=1:100
    file=['par' num2str(i) '.m'];
    if exist(file)
        f=fopen(file)
        while(not(feof(f)))
            a=fgets(f);
            fprintf('file:%s commnad:%s\n',file,a)
            eval(a);
        end
        if move
            movefile(file,[regexprep(file,'.m','') '.done']);
        end
        return
    end
end