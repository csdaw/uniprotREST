library(magrittr)
library(httr2)

rest_url <- "https://rest.uniprot.org/idmapping/run"

input <- c("Q92945", "Q96AE4")

## Original

# post_req <- httr2::request(rest_url) %>%
#   httr2::req_user_agent("uniprotREST https://github.com/csdaw/uniprotREST") %>%
#   httr2::req_body_form(
#     from = "UniProtKB_AC-ID",
#     to = "UniProtKB",
#     ids = paste(input, collapse = ",")
#   ) %>%
#   httr2::req_retry(max_tries = 5) %>%
#   httr2::req_throttle(rate = 1 / 1) # limit: 1 request every 1 second
#
# httr2::req_dry_run(post_req)

## New

post_resp <- uniprot_post(
  url = rest_url,
  from = "UniProtKB_AC-ID",
  to = "UniProtKB",
  ids = paste(input, collapse = ","),
  verbosity = 1,
  dry_run = TRUE
)

get_job_id(post_resp)



