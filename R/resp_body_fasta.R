#' Extract FASTA data from response body
#'
#' @description This function gets FASTA data from an `httr2_response`
#'   and either saves it to a file or parses it in memory into a
#'   [Biostrings::AAStringSet] or `named character` vector.
#'
#' @inheritParams resp_body_tsv
#' @inheritParams httr2::resp_body_raw
#'
#' @return By default, returns a [Biostrings::AAStringSet] object. If the
#'   `Biostrings` package is not installed, returns a `named character` vector.
#'   If `con` is not NULL, returns nothing and saves the FASTA sequences to the
#'   file specified by `con`.
#' @export
#'
#' @examples
#' resp <- structure(
#'   list(method = "GET", url = "https://example.com",
#'        body = charToRaw(">Protein1\nAAA\n>Protein2\nCCC")),
#'   class = "httr2_response"
#' )
#'
#' resp_body_fasta(resp)
#'
resp_body_fasta <- function(resp, con = NULL, encoding = NULL) {
  check_response(resp)
  # check_con?
  if (!is.null(encoding))
    check_string(encoding)
  else
    encoding <- httr2::resp_encoding(resp)

  if (length(resp$body) == 0) {
    stop("Can not retrieve empty body")
  }

  body <- resp$body %>%
    readBin(character()) %>%
    iconv(from = encoding, to = "UTF-8")

  if (is.null(con)) {
    ## method = "stream" or method = "paged" with path = NULL
    parse_fasta_string(body)
  } else {
    ## method = "paged" with path = "string"
    writeLines(text = body, con = con, sep = "")
  }
}
