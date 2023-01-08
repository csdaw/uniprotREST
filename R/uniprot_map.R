#' Map from/to UniProt IDs
#'
#' @description This function wraps the
#'   [UniProt ID Mapping](https://www.uniprot.org/help/id_mapping) service which
#'   maps between the identifiers used in one database, to the identifiers of
#'   another. By default it maps UniProtKB accessions to UniProt and returns a
#'   `data.frame`, so you can get information about a set of IDs e.g. gene names,
#'   protein lengths, domains, etc. You can also map IDs from/to other databases
#'   e.g. `from = "Ensembl", to = "UniProtKB"`.
#'
#' @param ids `character`, vector of identifiers to map from.
#' @param from `string`, database to map from. Default is `"UniProtKB_AC-ID"`.
#'   See [from_to_dbs] possible databases whose identifiers you can map from.
#' @param to `string`, database to map to. Default is `"UniProtKB"`.
#'   See [from_to_rules] for the possible databases you can map to, depending on
#'   the `from` database.
#' @param fields Optional `character`, fields (i.e. columns) of data to get.
#'   Only used if `to` is a UniProtKB, UniRef, or UniParc database. See
#'   [return_fields] for all available fields.
#' @inheritParams uniprot_search
#' @inherit uniprot_search return
#'
#' @seealso Other API wrapper functions: [uniprot_search()], [uniprot_single()]
#'
#' @export
#'
#' @examples
#' \dontrun{
#'   # Default, get info about UniProt IDs
#'   uniprot_map(
#'     "P99999",
#'     format = "tsv",
#'     fields = c("accession", "gene_primary", "feature_count")
#'   )
#'
#'   # Other common use, mapping other IDs to UniProt
#'   # (or vice-versa)
#'   uniprot_map(
#'     c("ENSG00000088247", "ENSG00000162613"),
#'     from = "Ensembl",
#'     to = "UniProtKB"
#'   )
#'
#' }
uniprot_map <- function(ids,
                        from = "UniProtKB_AC-ID",
                        to = "UniProtKB",
                        format = "tsv",
                        path = NULL,
                        fields = NULL,
                        isoform = NULL,
                        method = "paged",
                        page_size = 500,
                        compressed = NULL,
                        verbosity = NULL,
                        dry_run = FALSE) {
  ## Argument checking
  if (!is.null(ids)) {
    assert_character(ids)
    if (length(ids) > 1) ids <- paste(ids, collapse = ",")
  }
  assert_from_to(from, to)
  database <- uniprotREST::from_to_dbs[uniprotREST::from_to_dbs$name == to, "uniprot_db"]
  assert_database_format(func = "map", d = database, f = format)
  if (!is.null(path)) assert_path_for_output(path)
  if (!is.null(fields)) {
    if (database == "other") {
      vmessage("Skipping `fields`, only used when mapping to UniProt databases.",
               verbosity = verbosity, null_prints = TRUE)
      fields <- NULL
    } else {
      assert_fields(fields, database = database)
      if (length(fields) > 1) fields <- paste(fields, collapse = ",")
    }
  }
  if (!is.null(isoform)) assert_logical(isoform, max.len = 1)
  assert_choice(method, c("paged", "stream"))
  if (method == "stream") {
    page_size <- NULL
  } else if (method == "paged") {
    assert_integerish(page_size, lower = 0, max.len = 1)
  }
  if (!is.null(compressed)) assert_compressed(compressed, method, path)
  if (!is.null(verbosity)) assert_integerish(verbosity, lower = 0, upper = 3, max.len = 1)
  assert_logical(dry_run, max.len = 1)

  ## Construct POST request
  post_req <- uniprot_request(
    url = "https://rest.uniprot.org/idmapping/run",
    method = "POST",
    from = from,
    to = to,
    ids = ids
  )

  ## Make POST request
  if (dry_run) {
    return(httr2::req_dry_run(post_req, quiet = if (is.null(verbosity)) FALSE else as.logical(verbosity)))
  } else {
    post_resp <- httr2::req_perform(post_req, verbosity = verbosity)
  }

  ## Get job ID and optionally print message
  job_id <- httr2::resp_body_json(post_resp)$jobId
  vcat(paste("Running job:", job_id, "\n"), verbosity = verbosity, null_prints = TRUE)

  ## Construct a status (HEAD) request
  status_req <- uniprot_request(
    url = paste0("https://rest.uniprot.org/idmapping/status/", job_id),
    method = "HEAD",
  ) %>%
    # UniProt returns status 200 while job is still running and
    # status 303 when job is complete.
    httr2::req_retry(
      is_transient = function(resp) {
        (httr2::resp_status(resp) %in% c("200") &
           is.null(httr2::resp_header(resp, "x-total-results")))
      },
      max_tries = 50
    )

  ## Make status (HEAD) request
  status_resp <- httr2::req_perform(status_req, verbosity = verbosity)

  ## Construct URL for GET request (depends on method)
  result_url <- switch(
    method,
    stream = gsub("results", "results/stream", status_resp$url),
    paged = status_resp$url
  )

  ## Construct GET request
  get_req <- uniprot_request(
    url = result_url,
    method = "GET",
    format = format,
    fields = fields,
    includeIsoform = isoform,
    size = page_size,
    compressed = compressed
  )

  ## Perform GET request via stream or pagination endpoint
  if (method == "stream") {
    fetch_stream(
      req = get_req,
      format = format,
      parse = TRUE,
      path = path,
      verbosity = verbosity
    )
  } else if (method == "paged") {
    # n pages = n results / page size
    n_results <- as.integer(status_resp$headers$`x-total-results`)

    n_pages <- ceiling(n_results / page_size)

    fetch_paged(
      req = get_req,
      n_pages = n_pages,
      format = format,
      path = path,
      verbosity = verbosity
    )
  }
}
