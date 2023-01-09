with_mock_dir("_mocks/uniprot_search", {
  test_that("works with tsv", {
    result <- uniprot_search(
      "FUBP3",
      database = "uniprotkb",
      format = "tsv",
      fields = c("accession", "id", "gene_primary"),
      isoform = TRUE
    )

    expect_snapshot({
      result
    })
  })

  test_that("works with stream endpoint", {
    result <- uniprot_search(
      "P99999",
      database = "uniref",
      method = "stream"
    )

    expect_snapshot({
      result
    })
  })

  test_that("verbosity suppresses output", {
    expect_output(
      uniprot_search("P99999", database = "uniref", verbosity = 0),
      regexp = NA
    )
  })

}, simplify = FALSE)

test_that("works with dry run", {
  expect_snapshot({
    uniprot_search(
      "P99999",
      database = "uniref",
      dry_run = TRUE
    )
  })
})
