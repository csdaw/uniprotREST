get_paged_results <- function(req, page_size, n_pages, verbosity) {
  out <- vector("list", n_pages)
  i <- 1L

  # Keep getting results pages until the Link header disappers (i.e. becomes)
  repeat({
    out[[i]] <- req_perform(req, verbosity = verbosity)
    if (i == n_pages) break

    next_page_url <- get_next_page(out[[i]])
    if (is.null(next_page_url)) break

    req$url <- next_page_url
    i <- i + 1L
  })

  out
}

get_next_page <- function(resp) {
  link_header <- httr2::resp_header(resp, "Link")

  if (!is.null(link_header)) {
    gsub('<(.+)>; rel="next"', "\\1", link_header)
  } else {
    link_header
  }
}
