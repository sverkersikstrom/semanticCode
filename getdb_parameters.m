function p=getdb_parameters(useCash)
if nargin<1 useCash=1;end
if not(isstruct(useCash)) & useCash
    persistent psave;
    if isfield(psave,'field') p=psave;return; end
end
p.field='archive_latin1';
p.context=15;%context words for extracting contexts
p.ttrain=15;%number of training days (15)
p.ttest=15;%number of testing days
p.ntest=10;%number of articles used at test
p.port='8889';%3306

%p.conn_p = database('stock','root','root','com.mysql.jdbc.Driver',['jdbc:mysql://localhost:' p.port '/stock']);
dbase='TheWebbotArchives';
tmp=getdb_parametersNew;p.conn_a=tmp.conn_a;
%p.conn_a = database(dbase,'root','root','com.mysql.jdbc.Driver',['jdbc:mysql://localhost:' p.port '/' dbase]);
%if length(p.conn_a.Message)==0
%else
%    fprintf('Error in communication with datbase: %s\n',p.conn_a.Message);
%end

%p.conn_s = database('space2','root','root','com.mysql.jdbc.Driver',['jdbc:mysql://localhost:' p.port '/space2']);
p.update=0;

p.weight=[ones(1,10)];%[6 5 4 3 2 1];
p.prefix='_pred';%'_pred_21_' fungerar bra
p.normalize=1;

p.testtype=1;

p.ttrain1=datenum('2001-01-01','yyyy-mm-dd');
p.ttrain2=datenum('2004-01-01','yyyy-mm-dd');
p.ttest1=p.ttrain2+p.ttrain;%datenum('2002-02-01','yyyy-mm-dd');
p.ttest2=datenum('2008-01-01','yyyy-mm-dd')-p.ttest;
p.exactmatch=1;
p.optimize_dim=0;
p.trainall=0;
p.trainpower=0;
p.alfa=.5;
p.comment='standard';
p.random=0;
p.random_train=0;
%stocks='sm?bolag facket fackf?reningar arbetsgivare direkt?r l?ntagare avtalsr?relse n?ringslivet sm?f?retag storf?retag';
p.stocks={'facket','fackf?reningar', 'arbetsgivare','direkt?r','l?ntagare','avtalsr?relse','n?ringslivet','sm?f?retag', 'storf?retag'};
%p.stock_text='nordea ericsson volvo boliden electrolux astrazeneca autoliv axfood castellum eniro fabege getinge hexagon holmen hufvudstaden investor jm kinnevik latour meda ncc biocare omx peab ratos saab sandvik sas scania seb seco securitas skf ssab enso swedbank teliasonera tietoenator vostok';
p.stock_text='ericsson volvo seb sas nordea omx investor scania saab electrolux swedbank securitas boliden sandvik teliasonera astrazeneca enso skf peab ssab autoliv vostok axfood holmen eniro jm kinnevik getinge ratos hexagon meda tietoenator ncc biocare fabege latour hufvudstaden castellum seco';
%'husqvarna','kaupthing','carnegie','lawson','millicom','nobia','lundbergfo
%retagen','lundin','oriflame','handelsbanken','tele2','sca','abb',
%p.stocks={'nordea','ericsson','volvo','boliden','electrolux','astrazeneca','autoliv','axfood','castellum','eniro','fabege','getinge','hexagon','holmen','hufvudstaden','investor','jm','kinnevik','latour','meda','ncc','biocare','omx','peab','ratos','saab','sandvik','sas','scania','seb','seco','securitas','skf','ssab','enso','swedbank','teliasonera','tietoenator','vostok'};
%p.stocks={'astrazeneca','autoliv','axfood','boliden','carnegie','castellum','electrolux','eniro','ericsson','fabege','getinge','hexagon','holmen','hufvudstaden','husqvarna','investor','kaupthing','kinnevik','latour','lawson','lundbergs','lundin','meda','millicom','ncc','biocare','nobia','nordea','omx','oriflame','peab','ratos','saab','sandvik','sas','sca','scania','seb','seco','securitas','handelsbanken','skf','ssab','enso','swedbank','tele2','teliasonera','tietoenator','volvo','vostok','jm'};
p.stocks=string2cell(p.stock_text);
psave=p;

