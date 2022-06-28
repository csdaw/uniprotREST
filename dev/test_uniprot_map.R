library(magrittr)

test_ids <- c("ENSG00000048828")
test_from <- "Ensembl"
test_to <- "UniProtKB"

result <- uniprotREST::uniprot_map(
  ids = test_ids,
  from = test_from,
  to = test_to,
  fields = c("uniparc_id", "go_c")
)

result %>%
  httr2::resp_body_string() %>%
  read.delim(text = .)
