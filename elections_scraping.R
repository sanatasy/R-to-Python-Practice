library("XML")

##Getting country names and links
homepage <- htmlParse("http://africanelections.tripod.com/")

countries.and.paths <- xpathApply(homepage, "//table[3]/tr[2]/td/div/font/div/center[9]/font/table/tbody/tr/td/font/a")
paths <- sapply(countries.and.paths, xmlGetAttr, "href")
countries <- sapply(countries.and.paths, xmlValue)

data <- data.frame(cbind(paths, countries))
colnames(data) <- c("path", "country")

###### Text Scraping for Angola ###### 

page <- htmlParse("http://africanelections.tripod.com/ao.html") 

##Getting election years 
x <- xpathApply(page, "//body/table[4]/tr/td/table/tr/td/div//a")
years <- sapply(x, xmlValue)
years <- as.numeric(years)
anchors <- sapply(x, xmlGetAttr, name = "href", default = NA)
elections <- cbind(as.numeric(years), anchors)
elections <- elections[!is.na(years), ]
elections <- apply(elections, 2, sort)

page <- htmlParse("http://africanelections.tripod.com/ao.html") 
# x <- xpathApply(page, "//body/table[4]/tr/td/table/tr/td/div") # works on every page

##Getting Angola page content 
x <- xmlRoot(page)
body.x <- x[["body"]]
content.divs <- getNodeSet(body.x, "//body/table[4]/tr/td/table/tr/td/div//div")
content.tables <- getNodeSet(content.divs[[1]], "//div/table" )
content.rows <- getNodeSet(content.divs[[1]], "//div/table/tbody/tr" )
content.cells <- getNodeSet(content.divs[[1]], "//div/table/tbody/tr/td")

##Alternative method using pathapply
divs <- xpathApply(page, "//body/table[4]/tr/td/table/tr/td/div//div")
tables <- xpathApply(page, "//body/table[4]/tr/td/table/tr/td/div//div/table")
cells <- xpathApply(page, "//body/table[4]/tr/td/table/tr/td/div//div/table/tbody/tr/td")
words <- sapply(cells, xmlValue)
words2 <- sapply(tables, xmlValue)


words <- sapply(tables[2], xmlValue)
words<- cat(words, sep = "\n")



#################### IPU Website ######################

year <- c("91", "95", "99", "03", "07")
html <- paste("http://www.ipu.org/parline-e/reports/arc/2033_", year, ".htm", sep = "")

page <- htmlParse("http://www.ipu.org/parline-e/reports/arc/2033_95.htm")

tree <- xmlRoot(page)
body <- tree[["body"]]
tables <- getNodeSet(body, "//table")


