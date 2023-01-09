library(magrittr)
library(checkmate)
library(httr2)
source("dev/refactor/uniprot_get.R")
source("R/checks.R")

rest_url <- "https://rest.uniprot.org/uniprotkb/P05067.tsv"

get_resp <- uniprot_get(
  url = rest_url,
  fields = "accession,protein_name",
  isoform = TRUE,
  verbosity = 1,
  dry_run = FALSE
)

aaa <- resp_body_string(get_resp)

