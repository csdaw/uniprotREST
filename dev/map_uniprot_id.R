library(magrittr)

query_input <- c("Q91YT7", "Q8BYK6")

query <- paste(query_input, collapse = ",")

rest_url <- "https://rest.uniprot.org/idmapping"

## POST JOB
req <- httr2::request(rest_url) %>%
  httr2::req_user_agent("proteotools https://github.com/csdaw/proteotools") %>%
  httr2::req_url_path_append("run") %>%
  httr2::req_body_form(
    `from` = "UniProtKB_AC-ID",
    `to` = "UniRef90",
    `ids` = query,
  )

resp_dry <- httr2::req_dry_run(req)
resp_dry
resp <- httr2::req_perform(req)
resp

jobid <- httr2::resp_body_json(resp)$jobId
jobid

## CHECK JOB DETAILS
req2 <- httr2::request(rest_url) %>%
  httr2::req_user_agent("proteotools https://github.com/csdaw/proteotools") %>%
  httr2::req_url_path_append("details", jobid)
req2

resp2_dry <- httr2::req_dry_run(req2)
resp2_dry
resp2 <- httr2::req_perform(req2)
resp2
resp2 %>% httr2::resp_headers()
result2 <- resp2 %>% httr2::resp_body_json()
result2

## CHECK JOB STATUS AND AUTOMATICALLY FETCH RESULTS (RETRY EVERY 60s ON FAILURE UP TO 1h)
req3 <- httr2::request(rest_url) %>%
  httr2::req_user_agent("proteotools https://github.com/csdaw/proteotools") %>%
  httr2::req_url_path_append("status", jobid) %>%
  httr2::req_retry(max_tries = 60, backoff = ~ 60)
req3

resp3_dry <- httr2::req_dry_run(req3)
resp3_dry
resp3 <- httr2::req_perform(req3, verbosity = 2)
resp3
