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

#### method == stream ####
result_url <- gsub("results", "results/stream", status_resp$url)

get_req <- httr2::request(result_url) %>%
  httr2::req_user_agent("uniprotREST https://github.com/csdaw/uniprotREST") %>%
  httr2::req_url_query(
    `format` = "json",
    `fields` = NULL,
    `compressed` = NULL
  ) %>%
  httr2::req_retry(max_tries = 5) %>%
  httr2::req_throttle(rate = 1 / 1) # limit 1 request every 1 second

## into memory
source(here("dev/get_results_stream.R"))

stream_mem <- get_results_stream(
  req = get_req,
  format = "json",
  path = NULL,
  fields = NULL,
  isoform = NULL,
  compressed = NULL,
  verbosity = NULL
)

## into disk
get_results_stream(
  req = get_req,
  format = "json",
  path = here("dev/test_to_disk/json_stream_disk.json"),
  fields = NULL,
  isoform = NULL,
  compressed = NULL,
  verbosity = NULL
)

stream_disk <- jsonlite::read_json(here("dev/test_to_disk/json_stream_disk.json"))

#### method = paged #####
pg_size <- 20L

result_url <- status_resp$url

get_req <- httr2::request(result_url) %>%
  httr2::req_user_agent("uniprotREST https://github.com/csdaw/uniprotREST") %>%
  httr2::req_url_query(
    `format` = "json",
    `fields` = NULL,
    `compressed` = NULL
  ) %>%
  httr2::req_retry(max_tries = 5) %>%
  httr2::req_throttle(rate = 1 / 1) %>%  # limit 1 request every 1 second
  httr2::req_url_query(`size` = pg_size) %>%
  httr2::req_error(is_error = function(resp) FALSE)

## into memory
# n pages = n results / page size
n_pages <- ceiling(as.integer(status_resp$headers$`x-total-results`) / pg_size)

test <- get_results_paged(
  req = get_req %>%
    httr2::req_url_query(`size` = pg_size) %>%
    httr2::req_error(is_error = function(resp) FALSE),
  n_pages = n_pages,
  format = "json",
  path = NULL,
  fields = NULL,
  isoform = NULL,
  compressed = NULL,
  verbosity = 1
)

paged_mem <- test %>% sapply(httr2::resp_body_json) %>%
  unlist(recursive = FALSE, use.names = FALSE)

# potential alternative method:
out <- vector("list", 187)

out[1:20] <- unlist(httr2::resp_body_json(test[[1]]), recursive = FALSE, use.names = FALSE)

## into disk

# just get the HTTP responses to test out best way to write to file
source(here("dev/get_results_paged_mem.R"))

get_req <- httr2::request(result_url) %>%
  httr2::req_user_agent("uniprotREST https://github.com/csdaw/uniprotREST") %>%
  httr2::req_url_query(
    `format` = "json",
    `size` = pg_size,
    `fields` = NULL,
    `compressed` = NULL
  ) %>%
  httr2::req_retry(max_tries = 5) %>%
  httr2::req_throttle(rate = 1 / 1) # limit 1 request every 1 second

get_resps <- get_results_paged_mem(
  req = get_req,
  format = "json",
  n_pages = n_pages,
  verbosity = NULL
)

resp_body_json_paged <- function(resp, page, n_pages, con, encoding = NULL) {
  uniprotREST:::check_response(resp)

  if (is.null(encoding)) encoding <- httr2::resp_encoding(resp)

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

file_con <- file(here("dev/test_to_disk/test_json_paged.json"), "w")

for (i in 1:n_pages) {
  resp_body_json_paged(
    resp = get_resps[[i]],
    page = i,
    n_pages = n_pages,
    con = file_con
  )
}

close(file_con)

ddd <- jsonlite::read_json(here("dev/test_to_disk/test_json_paged.json"))
