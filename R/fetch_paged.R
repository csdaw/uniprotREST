#' @noRd
#' @export
fetch_paged <- function(req, n_pages, format = "tsv", path = NULL, verbosity = NULL) {
  # Make an empty list to save outputs to
  out <- vector("list", n_pages)

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
      tsv = resp_body_tsv(resp, page = i, con = con)
    )

    next_url <- get_next_link(resp)

    # Get URL of next page
    if (!is.null(next_url)) req$url <- next_url

    # Increment counter
    i <- i + 1L
  }

  if (!is.null(path)) {
    close(con)
    # to disk = return nothing
    return(invisible())
  } else {
    # to memory = return parsed body
    switch(
      format,
      tsv = do.call(rbind, out)
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
