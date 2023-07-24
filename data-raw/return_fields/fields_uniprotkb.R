library(dplyr)
library(httr2)
library(here)
library(purrr)
library(tibble)

# Get return fields from table in UniProt website
req <- httr2::request("https://rest.uniprot.org/help/return_fields") %>%
  httr2::req_user_agent("https://github.com/csdaw")

resp <- httr2::req_perform(req)

resp_body <- resp %>% httr2::resp_body_json() %>% pluck("content")

# Content is in a single string of markdown which we need to parse

each_line <- unlist(strsplit(resp_body, "\n"))
table_headings <- grep("#|\\|&[^**|^:]", each_line, value = TRUE)[-1]

table_idx <- base::intersect(
  grep("# |\\|", each_line),
  grep("\\*\\*|\\:\\-", each_line, invert = TRUE)
)

table_lines <- each_line[table_idx[-1]]
head(table_lines)

# https://stackoverflow.com/questions/16357962/r-split-numeric-vector-at-position
split_at <- function(x, pos) {
  out <- list()
  pos2 <- c(pos, length(x) + 1)
  for (i in seq_along(pos2[-1])) {
    out[[i]] <- x[pos2[i]:(pos2[i+1] - 1)]
  }
  out
}

splits <- grep("#", table_lines)

tables <- split_at(table_lines, splits)

names(tables) <- gsub(
  "# ",
  "",
  lapply(tables, "[[", 1)
)

tables2 <- lapply(tables, "[", -1)
head(tables2)

# https://gist.github.com/alistaire47/8bf30e30d66fd0a9225d5d82e0922757
tables3 <- lapply(tables2, function(i) {
  i <- gsub('(^\\s*?\\|)|(\\|\\s*?$)', '', i)
  read.delim(text = paste(i, collapse = "\n"),
             sep = "|", strip.white = TRUE,
             header = FALSE)
})
head(tables3)

# add unicarbkb manually for now (need it for thesis)
unicarbkb <- tibble_row(database = "uniprotkb", section = "PTM Databases", field = "xref_unicarbkb", label = "UniCarbKB")

out <- purrr::map_df(tables3, c, .id = "section") %>%
  `colnames<-`(c("section", "label", "old_field", "field")) %>%
  filter(field != "\\<does not exist\\>") %>%
  mutate(field = gsub(" \\\\", "", field),
         database = "uniprotkb") %>%
  select(database, section, field, label) %>%
  add_row(unicarbkb, .after = 157)

# Save to tsv
write.table(
  out,
  file = here("data-raw/return_fields/fields_uniprotkb.tsv"),
  sep = "\t",
  row.names = FALSE,
  col.names = TRUE,
  fileEncoding = "UTF8"
)
