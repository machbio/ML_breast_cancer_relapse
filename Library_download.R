# Installing the Libraries
source("http://bioconductor.org/biocLite.R")
biocLite()
biocLite("GEOquery")
biocLite("affy")
biocLite("gcrma")
biocLite("org.Hs.eg.db")

# Installing the Probe Libraries
#biocLite("hgu133ahsentrezgcdf")
#biocLite("hgu133ahsentrezgprobe")
#biocLite("hgu133ahsentrezg.db")
install.packages("./Rlibs/hgu133ahsentrezgprobe_18.0.0.tar.gz", repos = NULL)
install.packages("./Rlibs/hgu133ahsentrezgcdf_18.0.0.tar.gz", repos = NULL)
install.packages("./Rlibs/hgu133ahsentrezg.db_18.0.0.tar.gz", repos = NULL)

install.packages("randomForest")
install.packages("ROCR")
install.packages("Hmisc")
source("http://bioconductor.org/biocLite.R")
biocLite("genefilter")
