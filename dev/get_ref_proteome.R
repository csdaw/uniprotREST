library(httr2)

req <- httr2::request("https://ftp.uniprot.org/pub/databases/uniprot/current_release/knowledgebase/reference_proteomes/") %>%
  httr2::req_url_path_append(paste("Eukaryota", "UP000005640", "UP000005640_9606.fasta.gz", sep = "/"))

req %>% req_dry_run()

resp <- httr2::req_perform(req, path = "./test.fasta")
