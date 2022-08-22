#' Available ID mapping databases
#'
#' @description A dataset containing all the databases available to use with
#'   `uniprot_map()`. Generally, any `from` can be mapped `to = "UniProtKB"` or
#'   `"UniProtKB-Swiss-Prot"` and `from = "UniProtKB_AC-ID"` can be mapped to any
#'   `to`.
#'
#'   See the `from_to` object for a list of allowed `from`-`to` mappings.
#'   Alternatively use the function \code{\link{check_from_to}} to check if
#'   the `from` and `to` pair is valid.
#'
#' @details Columns:
#' \tabular{ll}{
#'   **name** \tab `character`. Database name. \cr
#'   **from** \tab `logical`. Can the IDs be mapped from? \cr
#'   **to** \tab `logical`. Can the IDs be mapped to? \cr
#'   **url** \tab `character`. URLs for each database (replace %id with a given ID) \cr
#' }
#'
#' @source [UniProt ID mapping](https://www.uniprot.org/help/id_mapping)
#'
"from_to"
