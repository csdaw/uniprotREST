# Function slightly modified from httr2
req_method_get <- function(req) {
  if (!is.null(req$method)) {
    req$method
  } else if ("nobody" %in% names(req$options)) {
    "HEAD"
  } else if (!is.null(req$body)) {
    "POST"
  } else {
    "GET"
  }
}

test_that("default method is GET", {
  req <- uniprot_request("http://example.com")
  expect_equal(req_method_get(req), "GET")
})

test_that("can add queries to GET request", {
  req <- uniprot_request("http://example.com/", a = 1, b = 2, c = NULL)
  expect_equal(req$url, "http://example.com/?a=1&b=2")
})

test_that("can make POST request", {
  req <- uniprot_request("http://example.com/", method = "POST", a = 1, b = 2, c = NULL)
  expect_equal(req_method_get(req), "POST")
})

test_that("can make HEAD request", {
  req <- uniprot_request("http://example.com/", method = "HEAD", a = 1, b = 2, c = NULL)
  expect_equal(req_method_get(req), "HEAD")
})
