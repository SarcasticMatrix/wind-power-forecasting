################################################################################
## PLOTTING FUNCTIONS
################################################################################
library(dbplyr)


################################################################################
################################################################################
################################################################################
plotYear <- function(data,year){
  data$year <- format(data$t,"%Y")
  if (year %in%  unique(data$year)) {
    dataYear <- data[data$year== year,]
    gridSeq <- seq(min(dataYear$t), by="months", length=12)
    
    # Personnalisation des paramètres graphiques
    par(mfrow=c(4,1), mar=c(1, 5, 1.5, 1), oma=c(2, 2, 2, 1))
    
    # Plot measured average wind power
    plot(dataYear$p ~ dataYear$t,  ylab="measured average wind power", xlab="", type="n")
    abline(v=gridSeq, col="grey92")
    lines(dataYear$p ~ dataYear$t)
    
    # Plot 1,2,3-hour ahead forecasted wind speed.
    plot(dataYear$Ws1 ~ dataYear$t, type="n", xlab="", ylab="wind speed")
    abline(v=gridSeq, col="grey85", lty=3)
    lines(dataYear$Ws1 ~ dataYear$t)
    lines(dataYear$Ws2 ~ dataYear$t, col=2)
    lines(dataYear$Ws3 ~ dataYear$t, col=3)
    legend("bottomright", c("1-hour ahead", "2-hour ahead", "3-hour ahead"), lty=1, col=1:3, bg="grey95")
    
    # Plot 1,2,3-hour ahead forecasted wind direction
    plot(dataYear$Wd1 ~ dataYear$t, type="n", xlab="", ylab="wind direction")
    abline(v=gridSeq, col="grey85", lty=3)
    lines(dataYear$Wd1 ~ dataYear$t)
    lines(dataYear$Wd2 ~ dataYear$t, col=2)
    lines(dataYear$Wd3 ~ dataYear$t, col=3)
    legend("bottomright", c("1-hour ahead", "2-hour ahead", "3-hour ahead"), lty=1, col=1:3, bg="grey95")
    
    # Plot 1,2,3-hour ahead forecasted temperature
    plot(dataYear$T1 ~ dataYear$t, type="n", xlab="", ylab="temperature")
    abline(v=gridSeq, col="grey85", lty=3)
    lines(dataYear$T1 ~ dataYear$t)
    lines(dataYear$T2 ~ dataYear$t, col=2)
    lines(dataYear$T3 ~ dataYear$t, col=3)
    legend("bottomright", c("1-hour ahead", "2-hour ahead", "3-hour ahead"), lty=1, col=1:3, bg="grey95")
    axis.POSIXct(1, dataYear$t, xaxt="n", format="%Y-%m-%d")
  }
  else {
    cat ('The year',year,'is not part of the dataset')
  }
}
################################################################################
################################################################################
################################################################################
plotResiduals <- function(residuals) {
  
  par(mfrow=c(2, 2))
  
  # Residuals ACF
  acf(residuals, lag.max=6*12, main="Residuals ACF")
  
  # Histogram of residuals
  hist(residuals, main="Histogram of Residuals", xlab="Residuals")
  
  # Raw periodogram
  spec.pgram(residuals, main="Raw periodogram")
  
  # Cumulated periodogram
  cpgram(residuals, main="Cumulated periodogram")
  
  
  x11()
  qqnorm(p1Hat$residuals, pch = 1, frame = FALSE)
  qqline(p1Hat$residuals, col = "steelblue", lwd = 2)
}
################################################################################
################################################################################
################################################################################
library(Metrics)
plotResidualsTimeSeries_1hAhead <- function(p1Hat,data){
  
  gridSeq <- seq(min(data$t), by="months", length=12)
  
  par(mfrow=c(5,1), mar=c(1, 5, 1.5, 1), oma=c(2, 2, 2, 1))
  
  # Plot residuals
  plot(p1Hat$residuals ~ data$t, ylab="residuals", xlab="", type="n")
  abline(v=gridSeq, col="grey92")
  lines(p1Hat$residuals ~ data$t,col='blue')
  
  # Plot measured power and 1-hour ahead forecasted power 
  plot(data$p ~ data$t, ylab="power", xlab="", type="n")
  abline(v=gridSeq, col="grey92")
  lines(p1Hat$pHat ~ data$t,col='red')
  lines(data$p ~ data$t)
  legend( "topright",c("Measured", "1-hour ahead forecast"), lty=1, col=1:2, bg="grey95")

  # Plot wind speed 1-hour ahead forecast
  plot(data$Ws1 ~ data$t, ylab="wind speed", xlab="", type="n")
  abline(v=gridSeq, col="grey92")
  lines(data$Ws1 ~ data$t)
  
  # Plot temperature 1-hour ahead forecast
  plot(data$T1 ~ data$t, ylab="temperature", xlab="", type="n")
  abline(v=gridSeq, col="grey92")
  lines(data$T1 ~ data$t)
  
  # Plot wind direction 1-hour ahead forecast
  plot(data$Wd1 ~ data$t, ylab="wind direction", xlab="", type="n")
  abline(v=gridSeq, col="grey92")
  lines(data$Wd1 ~ data$t)
  
  cat ("Root-Mean-Square Error (RMSE) is:", round(rmse(p1Hat$pHat,data$p),3), "\n")
}


