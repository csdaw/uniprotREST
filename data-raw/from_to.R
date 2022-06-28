## Load libraries
library(purrr)
library(dplyr)

## Get from/to databases from UniProt
# See https://www.uniprot.org/help/id_mapping for a description of this
# file and how to use it

# Download json with all possible database from/to pairs
curl::curl_download("https://rest.uniprot.org/configure/idmapping/fields",
                    destfile = "data-raw/from_to.json")

# Load JSON
from_to_json <- jsonlite::read_json("data-raw/from_to.json")

# Extract table with list of databases
from_to_groups <- from_to_json %>%
  pluck("groups") %>%
  map_dfr(pluck, 2)

# Extract 'rules' for each database
from_to_rules <- from_to_json %>%
  pluck("rules") %>%
  map(function(i) modify_at(i, "tos", flatten_chr)) %>%
  map_dfr(~ .x)

## Clean up from/to data.frame and save as rds
## (exported object)
## To do: add example of each identifier
from_to <- from_to_groups %>%
  select(name, from, to, uriLink) %>%
  rename("url" = uriLink) %>%
  as.data.frame()

usethis::use_data(from_to, internal = FALSE, overwrite = TRUE)

## Combine from/to groups and rules into list and save as rds
## (internal object exposed via function)
from_to_list <- left_join(from_to_groups, from_to_rules, by = "ruleId") %>%
  filter(from) %>%
  select(name, tos) %>%
  rev() %>%
  unstack()

usethis::use_data(from_to_list, internal = TRUE, overwrite = TRUE)
