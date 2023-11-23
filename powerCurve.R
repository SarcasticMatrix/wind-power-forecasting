library(WindCurves)
powerCurveSmoothing <- function(data){

  .data <- data.frame(s=data$Ws1,p=data$p)
  .data <- .data[order(.data$s), ]

  
  average_by_s <- aggregate(.data$p, by = list(.data$s), FUN = median)
  .data <- average_by_s
  x <- fitcurve(.data)
  
  print(validate.curve(x))
   
  return(x)
}

library(npreg)
fitPowerCurve <- function(data, printBoolean = FALSE){
  # Input   : dataframe avec les colonnes $Ws1 et $p
  # Output  : model qui smooth la power curve
  
  .data <- data.frame(s=data$Ws1,p=data$p)
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
    plot(data$p~data$Ws1,col='gray',xlab = "Wind speed", ylab = "Average wind power")
    #lines(mod.ss,col='red')
    #lines(mod.smsp,col='blue')
    
    windSpeed <- data[order(data$Ws1),]$Ws1
    lines(predict.ss(mod.ss,windSpeed)$y~windSpeed,col='blue')
    
    legend("bottomright", c("ss","smsp"), lty=1, col=1:2, bg="grey95")
    title(main = "Power curve splines smoothig")
  }
  
  return(mod.ss)
}

predictPowerCurve <- function(powerCurve,x){
  # Input   : vecteur/double x et la powerCurve fitted
  # Output  : dataframe avec les colonnes x y se (erreur)
  #     x     y           se
  # 1   4     0.1549109   0.003117653
  
  return(predict.ss(powerCurve,x))
}

# http://xn--drmstrre-64ad.dk/wp-content/wind/miller/windpower%20web/en/tour/wres/powdensi.htm
# library(fitdistrplus)
# library(actuar)
# 
# df.data <- data.frame(
#   p = data$p,
#   s = data$Ws1
# )
# df.data <- na.omit(df.data)
# wind_speeds <- df.data$s
# wind_speeds <- df.data$s
# 
# # Estimer les paramètres de la distribution de Weibull
# fit_weibull <- fitdist(wind_speeds, "weibull")
# 
# # Obtenir les paramètres estimés
# shape <- fit_weibull$estimate[1]
# scale <- fit_weibull$estimate[2]
# 
# # Fonction de densité de probabilité de la distribution de Weibull
# weibull_pdf <- function(x) {
#   dweibull(x, shape = shape, scale = scale)
# }
# 
# # Pondération des points en utilisant la distribution de Weibull
# weights <- weibull_pdf(wind_speeds)
# 
# # Normaliser les poids pour que la somme soit égale à 1
# weights <- weights / sum(weights)
# 
# # Ajouter les poids à votre dataframe
# df.data$weights <- weights
# 
# # Maintenant, vous pouvez utiliser ces poids dans votre ajustement de courbe de puissance
# # Supposons que votre fonction de puissance soit de la forme P = a * V^b
# # Vous pouvez ajuster les paramètres a et b en utilisant les poids
# df.data$pWeighted <- df.data$p * df.data$weights
# test <- aggregate(df.data$pWeighted, by = list(df.data$s), FUN = sum)
