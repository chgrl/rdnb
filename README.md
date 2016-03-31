# Introduction to rdnb


### About the package

`rdnb` is an R wrapper for the Deutsche Nationalbibliothek (German National Library) API, available at http://www.dnb.de. As the German central archival library, the German National Library is collecting, archiving, bibliographically classifying all German and German-language publications from 1913, foreign publications about Germany, translations of German works, and the works of German-speaking emigrants published abroad between 1933 and 1945.

All bibliographic data of the German National Library are provided free of charge and can be freely re-used under "Creative Commons Zero" ([CC0 1.0](http://creativecommons.org/publicdomain/zero/1.0/deed.en)) terms. The metadata and online interfaces are provided with no guarantee of their being continuous, punctual, error-free or complete, or of their not infringing the rights of third parties (e.g. personal rights and copyright).

A personal access token is required for usage and can be requested by sending an e-mail to the Interface Service (schnittstellen-service@dnb.de). The e-mail must include the required catalogue "Catalogue of German National Library (DNB) / Katalog der Deutschen Nationalbibliothek (DNB)" and the access option "via access token / über Zugangscode".

If you do not want to enter your token for each R session, put the following in your .Renviron or .Rprofile file:
`DNB_TOKEN=PUTYOURTOKENHERE`.

#### Source and more details:

[About the DNB](http://www.dnb.de/EN/Wir/wir_node.html); 
[About the interface and access requirements](http://www.dnb.de/EN/Service/DigitaleDienste/SRU/sru_node.html); 
[The DNB web search](http://dnb.dnb.de)


### Package install

`rdnb` is available on CRAN and GitHub. Install from CRAN:


```r
install.packages("rdnb")
```

To install the development version from GitHub the `devtools`-package is required.


```r
if(packageVersion("devtools") < 1.6) {
  install.packages("devtools")
}
devtools::install_github("chgrl/rdnb")
```


### Load the package


```r
library(rdnb)
```


### Search the DNB catalogue

`rdnb` provides two approaches to expose a search. For common search requests use the simple `dnb_search` function. More complex requests are possible using the `dnb_advanced` function.

#### Simple search - `dnb_search`

##### Search for title

Use the `title` parameter to search in titles, including subtitle, short title, volume title, etc.


```r
single.title <- dnb_search(title="katze")
```

A vector of strings combines search terms. Strings in a vector are "OR"-combined by default. Logical operators can be changed by starting a string with `+` or `-`, thus the following code searches for titles containing one of "katze" or "kater", "maus" but not "hund".


```r
multi.title <- dnb_search(title=c("katze", "kater", "+maus", "-hund"))
```

##### Search for author

The `author` parameter offers a search for one or a set of authors. Logical operators can be set as explained above.


```r
single.author.1 <- dnb_search(author="kern")
single.author.2 <- dnb_search(author="kern, ingolf")
single.author.3 <- dnb_search(author="ingolf kern")
author.or.author <- dnb_search(author=c("kern", "locke"))
author.and.author <- dnb_search(author=c("kern", "+locke"))
author.not.author <- dnb_search(author=c("kern", "-locke"))
```

##### Search for publication year

Use the `year` parameter to limit the year(s) of publication. Set `year` to a single integer value to specify a single year. Set the parameter to a sequence to specify start and end. Or set the parameter to a vector of integer values to specify a set of years.


```r
single.year <- dnb_search(title="katze", year=2015)
sequence.of.years <- dnb_search(title="katze", year=2010:2015)
set.of.years <- dnb_search(title="katze", year=c(2010:2013, 2015))
```

##### Search for publisher

Publisher name and/or location may be limited by the `publisher` parameter. A vector of string values is combined by "OR".


```r
single.publisher <- dnb_search(title="katze", publisher="kiepenheuer")
single.publisher.location <- dnb_search(title="katze", publisher="*verlag leipzig")
set.of.publishers <- dnb_search(title="katze", publisher=c("kiepenheuer", "piper"))
```

##### Search for keyword

Keyword (subjects, persons, locations, organisations, etc.) search is available using the `keyword` parameter. Logical operators can be set as explained for title search.


```r
single.keyword <- dnb_search(keyword ="katze")
keyword.or.keyword <- dnb_search(keyword=c("katze", "hund"))
keyword.and.keyword <- dnb_search(keyword=c("katze", "+hund"))
keyword.not.keyword <- dnb_search(keyword=c("katze", "-hund"))
```

##### Search for type of publication

The DNB discriminates between several publication types:

  * articles (Artikel)
  * manuscript (Manuskripte)
  * biographicaldoc (Lebensdokumente)
  * letters (Briefe)
  * bequest (Nachlässe)
  * collections (Sammlungen)
  * books (Bücher)
  * brailles (Blindenschriften)
  * maps (Karten)
  * discs (Elektronische Datenträger)
  * dissertations (Hochschulschriften)
  * online (Online Ressourcen)
  * films (Filme/Hörbücher)
  * microfiches (Mikrofilm)
  * multimedia (Medienkombinationen)
  * music (Musiktonträger)
  * scores (Noten)
  * serials (Zeitschriften)
  * persons (Personen)
  * subjects (Sachbegriffe)
  * corperations (Organisationen)
  * works (Werke)
  * events (Ereignisse)
  * geographics (Geografika)
  
The `type` parameter can be specified as single string value (named above) or a vector of string values, that will be combined by "OR". Short terms of the available types usually work.


```r
single.type <- dnb_search(title="katze", type="books")
single.type.part <- dnb_search(title="katze", type="bio") # biographicaldoc
set.of.types <- dnb_search(title="katze", type=c("books", "articles", "online"))
```

##### Search for language

The DNB also archives publications in other languages than German, e.g. when they are about Germany or publicated in Germany. The language(s) can be filtered by ISO 639-2/B [code](http://www.dnb.de/SharedDocs/Downloads/DE/DNB/standardisierung/inhaltserschliessung/sprachenCodesEnglisch.pdf?__blob=publicationFile), like "ger" (German), "eng" (English), "fre" (French), "spa" (Spanish) or "gsw" (Swiss German). A vector of string values is combined by "OR".


```r
single.language <- dnb_search(title="cat", language="eng")
set.of.languages <- dnb_search(title=c("cat", "katze"), language=c("eng", "ger"))
```

##### Change limit of results

Use the `limit` parameter to set the number and optionally the starting point of the results returned. A single integer value (possible values: 1-100) specifies the number of results only. Use a vector of two integer values to specify the number of results (first value of vector) and the first result (1 or higher). Set `limit` to "all" for a complete list of results.


```r
first.result <- dnb_search(title="katze", limit=1)
five.results.starting.with.the.21st <- dnb_search(title="katze", limit=c(5, 21))
all.results <- dnb_search(title="katze", year=2016, limit="all")
```

##### Results

Per default no results are printed. Set `print` to `TRUE` to print the `data.frame` with the results.


```r
cats <- dnb_search(title="katze", print=TRUE)
#>            id                        link
#> 1  1088777961 http://d-nb.info/1088777961
#> 2  1079083170 http://d-nb.info/1079083170
#> 3  1078237050 http://d-nb.info/1078237050
#> 4  1082000671 http://d-nb.info/1082000671
#> 5  108078571X http://d-nb.info/108078571X
#> 6  1080780793 http://d-nb.info/1080780793
#> 7  1085681068 http://d-nb.info/1085681068
#> 8  107915972X http://d-nb.info/107915972X
#> 9  1079347178 http://d-nb.info/1079347178
#> 10 1084797631 http://d-nb.info/1084797631
#>                                                                     author
#> 1                                                    Boysen, Margret (aut)
#> 2                              von Vogel, Maja (aut); Bux, Alexander (ill)
#> 3                                                    Schacht, Andrea (aut)
#> 4                                                   Peters, Stefanie (aut)
#> 5                                                                     <NA>
#> 6                                                                     <NA>
#> 7  Francis, H.G. (aut); Pasetti, Peter (nrt); Francis, H.G.; Francis, H.G.
#> 8                     Michie, David (aut); Lang, Kurt (trl); Michie, David
#> 9                                   Fox, Diane (aut); Fox, Christyan (aut)
#> 10                                                  Poe, Edgar Allan (aut)
#>                                                                                                      title
#> 1                                                                Alice, der Klimawandel und die Katze Zeta
#> 2                                                       Bildermaus – Der kleine Fuchs und die freche Katze
#> 3                                                                \u0098Der\u009c Tag, an dem die Katze kam
#> 4                                                                                 Dermatologie-Atlas Katze
#> 5                                                                                     Dicke Katze 2017 A&I
#> 6                                                                                     Dicke Katze 2017 A&I
#> 7                                                            \u0098Die\u009c drei ??? und der Karpatenhund
#> 8                                      \u0098Die\u009c Katze des Dalai Lama und der Zauber des Augenblicks
#> 9  \u0098Die\u009c Katze, der Hund, Rotkäppchen, die explodierenden Eier, der Wolf und Omas Kleiderschrank
#> 10                                                                          \u0098Die\u009c schwarze Katze
#>                                           subtitle
#> 1                                             <NA>
#> 2                                             <NA>
#> 3                    Jennys & Ghizmos zweiter Fall
#> 4  Krankheitsbilder und typische Verteilungsmuster
#> 5                                             <NA>
#> 6                                             <NA>
#> 7                                             <NA>
#> 8                                            Roman
#> 9                                             <NA>
#> 10                                            <NA>
#>                                              publisher   year language
#> 1                              Edition Rugerup, Berlin   2016      ger
#> 2                                      Loewe, Bindlach   2016      ger
#> 3                                     Egmont LYX, Köln   2016      ger
#> 4                                      Enke, Stuttgart   2016      ger
#> 5  teNeues Calendars & Stationery, Kempen, Niederrhein   2016      ger
#> 6  teNeues Calendars & Stationery, Kempen, Niederrhein   2016      ger
#> 7       Sony Music Entertainment Germany GmbH, München [2016]      ger
#> 8                                       Lotos, München   2016      ger
#> 9                      Freies Geistesleben , Stuttgart   2016      ger
#> 10                     fabula Verlag Hamburg , Hamburg   2016      ger
#>             isbn
#> 1  9783942955522
#> 2  9783785582008
#> 3  9783802598975
#> 4  9783132194519
#> 5  4002725785084
#> 6  4002725784995
#> 7           <NA>
#> 8  9783778782620
#> 9  9783772527913
#> 10 9783958554276
#>                                                                          price
#> 1                                      Gewebe : EUR 22.60 (AT), EUR 21.90 (DE)
#> 2                                           Gb. : EUR 8.20 (AT), EUR 7.95 (DE)
#> 3                Kart. : EUR 10.30 (AT), sfr 13.50 (freier Pr.), EUR 9.99 (DE)
#> 4  Broschiert (FH) : EUR 92.60 (AT), sfr 103.00 (freier Preis), EUR 89.99 (DE)
#> 5                                                                         <NA>
#> 6                                                                         <NA>
#> 7                                                                         <NA>
#> 8                     : EUR 17.50 (AT), sfr 22.90 (freier Pr.), EUR 16.99 (DE)
#> 9                                 Gb. : ca. EUR 16.40 (AT), ca. EUR 15.90 (DE)
#> 10         Broschur : EUR 12.90 (AT), sfr 16.00 (freier Preis), EUR 12.90 (DE)
#>         pages                 format                         edition
#> 1  278 Seiten 21.5 cm x 17 cm, 650 g                      1. Auflage
#> 2       48 S.        24.5 cm x 18 cm                            <NA>
#> 3      320 S.        18 cm x 12.4 cm                            <NA>
#> 4  304 Seiten          24 cm x 17 cm                      1. Auflage
#> 5        <NA>          30 cm x 30 cm                            <NA>
#> 6        <NA>        45 cm x 19.5 cm                            <NA>
#> 7       2 CDs                  12 cm        Limitierte Sonderedition
#> 8      256 S.        20 cm x 12.5 cm                            <NA>
#> 9       32 S.                   <NA>                        1. Aufl.
#> 10       <NA>          19 cm x 12 cm 1. Auflage, bearbeitete Ausgabe
#>    keyword toc
#> 1       NA  NA
#> 2       NA  NA
#> 3       NA  NA
#> 4       NA  NA
#> 5       NA  NA
#> 6       NA  NA
#> 7       NA  NA
#> 8       NA  NA
#> 9       NA  NA
#> 10      NA  NA
#>                                                                                                description
#> 1                         https://www.edition-rugerup.de/?product=alice-der-klimawandel-und-die-katze-zeta
#> 2  http://deposit.d-nb.de/cgi-bin/dokserv?id=233cdda0eb904a09afd5ac8ac1825fdf&prov=M&dok_var=1&dok_ext=htm
#> 3  http://deposit.d-nb.de/cgi-bin/dokserv?id=98d487ce0c0441b28457bb7c73bcba6b&prov=M&dok_var=1&dok_ext=htm
#> 4  http://deposit.d-nb.de/cgi-bin/dokserv?id=f8d49875c2fd4966a5d3e09bc3d6a2a6&prov=M&dok_var=1&dok_ext=htm
#> 5                                                                                                     <NA>
#> 6                                                                                                     <NA>
#> 7                                                                                                     <NA>
#> 8  http://deposit.d-nb.de/cgi-bin/dokserv?id=399fda5149b74a79a65d599f48e3073f&prov=M&dok_var=1&dok_ext=htm
#> 9                                                                                                     <NA>
#> 10                                                                                                    <NA>
#>                                                              cover
#> 1  https://portal.dnb.de/opac/mvb/cover.htm?isbn=978-3-942955-52-2
#> 2  https://portal.dnb.de/opac/mvb/cover.htm?isbn=978-3-7855-8200-8
#> 3  https://portal.dnb.de/opac/mvb/cover.htm?isbn=978-3-8025-9897-5
#> 4  https://portal.dnb.de/opac/mvb/cover.htm?isbn=978-3-13-219451-9
#> 5                                                             <NA>
#> 6                                                             <NA>
#> 7                                                             <NA>
#> 8  https://portal.dnb.de/opac/mvb/cover.htm?isbn=978-3-7787-8262-0
#> 9  https://portal.dnb.de/opac/mvb/cover.htm?isbn=978-3-7725-2791-3
#> 10 https://portal.dnb.de/opac/mvb/cover.htm?isbn=978-3-95855-427-6
```

The following data is stored in the `data.frame` (if available):

| Variable | Description |
| --- | --- |
| id | DNB record ID |
| link | link to record |
| author | author(s) |
| title | main title |
| subtitle | subtitle |
| publisher | publisher |
| year | year of publication |
| language | language (abbreviation) |
| isbn | ISBN (13-digit or 10-digit) |
| price | price (as string, usually prices for DE, AT and CH) |
| pages | pages |
| format | size and weight (partial) |
| edition | edition |
| keyword | keyword(s) |
| toc | link to table of contents |
| description | link to description |
| cover | link to cover image |


The total number of records found by the request is stored in the attribute "number_of_records":


```r
attr(cats, "number_of_records")
#> [1] 5547
```

and the query itself can be viewed by calling the "query"-attribute:


```r
attr(cats, "query")
#> [1] "(tit=katze)"
```

You can use this query directly with the `dnb_advanced` function. 


#### Advanced search - `dnb_advanced`

`dnb_advanced` allows for complex requests using the Contextual Query Language (CQL). See the [DNB advanced search help pages](http://www.dnb.de/EN/Header/Hilfe/kataloghilfeExpertensuche.html) for available indices and a list of examples.

The following advanced search returns a list of german or english children's books titled with 'cat', excluding titles containing 'dog', since the year 2001:


```r
cats <- dnb_advanced("( (tit=katze OR tit=kater NOT tit=hund) OR (tit=cat NOT tit=dog) ) AND jhr>2000 AND mat=books AND (spr=ger OR spr=eng) AND sgt=K", limit="all")
```
