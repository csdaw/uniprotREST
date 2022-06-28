library(httr2)
library(dplyr)
library(purrr)

# https://stackoverflow.com/questions/61220346/web-scraping-with-rvest-and-xml2
req <- httr2::request("https://rest.uniprot.org/help/return_fields") %>%
  httr2::req_user_agent("https://github.com/csdaw")

resp <- httr2::req_perform(req)

aaa <- resp %>% httr2::resp_body_json()
bbb <- aaa$content
ccc <- unlist(strsplit(bbb, "\n"))
ddd <- grep("#|\\|&[^**|^:]", ccc, value = TRUE)[-1]

idx <- base::intersect(
  grep("# |\\|", ccc),
  grep("\\*\\*|\\:\\-", ccc, invert = TRUE)
)

ddd <- ccc[idx[-1]]
head(ddd)

# https://stackoverflow.com/questions/16357962/r-split-numeric-vector-at-position
split_at <- function(x, pos) {
  out <- list()
  pos2 <- c(pos, length(x) + 1)
  for (i in seq_along(pos2[-1])) {
    out[[i]] <- x[pos2[i]:(pos2[i+1] - 1)]
  }
  out
}

splits <- grep("#", ddd)

eee <- split_at(ddd, splits)

names(eee) <- gsub(
  "# ",
  "",
  lapply(eee, "[[", 1)
)

fff <- lapply(eee, "[", -1)
fff

# https://gist.github.com/alistaire47/8bf30e30d66fd0a9225d5d82e0922757
ggg <- lapply(fff, function(i) {
  i <- gsub('(^\\s*?\\|)|(\\|\\s*?$)', '', i)
  read.delim(text = paste(i, collapse = "\n"),
             sep = "|", strip.white = TRUE,
             header = FALSE)
})

hhh <- purrr::map_df(ggg, c, .id = "section") %>%
  `colnames<-`(c("section", "name", "old_field", "field")) %>%
  rev() %>%
  select(-old_field) %>%
  filter(field != "\\<does not exist\\>") %>%
  mutate(field = gsub(" \\\\", "", field))
