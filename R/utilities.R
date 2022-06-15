#' Argument verification using exact matching
#'
#' @description Works the same as \code{\link[base]{match.arg}} but
#' with the default of using exact matching with \code{\link[base]{match}}
#' instead of partial matching with \code{\link[base]{pmatch}}.
#'
#' @param arg `character vector` (of length one unless `several.ok = TRUE`) or
#' `NULL`.
#' @param choices `character vector` of candidate values.
#' @param several.ok `logical` specifying if `arg` should be allowed to have
#' more than one element. Default is `FALSE`.
#' @param exact `logical` specifying if exact matching should be used. Default
#' is `TRUE`.
#'
#' @return Returns the exact match if there is one, otherwise an returns an
#' error if `several.ok = FALSE`. When `several.ok = TRUE` and more than one
#' element of `arg` has a match, all matches are returned.
#'
#' @source This code was copied from the source of the [MARSS]() package which
#' is licensed under CC0 1.0 Universal.
#'
match.arg.exact <- function (arg, choices, several.ok = FALSE, exact = TRUE) {
  if (missing(choices)) {
    formal.args <- formals(sys.function(sysP <- sys.parent()))
    choices <- eval(formal.args[[as.character(substitute(arg))]],
                    envir = sys.frame(sysP))
  }
  if (is.null(arg))
    return(choices[1L])
  else if (!is.character(arg))
    stop("'arg' must be NULL or a character vector")
  if (!several.ok) {
    if (identical(arg, choices))
      return(arg[1L])
    if (length(arg) > 1L)
      stop("'arg' must be of length 1")
  }
  else if (length(arg) == 0L)
    stop("'arg' must be of length >= 1")
  # HERE IS THE MODIFIED CODE
  if (exact)
    i <- match(arg, choices, nomatch = 0L)
  else
    i <- pmatch(arg, choices, nomatch = 0L, duplicates.ok = TRUE)
  # END MODIFIED CODE

  if (all(i == 0L))
    stop(gettextf("'arg' should be one of %s", paste(dQuote(choices),
                                                     collapse = ", ")), domain = NA)
  i <- i[i > 0L]
  if (!several.ok && length(i) > 1)
    stop("there is more than one match in 'match.arg'")
  choices[i]
}
