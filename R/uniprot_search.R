#' Search UniProt
#'
#' @description Search Uniprot via REST API. By default it searches the supplied
#'   query against UniProtKB and returns a `data.frame` of matching proteins.
#'   It is a wrapper for
#'   [this](https://www.uniprot.org/help/api_queries) UniProt API
#'   endpoint.
#'
#' @param query `string`, the search query. See
#'   [this page](https://www.uniprot.org/help/text-search) for helping
#'   constructing search queries.
#' @param database See the **Databases** section below or `?uniprot_dbs` for all
#'   available databases.
#' @param format `string`, data format to fetch. Default is `"tsv"`.
#'   Can only be `"tsv"` at the moment.
#' @param path Optional `string`, file path to save the results, e.g.
#'   `"path/to/results.tsv"`.
#' @param fields Optional `character`, fields (i.e. columns) of data to get.
#'   The fields available depends on the database used, see [return_fields]
#'   for all available fields.
#' @param isoform Optional `logical`, should protein isoforms be included in the
#'   results? Not necessarily relevant for all formats and databases.
#' @param method `string`, download method to use. Either `"paged"` (default) or
#'   `"stream"`. Paged is more robust to connection issues and takes less
#'   memory. Stream may be faster, but uses more memory and is more sensitive
#'   to connection issues.
#' @param page_size Optional `integer`, how many entries per page to request?
#'   Only relevant if `method = "paged"`. It's best to leave this at `500`.
#' @param compressed Optional `logical`, should gzipped data be requested?
#'   Only relevant if `method = "stream"` and `path` is specified.
#' @inheritParams httr2::req_perform
#' @inheritParams uniprot_single
#'
#' @return By default, returns an object whose type depends on `format`:
#'
#'   - **`tsv`**: `data.frame`
#'
#'   If `path` is specified, saves the results to the file path indicated,
#'   and returns `NULL` invisibly. If `dry_run = TRUE`, returns a
#'   list containing information about the request, including the request
#'   `method`, `path`, and `headers`.
#'
#' @inheritSection uniprot_single Databases
#'
#' @export
#'
#' @examples
#' \dontrun{
#'   # Search for all human glycoproteins from SwissProt
#'   res <- uniprot_search(
#'     query = "(proteome:UP000005640) AND (keyword:KW-0325) AND (reviewed:true)",
#'     database = "uniprotkb",
#'     format = "tsv",
#'     fields = c("accession", "gene_primary", "feature_count")
#'   )
#'
#'   # Look at the resulting dataframe
#'   head(res)
#' }
uniprot_search <- function(query,
                           database = "uniprotkb",
                           format = "tsv",
                           path = NULL,
                           fields = NULL,
                           isoform = NULL,
                           method = "paged",
                           page_size = 500,
                           compressed = NULL,
                           verbosity = NULL,
                           dry_run = FALSE) {
  ## Argument checking
  assert_string(query)
  assert_database_format(func = "search", d = database, f = format)
  if (!is.null(path)) assert_path_for_output(path)
  if (!is.null(fields)) {
    assert_fields(fields, database = database)
    if (length(fields) > 1) fields <- paste(fields, collapse = ",")
  }
  if (!is.null(isoform)) assert_logical(isoform, max.len = 1)
  assert_choice(method, c("paged", "stream"))
  if (method == "stream") {
    page_size <- NULL
  } else if (method == "paged") {
    assert_integerish(page_size, lower = 0, max.len = 1)
  }
  if (!is.null(compressed)) assert_compressed(compressed, method, path)
  if (!is.null(verbosity)) assert_integerish(verbosity, lower = 0, upper = 3, max.len = 1) # verbosity must be in 0:3
  assert_logical(dry_run, max.len = 1)

  ## Construct URL for GET request (depends on method)
  req_url <- switch(
    method,
    stream = paste0("https://rest.uniprot.org/", database, "/stream"),
    paged = paste0("https://rest.uniprot.org/", database, "/search")
  )

  ## Define GET request with correct structure
  req <- uniprot_request(
    url = req_url,
    method = "GET",
    query = query,
    format = format,
    fields = fields,
    includeIsoform = isoform,
    size = page_size,
    compressed = compressed
  )

  ## Perform request via stream or pagination endpoint
  if (dry_run) {
    return(httr2::req_dry_run(req, quiet = if (is.null(verbosity)) FALSE else as.logical(verbosity)))
  } else if (method == "stream") {
    fetch_stream(
      req = req,
      format = format,
      parse = TRUE,
      path = path,
      verbosity = verbosity
    )
  } else if (method == "paged") {
    # n pages = n results / page size
    n_results <- fetch_n_results(req, verbosity = verbosity)

    n_pages <- ceiling(n_results / page_size)

    fetch_paged(
      req = req,
      n_pages = n_pages,
      format = format,
      path = path,
      verbosity = verbosity
    )
  }
}
