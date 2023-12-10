library(lubridate)
library(patchwork)

setwd("C:/Users/utilisateur/Documents/DTU/Première Année 2023-2024/Cours/Advanced Time Series Analysis/Computer Exercise 4/windPowerForecasting")

source('plotting.R')
source('powerCurve.R')
source('ARIMA.R')

#source('logisticSDE-model.R')

############################################################
# Data simulation
############################################################

data <- read.csv('data/cex4WindDataInterpolated.csv')
data$t <- as.POSIXct(data$t, tz="UTC")

data$year <- format(data$t,"%Y")

################################################################################
# Model creation and estimation
################################################################################
dataTest <- data[data$t < "1999-10-01",]

# Forecasting with Power Curve
powerCurve <- fitPowerCurve(dataTest)
p1Hat_PC <- predictPowerCurve(powerCurve,dataTest$Ws1)
p1Hat_PC$residuals <- p1Hat_PC$pHat - dataTest$p
p1Hat_PC$t <- dataTest$t

# Forecasting with ARIMA(1,1,1)
p1Hat_ARIMA <- forecast1H_ARIMA(dataTest)

data_range <- 1:300
x11()
plot(dataTest$p[data_range] ~ dataTest$t[data_range], main='1-hour ahead forecasts', ylab="power", xlab='date',type='n')
polygon(c(p1Hat_ARIMA$t[data_range], rev(p1Hat_ARIMA$t[data_range])), c(p1Hat_ARIMA$upperBound[data_range], rev(p1Hat_ARIMA$lowerBound[data_range])), col='gray', border=NA)
lines(dataTest$p[data_range] ~ dataTest$t[data_range])
lines(p1Hat_PC$pHat[data_range] ~ p1Hat_PC$t[data_range], col='blue')
lines(p1Hat_ARIMA$pHat[data_range] ~ p1Hat_ARIMA$t[data_range], col='red')
legend("topright", legend=c("Measured", "Power Curve", "ARIMA(1,1,1)"),
       col=c("black", "blue", "red"), lty=1:1, cex=0.8)


data_range <- 1:300
x11()
plot(dataTest$p[data_range] ~ dataTest$t[data_range], main='1-hour ahead forecasts', ylab="power", xlab='date',type='n')
# Interval de confiance
conf_level <- 0.05
N <- length(dataTest$t)
upperBound <- p1Hat_PC$pHat[data_range] + N *qnorm((1 + conf_level) / 2) * p1Hat_PC$standardErrors[data_range]
lowerBound <- p1Hat_PC$pHat[data_range] - N * qnorm((1 + conf_level) / 2) * p1Hat_PC$standardErrors[data_range]
polygon(c(p1Hat_PC$t[data_range], rev(p1Hat_PC$t[data_range])), c(upperBound, rev(lowerBound)), col='gray', border=NA)
lines(dataTest$p[data_range] ~ dataTest$t[data_range])
lines(p1Hat_PC$pHat[data_range] ~ p1Hat_PC$t[data_range], col='blue')
legend("topright", legend=c("Measured", "Power Curve Forecast"),
       col=c("black", "blue"), lty=1:1, cex=0.8)



