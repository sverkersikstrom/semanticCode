function num=javaLinkedList2double(selectioncell)
num= {};
for j=1:selectioncell.size,
    num{j}=selectioncell.get(j-1);
end
num=str2double(num);

