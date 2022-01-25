#Install these packages (might work without Rtools); install.packages("Rtools")
#Installing is only neccasssary the first time.
install.packages(c('devtools', 'dplyr', 'tokenizers', 'tidyr', 'tidyverse', 'stringi', 'purrr', 'tibble'))
library(devtools)
install.packages("tensorflow")
tensorflow::install_tensorflow(version = "1.13.1")

devtools::install_github("rstudio/reticulate")
devtools::install_github("jonathanbratt/RBERT")
#Select 1