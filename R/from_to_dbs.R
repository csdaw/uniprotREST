#' UniProt ID mapping from/to databases
#'
#' @description This dataframe contains details of the databases that can be
#'   mapped from/to with `uniprot_map()`.
#'
#' @details Columns:
#'   \tabular{ll}{
#'     **name** \tab `character`. Database name. \cr
#'     **from** \tab `character`. Is the database allowed to be mapped `from`? \cr
#'     **to** \tab `character`. Is the database allowed to be mapped `to`? \cr
#'     **url** \tab `character`. Database URL.\cr
#'   }
#'
#' @seealso [from_to_rules] for rules of which database identifiers can be
#'   mapped to what other database.
#'
#' @source From/to pairs have been downloaded according to the "Valid from and
#'   to databases pairs" section on the UniProt
#'   [ID Mapping](https://www.uniprot.org/help/id_mapping) page.
"from_to_dbs"
