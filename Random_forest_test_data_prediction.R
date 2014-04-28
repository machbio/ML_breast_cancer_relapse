library(randomForest)
library(ROCR)
require(Hmisc)

RF_model_file="RF_model"
datafile="testdata_gcrma.txt"
clindatafile="testdata_clindetails.txt"
outfile="testset_RFoutput.txt"
case_pred_outfile="testset_RF_CasePredictions.txt"
ROC_pdffile="testset_RF_ROC.pdf"

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

load(file=RF_model_file)

RF_predictions_responses=predict(rf_output, predictor_data, type="response")
RF_predictions_votes=predict(rf_output, predictor_data, type="vote")

clindata_plusRF=cbind(clindata,RF_predictions_responses,RF_predictions_votes)
clindata_plusRF=clindata_plusRF[which(!is.na(clindata_plusRF[,"event.rfs"])),]
write.table(clindata_plusRF,file=case_pred_outfile, sep="\t", quote=FALSE, col.names=TRUE, row.names=FALSE)

confusion=table(clindata_plusRF[,c("event.rfs","RF_predictions_responses")])
rownames(confusion)=c("NoRelapse","Relapse")
sensitivity=(confusion[2,2]/(confusion[2,2]+confusion[2,1]))*100
specificity=(confusion[1,1]/(confusion[1,1]+confusion[1,2]))*100
overall_error=((confusion[1,2]+confusion[2,1])/sum(confusion))*100
overall_accuracy=((confusion[1,1]+confusion[2,2])/sum(confusion))*100
class1_error=confusion[1,2]/(confusion[1,1]+confusion[1,2])
class2_error=confusion[2,1]/(confusion[2,2]+confusion[2,1])

sens_out=paste("sensitivity=",sensitivity, sep="")
spec_out=paste("specificity=",specificity, sep="")
err_out=paste("overall error rate=",overall_error,sep="")
acc_out=paste("overall accuracy=",overall_accuracy,sep="")
misclass_1=paste(confusion[1,2], colnames(confusion)[1],"misclassified as", colnames(confusion)[2], sep=" ")
misclass_2=paste(confusion[2,1], colnames(confusion)[2],"misclassified as", colnames(confusion)[1], sep=" ")
confusion_out=confusion[1:2,1:2]
confusion_out=cbind(rownames(confusion_out), confusion_out)

write("confusion table", file=outfile)
write.table(confusion_out,file=outfile, sep="\t", quote=FALSE, col.names=TRUE, row.names=FALSE, append=TRUE)
write(c(sens_out,spec_out,acc_out,err_out,misclass_1,misclass_2,AUC_out), file=outfile, append=TRUE)

target=clindata_plusRF[,"event.rfs"]
target[target==1]="Relapse"
target[target==0]="NoRelapse"
relapse_scores=clindata_plusRF[,"Relapse"]

pred=prediction(relapse_scores,target)
perf_AUC=performance(pred,"auc")
AUC=perf_AUC@y.values[[1]]
AUC_out=paste("AUC=",AUC,sep="")
perf_ROC=performance(pred,"tpr","fpr")
pdf(file=ROC_pdffile)
plot(perf_ROC, main="ROC plot")
text(0.5,0.5,paste("AUC = ",format(AUC, digits=5, scientific=FALSE)))
dev.off()

