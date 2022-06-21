#' Get current available UniProt reference proteomes
#'
#' @description This function outputs a table showing which UniProt reference
#' proteomes are available to download from their
#' [FTP site](https://beta.uniprot.org/help/downloads). This table is updated
#' by UniProt every 8 weeks.
#'
#' @details Some proteomes in UniProt have been (manually and algorithmically)
#' selected as reference proteomes. They cover well-studied model organisms and
#' other organisms of interest for biomedical research and phylogeny. For all
#' of the `proteome_id` listed in this table you can download the following types
#' of files:
#'
#' - `*.gene2acc`, `*.fasta`, `*.dat`, `*.xml` (canonical sequences)
#' - `*_DNA.fasta` (only canonical sequences)
#' - `*.idmapping`
#'
#' For a subset of the `proteome_id` listed in this table you can also download:
#'
#' - `*_additional.fasta`, `*_additional.dat`, `*_additional.xml` (isoform sequences)
#' - `*_DNA.miss` (only canonical sequences)
#'
#' @return Returns a `data.frame` with the current species in UniProt with
#' available reference proteomes.
#'
#' @examples
#' # To do: example
#'
cur_uniprot_proteomes <- function() {
  # Get README describing available UniProt proteomes via FTP
  txt <- httr2::request("https://ftp.uniprot.org/pub/databases/uniprot/current_release/knowledgebase/reference_proteomes/README") %>%
    httr2::req_user_agent("proteotools https://github.com/csdaw/proteotools") %>%
    httr2::req_perform() %>%
    httr2::resp_body_string() %>%
    strsplit("\\n") %>%
    unlist()

  # Get index of table within the unstructured text of README
  # (Each row starts with a proteome number UPXXXXXXXXX)
  idx <- grep("^UP[0-9]{9}", txt)

  # Output table of available proteomes
  utils::read.delim(text = txt[idx], header = FALSE) %>%
    `colnames<-`(c(
      "proteome_id",
      "tax_id",
      "os_code",
      "superregnum",
      "n_entries_canonical",
      "n_entries_isoform",
      "n_entries_gene2acc",
      "species_name"
    ))
}
