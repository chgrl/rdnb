dnb_get_url <- function(path, query, limit, offset, token=dnb_token()) {
	req <- GET("http://services.dnb.de/", path=path, query=list(version="1.1", operation="searchRetrieve", accessToken=token, query=query, maximumRecords=limit, startRecord=offset, recordSchema="MARC21-xml"))
	dnb_check(req)
	message("Request: ", req$url) # for debugging
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
	parsed <- as_list(read_xml(xml))
	return(parsed)
}


dnb_token <- function(force=FALSE) {
	env <- Sys.getenv('DNB_TOKEN')
	if(!identical(env, "") && !force) return(env)
	if(!interactive()) {
		stop("Please set env var 'DNB_TOKEN' to your personal access token", call.=FALSE)
	}
	message("Couldn't find env var DNB_TOKEN.")
	message("Please enter your token and press enter")
	token <- readline(": ")
	if(identical(token, "")) {
		stop("Token entry failed", call.=FALSE)
	}
	message("Updating DNB_TOKEN env var to given token")
	Sys.setenv(DNB_TOKEN=token)
	return(token)
}


hasKey <- function() {
	!identical(dnb_token(), "")
dnb_to_df <- function(lst) {
	df <- as.data.frame(lst$records)
	return(df)
}
