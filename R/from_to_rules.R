#' (Dataset) From/to rules for ID mapping
#'
#' @description This list contains the valid from/to pairings that can be used
#'   with `uniprot_map()`. See **Examples** below for how to use this object.
#'
#' @seealso [from_to_dbs] for details of each database available for ID mapping.
#'
#' @source From/to pairs have been downloaded according to the "Valid from and
#'    to databases pairs" section on the UniProt
#'   [ID Mapping](https://www.uniprot.org/help/id_mapping) page.
#' @examples
#' # Show valid `from` values
#' names(from_to_rules)
#'
#' # Show valid `to` values for a given `from` e.g. SGD
#' from_to_rules[["SGD"]]
"from_to_rules"
