library(nnet)
library(ROCR)
library(genefilter)
library(Hmisc)

datafile="trainset_gcrma.txt" 
clindatafile="trainset_clindetails.txt"
outfile="ne_trainset_output.txt"
ROC_pdffile="ne_trainset_ROC.pdf"

data_import=read.table(datafile, header = TRUE, na.strings = "NA", sep="\t")
clin_data_import=read.table(clindatafile, header = TRUE, na.strings = "NA", sep="\t")
clin_data_order=order(clin_data_import[,"GEO.asscession.number"])
clindata=clin_data_import[clin_data_order,]
data_order=order(colnames(data_import)[4:length(colnames(data_import))])+3 
rawdata=data_import[,c(1:3,data_order)] 
header=colnames(rawdata)

X=rawdata[,4:length(header)]
ffun=filterfun(pOverA(p = 0.2, A = 100), cv(a = 0.7, b = 10))
filt=genefilter(2^X,ffun)
filt_Data=rawdata[filt,]

predictor_data=t(filt_Data[,4:length(header)])
predictor_names=c(as.vector(filt_Data[,3])) 
colnames(predictor_data)=predictor_names

target= clindata[,"relapse..1.True."]
target[target==0]="NoRelapse"
target[target==1]="Relapse"
target=as.factor(target)

tmp = as.vector(table(target))
num_classes = length(tmp)
min_size = tmp[order(tmp,decreasing=FALSE)[1]]
sampsizes = rep(min_size,num_classes)

neural_model = nnet(target~., data=predictor_data,size=20,maxit=100,decay=.001, MaxNWts =30000 )

save(neural_model, file="NE_model")
load("NE_model")

pred = prediction(predict(neural_model,newdata=predictor_data,type="raw"),target)
perf_AUC=performance(pred,"auc")
AUC=perf_AUC@y.values[[1]]
perf_ROC=performance(pred,"tpr","fpr")
pdf(file=ROC_pdffile)
plot(perf_ROC, main="ROC plot")
text(0.5,0.5,paste("AUC = ",format(AUC, digits=5, scientific=FALSE)))
dev.off()
