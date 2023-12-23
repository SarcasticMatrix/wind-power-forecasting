library(npreg)
library(tidyverse)

################################################################################
################################################################################
################################################################################
# FIT A POWER CURVE
fitPowerCurve <- function(data, printBoolean = FALSE){
  # Input   : dataframe avec les colonnes $Ws1 et $p
  # Output  : model qui smooth la power curve
  
  cat ("Beginning the fitting of the power curve ... \n")
  
  .data <- data.frame(s=data$Ws3,p=data$p)
  .data <- .data[order(.data$s), ]
  .data <- na.omit(.data)
  
  idx <- .data$s < 4
  median_by_s <- aggregate(.data$p[! idx], by = list(.data$s[! idx]), FUN = median)
  mean_by_s <- aggregate(.data$p[idx], by = list(.data$s[idx]), FUN = min)
  
  .dataAverage <- rbind(mean_by_s,median_by_s)
  
  mod.ss <- ss(.dataAverage$Group.1, .dataAverage$x, nknots = 10)
  mod.smsp <- smooth.spline(.dataAverage$Group.1, .dataAverage$x, spar = 0.8)
  
  idx <- mod.ss$x >= 20
  mod.ss$y[idx] <- tail(mod.ss$y[! idx],1) 

  max01 <- function(x) max(x,0.1)
  mod.ss$y <- sapply(mod.ss$y,max01)
  mod.ss <- ss(mod.ss$x, mod.ss$y, nknots = 20)

  if(printBoolean){
    plot(data$p ~ data$Ws1, col = 'gray', xlab = "Wind speed", ylab = "Average wind power")
    
    windSpeed <- data[order(data$Ws1),]$Ws1
    
    # Ajouter les valeurs ajustées du modèle
    fitted_values <- predict.ss(mod.ss, x = windSpeed)$y

    lines(fitted_values ~ windSpeed, col = 'blue')

    legend("bottomright", c("ss"), lty = c(1, 2), col = c('blue'), bg = "grey95")
    
    title(main = "Power curve splines smoothing for 3-hour ahead forecast")
  }
  
  return(mod.ss)
}
################################################################################
################################################################################
################################################################################
plotPowerCurves <- function(data){
  
  par(mfrow=c(1, 3))
  plot(data$p ~ data$Ws1, main="1-hour ahead forecasted") 
  plot(data$p ~ data$Ws2, main="2-hour ahead forecasted")
  plot(data$p ~ data$Ws3, main="3-hour ahead forecasted")
}

plotPowerCurve <- function(data, Ws, hourAhead) {
  
  title <- paste(hourAhead,"- hour ahead forecasted Power Curves")
  xlab <- paste("Wind Speed",hourAhead,"- hour ahead (Ws)")
  plot(data$p ~ Ws, main = title, pch="+", 
       xlab = xlab, ylab = "Power Output (p)")
  legend("topright", legend = c("Power Output"), col = "black", pch = "+")
}

################################################################################
################################################################################
################################################################################
predictPowerCurve <- function(powerCurve,x){
  # Input   : vecteur/double x et la powerCurve fitted
  # Output  : dataframe avec les colonnes x y se (erreur)
  #     x     y           se
  # 1   4     0.1549109   0.003117653
  prediction <- predict.ss(powerCurve,x)
  
  return(prediction %>% rename(pHat  = y,Ws = x,standardErrors = se))
}


