<img src="rdnb_logo.png" alt="rdnb" />

An R interface to the Deutsche Nationalbibliothek (German National Library) API

![downloads](http://cranlogs.r-pkg.org/badges/grand-total/rdnb)


### About the package

`rdnb` is an R wrapper for the Deutsche Nationalbibliothek (German National Library) API, available at http://www.dnb.de. As the German central archival library, the German National Library is collecting, archiving, bibliographically classifying all German and German-language publications, foreign publications about Germany, translations of German works, and the works of German-speaking emigrants published abroad between 1933 and 1945.

All bibliographic data of the German National Library are provided free of charge and can be freely re-used under "Creative Commons Zero" ([CC0 1.0](https://creativecommons.org/publicdomain/zero/1.0/deed.de)) terms. The metadata and online interfaces are provided with no guarantee of their being continuous, punctual, error-free or complete, or of their not infringing the rights of third parties (e.g. personal rights and copyright).


#### Source and more details:

[About the DNB](https://www.dnb.de/EN/Ueber-uns/ueberUns_node.html); 
[About the interface](https://www.dnb.de/EN/Professionell/Metadatendienste/Datenbezug/SRU/sru_node.html)


### Package install

`rdnb` is available on CRAN and GitHub. Install from CRAN:


```r
install.packages("rdnb")
```

To install the development version from GitHub the `devtools`-package is required.


```r
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

Publisher name and/or location may be limited by the `publisher` parameter. Logical operators can be set as explained above.


```r
single.publisher <- dnb_search(title="katze", publisher="kiepenheuer")
single.publisher.location <- dnb_search(title="katze", publisher="*verlag leipzig*")
pub.or.pub <- dnb_search(title="katze", publisher=c("kiepenheuer", "piper"))
pub.and.pub <- dnb_search(title="katze", publisher=c("*kinder*", "+*berlin*"))
pub.not.pub <- dnb_search(title="katze", publisher=c("pi*", "-piper"))
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

The DNB also archives publications in other languages than German, e.g. when they are about Germany or publicated in Germany. The language(s) can be filtered by ISO 639-2/B [code](https://en.wikipedia.org/wiki/List_of_ISO_639-2_codes), like "ger" (German), "eng" (English), "fre" (French), "spa" (Spanish) or "gsw" (Swiss German). A vector of string values is combined by "OR".


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
cats <- dnb_search(title="katze", limit=3, print=TRUE)
#>           id                        link
#> 1 1116362198 http://d-nb.info/1116362198
#> 2 1120516579 http://d-nb.info/1120516579
#> 3 1125403497 http://d-nb.info/1125403497
#>                                               author
#> 1 Teckentrup, Britta (ill); Teckentrup, Britta (aut)
#> 2                       Frey, Alexander Moritz (aut)
#> 3                            Krokowski, Carola (aut)
#>                              title             subtitle
#> 1 Alles Natur - Meine kleine Katze                 <NA>
#> 2            Birl, die kühne Katze          Ein Märchen
#> 3   Blutwerte - Pferd, Hund, Katze Blutwerte verstehen!
#>                        publisher year language          isbn
#> 1           Ars Edition, München 2017      ger 9783845815886
#> 2       Elsinor Verlag, Coesfeld 2017      ger 9783942788373
#> 3 Igelsburg Verlag, Habichtswald 2017      ger 9783941933200
#>                                                              price pages
#> 1   Pappe : EUR 7.99 (DE), EUR 8.30 (AT), CHF 11.90 (freier Preis)    16
#> 2            Broschur : circa EUR 12.80 (DE), circa EUR 13.20 (AT)    88
#> 3 : EUR 29.95 (DE), EUR 29.95 (DE), EUR 30.80 (AT), EUR 30.30 (AT)     2
#>              format                  edition keyword  toc
#> 1 17.3 cm x 17.3 cm                     <NA>    <NA> <NA>
#> 2     19 cm x 12 cm 1. Auflage, neue Ausgabe    <NA> <NA>
#> 3              <NA>               1. Auflage    <NA> <NA>
#>                                                                                               description
#> 1 http://deposit.d-nb.de/cgi-bin/dokserv?id=992efedfe14a4b06ad7dc4f344cd9e87&prov=M&dok_var=1&dok_ext=htm
#> 2                                                                                                    <NA>
#> 3                                                                                                    <NA>
#>                                                             cover
#> 1 https://portal.dnb.de/opac/mvb/cover.htm?isbn=978-3-8458-1588-6
#> 2 https://portal.dnb.de/opac/mvb/cover.htm?isbn=978-3-942788-37-3
#> 3 https://portal.dnb.de/opac/mvb/cover.htm?isbn=978-3-941933-20-0
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

#### Advanced search - `dnb_advanced`

`dnb_advanced` allows for complex requests using the Contextual Query Language (CQL). See the [DNB advanced search help pages](https://www.dnb.de/expertensuche) for available indices and a list of examples.

The following advanced search returns a list of german or english children's books titled with 'cat', excluding titles containing 'dog', since the year 2001:


```r
cats <- dnb_advanced("( (tit=katze OR tit=kater NOT tit=hund) OR (tit=cat NOT tit=dog) ) AND jhr>2000 AND mat=books AND (spr=ger OR spr=eng) AND sgt=K", limit="all")
```


### Utils

#### Number of records

Use `n_rec` to get the total number of records found by a request:


```r
n_rec(cats)
#> [1] 5895
```

#### Print query

To print the query used for a DNB-search, call `print_query`:


```r
print_query(cats)
#> [1] "(tit=katze)"
```

You can use this query (or an edited version) directly with the `dnb_advanced` function:


```r
cat.q <- print_query(cats)
cat.q <- gsub("jhr>2000", "jhr>=2015", cat.q) # change year
dnb_advanced(cat.q)
```
