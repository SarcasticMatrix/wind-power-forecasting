library(dbplyr)

path <- "C:/Users/utilisateur/Documents/DTU/Première Année 2023-2024/Cours/Advanced Time Series Analysis/Computer Exercise 4/windPowerForecasting/residuals/"
file_name <- "residuals-ARIMA.csv"
residuals <- read.csv(paste(path,file_name,sep=""))


plotResiduals <- function(residuals) {
  
  residuals <- na.omit(residuals)
  
  x11()
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
  qqnorm(residuals, pch = 1, frame = FALSE)
  qqline(residuals, col = "steelblue", lwd = 2)
}

plotResiduals(residuals$residuals)
