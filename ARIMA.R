################################################################################
# Test model
################################################################################
library(tseries)
library(progress) # tqdm loop


forecast1H_ARIMA <- function(dataTest,p=1,d=1,q=1,plot=FALSE){
  # Input :
  # Output : dataframe p1Hat with columns $t, $pHat and $residuals
  
  p1Hat <- data.frame(
      t = dataTest$t,
      pHat = NaN,
      residuals = NaN,
      standardErrors = NaN)
  
  startDate <- dataTest$t[10]
  cat("Starting to compute the forecasts ... \n")
  
  # Create a progress bar
  pb <- progress_bar$new(
    format = "[:bar] :percent Time remaining: :eta",
    total = length(dataTest[dataTest$t > startDate,]$t)
  )
  
  for(date in dataTest[dataTest$t > startDate,]$t) {
    
    availableData <- dataTest[dataTest$t < date,]
    
    model <- arima(availableData$p,order=c(p,d,q))
    p1Hat[p1Hat$t == date - 60*60,]$pHat <- predict(model,1)$pred
    p1Hat[p1Hat$t == date - 60*60,]$standardErrors <- predict(model,1)$se
    
    # Update the progress bar
    pb$tick()
  }

  cat("Computing the forecasts is done ... \n")
  
  if(plot){
    
    data_range <- 1:240
    plot(dataTest$p[data_range] ~ dataTest$t[data_range], ylab="power", xlab='date',type='n')
    # Interval de confiance
    conf_level <- 0.95
    N <- length(dataTest$t)
    upperBound <- p1Hat$pHat[data_range] + qnorm((1 + conf_level) / 2) * p1Hat$standardErrors[data_range]
    lowerBound <- p1Hat$pHat[data_range] - qnorm((1 + conf_level) / 2) * p1Hat$standardErrors[data_range]
    polygon(c(p1Hat$t[data_range], rev(p1Hat$t[data_range])), c(upperBound, rev(lowerBound)), col='gray', border=NA)
    
    lines(dataTest$p[data_range] ~ dataTest$t[data_range])
    lines(p1Hat$pHat[data_range] ~ p1Hat$t[data_range],col='red')
    legend("topright", legend=c("Measured", "1-hour ahead forecast", "95% Confidence Interval"),
           col=c("black", "red", "gray"), lty=1:1, cex=0.8)
  }

  p1Hat$residuals <- p1Hat$pHat - dataTest$p
  p1Hat <- na.omit(p1Hat)
  return(p1Hat)
}
dataTest <- data[data$t < "1999-05-01",]
p1Hat <- forecast1H_ARIMA(dataTest,plot=TRUE)




