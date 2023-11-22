library(lubridate)

setwd("C:/Users/utilisateur/Documents/DTU/Première Année 2023-2024/Cours/Advanced Time Series Analysis/Computer Exercise 4")

data <- read.csv('data/cex4WindDataInterpolated.csv')
data$t <- as.POSIXct(data$t, tz="UTC")

plot(data$t, data$p, type='l')

