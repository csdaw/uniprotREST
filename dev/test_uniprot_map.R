library(magrittr)
library(here)

input <- readLines(here("dev/map-id-test-input.txt"))[-4]

debugonce(uniprotREST::uniprot_map)
test <- uniprotREST::uniprot_map(
  ids = input,
  fields = c("accession", "length", "reviewed"),
  size = 25,
  verbosity = 1
)
