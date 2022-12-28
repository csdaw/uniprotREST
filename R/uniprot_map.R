uniprot_map <- function(ids,
                        # from = "UniProtKB_AC-ID",
                        # to = "UniProtKB",
                        format = "tsv",
                        path = NULL,
                        fields = NULL,
                        isoform = NULL,
                        compressed = NULL,
                        # method = c("paged", "stream"),
                        # size = 500L,
                        verbosity = NULL,
                        dry_run = FALSE) {
  ## Argument checking
  if (!is.null(ids)) {
    if (check_character(ids, min.len = 2)) fields <- paste(ids, collapse = ",")
    assert_string(ids)
  }
  # assert_from_to
  assert_choice(format, c("tsv"))
  if (!is.null(path)) assert_path_for_output(path)
  # check fields are valid, need to check from to first and define database from that
  if (!is.null(isoform)) assert_logical(isoform, max.len = 1)
  if (!is.null(compressed)) assert_logical(compressed, max.len = 1)
  if (!is.null(verbosity)) assert_integerish(verbosity, lower = 0, upper = 3, max.len = 1)
  assert_logical(dry_run, max.len = 1)
}
