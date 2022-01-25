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

