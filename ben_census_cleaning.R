
###### Benin 2016 Village-Level Census #######
## Cleaning PDF table of preliminary Census results. 
## To be used for survey sampling
## To be merged with: GIS data to get population density 
##################################################


library(stringr)
setwd("C:\\Users\\Sanata\\Documents\\AAB_Benin\\Census")

vill <- read.csv("C:\\Users\\Sanata\\Documents\\AAB_Benin\\Census\\census_villages_2013.csv")
colnames(vill) <- c("division", "nombre.men", "total", "masc", "fem", "taille.men") #assign col names
vill <- vill[!apply(vill == "", 1, any),] #cut empty vectors 
vill <-vill[-1, ] #cut benin vector 
vill[, 1:6] <- sapply(vill[, 1:6], as.character) #de-factor 
vill[, 2:6] <- sapply(vill[, 2:6], function(x) gsub(" ", "", x)) #take out blank spaces 
vill[, 6] <- gsub(",", ".", vill[, 6]) #take out commas 
vill[, 2:6] <- sapply(vill[, 2:6], as.numeric) #convert to numeric 

#create empty vectors 
vill$dep <- NA
vill$com <- NA
vill$arr <- NA

##find departments 
headers.dep <- grep("DEP:", vill$division, value=F)
dep.lab <- gsub("DEP:", "", vill$division[headers.dep])
dep.lab <- gsub(" ", "", dep.lab)
#num <- findInterval(row(vill)[,1], headers.dep, rightmost.closed = F)
dep.assign <- cut(row(vill)[,1], c(headers.dep, max(row(vill)[,1])), right=F, labels=dep.lab)
vill$dep <- as.character(dep.assign)
dep.data.frame <- vill[headers.dep, -c(8:9) ]
write.csv(dep.data.frame, file="census_by_dept2013.csv")


##find communes 
headers.com <- grep("COM:", vill$division, value=F)
com.lab <- gsub("COM:", "", vill$division[headers.com])
com.lab <- gsub(" ", "", com.lab)
com.assign <- cut(row(vill)[,1], c(headers.com, max(row(vill)[,1])), right=F, labels=com.lab)
vill$com <- as.character(com.assign)
com.data.frame <- vill[headers.com, -9]
write.csv(com.data.frame, file="census_by_com2013.csv")

##find arrondissements 
headers.arr <- grep("ARROND:", vill$division, value=F)
arr.lab <- gsub("ARROND:", "", vill$division[headers.arr])
arr.lab <-  gsub(" ", "", arr.lab)
arr.assign <- cut(row(vill)[,1], c(headers.arr, max(row(vill)[,1])), right=F, labels=arr.lab)
vill$arr <- as.character(arr.assign)
#glitch: doesn't assign the last arrondissement observation; added manually 
vill$arr[4404] <- vill$arr[4403]
arr.data.frame <- vill[headers.arr, ]
write.csv(arr.data.frame, file="census_by_arr2013.csv")

##clean village-level dataset 
cut.vill <- vill[-c(headers.dep, headers.com, headers.arr), ]
colnames(cut.vill)[which(colnames(cut.vill)=="division")] <- "village"  #change division label
cut.vill$village <- str_trim(cut.vill$village, side="both")
cut.vill <- cut.vill[, c(7:9, 1, 2:6)] #reorder variables 
write.csv(cut.vill, file="census_by_village2013.csv")



class(cen$Arrond)
