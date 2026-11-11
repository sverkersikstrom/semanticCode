function d=config;
%decalare globals
d.matlab_error_log='/usr/share/nginx/html/semanticexcel/public/mat_error.txt';
d.download_plot_dir='/usr/share/nginx/html/semanticexcel/public/downloaded_plots/';
d.words_plot_dir='/usr/share/nginx/html/semanticexcel/public/3words_plots/';
d.download_plot_url='http://www.semanticexcel.com/downloaded_plots/';
d.words_plot_url='http://www.semanticexcel.com/3words_plots/';
d.spaceCache='spaceCache/';
%if findstr(pwd,'sverker')>0
%else
%    d.spaceCache='';
%end
