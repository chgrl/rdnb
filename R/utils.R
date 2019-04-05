dnb_get_url <- function(path, query, limit, start, token=dnb_token()) {
	req <- GET("http://services.dnb.de/", path=path, query=list(version="1.1", operation="searchRetrieve", accessToken=token, query=query, maximumRecords=limit, startRecord=start, recordSchema="MARC21-xml"))
	dnb_check(req)
	if(getOption("rdnb_show_url")) message("Request: ", req$url)
	return(req)
}


dnb_check <- function(req) {
	if(req$status_code<400) return(invisible())
	message <- dnb_parse(req)$message
	stop("HTTP failure: ", req$status_code, "\n", message, call.=FALSE)
}


dnb_parse <- function(req) {
	xml <- content(req, as="text")
	if(identical(xml, "")) stop("Not output to parse", call.=FALSE)
	if(length(grep("text/xml", req$headers$'content-type', fixed=TRUE))==0) stop("No XML to parse", call.=FALSE)
	parsed <- as_list(read_xml(gsub("\n +", "", xml)))
	return(parsed)
}


dnb_token <- function(force=FALSE) {
	env <- Sys.getenv('DNB_TOKEN')
	if(!identical(env, "") && !force) return(env)
	if(!interactive()) {
		stop("Please set env var 'DNB_TOKEN' to your personal access token", call.=FALSE)
	}
	message("Couldn't find env var DNB_TOKEN")
	message("Please enter your token and press enter")
	token <- readline(": ")
	if(identical(token, "")) {
		stop("Token entry failed", call.=FALSE)
	}
	message("Updating DNB_TOKEN env var to given token")
	Sys.setenv(DNB_TOKEN=gsub("\"", "", token, fixed=TRUE))
	return(token)
}


#' @title Save token to file
#' @description \code{save_token} saves the DNB token to file, so the user does not to enter it for each R session.
#' @param token the personal DNB token as string.
#' @param path the path to the file where the token is stored. Default is the .Renvion file in the users home directory.
#' @note If an environment variable named "DNB_TOKEN" is found in the file, it is updated to the given token.
#' @examples
#' \dontrun{
#' save_token(token="YOUR_TOKEN_HERE")
#' }
#' @export
save_token <- function(token=dnb_token(), 
                      path=paste(normalizePath("~/"), ".Renviron", sep="/")){
  # check file
  if(!file.exists(path)) {
    file.create(path)
    message(".Renviron file created")
  }
    
  # read file
  env <- readLines(path, encoding="UTF-8")
  
  # write token
  if(length(grep("DNB_TOKEN=.", env) > 0)) { # update
    env[tail(grep("DNB_TOKEN=.", env), 1)] <- paste0("DNB_TOKEN=", token)
    writeLines(env, path)
    message("DNB_TOKEN updated in ", path)
  } else {  # create
    writeLines(paste0(env, "\nDNB_TOKEN=", token), path)
    message("DNB_TOKEN created in ", path)
  }
  
  # set environment variable
  Sys.setenv(DNB_TOKEN=token)
}


dnb_to_df <- function(lst, clean) {
	# prepare data.frame
	nrec <- length(lst$records)
	df <- data.frame(matrix(nrow=nrec, ncol=17))
	names(df) <- c("id", "link", "author", "title", "subtitle", "publisher", "year", "language", "isbn", "price", "pages", "format", "edition", "keyword", "toc", "description", "cover")
	
	# get data
	for(r in 1:nrec) {
		rec <- lst$records[[r]]$recordData$record
		rec <- setNames(rec, sapply(rec, function(x) attributes(x)$tag))
		rec <- lapply(rec, function(x) lapply(x, function(y) setNames(y, attributes(y)$code)))
		rec <- lapply(rec, function(x) unlist(x, recursive=FALSE))
		
		if(!is.null(rec[["001"]])) {	# id/link
			df$id[r] <- rec[["001"]]
			df$link[r] <- paste0("http://d-nb.info/", rec[["001"]])	
		}
		if(!is.null(rec[["100"]][["subfield.a"]])) {	# author
			aut <- rec[["100"]][["subfield.a"]]
			if(!is.null(rec[["100"]][["subfield.4"]])) aut <- paste0(aut, " (", rec[["100"]][["subfield.4"]], ")")
			df$author[r] <- aut
		}
		if(length(which(names(rec)=="700"))>0) {	# co-author
			for(ca in which(names(rec)=="700")) {
				if(!is.null(rec[[ca]][["subfield.a"]])) {
					coaut <- rec[[ca]][["subfield.a"]]
					if(!is.null(rec[[ca]][["subfield.4"]])) coaut <- paste0(coaut, " (", rec[[ca]][["subfield.4"]], ")")
					if(is.na(df$author[r])) {
						df$author[r] <- coaut
					} else {
						df$author[r] <- paste(df$author[r], coaut, sep="; ")
					}
				}
			}
		}
		if(!is.null(rec[["245"]][["subfield.a"]])) {	# title
			df$title[r] <- rec[["245"]][["subfield.a"]]
		}
		if(!is.null(rec[["245"]][["subfield.b"]])) {	# subtitle
			df$subtitle[r] <- rec[["245"]][["subfield.b"]]
		}
		if(!is.null(rec[["264"]][["subfield.b"]])) {	# publisher
			pub <- rec[["264"]][["subfield.b"]]
			if(!is.null(rec[["264"]][["subfield.a"]])) pub <- paste0(pub, ", ", rec[["264"]][["subfield.a"]])
			df$publisher[r] <- pub
		}
		if(!is.null(rec[["264"]][["subfield.c"]])) {	# year
			df$year[r] <- rec[["264"]][["subfield.c"]]
		} else {
		  if(!is.null(rec[["008"]])) {	# year 2
		    df$year[r] <- rec[["008"]]
		  }
		}
		if(!is.null(rec[["041"]][["subfield.a"]])) {	# language
			df$language[r] <- rec[["041"]][["subfield.a"]]
		}
		if(!is.null(rec[["024"]][["subfield.a"]])) {	# isbn
			df$isbn[r] <- rec[["024"]][["subfield.a"]]
		} else if(!is.null(rec[["020"]][["subfield.a"]])) {
			df$isbn[r] <- rec[["020"]][["subfield.a"]]
		}
		if(!is.null(rec[["020"]][["subfield.c"]])) {	# price
			df$price[r] <- rec[["020"]][["subfield.c"]]
		}
		if(!is.null(rec[["300"]][["subfield.a"]])) {	# pages
			df$pages[r] <- rec[["300"]][["subfield.a"]]
		}
		if(!is.null(rec[["300"]][["subfield.c"]])) {	# format
			df$format[r] <- rec[["300"]][["subfield.c"]]
		}
		if(!is.null(rec[["250"]][["subfield.a"]])) {	# edition
			df$edition[r] <- rec[["250"]][["subfield.a"]]
		}
		if(length(which(names(rec)=="689"))>0) {	# keyword
			for(kw in which(names(rec)=="689")) {
				if(!is.null(rec[[kw]][["subfield.a"]])) {
					if(is.na(df$keyword[r])) {
						df$keyword[r] <- rec[[kw]][["subfield.a"]]
					} else {
						df$keyword[r] <- paste(df$keyword[r], rec[[kw]][["subfield.a"]], sep="; ")
					}
				}
			}
		}
		if(length(which(names(rec)=="856"))>0) {	# toc/description
			for(kw in which(names(rec)=="856")) {
				if(!is.null(rec[[kw]][["subfield.3"]]) && !is.null(rec[[kw]][["subfield.u"]])) {
					if(rec[[kw]][["subfield.3"]]=="Inhaltsverzeichnis") {
						df$toc[r] <- rec[[kw]][["subfield.u"]]
					} else if(rec[[kw]][["subfield.3"]]=="Inhaltstext") {
						df$description[r] <- rec[[kw]][["subfield.u"]]
					}
				}
			}
		}
		if(!is.null(rec[["020"]][["subfield.9"]])) {	# cover
			df$cover[r] <- paste0("https://portal.dnb.de/opac/mvb/cover.htm?isbn=", rec[["020"]][["subfield.9"]])
		}	
	}
	
	# clean data
	if(clean) {
		if(nrow(df)>1) {
			df <- as.data.frame(sapply(df, gsub, pattern="\u0098", replacement="", fixed=TRUE), stringsAsFactors=FALSE)
			df <- as.data.frame(sapply(df, gsub, pattern="\u009c", replacement="", fixed=TRUE), stringsAsFactors=FALSE)
			df <- as.data.frame(sapply(df, gsub, pattern=",,", replacement=",", fixed=TRUE), stringsAsFactors=FALSE)
			df <- as.data.frame(sapply(df, gsub, pattern="..", replacement=".", fixed=TRUE), stringsAsFactors=FALSE)
			df <- as.data.frame(sapply(df, gsub, pattern=";;", replacement=";", fixed=TRUE), stringsAsFactors=FALSE)
		}
	  df$author <- sapply(df$author, gsub, pattern=" (aut)", replacement="", fixed=TRUE)
	  df$year <- sapply(df$year, function(x) str_split(x, pattern=" ", n=2)[[1]][1])
	  df$year <- sapply(df$year, function(x) substr(x, nchar(x)-3, nchar(x)))
	  df$year <- sapply(df$year, gsub, pattern="[^0-9]", replacement="")
		df$year <- as.numeric(df$year)
		df$pages <- sapply(df$pages, gsub, pattern=" S.", replacement="", fixed=TRUE)
		df$pages <- sapply(df$pages, gsub, pattern=" Seiten", replacement="", fixed=TRUE)
		df$pages <- sapply(df$pages, gsub, pattern="[", replacement="", fixed=TRUE)
		df$pages <- sapply(df$pages, gsub, pattern="]", replacement="", fixed=TRUE)
		df$publisher <- sapply(df$publisher, gsub, pattern="Verl.", replacement="Verlag", fixed=TRUE)
		df$publisher <- sapply(df$publisher, gsub, pattern="verl.", replacement="verlag", fixed=TRUE)
		df$publisher <- sapply(df$publisher, gsub, pattern="[", replacement="", fixed=TRUE)
		df$publisher <- sapply(df$publisher, gsub, pattern="]", replacement="", fixed=TRUE)
		df$edition <- sapply(df$edition, gsub, pattern="Aufl.", replacement="Auflage", fixed=TRUE)
		df$edition <- sapply(df$edition, gsub, pattern="aufl.", replacement="auflage", fixed=TRUE)
		df$edition <- sapply(df$edition, gsub, pattern="Ed.", replacement="Edition", fixed=TRUE)
		df$edition <- sapply(df$edition, gsub, pattern="ed.", replacement="edition", fixed=TRUE)
		df$edition <- sapply(df$edition, gsub, pattern="Orig.", replacement="Original", fixed=TRUE)
		#df$edition <- sapply(df$edition, gsub, pattern="korr.", replacement="korrigierte", fixed=TRUE)
		df$edition <- sapply(df$edition, gsub, pattern="Nachdr.", replacement="Nachdruck", fixed=TRUE)
		df$edition <- sapply(df$edition, gsub, pattern="Bibliogr.", replacement="Bibliografie", fixed=TRUE)
		#df$edition <- sapply(df$edition, gsub, pattern="dt.", replacement="deutsche", fixed=TRUE)
		#df$edition <- sapply(df$edition, gsub, pattern="Dt.", replacement="Deutsche", fixed=TRUE)
		#df$edition <- sapply(df$edition, gsub, pattern="Ver\u00F6ff.", replacement="Ver\u00F6ffentlichung", fixed=TRUE)
		#df$edition <- sapply(df$edition, gsub, pattern="ver\u00F6ff.", replacement="ver\u00F6ffentlichung", fixed=TRUE)
		df$edition <- sapply(df$edition, gsub, pattern="Ausg.", replacement="Ausgabe", fixed=TRUE)
		df$edition <- sapply(df$edition, gsub, pattern="ausg.", replacement="ausgabe", fixed=TRUE)
		#df$edition <- sapply(df$edition, gsub, pattern="Vollst.", replacement="Vollst\u00E4ndige", fixed=TRUE)
		#df$edition <- sapply(df$edition, gsub, pattern="vollst.", replacement="vollst\u00E4ndige", fixed=TRUE)
		#df$edition <- sapply(df$edition, gsub, pattern="\u00DCberarb.", replacement="\u00DCberarbeitete", fixed=TRUE)
		#df$edition <- sapply(df$edition, gsub, pattern="\u00FCberarb.", replacement="\u00FCberarbeitete", fixed=TRUE)
		#df$edition <- sapply(df$edition, gsub, pattern="Erw.", replacement="Erweiterte", fixed=TRUE)
		#df$edition <- sapply(df$edition, gsub, pattern="erw.", replacement="erweiterte", fixed=TRUE)
		#df$edition <- sapply(df$edition, gsub, pattern="Erg.", replacement="Erg\u00E4nzte", fixed=TRUE)
		#df$edition <- sapply(df$edition, gsub, pattern="erg.", replacement="erg\u00E4nzte", fixed=TRUE)
		#df$edition <- sapply(df$edition, gsub, pattern="Ungek.", replacement="Ungek\u00FCrzte", fixed=TRUE)
		#df$edition <- sapply(df$edition, gsub, pattern="ungek.", replacement="ungek\u00FCrzte", fixed=TRUE)
		#df$edition <- sapply(df$edition, gsub, pattern="Ver\u00E4nd.", replacement="Ver\u00E4nderte", fixed=TRUE)
		#df$edition <- sapply(df$edition, gsub, pattern="ver\u00E4nd.", replacement="ver\u00E4nderte", fixed=TRUE)
		df$edition <- sapply(df$edition, gsub, pattern="[", replacement="", fixed=TRUE)
		df$edition <- sapply(df$edition, gsub, pattern="]", replacement="", fixed=TRUE)
		df$edition <- sapply(df$edition, gsub, pattern="1., ", replacement="1. ", fixed=TRUE)
		df$edition <- sapply(df$edition, gsub, pattern="2., ", replacement="2. ", fixed=TRUE)
		df$edition <- sapply(df$edition, gsub, pattern="3., ", replacement="3. ", fixed=TRUE)
		df$edition <- sapply(df$edition, gsub, pattern="4., ", replacement="4. ", fixed=TRUE)
		df$edition <- sapply(df$edition, gsub, pattern="5., ", replacement="5. ", fixed=TRUE)
		df$edition <- sapply(df$edition, gsub, pattern="6., ", replacement="6. ", fixed=TRUE)
		df$edition <- sapply(df$edition, gsub, pattern="7., ", replacement="7. ", fixed=TRUE)
		df$edition <- sapply(df$edition, gsub, pattern="8., ", replacement="8. ", fixed=TRUE)
		df$edition <- sapply(df$edition, gsub, pattern="9., ", replacement="9. ", fixed=TRUE)
		df$edition <- sapply(df$edition, gsub, pattern="10., ", replacement="10. ", fixed=TRUE)
		df$edition <- sapply(df$edition, gsub, pattern="11., ", replacement="11. ", fixed=TRUE)
		df$edition <- sapply(df$edition, gsub, pattern="12., ", replacement="12. ", fixed=TRUE)
		df$edition <- sapply(df$edition, gsub, pattern="13., ", replacement="13. ", fixed=TRUE)
		df$edition <- sapply(df$edition, gsub, pattern="14., ", replacement="14. ", fixed=TRUE)
		df$edition <- sapply(df$edition, gsub, pattern="15., ", replacement="15. ", fixed=TRUE)
		df$price <- sapply(df$price, gsub, pattern="kart.", replacement="Kartoniert", fixed=TRUE)
		df$price <- sapply(df$price, gsub, pattern="Gb.", replacement="Gebunden", fixed=TRUE)
		df$price <- sapply(df$price, gsub, pattern="Spiralb.", replacement="Spiralbindung", fixed=TRUE)
		df$price <- sapply(df$price, gsub, pattern="Pb.", replacement="Paperback", fixed=TRUE)
	}
		
	return(df)
}


#' @title Number of records
#' @description \code{n_rec} returns the number of items in a list of records returned by a DNB-search. 
#' @param dnb_obj the DNB-search object returned \code{\link{dnb_search}} or \code{\link{dnb_advanced}}.
#' @return Number of records found.
#' @export
#' @examples
#' \dontrun{
#' dnb.srch <- dnb_search(title="katze")
#' n_rec(dnb.srch)
#' }
n_rec <- function(dnb_obj) {
  # check lor and return nrec
  if(is.null(attr(dnb_obj, "number_of_records"))) {
    return(NULL)
  } else {
    return(attr(dnb_obj, "number_of_records"))
  }
}


#' @title Print search query
#' @description \code{print_query} prints out the query used for a DNB-search request.
#' @param dnb_obj the DNB-serch object returned by \code{\link{dnb_search}} or \code{\link{dnb_advanced}}.
#' @return Query string.
#' @export
#' @examples
#' \dontrun{
#' dnb.srch <- dnb_search(title="katze")
#' print_query(dnb.srch)
#' }
print_query <- function(dnb_obj) {
  # check lor and return query
  if(is.null(attr(dnb_obj, "query"))) {
    return(NULL)
  } else {
    return(attr(dnb_obj, "query"))
  }
}
