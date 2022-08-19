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
lst <- uniprot_retrieve(
  id = "P99999",
  database = "uniprotkb",
  format = "json"
)

lst %>% str(max.level = 1)
```

    ## List of 17
    ##  $ entryType               : chr "UniProtKB reviewed (Swiss-Prot)"
    ##  $ primaryAccession        : chr "P99999"
    ##  $ secondaryAccessions     :List of 6
    ##  $ uniProtkbId             : chr "CYC_HUMAN"
    ##  $ entryAudit              :List of 5
    ##  $ annotationScore         : num 5
    ##  $ organism                :List of 4
    ##  $ proteinExistence        : chr "1: Evidence at protein level"
    ##  $ proteinDescription      :List of 1
    ##  $ genes                   :List of 1
    ##  $ comments                :List of 10
    ##  $ features                :List of 36
    ##  $ keywords                :List of 14
    ##  $ references              :List of 19
    ##  $ uniProtKBCrossReferences:List of 177
    ##  $ sequence                :List of 5
    ##  $ extraAttributes         :List of 3

### Retrieve entries via queries

[API description](https://www.uniprot.org/help/api_queries).

``` r
seqs <- uniprot_search(
  query = "Major capsid protein 723",
  format = "fasta",
  method = "paged"
)
```

    ## Page 1 of 1

    ## Success

``` r
seqs
```

    ## AAStringSet object of length 10:
    ##      width seq                                              names               
    ##  [1]  1436 MGARASVLSGGKLDAWEKIRLRP...IIRDYGKQMAGDDCVASRQDED sp|P12499|POL_HV1...
    ##  [2]   418 MSTKLQALRERHNTLVAEVHKIN...QRQGGNLIDAGGAVKYYQNSAT tr|A0A8B6X312|A0A...
    ##  [3]   566 MKTIIALSYILCLVFAQKLPGND...VALLGFIMWACQKGNIRCNICI tr|A0A2D3QNK9|A0A...
    ##  [4]   566 MKAILVVLLYTFATANADTLCIG...VSLGAISFWMCSNGSLQCRICI tr|G2TSP5|G2TSP5_...
    ##  [5]   566 MKTIIALSYILCLVFAQKLPGND...VVLLGFIMWACQKGNIRCNICI tr|Q0R7D7|Q0R7D7_...
    ##  [6]   560 METVSLITILLVVTVSNADKICI...MGFAAFLFWAMSNGSCRCNICI tr|T1S005|T1S005_...
    ##  [7]   116 VMFCIHGSPVNSYFNTPYTGALG...LTLFNLADTLLGGLPTELISSA tr|A0A0N9R076|A0A...
    ##  [8]   326 DRICTGITSSNSPHVVKTATQGE...SKPYYTGEHAKAIGNCPIWVKT tr|A0A0G2S1S8|A0A...
    ##  [9]   344 CTGITSSNSPHVVKTATQGEVNV...KTPLKLANGTKYRPPAKLLKER tr|M1GNV6|M1GNV6_...
    ## [10]   319 YILCLVFAQKLPGNDNSTATLCL...NDKPFQNVNRITYGACPRYVKQ tr|W6HUJ6|W6HUJ6_...

### Map database identifiers

[API description](https://www.uniprot.org/help/id_mapping)

``` r
df <- uniprot_map(
  ids = c("ENSG00000092199", "ENSG00000136997"),
  from = "Ensembl",
  to = "UniProtKB-Swiss-Prot",
  format = "tsv",
  fields = c("accession", "gene_names", "organism_name"),
  method = "stream"
)
```

    ## Job ID: 9fd69708ccefc32b78b8a13d5e126be638cd7f90

``` r
df
```

    ##              From  Entry   Gene.Names             Organism
    ## 1 ENSG00000092199 P07910 HNRNPC HNRPC Homo sapiens (Human)
    ## 2 ENSG00000136997 P01106  MYC BHLHE39 Homo sapiens (Human)
