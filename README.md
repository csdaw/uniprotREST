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

### Retrieve individual entries

[API description](https://www.uniprot.org/help/api_retrieve_entries)

``` r
resp <- uniprot_retrieve(
  id = "P99999",
  database = "uniprotkb",
  format = "json"
)

result <- httr2::resp_body_json(resp) %>% 
  str(max.level = 1)
```

    ## List of 17
    ##  $ entryType               : chr "UniProtKB reviewed (Swiss-Prot)"
    ##  $ primaryAccession        : chr "P99999"
    ##  $ secondaryAccessions     :List of 6
    ##  $ uniProtkbId             : chr "CYC_HUMAN"
    ##  $ entryAudit              :List of 5
    ##  $ annotationScore         : num 263
    ##  $ organism                :List of 4
    ##  $ proteinExistence        : chr "1: Evidence at protein level"
    ##  $ proteinDescription      :List of 1
    ##  $ genes                   :List of 1
    ##  $ comments                :List of 10
    ##  $ features                :List of 36
    ##  $ keywords                :List of 14
    ##  $ references              :List of 19
    ##  $ uniProtKBCrossReferences:List of 175
    ##  $ sequence                :List of 5
    ##  $ extraAttributes         :List of 3

### Retrieve entries via queries

[API description](https://www.uniprot.org/help/api_queries).

``` r
resp <- uniprot_search(
  query = "Major capsid protein 723",
  format = "tsv", 
  fields = c("accession", "gene_primary", "length")
)

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

[API description](https://www.uniprot.org/help/id_mapping)

``` r
resp <- uniprot_map(
  ids = c("ENSG00000092199", "ENSG00000136997"),
  from = "Ensembl",
  to = "UniProtKB-Swiss-Prot",
  format = "tsv",
  fields = c("accession", "gene_names", "organism_name")
)
```

    ## Job ID: 9fd69708ccefc32b78b8a13d5e126be638cd7f90

``` r
result <- httr2::resp_body_string(resp) %>% 
  read.delim(text = .)

result
```

    ##              From  Entry   Gene.Names             Organism
    ## 1 ENSG00000092199 P07910 HNRNPC HNRPC Homo sapiens (Human)
    ## 2 ENSG00000136997 P01106  MYC BHLHE39 Homo sapiens (Human)
