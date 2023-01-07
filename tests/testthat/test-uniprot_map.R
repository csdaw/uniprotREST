# with_mock_dir("_mocks", {
#   test_that("works with paged, to memory", {
#     result <- uniprot_map(
#       ids = c("P99999", "P12345"),
#       format = "tsv",
#       fields = c("accession", "id", "gene_primary"),
#       page_size = 1
#     )
#
#     expect_snapshot({
#       result
#     })
#   })
#
#   test_that("works with stream, to memory", {
#     result <- uniprot_map(
#       ids = c("P99999", "P12345"),
#       format = "tsv",
#       fields = c("accession", "id", "gene_primary"),
#       method = "stream"
#     )
#
#     expect_snapshot({
#       result
#     })
#   })
#
#   test_that("works mapping from non-UniProt ID", {
#     result <- uniprot_map(
#       ids = "ENSG00000010404",
#       from = "Ensembl",
#       format = "tsv",
#       fields = c("accession", "id", "gene_primary")
#     )
#
#     expect_snapshot({
#       result
#     })
#   })
#
#   test_that("works mapping to non-UniProt ID", {
#     result <- uniprot_map(
#       ids = c("P99999", "P99998"),
#       to = "Ensembl",
#       format = "tsv"
#     )
#
#     expect_snapshot({
#       result
#     })
#   })
#
#   test_that("verbosity suppresses output", {
#     expect_output(
#       uniprot_map(c("P99999", "P99998"), to = "Ensembl", format = "tsv", verbosity = 0),
#       regexp = NA
#     )
#   })
# }, simplify = FALSE)
#
# test_that("works with dry run", {
#   expect_snapshot({
#     uniprot_map(
#       "P99999",
#       dry_run = TRUE
#     )
#   })
# })
