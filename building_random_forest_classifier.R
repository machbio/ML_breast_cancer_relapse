library(randomForest)
library(ROCR)
library(genefilter)
library(Hmisc)

datafile="trainset_gcrma.txt" 
clindatafile="trainset_clindetails.txt"
outfile="rf_trainset_RFoutput.txt"
ROC_pdffile="rf_trainset_ROC.pdf"

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
rf_output=randomForest(x=predictor_data, y=target, importance = TRUE, ntree = 10001, proximity=TRUE, sampsize=sampsizes)

save(rf_output, file="RF_model")
load("RF_model")

rf_importances=importance(rf_output, scale=FALSE)

confusion=rf_output$confusion
sensitivity=(confusion[2,2]/(confusion[2,2]+confusion[2,1]))*100
specificity=(confusion[1,1]/(confusion[1,1]+confusion[1,2]))*100
overall_error=rf_output$err.rate[length(rf_output$err.rate[,1]),1]*100
overall_accuracy=1-overall_error
class1_error=paste(rownames(confusion)[1]," error rate= ",confusion[1,3], sep="")
class2_error=paste(rownames(confusion)[2]," error rate= ",confusion[2,3], sep="")
overall_accuracy=100-overall_error

sens_out=paste("sensitivity=",sensitivity, sep="")
spec_out=paste("specificity=",specificity, sep="")
err_out=paste("overall error rate=",overall_error,sep="")
acc_out=paste("overall accuracy=",overall_accuracy,sep="")
misclass_1=paste(confusion[1,2], rownames(confusion)[1],"misclassified as", colnames(confusion)[2], sep=" ")
misclass_2=paste(confusion[2,1], rownames(confusion)[2],"misclassified as", colnames(confusion)[1], sep=" ")
confusion_out=confusion[1:2,1:2]
confusion_out=cbind(rownames(confusion_out), confusion_out)

write.table(rf_importances[,4],file=outfile, sep="\t", quote=FALSE, col.names=FALSE)
write("confusion table", file=outfile, append=TRUE)
write.table(confusion_out,file=outfile, sep="\t", quote=FALSE, col.names=TRUE, row.names=FALSE, append=TRUE)
write(c(sens_out,spec_out,acc_out,err_out,class1_error,class2_error,misclass_1,misclass_2), file=outfile, append=TRUE)

predictions=as.vector(rf_output$votes[,2])
pred=prediction(predictions,target)
perf_AUC=performance(pred,"auc")
AUC=perf_AUC@y.values[[1]]
perf_ROC=performance(pred,"tpr","fpr")
pdf(file=ROC_pdffile)
plot(perf_ROC, main="ROC plot")
text(0.5,0.5,paste("AUC = ",format(AUC, digits=5, scientific=FALSE)))
dev.off()

