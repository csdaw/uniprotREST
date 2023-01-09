#' Get current UniProt release number
#'
#' @description This function queries the UniProt REST API and gets the current
#' release number.
#'
#' @param dry_run `logical`, default is `FALSE`. Used for debugging purposes.
#'   If `TRUE` print the HTTP
#'   request using \code{\link[httr2]{req_dry_run}} without actually sending
#'   anything to the UniProt server.
#'
#' @return Returns a `string` with the current UniProt release number in the
#' format `"DDDD_DD"` e.g. `2022_02`.
#' @export
#'
#' @examples
#' # Useful for constructing file names e.g.
#' \dontrun{
#' paste0(current_release(), "_a_protein.fasta")
#' }
#'
current_release <- function(dry_run = FALSE) {
  # Construct and perform GET request for UniProt release notes file
  req <- httr2::request("https://ftp.uniprot.org/pub/databases/uniprot/current_release/relnotes.txt") %>%
    httr2::req_user_agent("uniprotREST https://github.com/csdaw/uniprotREST")

  if (dry_run) httr2::req_dry_run(req)
  else httr2::req_perform(req) %>%
    httr2::resp_body_string() %>%
    regmatches(regexpr("\\d{4}_\\d?\\d", .))
}
