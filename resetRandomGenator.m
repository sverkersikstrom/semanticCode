function resetRandomGenator(s,seedByTime);
if nargin<2 seedByTime=0;end
if seedByTime %Seed random generator by time!
    tmp=clock;tmp=10000*(tmp(end)-fix(tmp(end)));
    try
        rng(tmp,'twister');
    catch
        fprintf('Error in in random error generator!\n');
        tmp=fix(10*(tmp(end)-fix(tmp(end))));
        rand(1,tmp+1);
    end
elseif s.par.resetRandomGenator
    %if not(s.par.excelServer)
        %fprintf('\nResetting random generator\n');
    %end
    rng('default');
end
