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
