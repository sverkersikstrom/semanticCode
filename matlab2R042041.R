matlab2R042041 <- function (model = "bert_base_multilingual_cased",file="BERT-042041.csv",path="/home/semantic/semanticmatlab/")
{
source("/home/semantic/semanticmatlab/semanticCode/file2BERT2.R")
t <- file2BERT2(model,file,path) 
}
t2<-matlab2R042041()
