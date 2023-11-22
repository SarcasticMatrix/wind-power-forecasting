################################################################################
## PLOTTING FUNCTIONS
################################################################################
setwd("C:/Users/utilisateur/Documents/DTU/Première Année 2023-2024/Cours/Advanced Time Series Analysis/Computer Exercise 4")
library(dbplyr)
plotYear <- function(data,year){
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

plotForecast <- function() {
  
}

plotOneColumn <- function(nameOfTheColumn){
  

}