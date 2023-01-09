resp_body_tsv <- function(resp, encoding = NULL) {
  check_response(resp)

  if (is.null(encoding)) encoding <- httr2::resp_encoding(resp)

  if (length(resp$body) == 0) {
    stop("Can not retrieve empty body")
  }

  resp$body %>%
    readBin(character()) %>%
    iconv(from = encoding, to = "UTF-8") %>%
    utils::read.delim(text = .)
}

resp_body_tsv_paged <- function(resp, page, con, encoding = NULL) {
  check_response(resp)

  if (is.null(encoding)) encoding <- httr2::resp_encoding(resp)

  # message if length(resp$body) == 0?

  if (page == 1L) {
    resp$body %>%
      readBin(character()) %>%
      iconv(from = encoding, to = "UTF-8") %>%
      writeLines(con = con, sep = "")
  } else {
    resp$body %>%
      readBin(character()) %>%
      iconv(from = encoding, to = "UTF-8") %>%
      gsub("^.*?\n", "", .) %>%
      writeLines(con = con, sep = "")
  }
}
