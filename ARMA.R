################################################################################
# Test model
################################################################################
library(tseries)

dataTraining <- data[data$year == "1999",]
dataTraining <- na.omit(dataTraining)
armaFit <- arima(dataTraining$p,order=c(1,1,1))

forecast1H_ARIMA <- function(dataTest,p=1,d=1,q=1,plot=FALSE){
  
  predictions <- data.frame(
      t = dataTest$t,
      p1Hat = NaN)
  
  startDate <- dataTest$t[10]
  cat("Starting to compute the forecasts ... \n")
  for(date in dataTest[dataTest$t > startDate,]$t) {
    
    availableData <- dataTest[dataTest$t < date,]
    
    model <- arima(availableData$p,order=c(p,d,q))
    pred <- predict(model,1)$pred
    predictions[predictions$t == date,]$p1Hat <- pred
  }
  cat("Computing the forecasts is done ... \n")
  
  if(plot){
    data_range <- 1:240
    plot(dataTest$p[data_range] ~ dataTest$t[data_range], ylab="power", xlab='date',type='n')
    lines(dataTest$p[data_range] ~ dataTest$t[data_range])
    lines(predictions$p1Hat[data_range] ~ dataTest$t[data_range], col='red')
    legend( "topright",c("Measured", "1-hour ahead forecast"), lty=1, col=1:2, bg="grey95")
    
  }
  return(predictions)
}

data_range <- 1:240
plot(dataTest$p[data_range] ~ dataTest$t[data_range], ylab="power", xlab='date',type='n')
lines(dataTest$p[data_range] ~ dataTest$t[data_range])
lines(predictions$p1Hat[data_range] ~ dataTest$t[data_range], col='red')
