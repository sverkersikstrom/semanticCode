function [t, a]=testPar(iters)
t0=tic;
parfor idx=1:4 %iters
    excelServer
    %parTest(idx);
    %parTest(idx);
    %s;
    %pause(2)
end
toc(t0)

%p=parpool(2);%Start parpool
%gcp % Returns the current parallel pool
%j = batch('aScript') runs the script aScript.m on a worker according to the cluster defined in the default parallel profile.
%whos List current variables, long form. 

if 0
    c=parcluster;
    c.NumWorkers=64;
    ClusterInfo.setWallTime('00:15:00');
    ClusterInfo.setEmailAddress('sverker.sikstrom@psy.lu.se');
    %j=c.batch(@
end 

function parTest(j)
persistent a
t=now;
while abs(t-now)*24*3600<rand;end
for i=1:1000000*rand;
    a=rand;
end
fprintf('%d\n',j);



   