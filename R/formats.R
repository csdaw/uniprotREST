#' (Dataset) UniProt download formats
#'
#' @description This dataframe contains the available download file types i.e.
#'   values for `format` for each UniProt database.
#'   See **Examples** below for how to use this object.
#'
#' @details Columns:
#' \tabular{ll}{
#'   **func** \tab `character`. `uniprotREST` function to be used. \cr
#'   **database** \tab `character`. UniProt database to be queried. \cr
#'   **format** \tab `character`. The different formats available to download
#'   i.e. the string you'll use with the `uniprotREST` function. \cr
#' }
#'
#' @source UniProtKB download formats have been determined by hand by querying
#'   each REST API database with an unavailable format (usually `txt`) and
#'   determining the allowed formats from the resulting error response.
#'
#' @examples
#' # What UniProt databases are available to query?
#' levels(formats$database)
#'
#' # What formats are available for querying the `proteomes` database,
#' # using `uniprot_search()`
#' formats[formats$database == "proteomes" & formats$func == "search", "format"]
"formats"
