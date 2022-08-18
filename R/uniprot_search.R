#' Search UniProt via REST API
#'
#' @description Search UniProt programmatically with \code{\link[httr2:httr2-package]{httr2}}.
#'   Essentially a wrapper around a HTTP \code{\link[httr2]{request}} on the UniProt
#'   REST API sent using \code{\link[httr2]{req_perform}}.
#'   See the
#'   [Retrieving entries via queries](https://www.uniprot.org/help/api_queries)
#'   page for more details on the API this function accesses.
#'
#' @param query `string`, the search query. See available
#'   [query fields](https://www.uniprot.org/help/query-fields) and help for
#'   [constructing queries](https://www.uniprot.org/help/text-search).
#' @param database `string`, the name of the database endpoint of interest.
#'   Choose from: `uniprotkb` (default), `uniref`, `uniparc`, `proteomes`, `taxonomy`,
#'   `keywords`, `citations`, `diseases`, `database`, `locations`, `unirule`, `arba`.
#'   See details below.
#' @param format `string`, output format for search results.
#'   Only `tsv` (default) implemented properly at the moment.
#' @param path Optional `string`, file path to save API response. Useful for
#'   large queries to avoid storing in memory.
#' @param fields Optional `character vector`. Columns to retrieve in the search
#'   results. Applies to the `json`, `tsv`, and `xlsx` formats only.
#'   See [here](https://www.uniprot.org/help/return_fields) for available
#'   UniProtKB fields.
#' @param isoform Optional `logical`. Whether or not to include isoforms in the
#'   search results. Only applicable if `database = "uniprotkb"`.
#' @param compressed `logical`, should results be returned gzipped? Default is
#'   `FALSE`.
#' @param method `string`, method for getting results. Either `stream` (default) or `paged`.
#'   Stream method should be used with small queries, and can fail at times. Paged
#'   method is a bit slower but more reliable and useful for large queries.
#' @param size `integer`, number of entries to output per 'page' of results.
#'   Probably don't change this from the default to avoid hammering UniProt's servers.
#' @param verbosity Optional `integer`, how much information to print? This is
#'   a wrapper around \code{\link[httr2]{req_verbose}} that uses an integer to
#'   control verbosity:
#'
#'   * 0: no output.
#'   * 1: show headers.
#'   * 2: show headers and bodies.
#'   * 3: show headers, bodies, and curl status messages.
#'
#' @param dry_run `logical`, default is `FALSE`. If `TRUE` print the HTTP
#'   request using \code{\link[httr2]{req_dry_run}} without actually sending
#'   anything to the UniProt server. Useful for debugging if you get an HTTP 400
#'   Bad Request error i.e. your `query` was not written correctly.
#'
#' @return If the request was successful (i.e. the request was successfully
#'   performed and a response with HTTP status code <400 was received), a data.frame
#'   (`tsv`) or a list (`json`) is returned; otherwise an error is thrown.
#'   Use the `path` argument to save to a file instead.
#'
#'   If `dry_run = TRUE`, then prints the HTTP request and returns,
#'   invisibly, a list containing information about the request without actually
#'   sending anything to the UniProt server.
#' @export
#'
#' @details
#'
#' To do: add more details on a number of things!
#'
#' @examples
#' # See https://www.uniprot.org/help/query-fields and
#' # https://www.uniprot.org/help/text-search for help constructing queries.
#'
#' \dontrun{
#'
#' # Simple UniProtKB search
#' resp <- search_uniprot(
#'   query = "Major capsid protein 723"
#' )
#'
#' # Extract the response body (JSON by default)
#' results <- httr2::resp_body_json(resp)
#'
#' # Can use paste to construct query string
#' resp <- search_uniprot(
#'   query = paste(c("taxonomy_name:candida albicans", "length<50"), collapse = " AND "),
#'   fields = c("accession", "protein_name", "length")
#'   format = "tsv"
#' )
#'
#' # Extract the response body (tsv this time)
#' results <- httr2::resp_body_string(resp) %>%
#'   read.delim(text = .)
#'
#' # To do: add more examples
#' }
#'
uniprot_search <- function(query,
                           database = c("uniprotkb", "uniref", "uniparc", "proteomes",
                                        "taxonomy", "keywords", "citations", "diseases",
                                        "database", "locations", "unirule", "arba"),
                           format = c("tsv", "json"),
                           path = NULL,
                           fields = NULL,
                           isoform = NULL,
                           compressed = NULL,
                           method = c("stream", "paged"),
                           size = 500L,
                           verbosity = NULL,
                           dry_run = FALSE) {
  ## Argument checking
  check_string(query) # query must be single string
  database <- match.arg.exact(database) # database must be exactly one of the options
  format <- match.arg.exact(format) # format must be exactly one of the options
  if (!is.null(path)) check_string(path) # path must be single string
  if (!is.null(fields))
    fields <- check_character(fields, convert = TRUE) # convert fields to single string if necessary
  if (!is.null(isoform)) check_logical(isoform) # isoform must be T or F
  if (!is.null(compressed)) check_logical(compressed) # compressed must be T or F
  method <- match.arg.exact(method) # method must be stream or paged
  check_numeric(size) # size must be a number (ideally an integer)
  if (!is.null(verbosity)) check_verbosity(verbosity) # verbosity must be in 0:3
  check_logical(dry_run) # dry_run must be T or F

  ## Access REST API
  # Endpoint to get results depends on method
  result_url <- switch(
    method,
    stream = paste0("https://rest.uniprot.org/", database, "/stream"),
    paged = paste0("https://rest.uniprot.org/", database, "/search")
  )

  get_req <- httr2::request(result_url) %>%
    httr2::req_user_agent("uniprotREST https://github.com/csdaw/uniprotREST") %>%
    httr2::req_url_query(
      `query` = query,
      `format` = format,
      `fields` = fields,
      `includeIsoform` = isoform,
      `compressed` = compressed
    ) %>%
    httr2::req_retry(max_tries = 5) %>%
    httr2::req_throttle(rate = 1 / 1)

  if (dry_run) {
    httr2::req_dry_run(get_req)
  } else if (method == "stream") {
    get_results_stream(
      req = get_req,
      format = format,
      path = path,
      fields = fields,
      isoform = isoform,
      compressed = compressed,
      verbosity = verbosity
    )
  } else if (method == "paged") {
    # n pages = n results / page size
    n_pages <- httr2::request(result_url) %>%
      httr2::req_user_agent("uniprotREST https://github.com/csdaw/uniprotREST") %>%
      httr2::req_url_query(
        `query` = query,
        `format` = format,
        `fields` = fields,
        `includeIsoform` = isoform,
        `compressed` = compressed,
        `size` = size
      ) %>%
      httr2::req_retry(max_tries = 5) %>%
      httr2::req_method("HEAD") %>%
      httr2::req_perform(verbosity = verbosity) %>%
      httr2::resp_header("x-total-results") %>%
      as.integer() %>%
      `/`(size) %>%
      ceiling()
    # To do: consider adding throttle here

    get_results_paged(
      req = get_req %>%
        httr2::req_url_query(`size` = size) %>%
        httr2::req_error(is_error = function(resp) FALSE),
      n_pages = n_pages,
      format = format,
      path = path,
      fields = fields,
      isoform = isoform,
      compressed = compressed,
      verbosity = verbosity
    )
  }
}
