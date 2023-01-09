resp_body_json_paged <- function(resp, page, n_pages, con, encoding = NULL) {
  check_response(resp)

  if (is.null(encoding)) encoding <- httr2::resp_encoding(resp)

  if (n_pages == 1) {
    resp$body %>% readBin(character()) %>%
      iconv(from = encoding, to = "UTF-8") %>%
      # substr(13, nchar(.) - 2) %>%
      writeLines(con = con, sep = "\n")
  }
  else
  {
    if (page == 1L) {
      # First page = remove trailing brackets
      resp$body %>%
        readBin(character()) %>%
        iconv(from = encoding, to = "UTF-8") %>%
        substr(1, nchar(.) - 2) %>%
        writeLines(con = con, sep = "\n")
      cat(",", file = con)

    } else if (page == n_pages) {
      # Last page = remove leading 'results'
      resp$body %>%
        readBin(character()) %>%
        iconv(from = encoding, to = "UTF-8") %>%
        substr(13, nchar(.)) %>%
        writeLines(con = con, sep = "\n")

    } else {
      # Internal page = remove leading 'results' and trailing brackets
      resp$body %>%
        readBin(character()) %>%
        iconv(from = encoding, to = "UTF-8") %>%
        substr(13, nchar(.) - 2) %>%
        writeLines(con = con, sep = "\n")
      cat(",", file = con)
    }
  }
}
