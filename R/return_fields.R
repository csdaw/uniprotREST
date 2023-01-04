#' (Dataset) UniProt return fields
#'
#' @description This dataframe contains the valid fields (i.e. columns) of
#'   data you can request from UniProt. The strings in the `field` column is what
#'   you'll use with the functions in this package.
#'   See **Examples** below for how to use this object.
#'
#' @details Columns:
#' \tabular{ll}{
#'   **database** \tab `character`. UniProt database to be queried. \cr
#'   **section** \tab `character`. Similar return fields are grouped together in sections. \cr
#'   **field** \tab `character`. The return field i.e. the string used to request the desired column of information. \cr
#'   **label** \tab `character`. Human readable column name that will be returned by the API.\cr
#' }
#'
#' @source UniProtKB return fields have been scraped from the
#'   [UniProtKB return fields](https://www.uniprot.org/help/return_fields) page.
#'   The return fields from other Uniprot databases have been determined by hand
#'   using Web Developer Tools (F12) to inspect the GET request made when
#'   searching the different database on the UniProt website.
#'
#' @seealso [from_to_dbs]
#'
#' @examples
#' # What UniProt databases are available to query?
#' levels(return_fields$database)
#'
#' # What fields are available for the `proteomes` database?
#' return_fields[return_fields$database == "proteomes", "field"]
"return_fields"
