# works with single reponse

    Code
      resp_body_tsv(resp)
    Output
         Entry Gene.Names..primary.
      1 P99999                 CYCS

# works with paged response

    Code
      read.delim(tmp)
    Output
         Entry Gene.Names..primary.
      1 P99999                 CYCS
      2 P99999                 CYCS

