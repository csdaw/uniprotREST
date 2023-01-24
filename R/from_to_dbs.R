#' (Dataset) From/to databases for ID mapping
#'
#' @description This dataframe contains details of the databases that can be
#'   mapped from/to with [uniprot_map()]. See [from_to_rules] for the rules on
#'   which database identifiers can be mapped to what other databases.
#'
#' @details Columns:
#'   \tabular{ll}{
#'     **name** \tab `character`. Database name. \cr
#'     **from** \tab `character`. Is the database allowed to be mapped `from`? \cr
#'     **to** \tab `character`. Is the database allowed to be mapped `to`? \cr
#'     **url** \tab `character`. Database URL. \cr
#'     **formats_db** \tab `factor`. Relevant `formats` database, see [formats]
#'     for which download formats are available \cr
#'   }
#'
#' @seealso [from_to_rules]
#'
#' @source From/to pairs have been downloaded according to the "Valid from and
#'   to databases pairs" section on the UniProt
#'   [ID Mapping](https://www.uniprot.org/help/id_mapping) page.
"from_to_dbs"
