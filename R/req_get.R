#' @export
uniprot_request <- function(url,
                            method = "GET",
                            ...,
                            max_tries = 5,
                            rate = 1 / 1) {
  ## Argument checks
  # ensure request isn't malformed
  assert_url(url)
  assert_choice(method, c("GET", "POST", "HEAD"))
  assert_integerish(max_tries, max.len = 1)
  assert_numeric(rate, lower = 0, max.len = 1)

  ## Construct base request object
  req <- httr2::request(url) %>%
    httr2::req_user_agent("uniprotREST https://github.com/csdaw/uniprotREST") %>%
    httr2::req_retry(max_tries = max_tries) %>%
    httr2::req_throttle(rate = rate)

  ## Modify HTTP request based on method
  switch(
    method,
    GET = httr2::req_url_query(req, ...),
    POST = httr2::req_body_form(req, ...),
    HEAD = httr2::req_options(req, nobody = TRUE)
  )
}
