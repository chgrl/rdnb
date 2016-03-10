#' @title Search the DNB catalogue - simple search
#' @description \code{dnb_search} exposes a search in the DNB catalogue. 
#' @param title the title (including subtitle, short title, volume title, etc.); optional single string value or vector of strings.
#' @param author the author(s); optional single string value or vector of strings.
#' @param year the year of publishing; optional single integer value or vector of integers.
#' @param publisher the publisher (publisher name and/or location); optional single string value or vector of strings.
#' @param keyword one or a set of keywords describing the work (subjects, persons, locations, organisations, etc.); optional single string value or vector of strings.
#' @param type the type of publication (optional), one or a vector of \code{articles}, \code{manuscript}, \code{biographicaldoc}, \code{letters}, \code{bequest}, \code{collections}, \code{books}, \code{brailles}, \code{maps}, \code{discs}, \code{dissertations}, \code{online}, \code{films}, \code{microfiches}, \code{multimedia}, \code{music}, \code{scores}, \code{serials}, \code{persons}, \code{subjects}, \code{corperations}, \code{works}, \code{events}, \code{geographics}.
#' @param language the language of the work by ISO 639-2/B code (\url{http://www.dnb.de/SharedDocs/Downloads/DE/DNB/standardisierung/inhaltserschliessung/sprachenCodesEnglisch.pdf?__blob=publicationFile}); single string value or vector of strings.
#' @param limit number and (optional) starting point of results returned; single integer value (number of results, 1--100), vector of two integer values (number of results and first result, >=1) or \code{"all"} for a complete list of results.
#' @param print if \code{TRUE} the search results are printed (default is \code{FALSE}).
#' @return A list of results with metadata.
#' @details to do
#' @source \url{http://www.dnb.de/EN/Service/DigitaleDienste/SRU/sru_node.html}
#' @export
#' @examples
#' \dontrun{
#' }
dnb_search <- function(title, author, year, publisher, keyword, type, language, limit=10, print=FALSE) {		
	# init query
	query <- ""
	
	# prepare title
	if(!missing(title)) {
		title <- paste0("tit=", title)
		query <- paste0("(", title, ")")
	}
	
	# prepare author
	if(!missing(author)) {
		author <- paste0("atr=", author)
		if(query=="") query <- paste0("(", author, ")")
		else query <- paste(query, paste0("(", author, ")"), sep=" AND ") 
	}
	
	# prepare year
	if(!missing(year)) {
		if(length(year)>1 && (tail(year, 1)-year[1]+1)==length(year)) {
			year <- paste0("jhr>=", year[1], " AND jhr<=", tail(year, 1))
		} else {
			year <- paste0("jhr=", year, collapse=" OR ")
		}
		if(query=="") query <- paste0("(", year, ")")
		else query <- paste(query, paste0("(", year, ")"), sep=" AND ")
	}
	
	# prepare publisher
	if(!missing(publisher)) {
		publisher <- paste0("vlg=", publisher, collapse=" OR ")
		if(query=="") query <- paste0("(", publisher, ")")
		else query <- paste(query, paste0("(", publisher, ")"), sep=" AND ")
	}
	
	# prepare keyword
	if(!missing(keyword)) {
		keyword <- paste0("sw=", keyword)
		if(query=="") query <- paste0("(", keyword, ")")
		else query <- paste(query, paste0("(", keyword, ")"), sep=" AND ")
	}
	
	# prepare type
	if(!missing(type)) {
		avail.types <- c("articles", "manuscript", "biographicaldoc", "letters", "bequest", "collections", "books", "brailles", "maps", "discs", "dissertations", "online", "films", "microfiches", "multimedia", "music", "scores", "serials", "persons", "subjects", "corperations", "works", "events", "geographics")
		type <- avail.types[pmatch(type, avail.types)]		
		type <- paste0("mat=", type, collapse=" OR ")
		if(query=="") query <- paste0("(", type, ")")
		else query <- paste(query, paste0("(", type, ")"), sep=" AND ")
	}
	
	# prepare language
	if(!missing(language)) {
		language <- paste0("spr=", language, collapse=" OR ")
		if(query=="") query <- paste0("(", language, ")")
		else query <- paste(query, paste0("(", language, ")"), sep=" AND ")
	}
	
	# prepare limit
	if(any(limit=="all")) {
		lim <- 100
		strt <- 1
	} else if(is.numeric(limit)) {
		if(length(limit)==1) {
			lim <- limit
			strt <- 1
		} else if(length(limit)==2) {
			lim <- limit[1]
			strt <- limit[2]
		} else stop("cannot read 'limit'")
	} else stop("cannot read 'limit'")
		
	# make request
	req <- dnb_get_url(path="sru/dnb", query=query, limit=lim, start=strt)
	raw <- dnb_parse(req)
	
	# no hits
	if(as.numeric(raw[["numberOfRecords"]]==0)) {
		message("Nothing found")
		return(NULL)
	}
	
	# convert
	df <- dnb_to_df(raw)
	
	# loop request for all records
	if(any(limit=="all")) {
		nrec <- as.numeric(raw[["numberOfRecords"]])
		strt <- as.numeric(raw[["nextRecordPosition"]])
		repeat{
			if(strt>nrec) break
			req <- dnb_get_url(path="sru/dnb", query=query, limit=lim, start=strt)
			raw <- dnb_parse(req)
			df_add <- dnb_to_df(raw)
			df <- rbind(df, df_add)
			strt <- as.numeric(raw[["nextRecordPosition"]])
		}
	}
  
  # return
  if(print) print(df)
  invisible(df)
}


#' @title Search the DNB catalogue - advanced search
#' @description \code{dnb_search} exposes a search in the DNB catalogue. 
#' @param query the main search query; single string value or vector of strings.
#' @param limit number and (optional) starting point of results returned; single integer value (number of results, 1--100), vector of two integer values (number of results and first result, >=1) or \code{"all"} for a complete list of results.
#' @param print if \code{TRUE} the search results are printed (default is \code{FALSE}).
#' @return A list of results with metadata.
#' @details to do
#' @source \url{http://www.dnb.de/EN/Service/DigitaleDienste/SRU/sru_node.html}
#' @export
#' @examples
#' \dontrun{
#' }
dnb_advanced <- function(query, limit=10, print=FALSE) {		
	# prepare limit
	if(any(limit=="all")) {
		lim <- 100
		strt <- 1
	} else if(is.numeric(limit)) {
		if(length(limit)==1) {
			lim <- limit
			strt <- 1
		} else if(length(limit)==2) {
			lim <- limit[1]
			strt <- limit[2]
		} else stop("cannot read 'limit'")
	} else stop("cannot read 'limit'")
	
	# make request
  req <- dnb_get_url(path="sru/dnb", query=query, limit=lim, start=strt)
  raw <- dnb_parse(req)
  
  # no hits
	if(as.numeric(raw[["numberOfRecords"]]==0)) {
		message("Nothing found")
		return(NULL)
	}
  
  # convert
  df <- dnb_to_df(raw)
  
  # loop request for all records
	if(any(limit=="all")) {
		nrec <- as.numeric(raw[["numberOfRecords"]])
		strt <- as.numeric(raw[["nextRecordPosition"]])
		repeat{
			if(strt>nrec) break
			req <- dnb_get_url(path="sru/dnb", query=query, limit=lim, start=strt)
			raw <- dnb_parse(req)
			df_add <- dnb_to_df(raw)
			df <- rbind(df, df_add)
			strt <- as.numeric(raw[["nextRecordPosition"]])
		}
	}
  
  # return
  if(print) print(df)
  invisible(df)
}