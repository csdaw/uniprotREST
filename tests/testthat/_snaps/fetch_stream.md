# fetch_stream works with tsv format

    Code
      fetch_stream(req, parse = FALSE, verbosity = 0)
    Message <cliMessage>
      <httr2_response>
      GET
      https://rest.uniprot.org/uniref/stream?query=P99999&format=tsv&fields=id%2Cname%2Ccount
      Status: 200 OK
      Content-Type: text/plain
      Body: In memory (154 bytes)

---

    Code
      fetch_stream(req, parse = TRUE, verbosity = 0)
    Output
              Cluster.ID          Cluster.Name Size
      1 UniRef100_P99999 Cluster: Cytochrome c   18
      2  UniRef50_P99999 Cluster: Cytochrome c  170
      3  UniRef90_P99999 Cluster: Cytochrome c   99

