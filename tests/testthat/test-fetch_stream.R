with_mock_dir("_mocks/fetch_stream", {
  test_that("can parse tsv format", {
    req <- uniprot_request(
      "https://rest.uniprot.org/uniref/stream",
      query = "P99999",
      format = "tsv",
      fields = "id,name,count"
    )

    result <- fetch_stream(req, format = "tsv", parse = TRUE)

    expect_snapshot({
      result
    })
  })

  test_that("can parse json format", {
    req <- uniprot_request(
      "https://rest.uniprot.org/uniref/stream",
      query = "P99999",
      format = "json",
      fields = "id,name,sequence"
    )

    result <- fetch_stream(req, format = "json", parse = TRUE)

    expect_snapshot({
      str(result, max.level = 3)
    })
  })

  test_that("can parse fasta format", {
    req <- uniprot_request(
      "https://rest.uniprot.org/uniref/stream",
      query = "P99999",
      format = "fasta"
    )

    result <- fetch_stream(req, format = "fasta", parse = TRUE)

    expect_snapshot({
      result
    })
  })
}, simplify = TRUE)
