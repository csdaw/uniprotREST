with_mock_dir("httptest2/fetch_stream", {
  test_that("fetch_stream works with tsv format", {
    req <- uniprot_request(
      "https://rest.uniprot.org/uniref/stream",
      query = "P99999",
      format = "tsv",
      fields = "id,name,count"
    )

    expect_snapshot({
      # Verbosity must be zero or snapshot diffs won't match
      fetch_stream(req, parse = FALSE, verbosity = 0)
    })
    expect_snapshot({
      # Verbosity must be zero or snapshot diffs won't match
      fetch_stream(req, parse = TRUE, verbosity = 0)
    })
  })
}, simplify = FALSE)
