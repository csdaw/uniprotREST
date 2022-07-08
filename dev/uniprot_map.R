####
library(here)

input <- readLines(here("dev/map-id-test-input.txt"))[-2]

test <- uniprotREST::uniprot_map(
  ids = input,
  fields = c("accession", "length", "reviewed"),
  size = 25,
  verbosity = 1
)

####

library(magrittr)
library(httr2)



## Construct and send POST request
rest_url <- "https://rest.uniprot.org/idmapping"

# Construct POST request containing IDs
# On failure retry 5 times
post_req <- httr2::request(rest_url) %>%
  httr2::req_user_agent("uniprotREST https://github.com/csdaw/uniprotREST") %>%
  httr2::req_url_path_append("run") %>%
  httr2::req_body_form(
    `from` = "UniProtKB_AC-ID",
    `to` = "UniProtKB",
    `ids` = input
  ) %>%
  httr2::req_retry(max_tries = 5) %>%
  httr2::req_throttle(rate = 1 / 1) # limit: 1 request every 1 second

# Send POST request
dry_run <- FALSE

if (dry_run) return(httr2::req_dry_run(post_req)) else
  post_resp <- httr2::req_perform(post_req, verbosity = 1)

# Extract and print job id (useful for manually looking up results)
jobid <- httr2::resp_body_json(post_resp)
message(paste("Job ID:", jobid))

# test_req <-  httr2::request(rest_url) %>%
#   httr2::req_user_agent("uniprotREST https://github.com/csdaw/uniprotREST") %>%
#   httr2::req_url_path_append("status", jobid) %>%
#   httr2::req_throttle(rate = 15 / 60)
#
# test_resp <- httr2::req_perform(test_req, verbosity = 1)
#
# out <- test_resp %>% httr2::resp_body_json()

test_req2 <- httr2::request(rest_url) %>%
  httr2::req_user_agent("uniprotREST https://github.com/csdaw/uniprotREST") %>%
  httr2::req_url_path_append("status", jobid) %>%
  httr2::req_retry(is_transient = ~ httr2::resp_status(.x) %in% c("200", "429", "503")) %>%
  httr2::req_throttle(rate = 1 / 1) %>% # limit: 1 request every 1 second
  httr2::req_method("HEAD")

test_resp2 <- httr2::req_perform(test_req2, verbosity = 1)
#
# aaa <- test_resp2$headers$link
#
# re_next_link <- gsub('<(.+)>; rel="next"', "\\1", aaa)
#
# get_next_link <- function(resp) {
#   link_header <- httr2::resp_header(resp, "Link")
#
#   if (!is.null(link_header)) {
#     gsub('<(.+)>; rel="next"', "\\1", link_header)
#   } else {
#     link_header
#   }
# }

page_size <- 500
n_pages <- ceiling(as.integer(test_resp2$headers$`x-total-results`) / page_size)

# out <- vector(mode = "list", length = n_pages)
#
# result_url <- test_resp2 %>%
#   httr2::resp_header("location")

test_req3 <- httr2::request(rest_url) %>%
  httr2::req_user_agent("uniprotREST https://github.com/csdaw/uniprotREST") %>%
  httr2::req_url(test_resp2$url) %>%
  httr2::req_url_query(
    `format` = "tsv",
    `fields` = paste(c("accession", "gene_primary"), collapse = ","),
    `compressed` = FALSE,
    `size` = page_size
  ) %>%
  httr2::req_retry(max_tries = 5) %>%
  httr2::req_throttle(rate = 2 / 1) # limit: 2 requests every 1 second

source(here("dev", "get_paged_results.R"))
debugonce(get_paged_results)
bbb <- get_paged_results(test_req3, page_size, n_pages, 1)
ccc <- bbb[[1]] %>%
  httr2::resp_body_string() %>%
  read.delim(text = .)
