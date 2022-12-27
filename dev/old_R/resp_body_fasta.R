resp_body_fasta <- function(resp, biostrings = TRUE, encoding = NULL) {
  check_response(resp)

  if (is.null(encoding)) encoding <- httr2::resp_encoding(resp)

  if (length(resp$body) == 0) {
    stop("Can not retrieve empty body")
  }

  resp$body %>%
    readBin(character()) %>%
    iconv(from = encoding, to = "UTF-8") %>%
    str2fasta()
}

resp_body_fasta_paged <- function(resp, con = NULL, encoding = NULL) {
  check_response(resp)

  if (is.null(encoding)) encoding <- httr2::resp_encoding(resp)

  if (!is.null(con)) {
    resp$body %>%
      readBin(character()) %>%
      iconv(from = encoding, to = "UTF-8") %>%
      writeLines(con = con, sep = "")
  } else {
    resp$body %>%
      readBin(character()) %>%
      iconv(from = encoding, to = "UTF-8") %>%
      strsplit(split = "\n")
  }
}
