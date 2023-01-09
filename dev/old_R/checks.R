## Specific argument checking
check_url <- function(x) {
  assert_string(x)
  any(grepl("(https?|ftp)://[^\\s/$.?#].[^\\s]*", x))
}

assert_url <- function(x) {
  if (!check_url(x)) {
    stop(sprintf("`%s` is not a valid url.", deparse(substitute(x))))
  }
}

check_from_to <- function(from, to) {
  # Check from is valid
  if (!from %in% names(map_from_to))
    stop("`from` database is not valid.")

  # Check to is valid
  if (!to %in% unique(unlist(map_from_to, use.names = FALSE)))
    stop("`to` database is not valid.")

  # Check from to pair is valid
  if (!to %in% map_from_to[[from]])
    stop(sprintf("Unable to map IDs from `%s` to `%s`.", from, to))
}

## Other object checking
check_response <- function(req) {
  if (inherits(req, "httr2_response")) {
    return()
  }
  stop("`resp` must be an HTTP response object")
}

