get_results_stream <- function(url, format, path, fields, isoform, compressed, size, verbosity) {
  get_req <- httr2::request(url) %>%
    httr2::req_user_agent("uniprotREST https://github.com/csdaw/uniprotREST") %>%
    httr2::req_url_query(
      `format` = format,
      `fields` = fields,
      `compressed` = compressed,
      `size` = size
    ) %>%
    httr2::req_retry(max_tries = 5)

  if (!is.null(path)) {
    # Stream results to disk
    httr2::req_perform(get_req, path = path, verbosity = verbosity)
  } else {
    # Stream results to memory and parse depending on format
    resp <- httr2::req_perform(get_req, verbosity = verbosity)

    switch(
      format,
      tsv = resp_body_tsv(resp),
      stop("Only format = `tsv` implemented currently")
    )
  }
}
