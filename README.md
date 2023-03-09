uniprotREST
================

<!-- badges: start -->

[![Project Status: Active – The project has reached a stable, usable
state and is being actively
developed.](https://www.repostatus.org/badges/latest/active.svg)](https://www.repostatus.org/#active)
<!-- badges: end -->

This package provides an R wrapper for the [UniProt website REST
API](https://www.uniprot.org/help/api).

## Installation

Install the latest development version from GitHub:

``` r
remotes::install_github("csdaw/uniprotREST", build_vignettes = TRUE)
```

## Documentation

Read the full documentation
[here](https://csdaw.github.io/uniprotREST/articles/uniprotREST.html).

## Quick start

``` r
library(uniprotREST)
```

### ID mapping with `uniprot_map()`

Map to/from UniProt IDs. This function wraps the [ID
mapping](https://www.uniprot.org/help/id_mapping) API endpoint.

``` r
# Proteins of interest (from 3 different taxa)
ids <- c("P99999", "P12345", "P23456")

# Get accessions, gene names and sequence lengths
result <- uniprot_map(
  ids = ids, 
  from = "UniProtKB_AC-ID",
  to = "UniProtKB",
  format = "tsv",
  fields = c("accession", "gene_primary", "length")
)
```

    ## Running job: fb7778b417ab8f889e11f4ffb4a602bf8fecef13 
    ##  Downloading: page 1 of 1

``` r
result
```

    ##     From  Entry Gene.Names..primary. Length
    ## 1 P99999 P99999                 CYCS    105
    ## 2 P12345 P12345                 GOT2    430
    ## 3 P23456 P23456                    L   2151

### Querying UniProt with `uniprot_search()`

Perform text searches against UniProt databases. This function wraps the
[Query](https://www.uniprot.org/help/api_queries) API endpoint.

``` r
# Get human glycoproteins less than 100 amino acids long

result <- uniprot_search(
  query = "(proteome:UP000005640) AND (keyword:KW-0325) AND (length<100)",
  database = "uniprotkb",
  format = "tsv",
  fields = c("accession", "gene_primary")
)
```

    ##  Downloading: page 1 of 1

``` r
head(result)
```

    ##    Entry Gene.Names..primary.
    ## 1 P06028                 GYPB
    ## 2 P80098                 CCL7
    ## 3 Q16627                CCL14
    ## 4 P0DMC3                APELA
    ## 5 P25063                 CD24
    ## 6 P31358                 CD52

### Retrieving an entry with `uniprot_single()`

Download the full entry for a single protein. This function wraps the
[Retrieve](https://www.uniprot.org/help/api_retrieve_entries) API
endpoint.

``` r
# Human cytochrome C
result <- uniprot_single(
  id = "P99999",
  database = "uniprotkb",
  format = "json",
  verbosity = 0
)

str(result, max.level = 1)
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
    ##  $ uniProtKBCrossReferences:List of 179
    ##  $ sequence                :List of 5
    ##  $ extraAttributes         :List of 3

## Metadata

- Please [report any issues or
  bugs](https://github.com/csdaw/uniprotREST/issues) ideally with a
  [reproducible example](https://reprex.tidyverse.org/)
- This project is released with a [Contributor Code of
  Conduct](https://pkgdown.r-lib.org/CODE_OF_CONDUCT.html). By
  participating in this project you agree to abide by its terms.
- Author: Charlotte Dawson
- License: MIT
