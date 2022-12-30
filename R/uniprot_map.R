uniprot_map <- function(ids,
                        from = "UniProtKB_AC-ID",
                        to = "UniProtKB",
                        format = "tsv",
                        path = NULL,
                        fields = NULL,
                        isoform = NULL,
                        compressed = NULL,
                        # method = c("paged", "stream"),
                        # size = 500L,
                        verbosity = NULL,
                        dry_run = FALSE) {
  ## Argument checking
  if (!is.null(ids)) {
    assert_character(ids)
    if (test_character(ids, min.len = 2)) ids <- paste(ids, collapse = ",")
  }
  assert_from_to(from, to)
  database <- uniprotREST::from_to_dbs[uniprotREST::from_to_dbs$name == to, "return_fields_db"]
  assert_choice(format, c("tsv"))
  if (!is.null(path)) assert_path_for_output(path)
  if (!is.null(fields)) {
    if (!test_string(database)) {
      warning("Skipping `fields`... this argument can't be used with this `to` database.")
      # do nothing
    } else {
      assert_fields(fields, database = database)
      if (length(fields) > 1)
        fields <- paste(fields, collapse = ",")
    }
  }
  if (!is.null(isoform)) assert_logical(isoform, max.len = 1)
  if (!is.null(compressed)) assert_logical(compressed, max.len = 1)
  if (!is.null(verbosity)) assert_integerish(verbosity, lower = 0, upper = 3, max.len = 1)
  assert_logical(dry_run, max.len = 1)

  # construct post request

  # define a post request (need to make a req_post() function)

  # get job id

  # define a status request (need to make a req_head() function)

  # make status request

  # construct results request

  # define a get request

  # if method = paged fetch_paged else if method = stream fetch_stream
}
