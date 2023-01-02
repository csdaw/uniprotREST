vmessage <- function(..., verbosity = NULL, vlimit = 0) {
  if (!is.null(verbosity)) {
    assert_integerish(verbosity, lower = 0, upper = 3, max.len = 1) # verbosity must be in 0:3

    if (verbosity > vlimit)
      message(...)
    else
      invisible()
  } else {
    invisible()
  }
}
