with_mock_dir("httptest2", {
  test_that("uniprot_get works", {
    resp <- uniprot_get(
      "https://rest.uniprot.org/uniprotkb/P99999?fields=accession,gene_names&format=tsv",
      fields = "accession,gene_primary",
      format = "tsv"
    )

    expect_length(read.delim(text = httr2::resp_body_string(resp), sep = "\t"), 2)
  })
})
