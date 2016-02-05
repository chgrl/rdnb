#' @title Search the DNB catalogue
#' @description \code{dnb_search} exposes a search in the DNB catalogue. 
#' @param query the main search query; single string value or vector of strings.
#' @param print if \code{TRUE} (default) the search results are printed.
#' @return to do
#' @details to do
#' @source \url{http://www.dnb.de/EN/Service/DigitaleDienste/SRU/sru_node.html}
#' @export
#' @examples
#' \dontrun{
#' }
dnb_search <- function(query, print=TRUE) {		
	# make request
  req <- dnb_get_url(path="sru/dnb", query=query)
  raw <- dnb_parse(req)
  
  # return
  if(print) print(raw)
  invisible(raw)
}