with_mock_dir("httptest2", {
  test_that("resp is returned", {
    req <- uniprot_request(
      "https://rest.uniprot.org/uniprotkb/P99999",
      format = "tsv",
      fields = "accession,gene_primary"
    )

    expect_snapshot({
      fetch_stream(req, parse = FALSE)
    })
  })
}, simplify = FALSE)
