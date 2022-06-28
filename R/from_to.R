#' Available ID mapping databases
#'
#' @description A dataset containing all the databases available to use with
#' `uniprot_map()`.
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
