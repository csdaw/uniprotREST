get_paged_results <- function(req, page_size, n_pages, verbosity) {
  i <- 1L
  # n_pages <- httr2::req_perform(httr2::req_method(req, "HEAD"), verbosity = verbosity)$headers$`x-total-results`

  out <- vector("list", n_pages)

  # Keep getting results pages until the Link header disappears (i.e. becomes NULL)
  repeat({
    message(paste("Page", i, "of", n_pages))
    out[[i]] <- httr2::req_perform(httr2::req_error(req, is_error = function(resp) FALSE), verbosity = verbosity)
    if (out[[i]]$status_code == "200")
      message("Success")
    else
      message(paste("Something went wrong. Status code:", out[[i]]$status_code))
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

get_to_db <- function(to) {
  lookup_df <- data.frame(
    to = c("UniProtKB", "UniProtKB-Swiss-Prot",
           "UniRef100", "UniRef90", "UniRef50",
           "UniParc"),
    db = c(rep("uniprotkb", 2),
           rep("uniref", 3),
           "uniparc")
  )

  if (!to %in% lookup_df$to) {
    return("")
  } else {
    lookup_df[lookup_df$to == to, "db"]
  }
}

