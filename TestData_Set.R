# Loading the Standard Libraries
library(GEOquery)
library(affy)
library(gcrma)
# Load All the Libraries
library(hgu133ahsentrezgcdf) #cdfname="HGU133A_HS_ENTREZG"
library(hgu133ahsentrezgprobe)
library(hgu133ahsentrezg.db)

# download dataset
getGEOSuppFiles("GSE2990")
untar("GSE2990/GSE2990_RAW.tar", exdir="GSE2990/data")
cels <- list.files("GSE2990/data/", pattern = "[gz]")
sapply(paste("GSE2990/data", cels, sep="/"), gunzip)
cels = list.files("GSE2990/data/", pattern = "CEL")

setwd("GSE2990/data")
getwd()

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

write.table(gcrma, file = "testdata_gcrma.txt", quote = FALSE, sep = "\t", row.names = FALSE, col.names = TRUE)

GSE2990_clindata=read.table("ftp://ftp.ncbi.nlm.nih.gov/geo/series/GSE2nnn/GSE2990/suppl/GSE2990_suppl_info.txt", header=TRUE)
write.table(GSE2990_clindata, "testdata_clindetails.txt", quote = FALSE, sep = "\t", row.names = FALSE)
