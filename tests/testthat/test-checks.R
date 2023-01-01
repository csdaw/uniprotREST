## assert_url() ----------------------------------------------------------------
test_that("assert_url works", {
  expect_no_error(
    uniprotREST:::assert_url("https://rest.uniprot.org/somestring1234")
  )
})

test_that("assert_url errors if input not string", {
  expect_error(
    uniprotREST:::assert_url(222),
    "Must be of type 'string', not 'double'"
  )
})

test_that("assert_url errors if string isn't a url", {
  expect_error(
    uniprotREST:::assert_url("this is not a url.com"),
    "Not a valid URL"
  )
})

## assert_fields() -------------------------------------------------------------
test_that("assert_fields works", {
  expect_no_error(
    uniprotREST:::assert_fields(c("accession", "gene_names"))
  )
})

test_that("assert_fields works with other database", {
  expect_no_error(
    uniprotREST:::assert_fields(c("length", "sequence"), database = "uniparc")
  )
})

test_that("assert_fields errors if input not character", {
  expect_error(
    uniprotREST:::assert_fields(c(1, 2)),
    "Must be of type 'character', not 'double'"
  )
})

test_that("assert_fields errors if input contains NA", {
  expect_error(
    uniprotREST:::assert_fields(c("accession", NA)),
    "Contains missing values"
  )
})

test_that("assert_fields errors if input is not an accepted field", {
  expect_error(
    uniprotREST:::assert_fields(c("accession", "banana")),
    "Invalid field"
  )
})

## assert_from() ---------------------------------------------------------------
test_that("assert_from works", {
  expect_no_error(
    uniprotREST:::assert_from("UniParc")
  )
})

test_that("assert_from errors if input not string", {
  expect_error(
    uniprotREST:::assert_from(222),
    "Must be of type 'string', not 'double'"
  )
})

test_that("assert_from errors if string isn't valid", {
  expect_error(
    uniprotREST:::assert_from("banana"),
    "is invalid"
  )
})

## assert_to() -----------------------------------------------------------------
test_that("assert_to works", {
  expect_no_error(
    uniprotREST:::assert_to("UniParc")
  )
})

test_that("assert_to errors if input not string", {
  expect_error(
    uniprotREST:::assert_to(222),
    "Must be of type 'string', not 'double'"
  )
})

test_that("assert_to errors if string isn't valid", {
  expect_error(
    uniprotREST:::assert_to("banana"),
    "is invalid"
  )
})

## assert_from_to() ------------------------------------------------------------
test_that("assert_from_to works", {
  expect_no_error(
    uniprotREST:::assert_from_to("UniProtKB_AC-ID", "Ensembl")
  )
})

test_that("assert_from_to errors if from is invalid", {
  expect_error(
    uniprotREST:::assert_from_to("apple", "Ensembl"),
    "is invalid"
  )
})

test_that("assert_from_to errors if to is invalid", {
  expect_error(
    uniprotREST:::assert_from_to("SGD", "apple"),
    "is invalid"
  )
})

test_that("assert_from_to errors if from/to pair is invalid", {
  expect_error(
    uniprotREST:::assert_from_to("SGD", "Ensembl"),
    "is invalid"
  )
})

## assert_compressed() ---------------------------------------------------------
test_that("assert_compressed works if FALSE", {
  expect_no_error(
    uniprotREST:::assert_compressed(FALSE, "apple", "banana")
  )
})

test_that("assert_compressed works if TRUE", {
  expect_no_error(
    uniprotREST:::assert_compressed(TRUE, "stream", "some/file/path")
  )
})

test_that("assert_compressed errors if type is not logical", {
  expect_error(
    uniprotREST:::assert_compressed("aaa", "stream", "some/file/path"),
    "Must be of type 'logical', not 'character'."
  )
})

test_that("assert_compressed errors if method is paged", {
  expect_error(
    uniprotREST:::assert_compressed(TRUE, "paged", "some/file/path"),
    "Compressed output only works when"
  )
})

test_that("assert_compressed errors if path is not provided", {
  expect_error(
    uniprotREST:::assert_compressed(TRUE, "stream", NULL),
    "Compressed output only works when"
  )
})

## assert_request() ------------------------------------------------------------
test_that("assert_request works", {
  req <- httr2::request("http://example.com")
  expect_no_error(
    uniprotREST:::assert_request(req)
  )
})

test_that("assert_request errors if req is wrong class", {
  expect_error(
    uniprotREST:::assert_request("banana"),
    "Not an httr2 request object"
  )
})

## assert_response() ------------------------------------------------------------
test_that("assert_response works", {
  resp <- structure(list(url = "http://example.com", body = NULL),
                    class = "httr2_response")
  expect_no_error(
    uniprotREST:::assert_response(resp)
  )
})

test_that("assert_response errors if resp is wrong class", {
  expect_error(
    uniprotREST:::assert_response("banana"),
    "Not an httr2 response object"
  )
})
