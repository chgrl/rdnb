#' @title R Interface to the Deutsche Nationalbibliothek (German National Library) API
#' @description A wrapper for the Deutsche Nationalbibliothek (German National Library) API, available at \url{https://www.dnb.de/EN/Home/home_node.html}. The German National Library is the German central archival library, collecting, archiving, bibliographically classifying all German and German-language publications, foreign publications about Germany, translations of German works, and the works of German-speaking emigrants published abroad between 1933 and 1945.
#' @name rdnb
#' @docType package
#' @details All bibliographic data of the German National Library are provided free of charge and can be freely re-used under "Creative Commons Zero" (CC0 1.0) terms. The metadata and online interfaces are provided with no guarantee of their being continuous, punctual, error-free or complete, or of their not infringing the rights of third parties (e.g. personal rights and copyright).
#' @references About the DNB: \url{https://www.dnb.de/EN/Ueber-uns/ueberUns_node.html}; about the interface: \url{https://www.dnb.de/EN/Professionell/Metadatendienste/Datenbezug/SRU/sru_node.html}
#' @importFrom httr GET
#' @importFrom httr content
#' @importFrom stringr str_split
#' @importFrom xml2 as_list
#' @importFrom xml2 read_xml
#' @importFrom stats setNames
#' @import brew
#' @import grDevices
#' @import methods
#' @import utils
#' @aliases rdnb rdnb-package
NULL
