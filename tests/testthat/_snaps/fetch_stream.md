# dry run shows body

    Code
      uniprot_request("https://rest.uniprot.org/idmapping/run", method = "POST",
        from = "Ensembl", to = "UniProtKB", ids = "P99999") %>% uniprotREST:::fetch_stream(
        dry_run = TRUE)
    Output
      POST /idmapping/run HTTP/1.1
      Host: rest.uniprot.org
      User-Agent: uniprotREST https://github.com/csdaw/uniprotREST
      Accept: */*
      Accept-Encoding: deflate, gzip
      Content-Type: application/x-www-form-urlencoded
      Content-Length: 36
      
      from=Ensembl&to=UniProtKB&ids=P99999

