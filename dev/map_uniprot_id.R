library(magrittr)
library(jsonlite)
library(purrr)

## Valid from to values
valid_to_from <- read_json("dev/valid_from_to.json")

to_from_groups <- valid_to_from %>%
  pluck("groups") %>%
  map_dfr(pluck, 2)

to_from_rules <- valid_to_from %>%
  pluck("rules") %>%
  map(function(i) modify_at(i, "tos", flatten_chr)) %>%
  map_dfr(~ .x)

## Potential approach 1
# valid froms = check against some vector

# valid tos = check against some vector

# check_from_to(from, to)
# function to check the mapping of from to

# Given a 'from' is the 'to' allowed?
input_from <- "PDB"

bad_to <- "A string"
good_to <- "UniProtKB"

bad_to %in% allowed_tos
good_to %in% allowed_tos

## Wrap the above into a function
check_from_to <- function(from, to) {
  valid_froms <- to_from_groups[to_from_groups$from, "name", drop = TRUE]
  valid_tos <- to_from_groups[to_from_groups$to, "name", drop = TRUE]

  uniprotREST:::match.arg.exact(from, valid_froms)
  uniprotREST:::match.arg.exact(to, valid_tos)

  rule_id <- to_from_groups[to_from_groups$name == from, "ruleId", drop = TRUE]

  allowed_tos <- to_from_rules[to_from_rules$ruleId == rule_id, "tos", drop = TRUE]

  if (!to %in% allowed_tos) stop("`to` is invalid.")
}

check_from_to("UniProtKB", "UniProtKB")
check_from_to("UniParc", "aaaaaaaa")
check_from_to("UniParc", "PDB")
check_from_to("UniParc", "UniProtKB")

## Potential approach 2
# named list
# list elements are vectors with allowed tos
test <- dplyr::left_join(to_from_groups, to_from_rules, by = "ruleId") %>%
  dplyr::filter(from) %>%
  dplyr::select(name, tos) %>%
  rev() %>%
  unstack()

# function to check a given from to pair
# from in names of list
# to in collapsed unique list elements
# index list based on from name and check if to is in vector
input_from <- "PDB"

# Check from is valid
input_from %in% names(test)

bad_to <- "A string"
good_to <- "UniProtKB"

# Check to is valid overall
bad_to %in% unique(unlist(test, use.names = FALSE))
good_to %in% unique(unlist(test, use.names = FALSE))

# Check to is valid for the given from
bad_to %in% test[[input_from]]
good_to %in% test[[input_from]]

## Construct and send POST request
rest_url <- "https://rest.uniprot.org/idmapping"

# test_ids <- paste(readLines("dev/map-id-test-input.txt"), collapse = ",")
test_ids <- "Q9NZB2"
test_from <- "UniProtKB_AC-ID"
test_to <- "Ensembl"

post_req <- httr2::request(rest_url) %>%
  httr2::req_user_agent("uniprotREST https://github.com/csdaw/uniprotREST") %>%
  httr2::req_url_path_append("run") %>%
  httr2::req_body_form(
    `from` = test_from,
    `to` = test_to,
    `ids` = test_ids
  )
dry_run <- FALSE
if (dry_run) return(httr2::req_dry_run(post_req)) else
  post_resp <- httr2::req_perform(post_req)

# Extract and print job ID
jobid <- httr2::resp_body_json(post_resp)$jobId
message(paste("Job ID:", jobid))

## Check job status and automatically fetch results if job is complete
## (i.e. HTML status 303 is returned)
## On failure retry every 1 min for 60 min in total
get_req <- httr2::request(rest_url) %>%
  httr2::req_user_agent("uniprotREST https://github.com/csdaw/uniprotREST") %>%
  httr2::req_url_path_append("results", jobid) %>%
  httr2::req_url_query(
    `format` = "tsv",
    `compressed` = FALSE
  )

httr2::req_dry_run(get_req)

get_resp <- httr2::req_perform(get_req, path = "dev/zzzz.txt")

xxx <- read.delim("dev/map-id-test-output.txt")
xxx <- jsonlite::read_json("dev/map-id-test-output.json")

map_uniprot_id <- function(ids, from = "UniProtKB_AC-ID", to = "UniProtKB",
                           format = c("json", "tsv", "xlsx"),
                           path = NULL,
                           fields = NULL,
                           isoform = NULL,
                           compressed = FALSE,
                           dry_run = FALSE) {
  ## Argument checking
  # Check ids and convert to single string if necessary
  if (!is.character(ids)) stop("`ids` must be a string or character vector.")
  if (length(ids) > 1) ids <- paste(ids, collapse = ",")

  # Check from, to, and format arguments
  from <- match.arg.exact(from)
  to <- match.arg.exact(to)
  format <- match.arg.exact(format)

  # Check path is a single string if present
  if (!is.null(path)) {
    if (!is.character(path) & length(path) == 1) stop("`path` must be a single string")
  }

  # Check fields and convert to single string if necessary
  if (!is.null(fields)) {
    if (!is.character(fields)) stop("`fields` must be a string or character vector")
    if (length(fields) > 1) fields <- paste(fields, collapse = ",")
  }

  # Check other arguments
  if (!is.null(isoform)) if (!is.logical(isoform)) stop("`isoform` must be TRUE or FALSE.")
  if (!is.logical(compressed)) stop("`compressed` must be TRUE or FALSE.")
  if (!is.logical(dry_run)) stop("`dry_run` must be TRUE or FALSE.")

  ## Construct and send POST request
  rest_url <- "https://rest.uniprot.org/idmapping"

  post_req <- httr2::request(rest_url) %>%
    httr2::req_user_agent("proteotools https://github.com/csdaw/proteotools") %>%
    httr2::req_url_path_append("run") %>%
    httr2::req_body_form(
      `from` = from,
      `to` = to,
      `ids` = ids,
    )

  if (dry_run) return(httr2::req_dry_run(post_req)) else
    post_resp <- httr2::req_perform(post_req)

  # Extract and print job ID
  jobid <- httr2::resp_body_json(post_resp)$jobId
  message(paste("Job ID:", jobid))

  ## Check job status and automatically fetch results if job is complete
  ## (i.e. HTML status 303 is returned)
  ## On failure retry every 1 min for 60 min in total
  get_req <- httr2::request(rest_url) %>%
    httr2::req_user_agent("proteotools https://github.com/csdaw/proteotools") %>%
    httr2::req_url_path_append("results", jobid) %>%
    httr2::req_url_query(
      `format` = format,
      `fields` = fields,
      `includeIsoform` = isoform,
      `compressed` = compressed
    ) %>%
    httr2::req_retry(max_tries = 60, backoff = ~ 60)

  httr2::req_perform(get_req, path = path)
}
