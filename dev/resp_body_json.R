library(magrittr)
library(here)
source(here("dev/get_results_paged.R"))

input <- readLines(here("dev/map-id-test-input.txt"))[-10:-14]

rest_url <- "https://rest.uniprot.org/idmapping"

post_req <- httr2::request(rest_url) %>%
  httr2::req_user_agent("uniprotREST https://github.com/csdaw/uniprotREST") %>%
  httr2::req_url_path_append("run") %>%
  httr2::req_body_form(
    `from` = "UniProtKB_AC-ID",
    `to` = "UniProtKB",
    `ids` = paste(input, collapse = ",")
  ) %>%
  httr2::req_retry(max_tries = 5) %>%
  httr2::req_throttle(rate = 1 / 1) # limit: 1 request every 1 second

post_resp <- httr2::req_perform(post_req, verbosity = 1)

jobid <- httr2::resp_body_json(post_resp)$jobId
message(paste("Job ID:", jobid))

status_req <- httr2::request(rest_url) %>%
  httr2::req_user_agent("uniprotREST https://github.com/csdaw/uniprotREST") %>%
  httr2::req_url_path_append("status", jobid) %>%
  httr2::req_method("HEAD") %>%
  httr2::req_retry(is_transient = function(resp) {
    httr2::resp_status(resp) %in% c("429", "503") |
      (httr2::resp_status(resp) %in% c("200") & is.null(httr2::resp_header(resp, "x-total-results")))
  },
  max_tries = 50) %>%
  httr2::req_throttle(rate = 1 / 1) # limit: 1 request every 1 second

status_resp <- httr2::req_perform(status_req, verbosity = 1)

get_req <- httr2::request(status_resp$url) %>%
  httr2::req_user_agent("uniprotREST https://github.com/csdaw/uniprotREST") %>%
  httr2::req_url_query(
    `format` = "json",
    `fields` = NULL,
    `compressed` = NULL
  ) %>%
  httr2::req_retry(max_tries = 5)

size <- 20L

# n pages = n results / page size
n_pages <- ceiling(as.integer(status_resp$headers$`x-total-results`) / size)

test <- get_results_paged(
  req = get_req %>%
    httr2::req_url_query(`size` = size) %>%
    httr2::req_error(is_error = function(resp) FALSE),
  n_pages = n_pages,
  format = "json",
  path = NULL,
  fields = NULL,
  isoform = NULL,
  compressed = NULL,
  verbosity = 1
)

## mem
test2 <- test %>%
  lapply(httr2::resp_body_string)

test3 <- jsonlite::fromJSON(test2[[1]], simplifyVector = FALSE) %>%
  unlist(recursive = FALSE)

test4 <- test %>% sapply(httr2::resp_body_json) %>%
  unlist(recursive = FALSE, use.names = FALSE)

## disk
test2[[1]] -> test5

test6 <- jsonlite::fromJSON(
  test5,
  simplifyVector = FALSE
) %>%
  unlist(recursive = FALSE, use.names = FALSE)

test6 <- stringr::str_sub(test5, 1, 200)
test7 <- stringr::str_sub(test5, -200, -1)

test8 <- sub('{"results":[', "", test5, fixed = TRUE)
test8 <- sub('}}}]}', "}}}", test8, fixed = TRUE)

test9 <- jsonlite::fromJSON(test8, simplifyVector = FALSE)

#### JSON to disk ####
resp_body_json_paged <- function(resp, page, con, encoding = NULL) {
  uniprotREST:::check_response(resp)

  if (is.null(encoding)) encoding <- httr2::resp_encoding(resp)

  # message if length(resp$body) == 0?
  writeLines("{")

  resp$body %>%
    readBin(character()) %>%
    iconv(from = encoding, to = "UTF-8") %>%
    writeLines(con = con, sep = "\n")
}

get_results_paged(
  req = get_req %>%
    httr2::req_url_query(`size` = size) %>%
    httr2::req_error(is_error = function(resp) FALSE),
  n_pages = n_pages,
  format = "json",
  path = here("dev/test_to_disk/test.json"),
  fields = NULL,
  isoform = NULL,
  compressed = NULL,
  verbosity = 1
)

bbb <- readr::read_file(here("dev/test_to_disk/test.json"))

substr(bbb, 1, 20)

ccc <- gsub('{"results":[', '', bbb, fixed = TRUE)

substr(ccc, 1, 20)
