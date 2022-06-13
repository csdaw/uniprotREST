ref_proteome_formats <- list(
  "dat" = ".dat.gz",
  "fasta" = ".fasta.gz",
  "gene2acc" = ".gene2acc.gz",
  "idmapping" = ".idmapping.gz",
  "xml" = ".xml.gz",
  "DNA.fasta" = "_DNA.fasta.gz",
  "DNA.miss" = "_DNA.miss.gz",
  "additional.dat" = "_additional.dat.gz",
  "additional.fasta" = "_additional.fasta.gz",
  "additional.xml" = "_additional.xml.gz"
)

get_ref_proteome <- function(id, format, path = NULL) {
  # Need superregnum, taxon_id, and file format to construct url
  proteome_info <- search_uniprot(paste0("upid:", id), "proteomes",
                                  fields = paste("organism_id", "lineage", sep = ",")) %>%
    httr2::resp_body_string() %>%
    read.delim(text = .)

  superregnum <- sub("(\\w+).*", "\\1", proteome_info$Taxonomic.lineage)
  taxon_id <- proteome_info$Organism.Id

  file_ext <- ref_proteome_formats[[format]]

  # Construct name of file to download
  file_name <- paste0(id, "_", taxon_id, file_ext)

  # Construct FTP download request
  req <- httr2::request("https://ftp.uniprot.org/pub/databases/uniprot/current_release/knowledgebase/reference_proteomes/") %>%
    httr2::req_user_agent("proteotools https://github.com/csdaw/proteotools") %>%
    httr2::req_url_path_append(superregnum, id, file_name)

  # Download reference proteome
  httr2::req_perform(req, path = path)
}

get_ref_proteome("UP000005640", "fasta", "./test2.fasta.gz")
