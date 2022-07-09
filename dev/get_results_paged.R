get_results_paged <- function(url, n_pages, format, path, fields, isoform, compressed, size, verbosity) {
  get_req <- httr2::request(url) %>%
    httr2::req_user_agent("uniprotREST https://github.com/csdaw/uniprotREST") %>%
    httr2::req_url_query(
      `format` = format,
      `fields` = fields,
      `compressed` = compressed,
      `size` = size
    ) %>%
    httr2::req_retry(max_tries = 5) %>%
    httr2::req_error(is_error = function(resp) FALSE)

  if (!is.null(path)) {
    # Load results into memory then save to disk, page by page
    get_results_paged_disk(get_req, format = format, path = path, page_size = size, n_pages = n_pages, verbosity = verbosity)
  } else {
    # Load results into memory page by page and output single object
    get_results_paged_mem(get_req, format = format, page_size = size, n_pages = n_pages, verbosity = verbosity)
  }
}
