with_mock_dir("httptest2/fetch_paged", {
  test_that("fetch_paged works with tsv format", {
    req <- uniprot_request(
      "https://rest.uniprot.org/uniref/search",
      query = "P99999",
      format = "tsv",
      fields = "id,name,count",
      size = 1
    )

    expect_snapshot({
      fetch_paged(req, n_pages = 3)
    })
  })
}, simplify = FALSE)
