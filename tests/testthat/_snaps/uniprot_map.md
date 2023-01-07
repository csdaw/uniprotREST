# works with paged, to memory

    Code
      result
    Output
          From  Entry Entry.Name Gene.Names..primary.
      1 P99999 P99999  CYC_HUMAN                 CYCS
      2 P12345 P12345 AATM_RABIT                 GOT2

# works with stream, to memory

    Code
      result
    Output
          From  Entry Entry.Name Gene.Names..primary.
      1 P99999 P99999  CYC_HUMAN                 CYCS
      2 P12345 P12345 AATM_RABIT                 GOT2

# works mapping from non-UniProt ID

    Code
      result
    Output
                   From  Entry   Entry.Name Gene.Names..primary.
      1 ENSG00000010404 P22304    IDS_HUMAN                  IDS
      2 ENSG00000010404 E5RHJ1 E5RHJ1_HUMAN                  IDS
      3 ENSG00000010404 H0YB91 H0YB91_HUMAN                  IDS
      4 ENSG00000010404 O60597 O60597_HUMAN                  IDS

# works mapping to non-UniProt ID

    Code
      result
    Output
          From                 To
      1 P99999  ENSG00000172115.9
      2 P99998 ENSPTRG00000018996
      3 P99998 ENSPTRG00000043922

# works with dry run

    Code
      uniprot_map("P99999", dry_run = TRUE)
    Output
      POST /idmapping/run HTTP/1.1
      Host: rest.uniprot.org
      User-Agent: https://github.com/csdaw/uniprotREST
      Accept: */*
      Accept-Encoding: deflate, gzip
      Content-Type: application/x-www-form-urlencoded
      Content-Length: 44
      
      from=UniProtKB_AC-ID&to=UniProtKB&ids=P99999

