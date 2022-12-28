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
  if (!all(x %in% return_fields[return_fields[["database"]] == database, "field"]))
    return("Invalid field(s). See `return_fields` for valid strings")
  return(TRUE)
}

assert_fields <- checkmate::makeAssertionFunction(check_fields)
