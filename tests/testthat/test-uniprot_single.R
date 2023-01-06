with_mock_dir("httptest2/uniprot_single", {
  test_that("uniprot_single works with tsv", {
    result <- uniprot_single("P99999", format = "tsv")

    expect_snapshot({
      result
    })
  })
}, simplify = FALSE)
