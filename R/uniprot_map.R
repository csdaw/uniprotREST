uniprot_map <- function(ids,
                        from = "UniProtKB_AC-ID",
                        to = "UniProtKB",
                        format = c("tsv", "fasta", "json"),
                        path = NULL,
                        fields = NULL,
                        isoform = NULL,
                        compressed = NULL,
                        method = c("paged", "stream"),
                        size = 500L,
                        verbosity = NULL,
                        dry_run = FALSE) {
  ## Argument checking
  ids <- check_character(ids, convert = TRUE) # convert ids to single string if necessary
  check_from_to(from, to) # from/to pair must be okay
  format <- match.arg.exact(format) # format must be exactly one of the options
  if (!is.null(path)) check_string(path) # path must be single string
  if (!is.null(fields))
    fields <- check_character(fields, convert = TRUE) # convert fields to single string if necessary
  if (!is.null(isoform)) check_logical(isoform) # isoform must be T or F
  if (!is.null(compressed)) check_logical(compressed) # compressed must be T or F
  method <- match.arg.exact(method) # method must be stream or paged
  check_numeric(size) # size must be a number (ideally an integer)
  if (!is.null(verbosity)) check_verbosity(verbosity) # verbosity must be in 0:3
  check_logical(dry_run) # dry_run must be T or F
}
