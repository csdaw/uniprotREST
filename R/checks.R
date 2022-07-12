check_response <- function(req) {
  if (inherits(req, "httr2_response")) {
    return()
  }
  stop("`resp` must be an HTTP response object")
}

check_string <- function(x) {
  if (!(is.character(x) && length(x) == 1))
    stop(sprintf( "`%s` must be a single string.", deparse(substitute(x))))
}

check_character <- function(x, convert = FALSE) {
  if (!is.character(x))
    stop(sprintf("`%s` must be a string or character vector.", deparse(substitute(x))))

  if (convert && length(x) > 1)
    paste(x, collapse = ",")
}

check_logical <- function(x) {
  if (!is.logical(x)) stop(sprintf("`%s` must be TRUE or FALSE.", deparse(substitute(x))))
}

check_verbosity <- function(x) {
  if (!x %in% 0:3) stop("`verbosity` must be 0, 1, 2, or 3.")
}
