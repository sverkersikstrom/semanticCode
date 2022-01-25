function d=getSetProperty(s,index,data);
for i=1:length(index)
    try; 
        eval(['d(i)=s.info{index(i)}.' data ';']); 
    catch
        d(i)=NaN; 
    end
end
