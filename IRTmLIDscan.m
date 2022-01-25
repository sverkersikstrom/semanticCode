function [varargout]=IRTmLIDscan(Y,TH)
%Rough LID detection utility function
% [varargout]=IRTmLIDscan(Y,TH,bin,varargin) computes
% Mantel-Haenszel statistics based upon data Y an latent trait proxy TH
% These MH statistics are then hierarchically clustered and the results are
% shown in a colormatrix of the MH statistics and a dendrogram of the
% resulting clustering in which you can determine the item subsets.
% As for now a good automatic cluster determination is lacking.
% Hierarchical clustering makes use of the matlab statistics toolbox and
% algorithms therein
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%_________________________________________________________________________%
%
%IRTm Toolbox version0.0 2008 | code written by: Johan Braeken |
%Using this file implies that you agree with the license (see License.pdf)| 
%email: j.braeken@uvt.nl|j.braeken@flavus.org
%_________________________________________________________________________%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

[MHT Gbase]=IRTmMHT(Y,TH);

X=-MHT(:,3)'+50;
Z=linkage(X,'average');
figure();dendrogram(Z,0);
figure();viewmatrix(Gbase);
if nargout>=2;
    varargout{2}=MHT;
end
if nargout==1; varargout{1}=Gbase; end


function [STAT G_base]=IRTmMHT(Y,Th);
%%%%%%%%%%DIVIDE INTO K BINS;
Thnew=Th;
kk=unique(Th);
nkk=zeros(length(kk),1);
for i=1:length(kk);
    nkk(i)=length(find(Th==kk(i)));
end;
mukk=mean(nkk);
nk=[];j=1;i=1;z=1;
while i <= length(kk);

    nk(z)=nkk(i);
    j=i;
    while ((nk(z)<(mukk*6)) & ((j+1)<=length(kk)));
        nk(z)=nk(z)+nkk(j+1);
        index=find(Th==kk(j+1));
        Thnew(index)=kk(i);
        j=j+1;
    end;
    if j>i;
        i=j;
    end;
    i=i+1;
    z=z+1;
end;
k=unique(Thnew);
tot=factorial(size(Y,2))/(factorial(size(Y,2)-2)*factorial(2));
MHQ=zeros(tot,2);
ID=zeros(tot,2);
nr=1;
G_base=zeros(size(Y,2));
for i=1:size(Y,2);
    for j=i+1:size(Y,2);
        Xx=Y(:,[i,j]);
        m11=zeros(length(nk),1);
        n11=zeros(length(nk),1);
        V=zeros(length(nk),1);
        for h=1:length(nk);
            index=find(Thnew==k(h));
            X=Xx(index,:);
            D=X(:,1)*10+X(:,2);
            n11(h)=length(find(D==11));
            n00=length(find(D==0));
            n10=length(find(D==10));
            n01=length(find(D==1));
            n1plus=n11(h)+n10;
            nplus1=n11(h)+n01;
            n0plus=n00+n01;
            nplus0=n00+n10;
            m11(h)=((n1plus+0.5)*(nplus1+0.5))/(length(index)+0.5);
            V(h)=((n1plus+0.5)*(n0plus+0.5)*(nplus1+0.5)*(nplus0+0.5))/( ((length(index)+0.5)^2)*(length(index)-1+0.5) );
        end;
        MHQ(nr,1)=sum(n11+0.5-m11)/sqrt(sum(V));
        MHQ(nr,2)=normpdf(MHQ(nr,1),0,1);
        ID(nr,:)=[i j];
        G_base(i,j)=MHQ(nr,1);
        nr=nr+1;
    end;
end;
[base, index]=sortrows(MHQ,2);
alfa=0.05;
j=size(base,1);
while j>=1;
    if base(j,2)<= ((j/size(base,1))*0.05);
        alfa=base(j,2);
        break;
    end;
    j=j-1;
end;
signifBH=zeros(size(base,1),1);
signifBH(index(1:j),1)=1;
signifBF=MHQ(:,2)<=(0.05/size(base,1));
STAT=[ID MHQ signifBH signifBF];

function viewmatrix(x,c,alpha_value)
% VIEWMATRIX   Visualize 2d-matrices with colorful plots.
%     VIEWMATRIX(X) visualizes a NxM matrix by plotting each matrix entry
%     as a colored square. The entry value itself is also displayed. Since
%     the digits of the number are not plotted as regular text but as
%     bitmaps, the method scales the text for any matrix size.
%  Author : Mirza Faisal Baig
%  Version: 1.0
%  Date   : January 22, 2004
%  Available at MATLAB file exchange

% Numbers defined as matrices to be diaplayed as textures
bitmapdata = { ...
    [0 0 0 0 0 0 0 0 0 0;
    0 0 0 0 1 1 0 0 0 0;
    0 0 0 1 1 1 0 0 0 0;
    0 0 1 1 1 1 0 0 0 0;
    0 1 1 0 1 1 0 0 0 0;
    0 0 0 0 1 1 0 0 0 0;
    0 0 0 0 1 1 0 0 0 0;
    0 0 0 0 1 1 0 0 0 0;
    0 0 0 0 1 1 0 0 0 0;
    0 0 0 0 1 1 0 0 0 0;
    0 0 0 0 1 1 0 0 0 0;
    0 0 0 0 1 1 0 0 0 0;
    0 0 0 0 1 1 0 0 0 0;
    0 1 1 1 1 1 1 1 1 0;
    0 0 0 0 0 0 0 0 0 0],

    [0 0 0 0 0 0 0 0 0 0;
    0 0 0 1 1 1 1 0 0 0;
    0 0 1 1 0 0 1 1 0 0;
    0 1 1 0 0 0 0 1 1 0;
    0 1 1 0 0 0 0 1 1 0;
    0 0 0 0 0 0 0 1 1 0;
    0 0 0 0 0 0 0 1 1 0;
    0 0 0 0 0 0 1 1 0 0;
    0 0 0 0 1 1 1 0 0 0;
    0 0 0 1 1 0 0 0 0 0;
    0 0 1 1 0 0 0 0 0 0;
    0 1 1 0 0 0 0 0 0 0;
    0 1 1 0 0 0 0 0 0 0;
    0 1 1 1 1 1 1 1 1 0;
    0 0 0 0 0 0 0 0 0 0],

    [0 0 0 0 0 0 0 0 0 0;
    0 0 0 1 1 1 1 0 0 0;
    0 0 1 1 0 0 1 1 0 0;
    0 1 1 0 0 0 0 1 1 0;
    0 1 1 0 0 0 0 1 1 0;
    0 0 0 0 0 0 0 1 1 0;
    0 0 0 0 0 0 1 1 0 0;
    0 0 0 0 1 1 1 0 0 0;
    0 0 0 0 0 0 1 1 0 0;
    0 0 0 0 0 0 0 1 1 0;
    0 1 1 0 0 0 0 1 1 0;
    0 1 1 0 0 0 0 1 1 0;
    0 0 1 1 0 0 1 1 0 0;
    0 0 0 1 1 1 1 0 0 0;
    0 0 0 0 0 0 0 0 0 0],

    [0 0 0 0 0 0 0 0 0 0;
    0 0 0 0 0 0 0 1 0 0;
    0 0 0 0 0 0 1 1 0 0;
    0 0 0 0 0 1 1 1 0 0;
    0 0 0 0 1 1 1 1 0 0;
    0 0 0 1 1 0 1 1 0 0;
    0 0 1 1 0 0 1 1 0 0;
    0 1 1 0 0 0 1 1 0 0;
    0 1 1 0 0 0 1 1 0 0;
    0 1 1 1 1 1 1 1 1 0;
    0 0 0 0 0 0 1 1 0 0;
    0 0 0 0 0 0 1 1 0 0;
    0 0 0 0 0 0 1 1 0 0;
    0 0 0 0 0 0 1 1 0 0;
    0 0 0 0 0 0 0 0 0 0],

    [0 0 0 0 0 0 0 0 0 0;
    0 1 1 1 1 1 1 1 1 0;
    0 1 1 0 0 0 0 0 0 0;
    0 1 1 0 0 0 0 0 0 0;
    0 1 1 0 0 0 0 0 0 0;
    0 1 1 0 0 0 0 0 0 0;
    0 1 1 0 1 1 1 0 0 0;
    0 1 1 1 0 0 1 1 0 0;
    0 0 0 0 0 0 0 1 1 0;
    0 0 0 0 0 0 0 1 1 0;
    0 0 0 0 0 0 0 1 1 0;
    0 1 1 0 0 0 0 1 1 0;
    0 0 1 1 0 0 1 1 0 0;
    0 0 0 1 1 1 1 0 0 0;
    0 0 0 0 0 0 0 0 0 0],

    [0 0 0 0 0 0 0 0 0 0;
    0 0 0 1 1 1 1 0 0 0;
    0 0 1 1 0 0 1 1 0 0;
    0 1 1 0 0 0 0 1 0 0;
    0 1 1 0 0 0 0 0 0 0;
    0 1 1 0 0 0 0 0 0 0;
    0 1 1 0 1 1 1 0 0 0;
    0 1 1 1 0 0 1 1 0 0;
    0 1 1 0 0 0 0 1 1 0;
    0 1 1 0 0 0 0 1 1 0;
    0 1 1 0 0 0 0 1 1 0;
    0 1 1 0 0 0 0 1 1 0;
    0 0 1 1 0 0 1 1 0 0;
    0 0 0 1 1 1 1 0 0 0;
    0 0 0 0 0 0 0 0 0 0],

    [0 0 0 0 0 0 0 0 0 0;
    0 1 1 1 1 1 1 1 1 0;
    0 0 0 0 0 0 0 1 1 0;
    0 0 0 0 0 0 0 1 1 0;
    0 0 0 0 0 0 1 1 0 0;
    0 0 0 0 0 0 1 1 0 0;
    0 0 0 0 0 1 1 0 0 0;
    0 0 0 0 0 1 1 0 0 0;
    0 0 0 0 1 1 0 0 0 0;
    0 0 0 0 1 1 0 0 0 0;
    0 0 0 1 1 0 0 0 0 0;
    0 0 0 1 1 0 0 0 0 0;
    0 0 1 1 0 0 0 0 0 0;
    0 0 1 1 0 0 0 0 0 0;
    0 0 0 0 0 0 0 0 0 0],

    [0 0 0 0 0 0 0 0 0 0;
    0 0 0 1 1 1 1 0 0 0;
    0 0 1 1 0 0 1 1 0 0;
    0 1 1 0 0 0 0 1 1 0;
    0 1 1 0 0 0 0 1 1 0;
    0 1 1 0 0 0 0 1 1 0;
    0 0 1 1 0 0 1 1 0 0;
    0 0 0 1 1 1 1 0 0 0;
    0 0 1 1 0 0 1 1 0 0;
    0 1 1 0 0 0 0 1 1 0;
    0 1 1 0 0 0 0 1 1 0;
    0 1 1 0 0 0 0 1 1 0;
    0 0 1 1 0 0 1 1 0 0;
    0 0 0 1 1 1 1 0 0 0;
    0 0 0 0 0 0 0 0 0 0],

    [0 0 0 0 0 0 0 0 0 0;
    0 0 0 1 1 1 1 0 0 0;
    0 0 1 1 0 0 1 1 0 0;
    0 1 1 0 0 0 0 1 1 0;
    0 1 1 0 0 0 0 1 1 0;
    0 1 1 0 0 0 0 1 1 0;
    0 1 1 0 0 0 0 1 1 0;
    0 0 1 1 0 0 1 1 1 0;
    0 0 0 1 1 1 0 1 1 0;
    0 0 0 0 0 0 0 1 1 0;
    0 0 0 0 0 0 0 1 1 0;
    0 0 1 0 0 0 0 1 1 0;
    0 0 1 1 0 0 1 1 0 0;
    0 0 0 1 1 1 1 0 0 0;
    0 0 0 0 0 0 0 0 0 0],

    [0 0 0 0 0 0 0 0 0 0;
    0 0 0 0 1 1 0 0 0 0;
    0 0 0 1 1 1 1 0 0 0;
    0 0 1 1 0 0 1 1 0 0;
    0 0 1 1 0 0 1 1 0 0;
    0 1 1 0 0 0 0 1 1 0;
    0 1 1 0 0 0 0 1 1 0;
    0 1 1 0 0 0 0 1 1 0;
    0 1 1 0 0 0 0 1 1 0;
    0 1 1 0 0 0 0 1 1 0;
    0 0 1 1 0 0 1 1 0 0;
    0 0 1 1 0 0 1 1 0 0;
    0 0 0 1 1 1 1 0 0 0;
    0 0 0 0 1 1 0 0 0 0;
    0 0 0 0 0 0 0 0 0 0],

    [0 0 0 0 0 0 0 0 0 0;
    0 0 0 0 0 0 0 0 0 0;
    0 0 0 0 0 0 0 0 0 0;
    0 0 0 0 0 0 0 0 0 0;
    0 0 0 0 0 0 0 0 0 0;
    0 0 0 0 0 0 0 0 0 0;
    0 0 0 0 0 0 0 0 0 0;
    0 0 0 0 0 0 0 0 0 0;
    0 0 0 0 0 0 0 0 0 0;
    0 0 0 0 0 0 0 0 0 0;
    0 0 0 0 0 0 0 0 0 0;
    0 0 0 1 1 1 1 0 0 0;
    0 0 0 1 1 1 1 0 0 0;
    0 0 0 1 1 1 1 0 0 0;
    0 0 0 0 0 0 0 0 0 0],

    [0 0 0 0 0 0 0 0 0 0;
    0 0 0 0 0 0 0 0 0 0;
    0 0 0 0 0 0 0 0 0 0;
    0 0 0 0 0 0 0 0 0 0;
    0 0 0 0 0 0 0 0 0 0;
    0 0 0 0 0 0 0 0 0 0;
    0 0 0 0 0 0 0 0 0 0;
    0 1 1 1 1 1 1 1 1 0;
    0 0 0 0 0 0 0 0 0 0;
    0 0 0 0 0 0 0 0 0 0;
    0 0 0 0 0 0 0 0 0 0;
    0 0 0 0 0 0 0 0 0 0;
    0 0 0 0 0 0 0 0 0 0;
    0 0 0 0 0 0 0 0 0 0;
    0 0 0 0 0 0 0 0 0 0],

    [0 0 0 0 0 0 0 0 0 0;
    0 0 0 0 0 0 0 0 0 0;
    0 0 0 0 0 0 0 0 0 0;
    0 0 0 0 0 0 0 0 0 0;
    0 0 0 0 0 0 0 0 0 0;
    0 0 0 1 1 1 1 0 0 0;
    0 0 1 1 0 0 0 1 1 0;
    0 1 1 0 0 0 0 1 1 0;
    0 1 1 1 1 1 1 1 1 0;
    0 1 0 0 1 0 0 0 0 0;
    0 1 1 0 0 0 0 0 0 0;
    0 1 1 0 0 0 0 0 0 0;
    0 0 1 1 0 0 0 1 1 0;
    0 0 0 1 1 1 1 1 0 0;
    0 0 0 0 0 0 0 0 0 0],
    };
% Characters defined to identify the numbers
chars = {'1', '2', '3','4', '5', '6', '7','8', '9','0','.','-','e'};
% If color matrix is not defined use default color matrix
if nargin < 2
    c = [];
end
if isempty(c)
    c = x/max(x(:))*.9;
else
    c = c*.9;
end
alpha_value = 1;
clf;
[numrow,numcol] = size(x); % number of rows and columns of the matrix x
%total_elements = numrow*numcol;
con = 1; % counter to find the maximum size of the texture matrix
for row=1:numrow
    for col=1:numcol,
        %To convert each number to its corresponding texture matrix
        num_matrix = number2matrix(x(row,col),chars,bitmapdata);
        p{row,col} = num_matrix;
        [rowdata,coldata] = size(num_matrix);     % number of rows and columns of the texture matrix
        max_dim_temp(con) = max(rowdata,coldata); % save the maximum
        con = con+1;                              % increment counter con
    end % end of "for col"
end % end of "for row"
max_dim = max(max_dim_temp); % pick the maximum size from all the texture matrices
for i = 1:numrow
    for k = 1:numcol
        % Assign the texture matrix to variable data starting from last row and first column
        data = p{numrow+1-i,k};
        [rowdata,coldata] = size(data);
        factorY = rowdata/max_dim;   % scaling factor according to the dimenions of the texture matrix
        factorX = coldata/max_dim;   % scaling factor according to the dimenions of the texture matrix
        x_init_back = [k-1,k];       % column index for background box
        y_init_back = [i-1,i];       % row index for background box
        a1 = x_init_back(1)+0.5-factorX/2;    % x-coor of bottom left corner of the texture
        a2 = x_init_back(1)+0.5+factorX/2;    % x-coor of bottom right corner of the texture
        b1 = y_init_back(1)+0.5-factorY/2;    % y-coor of bottom right corner of the texture
        b2 = y_init_back(1)+0.5+factorY/2;    % y-coor of upper right corner of the texture
        z_init = zeros(length(x_init_back),length(y_init_back)); % zeros matrix to plot surface
        % To plot the background color boxes
        back_ground = surface(x_init_back,y_init_back,z_init,c(numrow+1-i,k));
        % To plot the foreground box for the texture
        for_ground = surface([a1 a2],[b1 b2],z_init);
        set(back_ground,'FaceAlpha',alpha_value)  % to make background transparent
        % To set the texture to the foreground box
        set(for_ground,'Cdata',flipud(data),'AlphaData',flipud(data),'FaceColor','Texture',...
            'FaceAlpha','Texture','LineStyle','None')
    end
end
a = colormap;       % current figure colormap
a(end,:) = [0 0 0]; % to change the last color value to back
colormap(a)         % change the colormap
axis equal          % make axis of the plot equal
box on              % make border line of the plot visible
axis off            % make the axis numbers and lines invisible
return % end of the main function
%-----------------------------------------------------------
% Function to convert number (real of intergers) into their corresponding
% texture matrices
function res = number2matrix(n, chars, bitmapdata)
n = num2str(n);                % change number to the string
res = [];                      % initialize res variable
for i = 1:length(n)
    for k = 1:length(chars)
        if n(i) == chars{k}
            m = bitmapdata{k}; % assign texture to the variable
            break;             % if number found stop
        end % end "if n(i)"
    end % end "for k"
    res = [res m];             % concatenate the result
end % end "for i"