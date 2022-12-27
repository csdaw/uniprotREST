## Specific argument checking
check_url <- function(x, na.ok = FALSE, null.ok = FALSE) {
  res = check_string(x, na.ok = na.ok, null.ok = null.ok)
  if (!isTRUE(res))
    return(res)
  if (!any(grepl("(https?|ftp)://[^\\s/$.?#].[^\\s]*", x)))
    return("Not a valid URL.")
  return(TRUE)
}

assert_url <- makeAssertionFunction(check_url)
