#' Fetch results via pagination
#'
#' @description This function performs a request for data from the UniProt REST
#'   API, fetches the results using pagination, and saves them to a file or
#'   into memory.
#'
#'   You likely won't use this function directly, but rather one of the
#'   wrapper functions: [uniprot_map()], [uniprot_search()], or [uniprot_single()].
#'
#'   ### Things to note:
#'
#'   1. The pagination endpoint is less expensive for the API infrastructure to
#'      deal with versus [fetch_stream()], as the memory demand is distributed
#'      over a longer period of time.
#'   2. If the connection is interrupted while fetching results with pagination,
#'      only the request for the current page needs to be reattempted. With the
#'      stream endpoint, the entire request needs to be completely restarted.
#'
#' @inheritParams httr2::req_perform
#' @inheritParams fetch_stream
#' @param n_pages `integer`, the number of pages to be fetched. This can be
#'   calculated by dividing the number of total results by the page size e.g.
#'   `resp$headers$x-total-results / page_size`.
#' @param format `string`, data format to fetch. Can one of `"tsv"`, or `"fasta"`.
#'
#' @inherit fetch_stream return
#' @export
#'
#' @examples
#' \dontrun{
#'   req <- uniprot_request(
#'     "https://rest.uniprot.org/uniref/search",
#'     query = "P99999",
#'     format = "tsv",
#'     fields = "id,name,count",
#'     size = 1
#'   )
#'
#'   fetch_paged(req, n_pages = 3)
#' }
fetch_paged <- function(req,
                        n_pages,
                        format = "tsv",
                        path = NULL,
                        verbosity = NULL) {
  ## Argument checking
  assert_request(req)
  assert_integerish(n_pages, lower = 1, max.len = 1)
  assert_format(format)
  if (!is.null(path)) assert_path_for_output(path)
  if (!is.null(verbosity))
    assert_integerish(verbosity, lower = 0, upper = 3, max.len = 1) # verbosity must be in 0:3

  out <- vector("list", n_pages)

  # Make an empty list to save outputs to
  if (format == "fasta" && requireNamespace("Biostrings", quietly = TRUE)) {
    out <- Biostrings::AAStringSetList(out)
  }

  # Initialise counter
  i <- 1L

  # Open file connection if necessary
  if (!is.null(path)) con = file(path, "w") else con = NULL

  while (i <= n_pages) {
    vcat(
      "\r", "Downloading: page", i, "of", n_pages,
      verbosity = verbosity, null_prints = TRUE
    )
    utils::flush.console()

    resp <- httr2::req_perform(req, verbosity = verbosity)

    # Parse response body
    out[[i]] <- switch(
      format,
      tsv = resp_body_tsv(resp, page = i, con = con),
      fasta = resp_body_fasta(resp, con = con)
    )

    next_url <- get_next_link(resp)

    # Get URL of next page if present, otherwise exit loop
    if (!is.null(next_url)) req$url <- next_url else break

    # Increment counter
    i <- i + 1L
  }

  if (!is.null(path)) {
    # to disk = close file connection and return nothing
    close(con)
    return(invisible())
  } else {
    # to memory = return parsed body
    switch(
      format,
      tsv = do.call(rbind, out),
      fasta = unlist(out)
    )
  }
}

get_next_link <- function(resp) {
  link_header <- httr2::resp_header(resp, "Link")

  if (!is.null(link_header)) {
    gsub('<(.+)>; rel="next"', "\\1", link_header)
  } else {
    link_header
  }
}
