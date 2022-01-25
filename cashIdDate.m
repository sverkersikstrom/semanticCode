function date=cashIdDate(id,date);
persistent d 
if isempty(d)
    d= java.util.HashMap;
end
if nargin>1 %Put
  d.put(id,date);
else
    date=d.get(id);
end
if d.size>10000
    fprintf('\nClearing id-date map\n');
    clear d;
end    
