library(here)
library(magrittr)

rest_url <- "https://rest.uniprot.org/idmapping"

input <- readLines(here("dev/map-id-test-input.txt"))[-10:-50]


## Original

post_req <- httr2::request(rest_url) %>%
  httr2::req_user_agent("uniprotREST https://github.com/csdaw/uniprotREST") %>%
  httr2::req_url_path_append("run") %>%
  httr2::req_body_form(
    from = "UniProtKB_AC-ID",
    to = "UniProtKB",
    ids = paste(input, collapse = ",")
  ) %>%
  httr2::req_retry(max_tries = 5) %>%
  httr2::req_throttle(rate = 1 / 1) # limit: 1 request every 1 second

httr2::req_dry_run(post_req)

## New

post_resp <- uniprot_post(
  url = paste(rest_url, "run", sep = "/"),
  from = "UniProtKB_AC-ID",
  to = "UniProtKB",
  ids = paste(input, collapse = ","),
  dry_run = FALSE
)

get_jobid(post_resp)



