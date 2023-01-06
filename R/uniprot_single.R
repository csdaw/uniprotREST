#' Download a single UniProt entry
#'
#' @description Get a single entry from UniProt.
#'   By default it fetches the webpage using `format = "json"` and outputs a
#'   list of information, but different formats are available from different
#'   databases. It is a wrapper for
#'   [this](https://www.uniprot.org/help/api_retrieve_entries) UniProt API
#'   endpoint.
#'
#' @param id `string`, entry ID. Form depends on database e.g. `"P12345"` for
#'   UniProtKB, `"UPI0000128BBF"` for UniParc, etc.
#' @param database `string`, database to look up. Default is `"uniprotkb"`.
#'   See the **Databases** section below or `?uniprot_dbs` for all
#'   available databases.
#' @param format `string`, data format to fetch. Default is `"json"`.
#'   Can only be `"tsv"` or `"json"` at the moment.
#' @param path Optional `string`, file path to save the results, e.g.
#'   `"path/to/results.tsv"`.
#' @param fields Optional `character`, fields (i.e. columns) of data to get.
#'   The fields available depends on the database used, see [return_fields]
#'   for all available fields.
#' @param isoform Optional `logical`, should protein isoforms be included in the
#'   results? Not necessarily relevant for all formats and databases.
#' @param dry_run `logical`, perform request with [httr2::req_dry_run()]?
#'   Default is `FALSE`.
#' @inheritParams fetch_stream
#' @inheritParams uniprot_request
#'
#' @return By default, returns an object whose type depends on `format`:
#'
#'   - **`tsv`**: `data.frame`
#'   - **`json`**: `list`
#'
#'   If `path` is specified, saves the results to the file path indicated,
#'   and returns `NULL` invisibly. If `dry_run = TRUE`, returns a
#'   list containing information about the request, including the request
#'   `method`, `path`, and `headers`.
#'
#' @section Databases:
#'
#'   The following databases are available to query:
#'
#'   - **`uniprotkb`**: [UniProt Knowledge Base](https://www.uniprot.org/help/uniprotkb)
#'   - **`uniref`**: [UniProt Reference Clusters](https://www.uniprot.org/help/uniref)
#'   - **`uniparc`**: [UniProt Archive](https://www.uniprot.org/help/uniparc)
#'   - **`proteomes`**: [Reference proteomes](https://www.uniprot.org/help/reference_proteome)
#'   - **`taxonomy`**: [Taxonomy](https://www.uniprot.org/help/taxonomy)
#'   - **`keywords`**: [Keywords](https://www.uniprot.org/help/keywords)
#'   - **`citations`**: [Literature references](https://www.uniprot.org/help/literature_references)
#'   - **`diseases`**: [Disease queries](https://www.uniprot.org/help/disease_query)
#'   - **`database`**: [Cross references](https://www.uniprot.org/help/cross_references_section)
#'   - **`locations`**: [Subcellular location](https://www.uniprot.org/help/subcellular_location)
#'   - **`unirule`**: [UniRule](https://www.uniprot.org/help/unirule)
#'   - **`arba`**: [ARBA](https://www.uniprot.org/help/automatic_annotation)
#'     (Association-Rule-Based Annotator)
#'
#' @export
#'
#' @examples
#' \dontrun{
#'   # Download the entry for human Cytochrome C
#'   res <- uniprot_single("P99999", format = "json")
#'
#'   # Look at the structure of the resulting list
#'   str(res, max.level = 1)
#' }
uniprot_single <- function(id,
                           database = "uniprotkb",
                           format = "json",
                           path = NULL,
                           fields = NULL,
                           isoform = NULL,
                           verbosity = NULL,
                           max_tries = 5,
                           rate = 1 / 1,
                           dry_run = FALSE) {
  ## Argument checking
  assert_string(id)
  assert_database_format(func = "single", d = database, f = format)
  if (!is.null(path)) assert_path_for_output(path)
  if (!is.null(fields)) {
    assert_fields(fields, database = database)
    if (length(fields) > 1)
      fields <- paste(fields, collapse = ",")
  }
  if (!is.null(isoform)) assert_logical(isoform, max.len = 1)
  if (!is.null(verbosity)) assert_integerish(verbosity, lower = 0, upper = 3, max.len = 1) # verbosity must be in 0:3

  ## Define GET request with correct structure
  req <- uniprot_request(
    url = "https://rest.uniprot.org",
    fields = fields,
    includeIsoform = isoform,
    max_tries = max_tries,
    rate = rate
  ) %>%
    httr2::req_url_path_append(database, paste(id, format, sep = "."))

  ## Perform request via stream endpoint
  if (dry_run) {
    httr2::req_dry_run(req, quiet = if (is.null(verbosity)) FALSE else as.logical(verbosity))
  } else {
    fetch_stream(
      req,
      format = format,
      parse = TRUE,
      path = path,
      verbosity = verbosity
    )
  }
}
