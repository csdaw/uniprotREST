get_to_db <- function(to) {
  lookup_df <- data.frame(
    to = c("UniProtKB", "UniProtKB-Swiss-Prot",
           "UniRef100", "UniRef90", "UniRef50",
           "UniParc"),
    db = c(rep("uniprotkb", 2),
           rep("uniref", 3),
           "uniparc")
  )

  if (!to %in% lookup_df$to) {
    return("")
  } else {
    lookup_df[lookup_df$to == to, "db"]
  }
}

