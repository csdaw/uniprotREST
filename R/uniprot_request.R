#' Create UniProt HTTP request
#'
#' @description This function creates a request object for the UniProt REST API.
#'   You likely won't use this function directly, but rather one of the
#'   wrapper functions: [uniprot_map()], [uniprot_search()], or [uniprot_single()].
#'
#' @param url `string`, the URL to make the request.
#' @param method `string`, the HTTP request method. One of `"GET"` (default),
#'   `"POST"`, or `"HEAD"`.
#' @param ... Name-value pairs that provide query parameters. Each value must be
#'   either a length-1 atomic vector (which is automatically escaped) or `NULL`
#'   (which is silently dropped).
#' @param max_tries `integer`, the number of maximum attempts to perform the
#'   HTTP request. Default is `5`.
#' @param rate `numeric`, the maximum number of requests per second. Default is
#' `1 / 1` i.e. 1 request per 1 second.
#'
#' @return Returns an `httr2_request` object.
#' @export
#'
#' @examples
#' # Construct a request for the accession and
#' # gene name for human Cytochrome C
#' uniprot_request(
#'   url = "https://rest.uniprot.org/uniprotkb/P99999",
#'   fields = "accession,gene_primary",
#'   format = "tsv"
#' )
#'
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
