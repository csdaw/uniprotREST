#' Retrieve individual UniProt entry
#'
#' @description To do: describe.
#'
#' @param id `string`, the entry's unique identifier.
#' @param database `string`, the name of the database endpoint of interest.
#'   Choose from: `uniprotkb` (default), `uniref`, `uniparc`, `proteomes`, `taxonomy`,
#'   `keywords`, `citations`, `diseases`, `database`, `locations`, `unirule`, `arba`.
#'   See details below.
#' @param format `string`, desired output format for search results. Different
#'   `database` provide different formats, though generally, `json` and `tsv`
#'   are always available. Choose from: `json` (default), `xml`, `txt`, `list`, `tsv`,
#'   `fasta`, `gff`, `obo`, `rdf`, `xlsx`.
#' @param path Optional `string`. Path to save the body of the HTTP response.
#'   This is useful for large search results since it avoids storing the response
#'   in memory.
#' @param fields Optional `character vector`. Columns to retrieve in the search
#'   results. Applies to the `json`, `tsv`, and `xlsx` formats only.
#'   See [here](https://www.uniprot.org/help/return_fields) for available
#'   UniProtKB fields
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
#' # To do: add examples
#'
uniprot_retrieve <- function(id,
                             database = c("uniprotkb", "uniref", "uniparc", "proteomes",
                                          "taxonomy", "keywords", "citations", "diseases",
                                          "database", "locations", "unirule", "arba"),
                             format = "tsv",
                             path = NULL,
                             fields = NULL,
                             isoform = NULL,
                             verbosity = NULL,
                             dry_run = FALSE) {
  ## Argument checking
  # Check query is single string
  if (!is.character(id) & length(id) == 1) stop("`id` must be single string.")

  # Check database and format arguments
  database <- match.arg.exact(database)

  # Check fields and convert to single string if necessary
  if (!is.null(fields)) {
    if (!is.character(fields)) stop("`fields` must be a string or character vector")
    if (length(fields) > 1) fields <- paste(fields, collapse = ",")
  }

  ## Access REST API
  rest_url <- "https://rest.uniprot.org"

  req <- httr2::request(rest_url) %>%
    httr2::req_user_agent("uniprotREST https://github.com/csdaw/uniprotREST") %>%
    httr2::req_url_path_append(database, paste(id, format, sep = ".")) %>%
    httr2::req_url_query(
      `fields` = fields,
      `includeIsoform` = isoform
    ) %>%
    httr2::req_retry(max_tries = 5)

  if (!is.null(path)) {
    if (dry_run) httr2::req_dry_run(req) else
      httr2::req_perform(req, path = path, verbosity = verbosity)
  } else {
    resp <- httr2::req_perform(req, verbosity = verbosity)

    switch(
      format,
      tsv = resp_body_tsv(resp),
      json = httr2::resp_body_json(resp), # To do: add ... ?
      stop("Only format = `tsv` or `json` implemented currently")
    )
  }
}
