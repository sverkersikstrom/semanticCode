matlab2R041599 <- function (model = "bert_base_multilingual_cased",file="BERT-041599.csv",path="/home/semantic/semanticmatlab/")
{
source("/home/semantic/semanticmatlab/semanticCode/file2BERT2.R")
t <- file2BERT2(model,file,path) 
}
t2<-matlab2R041599()
