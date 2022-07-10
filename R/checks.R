check_response <- function(req) {
  if (inherits(req, "httr2_response")) {
    return()
  }
  stop("`resp` must be an HTTP response object")
}
