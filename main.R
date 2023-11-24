library(lubridate)
library(patchwork)

source('plotting.R')
source('powerCurve.R')

#source('logisticSDE-model.R')

############################################################
# Data simulation
############################################################

setwd("C:/Users/utilisateur/Documents/DTU/Première Année 2023-2024/Cours/Advanced Time Series Analysis/Computer Exercise 4/windPowerForecasting")

data <- read.csv('data/cex4WindDataInterpolated.csv')
data$t <- as.POSIXct(data$t, tz="UTC")

data$year <- format(data$t,"%Y")
data1999 <- data[data$year== 1999,]

################################################################################
# Model creation and estimation
################################################################################
dataTest <- data[data$t < "1999-10-01",]

powerCurve <- fitPowerCurve(dataTest)
p1Hat <- predictPowerCurve(powerCurve,dataTest$Ws1)
  
p1Hat$residuals <- p1Hat$pHat - dataTest$p



data_range <- 1:240

plot(dataTest$p[data_range] ~ dataTest$t[data_range], ylab="power", xlab='date',type='n')
# Interval de confiance
conf_level <- 0.05
N <- length(dataTest$t)
upperBound <- p1Hat$pHat[data_range] + N * qnorm((1 + conf_level) / 2) * p1Hat$standardErrors[data_range]
lowerBound <- p1Hat$pHat[data_range] - N * qnorm((1 + conf_level) / 2) * p1Hat$standardErrors[data_range]
polygon(c(dataTest$t[data_range], rev(dataTest$t[data_range])), c(upperBound, rev(lowerBound)), col='gray', border=NA)

lines(dataTest$p[data_range] ~ dataTest$t[data_range])
lines(p1Hat$pHat[data_range] ~ dataTest$t[data_range], col='red')
legend("topright", legend=c("Measured", "Predicted", "95% Confidence Interval"),
       col=c("black", "red", "gray"), lty=1:1, cex=0.8)



