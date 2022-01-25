function d=config;
%decalare globals
d.matlab_error_log='/usr/.../public/mat_error.txt';
d.download_plot_dir='/usr/.../public/downloaded_plots/';
d.words_plot_dir='/usr/.../public/3words_plots/';
d.download_plot_url='http://www.semanticexcel.com/downloaded_plots/';
d.words_plot_url='http://www.semanticexcel.com/3words_plots/';
d.spaceCache='spaceCache/';
%if findstr(pwd,'DB_USERNAME')>0
%else
%    d.spaceCache='';
%end
