search_uniprot <- function(query, database = "uniprotkb", format = "tsv", path = NULL,
                           fields = NULL, isoform = NULL, compressed = FALSE,
                           size = NULL, cursor = NULL) {
  rest_url <- paste0("https://rest.uniprot.org/", database, "/search")

  req <- httr2::request(rest_url) %>%
    httr2::req_user_agent("proteotools https://github.com/csdaw/proteotools") %>%
    httr2::req_url_query(
      `query` = query,
      `format` = format,
      `fields` = fields,
      `includeIsoform` = isoform,
      `compressed` = compressed,
      `size` = size,
      `cursor` = cursor
    )

  httr2::req_perform(req, path = path)
}

aaa <- search_uniprot("upid:UP000005640", "proteomes", fields = paste("organism_id", "lineage", sep = ","))
bbb <- aaa %>% httr2::resp_body_string() %>%
  read.delim(text = .)
