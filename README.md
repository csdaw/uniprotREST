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

### Retrieving individual entries

Placeholder.

### Retrieving entries via queries

[API description](https://beta.uniprot.org/help/api_queries).

``` r
library(uniprotREST)
library(magrittr)

resp <- search_uniprot(query = "Major capsid protein 723",
                       format = "tsv", 
                       fields = c("accession", "gene_primary", "length"))

result <- httr2::resp_body_string(resp) %>% 
  read.delim(text = .)

head(result)
```

    ##        Entry Gene.Names..primary. Length
    ## 1     P12499              gag-pol   1436
    ## 2 A0A2D3QNK9                   HA    566
    ## 3     G2TSP5                   HA    566
    ## 4     Q0R7D7                   HA    566
    ## 5     T1S005                   HA    560
    ## 6 A0A0G2S1S8                   HA    326

### Mapping database identifiers

Placeholder.