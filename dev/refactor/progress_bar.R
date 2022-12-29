library(httr2)

# slightly modified from httr package
progress_bar <- function(type) {
  bar <- NULL

  show_progress <- function(down, up) {
    if (type == "down") {
      total <- down[[1]]
      now <- down[[2]]
    } else {
      total <- up[[1]]
      now <- up[[2]]
    }

    if (total == 0 && now == 0) {
      # Reset progress bar when seeing first byte
      bar <<- NULL
    } else if (total == 0) {
      cat("\rDownloading: ", httr:::bytes(now, digits = 2), "     ", sep = "")
      utils::flush.console()
      # Can't automatically add newline on completion because there's no
      # way to tell when then the file has finished downloading
    } else {
      if (is.null(bar)) {
        bar <<- utils::txtProgressBar(max = total, style = 3)
      }
      utils::setTxtProgressBar(bar, now)
      if (now == total) close(bar)
    }

    TRUE
  }

  show_progress
}

# https://github.com/r-lib/httr/blob/21ff69f219ad11298854a63b8f753389088cf382/R/progress.R
resp_normal <- request("https://rest.uniprot.org/uniprotkb/P99999?fields=accession,gene_names&format=tsv") %>%
  httr2::req_options(noprogress=FALSE, progressfunction=progress_bar("down")) %>%
  httr2::req_perform()

httr2::resp_body_string(resp_normal)

resp_large <- request("https://rest.uniprot.org/uniprotkb/stream?fields=accession%2Cid%2Cgene_names%2Cgene_oln%2Cgene_orf%2Cgene_primary%2Cgene_synonym%2Corganism_name%2Corganism_id%2Cprotein_name%2Cxref_proteomes%2Clineage%2Clineage_ids%2Cvirus_hosts&format=tsv&query=%28candida%20albicans%29%20AND%20%28reviewed%3Atrue%29") %>%
  httr2::req_options(noprogress=FALSE, progressfunction=progress_bar("down")) %>%
  httr2::req_perform()

# slow
testit <- function(x = sort(runif(20)), ...)
{
  pb <- txtProgressBar(...)
  for(i in c(0, x, 1)) {Sys.sleep(0.5); setTxtProgressBar(pb, i)}
  Sys.sleep(1)
  close(pb)
}
testit()
testit(runif(10))
testit(style = 3)
testit(char=' \u27a4')
