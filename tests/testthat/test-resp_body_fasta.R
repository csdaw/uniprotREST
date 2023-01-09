test_that("errors if body is empty", {
  resp <- structure(
    list(method = "GET", url = "http://example.com", body = NULL),
    class = "httr2_response"
  )

  expect_error(
    resp_body_fasta(resp)
  )
})

test_that("works with single reponse", {
  resp <- structure(
    list(method = "GET", url = "https://example.com",
         body = charToRaw(">Protein1\nAAA\n>Protein2\nCCC")),
    class = "httr2_response"
  )

  expect_snapshot(resp_body_fasta(resp))
})

test_that("works with paged response", {
  # Construct list of responses
  resp <- structure(
    list(method = "GET", url = "https://example.com",
         body = charToRaw(">Protein1\nAAA\n>Protein2\nCCC")),
    class = "httr2_response"
  )
  resps <- list(resp, resp)

  # Make temp file to hold result
  tmp <- tempfile(fileext = ".fasta")
  con <- file(tmp, open = "w")
  on.exit(unlink(tmp)) # delete tempfile when finished

  for (i in seq_along(resps)) {
    resp_body_fasta(resps[[i]], con = con)
  }
  close(con)

  expect_snapshot(Biostrings::readAAStringSet(tmp))
})
