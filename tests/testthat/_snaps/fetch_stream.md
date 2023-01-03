# fetch_stream works

    Code
      result
    Message <cliMessage>
      <httr2_response>
      GET
      https://rest.uniprot.org/uniref/stream?query=P99999&format=tsv&fields=id%2Cname%2Ccount
      Status: 200 OK
      Content-Type: text/plain
      Body: In memory (154 bytes)

# fetch_stream can parse tsv format

    Code
      result
    Output
              Cluster.ID          Cluster.Name Size
      1 UniRef100_P99999 Cluster: Cytochrome c   18
      2  UniRef50_P99999 Cluster: Cytochrome c  170
      3  UniRef90_P99999 Cluster: Cytochrome c   99

