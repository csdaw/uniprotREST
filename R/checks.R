## Specific argument checking
check_url <- function(x, na.ok = FALSE, null.ok = FALSE) {
  res <- check_string(x, na.ok = na.ok, null.ok = null.ok)
  if (!isTRUE(res))
    return(res)
  if (!any(grepl("(https?|ftp)://[^\\s/$.?#].[^\\s]*", x)))
    return("Not a valid URL")
  return(TRUE)
}

assert_url <- checkmate::makeAssertionFunction(check_url)

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

check_from <- function(x) {
  res <- check_string(x)
  if (!isTRUE(res))
    return(res)
  if (!test_choice(x, names(uniprotREST::from_to_rules)))
    return("`from` is invalid. See `?from_to_rules` for valid `from` values")
  return(TRUE)
}

assert_from <- checkmate::makeAssertionFunction(check_from)

check_to <- function(x) {
  res <- check_string(x)
  if (!isTRUE(res))
    return(res)
  if (!test_choice(x, sort(unique(unlist(uniprotREST::from_to_rules)))))
    return("`to` is invalid. See `?from_to_rules` for valid `to` values")
  return(TRUE)
}

assert_to <- checkmate::makeAssertionFunction(check_to)

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

check_compressed <- function(x, method, path) {
  res <- check_logical(x, max.len = 1)
  if (!isTRUE(res))
    return(res)
  if (x && (method == "paged" | is.null(path)))
    return('Compressed output only works when method = "stream" and path is defined')
  return(TRUE)
}

assert_compressed <- checkmate::makeAssertionFunction(check_compressed)

check_request <- function(x) {
  if (!inherits(x, "httr2_request"))
    return("Not an httr2 request object")
  return(TRUE)
}

assert_request <- checkmate::makeAssertionFunction(check_request)

check_response <- function(x) {
  if (!inherits(x, "httr2_response"))
    return("Not an httr2 response object")
  return(TRUE)
}

assert_response <- checkmate::makeAssertionFunction(check_response)
