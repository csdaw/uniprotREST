vcat <- function(..., verbosity = NULL, vlimit = 0, null_prints = FALSE) {
  if (!is.null(verbosity)) {
    assert_integerish(verbosity, lower = 0, upper = 3, max.len = 1) # verbosity must be in 0:3
    if (verbosity > vlimit)
      cat(...)
    else
      invisible()
  } else {
    if (null_prints)
      cat(...)
    else
      invisible()
  }
}
