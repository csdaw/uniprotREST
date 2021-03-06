get_results_stream <- function(req, format, path, fields, isoform, compressed, verbosity) {
  if (!is.null(path)) {
    # Stream results to disk
    httr2::req_perform(req, path = path, verbosity = verbosity)
  } else {
    # Stream results to memory and parse depending on format
    resp <- httr2::req_perform(req, verbosity = verbosity)

    switch(
      format,
      tsv = resp_body_tsv(resp),
      stop("Only format = `tsv` implemented currently")
    )
  }
}
