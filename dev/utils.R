is_response <- function(x) {
  inherits(x, "httr2_response")
}

check_response <- function(req) {
  if (is_response(req)) {
    return()
  }
  stop("`resp` must be an HTTP response object")
}
