function p=word2phonology(text)
if ischar(text) 
   text=string2cell(text)';
   p=word2phonology(text);
   return
end
p='';
for i=1:length(text)
    p=[p  word2phonology2(text{i})];
end

function p=word2phonology2(text)
text=['_' text '_'];
p='';
for i=1:length(text)
    for j=1:length(text)-i+1
        p=[p ' ' text(j:j+i-1)];
    end
end

        