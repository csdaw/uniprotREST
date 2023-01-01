#' @export
fetch_stream <- function(req, format = "tsv", parse = TRUE, path = NULL, verbosity = NULL, dry_run = FALSE) {
  ## Argument checking
  assert_request(req)
  assert_choice(format, c("tsv"))
  assert_logical(parse, max.len = 1)
  if (!is.null(path)) assert_path_for_output(path)
  if (!is.null(verbosity)) {
    assert_integerish(verbosity, lower = 0, upper = 3, max.len = 1) # verbosity must be in 0:3
    quiet <- !as.logical(verbosity)
  } else {
    quiet <- FALSE
  }
  assert_logical(dry_run, max.len = 1)

  ## Perform dry-run if requested, otherwise...
  if (dry_run) return(httr2::req_dry_run(req, quiet = quiet))

  ## Perform request
  resp <- httr2::req_perform(req, path = path, verbosity = verbosity)

  if (!is.null(path) | !parse) {
    return(resp)
  } else if (parse) {
    switch(
      format,
      tsv = httr2::resp_body_string(resp)# resp_body_tsv(resp),
      # fasta = httr2::resp_body_string(resp) %>% str2fasta(),
      # json = httr2::resp_body_json(resp)
    )
  }
}
