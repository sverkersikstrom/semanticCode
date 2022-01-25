function r=averageOverSubject(data,id)
r=[];
for i=unique(id)
    r=[r nanmean(data(i==id))];
end
