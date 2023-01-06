#' @noRd
#' @export
uniprot_search <- function(query,
                           database = "uniprotkb",
                           format = "tsv",
                           path = NULL,
                           fields = NULL,
                           isoform = NULL,
                           method = "paged",
                           page_size = 500,
                           compressed = NULL,
                           verbosity = NULL,
                           dry_run = FALSE) {
  ## Argument checking
  assert_string(query)
  assert_database_format(func = "search", d = database, f = format)
  if (!is.null(path)) assert_path_for_output(path)
  if (!is.null(fields)) {
    assert_fields(fields, database = database)
    if (length(fields) > 1) fields <- paste(fields, collapse = ",")
  }
  if (!is.null(isoform)) assert_logical(isoform, max.len = 1)
  assert_choice(method, c("paged", "stream"))
  if (method == "stream") {
    page_size <- NULL
  } else if (method == "paged") {
    assert_integerish(page_size, lower = 0, max.len = 1)
  }
  if (!is.null(compressed)) assert_compressed(compressed, method, path)
  if (!is.null(verbosity)) assert_integerish(verbosity, lower = 0, upper = 3, max.len = 1) # verbosity must be in 0:3
  assert_logical(dry_run, max.len = 1)

  ## Construct URL for GET request (depends on method)
  req_url <- switch(
    method,
    stream = paste0("https://rest.uniprot.org/", database, "/stream"),
    paged = paste0("https://rest.uniprot.org/", database, "/search")
  )

  ## Define GET request with correct structure
  req <- uniprot_request(
    url = req_url,
    method = "GET",
    query = query,
    format = format,
    fields = fields,
    includeIsoform = isoform,
    size = page_size,
    compressed = compressed
  )

  ## Perform request via stream or pagination endpoint
  if (dry_run) {
    httr2::req_dry_run(req, quiet = if (is.null(verbosity)) FALSE else as.logical(verbosity))
  } else if (method == "stream") {
    fetch_stream(
      req = req,
      format = format,
      parse = TRUE,
      path = path,
      verbosity = verbosity
    )
  } else if (method == "paged") {
    # n pages = n results / page size
    n_results <- fetch_n_results(req, verbosity = verbosity)

    n_pages <- ceiling(n_results / page_size)

    fetch_paged(
      req = req,
      n_pages = n_pages,
      format = format,
      path = path,
      verbosity = verbosity
    )
  }
}
