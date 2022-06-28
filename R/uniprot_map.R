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
#'   To do: add available formats.
#' @param path Optional `string`. Path to save the body of the HTTP response.
#'   This is useful for large search results since it avoids storing the response
#'   in memory.
#' @param fields Optional `character vector`. Columns to retrieve in the search
#'   results. Applies to the `tsv`, and `xlsx` formats only.
#' @param isoform Optional `logical`. Whether or not to include isoforms in the
#'   search results. Only applicable if `to` is `UniProtKB` or `UniProt-Swiss-Prot`.
#' @param compressed `logical`, should results be returned gzipped? Default is
#'   `FALSE`.
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
#'   performed and a response with HTTP status code <400 was received), an HTTP
#'   response is returned; otherwise an error is thrown. Use the `path` argument
#'   to save the body of the response to a file.
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
                        format = "tsv",
                        path = NULL,
                        fields = NULL,
                        isoform = NULL,
                        compressed = FALSE,
                        verbosity = NULL,
                        dry_run = FALSE) {
  ## Argument checking
  if (!is.character(ids)) stop("`ids` must be a string or character vector")
  if (length(ids) > 1) ids <- paste(ids, collapse = ",")

  if (!is.null(fields)) {
    if (!is.character(fields)) stop("`fields` must be a string or character vector")
    if (length(fields) > 1) fields <- paste(fields, collapse = ",")

    # If `fields` is specified then need to check `to` to construct GET url properly
    database <- get_to_db(to)
  } else {
    database <- ""
  }

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
    httr2::req_retry(max_tries = 5)

  # Send POST request
  if (dry_run) return(httr2::req_dry_run(post_req)) else
    post_resp <- httr2::req_perform(post_req, verbosity = verbosity)

  # Extract and print job id (useful for manually looking up results)
  jobid <- httr2::resp_body_json(post_resp)$jobId
  message(paste("Job ID:", jobid))

  ## Construct and send GET request
  # Check job status and automatically fetch results if job is complete
  # (i.e. HTML status 303 is returned)
  # If job not complete (i.e. HTML status 200 is returned)
  # send status request another 5 times
  status_req <- httr2::request(rest_url) %>%
    httr2::req_user_agent("uniprotREST https://github.com/csdaw/uniprotREST") %>%
    httr2::req_url_path_append("status", jobid) %>%
    httr2::req_retry(is_transient = ~ httr2::resp_status(.x) %in% c("200", "429", "503"),
                     max_tries = 5) %>%
    httr2::req_options(followlocation = FALSE)

  result_url <- httr2::req_perform(status_req, verbosity = verbosity) %>%
    httr2::resp_header("location")

  # When job complete, follow result URL and download paginated results
  get_req <- httr2::request(rest_url) %>%
    httr2::req_user_agent("uniprotREST https://github.com/csdaw/uniprotREST") %>%
    httr2::req_url(result_url) %>%
    httr2::req_url_query(
      `format` = format,
      `fields` = fields,
      `isoform` = isoform,
      `compressed` = compressed
    ) %>%
    httr2::req_retry(max_tries = 5)

  # Send GET request
  httr2::req_perform(get_req, path = path, verbosity = verbosity)
}

get_to_db <- function(to) {
  lookup_df <- data.frame(
    to = c("UniProtKB", "UniProtKB-Swiss-Prot",
           "UniRef100", "UniRef90", "UniRef50",
           "UniParc"),
    db = c(rep("uniprotkb", 2),
           rep("uniref", 3),
           "uniparc")
  )

  if (!to %in% lookup_df$to) {
    return("")
  } else {
    lookup_df[lookup_df$to == to, "db"]
  }
}
