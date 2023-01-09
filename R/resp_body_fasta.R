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
