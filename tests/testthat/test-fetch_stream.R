with_mock_dir("httptest2/fetch_stream", {
  test_that("fetch_stream works", {
    req <- uniprot_request(
      "https://rest.uniprot.org/uniref/stream",
      query = "P99999",
      format = "tsv",
      fields = "id,name,count"
    )

    result <- fetch_stream(req, parse = FALSE)

    expect_snapshot({
      result
    })
  })
}, simplify = FALSE)

with_mock_dir("httptest2/fetch_stream", {
  test_that("fetch_stream can parse tsv format", {
    req <- uniprot_request(
      "https://rest.uniprot.org/uniref/stream",
      query = "P99999",
      format = "tsv",
      fields = "id,name,count"
    )

    result <- fetch_stream(req, parse = TRUE)

    expect_snapshot({
      result
    })
  })
}, simplify = FALSE)
