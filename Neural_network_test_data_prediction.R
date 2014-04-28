library(nnet)
library(ROCR)
require(Hmisc)

NE_model_file="NE_model"

datafile="testdata_gcrma.txt"
clindatafile="testdata_clindetails.txt"
ROC_pdffile="testset_NE_ROC.pdf"

data_import=read.table(datafile, header = TRUE, na.strings = "NA", sep="\t")
clin_data_import=read.table(clindatafile, header = TRUE, na.strings = "NA", sep="\t")
clin_data_order=order(clin_data_import[,"geo_accn"])
clindata=clin_data_import[clin_data_order,]
data_order=order(colnames(data_import)[4:length(colnames(data_import))])+3 
rawdata=data_import[,c(1:3,data_order)] 
header=colnames(rawdata)

predictor_data=t(rawdata[,4:length(header)])
predictor_names=as.vector((rawdata[,3])) 
colnames(predictor_data)=predictor_names

NE_predictions_responses=predict(neural_model, predictor_data, type="raw")
NE_predictions_votes=predict(neural_model, predictor_data, type="class")

clindata_plusRF=cbind(clindata,NE_predictions_responses,NE_predictions_votes)
clindata_plusRF=clindata_plusRF[which(!is.na(clindata_plusRF[,"event.rfs"])),]

target=clindata_plusRF[,"event.rfs"]
relapse_scores=clindata_plusRF[,"NE_predictions_responses"]

load(file=NE_model_file)

pred=prediction(relapse_scores,target)
perf_AUC=performance(pred,"auc")
AUC=perf_AUC@y.values[[1]]
perf_ROC=performance(pred,"tpr","fpr")
pdf(file=ROC_pdffile)
plot(perf_ROC, main="ROC plot")
text(0.5,0.5,paste("AUC = ",format(AUC, digits=5, scientific=FALSE)))
dev.off()
