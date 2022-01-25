
#library()
library(dplyr)
library(tokenizers)
library(tidyr)
library(tidyverse)
library(stringi)
library(purrr)
library(tibble)

# Function to make sure text is in right format
select_character_v_utf8 <- function(x){
  # Select all character variables
  x_characters <- dplyr::select_if(x, is.character)
  # This makes sure that all variables are UTF-8 coded, since BERT wants it that way
  x_characters <- tibble::as_tibble(purrr::map(x_characters, stringi::stri_encode, "", "UTF-8"))
}


# Function to get BERT embeddings.
ImportBERT <- function(x,
                       model = "bert_base_multilingual_cased",
                       layer_indexes_RBERT = 12,
                       batch_size = 2L,
                       token_index_filter = 1,
                       layer_index_filter = 12,
                       ...) {
  
  # Download/select pre-trained BERT model. This will go to an appropriate cache
  # directory by default.
  BERT_PRETRAINED_DIR <- RBERT::download_BERT_checkpoint(
    model = model
  )
  
  # Select all character variables and make them UTF-8 coded, since BERT wants it that way
  x_characters <- select_character_v_utf8(x)
  
  # Create lists
  BERT_feats <- list()
  output_vectors <- list()
  
  # Loop over character variables to tokenize sentences; create BERT-embeddings and Add them to list i=1 i=2 i=4
  for (i in 1:length(x_characters)) {
    # Extract BERT feature; help(extract_features) help(make_examples_simple)
    BERT_feats[[i]] <- RBERT::extract_features(
      examples = x_characters[[i]],
      ckpt_dir = BERT_PRETRAINED_DIR,
      layer_indexes = layer_indexes_RBERT,
      batch_size = batch_size ,
      ...
    )
    # Extract/Sort output vectors for all sentences...
    # Convenience functions for doing this extraction will be added to the RBERT package in the near future.
    output_vectors[[i]] <- BERT_feats[[i]]$output %>%
      dplyr::filter(token_index == token_index_filter, layer_index == layer_index_filter)
    # output_vectors[[i]] <- textEmbeddingAggregation(BERT_feats[[i]]$output, aggregation = aggregation) DOES NOT WORK; AGGREAGATE ALL Cells; see filter function above
  }
  # Gives the names in the list the same name as the orginal character variables
  names(output_vectors) <- names(x_characters)
  output_vectors
}


#data_file <- read.csv2("/Users/sverkersikstrom/Documents/Dokuments/Artiklar_in_progress/Semantic_spaces/BERT/solmini.csv", sep=",")
#data_file <- read.csv2("/Users/sverkersikstrom/Box Sync/Sverker_Katarina_Oscar/WordDiagnostics/CE märkning/Clinical report/2 Clinical data used for the clinical report/Analysis BERT/file2BERT.csv", sep=",")
data_file <- read.csv2("/Users/sverkersikstrom/Dropbox/semantic/file2BERT.csv", sep=",")
#data_file

data_file$dep_all

library(tidyverse)

#x <- c("text to try if it works", "this is another sentence")
## OK to send numeric variable to the function as the function will only take character variables
#y <- c(1, 2)
#xy_data <- tibble(x, y)
#wordembeddings <- ImportBERT(xy_data)

y2 <- c(1:dim(data_file))
#x2=c(data_file$dep_all)
x2=c(data_file$text)

xy_data2 <- tibble(x2, y2)
wordembeddings2 <- ImportBERT(xy_data2)
write.csv(wordembeddings2, "/Users/sverkersikstrom/Dropbox/semantic/BERT.csv")

#write.csv(wordembeddings2, "/Users/sverkersikstrom/Documents/Dokuments/Artiklar_in_progress/Semantic_spaces/BERT/solminiBERT.csv")
#write.csv(wordembeddings2, "/Users/sverkersikstrom/Box Sync/Sverker_Katarina_Oscar/WordDiagnostics/CE märkning/Clinical report/2 Clinical data used for the clinical report/Analysis BERT/BERT.csv")
