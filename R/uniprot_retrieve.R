uniprot_retrieve <- function(id,
                             database = "uniprotkb",
                             format = "tsv",
                             path = NULL,
                             fields = NULL,
                             isoform = NULL,
                             verbosity = NULL,
                             dry_run = FALSE) {
  ## Argument checking
  assert_string(id)
  assert_choice(database, c("uniprotkb", "alphafold", "uniref",
                            "uniparc", "proteomes", "taxonomy",
                            "keywords", "citations", "diseases",
                            "database", "locations", "unirule",
                            "arba"))
  assert_choice(format, c("tsv"))
  if (!is.null(path)) assert_path_for_output(path)
  if (!is.null(fields)) {
    if (check_character(fields, min.len = 2)) fields <- paste(fields, collapse = ",")
    assert_string(fields)
  }
  if (!is.null(isoform)) assert_logical(isoform, max.len = 1)
  if (!is.null(verbosity)) assert_integerish(verbosity, lower = 0, upper = 3, max.len = 1) # verbosity must be in 0:3
  assert_logical(dry_run, max.len = 1)
}
