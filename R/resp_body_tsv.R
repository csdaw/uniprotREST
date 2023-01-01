resp_body_tsv <- function(resp, page = NULL, con = NULL, encoding = NULL) {
  check_response(resp)

  if (is.null(encoding)) encoding <- httr2::resp_encoding(resp)

  if (length(resp$body) == 0) {
    stop("Can not retrieve empty body")
  }

  body <- resp$body %>%
    readBin(character()) %>%
    iconv(from = encoding, to = "UTF-8")

  if (is.null(page)) {
    ## method = "stream"
    utils::read.delim(text = body)
  } else {
    ## method = "paged"
    if (page == 1L) {
      writeLines(text = body, con = con, sep = "")
    } else {
      # remove header for non-first pages
      writeLines(text = gsub("^.*?\n", "", body), con = con, sep = "")
    }
  }
}
