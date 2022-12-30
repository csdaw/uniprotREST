uniprotREST
================

<!-- badges: start -->

[![Project Status: WIP – Initial development is in progress, but there
has not yet been a stable, usable release suitable for the
public.](https://www.repostatus.org/badges/latest/wip.svg)](https://www.repostatus.org/#wip)
[![Lifecycle:
experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://lifecycle.r-lib.org/articles/stages.html#experimental)
![License: MIT](https://img.shields.io/github/license/csdaw/uniprotREST)
<!-- badges: end -->

An R interface for the new UniProt REST API.

## Overview

Placeholder.

``` r
library(uniprotREST)
library(magrittr)
```

### Retrieve single entries

[API description](https://www.uniprot.org/help/api_retrieve_entries)

``` r
# lst <- uniprot_single(
#   id = "P99999",
#   database = "uniprotkb",
#   format = "json"
# )
# 
# lst %>% str(max.level = 1)
```

### Retrieve entries via queries

[API description](https://www.uniprot.org/help/api_queries).

``` r
# seqs <- uniprot_search(
#   query = "Major capsid protein 723",
#   format = "fasta",
#   method = "paged"
# )
# 
# seqs
```

### Map database identifiers

[API description](https://www.uniprot.org/help/id_mapping)

``` r
# df <- uniprot_map(
#   ids = c("ENSG00000092199", "ENSG00000136997"),
#   from = "Ensembl",
#   to = "UniProtKB-Swiss-Prot",
#   format = "tsv",
#   fields = c("accession", "gene_names", "organism_name"),
#   method = "stream"
# )
# 
# df
```
