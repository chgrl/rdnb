#' @title Search the DNB catalogue - simple search
#' @description \code{dnb_search} exposes a search in the DNB catalogue. 
#' @param title the title (including subtitle, short title, volume title, etc.); single string value or vector of strings.
#' @param author the author(s); single string value or vector of strings.
#' @param year the year of publishing; single integer value or vector of integers.
#' @param publisher the publisher (publisher name and/or location); single string value or vector of strings.
#' @param keyword one or a set of keywords describing the work (subjects, persons, locations, organisations, etc.); single string value or vector of strings.
#' @param type the type of publication, one or a vector of articles, manuscript, biographicaldoc, letters, bequest, collections, books, brailles, maps, discs, dissertations, online, films, microfiches, multimedia, music, scores, serials, persons, subjects, corperations, works, events, geographics.
#' @param language the language of the work by ISO 639-2/B code (\url{http://www.dnb.de/SharedDocs/Downloads/DE/DNB/standardisierung/inhaltserschliessung/sprachenCodesEnglisch.pdf?__blob=publicationFile}); single string value or vector of strings.
#' @param print if \code{TRUE} the search results are printed (default is \code{FALSE}).
#' @return A list of results with metadata.
#' @details to do
#' @source \url{http://www.dnb.de/EN/Service/DigitaleDienste/SRU/sru_node.html}
#' @export
#' @examples
#' \dontrun{
#' }
dnb_search <- function(title, author, year, publisher, keyword, type, language, print=FALSE) {		
	# prepare title
	if(!missing(title)) {
		title <- paste0("tit=", title)
		title <- paste0("(", title, ")")
	} else title <- NULL
	
	# prepare author
	if(!missing(author)) {
		author <- paste0("atr=", author)
		author <- paste0("(", author, ")")
	} else author <- NULL
	
	# prepare year
	if(!missing(year)) {
		year <- paste0("jhr=", year)
		year <- paste0("(", year, ")")
	} else year <- NULL
	
	# prepare publisher
	if(!missing(publisher)) {
		publisher <- paste0("vlg=", publisher)
		publisher <- paste0("(", publisher, ")")
	} else publisher <- NULL
	
	# prepare keyword
	if(!missing(keyword)) {
		keyword <- paste0("sw=", keyword)
		keyword <- paste0("(", keyword, ")")
	} else keyword <- NULL
	
	# prepare type
	if(!missing(type)) {
		avail.types <- c("articles", "manuscript", "biographicaldoc", "letters", "bequest", "collections", "books", "brailles", "maps", "discs", "dissertations", "online", "films", "microfiches", "multimedia", "music", "scores", "serials", "persons", "subjects", "corperations", "works", "events", "geographics")
		type <- avail.types[pmatch(type, avail.types)]		
		type <- paste0("mat=", type)
		type <- paste0("(", type, ")")
	} else type <- NULL
	
	# prepare language
	if(!missing(language)) {
		language <- paste0("spr=", language)
		language <- paste0("(", language, ")")
	} else language <- NULL
	
	# build query
	query <- paste(title, author, year, publisher, keyword, type, language)
	
	# make request
  req <- dnb_get_url(path="sru/dnb", query=query)
  raw <- dnb_parse(req)
  
  # return
  if(print) print(raw)
  invisible(raw)
}


#' @title Search the DNB catalogue - advanced search
#' @description \code{dnb_search} exposes a search in the DNB catalogue. 
#' @param query the main search query; single string value or vector of strings.
#' @param genre the bibliographic genre to ; single string value or vector of strings.
#' @param print if \code{TRUE} the search results are printed (default is \code{FALSE}).
#' @return A list of results with metadata.
#' @details to do
#' @source \url{http://www.dnb.de/EN/Service/DigitaleDienste/SRU/sru_node.html}
#' @export
#' @examples
#' \dontrun{
#' }
dnb_advanced <- function(query, print=FALSE) {		
	# make request
  req <- dnb_get_url(path="sru/dnb", query=query)
  raw <- dnb_parse(req)
  
  # return
  if(print) print(raw)
  invisible(raw)
}