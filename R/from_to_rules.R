#' UniProt ID mapping from/to rules
#'
#' @description This list contains the valid from/to pairings that can be used
#'   with `uniprot_map()`.
#'
#'   `names(from_to_rules)` shows all the valid values for `from`.
#'
#'   `from_to_rules[["SGD"]]` shows all the valid `to` values for a certain
#'   `from`, for example in this case is `"SGD"`.
#'
#' @seealso [from_to_dbs] for details of each database available for ID mapping.
#'
#' @source From/to pairs have been downloaded according to the "Valid from and
#'    to databases pairs" section on the UniProt
#'   [ID Mapping](https://www.uniprot.org/help/id_mapping) page.
"from_to_rules"
