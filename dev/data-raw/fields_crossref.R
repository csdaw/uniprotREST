library(dplyr)

# Get README describing available cross-reference databases via FTP
# (`txt` object is character vector where each value is a line in the text file)
txt <- httr2::request("https://ftp.uniprot.org/pub/databases/uniprot/current_release/knowledgebase/complete/docs/dbxref") %>%
  httr2::req_user_agent("uniprotREST https://github.com/csdaw/uniprotREST") %>%
  httr2::req_perform() %>%
  httr2::resp_body_string() %>%
  strsplit("\\n") %>%
  unlist()

# Get index of lines of interest and read into a data.frame

# field for API
cross_ref_fields <- utils::read.delim(
  text = txt[grep("^Abbrev: ", txt)],
  header = FALSE,
  col.names = "field"
) %>%
  mutate(field = tolower(gsub("Abbrev: ", "ref_", field)))

# name of database
cross_ref_fields$name <- utils::read.delim(
  text = txt[grep("^Abbrev: ", txt)],
  header = FALSE,
  col.names = "name"
) %>%
  mutate(name = gsub("Abbrev: ", "", name)) %>%
  pull(name)

# accession of database
cross_ref_fields$accession <- utils::read.delim(
  text = txt[grep("^AC    : ", txt)],
  header = FALSE,
  col.names = "accession"
) %>%
  mutate(accession = gsub("AC    : ", "", accession)) %>%
  pull(accession)

# description of database
cross_ref_fields$description <- utils::read.delim(
  text = txt[grep("^Name  : ", txt)],
  header = FALSE,
  col.names = "description"
) %>%
  mutate(description = gsub("Name  : ", "", description)) %>%
  pull(description)

# Save to tsv
write.table(
  cross_ref_fields,
  file = "dev/data-raw/fields_crossref.txt",
  sep = "\t",
  row.names = FALSE,
  col.names = TRUE,
  fileEncoding = "UTF8"
)
