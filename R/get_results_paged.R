get_results_paged <- function(req, n_pages, format, path, fields, isoform, compressed, verbosity) {
  if (!is.null(path)) {
    # Load results into memory then save to disk, page by page
    get_results_paged_disk(req, format = format, path = path, n_pages = n_pages, verbosity = verbosity)
  } else {
    # Load results into memory page by page and output single object
    get_results_paged_mem(req, format = format, n_pages = n_pages, verbosity = verbosity)
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
        fasta = resp_body_fasta_paged(resp, con = file_con),
        stop("Only format = `tsv` or `fasta` implemented currently")
      )
    } else {
      message(paste("Something went wrong. Status code:", resp$status_code))
    }

    if (i == n_pages) break
    next_page <- get_next_page(resp)
    if (!is.null(next_page)) req$url <- next_page else break
    i <- i + 1L
  })

  close(file_con)
}

get_results_paged_mem <- function(req, format, n_pages, verbosity) {
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
    next_page <- get_next_page(out[[i]])
    if (!is.null(next_page)) req$url <- next_page else break
    i <- i + 1L
  })

  switch(
    format,
    tsv = {
      out %>%
        lapply(resp_body_tsv) %>%
        do.call(rbind, .)
    },
    fasta = {
      out %>%
        lapply(resp_body_fasta_paged, con = NULL) %>%
        unlist() %>%
        str2fasta()
    },
    stop("Only format = `tsv` or `fasta` implemented currently")
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
