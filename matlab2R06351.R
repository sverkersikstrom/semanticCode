matlab2R06351 <- function (model = "bert_base_multilingual_cased",file="BERT-06351.csv",path="/Users/sverkersikstrom/Dropbox/semantic/")
{
source("/Users/sverkersikstrom/Dropbox/semantic/semanticCode/file2BERT2.R")
t <- file2BERT2(model,file,path) 
}
t2<-matlab2R06351()
