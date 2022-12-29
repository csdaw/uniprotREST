#' @export
uniprot_request <- function(url,
                            ...,
                            max_tries = 5,
                            rate = 1 / 1) {
  ## Argument checks
  # ensure request isn't malformed
  assert_url(url)
  assert_integerish(max_tries, max.len = 1)
  assert_numeric(rate, lower = 0, max.len = 1)

  ## Return request object
  httr2::request(url) %>%
    httr2::req_method("GET") %>%
    httr2::req_user_agent("uniprotREST https://github.com/csdaw/uniprotREST") %>%
    httr2::req_retry(max_tries = max_tries) %>%
    httr2::req_throttle(rate = rate) %>%
    httr2::req_url_query(...)
}
