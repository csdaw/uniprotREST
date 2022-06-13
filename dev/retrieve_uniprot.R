retrieve_uniprot <- function(id, database, format, path = NULL, include) {
  rest_url <- paste0("https://rest.uniprot.org/", database, "/")

  req <- httr2::request(rest_url) %>%
    httr2::req_user_agent("proteotools https://github.com/csdaw/proteotools") %>%
    httr2::req_url_path_append(paste(id, format, sep = "."))

  httr2::req_perform(req, path = path)
}

hsap <- retrieve_uniprot("UP000005640", "proteomes", "json")

hsap2 <- hsap %>%
  httr2::resp_body_json()

aaa <- httr2::request("https://ftp.uniprot.org/pub/databases/uniprot/current_release/knowledgebase/reference_proteomes/") %>%
  httr2::req_perform()

bbb <- httr2::resp_link_url(aaa)

