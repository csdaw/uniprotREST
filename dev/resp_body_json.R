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

test3 <- test %>%
  lapply(httr2::resp_body_json)

test4 <- test %>% sapply(httr2::resp_body_json) %>%
  unlist(recursive = FALSE, use.names = FALSE)

## disk

## stream

debugonce(uniprotREST:::get_results_stream)
uniprotREST:::get_results_stream(
  req = get_req %>%
    httr2::req_url(sub("results", "results/stream", get_req$url)),
  # n_pages = n_pages,
  format = "json",
  path = here("dev/test_to_disk/test_json_stream.json"),
  fields = NULL,
  isoform = NULL,
  compressed = NULL,
  verbosity = 1
)

ddd <- jsonlite::read_json(here("dev/test_to_disk/test_json_stream.json"))

## paged
aaa <- test[[1]]$body %>%
  readBin(character()) %>%
  iconv(from = "UTF-8", to = "UTF-8")

bbb <- test[[2]]$body %>%
  readBin(character()) %>%
  iconv(from = "UTF-8", to = "UTF-8")

ccc <- test[[3]]$body %>%
  readBin(character()) %>%
  iconv(from = "UTF-8", to = "UTF-8")

file_con <- file(here("dev/test_to_disk/test_json_paged.json"), "w")

# first page
writeLines(aaa %>% substr(., 1, nchar(.) - 2), file_con)
cat(",", file = file_con)

# any internal page
writeLines(bbb %>% substr(., 13, nchar(.) - 2), file_con)
cat(",", file = file_con)

# final page
writeLines(ccc %>% substr(., 13, nchar(.)), file_con)
close(file_con)

ddd <- jsonlite::read_json(here("dev/test_to_disk/test_json_paged.json"))
