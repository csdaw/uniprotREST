#' @export
map_uniprot_id <- function(ids, from = "UniProtKB_AC-ID", to = "UniProtKB",
                           format = c("json", "tsv", "xlsx"),
                           path = NULL,
                           fields = NULL,
                           isoform = NULL,
                           compressed = FALSE,
                           dry_run = FALSE) {
  ## Argument checking
  # Check ids and convert to single string if necessary
  if (!is.character(ids)) stop("`ids` must be a string or character vector.")
  if (length(ids) > 1) ids <- paste(ids, collapse = ",")

  # Check from, to, and format arguments
  from <- match.arg.exact(from)
  to <- match.arg.exact(to)
  format <- match.arg.exact(format)

  # Check path is a single string if present
  if (!is.null(path)) {
    if (!is.character(path) & length(path) == 1) stop("`path` must be a single string")
  }

  # Check fields and convert to single string if necessary
  if (!is.null(fields)) {
    if (!is.character(fields)) stop("`fields` must be a string or character vector")
    if (length(fields) > 1) fields <- paste(fields, collapse = ",")
  }

  # Check other arguments
  if (!is.null(isoform)) if (!is.logical(isoform)) stop("`isoform` must be TRUE or FALSE.")
  if (!is.logical(compressed)) stop("`compressed` must be TRUE or FALSE.")
  if (!is.logical(dry_run)) stop("`dry_run` must be TRUE or FALSE.")

  ## Construct and send POST request
  rest_url <- "https://rest.uniprot.org/idmapping"

  post_req <- httr2::request(rest_url) %>%
    httr2::req_user_agent("proteotools https://github.com/csdaw/proteotools") %>%
    httr2::req_url_path_append("run") %>%
    httr2::req_body_form(
      `from` = from,
      `to` = to,
      `ids` = ids,
    )

  if (dry_run) return(httr2::req_dry_run(post_req)) else
    post_resp <- httr2::req_perform(post_req)

  # Extract and print job ID
  jobid <- httr2::resp_body_json(post_resp)$jobId
  message(paste("Job ID:", jobid))

  ## Check job status and automatically fetch results if job is complete
  ## (i.e. HTML status 303 is returned)
  ## On failure retry every 1 min for 60 min in total
  get_req <- httr2::request(rest_url) %>%
    httr2::req_user_agent("proteotools https://github.com/csdaw/proteotools") %>%
    httr2::req_url_path_append("results", jobid) %>%
    httr2::req_url_query(
      `format` = format,
      `fields` = fields,
      `includeIsoform` = isoform,
      `compressed` = compressed
    ) %>%
    httr2::req_retry(max_tries = 60, backoff = ~ 60)

  httr2::req_perform(get_req, path = path)
}
