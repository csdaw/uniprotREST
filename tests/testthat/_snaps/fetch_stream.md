# can parse tsv format

    Code
      result
    Output
              Cluster.ID          Cluster.Name Size
      1 UniRef100_P99999 Cluster: Cytochrome c   18
      2  UniRef50_P99999 Cluster: Cytochrome c  170
      3  UniRef90_P99999 Cluster: Cytochrome c   99

# can parse json format

    Code
      str(result, max.level = 3)
    Output
      List of 1
       $ results:List of 3
        ..$ :List of 3
        .. ..$ id                  : chr "UniRef100_P99999"
        .. ..$ name                : chr "Cluster: Cytochrome c"
        .. ..$ representativeMember:List of 1
        ..$ :List of 3
        .. ..$ id                  : chr "UniRef50_P99999"
        .. ..$ name                : chr "Cluster: Cytochrome c"
        .. ..$ representativeMember:List of 1
        ..$ :List of 3
        .. ..$ id                  : chr "UniRef90_P99999"
        .. ..$ name                : chr "Cluster: Cytochrome c"
        .. ..$ representativeMember:List of 1

# can parse fasta format

    Code
      result
    Output
      AAStringSet object of length 3:
          width seq                                               names               
      [1]   105 MGDVEKGKKIFIMKCSQCHTVEK...FVGIKKKEERADLIAYLKKATNE UniRef100_P99999 ...
      [2]   105 MGDVEKGKKIFIMKCSQCHTVEK...FVGIKKKEERADLIAYLKKATNE UniRef50_P99999 C...
      [3]   105 MGDVEKGKKIFIMKCSQCHTVEK...FVGIKKKEERADLIAYLKKATNE UniRef90_P99999 C...

