#' Get current UniProt release number
#'
#' @description This function queries the UniProt REST API and gets the current
#' release number.
#'
#' @return Returns a `string` with the current UniProt release number in the
#' format `"20XX_0X"`.
#' @export
#'
#' @examples
#' # Useful for constructing file names e.g.
#' \dontrun{
#' paste0(cur_uniprot_release(), "_a_protein.fasta")
#' }
#'
current_release <- function() {
  # Construct and perform GET request for human actin
  httr2::request("https://rest.uniprot.org/uniprotkb/P60709") %>%
    httr2::req_user_agent("proteotools https://github.com/csdaw/proteotools") %>%
    httr2::req_perform() %>%
    httr2::resp_header("x-release-number") # Extract release number from response header
}
