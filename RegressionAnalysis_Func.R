# Regression coefficients
Regression=function(X,Y)
{
  lm_raw=lm(X~Y)
  lm_s=summary(lm_raw)
  p=lm_s$coefficients[2,4]
  R.squared=lm_s$r.squared
  Adj.R.squared=lm_s$adj.r.squared
  Result=list(r.squared=R.squared,adj.r.squared=Adj.R.squared,p=p)
  return(Result)
}

RegressionDf=function(Df,GroupCol,FeatureCols,P.adj.Method='BH'){
  Groups=levels(as.factor(Df[,GroupCol]))
  if(length(Groups)==2){
    ResultDf=as.data.frame(FeatureCols)
    for(i in c(1:length(FeatureCols))){
      Feature=FeatureCols[i]
      X=Df[Df[,GroupCol]==Groups[1],Feature]
      Y=Df[Df[,GroupCol]==Groups[2],Feature]
      Result=tryCatch(Regression(X,Y),error=function(x){return("error")},silent=TRUE)
      if (all(Result!='error')){
        ResultDf$R.squared[i]=Result$r.squared
        ResultDf$Adj.R.squared[i]=Result$adj.r.squared
        ResultDf$p[i]=Result$p
      }
      
    }
  }else{
    stop('GroupCol should only contain 2 groups')
  }
  ResultDf$adjp[!is.na(ResultDf$p)]=p.adjust(ResultDf$p[!is.na(ResultDf$p)],
                                             method = P.adj.Method)
  return(ResultDf)
}


RemoveNa=function(Df){
  temp=c()
  for(i in c(1:dim(Df)[2])){
    temp[i]=all(is.na(Df[,i]))
  }
  #print(temp)
  return(Df[,!temp]) 
  }
 

