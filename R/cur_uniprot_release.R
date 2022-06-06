#' Get current UniProt release number
#'
#' @return Returns a string with the current UniProt release number in the
#' format `"20XX_0X"`.
#' @export
#'
#' @examples
#' # Useful for naming files e.g.
#' \dontrun{
#'   Biostrings::writeXStringSet(
#'     x = Biostrings::AAStringSet("AAA"),
#'     filepath = paste0(cur_uniprot_release, "_a_protein.fasta")
#'   )
#' }
#'
cur_uniprot_release <- function() {
  # Construct GET request for human actin
  req <- httr2::request("https://rest.uniprot.org/uniprotkb/P60709")

  # Perform GET request
  resp <- httr2::req_perform(req)

  # Extract release number from HTTP response header
  resp %>% httr2::resp_header("x-release-number")
}
