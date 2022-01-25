function [hf s]=plotSpace(s,data,axis1,axis2,axis3,animate,axisSub1,axisSub2,axisSub3,property1,property2,property3)
%plotSpace(s,cellArrayOfindex,indexaxis1,indexaxis2,indexaxis3
%data; cell array of indexdes defining data to plot, e.g. {[1 5  10],[8 9]}
%axis1=one index defining the x-axais, e.g. 10 
%axis2,axis3 simliarit for the y and z axises
%axisSub1-3 and property1-3 are only used for a creating a semantictext on axis 1-3, and can be omitted in most cases!

if nargin<4
    axis2=[];
end
if nargin<5
    axis3=[];
end
if nargin<6
    animate=0;
end
if nargin<7
    axisSub1=[];
end
if nargin<8
    axisSub2=[];
end
if nargin<9
    axisSub3=[];
end
if nargin<10
    property1=[];
end
if nargin<11
    property2=[];
end
if nargin<12
    property3=[];
end

%Convert from old syntax!
warning off
for i=1:length(data)
    if not(isfield(data{i},'index'))
        data{i}.index=data{i};
        data{i}.input_clean=['dataset ' num2str(i)];
    end
end
if not(isfield(axis1,'index'))
    axis1.index=axis1;
    axis1.input_clean='x-axis';
end
if not(isfield(axis2,'index')) & not(isempty(axis2))
    axis2.index=axis2;
    axis2.input_clean='x-axis';
end
if not(isfield(axis3,'index')) & not(isempty(axis3))
    axis3.index=axis3;
    axis3.input_clean='x-axis';
end
warning on

if not(isempty(axis1))
    ver='d1';
else
    axis1.input='';
    axis1.input_clean='';
end

if not(isempty(axis2))
    ver='d2';
else
    axis2.input='';
    axis2.input_clean='';
end
if not(isempty(axis3))
    ver='d3';
else
    axis3.input='';
    axis3.input_clean='';
end

h1=[];

tMax=1;
if animate
    tMax=5;%Divides into tMax time periods
    timeProperty='_time';%Get time from timeProperty
    subjectProperty='_subject';%Match words across time 
else
    animate=0;
end

drawnow

col='rkgybcmrgbkymcrgbky';
marker='+x+xo*d.p<>s^h';
hf=newfigure(s);

hold on

for t=1:tMax
    title_=['Semantic plot of ' axis1.input_clean ' and ' axis2.input_clean];
    if strcmpi(ver,'d3')
        title_=['Semantic plot of ' axis1.input_clean ', ' axis2.input_clean ' and ' axis3.input_clean];
    end

    l=0;r='';
    for j=1:length(data)
        if not(isempty(axisSub1))
           [s1{t,j}, ~, s] =semanticDiffOneLeaveOut(s,axis1,axisSub1,data{j},property1);
        else
            [s1{t,j}, ~,s]=getProperty(s,axis1.index,data{j}.index);
        end
        
        if strcmpi(ver,'d1')
            s2{t,j}=[1:length(data{j}.index)]/length(data{j}.index);
        else
            if not(isempty(axisSub2))
                s2{t,j}=semanticDiffOneLeaveOut(s,axis2,axisSub2,data{j},property2);
            else 
                [s2{t,j}, ~,s]=getProperty(s,axis2.index(1),data{j}.index);
            end
        end
        if strcmpi(ver,'d3')
            if not(isempty(axisSub3))
                s3{t,j}=semanticDiffOneLeaveOut(s,axis3,axisSub3,data{j},property3);
            else
                [s3{t,j}, ~, s]=getProperty(s,axis3.index(1),data{j}.index);
            end
        else
            s3{t,j}=zeros(1,length(data{j}.index));
        end
        
        if animate
            [time, ~,s]=getProperty(s,timeProperty,data{j}.fwords);
            [subjects, ~, s]=getProperty(s,subjectProperty,data{j}.fwords);
            if isnan(nanmean(subjects))
                subjects=ones(1,length(subjects))*1;
            end
            usubjects=unique(subjects);
            [a crit]=hist(time,tMax);
            crit=[min(time) crit];
            iWrongTime=find(not(crit(t)<=time & crit(t+1)>time));
            s1{t,j}(iWrongTime)=NaN;%Remove wrong time periods
            s2{t,j}(iWrongTime)=NaN;%Remove wrong time periods
            s3{t,j}(iWrongTime)=NaN;%Remove wrong time periods
            tmp1=nan(1,length(usubjects));
            tmp2=nan(1,length(usubjects));
            tmp3=nan(1,length(usubjects));
            for i=1:length(usubjects)
                indexS=find(subjects==usubjects(i));
                tmp1(i)=nanmean(s1{t,j}(indexS));
                tmp2(i)=nanmean(s2{t,j}(indexS));
                tmp3(i)=nanmean(s3{t,j}(indexS));
            end
            s1{t,j}=tmp1;
            s2{t,j}=tmp2;
            s3{t,j}=tmp3;
        end

        if t==1 & s.par.plotEachDataPoint==1
            if strcmpi(ver,'d3')
                h{j}=plot3(s1{t,j},s2{t,j},s3{t,j},[col(j) marker(j)]);
                m3=mean(s3{t,j});view([1 1 1]);
            else
                h{j}=plot(s1{t,j},s2{t,j},[col(min(length(col),j)) marker(j)]);
                r=[' r=' num2str(corr(shiftdim(s1{t,j},1),shiftdim(s2{t,j},1))) ];
                m3=0;
            end
            m1=nanmean(s1{t,j});
            m2=nanmean(s2{t,j});
            if s.par.text_all2 | (s.par.print_some2 & ((s1{t,j}(i)-m1)^2+(s2{t,j}(i)-m2)^2+(s2{t,j}(i)-m3)^2)^.5>.25)
                for i=1:length(s1{t,j})
                    l=l+1;
                    h1(l)=text(s1{t,j}(i),s2{t,j}(i),s3{t,j}(i),regexprep(s.fwords{data{j}.index(i)},'_',' '));
                    set(h1(l),'fontsize',8);
                end
            end
        end
        drawnow
        dic3{j}=data{j}.input_clean;
    end
    if s.par.plot_mean
        if not(strcmpi(ver,'d3'))
            %for j=1:length(data)
                %plot(mean(s1{t,j}),mean(s2{t,j}),[col(j) marker(j)],'Markersize',12,'LineWidth',6);
            %end
            for j=1:length(data)
                
                stdm1=1.96*std(s1{t,j})/length(s1{t,j})^.5;
                stdm2=1.96*std(s2{t,j})/length(s2{t,j})^.5;
                stdm3=1.96*std(s3{t,j})/length(s3{t,j})^.5;
                m1=mean(s1{t,j});
                m2=mean(s2{t,j});
                m3=mean(s2{t,j});
                %plot(m1,m2,[col(j) marker(j)],'Markersize',12,'LineWidth',6);
                h=ezplot(['(x-' num2str(m1) ')^2/ ' num2str(stdm1) '^2 +(y-' num2str(m2) ')^2/' num2str(stdm2) '^2=1'],[-stdm1+m1 +stdm1+m1 -stdm2+m2 +stdm2+m2]);
                set(h, 'Color', col(j),'LineWidth',4); 
                %plot([m1-stdm1,m1+stdm1],[m2,m2],[col(j) ],'LineWidth',6);
                %plot([m1,m1],[m2-stdm2,m2+stdm2],[col(j) ],'LineWidth',6);
                1;
            end
            legend(dic3)
            drawnow

        end
    end
    if s.par.plotEachDataPoint==1 & 0
        maxV=NaN;
        minV=NaN;%-.5
        set(gca,'Xlim',[min([min(s1{t,j});minV]) max([max(s1{t,j});maxV])]);
        set(gca,'Ylim',[min([min(s2{t,j});minV]) max([max(s2{t,j});maxV])]);
        try
            set(gca,'Zlim',[min([min(s3{t,j});minV]) max([max(s3{t,j});maxV])]);
        end
    end
    
    legend(dic3)
    title(title_);
    drawnow

    xlabel(axis1.input_clean);
    ylabel(axis2.input_clean);
    zlabel(axis3.input_clean);

    fprintf('correlation first and second axel %.3f\n',corr(shiftdim(s1{t,j},1),shiftdim(s2{t,j},1)))
end
if strcmpi(ver,'d1'); ylabel(''); end
set(gcf,'Color',[1 1 1]);

if isfield(s.par,'plotSaveas')
    saveas(hf,s.par.plotSaveas,'fig')
    saveas(hf,s.par.plotSaveas,'jpg')
end

if strcmpi(ver,'d3'); 
    try
        for i=1:36
            camorbit(10,0,'camera')
            F(i)=getframe;
            drawnow
        end
        save('movie_last','F');
    catch
        fprintf('Error: Could not rotate 3d figure\n')
    end
    %movie2avi(F(1:length(F)),'movie_last','fps',5)
end
if tMax>1 %Animation of concept changes over spaces...
    h3=line([0 0],[0 0]);%Draw diagonal dotted black line
    for j=1:length(data)
        set(h{j},'EraseMode','xor');%,'MarkerSize',18)
    end
    cont=1;
    drawnow
    N=0;
    while cont
        tFrame=0;
        for t=1:tMax-1
            for i=0:10
                for j=1:length(data)
                    f=i/10;
                    title(['Semantic at time ' datestr(crit(t)+f*(crit(t+1)-crit(t)),'yyyy-mm-dd')]);
                    if strcmpi(ver,'d3')
                        set(h{j},'XData',(1-f)*s1{m,j}+f*s1{t+1,j},'YData',(1-f)*s2{t,j}+f*s2{t+1,j},'ZData',(1-f)*s3{t,j}+f*s3{t+1,j})
                    else
                        set(h{j},'XData',(1-f)*s1{t,j}+f*s1{t+1,j},'YData',(1-f)*s2{t,j}+f*s2{t+1,j})
                    end
                    if s.par.text_all2 | s.par.print_some2
                        [tmp index]=sort(((s1{t,j}-m1).^2+(s2{t,j}-m2).^2 +(s3{t,j}-m3).^2).^.5,'descend');
                        for i1=1:length(h1)
                            try
                                set(h1(j),'Position',[(1-f)*s1{t,j}(index(i1))+f*s1{t+1,j}(index(i1)) (1-f)*s2{t,j}(index(i1))+f*s2{t+1,j}(index(i1))  (1-f)*s3{t,j}(index(i1))+f*s3{t+1,j}(index(i1)) ])
                                set(h1(j),'String',otmp1.word{index(i1)});
                            end
                        end
                    end
                end
                %Draw time line..
                set(h3,'XData',[-.5 -.5+(f+t-1)/(tMax-1)*1.5],'YData',[0 0])
                drawnow expose update
                if N==0
                    tFrame=tFrame+1;
                    F(tFrame)=getframe;
                end
            end
        end
        N=N+1;
        cont=strcmpi( 'Animate', questdlg2('Repeat animatation','Animate','Animate','Cancel','Animate'));
    end
    if strcmpi('Save',questdlg2('Save','Save','Save','Cancel','Cancel'))
        filename=inputdlg3('Filename',['movie_']);
        save(filename,'F')
        movie2avi(F(1:length(F)),filename,'fps',5)
    end
end