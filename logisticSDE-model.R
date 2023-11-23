library(ctsmrTMB)
library(patchwork)

fitLogisticSDE <- function(dataFrame) {
  
  # Create data
  .data = data.frame(
    t = dataFrame$toy,
    y = dataFrame$p
  )
  
  # Create model object
  obj = ctsmrTMB$new()
  
  # Set name of model (and the created .cpp file)
  obj$set_modelname("logisticSDE")
  
  # Set path where generated C++ files are saved.
  # This will create a cppfiles folder in your current working directory if it doesnt exist
  obj$set_cppfile_directory("cppfiles")
  
  # Add system equations
  obj$add_systems(
    dx ~ theta * (mu-x) * dt + sigma*x*(1-x)*dw
  )
  
  # Add observation equations
  obj$add_observations(
    y ~ x
  )
  
  # Set observation equation variances
  obj$add_observation_variances(
    y ~ sigma_y^2
  )
  
  # Specify algebraic relations
  obj$add_algebraics(
    theta   ~ exp(logtheta),
    sigma   ~ exp(logsigma),
    sigma_y ~ exp(logsigma_y)
  )
  
  # Specify parameter initial values and lower/upper bounds in estimation
  obj$add_parameters(
    logtheta    = log(c(init = 1, lower=1e-5, upper=50)),
    mu          = c(init=1.5, lower=0, upper=5),
    logsigma  = log(c(init= 1e-1, lower=1e-10, upper=10)),
    logsigma_y  = log(c(init=1e-1, lower=1e-10, upper=10))
  )
  
  # Set initial state mean and covariance
  obj$set_initial_state(dataFrame$p[1], 1e-1*diag(1))
  
  fit <- obj$estimate(data=.data, method="ekf", ode.solver="rk4", use.hessian=TRUE)
  
  return(fit)
}