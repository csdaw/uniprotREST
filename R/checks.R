## Type checking
check_string <- function(x) {
  if (!(is.character(x) && length(x) == 1))
    stop(sprintf( "`%s` must be a single string.", deparse(substitute(x))))
}

check_character <- function(x, convert = FALSE) {
  if (!is.character(x))
    stop(sprintf("`%s` must be a string or character vector.", deparse(substitute(x))))

  if (convert){
    if (length(x) > 1) {
      paste(x, collapse = ",")
    } else {
      x
    }
  }
}

check_url <- function(x) {
  if (!any(grepl("^(https?|ftp)://[^\\s/$.?#].[^\\s]*$", x)))
    stop(sprintf("`%s` is not a valid url.", deparse(substitute(x))))
}

check_logical <- function(x) {
  if (!is.logical(x)) stop(sprintf("`%s` must be TRUE or FALSE.", deparse(substitute(x))))
}

check_verbosity <- function(x) {
  if (!x %in% 0:3) stop("`verbosity` must be 0, 1, 2, or 3.")
}

check_numeric <- function(x) {
  if (!is.numeric(x)) stop(sprintf("`%s` must be numeric.", deparse(substitute(x))))
}


## Specific argument checking
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

