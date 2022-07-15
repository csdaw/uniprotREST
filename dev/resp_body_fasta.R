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

bbb <- Biostrings::AAStringSet(seqs)

httr2::resp_body_string(tresp) %>%
  Biostrings::AAStringSet()
Biostrings::AAStringSet(tresp$body)
