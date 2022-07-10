get_results_paged <- function(url, n_pages, format, path, fields, isoform, compressed, size, verbosity) {
  get_req <- httr2::request(url) %>%
    httr2::req_user_agent("uniprotREST https://github.com/csdaw/uniprotREST") %>%
    httr2::req_url_query(
      `format` = format,
      `fields` = fields,
      `compressed` = compressed,
      `size` = size
    ) %>%
    httr2::req_retry(max_tries = 5) %>%
    httr2::req_error(is_error = function(resp) FALSE)

  if (!is.null(path)) {
    # Load results into memory then save to disk, page by page
    get_results_paged_disk(get_req, format = format, path = path, page_size = size, n_pages = n_pages, verbosity = verbosity)
  } else {
    # Load results into memory page by page and output single object
    get_results_paged_mem(get_req, format = format, page_size = size, n_pages = n_pages, verbosity = verbosity)
  }
}

get_results_paged_disk <- function(req, format, path, page_size, n_pages, verbosity) {
  i <- 1L

  file_con <- file(path, "w")

  # Keep getting results pages until the Link header disappears (i.e. becomes NULL)
  repeat({
    message(paste("Page", i, "of", n_pages))

    resp <- httr2::req_perform(req, verbosity = verbosity)
    if (resp$status_code == "200") {
      message("Success")

      switch(
        format,
        tsv = resp_body_tsv_paged(resp, page = i, con = file_con),
        stop("Only format = `tsv` implemented currently")
      )
    } else {
      message(paste("Something went wrong. Status code:", resp$status_code))
    }

    if (i == n_pages) break
    req$url <- get_next_page(resp)
    i <- i + 1L
  })

  close(file_con)
}

get_results_paged_mem <- function(req, format, page_size, n_pages, verbosity) {
  i <- 1L

  out <- vector("list", n_pages)

  # Keep getting results pages until the Link header disappears (i.e. becomes NULL)
  repeat({
    message(paste("Page", i, "of", n_pages))

    out[[i]] <- httr2::req_perform(req, verbosity = verbosity)
    if (out[[i]]$status_code == "200") {
      message("Success")
    } else {
      message(paste("Something went wrong. Status code:", out[[i]]$status_code))
    }

    if (i == n_pages) break
    req$url <- get_next_page(out[[i]])
    i <- i + 1L
  })

  switch(
    format,
    tsv = {
      out %>%
        lapply(resp_body_tsv) %>%
        do.call(rbind, .)
    },
    stop("Only format = `tsv` implemented currently")
  )
}

get_next_page <- function(resp) {
  link_header <- httr2::resp_header(resp, "Link")

  if (!is.null(link_header)) {
    gsub('<(.+)>; rel="next"', "\\1", link_header)
  } else {
    link_header
  }
}
