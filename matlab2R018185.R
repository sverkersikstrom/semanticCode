matlab2R018185 <- function (model = "bert_base_multilingual_cased",file="BERT-018185.csv",path="/home/semantic/semanticmatlab/")
{
source("/home/semantic/semanticmatlab/semanticCode/file2BERT2.R")
t <- file2BERT2(model,file,path) 
}
t2<-matlab2R018185()
