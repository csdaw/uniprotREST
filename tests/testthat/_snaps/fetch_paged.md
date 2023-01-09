# works with tsv format

    Code
      fetch_paged(req, format = "tsv", n_pages = 3)
    Output
       Downloading: page 1 of 3 Downloading: page 2 of 3 Downloading: page 3 of 3
              Cluster.ID          Cluster.Name Size
      1 UniRef100_P99999 Cluster: Cytochrome c   18
      2  UniRef50_P99999 Cluster: Cytochrome c  170
      3  UniRef90_P99999 Cluster: Cytochrome c   99

# works with fasta format

    Code
      fetch_paged(req, format = "fasta", n_pages = 3)
    Output
       Downloading: page 1 of 3 Downloading: page 2 of 3 Downloading: page 3 of 3
      AAStringSet object of length 3:
          width seq                                               names               
      [1]   105 MGDVEKGKKIFIMKCSQCHTVEK...FVGIKKKEERADLIAYLKKATNE UniRef100_P99999 ...
      [2]   105 MGDVEKGKKIFIMKCSQCHTVEK...FVGIKKKEERADLIAYLKKATNE UniRef50_P99999 C...
      [3]   105 MGDVEKGKKIFIMKCSQCHTVEK...FVGIKKKEERADLIAYLKKATNE UniRef90_P99999 C...

