## Use like:
# post_resp <- uniprot_post(
#   url = paste(rest_url, "run", sep = "/"),
#   from = "UniProtKB_AC-ID",
#   to = "UniProtKB",
#   ids = paste(input, collapse = ","),
#   dry_run = FALSE
# )
#
# get_jobid(post_resp)
uniprot_post <- function(url,
                         ...,
                         max_tries = 5,
                         rate = 1 / 1,
                         verbosity = NULL,
                         dry_run = FALSE) {
  assert_url(url)
  assert_integerish(max_tries, max.len = 1)
  assert_numeric(rate, lower = 0)
  if (!is.null(verbosity)) assert_integerish(verbosity, lower = 0, upper = 3, max.len = 1)
  assert_logical(dry_run)

  post_req <- httr2::request(url) %>%
    httr2::req_method("POST") %>%
    httr2::req_user_agent("uniprotREST https://github.com/csdaw/uniprotREST") %>%
    httr2::req_retry(max_tries = max_tries) %>%
    httr2::req_throttle(rate = rate) %>%
    httr2::req_body_form(...)

  if (dry_run) return(httr2::req_dry_run(post_req, quiet = ifelse(is.null(verbosity), TRUE, FALSE)))
  else httr2::req_perform(post_req, verbosity = verbosity)
}

get_job_id <- function(resp) {
  httr2::resp_body_json(resp)$jobId
}
