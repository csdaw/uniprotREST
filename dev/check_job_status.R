check_job_status <- function(jobid,
                             max_tries = 20,
                             rate = 1,
                             verbosity = NULL,
                             dry_run = FALSE) {
  # Check job status and automatically fetch results if job is complete
  # (i.e. HTML status 303 is returned)
  # If job not complete (i.e. HTML status 200 is returned)
  # send status request again at a rate of y requests/sec, up to n times

  status_req <- httr2::request("https://rest.uniprot.org/idmapping/status") %>%
    httr2::req_method("HEAD") %>%
    httr2::req_user_agent("uniprotREST https://github.com/csdaw/uniprotREST") %>%
    httr2::req_url_path_append("status", jobid) %>%
    httr2::req_retry(is_transient = function(resp) {
      httr2::resp_status(resp) %in% c("429", "503") |
        (httr2::resp_status(resp) %in% c("200") & is.null(httr2::resp_header(resp, "x-total-results")))
    },
    max_tries = max_tries) %>%
    httr2::req_throttle(rate = rate)

  if (dry_run) return(httr2::req_dry_run(status_req))
  else httr2::req_perform(status_req, verbosity = verbosity)
}
