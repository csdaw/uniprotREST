#' Map from/to UniProt IDs
#'
#' @description To do: write description.
#'
#' @param ids `string`, comma-separated IDs to map.
#' @param from `string`, name of database which IDs are from. The default is
#'   `UniProtKB_AC-ID`. See \code{\link{from_to}} for a list of all possible
#'   database names.
#' @param to `string`, name of database to map to. The default is `UniProtKB`.
#'   See \code{\link{from_to}} for a list of all possible database names.
#' @param format `string`, output format for mapping results.
#'   Only `tsv` (default) implemented properly at the moment.
#' @param path Optional `string`, file path to save API response. Useful for
#'   large queries to avoid storing in memory.
#' @param fields Optional `character vector`. Columns to retrieve in the search
#'   results. Applies to the `tsv`, and `xlsx` formats only.
#' @param isoform Optional `logical`. Whether or not to include isoforms in the
#'   search results. Only applicable if `to` is `UniProtKB` or `UniProt-Swiss-Prot`.
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
#'   Bad Request error i.e. your `ids` or `fields` were not written correctly.
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
#' # To do: add some examples
#'
uniprot_map <- function(ids,
                        from = "UniProtKB_AC-ID",
                        to = "UniProtKB",
                        format = c("tsv", "fasta"),
                        path = NULL,
                        fields = NULL,
                        isoform = NULL,
                        compressed = NULL,
                        method = c("paged", "stream"),
                        size = 500L,
                        verbosity = NULL,
                        dry_run = FALSE) {
  ## Argument checking
  ids <- check_character(ids, convert = TRUE) # convert ids to single string if necessary
  check_from_to(from, to) # from/to pair must be okay
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

  ## Construct and send POST request
  rest_url <- "https://rest.uniprot.org/idmapping"

  # Construct POST request containing IDs
  # On failure retry 5 times
  post_req <- httr2::request(rest_url) %>%
    httr2::req_user_agent("uniprotREST https://github.com/csdaw/uniprotREST") %>%
    httr2::req_url_path_append("run") %>%
    httr2::req_body_form(
      `from` = from,
      `to` = to,
      `ids` = ids
    ) %>%
    httr2::req_retry(max_tries = 5) %>%
    httr2::req_throttle(rate = 1 / 1) # limit: 1 request every 1 second

  # Send POST request
  if (dry_run) return(httr2::req_dry_run(post_req)) else
    post_resp <- httr2::req_perform(post_req, verbosity = verbosity)

  # Extract and print job id (useful for manually looking up results)
  jobid <- httr2::resp_body_json(post_resp)$jobId
  message(paste("Job ID:", jobid))

  ## Construct and send status GET request
  # Check job status and automatically fetch results if job is complete
  # (i.e. HTML status 303 is returned)
  # If job not complete (i.e. HTML status 200 is returned)
  # send status request again, up to 50 times
  status_req <- httr2::request(rest_url) %>%
    httr2::req_user_agent("uniprotREST https://github.com/csdaw/uniprotREST") %>%
    httr2::req_url_path_append("status", jobid) %>%
    httr2::req_method("HEAD") %>%
    httr2::req_retry(is_transient = function(resp) {
      httr2::resp_status(resp) %in% c("429", "503") |
        (httr2::resp_status(resp) %in% c("200") & is.null(httr2::resp_header(resp, "x-total-results")))
    },
    max_tries = 50) %>%
    httr2::req_throttle(rate = 1 / 1) # limit: 1 request every 1 second

  status_resp <- httr2::req_perform(status_req, verbosity = verbosity)

  ## Get results (via stream or pagination)
  result_url <- switch(
    method,
    stream = gsub("results", "results/stream", status_resp$url),
    paged = status_resp$url
  )

  get_req <- httr2::request(result_url) %>%
    httr2::req_user_agent("uniprotREST https://github.com/csdaw/uniprotREST") %>%
    httr2::req_url_query(
      `format` = format,
      `fields` = fields,
      `includeIsoform` = isoform,
      `compressed` = compressed
    ) %>%
    httr2::req_retry(max_tries = 5) %>%
    httr2::req_throttle(rate = 1 / 1) # limit 1 request every 1 second

  if (method == "stream") {
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
    n_pages <- ceiling(as.integer(status_resp$headers$`x-total-results`) / size)

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
