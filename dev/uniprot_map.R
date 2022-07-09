library(here)
library(magrittr)
source(here("dev", "utils.R"))
source(here("dev", "resp_body_tsv.R"))
source(here("dev", "get_results_stream.R"))
source(here("dev", "get_results_paged.R"))
source(here("dev", "get_results_paged_disk.R"))
source(here("dev", "get_results_paged_mem.R"))

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

#### STREAM INTO DISK ####
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

#### STREAM TO MEMORY ####

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
result_url <- test$url

n_pages <- ceiling(as.integer(test$headers$`x-total-results`) / 50)

test_res2 <- get_results_paged(
  url = result_url,
  n_pages = n_pages,
  format = "tsv",
  path = NULL,
  fields = "accession,reviewed,length",
  isoform = NULL,
  compressed = NULL,
  size = 50,
  verbosity = 1
)

#### PAGINATE TO DISK ####
test_res2 <- get_results_paged(
  url = result_url,
  n_pages = n_pages,
  format = "tsv",
  path = here("dev", "test_to_disk", "test_page_disk2.txt"),
  fields = "accession,reviewed,length",
  isoform = NULL,
  compressed = NULL,
  size = 50,
  verbosity = 1
)
