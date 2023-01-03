#' @noRd
#' @export
uniprot_single <- function(id,
                           database = "uniprotkb",
                           format = "tsv",
                           path = NULL,
                           fields = NULL,
                           isoform = NULL,
                           verbosity = NULL,
                           max_tries = 5,
                           rate = 1 / 1,
                           dry_run = FALSE) {
  ## Argument checking
  assert_string(id)
  assert_choice(database, c("uniprotkb", "uniref", "uniparc",
                            "proteomes", "taxonomy", "keywords",
                            "citations", "diseases", "locations"))
  assert_choice(format, c("tsv"))
  if (!is.null(path)) assert_path_for_output(path)
  if (!is.null(fields)) {
    assert_fields(fields, database = database)
    if (length(fields) > 1)
      fields <- paste(fields, collapse = ",")
  }
  if (!is.null(isoform)) assert_logical(isoform, max.len = 1)
  if (!is.null(verbosity)) assert_integerish(verbosity, lower = 0, upper = 3, max.len = 1) # verbosity must be in 0:3

  ## Define GET request with correct structure
  req <- uniprot_request(
    url = "https://rest.uniprot.org",
    fields = fields,
    includeIsoform = isoform,
    max_tries = max_tries,
    rate = rate
  ) %>%
    httr2::req_url_path_append(database, paste(id, format, sep = "."))

  if (dry_run) {
    httr2::req_dry_run(req, quiet = if (is.null(verbosity)) FALSE else as.logical(verbosity))
  } else {
    fetch_stream(
      req,
      format = format,
      parse = TRUE,
      path = path,
      verbosity = verbosity
    )
  }
}
