#' @export
uniprot_get <- function(url,
                        ...,
                        max_tries = 5,
                        rate = 1 / 1,
                        path = NULL,
                        verbosity = NULL,
                        dry_run = FALSE) {
  assert_url(url)
  assert_integerish(max_tries, max.len = 1)
  assert_numeric(rate, lower = 0, max.len = 1)
  if (!is.null(verbosity)) assert_integerish(verbosity, lower = 0, upper = 3, max.len = 1)
  assert_logical(dry_run, max.len = 1)

  get_req <- httr2::request(url) %>%
    httr2::req_method("GET") %>%
    httr2::req_user_agent("uniprotREST https://github.com/csdaw/uniprotREST") %>%
    httr2::req_retry(max_tries = max_tries) %>%
    httr2::req_throttle(rate = rate) %>%
    httr2::req_url_query(...)

  if (dry_run) {
    httr2::req_dry_run(get_req, quiet = ifelse(is.null(verbosity), TRUE, FALSE))
  } else {
    httr2::req_perform(get_req, path = path, verbosity = verbosity)
  }
}
