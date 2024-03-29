#' Retrieve individual UniProt entry
#'
#' @description To do: describe.
#'
#' @param id `string`, the entry's unique identifier.
#' @param database `string`, the name of the database endpoint of interest.
#'   Choose from: `uniprotkb` (default), `uniref`, `uniparc`, `proteomes`, `taxonomy`,
#'   `keywords`, `citations`, `diseases`, `database`, `locations`, `unirule`, `arba`.
#'   See details below.
#' @param format `string`, output format for search results.
#'   Only `tsv` (default) or `json` implemented at the moment.
#' @param path Optional `string`, file path to save API response. Useful for
#'   large queries to avoid storing in memory.
#' @param fields Optional `character vector`. Columns to retrieve in the search
#'   results. Applies to the `json`, `tsv`, and `xlsx` formats only.
#'   See [here](https://www.uniprot.org/help/return_fields) for available
#'   UniProtKB fields.
#' @param isoform Optional `logical`. Whether or not to include isoforms in the
#'   search results. Only applicable if `database = "uniprotkb"`.
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
#' @examples
#' # To do: add examples
#'
uniprot_retrieve <- function(id,
                             database = c("uniprotkb", "uniref", "uniparc", "proteomes",
                                          "taxonomy", "keywords", "citations", "diseases",
                                          "database", "locations", "unirule", "arba"),
                             format = c("tsv", "fasta", "json"),
                             path = NULL,
                             fields = NULL,
                             isoform = NULL,
                             verbosity = NULL,
                             dry_run = FALSE) {
  ## Argument checking
  check_string(id) # id must be single string
  database <- match.arg.exact(database) # database must be exactly one of the options
  format <- match.arg.exact(format) # format must be exactly one of the options
  if (!is.null(path)) check_string(path) # path must be single string
  if (!is.null(fields))
    fields <- check_character(fields, convert = TRUE) # convert fields to single string if necessary
  if (!is.null(isoform)) check_logical(isoform) # isoform must be T or F
  if (!is.null(verbosity)) check_verbosity(verbosity) # verbosity must be in 0:3
  check_logical(dry_run) # dry_run must be T or F

  ## Access REST API
  rest_url <- "https://rest.uniprot.org"

  get_req <- httr2::request(rest_url) %>%
    httr2::req_user_agent("uniprotREST https://github.com/csdaw/uniprotREST") %>%
    httr2::req_url_path_append(database, paste(id, format, sep = ".")) %>%
    httr2::req_url_query(
      `fields` = fields,
      `includeIsoform` = isoform
    ) %>%
    httr2::req_retry(max_tries = 5) %>%
    httr2::req_throttle(rate = 1 / 1) # limit: 1 request every 1 second

  if (dry_run) {
    return(httr2::req_dry_run(get_req))
  } else {
    if (!is.null(path)) {
      httr2::req_perform(get_req, path = path, verbosity = verbosity)
    } else {
      get_resp <- httr2::req_perform(get_req, verbosity = verbosity)

      switch(
        format,
        tsv = resp_body_tsv(get_resp),
        fasta = httr2::resp_body_string(get_resp) %>% str2fasta(),
        json = httr2::resp_body_json(get_resp),
        stop("Only format = `tsv` or `json` implemented currently")
      )
    }
  }
}
