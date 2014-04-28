# Loading the Standard Libraries
library(GEOquery)
library(affy)
library(gcrma)
# Load All the Libraries
library(hgu133ahsentrezgcdf) #cdfname="HGU133A_HS_ENTREZG"
library(hgu133ahsentrezgprobe)
library(hgu133ahsentrezg.db)

# download dataset
getGEOSuppFiles("GSE2034")
untar("GSE2034/GSE2034_RAW.tar", exdir="GSE2034/data")
cels <- list.files("GSE2034/data/", pattern = "[gz]")
sapply(paste("GSE2034/data", cels, sep="/"), gunzip)
cels = list.files("GSE2034/data/", pattern = "CEL")

getwd()
setwd("GSE2034/data")

raw.data=ReadAffy(verbose=TRUE,filenames=cels, cdfname="HGU133A_HS_ENTREZG") 
data.gcrma.norm=gcrma(raw.data)

gcrma=exprs(data.gcrma.norm)
gcrma=gcrma[1:12030,]

probes=row.names(gcrma)
symbol = unlist(mget(probes, hgu133ahsentrezgSYMBOL))
ID = unlist(mget(probes, hgu133ahsentrezgENTREZID))
gcrma=cbind(probes,ID,symbol,gcrma)


setwd("/home/mllearn/ML_breast_cancer_relapse/")
getwd()

write.table(gcrma, file = "trainset_gcrma.txt", quote = FALSE, sep = "\t", row.names = FALSE, col.names = TRUE)
GSE2034_clindata=getGSEDataTables("GSE2034")[[2]][1:286,]
write.table(GSE2034_clindata, "trainset_clindetails.txt", quote = FALSE, sep = "\t", row.names = FALSE)
