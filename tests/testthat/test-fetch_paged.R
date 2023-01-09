with_mock_dir("_mocks/fetch_paged", {
  test_that("works with tsv format", {
    req <- uniprot_request(
      "https://rest.uniprot.org/uniref/search",
      query = "P99999",
      format = "tsv",
      fields = "id,name,count",
      size = 1
    )

    expect_snapshot({
      fetch_paged(req, format = "tsv", n_pages = 3)
    })
  })

  test_that("works with fasta format", {
    req <- uniprot_request(
      "https://rest.uniprot.org/uniref/search",
      query = "P99999",
      format = "fasta",
      size = 1
    )

    expect_snapshot({
      fetch_paged(req, format = "fasta", n_pages = 3)
    })
  })
}, simplify = FALSE)
