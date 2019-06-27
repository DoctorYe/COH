setwd('/Users/ningrongye/Desktop/python/Gene/JN/')
# Table clean

DfRaw=read.csv('./feature.csv')
ColNameUse=paste(colnames(DfRaw),as.matrix(DfRaw)[1,],sep = '.')
#colnames(DfRaw)=ColNameUse

ColNameUse[1]='Group'
dim(DfRaw[-1,])
# 18 1562
DfUse=as.data.frame(
  matrix(
    as.numeric(as.matrix(DfRaw[-1,])),
    nrow = 18,
    ncol = 1562)
  )

colnames(DfUse)=ColNameUse
DfUse1=RemoveNa(DfUse)
ReulstDf=RegressionDf(Df=DfUse1,GroupCol = 'Group',
                      FeatureCols = ColNameUse[-1])
write.csv(ReulstDf,'./Feature_Cor.csv')
