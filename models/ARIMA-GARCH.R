library(rugarch)
library(progress) # tqdm loop
library(tseries)
library(forecast)
library(data.table) # shift


startDate <- "2000-01-01"
dataTest <- data[data$t > startDate,]
endDate <- "2000-12-30"
dataTest <- dataTest[dataTest$t < endDate,]

################################################################################
## ARMA(1,1)-GARCH(1,1)
################################################################################

model_spec <- ugarchspec(
  variance.model = list(model = "sGARCH", garchOrder = c(1, 1)),
  mean.model = list(armaOrder = c(1, 1, 1), include.mean = TRUE), 
  distribution.model = "norm"
)

rolling_forecast <- ugarchroll(
  spec = model_spec,
  data = dataTest$p,
  n.ahead = 1,
  forecast.length = 100,
  n.start = NULL,
  refit.every = 1,
  #refit.window = c("recursive"),
  window.size = NULL,
  solver = "hybrid",
  fit.control = list(),
  solver.control = list(),
  calculate.VaR = FALSE,  
  cluster = NULL,
  keep.coef = TRUE
)


# Afficher les résultats
print(rolling_forecast)
rolling_df <- as.data.frame(rolling_forecast)
conf_level <- 0.95
rolling_df$upperBound <- rolling_df$Mu + qnorm((1 + conf_level) / 2) * rolling_df$Sigma
rolling_df$lowerBound <- rolling_df$Mu - qnorm((1 + conf_level) / 2) * rolling_df$Sigma

range <- 1:length(rolling_df$Mu)

x11()
plot(rolling_df$Mu ~ range, ylab="power", xlab='date',type='n')
polygon(c(range, rev(range)), c(rolling_df$upperBound, rev(rolling_df$lowerBound)), col='gray', border=NA)
lines(rolling_df$Mu ~ range)
lines(shift(rolling_df$Realized) ~ range,col='red')
legend("topright", legend=c("Measured", "1-hour ahead forecast", "95% Confidence Interval"),
       col=c("black", "red", "gray"), lty=1:1, cex=0.8)
################################################################################
## ARIMA(1,1,1)-GARCH(1,1)
################################################################################
# Différenciation de la série temporelle pour ARIMA(1,1,1)
differenced_data <- diff(dataTest$p, lag = 1)

# Spécification du modèle ARIMA(1,1,1)-GARCH(1,1)
model_spec <- ugarchspec(
  variance.model = list(model = "sGARCH", garchOrder = c(1, 1)),
  mean.model = list(armaOrder = c(1, 1, 1), include.mean = TRUE),
  distribution.model = "norm"
)

# Rolling windows forecast avec la série temporelle différenciée
rolling_forecast <- ugarchroll(
  spec = model_spec,
  data = differenced_data,
  n.ahead = 1,
  forecast.length = 100,
  n.start = NULL,
  refit.every = 1,
  window.size = NULL,
  solver = "hybrid",
  fit.control = list(),
  solver.control = list(),
  calculate.VaR = FALSE,
  cluster = NULL,
  keep.coef = TRUE
)

rolling_df <- as.data.frame(rolling_forecast)

true_data <- tail(dataTest$p,100)
rolling_df$Realized <- cumsum(c(true_data[1], differenced_data[index:length_total]))
rolling_df$Mu <- cumsum(c(true_data[1], differenced_data[index:length_total]))

conf_level <- 0.95
upperBound <- rolling_df$Mu + qnorm((1 + conf_level) / 2) * rolling_df$Sigma
lowerBound <- rolling_df$Mu - qnorm((1 + conf_level) / 2) * rolling_df$Sigma
lowerBound <- sapply(lowerBound, function(x) pmax(x, 0))
rolling_df$Mu <- sapply(rolling_df$M, function(x) pmax(x, 0))

# Plot
range <- 1:length(rolling_df$Mu)

x11()
plot(rolling_df$Mu ~ range, ylab="power", xlab='date',type='n')
polygon(c(range, rev(range)), c(upperBound, rev(lowerBound)), col='gray', border=NA)
lines(rolling_df$Mu ~ range)
lines(shift(true_data,-1) ~ range,col='red')
legend("topright", legend=c("Measured", "1-hour ahead forecast", "95% Confidence Interval"),
       col=c("black", "red", "gray"), lty=1:1, cex=0.8)

dataframe <- data.frame(
  t = tail(dataTest$t,100),
  p = tail(dataTest$p,100),
  Forecast = rolling_df$Mu,
  UpperBound = upperBound,
  LowerBound = lowerBound
)
write.csv(dataframe, file = "ARIMA(1,1,1)-GARCH(1,1).csv", row.names = FALSE)


