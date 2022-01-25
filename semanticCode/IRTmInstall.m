function IRTmInstall();
%IRTm toolbox installer version 0.0;
% Sets path, compiles mex files, ...
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%_________________________________________________________________________%
%
%IRTm Toolbox version0.0 2008 | code written by: Johan Braeken |
%Using this file implies that you agree with the license (see License.pdf)| 
%email: j.braeken@uvt.nl|j.braeken@flavus.org
%_________________________________________________________________________%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

versienr='version0.0';
lic=['license',versienr,'.txt'];

if ~exist(lic,'file')
    txt = [{''};
        {'AGREEMENT'};
        {''};
        {'This Software was developed by the Research Group of Quantitative Psychology and Individual Differences and is owned by the Katholieke Universiteit Leuven, for the purpose of this Agreement represented by the Research Group of Quantitative Psychology and Individual Differences and hereinafter referred to as KULEUVEN. By downloading and or installing the Software and associated files on your computing system you agree to use the Software under the terms and condition as specified in this Agreement.'};
        {''};
        {'Article 1 - Definitions'};
        {'1.1 "Software" shall mean KULEUVENs software described in Annex A including the source code.'};
        {'1.2 "Additions" shall mean lines of code, which are added to the Software and which optimize an existing functionality of the Software.'};
        {'1.3 "Module" shall mean lines of code, which add a new functionality to the Software regardless of the fact that this new function is operative without the Software.'};
        {'1.4 "Effective Date" shall mean the date on which you download or install the Software and associated files on your system.'};
        {''};
        {'Article 2 - License'};
        {'2.1 You shall have a non-exclusive, non-transferrable license to the Software supplied by KULEUVEN for Academic Purposes. All other uses are prohibited, except to the extent provided in any separate agreement. You acknowledge and agree that you may not use the Software for commercial purpose without first obtaining a commercial license from K.U.LEUVEN.'};
        {'2.2 For the purposes of this Agreement "use for commercial purposes" shall include the use or transfer of the Software for a consideration as well as the use of the Software to support commercial activities.'};
        {'2.3 Any use of Software for commercial purposes without first obtaining a license from KULEUVEN shall be deemed a breach of this Agreement for which KULEUVEN shall be entitled to whatever remedies it may have under law or equity, including recovery of consequential damages.'};
        {'2.4 You shall not sublicense any of your rights to the Software. Neither will you transfer the Software to a third party, unless prior written agreement of KULEUVEN has been obtained. '};
        {'2.5 KULEUVEN retains the right to the Software. Nothing in this Agreement shall preclude KULEUVEN from entering into agreements with third parties concerning the Software.'};
        {''};
        {'Article 3 - Ownership'};
        {'3.1 The Software is copyrighted and KULEUVEN retains all title and ownership to the Software.'};
        {'3.2 In case you introduce an Addition to the Software, the KULEUVEN will be informed immediately of the existence and nature of such Addition. Additions will become the property of KULEUVEN.'};
        {'3.3 Any Modules you create shall remain your property. Nevertheless, you will inform KULEUVEN on the existence and nature of any Module created under this Agreement. Moreover, you will, upon request of KULEUVEN, make available the Modules to KULEUVEN for use for Academic Purposes.'};
        {''};
        {'Article 4 - Confidentiality/Publication'};
        {'4.1 Each of the Parties agrees to keep strictly confidential any information, technical as well as commercial, obtained from another Party under this Agreement and not to communicate such information to third parties.  This obligation of confidentiality is not applicable to information:'};
        {' of which the receiving party was already in the possession at the time the information was acquired from the disclosing party;'};
        {' which was, at the time the information was acquired by the receiving party, already common knowledge;'};
        {' which became common knowledge after it was received from the disclosing party and without any fault of the receiving party;'};
        {' which the receiving party acquired from a third party who was in good faith and in possession of the information and allowed to disseminate the information without confidentiality obligations;'};
        {' of which the receiving party can prove that the information was developed by the receiving party independently from the knowledge and skills or experiences received from the disclosing party.'};
        {'4.2 The Parties have at all times the right to publish articles regarding the Software and regarding output as obtained from the Software, provided that the above obligation of confidentiality is respected. In all such articles, however, an explicit reference citation to all papers as listed in Annex A has to be included.'};
        {''};
        {'Article 5 - Financial Arrangements'};
        {'5.1 The Software will be provided at no cost.'};
        {''};
        {'Article 6 - Third party rights'};
        {'6.1 You will indemnify and hold harmless KULEUVEN against any damages, costs (including attorneys’ fees and costs) or other liability arising from claims that your use of the Software as provided under this Agreement, infringe any patent, copyright, trade secret, or intellectual property right of any third party. However, in no event you will have the obligation to indemnify and hold harmless KULEUVEN against any damages, costs or other liability arising from claims solely based on agreements between KULEUVEN and third parties.'};
        {''};
        {'Article 7 - Warranty'};
        {'7.1 The Software is provided "as is" by KULEUVEN without warranty of any kind, whether express or implied.  KULEUVEN specifically disclaims the implied warranties of merchantability and fitness for a particular purpose.'};
        {'7.2 KULEUVEN shall not be responsible for any loss, direct or indirect damage or other liability incurred by you or any third party in connection with the Software licensed by KULEUVEN under this Agreement. Under no circumstances shall KULEUVEN be liable for any direct, indirect, special, incidental, or consequential damages arising out of any performance of this Agreement, whether such damages are based on contract, tort or any other legal theory. You shall defend, indemnify and hold harmless KULEUVEN from all losses, damages, expenses, costs and other liabilities in connection with your use or disclosure of the Software.'};
        {''};
        {'Article 8 - Term'};
        {'8.1 This Agreement is effective from the Effective Date until you delete the Software and any and all related files from your computing system.'};
        {'8.2 In case of termination the provisions of Article 3, 4, and 7 shall remain in full force and effect.'};
        {''};
        {'Article 9 - Miscellaneous'};
        {'9.1 Any notice authorised or required to be given to KULEUVEN under this Agreement shall be in writing and shall be deemed to be duly given if left at or sent by registered post or facsimile transmission addressed to:'};
        {' Research Group of Quantitative Psychology and Individual Differences'};
        {'Address: Tiensestraat 102'};
        {'B-3000 Leuven'};
        {'Belgium'};
        {'Fax: 016 32 59 93'};
        {'Attention: Head of the Research Group'};
        {'9.2 You shall not assign this Agreement wholly or partially to any third party without the prior written consent of the other two parties.'};
        {'9.3 Any modifications or supplements to this Agreement shall be in writing and duly signed by the Parties hereto to become legally binding.'};
        {'9.4 The terms and conditions herein contained constitute the entire agreement between the Parties and supersede all previous agreements and understandings, whether oral or written, between the parties hereto with respect to the subject matter hereof.'};
        {''};
        {'Article 10 - Conflicts'};
        {'10.1 In the event of conflicts in the interpretation and/or performance of this Agreement, the parties shall first undertake to settle their differences amicably. If no amicable settlement can be reached concerning the execution and/or interpretation of this Agreement, such conflict shall be brought before the courts of Leuven and Belgian Law shall be applicable.'};
        {''};{''};
        {'Annex A : '};
        {'Description of the Software'};
        {'Item response theory (IRT) models are the central tools in modern measurement and advanced psychometrics. IRTm is a MATLAB IRT modeling toolbox that can fit a large variety of IRT models for binary responses. A design-matrix approach is followed, giving the end-user control and flexibility in building a model that goes beyond standard models like the Rasch or 2PL model. For instance, the very recent copula IRT models to handle local item dependencies are included, as well as the possibility to take into account differential item functioning, and many more. Data simulation is supported.'};
        {'Braeken, J., Tuerlinckx, F., & De Boeck, P. (2007). Copulas for residual dependency. Psychometrika, 72, 393–411.'}
        {''};
        {'Braeken, J., & Tuerlinckx, F. (submitted). Fitting explanatory Item Response Theory models:a Matlab IRTm toolbox.'}
        {''};
        {'De Boeck, P., & Wilson, M. (Eds.). (2004). Explanatory item response models: A generalized linear and nonlinear approach. New York: Springer.'}];

    scrsz = get(0,'ScreenSize');
    h=figure('CloseRequestFcn',@my_closereq,'Toolbar','none','MenuBar','none','NumberTitle','off','Name','License Agreement','Position',[50 50 scrsz(3)-150 scrsz(4)-150],'color',[1 1 1]);
    ha = get(h,'Position');
    a1=uicontrol(h,'Style','Listbox','Position',[0 50 ha(3) ha(4)-50],'Value',1,'FontName','Courier','BackgroundColor',[1 1 1],'String',txt);
    b3=uicontrol(h,'Style','text','Position',[0 30 ha(3) 20],'FontWeight','bold','BackgroundColor',[1 1 1],'String','Do you accept this license agreement and want to continue with installing the IRTm toolbox?');
    b1=uicontrol(h,'Position',[ha(3)/6 0 ha(3)/6 30],'String','NO','tag','no','FontWeight','bold','FontSize',16,'Callback',{@irtcend});
    b2=uicontrol(h,'Position',[2*ha(3)/3 0 ha(3)/6 30],'String','YES','tag','yes','FontWeight','bold','FontSize',16,'Callback',{@irtcinst});
else
    display(['The IRTm toolbox version ',versienr,' appears to be already installed!'])
end

function my_closereq(src,evnt)
% User-defined close request function
% to display a question dialog box
selection = questdlg('Do you accept this license agreement and want to continue with installing the IRTm toolbox?','Close Request Function',...
    'Yes','No','Yes');
switch selection,
    case 'Yes',
        irtcinst();
    case 'No'
        irtcend();
        return
end

function irtcinst(hObject,eventdata);
versienr='version0.0';
lic=['license',versienr,'.txt'];

delete(gcf);
fid = fopen(lic,'w');
fprintf(fid,'%s\n',versienr);
fprintf(fid,'%s\n','If you delete this file, the IRTm toolbox might not function like it should do.');
fclose(fid);

completed=0;
I = imread('doc/logoJB.jpg');
splashImage = im2java(I);
win = javax.swing.JWindow;icon = javax.swing.ImageIcon(splashImage);
label = javax.swing.JLabel(icon);win.getContentPane.add(label);
screenSize = win.getToolkit.getScreenSize;screenHeight = screenSize.height;
screenWidth = screenSize.width;imgHeight = icon.getIconHeight;
imgWidth = icon.getIconWidth;win.setLocation((screenWidth-imgWidth)/2,(screenHeight-imgHeight)/2);
win.pack
win.show
display('Setting path');path=fileparts(which('IRTmInstall.m'));
cd(matlabroot);addpath(path);savepath;cd(path);
path2=[path,'\doc\index.html'];


txt=['<productinfo  xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"  xsi:noNamespaceSchemaLocation="http://www.mathworks.com/namespace/info/v1/info.xsd"><?xml-stylesheet type="text/xsl" href="http://www.mathworks.com/namespace/info/v1/info.xsl"?><matlabrelease>14</matlabrelease><name>IRTm</name><type>toolbox</type><icon>$toolbox/matlab/icons/matlabicon.gif</icon><help_location>doc</help_location><list><listitem><label>Help</label><callback>web(''',path2,''','' -helpbrowser'');</callback><icon>$toolbox/matlab/icons/book_mat.gif</icon></listitem><listitem><label>Basic Examples</label><callback>echodemo(''IRTmCase'',1)</callback><icon>$toolbox/matlab/icons/demoicon.gif</icon></listitem><listitem><label>Product Page (Web)</label><callback>web http://ppw.kuleuven.be/okp/software/ -browser;</callback><icon>$toolbox/matlab/icons/webicon.gif</icon></listitem></list></productinfo>'];
fid = fopen('info.xml','w');
fprintf(fid,'%s',char(txt));
fclose(fid);

completed=1;
if completed==1; win.dispose(), display(['Install of IRTm toolbox ',versienr,' completed.']); end

function irtcend(hObject,eventdata);
versienr='version0.0';
delete(gcf);
display(['Installation of IRTm toolbox ',versienr,' has been cancelled.']);

%   Adapted a bit of code for the splash screen of Han Qun, Sept. 2004
%   College of Precision Instrument and Opto-Electronics Engineering,
%   Tianjin University, 300072, P.R.China.
%   Email: junziyang@126.com