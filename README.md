# Motivation 

A large-scale introduction of wind power causes a number of challenges for electricity market and power system operators who will have to deal with the variability and uncertainty in wind power generation when making their scheduling and dispatch decisions. 

The objective of this exercise is to develop adaptive models for the prediction of wind power 1, 2, and 3 hours ahead of a wind farm. We have at our disposal the hourly averages of wind power measurements and weather forecasts (including 1-hour, 2-hour and 3-hour ahead temperature, wind speed and wind direction forecasts).

# The models

We shall first consider a multivariate model based on the estimation of a **power curve**. Second, we shall implement a straightforward **ARIMA(1,1,1)** model. Third, we shall explore considering a **ARIMA(1,1,1)-GARCH(1,1) model**, we will use a GARCH model for forecasting the residuals. 

# The process 

The analysis procedure shall remain consistent across ARIMA, ARMA-GARCH, and ARIMA-GARCH models. The models shall initially be fitted to the entire dataset spanning the year 1999. Subsequently, a rolling forecast approach shall be employed, fittingthe models on the preceding 1.5 years. It might be oversufficient and too heavy computationally.  

All the details are in the `Wind power forecasting - report.pdf`. The methods are implemented in `R` and `Python`