map_uniprot_id <- function(query, format = NULL, from = "ACC+ID", to = "ACC", columns = NULL) {
  # check input length
  if (length(query) >= 100000) {
    stop("`query` is too long. Length must be < 100,000 entries.")
  }

  httr2::request("https://www.uniprot.org/uploadlists/") %>%
    httr2::req_url_query(
      `query` = paste(query, collapse = ","),
      `from` = from,

    )
}
