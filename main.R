library(lubridate)
library(patchwork)

source('plotting.R')
source('powerCurve.R')
source('logisticSDE-model.R')

############################################################
# Data simulation
############################################################

setwd("C:/Users/utilisateur/Documents/DTU/Première Année 2023-2024/Cours/Advanced Time Series Analysis/Computer Exercise 4/windPowerForecasting")

data <- read.csv('data/cex4WindDataInterpolated.csv')
data$t <- as.POSIXct(data$t, tz="UTC")

data$year <- format(data$t,"%Y")
data1999 <- data[data$year== 2002,]

plotPowerCurve(data,2002)

############################################################
# Model creation and estimation
############################################################

fit <- fitLogisticSDE(data1999)
print(summary(fit))

plotResiduals(fit$residuals)

data$year <- format(data$t,"%Y")
data2000 <- data[data$year== 2000,]
.data <- data.frame(
  t = data2000$toy,
  y = data2000$p
)
pred = obj$predict(.data,k.ahead=1)
aheadOneHour <- pred$y.predict[pred$k.ahead == 1] 

T <- length(data2000$p)
plot(data2000$p[2:T] ~ data2000$toy[2:T],col='red')
lines(aheadOneHour ~ data2000$toy[2:T])
