function highLightWords(h,word,newword)
%In the figure (h), change text in the struct 'word' to the text in 'newword'
%If the newword argument is missing, then make 'word' bold and titel it 20 degres

%if not(isempty(h))
%    figure(h)
%end
if nargin<3
    newword=[];
end
c=get(gca,'Children');
for i=1:length(c)
    try
        k=find(strcmpi(get(c(i),'String'),word));
        if not(isempty(k))
            if not(isempty(newword))
                set(c(i),'String',newword{k})
            else
                set(c(i),'fontweight','bold','fontangle','italic');
                line([c(i).Extent(1) c(i).Extent(1)+c(i).Extent(3)],c(i).Extent(4)*.2+[c(i).Extent(2) c(i).Extent(2)],'color','r')
            end
        end
    end
end
