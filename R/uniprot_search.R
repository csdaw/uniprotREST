uniprot_search <- function(query,
                           database = "uniprotkb",
                           format = "tsv",
                           path = NULL,
                           fields = NULL,
                           isoform = NULL,
                           compressed = NULL,
                           #method = c("paged", "stream"),
                           #size = 500L,
                           verbosity = NULL,
                           dry_run = FALSE) {
  ## Argument checking
  assert_string(query)
  assert_choice(database, c("uniprotkb", "uniref", "uniparc",
                            "proteomes", "taxonomy", "keywords",
                            "citations", "diseases",
                            "locations"))
  assert_choice(format, c("tsv"))
  if (!is.null(path)) assert_path_for_output(path)
  if (!is.null(fields)) {
    assert_fields(fields, database = database)
    if (length(fields) > 1)
      fields <- paste(fields, collapse = ",")
  }
  if (!is.null(isoform)) assert_logical(isoform, max.len = 1)
  if (!is.null(compressed)) assert_logical(compressed, max.len = 1)
  if (!is.null(verbosity)) assert_integerish(verbosity, lower = 0, upper = 3, max.len = 1) # verbosity must be in 0:3
  assert_logical(dry_run, max.len = 1)

  # define a get request

  # if method = paged fetch_paged else if method = stream fetch_stream
}
