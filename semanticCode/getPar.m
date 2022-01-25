function [par d]=getPar(setPar,type)
if nargin>=2
    if strcmpi(type,'persistent')
        setPar.persistent=1;
    elseif strcmpi(type,'clear')
        setPar.clear=1;
    end
end
persistent setParPersistent

%if isfield(setParPersistent,'handels')
%    handles=setParPersistent.handels;
%    fprintf('GetH')
%else
handles=getHandles;
%end 
%parameter(handles.predictionProperties,'string');

%category Context generations
par.variableToCreateSemanticRepresentationFrom='_text';%skipse%Generate one semantic representation from one, or several, text(s) stored in this/these property/properties
par.variableToCreateSemanticRepresentationFromRepeted=0;%options 0 1%skipse%Repeate the semantic representations above with single texts
par.trainOnCrossValidationOfMultipleTexts='';%Conducting one training for each texts, and train on the cross-validated predictions.
par.predictionProperties='';%Numerical predictor(s) used in training
par.predictionPropertiesAddLate=0;%options 0 1%Add numerical preditors in the last step
par.variableToPreprocessCreateSemanticRepresentationFrom='';%Preprocess by logarihtm+1 variables used in training
par.variableToCreateMultipleSemanticRepresentationFrom='';%Generate one semantic represenation for each text(s), and then append the semantic representations
par.space2='';%skipse%Add a second space with this name
par.variableToCreateSemanticRepresentationFrom2='';%Second space; Generate semantic context from text(s) stored in this Property, default value _text
par.variableToCompareSemanticSimliarity='';%Measure semantic simliarity to this Property
par.subtractSemanticRepresentation='';%Subtract semantic representions from text(s) stored in this Property
par.contextNorimalizeBySubject=0;%options 0 1%Normalize space vector by subject (_subject)
par.expandWordClass=0;%options 0 1%%Expand semantic represenation with wordclass and then compress with SVD
par.trainOnWordFrequency=0;%options 0 1%%Add word frequencies to the representation
par.trainReplaceMissingDataWithMean=0;%options 0 1%Replaces missing data with the mean value of the same variable
par.preprocessWithSVD=strcmpi(get(handles.preprocess_with_SVD,'checked'),'on');%options 0 1%Preprocesses training data with SVD
par.preprocessWithNNMF=0;%positive%Preprocesses training data with Non-negative matrix factorization, using N factors
par.forceMaxDim=0;%Maximal number of dimensions used in space (0=all)
par.weightTargetWord=parameter(handles.weightByContextWords,'string');%Weigth the semantic representation stronger close the target word(s)
par.weight=.9;%options range 0 1%Power/exponential-function weighting factor for target word
par.weightPower=0;%options 0 1%Weight words using a power-function, otherwise with an exponential function
par.weightPrimacy=0;%positiv%Weight words in the begining of the text stronger (ie power or exponential-function)
par.weightFrequency=0;%Weight semantic representation depending on frequency
par.weightWordClass=strcmpi(get(handles.wordClass,'Checked'),'on')';%Weight semantic representation depending on word classes
par.weightWordClass(length(par.weightWordClass):-1:1)=par.weightWordClass;
if mean(par.weightWordClass(1:17))==1; par.weightWordClass=0;end
par.contextSizeSet=parameter(handles.word_context_size);%Size of context
par.contextSeperator='_NAN';
par.stopwords(1)=strcmpi(get(handles.includeStopwords,'Checked'),'on')';
par.stopwords(2)=strcmpi(get(handles.includeNonStopwords,'Checked'),'on')';
par.stopwords(3)=strcmpi(get(handles.stopwordsSmooth,'Checked'),'on')';
par.weightFirstNWords=0;%positiv%Include the first N words of text in the semantic representation
par.weightRandomNWords=0;%positiv%Include N randomly selected words from the text in the semantic representation
par.weightWordPosition=0;%positiv%Include word in serial-position "weightWordPosition" in the semantic representation
par.weightLogNwords=0;%Weight words by the log of the frequency in the current text
par.weightByDate='';%Select words with dates between the two dates, i.e. "2011-04-31 2015-01-14", where the dates are stored in text+Dates properties
par.weightByDateVariabel='';%Property where dates are stored, needs to match in length with the text
par.xmeanCorrection=strcmpi(get(handles.xmeanCorrection,'checked'),'on');%options 0 1%Correct for frequency artifacts during creation of a semantic represenation
par.NWildcardExpansion=0;%Use the N most high frequency words in expansions (e.g lov* expands with the 2500 most high frequenct words)
par.semanticRepOnUniqueWords=0;%options 0 1%Create semantic representation on unique words
par.openNormFile='text';%options norm LIWC text%Open file as norms, LIWC, or text.
par.updateNorms=0;%options 0 1%Allow parameter settings to change norm representation
par.parametersForTrainUpperMedianSplit=0;%options 0 1%In traning, for the uppder medial split y-data, use these parameter settings
par.normalizeSpace=1;%options 0 1%Normalize length of space vectors to 1
par.contextAddCluster=[];%Make Fuzzy clusters and add them to the representations, e.g. [5 20] adds 5 and 20 clusters
par.contextPrintLabels=1;%options 0 1%Print out labels on the semantic dimensions
par.numericalData=[];
%contextWildcardExpansion=0;%options 0 1%Use "*" in words, ie, lov* expandes to love, loved, etc

%category List identifiers
par.sortIdentifier='';%Sort the order of the identifier, according a property, e.g, _frequency
par.semanticRepWords=0;%Create semantic representation on ALL words (warning: memory problems)

%category getProperty
par.getPropertyShow=get(handles.similarityMeasure(1),'UserData');%options property default semanticSimilarity predTextVariables predNumericalVariables pred2percentage pred2z pred2zStored standarddeviation   min   max   mean   positive   negative   positivenegative   sortwordcrit sortword sortwordLow2High   sortvalue  mergeTexts subtractTexts unionText unionPercentage meanFull semanticTest chi2test targetword seperator keywords LIWC liwcAll noLIWC reverseOrder color sortByFrequency %Type of association
par.mapPredictions2Labels=0;%options 0 1%Map predicitons data based on data2p or pred2percentage to labels normal (p<.80), mild (p>=.80), moderate (p>=.90), severe (p>=.95)
par.mapPredictions2LabelsP=[.80 .90 .95 1];%Critiera for mapping to labels
par.mapPredictions2LabelsText={'Normal','Mild','Moderate','Severe'};%Text for labels
par.multinomialCategory=0;%Show category from multinomial predictions
par.resultsVariables=parameter(handles.resultsVariables,'string');%Select variables to output;
par.variablityN=30;%options range 0 100%Number of words used in _pairwisevariablity, less than 100 is recommended for speed
par.freezeSecondsParameterGetProperty=strcmpi(get(handles.freezeSecondsParameterGetProperty,'checked'),'on');%skip%
par.coherenceN=parameter(handles.dist_number_words);
par.reverseOrder=0;%Reverse order for calculating LIWC scores
par.correlationType='';%options Pearson Kendall Spearman %Type of correlation, default is Pearson
[~, categories]=getIndexCategory;
par.getcategoryid=categories{5};%options Functions Clusters Prediction LIWC Semantic dimensions Semantic scales Wordclasses Texts Words Stopwords Variables Norms User Defined%Choose the category to list in getcategoryid
par.sortwordcrit=2;

if isempty(par.getPropertyShow) par.getPropertyShow='';end

%category Semantic test
par.n_bootstraps= parameter(handles.n_bootstraps);%Number of bootstraps during semantic test
par.paired_semantic_difference= strcmpi(get(handles.paired_semantic_difference,'checked'),'on');%options 0 1%Paired semantic test
par.match_paired_test_on_subject_property= strcmpi(get(handles.match_paired_test_on_subject_property,'checked'),'on');%Match semantic test on subject property
par.semanticTestMatchProperty=regexprep(parameter(handles.bootstrap_subject,'string'),'_','');%Property to match paired semantc on, e.g., _subject
par.semanticCorrelationAlgorithm='correlation';%options correlation canonical similiarity%Algorithm used for semantic correlation

%category Keywords
par.keywordsWordclass=0;%options 0 1%Calculate statistics on wordclasses
par.keywords_over_articles=strcmpi(get(handles.keywords_over_articles,'checked'),'on');
par.save_assocation_matrix=strcmpi(get(handles.save_assocation_matrix,'checked'),'on');
%if strcmpi(get(handles.correctionForMultipleComparisions(1),'checked'),'on')
%    par.keywordCorrectionType=2;
%elseif strcmpi(get(handles.correctionForMultipleComparisions(2),'checked'),'on')
%    par.keywordCorrectionType=1;
%elseif strcmpi(get(handles.correctionForMultipleComparisions(3),'checked'),'on')
par.keywordCorrectionType=0;%options 0 1 2%Correcting for multiple comparisions (=0 Bonferroni correction,=1 Holme s correction,=2 not corrected
%end
par.keywordSelectRelevance=0;%skip%Select only X words that are most overrepresented relative the norm in the language
par.category={''};%Calculate LIWC scores based on these identifiers
par.reverseOrder=0;
par.LIWCcorr=parameter(handles.LIWCcorr,'string');
par.keywordCorrProperty=parameter(handles.keywordCorrProperty,'string');
par.categoryLabel='';
par.keywordsPointBiSerialCorrelation=0;%options 0 1%%Use pointbiserial correlation

%category Plot(old)
par.figureType=0;%Figures to plot [1-15]
par.plotwordCountCorrelation=1;%Use correlation, rather than median split
par.plotOnSemanticScale=0;%options 0 1%Plot on semantic scale
par.plotWordcloudNormalizedWithFrequency5=1;%options 0 1%Normalize wordcloud 5 word frequency
par.plotWordcloudNormalizedWithFrequency15=0;%options 0 1%Normalize wordcloud 15 word frequency

par.time_new_graf=strcmpi(get(handles.time_new_graf,'checked'),'on');
par.text_all2=strcmpi(get(handles.text_all2,'checked'),'on');
par.print_some2=strcmpi(get(handles.print_some2,'checked'),'on');
par.plot_mean= strcmpi(get(handles.plot_mean,'checked'),'on');
par.plotEachDataPoint= strcmpi(get(handles.plotEachDataPoint,'checked'),'on');

par.keywordsPlotSpread=parameter(handles.keywordsPlotSpread);
par.plotWordPrintDots=strcmpi(get(handles.plotWordPrintDots,'Checked'),'on');
par.plotWordCountWords=strcmpi(get(handles.plotWordCountWords,'Checked'),'on');
par.plotWordcountWeightCluster=parameter(handles.plotWordcountWeightCluster);

%category Plot
par.plotCloudType='words';%options words users category histogram%Plot words, users, or categories
par.plotCategory='LIWC';%options Functions Clusters Prediction semanticLIWC LIWC Semantic-dimensions Semantic-scales Wordclasses Texts Words Stopwords Variables Norms User-defined%Choose the category of identifiers to plot
par.plotNumericData='';%Plot numeric data only, list numeric properties here.
par.plotTestType='semantic';%options semantic semanticTest train frequency frequency-correlation property%Choose how the semantic scale is calculated
par.plotCluster=0;%options 0 1%Cluster the plot
par.plotWordcloudType='non-nominal';%options nominal non-nominal%Treat data as nominal (categories) or non-nominal (continous)
par.plotWordcloud=1;%options 0 1%Plot as wordcloud (1) or as scale (0)
par.plotProperty='_predvalence';%Property to plot
par.plotCategoryUserDefined='';%Defines a group of identifier called User-Defined
par.keywordsPlotPvalue=parameter(handles.keywordsPlotPvalue);%options range 0 1%%Plot identifiers with p-values less than this
par.plotBonferroni=1;%options 0 1 2%Correction for multiple comparisions, 1=Bonferroni, 2=Holme's, 0=Uncorrected
par.plotWordcountMaxNumber=parameter(handles.plotWordcountMaxNumber);%Maximum number of words to plot in Wordclouds
par.plotRemoveWords='';%Remove/replace words from the plot
par.plotReplaceWords='';%Replace comma seperated removed words, e.g., 'U.S. USA, you YOU' replace U.S with USA etc.
par.plotAxis='default';%options default z q f 1-p predicted%Defines scales on the axis
par.plotFilename='';%For 3-dimensional plots, make a move with this filename
par.plotDrawCross=0;%options 0 1 2%Draw crosses (1), pr crosses and connected lines (2)
par.plotAxisLocation='Lower-left';;%options Origo Lower-left%Place axis either at origo or the lower left of the figure
par.plotSignificantColors=2;%options 1 2 3 4 5 6 7 8 9%Color schema: 1=red,2=p-coded, 3=Grouped, 4=random(p=0), 5=one-random-color,6=Color-map, 7=Plot z-values, 8=Cluster
par.plotColorMap='hot';%options parula jet hsv hot cool spring cool summer autumn winter gray %Color map
par.plotColor='';%Defines group colours in the plot, default: gkrbcmyg (g=green, G=gray, b=blue, r=red, c=cyan, m=magenta, y=yellow, k=black)
par.plotBackGroundColor=[.94 .94 .94];%Sets background color [Red Green Blue], default value is [0.94 0.94 0.94]
par.plotColorCodesFor='p';%options p value%Color codes for p or values.
par.plotColorLimits=[];%Set limits for color coding
par.plotFontname='Helvetica';%options listfonts%Fontname used in wordclouds
par.fontsizeLimits=parameter(handles.plotWordcountMinMaxFontsize);%Upper and lower limits for fontsize in plotting
par.plotRemoveCharacters='';%Remove parts these characters from the plotted words
par.plotXlabel='';%Label on x-axis
par.plotYlabel='';%Label on y-axis
par.plotZlabel='';%Label on z-axis
par.plotTitle='';%Title on the figure
par.excelServer=0;%skipse%Faster plotting, used in webserver
par.plotCovariateProperties='';%%Covarites used in plotting
par.fixProblemWithSemanticTestWordClouds=0;
par.plotRemoveHFWords=0;%Remove high frequency words from the figure(range 0< <1, =0 keep all, try .001)
par.plotRemoveNoneWords=0;;%options 0 1%Do not plot words from texts where all words are non-words
par.plotSaveFolder='';%Save figures in the this folder
par.plotOnCircle=0;%options 0 1%Plot words on a circle, if there are 30 words or less
par.plotNetWorkAnalysis=0;%options 0 1%Plot network analysis
par.plotNetworkModel='';%Prediction model to make network analysis on
par.plotNetWorkCovariates=0;%options 0 1%Use covariates on plot network analysis
par.plotNetworkMaxLine2print=21;%Maximal number of plotted lines in network analysis
par.plotDrawLinesBetweenSimilarConcepts=0;%options 0 1%Draws lines between semanticially similiar concepts
par.plotNominalLabels='';%Labels on nominal data
par.plotWordSize=1;%Changes the size of with a factor x, default 1
par.plotAutoSaveFigure=0;%options 0 1%Automatically save figures

%Report
par.updateReportAutomatic=0;
par.update_report_automatic=strcmpi(get(handles.update_report_automatic,'checked'),'on');

%category train
par.trainModelName='';%skipse%Model name produced by traning
par.regressionCategory=strcmpi(get(handles.regressionCategory,'checked'),'on');
par.bootstrapSubject=strcmpi(get(handles.bootstrap_subject,'checked'),'on');
par.extendedOutput=strcmpi(get(handles.extendedOutput,'checked'),'on');
par.covariateProperties=parameter(handles.covariates_properties,'string');%skipse%Covarites used in training
par.trainMengz='';%p-value wheather the predicted correlation differs from the correlation to another variable using Meng's test
par.groupingProperty=regexprep(parameter(handles.bootstrap_subject,'string'),'_','');%skipse%Group training according to this property
par.selectBestDimensions=strcmpi(get(handles.selectBestDimensions,'checked'),'on');%Select dimensions orded by how well they correlate training with outcome variables
par.NleaveOuts=parameter(handles.NleaveOuts);%Number of groups in during N-leave-out cross validation
%NleaveOuts2=NaN;%Number of groups in during N-leave-out cross validation during optimization of dimensions
par.optimzeDimensions=strcmpi(get(handles.optimize_dimensions,'checked'),'on');
par.dim=parameter(handles.optimize_dimensions);
if isempty(par.dim) par.dim=0; end
par.optimzeDimensionsConservative=strcmpi(get(handles.optimize_dimensions_conservative,'checked'),'on');%options 0 1%Use N-leavout while optimizing the number of dimensions, conservative and slow
par.predictOnWordClass=strcmpi(get(handles.predictOnWordClass,'checked'),'on');
par.forceMaxDimToN2=strcmpi(get(handles.forceMaxDimToN2,'checked'),'on');%Force maximimal number of dimensions used to N/2
par.randomizeTraining=0;%Randomized training (Should yield insignificant results)!
par.optimizeTrainingGroups=1;%options 0 1%Matching groups to minimize variabiliy in the trained data values
par.trainRemoveOutLiners=0;%options 0 1%Automatically remove outerliners in the training data set and in the predicted data set
par.trainOnSingleWords=0;
par.trainBinaryOutput=0;
par.trainBinaryOptimizeMethod=1;%options 0 1%For binary outputs, 1=optimes recall and precsion, 0=1 optimze recall
par.trainBinaryOptimizeWeight=.05;% Weight precision with (w) and recall with (1-w)  function.
par.trainBinaryThreshold=NaN;%Manually set threshold (NaN=optimize according to par.trainBinaryOptimizeMethod)
par.trainSemanticKeywordsFrequency=0;%options 0 1 2 3 4%Use word frequency while extracting semantic keywords 0 (skip), 1&3, leavout 3&4
par.trainOnWFSVDCrossValidationOfMultipleTexts=0;%options 0 1%Train on crossvalidation of multiple texts using word-frequency and SVD preprocessing
par.trainOnDiffCrossValidationOfMultipleTexts=0;%options 0 1%Train on difference-crossvalidation of multiple texts
par.trainOnCrossValidationOfMultipleTextsRetrain=0;%options 0 1%Retrain crossvalidated data
par.timeSerieAverage=1;
par.timeSerie= strcmpi(get(handles.regression_on_time_serie,'checked'),'on');
par.timeSerieOffset=parameter(handles.time_serie_delay);
par.timeSerieExpand=NaN;
par.trainMedianSplitKeywordAnalysis=strcmpi(get(handles.trainMedianSplitKeywordAnalysis,'checked'),'on');%In train, also calculate keywords
par.timeSerieGrouping=0;
par.trainEnsambleMethod='bag';%skip%AdaBoostM2
par.trainNumberens=100;
par.trainLearners='Tree';
par.trainPerformanceDependingOnN=0;%options 0 1%Performance as a function of the number of datapoints
par.trainPerformanceDependingOnNWords=0;%options 0 1%Performance as a function of the number of first words in the texts
par.trainPerformanceDependingOnNRandomWords=0;%options 0 1%Performance as a function a number of random words in the texts
par.trainPerformanceDependingOnSerialPosition=0;%options 0 1%Performance as a function a serial position of the words in the texts
par.trainPerformanceDependingOnXData=0;%Loops over positions, e.g., [1 2 4 8 16]
par.trainPerformanceOnVariabel='';%Performance depending on variable, e.g., {'weightFrequency', '[1 1.25 1.5 2 3 4 6]'}
par.trainingSets='';%Do performance depending on variable on multiple trainingssets, e.g., '_study6a* _study6b* _study6c*'
par.regression_extension=parameter(handles.regression_extension,'string');
par.trainSortOutput=1;;%options 0 1%Sort multiple predictions after correlation cofficients
par.trainNominal2Dummy='';
par.trainOutPutCrossValidatedData=0;;%options 0 1%Print cross validated data
par.zTransformGroup=0;%options 0 1%Z-transform the y-values of each unique group

%model: regression logistic ridge ensemble LDA
par.model=strcmpi(get(handles.logisticRegression,'checked'),'on');%options logistic ridge regression lasso%Type of predictor used during training
if par.model==1
    par.model='logistic';
elseif par.model==2
    par.model='ridge';
    par.ridgeK=1;
else
    par.model='regression';
end

%category Cluster
par.clusterName='';%Identifers for cluster centroids, e.g., cluster1, cluster2... clusterN
par.Ncluster=parameter(handles.Ncluster);%Number of clusters
par.clusterQuality=0;%options 0 1%Calculates Davies Bouldin and Dunn indexs of cluster quality for 1-N clusters, set to 0/1 (Takes time).
par.clusterNRepetions=1;%Repeat k-means kluster N times, and output the best klustering according to Dunns kriteria
par.clusterFuzzyKMeans=0;%options 0 1%Use fuzzy k-means
par.clusterFuzzyKMeansUOverlapParmeter=1.01;%Exponent for the fuzzy partition matrix U, specified as a scalar greater than 1.0. This option controls the amount of fuzzy overlap between clusters, with larger values indicating a greater degree of overlap.
par.clusterPlot=strcmpi(get(handles.clusterPlot,'Checked'),'on');%Calculate binary hiearical clustering
par.clusterProperties='';%Compares each cluster with these continous values properties
par.clusterPropertiesCategorical='';%Compares each cluster with these categorical properties
par.clusterDominantWordclass=0;%Select domiant wordclass for each cluster
par.resetRandomGenator=1;%options 0 1%Reset random generator prioer to clustering (produces the same cluster all the time)

%category Translate
par.translate=0;%options 0 1%Translate output in plots from current language to English
par.translateTolanguage='en';%Translate text to this language code, e.g., 'en' for English, 'sv' for Swedish
par.translateFromlanguage='sv';%Translate text from this language code, e.g., 'en' for English, 'sv' for Swedish
par.translateWordByWord=1;%options 0 1%Translate text word by word using a cache.

%category Various settings
par.save2json=0;%options 0 1%Save data to json file
par.saveResults2File=0;%options 0 1%Save text output to file file results+date.txt
par.maxPrintedCharacters=24000;%Maximal number of output characters per line/variable in output structure
par.printOutputToScreen=1;%Print output to matlab window
par.NgramPOS=strcmpi(get(handles.NgramPOS,'checked'),'on');%Use Google Ngram word class classifier
par.parfor=0;%options 0 1%Use paralell processing
par.generalUseDefaultSettings=0;%options 0 1%Use default settings, so that no input dialog is used. Use Analyse/Set parameters to change settings
par.saveCrossValidationData=1;

%category associates
par.number_of_ass2= parameter(handles.number_of_ass2);%Number of semantic associates to print
par.remove_underscore_words= strcmpi(get(handles.remove_underscore_words,'checked'),'on');%For associats, remove words starting with _
par.remove_normal_words= strcmpi(get(handles.remove_normal_words,'checked'),'on');%For associates, remove normal words
par.semanticSelectWords='';%Limit possibel associates to these words
par.semanticSelectWordsToSelectedWords=0;%Limit possibel associates to the most recent selected group of words, occuring at least N times
par.printDistance= strcmpi(get(handles.printDistance,'checked'),'on');%For associates, print semantic simliarity value

%category CreateSpace
par.contextSize=15;%Context size for co-occurence matrix (0=all words)
par.Ncol=10000;%Number of columns in co-occurence matrix
par.NSVD= 2000;%Number of columns used in non-sparse SVD
par.Nrow=120000;%Number of words in space
par.SVDsparse=1;%options 0 1 2%Use sparse SVDs(1)/Use full SVD/Or automatic choice(2)
par.tdidf=0;%Noramlize co-occurence matrix with tdidf (1)/logarithm (0)
par.seperationCharacters='\".,!?;&?()[]/<>:$%`-';%Seperate text using these characters
par.allowNumbers=0;%Allow words begning with numbers
par.normalizeContextSize=0;%Normalize influence of different contextsizes (1=word, 2=context, 0=not-normalize)
par.languageCode='';%Language code, e.g., 'en' for English, or 'se' for Swedish
par.LSAaddFeatureFile='';%Add features from data-file with this name
par.LSAtabSeperator=1;%options 0 1%Seperate context by tabs
par.LSAaddColumnNames=0;%options 0 1%Add column names (for row 1) to corpus
par.LSAaddRowNames=0;%options 0 1%Add row name (for column 1) to cells in the corpus
par.LSAsaveExtraFiles=0;

%category large files
par.textColumn=1;%Column where the text data is located
par.restart=1;%options 0 1%Starts from the beging of the file (otherwise continue where interupted)
par.keepText=0;%options 0 1%Keep text in output file
par.hasTitle=0;%options 0 1%Inputfile has a title row that is skipped
par.runOnce=0;%options 0 1%Run Nstep texts, and then exit
par.Nstep=40;%Calculates N rows at a time
par.parallelFiles=0;%options 0 1%Do parelle computing


%Programing setting
par.saplo=0;
par.user=0;
par.db2space=0;
par.public=0;
par.checkIfSaved=1;
par.fastAdd2Space=0;
par.text2indexIgnore=0;
par.variables=1;%findstr(pwd,'sverker')>0;
par.askForInput=1;
par.callfrom='';
par.func='';
par.userCallId='';
par.condition_string='';

%category DLATK
par.DLATK=0;%options 0 1%Use DLATK
par.DLATKparameter1='dlatkInterface.py -d space2 -t msgs -c user_id --add_ngrams -n 1';%DLATK1 dlatkInterface.py -d space2 -t msgs -c user_id --add_ngrams -n 1
par.DLATKparameter2='dlatkInterface.py -d space2 -t msgs -c user_id -f ''feat$1gram$msgs$user_id$16to16'' --feat_occ_filter --set_p_occ 0.05';%DLATK2 dlatkInterface.py -d space2 -t msgs -c user_id -f ''feat$1gram$msgs$user_id$16to16'' --feat_occ_filter --set_p_occ 0.05
par.DLATKparameter3='dlatkInterface.py -d space2 -t msgs -c user_id --group_freq_thresh 1 -f ''feat$1gram$msgs$user_id$16to16$0_05'' --outcome_table outcomes --outcomes swlstotal hilstotal --combo_test_reg --feat_selection magic_sauce --model ridgehighcv --folds 10 --save_model --picklefile ~/msgs_tsBERThils_swls_OK_TEST14aug_2.pickle';%DLATK3 dlatkInterface.py -d space2 -t msgs -c user_id --group_freq_thresh 1 -f ''feat$1gram$msgs$user_id$16to16$0_05'' --outcome_table outcomes --outcomes swlstotal hilstotal --combo_test_reg --feat_selection magic_sauce --model ridgehighcv --folds 10 --save_model --picklefile ~/msgs_tsBERThils_swls_OK_TEST14aug_2.pickle
 
%Variables set while debugging
par.debug=0;
if strfind(pwd,'sverkersikstrom')>0 & 0
    par.clusterDominantWordclass=1;
    beep2(1)  
end
par.parameterFile=parameter(handles.setParametersFromFile,'string');
if length(par.parameterFile)>0
    f=fopen(par.parameterFile);
    while not(feof(f))
        a=fgets(f);
        if length(a)>4 & strcmpi(a(1:4),'par.')
            eval(a);
            fprintf('Settings parameter: %s\n',a);
        else
            fprintf('Problem on line: %s\n',a);
        end
    end
end

persistent dsave;

if nargin>0
    if isstruct(setPar) & isfield(dsave,'field')
        f=fields(setPar);
        for i=1:length(f)
            index=find(strcmpi(dsave.field,f{i}));
            if not(isempty(index)) & not(isnan(dsave.range(index,1)))
                eval(['setPar.' f{i} '=max(setPar.' f{i} ',dsave.range(index,1));'])
                eval(['setPar.' f{i} '=min(setPar.' f{i} ',dsave.range(index,2));'])
            end
        end
    end
    par=structCopy(par,setPar);
    if isfield(setPar,'clear')
        setParPersistent=[];
        dsave=[];
    elseif isfield(setPar,'persistent')
        setParPersistent=structCopy(setParPersistent,setPar);
        dsave=[];
    end
    %     if setPar==1
    %         fprintf('Saving parameter settings\n')
    %         savedPar=par;
    %     else
    %         fprintf('Clearing parameter settings\n')
    %         savedPar=[];
    %     end
end
if not(isempty(setParPersistent))
    par=structCopy(par,setParPersistent);
end
d.setParPersistent=setParPersistent;

if nargout>1
    global compile
    if compile
        if not(isempty(dsave))
            d=dsave;
        elseif not(exist('getPar.mat'))
            [f p]=uigetfile('getPar.mat','Please locate the file getPar.mat');
            load([p f])
        else
            load('getPar')
        end
        if exist('d')
            %load('getPar')
            for i=1:length(d.value)
                if isfield(par,d.field{i})
                    d.value{i}=par.(d.field{i});
                end
            end
        end
        dsave=d;
    elseif not(isempty(dsave))
        d=dsave;
    else
        category='';
        f=fopen('getPar.m','r','n', 'UTF-8');
        i=0;
        
        while not(feof(f))
            t=fgets(f);
            try
                i1=findstr(t,'par.');
                i2=findstr(t,'=');
                i3=findstr(t,'%');
                i4=findstr(t,'%skip%');
                tmp='%';%Skip in semantic excel.
                i5=not(isempty(findstr(t,[tmp 'skipse' tmp])>0)) & par.excelServer;
                
                icat=findstr(t,['%' 'category']);
                if icat>0 %This item is category
                    category=t(min(end,icat+10):end-1);
                    if length(category)<=1 category=[];end
                    i=i+1;
                    d.range(i,1:2)=nan(1,2);
                    d.comment{i}=upper(category);
                    d.field{i}='category';
                    d.options{i}='';
                    d.category{i}=d.comment{i};
                    d.value{i}='';
                    d.datatype{i}='string';
                end
                
                if not(isempty(i1)) & not(isempty(i2)) & not(isempty(i3)) & isempty(i4) & not(i5)
                    i=i+1;
                    d.range(i,1:2)=nan(1,2);
                    d.comment{i}=t(i3(end)+1:end-1);
                    d.field{i}=t(i1+4:i2-1);
                    i4=findstr(t,'%options');
                    i5=findstr(t,'%positiv%');
                    if i5>0
                        d.range(i,1)=0;d.range(i,2)=Inf;
                    elseif i4>0
                        options=string2cell(t(i3(1)+9:i3(2)-1));
                        if strcmpi(options,'listfonts')
                            options=listfonts;
                        end
                        if length(options)>=3 & strcmpi(options{1},'range')
                            d.range(i,1)=str2double(options{2});
                            d.range(i,2)=str2double(options{3});
                        else
                            d.options{i}=options;
                        end
                    else
                        d.options{i}='';
                    end
                    d.category{i}=category;
                    d.value{i}=par.(d.field{i});
                    if iscell(d.value{i})
                        d.commentValue{i}=[d.comment{i} ' : ' cell2string(d.value{i})];
                    else
                        d.commentValue{i}=[d.comment{i} ' : ' num2str(d.value{i})];
                    end
                    if isnumeric(par.(d.field{i}))
                        d.datatype{i}='numeric';
                    elseif ischar(par.(d.field{i}))
                        d.datatype{i}='string';
                    elseif islogical(par.(d.field{i}))
                        d.datatype{i}='logical';
                    elseif isstruct(par.(d.field{i}))
                        d.datatype{i}='struct';
                    else
                        d.datatype{i}='';
                    end
                end
            catch
                fprintf('Error in getPar: %s\n',t)
            end
        end
        if 1 
            expand={'getPropertyShow','plotTestType'};
            for k=1:length(expand)
                i=find(strcmpi(d.field,expand{k}));
                optionsLong=...
                    {'semanticSimilarity','Semantic similarity';...
                    'pred2percentage','Maps predictions to percentages';
                    'pred2z','Maps predictions to z-transformation';...
                    ,'standarddeviation','Standarddeviation of semantic similiarity of words';...
                    ,'min','Minimum value of the words in the text';...
                    ,'max','Maximum value of the words in the text';...
                    ,'mean','Mean value of the words in the text';...
                    ,'positive','';...
                    ,'negative','';...
                    ,'positivenegative','';...
                    ,'sortword','Sort words from high to low';...
                    ,'sortwordLow2High','Sort word from low to high';...
                    ,'sortvalue','';...
                    ,'mergeTexts','Concatenate two texts';...
                    ,'subtractTexts','Remove words in the second text from the first text';...
                    ,'unionText','Show words that exists in both texts';...
                    ,'unionPercentage','The percentage of words that are present in both texts';...
                    ,'meanFull','Pairwise semantic simliarities between words in the two texts';...
                    ,'semanticTest','Semantic t-test on words in the two texts';...
                    ,'chi2test','Chi2test on words in the two texts';...
                    ,'targetword','';...
                    ,'seperator','';...
                    ,'keywords','';...
                    ,'LIWC','';...
                    ,'liwcAll','';...
                    ,'noLIWC','';...
                    ,'reverseOrder','';...
                    ,'color','';...
                    ,'sortByFrequency','';...
                    ,'semantic','Use semantic t-test if the variable is binary, otherwise use train'
                    };
                d.optionsLong=d.options;
                for j=1:length(d.options{i})
                    k=find(strcmpi(d.options{i}{j},optionsLong(:,1)'));
                    if not(isempty(k)) & length(optionsLong{k,2})>0
                        d.optionsLong{i}{j}=optionsLong{k,2};
                    end
                end
            end
        end
    end
    try
        for i=1:length(d.commentValue)
            if isempty(d.commentValue{i})
                d.commentValue{i}='';
            end 
        end
    end 
    save('getPar.mat','d') 
    dsave=d;
end
global correlationType
correlationType=par.correlationType;

persistent parametersForTrainUpperMedianSplitTmp;
if isempty(parametersForTrainUpperMedianSplitTmp) | not(parametersForTrainUpperMedianSplitTmp==par.parametersForTrainUpperMedianSplit)
    parametersForTrainUpperMedianSplitTmp=par.parametersForTrainUpperMedianSplit;
    global parametersForTrainUpperMedianSplit;
    parametersForTrainUpperMedianSplit=par;
end

end



