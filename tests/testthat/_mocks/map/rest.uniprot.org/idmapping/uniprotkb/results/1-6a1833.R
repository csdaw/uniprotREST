structure(list(method = "GET", url = "https://rest.uniprot.org/idmapping/uniprotkb/results/1?format=tsv&fields=accession,id,gene_primary&cursor=j5xqrofo4&size=1", 
    status_code = 200L, headers = structure(list(Server = "nginx/1.17.7", 
        Vary = "Accept, Accept-Encoding, X-UniProt-Release, X-API-Deployment-Date, User-Agent", 
        `Cache-Control` = "no-cache", `Content-Type` = "text/plain; format=tsv", 
        `Access-Control-Allow-Credentials` = "true", `Content-Encoding` = "gzip", 
        `Access-Control-Expose-Headers` = "Link, X-Total-Results, X-UniProt-Release, X-UniProt-Release-Date, X-API-Deployment-Date", 
        `X-API-Deployment-Date` = "20-December-2022", `Strict-Transport-Security` = "max-age=31536000; includeSubDomains", 
        Date = "Sat, 07 Jan 2023 07:26:18 GMT", `X-UniProt-Release` = "2022_05", 
        `X-Total-Results` = "2", `Transfer-Encoding` = "chunked", 
        `Access-Control-Allow-Origin` = "*", Connection = "keep-alive", 
        `Access-Control-Allow-Methods` = "GET, PUT, POST, DELETE, PATCH, OPTIONS", 
        `Access-Control-Allow-Headers` = "DNT,X-CustomHeader,Keep-Alive,User-Agent,X-Requested-With,If-Modified-Since,Cache-Control,Content-Type,Authorization", 
        `X-UniProt-Release-Date` = "14-December-2022"), class = "httr2_headers"), 
    body = charToRaw("From\tEntry\tEntry Name\tGene Names (primary)\nP12345\tP12345\tAATM_RABIT\tGOT2\n")), class = "httr2_response")
