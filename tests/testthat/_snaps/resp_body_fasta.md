# works with single reponse

    Code
      resp_body_fasta(resp)
    Output
      AAStringSet object of length 2:
          width seq                                               names               
      [1]     3 AAA                                               Protein1
      [2]     3 CCC                                               Protein2

# works with paged response

    Code
      Biostrings::readAAStringSet(tmp)
    Output
      AAStringSet object of length 3:
          width seq                                               names               
      [1]     3 AAA                                               Protein1
      [2]    15 CCC>Protein1AAA                                   Protein2
      [3]     3 CCC                                               Protein2

