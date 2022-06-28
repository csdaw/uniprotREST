library(magrittr)

test_id <- "P04637"
test_db <- "uniprotkb"
test_format <- "rdf"

resp <- uniprot_retrieve(
  id = test_id,
  database = test_db,
  format = test_format,
  include = "no"
)

result <- resp %>%
  httr2::resp_body_xml()

result <- resp %>%
  httr2::resp_body_string() %>%
  Biostrings::readAAStringSet()
result <- resp %>%
  httr2::resp_body_string() %>%
  read.delim(text = .)
result <- httr2::resp_body_json(resp)
