matlab2R027025 <- function (model = "bert_base_multilingual_cased",file="BERT-027025.csv",path="/Users/sverkersikstrom/Dropbox/semantic/")
  {
  source("/Users/sverkersikstrom/Dropbox/semantic/semanticCode/file2BERT2.R")
  t <- file2BERT2(model,file,path) 
}
t2<-matlab2R027025() 