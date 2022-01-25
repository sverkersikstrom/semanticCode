#library()
library(dplyr)
library(tokenizers)
library(tidyr)
library(tidyverse)
library(stringi)
library(purrr)
library(tibble)
library(tidyverse)
file2BERT2 <- function(model="bert_base_multilingual_cased",fname="BERT.csv",fpath="/Users/sverkersikstrom/Dropbox/semantic/")
{

 source(paste(fpath,"semanticCode/ImportBERT.R",sep= ""))
 source(paste(fpath,"semanticCode/ImportBERT.R",sep= ""))
  source(paste(fpath,"semanticCode/select_character_v_utf8.R",sep= ""))
  

file<-paste(fpath,"file2",fname,sep= "")
data_file <- read.csv2(file, sep=",")
y <- c(1:dim(data_file))
x=c(data_file$text)
xy_data <- tibble(x, y)
wordembeddings <- ImportBERT(xy_data,model)
file<-paste(fpath,fname,sep= "")
write.csv(wordembeddings, file)
}
