with_mock_dir("httptest2/uniprot_single", {
  test_that("uniprot_single works with tsv", {
    result <- uniprot_single("P99999", format = "tsv")

    expect_snapshot({
      # Verbosity must be zero or snapshot diffs won't match
      result
    })
  })
}, simplify = FALSE)
