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
  res <- check_from(f) && check_to(t)
  if (!isTRUE(res))
    return(res)
  if (!test_choice(t, uniprotREST::from_to_rules[[f]]))
    return("`from` and `to` pair is invalid. See `?from_to_rules` for valid values")
  return(TRUE)
}

assert_from_to <- checkmate::makeAssertionFunction(check_from_to)
