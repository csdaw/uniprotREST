## dry run ---------------------------------------------------------------------
test_that("dry run returns useful data", {
  req <- uniprot_request(
    "https://rest.uniprot.org/uniprotkb/P99999",
    format = "tsv",
    fields = "accession,gene_primary"
  )

  resp <- uniprotREST::fetch_stream(req, verbosity = 0, dry_run = TRUE)
  expect_equal(resp$method, "GET")
  expect_equal(resp$path, "/uniprotkb/P99999")
  expect_match(resp$headers$`user-agent`, "uniprotREST https://github.com/csdaw/uniprotREST")
})

test_that("dry run shows body", {
  expect_snapshot({
    uniprot_request(
      "https://rest.uniprot.org/idmapping/run",
      method = "POST",
      from = "Ensembl",
      to = "UniProtKB",
      ids = "P99999"
    ) %>%
      uniprotREST::fetch_stream(dry_run = TRUE)
  })
})

## actual query (via httptest2) ------------------------------------------------
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
