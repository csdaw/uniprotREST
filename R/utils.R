# convert string to AAStringSet
# return AAStringSet if Biostrings is installed
# else return named vector
parse_fasta_string <- function(x) {
  xlines <- unlist(strsplit(x, "\n"))

  hdr_idx <- grep(">", xlines)

  seq_idx <- data.frame(
    hdr = hdr_idx,
    from = hdr_idx + 1,
    to = c((hdr_idx - 1)[-1], length(xlines))
  )

  seqs <- vector(mode = "character", length = length(hdr_idx))

  for (i in seq_along(hdr_idx)) {
    seqs[i] <- paste(xlines[seq_idx$from[i]:seq_idx$to[i]], collapse = "")
  }

  names(seqs) <- substring(xlines[hdr_idx], 2)

  if (!requireNamespace("Biostrings", quietly = TRUE)) {
    return(seqs)
  } else {
    Biostrings::AAStringSet(seqs)
  }
}

# fetch total results header
# input: get request, output: integer
fetch_n_results <- function(req, verbosity = NULL) {
  req %>%
    httr2::req_method("HEAD") %>%
    httr2::req_perform(verbosity = verbosity) %>%
    httr2::resp_header("x-total-results") %>%
    as.integer()
}

# cat to console, but respect verbosity
vcat <- function(..., verbosity = NULL, vlimit = 0, null_prints = FALSE) {
  if (!is.null(verbosity))
    assert_integerish(verbosity, lower = 0, upper = 3, max.len = 1) # verbosity must be in 0:3

  if (verbosity > vlimit || (is.null(verbosity) & null_prints))
    cat(...)
  else
    invisible()
}

# print message, but respect verbosity
vmessage <- function(..., verbosity = NULL, vlimit = 0, null_prints = FALSE) {
  if (!is.null(verbosity))
    assert_integerish(verbosity, lower = 0, upper = 3, max.len = 1) # verbosity must be in 0:3

  if (verbosity > vlimit || (is.null(verbosity) & null_prints))
    message(...)
  else
    invisible()
}

# Modified from httr package
# https://github.com/r-lib/httr/blob/main/R/progress.R
progress_stream <- function(con = stdout(), verbosity = NULL) {
  show_progress <- function(down, up) {
    total <- down[[1]]
    now <- down[[2]]

    # We don't know the size of the data beforehand
    if (total == 0) {
      vcat("\rDownloading: ", bytes(now, digits = 2), "     ", sep = "",
           file = con, verbosity = verbosity, null_prints = TRUE)
      utils::flush.console()
      # No way to tell when then the file has finished downloading until
      # total is not zero
    }

    TRUE
  }

  show_progress
}

# Copied from httr package
bytes <- function(x, digits = 3, ...) {
  power <- min(floor(log(abs(x), 1000)), 4)
  if (power < 1) {
    unit <- "B"
  } else {
    unit <- c("kB", "MB", "GB", "TB")[[power]]
    x <- x / (1000^power)
  }

  formatted <- format(signif(x, digits = digits),
                      big.mark = ",",
                      scientific = FALSE
  )

  paste0(formatted, " ", unit)
}
