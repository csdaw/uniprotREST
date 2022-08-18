library(here)
library(magrittr)

get_req <- httr2::request("https://rest.uniprot.org/uniprotkb/search") %>%
  httr2::req_url_query(
    query = "Major capsid protein 2073",
    size = 2L,
    format = "fasta"
  )



#### functions ####
str2fasta <- function(x, biostrings = TRUE) {
  xlines <- unlist(strsplit(x, "\n"))

  hdr_idx <- grep(">", xlines)

  seq_idx <- data.frame(
    hdr = hdr_idx,
    from = hdr_idx + 1,
    to = c((hdr_idx - 1)[-1], length(xlines))
  )

  seqs <- vector(mode = "character", length = length(hdr_idx))

  for (i in seq_along(hdr_idx)) {
    seqs[i] <- paste(xlines[seq_idx$from[i]:seq_idx$to[i]], collapse = "")
  }

  names(seqs) <- substring(xlines[hdr_idx], 2)

  if (biostrings && requireNamespace("Biostrings", quietly = TRUE)) {
    Biostrings::AAStringSet(seqs)
  } else {
    seqs
  }
}

resp_body_fasta_paged <- function(resp, con, encoding = NULL) {
  uniprotREST:::check_response(resp)

  if (is.null(encoding)) encoding <- httr2::resp_encoding(resp)

  if (!is.null(con)) {
    resp$body %>%
      readBin(character()) %>%
      iconv(from = encoding, to = "UTF-8") %>%
      writeLines(con = con, sep = "")
  } else {
    resp$body %>%
      readBin(character()) %>%
      iconv(from = encoding, to = "UTF-8") %>%
      strsplit(split = "\n")
  }
}

resp_body_fasta <- function(resp, biostrings = TRUE, encoding = NULL) {
  uniprotREST:::check_response(resp)

  if (is.null(encoding)) encoding <- httr2::resp_encoding(resp)

  resp$body %>%
    readBin(character()) %>%
    iconv(from = encoding, to = "UTF-8") %>%
    str2fasta(biostrings = TRUE)
}

#### method = paged ####
## to disk = also straightforward
source(here("dev/get_results_paged.R"))

get_results_paged(
  req = get_req,
  n_pages = 2,
  format = "fasta",
  path = here("dev/test_to_disk/fasta_paged.fasta"),
  verbosity = 1
)

Biostrings::readAAStringSet(here("dev/test_to_disk/fasta_paged.fasta"))
# or
str2fasta(readLines(here("dev/test_to_disk/fasta_paged.fasta")), biostrings = FALSE)

## to memory
debugonce(get_results_paged_mem)
test <- get_results_paged(
  req = get_req,
  n_pages = 2,
  format = "fasta",
  path = NULL,
  verbosity = 1
)

#### method = stream ####
## to disk = straightforward
httr2::req_perform(get_req, path = here("dev/test_to_disk/fasta_stream.fasta"), verbosity = 1)

Biostrings::readAAStringSet(here("dev/test_to_disk/fasta_stream.fasta"))
# or
str2fasta(readLines(here("dev/test_to_disk/fasta_stream.fasta")), biostrings = FALSE)

## to memory
get_resp <- httr2::req_perform(get_req, verbosity = 1)

str2fasta(get_resp %>% httr2::resp_body_string())
# or
str2fasta(get_resp %>% httr2::resp_body_string(), biostrings = FALSE)








xxx <- c(
  ">protein1
AAAAAAAAA
>protein2
BBBBBBBBB"
)

Biostrings::AAStringSet(x = xxx, start = 2)

treq <- httr2::request("https://rest.uniprot.org/uniprotkb/search?format=fasta&query=Major%20capsid%20protein%20723&size=500")

tresp <- httr2::req_perform(treq)

library(magrittr)

aaa <- tresp %>%
  httr2::resp_body_string() %>%
  strsplit("\n") %>%
  unlist()

# https://stackoverflow.com/questions/26843995/r-read-fasta-files-into-data-frame-using-base-r-not-biostrings-and-the-like
ind <- grep(">", aaa)

s <- data.frame(ind = ind,
                from = ind + 1,
                to = c((ind - 1)[-1], length(ind)))

seqs <- vector(mode = "character", length = length(ind))

for (i in seq_along(ind)) {
  seqs[i] <- paste(aaa[s$from[i]:s$to[i]], collapse = "")
}

hdrs <- aaa[ind]

names(seqs) <- substring(hdrs, 2)

seqs

bbb <- Biostrings::AAStringSet(seqs)

httr2::resp_body_string(tresp) %>%
  Biostrings::AAStringSet()
Biostrings::AAStringSet(tresp$body)

resp_body_fasta <- function(resp, encoding = NULL) {
  check_response(resp)

  if (is.null(encoding)) encoding <- httr2::resp_encoding(resp)

  if (length(resp$body) == 0) {
    stop("Can not retrieve empty body")
  }

  txt <- resp$body %>%
    readBin(character()) %>%
    iconv(from = encoding, to = "UTF-8") %>%
    strsplit("\n") %>%
    unlist()

  header_idx <- grep(">", txt)

  seqs_idx <- data.frame(ind = ind,
                         from = ind + 1,
                         to = c((ind - 1)[-1], length(ind)))

  seqs <- vector(mode = "character", length = length(ind))

  for (i in seq_along(header_idx)) {
    seqs[i] <- paste(txt[seqs_idx$from[i]:seqs_idx$to[i]], collapse = "")
  }

  names(seqs) <- substr(txt[header_idx], 2)

  if (requireNamespace("Biostrings", quietly = TRUE)) {
    Biostrings::AAStringSet(seqs)
  } else {
    seqs
  }
}
