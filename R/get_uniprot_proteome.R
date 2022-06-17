#' Download canonical reference proteome from UniProt FTP server
#'
#' @description To do: write proper description. See
#' [here](https://pwilmart.github.io/blog/2020/09/19/shotgun-quantification-part2)
#' for description of the FTP canonical reference proteomes. Use
#' \code{\link{cur_uniprot_proteomes}} to see the table of available proteomes
#' to download.
#'
#' @param id `string`, UniProt proteome ID e.g. `UP000005640` for _Homo sapiens_.
#' @param format `string`, desired file format to download. Choose from:
#' `fasta` (default), `dat`, `xml`, `gene2acc`, `idmapping`, `DNA.fasta`, `DNA.miss`.
#' See [here](https://ftp.uniprot.org/pub/databases/uniprot/current_release/knowledgebase/reference_proteomes/README)
#' for a description of each file type.
#' @param path Optional `string`. Path to save the downloaded file.
#' @param isoform `logical`, should the file with isoform sequences be downloaded?
#' Only applicable for the `fasta`, `dat`, and `xml` formats. Default is `FALSE`.
#' @param dry_run `logical`, default is `FALSE`. If `TRUE` print the HTTP
#' request using \code{\link[httr2]{req_dry_run}} without actually sending
#' anything to the UniProt server. Useful for debugging if you get an HTTP 400
#' Bad Request error i.e. `id` was not written correctly, or if you get an
#' HTTP 404 Not found error i.e. the desired `format` is not available for your
#' proteome of interest.
#'
#' @return If the request was successful (i.e. the request was successfully
#' performed and a response with HTTP status code <400 was received), an HTTP
#' response is returned; otherwise an error is thrown. Use the `path` argument
#' to save the body of the response to a file.
#'
#' If `dry_run = TRUE`, then prints the HTTP request and returns,
#' invisibly, a list containing information about the request without actually
#' sending anything to the UniProt server.
#' @export
#'
#' @examples
#'
#' \dontrun{
#' get_uniprot_proteome("UP000005640", "fasta", "./Homo_sapiens_canonical.fasta")
#' }
#'
get_uniprot_proteome <- function(id,
                                 format = c("fasta", "dat", "xml", "gene2acc", "idmapping", "DNA.fasta", "DNA.miss"),
                                 path = NULL,
                                 isoform = FALSE,
                                 dry_run = FALSE) {
  ## Argument checking
  # Check id is single string
  if (!is.character(id) & length(id) == 1) stop("`query` must be single string.")

  # Check format is okay
  match.arg.exact(format)

  # Check path is a single string if present
  if (!is.null(path)) {
    if (!is.character(path) & length(path) == 1) stop("`path` must be a single string")
  }

  # Check isoform is okay
  if (!is.null(isoform)) {
    if (!is.logical(isoform)) stop("`isoform` must be TRUE or FALSE.")
    if (isoform & !format %in% c("fasta", "dat", "xml")) stop("`isoform` data only available for the following formats: fasta, dat, xml.")
  }

  ## Access FTP server
  # Given a provided proteome id e.g. UP000005640, need to obtain the correct
  # superregnum and taxon ID to construct the URL
  proteome_info <- search_uniprot(
    query = paste0("upid:", id),
    database = "proteomes",
    format = "tsv",
    fields = c("organism_id", "lineage")
  ) %>%
    httr2::resp_body_string() %>%
    utils::read.delim(text = .)

  superregnum <- sub("(\\w+).*", "\\1", proteome_info$Taxonomic.lineage)
  taxon_id <- proteome_info$Organism.Id

  # These are the actual available file formats
  available_formats <- list(
    "fasta" = ".fasta.gz",
    "dat" = ".dat.gz",
    "xml" = ".xml.gz",
    "gene2acc" = ".gene2acc.gz",
    "idmapping" = ".idmapping.gz",
    "DNA.fasta" = "_DNA.fasta.gz",
    "DNA.miss" = "_DNA.miss.gz"
  )

  file_ext <- available_formats[[format]]
  if (isoform) file_ext <- paste0("_additional", file_ext)

  # Construct name of file to download
  file_name <- paste0(id, "_", taxon_id, file_ext)

  # Construct FTP download request
  req <- httr2::request("https://ftp.uniprot.org/pub/databases/uniprot/current_release/knowledgebase/reference_proteomes/") %>%
    httr2::req_user_agent("proteotools https://github.com/csdaw/proteotools") %>%
    httr2::req_url_path_append(superregnum, id, file_name)

  # Download reference proteome
  if (dry_run) httr2::req_dry_run(req) else
    httr2::req_perform(req, path = path)
}
