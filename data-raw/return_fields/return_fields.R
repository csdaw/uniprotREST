## Load libraries
library(readr)
library(here)
library(dplyr)
library(tidyr)

uniprot_kb <- read_tsv(here("data-raw/return_fields/fields_uniprotkb.tsv"), show_col_types = FALSE)

other <- read_tsv(here("data-raw/return_fields/fields_other.tsv"),
                  show_col_types = FALSE)

return_fields <- rbind(uniprot_kb, other) %>%
  mutate(database = factor(database, levels = c("uniprotkb", "uniref", "uniparc",
                                                "proteomes", "taxonomy", "keywords",
                                                "citations", "diseases", "database",
                                                "locations", "unirule", "arba"))) %>%
  as.data.frame()

## Optionally add some examples
# ccc <- list.files(here("dev/return_fields/examples/"), "*.tsv", full.names = TRUE)
#
# ddd <- sub("_.*", "", basename(ccc))
#
# examples <- lapply(ccc, read_tsv, col_types = cols(.default = "c"))
# names(examples) <- ddd
#
# examples
#
# eee <- purrr::map_dfr(examples, function(l) {
#   pivot_longer(l, everything(),
#                names_to = "label", values_to = "examples")
# },
# .id = "database"
# )

## Save table
# write_tsv(return_fields, here("data-raw/return_fields/return_fields.tsv"))
usethis::use_data(return_fields, overwrite = TRUE)
