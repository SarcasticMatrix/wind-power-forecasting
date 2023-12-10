################################################################################
# Test model
################################################################################
library(tseries)
library(progress) # tqdm loop


forecast1H_ARIMA <- function(dataTest,p=1,d=1,q=1,plotBoolean=FALSE){
  
  pHat <- data.frame(
      t = dataTest$t,
      pHat = NaN,
      residuals = NaN,
      standardErrors = NaN,
      upperBound = NaN,
      lowerBound = NaN)
  
  startDate <- dataTest$t[10]
  
  # Create a progress bar
  pb <- progress_bar$new(
    format = "[:bar] :percent Time remaining: :eta",
    total = length(dataTest[dataTest$t > startDate,]$t)
  )
  
  cat("Starting to compute the forecasts ... \n")
  
  for(date in dataTest[dataTest$t > startDate,]$t) {
    
    availableData <- dataTest[dataTest$t < date,]
    
    model <- arima(availableData$p,order=c(p,d,q))
    
    mask <- pHat$t == date - 60*60
    pHat[mask,]$pHat <- predict(model,1)$pred
    pHat[mask,]$standardErrors <- predict(model,1)$se

    # Update the progress bar
    pb$tick()
  }
  
  pHat$upperBound <- pHat$pHat + qnorm((1 + conf_level) / 2) * pHat$standardErrors
  pHat$lowerBound <- pHat$pHat - qnorm((1 + conf_level) / 2) * pHat$standardErrors
  
  cat("Computing the forecasts is done ... \n")
  
  if(plotBoolean){
    
    data_range <- 1:240
    x11()
    plot(dataTest$p[data_range] ~ dataTest$t[data_range], ylab="power", xlab='date',type='n')
    # Interval de confiance
    conf_level <- 0.95
    N <- length(dataTest$t)
    upperBound <- pHat$pHat[data_range] + qnorm((1 + conf_level) / 2) * pHat$standardErrors[data_range]
    lowerBound <- pHat$pHat[data_range] - qnorm((1 + conf_level) / 2) * pHat$standardErrors[data_range]
    polygon(c(pHat$t[data_range], rev(pHat$t[data_range])), c(upperBound, rev(lowerBound)), col='gray', border=NA)
    
    lines(dataTest$p[data_range] ~ dataTest$t[data_range])
    lines(pHat$pHat[data_range] ~ pHat$t[data_range],col='red')
    legend("topright", legend=c("Measured", "1-hour ahead forecast", "95% Confidence Interval"),
           col=c("black", "red", "gray"), lty=1:1, cex=0.8)
  }

  pHat$residuals <- pHat$pHat - dataTest$p
  pHat <- na.omit(pHat)
  return(pHat)
}

forecast2H_ARIMA <- function(dataTest,p=1,d=1,q=1,plotBoolean=FALSE){
  
  pHat <- data.frame(
    t = dataTest$t,
    pHat1 = NaN,
    pHat2 = NaN,
    residuals1 = NaN,
    residuals2 = NaN,
    standardErrors1 = NaN,
    standardErrors2 = NaN,
    upperBound = NaN,
    lowerBound = NaN)
  
  startDate <- dataTest$t[10]
  
  # Create a progress bar
  pb <- progress_bar$new(
    format = "[:bar] :percent Time remaining: :eta",
    total = length(dataTest[dataTest$t > startDate,]$t)
  )
  
  cat("Starting to compute the forecasts ... \n")
  
  for(date in dataTest[dataTest$t > startDate,]$t) {
    
    availableData <- dataTest[dataTest$t < date,]
    
    model <- arima(availableData$p,order=c(p,d,q))
    
    mask <- pHat$t == date - 60*60
    
    pHat[mask,]$pHat1 <- predict(model,2)$pred[1]
    pHat[mask,]$pHat2 <- predict(model,2)$pred[2]
    
    pHat[mask,]$standardErrors1 <- predict(model,2)$se[1]
    pHat[mask,]$standardErrors2 <- predict(model,2)$se[2]
    
    # Update the progress bar
    pb$tick()
  }
  
  pHat$upperBound1 <- pHat$pHat1 + qnorm((1 + conf_level) / 2) * pHat$standardErrors1
  pHat$lowerBound1 <- pHat$pHat1 - qnorm((1 + conf_level) / 2) * pHat$standardErrors1
  
  pHat$upperBound2 <- pHat$pHat2 + qnorm((1 + conf_level) / 2) * pHat$standardErrors2
  pHat$lowerBound2 <- pHat$pHat2 - qnorm((1 + conf_level) / 2) * pHat$standardErrors2
  
  cat("Computing the forecasts is done ... \n")
  
  if(plotBoolean){
    
    data_range <- 1:240
    x11()
    plot(dataTest$p[data_range] ~ dataTest$t[data_range], ylab="power", xlab='date',type='n')
    
    polygon(c(pHat$t[data_range], rev(pHat$t[data_range])), c(pHat$upperBound2[data_range], rev(pHat$lowerBound2[data_range])), col='gray', border=NA)
    
    lines(dataTest$p[data_range] ~ dataTest$t[data_range])
    lines(pHat$pHat1[data_range] ~ pHat$t[data_range],col='red')
    lines(pHat$pHat2[data_range] ~ pHat$t[data_range],col='green')
    legend("topright", legend=c("Measured", "1-hour ahead forecast","2-hour ahead forecast", "95% Confidence Interval"),
           col=c("black", "red", "green", "gray"), lty=1:1, cex=0.8)
  }
  
  pHat$residuals1 <- pHat$pHat1 - dataTest$p
  pHat$residuals2 <- pHat$pHat2 - dataTest$p
  return(pHat)
}




