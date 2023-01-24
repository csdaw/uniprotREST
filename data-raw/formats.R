suppressPackageStartupMessages(library(dplyr))
suppressPackageStartupMessages(library(tidyr))

# Make dataframes for each function with available formats
df_single <- data.frame(
  database = c("uniprotkb", "uniref", "uniparc", "proteomes",
               "taxonomy", "keywords", "citations", "diseases",
               "database", "locations", "unirule", "arba"),
  format = c(
    "fasta tsv xlsx json xml rdf txt gff list", #uniprotkb
    "fasta tsv xlsx json xml rdf list", #uniref
    "fasta tsv xlsx json xml rdf", #uniparc
    "tsv xlsx json xml list", #proteomes
    "tsv xlsx json rdf list", #taxonomy
    "tsv xlsx json rdf list obo", #keywords
    "tsv xlsx json rdf txt list", #citations
    "tsv xlsx json rdf list obo", #diseases
    "json rdf", #database
    "tsv xlsx json rdf list obo", #locations
    "json list", #unirule, tsv and xlsx supposedly ok, but they don't return anything
    "json list" # arba
  )
)

df_search <- data.frame(
  database = c("uniprotkb", "uniref", "uniparc", "proteomes",
               "taxonomy", "keywords", "citations", "diseases",
               "database", "locations", "unirule", "arba"),
  format = c(
    "fasta tsv xlsx json xml txt gff list", #uniprotkb
    "fasta tsv xlsx json list", #uniref
    "fasta tsv xlsx json xml list", #uniparc
    "tsv xlsx json xml list", #proteomes
    "tsv xlsx json list", #taxonomy
    "tsv xlsx json list obo", #keywords
    "tsv xlsx json list", #citations
    "tsv xlsx json list obo", #diseases
    "json", #database
    "tsv xlsx json list obo", #locations
    "json list", #unirule, tsv and xlsx supposedly ok, but they don't return anything
    "json list" #arba
  )
)

df_map <- data.frame(
  database = c("uniprotkb", "uniref", "uniparc", "other"),
  format = c(
    "fasta tsv xlsx json xml rdf txt gff list", #to uniprotkb
    "fasta tsv xlsx json rdf list", #to uniref
    "fasta tsv xlsx json xml rdf list", #to uniparc
    "tsv xlsx json list" # to everything else?
  )
)

# Combine and convert to long format
formats <- bind_rows("single" = df_single, "search" = df_search, "map" = df_map,
                     .id = "func") %>%
  mutate(database = factor(database,
                           levels = c("uniprotkb", "uniref", "uniparc", "proteomes",
                                      "taxonomy", "keywords", "citations", "diseases",
                                      "database", "locations", "unirule", "arba", "other"))) %>%
  separate_rows(format, sep = " ") %>%
  arrange(func, database, format) %>%
  filter(format %in% c("tsv", "json", "fasta")) %>% # only tsv, json, and fasta for now...
  filter(!format == "json" | !func %in% c("search", "map")) %>%
  as.data.frame()

# Save to rda
usethis::use_data(formats, internal = FALSE, overwrite = TRUE)
