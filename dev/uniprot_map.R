library(here)
library(magrittr)
source(here("dev", "utils.R"))
source(here("dev", "get_results_stream.R"))
source(here("dev", "resp_body.R"))

input <- readLines(here("dev/map-id-test-input.txt"))[-10:-15]

test <- uniprotREST::uniprot_map(
  ids = input,
  fields = c("accession", "length", "reviewed"),
  size = 50,
  verbosity = 1
)

# Essentially 4 ways to get the output

# 1: Into memory
## 1.1: Streamed
## 1.2: Paginated

# 2: To disk
## 2.1: Streamed
## 2.2: Paginated

# Exactly how these work might differ for different formats. For now I'll just
# consider tsv.

# Two functions:
# 1. get_results_stream(..., format = "", path = NULL)
# 2. get_results_page(..., format = "", path = NULL)
#
# If path is null then save to memory, otherwise save to disk.

#### STREAM INTO MEMORY ####
stream_url <- gsub("results", "results/stream", test$url)

get_results_stream(
  url = stream_url,
  format = "tsv",
  path = here("dev", "test_to_disk", "test_sream_disk2.txt"),
  fields = "accession,reviewed,length",
  isoform = NULL,
  compressed = NULL,
  size = 50,
  verbosity = 1
)

#### STREAM TO DISK ####

test_res <- get_results_stream(
  url = stream_url,
  format = "tsv",
  path = NULL,
  fields = "accession,reviewed,length",
  isoform = NULL,
  compressed = NULL,
  size = 50,
  verbosity = 1
)

#### PAGINATE TO MEMORY ####
# get_next_link <- function(headers) {
#   if ("Link" %in% names(headers)) {
#     gsub('<(.+)>; rel="next"', "\\1", headers$Link)
#   } else {
#     NULL
#   }
# }

source(here("dev", "get_paged_results.R"))

result_url <- test$url

req <- httr2::request(result_url) %>%
  httr2::req_user_agent("uniprotREST https://github.com/csdaw/uniprotREST") %>%
  httr2::req_url_query(
    `format` = "tsv",
    `fields` = "accession,length,reviewed,go_c",
    `compressed` = FALSE,
    `size` = 50
  ) %>%
  httr2::req_error(is_error = function(resp) FALSE)

aaa <- get_paged_results(req, page_size = 50, n_pages = 4, verbosity = 1)

# Check how to parse other formats before putting the methods in get_paged_results
bbb <- aaa %>%
  lapply(resp_body_tsv)
bbb
ccc <- do.call(rbind, bbb)

#### PAGINATE TO DISK ####
get_paged_results_disk <- function(req, page_size, n_pages, verbosity) {
  i <- 1L
  # n_pages <- httr2::req_perform(httr2::req_method(req, "HEAD"), verbosity = verbosity)$headers$`x-total-results`


  # out <- vector("list", length = n_pages)

  file_con <- file(here("dev", "test_to_disk", "test_page_disk.txt"), "w")

  # Keep getting results pages until the Link header disappears (i.e. becomes NULL)
  repeat({
    message(paste("Page", i, "of", n_pages))

    resp <- httr2::req_perform(req, verbosity = verbosity)
    if (resp$status_code == "200") {
      message("Success")

      # perform something different per format

      # TSV
      if (i == 1L) {
        resp$body %>%
          readBin(character()) %>%
          iconv(from = "", to = "UTF-8") %>%
          writeLines(con = file_con, sep = "")
      } else {
        resp$body %>%
          readBin(character()) %>%
          iconv(from = "", to = "UTF-8") %>%
          gsub("^.*?\n", "", .) %>%
          writeLines(con = file_con, sep = "")
      }

      # OTHER
    }
    else
      message(paste("Something went wrong. Status code:", resp$status_code))
    if (i == n_pages) break

    req$url <- get_next_page(resp)
    i <- i + 1L
  })

  close(file_con)
}

req <- httr2::request(result_url) %>%
  httr2::req_user_agent("uniprotREST https://github.com/csdaw/uniprotREST") %>%
  httr2::req_url_query(
    `format` = "tsv",
    `fields` = "accession,length,reviewed,go_c",
    `compressed` = FALSE,
    `size` = 50
  ) %>%
  httr2::req_error(is_error = function(resp) FALSE)

get_paged_results_disk(req, page_size = 50, n_pages = 4, verbosity = 1)

ccc <- read.delim(here("dev", "test_to_disk", "test_page_disk.txt"))
