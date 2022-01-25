function pUser
load('default')
for i=1:length(d.user)
    fprintf('%d\t%s\n',d.N(i),d.user{i})
end
