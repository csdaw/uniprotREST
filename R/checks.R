## check URLs ------------------------------------------------------------------
check_url <- function(x, na.ok = FALSE, null.ok = FALSE) {
  res <- check_string(x, na.ok = na.ok, null.ok = null.ok)
  if (!isTRUE(res))
    return(res)
  if (!any(grepl("(https?|ftp)://[^\\s/$.?#].[^\\s]*", x)))
    return("Not a valid URL")
  return(TRUE)
}

assert_url <- checkmate::makeAssertionFunction(check_url)

## check fields ----------------------------------------------------------------
check_fields <- function(x, database = "uniprotkb", any.missing = FALSE) {
  res <- check_character(x, any.missing = any.missing)
  if (!isTRUE(res))
    return(res)
  if (!test_subset(x, uniprotREST::return_fields[
    uniprotREST::return_fields[["database"]] == database, "field"
  ]))
    return("Invalid field(s). See `?return_fields` for valid strings")
  return(TRUE)
}

assert_fields <- checkmate::makeAssertionFunction(check_fields)

## check from ------------------------------------------------------------------
check_from <- function(x) {
  res <- check_string(x)
  if (!isTRUE(res))
    return(res)
  if (!test_choice(x, names(uniprotREST::from_to_rules)))
    return("`from` is invalid. See `?from_to_rules` for valid `from` values")
  return(TRUE)
}

assert_from <- checkmate::makeAssertionFunction(check_from)

## check to --------------------------------------------------------------------
check_to <- function(x) {
  res <- check_string(x)
  if (!isTRUE(res))
    return(res)
  if (!test_choice(x, sort(unique(unlist(uniprotREST::from_to_rules)))))
    return("`to` is invalid. See `?from_to_rules` for valid `to` values")
  return(TRUE)
}

assert_to <- checkmate::makeAssertionFunction(check_to)

## check from/to ---------------------------------------------------------------
check_from_to <- function(f, t) {
  res_f <- check_from(f)
  res_t <- check_to(t)
  if (!isTRUE(res_f))
    return(res_f)
  if (!isTRUE(res_t))
    return(res_t)
  if (!test_choice(t, uniprotREST::from_to_rules[[f]]))
    return("`from` and `to` pair is invalid. See `?from_to_rules` for valid values")
  return(TRUE)
}

assert_from_to <- checkmate::makeAssertionFunction(check_from_to)

## check compressed ------------------------------------------------------------
check_compressed <- function(x, method, path) {
  res <- check_logical(x, max.len = 1)
  if (!isTRUE(res))
    return(res)
  if (x && (method == "paged" | is.null(path)))
    return('Compressed output only works when method = "stream" and path is defined')
  return(TRUE)
}

assert_compressed <- checkmate::makeAssertionFunction(check_compressed)

## check request ---------------------------------------------------------------
check_request <- function(x) {
  if (!inherits(x, "httr2_request"))
    return("Not an httr2 request object")
  return(TRUE)
}

assert_request <- checkmate::makeAssertionFunction(check_request)

## check response --------------------------------------------------------------
check_response <- function(x) {
  if (!inherits(x, "httr2_response"))
    return("Not an httr2 response object")
  return(TRUE)
}

assert_response <- checkmate::makeAssertionFunction(check_response)

## check_database --------------------------------------------------------------
check_database <- function(x) {
  res <- check_string(x)
  if (!isTRUE(res))
    return(res)
  if (!test_choice(x, levels(uniprotREST::formats$database)))
    return("`database` is invalid. See `?formats` for valid `database` values")
  return(TRUE)
}

assert_database <- checkmate::makeAssertionFunction(check_database)

## check format ----------------------------------------------------------------
check_format <- function(x) {
  res <- check_string(x)
  if (!isTRUE(res))
    return(res)
  if (!test_choice(x, unique(uniprotREST::formats$format)))
    return("`format` is invalid. See `?formats` for valid `format` values")
  return(TRUE)
}

assert_format <- checkmate::makeAssertionFunction(check_format)

## check_database_format -------------------------------------------------------
check_database_format <- function(func, d, f) {
  res_d <- check_database(d)
  res_f <- check_format(f)
  if (!isTRUE(res_d))
    return(res_d)
  if (!isTRUE(res_f))
    return(res_f)
  if (!test_choice(f, uniprotREST::formats[
    uniprotREST::formats$func == func &
    uniprotREST::formats$database == d,
    "format"
  ]))
    return("This `format` is not available for this `database`. See `?formats` for valid values.")
  return(TRUE)
}

assert_database_format <- checkmate::makeAssertionFunction(check_database_format)
