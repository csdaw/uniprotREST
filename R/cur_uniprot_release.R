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
  # First line of current release notes text has release number
  release <- readLines("https://ftp.uniprot.org/pub/databases/uniprot/current_release/relnotes.txt", n = 1L)

  # Get rid of extraneous letters and whitespace
  gsub("[^0-9_]", "", release)
}
