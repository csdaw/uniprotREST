get_results_stream <- function(req, format, path, fields, isoform, compressed, verbosity) {
  if (!is.null(path)) {
    # Stream results to disk
    invisible(httr2::req_perform(req, path = path, verbosity = verbosity))
  } else {
    # Stream results to memory and parse depending on format
    resp <- httr2::req_perform(req, verbosity = verbosity)

    switch(
      format,
      tsv = resp_body_tsv(resp),
      fasta = httr2::resp_body_string(resp) %>% str2fasta(),
      json = httr2::resp_body_json(resp),
      stop("`format` must be one of: tsv, fasta, json")
    )
  }
}
