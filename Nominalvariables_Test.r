Nominalvariables_Test=function(Df,Groups,Nominalvariables){
  G=Df[,Groups]
  FinialDf=c()
  Paired=c()
  Result=list()
  for(v in Nominalvariables){
    #print(v)
    VVal=Df[,v]
    count=table(G,VVal)
    #countDf=as.data.frame.matrix(count)
    #colnames(countDf)=paste0(colnames(countDf),'_Count')
    percent=prop.table(count,1)
    #percentDf=as.data.frame.matrix(percent)
    #colnames(percentDf)=paste0(colnames(percentDf),'_Percent')
    MergedList=paste0(count,'(',percent,')')
    temp=as.data.frame(matrix(MergedList,nrow=dim(count)[1]))
    colnames(temp)=paste0(v,'.',colnames(count))
    rownames(temp)=rownames(count)
    
    Df1=as.data.frame(t(temp))
    if(any(count<=5)){
      R=fisher.test(count,simulate.p.value=TRUE,B=1e7)
      p=R$p.value
      if(p<0.05){
        PairedTest=pairwiseNominalIndependence(count,fisher = TRUE, gtest  = FALSE,chisq  = FALSE,digits = 3)
        rownames(PairedTest)=paste0(v,'_',rownames(PairedTest))
        Paired=rbind(Paired,PairedTest)
      }
    }else{
      R=chisq.test(count)
      p=R$p.value
      if(p<0.05){
        PairedTest=pairwiseNominalIndependence(count,fisher = FALSE, gtest  = FALSE,chisq  = TRUE,digits = 3)
        rownames(PairedTest)=paste0(v,'_',rownames(PairedTest))
        Paired=rbind(Paired,PairedTest)
        }
    }
    
    Df1$p=p
    FinialDf=rbind(FinialDf,Df1)
  }
  Result[['PairedDf']]=Paired
  Result[['FinialDf']]=FinialDf
  return(Result)
}
Result=Nominalvariables_Test(Df = Df,Groups = 'GeneTpye',Nominalvariables = c('RaceUse','Smoker','Mets','HistologyUse1'))
