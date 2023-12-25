library(dbplyr)

path <- "C:/Users/utilisateur/Documents/DTU/Première Année 2023-2024/Cours/Advanced Time Series Analysis/Computer Exercise 4/windPowerForecasting/residuals/"
file_name <- "residuals-ARIMA(1,1,1)-GARCH(1,1).csv"
residuals <- read.csv(paste(path,file_name,sep=""))$fittedResiduals

plotResiduals <- function(residuals) {
  
  residuals <- na.omit(residuals)
  
  x11()
  par(mfrow=c(2, 2))
  
  # Residuals ACF
  acf(residuals, lag.max=6*12, main="Residuals ACF")
  
  # Histogram of residuals
  hist(residuals, main="Histogram of Residuals", xlab="Residuals", probability=TRUE)
  lines(density(residuals), col="darkred", lwd=1.5)
  
  mean_resid <- mean(residuals)
  sd_resid <- sd(residuals)
  curve(dnorm(x, mean=mean_resid, sd=sd_resid), col="steelblue", lwd=1.5, add=TRUE)
  
  legend("topright", legend=c("Density of Residuals", "Normal Density"), col=c("darkred", "steelblue"), lty=1, lwd=2)
  
  
  # Raw periodogram
  spec.pgram(residuals, main="Raw periodogram")
  
  # Cumulated periodogram
  cpgram(residuals, main="Cumulated periodogram")
  
  
  x11()
  qqnorm(residuals, pch = 1, frame = FALSE)
  qqline(residuals, col = "steelblue", lwd = 2)
}

plotResiduals(residuals)


plot_residuals_analysis <- function(residuals) {
  
  ylim=c(0, 0.1)
  
  lower_limit <- min(residuals)
  upper_limit <- max(residuals)
  x11()
  par(mfrow=c(1, 2))
  
  # Plage spécifique [min(residus), -2.5]
  hist(residuals, main="Histogram of Residuals", xlab="Residuals", probability=TRUE, xlim=c(lower_limit, -0.5), ylim=ylim)
  lines(density(residuals), col="darkred", lwd=2)
  mean_resid <- mean(residuals)
  sd_resid <- sd(residuals)
  curve(dnorm(x, mean=mean_resid, sd=sd_resid), col="steelblue", lwd=2, add=TRUE)
  
  # Plage spécifique [2.5, max(residus)]
  hist(residuals, main="Histogram of Residuals", xlab="Residuals", probability=TRUE, xlim=c(0.5, upper_limit), ylim=ylim)
  lines(density(residuals), col="darkred", lwd=2)
  curve(dnorm(x, mean=mean_resid, sd=sd_resid), col="steelblue", lwd=2, add=TRUE)
  
  # Légende commune
  legend("topright", legend=c("Density of Residuals", "Normal Density"), col=c("darkred", "steelblue"), lty=1, lwd=2)
  
  # Titre commun
  suptitle <- "Tail analysis of residuals"
  mtext(suptitle, outer=TRUE, cex=1.5, font=2, line=1)
}

plot_residuals_analysis(residuals)

