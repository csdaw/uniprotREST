uniprot_retrieve <- function(id,
                             database = c("uniprotkb", "uniref", "uniparc", "proteomes",
                                          "taxonomy", "keywords", "citations", "diseases",
                                          "database", "locations", "unirule", "arba"),
                             format = c("tsv", "fasta", "json"),
                             path = NULL,
                             fields = NULL,
                             isoform = NULL,
                             verbosity = NULL,
                             dry_run = FALSE) {
  ## Argument checking
  check_string(id) # id must be single string
  database <- match.arg.exact(database) # database must be exactly one of the options
  format <- match.arg.exact(format) # format must be exactly one of the options
  if (!is.null(path)) check_string(path) # path must be single string
  if (!is.null(fields))
    fields <- check_character(fields, convert = TRUE) # convert fields to single string if necessary
  if (!is.null(isoform)) check_logical(isoform) # isoform must be T or F
  if (!is.null(verbosity)) check_verbosity(verbosity) # verbosity must be in 0:3
  check_logical(dry_run) # dry_run must be T or F
}
