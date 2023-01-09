with_mock_dir("_mocks/uniprot_single", {
  test_that("works with tsv", {
    result <- uniprot_single("P99999", format = "tsv")

    expect_snapshot({
      result
    })
  })
}, simplify = FALSE)
