matlab2R <- function (model = "bert_base_multilingual_cased",file="BERT.csv",path="/Users/sverkersikstrom/Dropbox/semantic/"){
  source("file2BERT2.R")
  t <- file2BERT2(model,file,path)
}