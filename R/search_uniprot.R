#' Search UniProt via REST API
#'
#' @description Search UniProt programmatically with \code{\link[httr2:httr2-package]{httr2}}.
#' Essentially a wrapper around a HTTP \code{\link[httr2]{request}} on the UniProt
#' REST API sent using \code{\link[httr2]{req_perform}}.
#' See the
#' [Retrieving entries via queries](https://www.uniprot.org/help/api_queries)
#' page for more details on the API this function accesses.
#'
#' @param query `string`, the search query. See available
#' [query fields](https://www.uniprot.org/help/query-fields) and help for
#' [constructing queries](https://www.uniprot.org/help/text-search).
#' @param database `string`, the name of the database endpoint of interest.
#' Choose from: `uniprotkb` (default), `uniref`, `uniparc`, `proteomes`, `taxonomy`,
#' `keywords`, `citations`, `diseases`, `database`, `locations`, `unirule`, `arba`.
#' See details below.
#' @param format `string`, desired output format for search results. Different
#' `database` provide different formats, though generally, `json` and `tsv`
#' are always available. Choose from: `json` (default), `xml`, `txt`, `list`, `tsv`,
#' `fasta`, `gff`, `obo`, `rdf`, `xlsx`.
#' @param path Optional `string`. Path to save the body of the HTTP response.
#' This is useful for large search results since it avoids storing the response
#' in memory.
#' @param fields Optional `character vector`. Columns to retrieve in the search
#' results. Applies to the `json`, `tsv`, and `xlsx` formats only.
#' See [here](https://www.uniprot.org/help/return_fields) for available
#' UniProtKB fields
#' @param isoform Optional `logical`. Whether or not to include isoforms in the
#' search results. Only applicable if `database = "uniprotkb"`.
#' @param compressed `logical`, should results be returned gzipped? Default is
#' `FALSE`.
#' @param size Optional `integer`. Specifies the maximum number of results to
#' return.
#' @param cursor Optional `string`. Specifies the cursor position in the entire
#' result set, from which returned results will begin. Cursors are used to allow
#' paging through results. Typically used together with the `size` argument.
#' @param dry_run `logical`, default is `FALSE`. If `TRUE` print the HTTP
#' request using \code{\link[httr2]{req_dry_run}} without actually sending
#' anything to the UniProt server. Useful for debugging if you get an HTTP 400
#' Bad Request error i.e. your `query` was not written correctly.
#'
#' @return If the request was successful (i.e. the request was successfully
#' performed and a response with HTTP status code <400 was received), an HTTP
#' response is returned; otherwise an error is thrown. Use the `path` argument
#' to save the body of the response to a file.
#'
#' If `dry_run = TRUE`, then prints the HTTP request and returns,
#' invisibly, a list containing information about the request without actually
#' sending anything to the UniProt server.
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
search_uniprot <- function(query,
                           database = c("uniprotkb", "uniref", "uniparc", "proteomes",
                                        "taxonomy", "keywords", "citations", "diseases",
                                        "database", "locations", "unirule", "arba"),
                           format = c("json", "xml", "txt", "list", "tsv", "fasta",
                                      "gff", "obo", "rdf", "xlsx"),
                           path = NULL,
                           fields = NULL,
                           isoform = NULL,
                           compressed = FALSE,
                           size = NULL,
                           cursor = NULL,
                           dry_run = FALSE) {
  ## Argument checking
  # Check query is single string
  if (!is.character(query) & length(query) == 1) stop("`query` must be single string.")

  # Check database and format arguments
  database <- match.arg.exact(database)
  format <- match.arg.exact(format)

  # Check path is a single string if present
  if (!is.null(path)) {
    if (!is.character(path) & length(path) == 1) stop("`path` must be a single string")
  }

  # Check fields and convert to single string if necessary
  if (!is.null(fields)) {
    if (!is.character(fields)) stop("`fields` must be a string or character vector")
    if (length(fields) > 1) fields <- paste(fields, collapse = ",")
  }

  # Check other arguments
  if (!is.null(isoform)) if (!is.logical(isoform)) stop("`isoform` must be TRUE or FALSE.")
  if (!is.logical(compressed)) stop("`compressed` must be TRUE or FALSE.")
  if (!is.null(size)) if (!is.integer(size)) stop("`size` must be an integer.")
  if (!is.null(cursor)) if (!is.character(cursor) & length(cursor) == 1) stop("`cursor` must be single string.")
  if (!is.logical(dry_run)) stop("`dry_run` must be TRUE or FALSE.")

  ## Access REST API
  rest_url <- paste0("https://rest.uniprot.org/", database, "/search")

  req <- httr2::request(rest_url) %>%
    httr2::req_user_agent("proteotools https://github.com/csdaw/proteotools") %>%
    httr2::req_url_query(
      `query` = query,
      `format` = format,
      `fields` = fields,
      `includeIsoform` = isoform,
      `compressed` = compressed,
      `size` = size,
      `cursor` = cursor
    )

  if (dry_run) httr2::req_dry_run(req) else
    httr2::req_perform(req, path = path)
}
