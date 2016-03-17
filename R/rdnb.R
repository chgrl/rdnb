#' @title R Interface to the Deutsche Nationalbibliohek (German National Library) API
#' @description A wrapper for the Deutsche Nationalbibliohek (German National Library) API, available at \url{http://www.dnb.de}. The German National Library is entrusted with the task of collecting, permanently archiving, bibliographically classifying and making available to the general public all German and German-language publications from 1913, foreign publications about Germany, translations of German works, and the works of German-speaking emigrants published abroad between 1933 and 1945.
#' A personal access token is required for usage.
#' @name rdnb
#' @docType package
#' @details The Deutsche Nationalbibliothek fulfills its legal mandate to index all publications issued in Germany. This database serves as the original bibliographic indexation. Anyone may research the database of the Deutsche Nationalbibliothek free of charge via public networks.
#' An access token can be requested by sending an e-mail to the Interface Service (\email{schnittstellen-service@@dnb.de}). The e-mail must include the required catalogue "Catalogue of German National Library (DNB) / Katalog der Deutschen Nationalbibliothek (DNB)" and the access option "via access token / ueber Zugangscode". You will receive a message as soon as access is activated, which might take some days. See \url{http://www.dnb.de/EN/Service/DigitaleDienste/SRU/sru_node.html} for details.
#'If you do not want to enter your token for each R session, put the following in your .Renviron or .Rprofile file:
#' \code{DNB_TOKEN=PUTYOURTOKENHERE}
#' @importFrom httr GET
#' @importFrom httr content
#' @importFrom xml2 as_list
#' @importFrom xml2 read_xml
#' @import brew
#' @import grDevices
#' @import methods
#' @import utils
#' @aliases rdnb rdnb-package
NULL
