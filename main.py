# from models.ARIMAModel import *
# run_ARIMAModel()



#################################################################################
### FORECAST : ARMA(1,1)-GARCH(1,1) Model
#################################################################################
import pandas as pd

df = pd.read_csv('models/ARMA(1,1)-GARCH(1,1).csv')
import matplotlib.pyplot as plt 

dates = pd.to_datetime(df["t"])[1:-1]
p = df['p'].values[:-2] 
fittedValues = df['Forecast'].values[1:-1] 
fittedResiduals = p - fittedValues

UpperBound = df['UpperBound'][2:]  
LowerBound = df['LowerBound'][2:]  

# Utilisez plt.subplots avec gridspec_kw pour définir les hauteurs relatives des sous-figures
fig, axs = plt.subplots(
    2, 1, figsize=(10, 6), gridspec_kw={"height_ratios": [3, 1]}
)

# Sous-figure 1
axs[0].fill_between(
    dates + pd.Timedelta(hours=1),
    UpperBound,
    LowerBound,
    color="blue",
    alpha=0.2,
    label="95% Confidence Interval",
)
axs[0].plot(dates, p, linewidth=0.7, label="Measured power", color="blue")
axs[0].plot(
    dates, fittedValues, linewidth=0.7, label="Fitted Values", color="red"
)
axs[0].set_title("ARMA(1,1)-GARCH(1,1) 1-hour ahead forecast versus measured power")
axs[0].set_ylabel("Wind Power")
axs[0].legend()

# Ajouter des grilles verticales chaque jour
for day in pd.date_range(start=dates.min(), end=dates.max(), freq="D"):
    axs[0].axvline(day, linestyle="--", color="gray", linewidth=0.5)

# Sous-figure 2 (résidus)
axs[1].plot(
    dates, fittedResiduals, linewidth=0.5, label="Residuals", color="black"
)
axs[1].set_xlabel("Time")
axs[1].set_ylabel("Residuals")

# Ajouter des grilles verticales chaque jour
for day in pd.date_range(start=dates.min(), end=dates.max(), freq="D"):
    axs[1].axvline(day, linestyle="--", color="gray", linewidth=0.5)

# Ajuster l'espace entre les sous-figures
plt.tight_layout()

# Ajouter une légende commune au niveau de l'axe x
plt.legend(
    loc="upper left",
    bbox_to_anchor=(0, -0.2),
    fancybox=True,
    shadow=True,
    ncol=2,
)

plt.show()

from models.functions import *
compute_metrics(p, fittedValues, name_forecast='ARMA(1,1)-GARCH(1,1)')

#################################################################################
### FITTING : ARIMA(1,1,1)-GARCH(1,1) Model
#################################################################################
import pandas as pd

df = pd.read_csv('models/fit-ARIMA(1,1,1)-GARCH(1,1).csv')
import matplotlib.pyplot as plt 

dates = pd.to_datetime(df["t"])[1:-1]
p = df['p'].values[:-2] 
fittedValues = df['fittedValue'].values[1:-1] 
fittedResiduals = p - fittedValues

UpperBound = df['UpperBound'][2:]  
LowerBound = df['LowerBound'][2:]  

fig, axs = plt.subplots(
    2, 1, figsize=(10, 6), gridspec_kw={"height_ratios": [3, 1]}
)

# Sous-figure 1
axs[0].fill_between(
    dates + pd.Timedelta(hours=1),
    UpperBound,
    LowerBound,
    color="blue",
    alpha=0.2,
    label="95% Confidence Interval",
)
axs[0].plot(dates, p, linewidth=0.7, label="Measured power", color="blue")
axs[0].plot(
    dates, fittedValues, linewidth=0.7, label="Fitted Values", color="red"
)
axs[0].set_title("ARIMA(1,1,1)-GARCH(1,1) fitting versus measured power")
axs[0].set_ylabel("Wind Power")
axs[0].legend()

# Ajouter des grilles verticales chaque jour
for day in pd.date_range(start=dates.min(), end=dates.max(), freq="D"):
    axs[0].axvline(day, linestyle="--", color="gray", linewidth=0.5)

# Sous-figure 2 (résidus)
axs[1].plot(
    dates, fittedResiduals, linewidth=0.5, label="Residuals", color="black"
)
axs[1].set_xlabel("Time")
axs[1].set_ylabel("Residuals")

# Ajouter des grilles verticales chaque jour
for day in pd.date_range(start=dates.min(), end=dates.max(), freq="D"):
    axs[1].axvline(day, linestyle="--", color="gray", linewidth=0.5)

# Ajuster l'espace entre les sous-figures
plt.tight_layout()

# Ajouter une légende commune au niveau de l'axe x
plt.legend(
    loc="upper left",
    bbox_to_anchor=(0, -0.2),
    fancybox=True,
    shadow=True,
    ncol=2,
)

plt.show()

from models.functions import *
compute_metrics(p, fittedValues, name_forecast='fit ARIMA(1,1)-GARCH(1,1)')

# #################################################################################
# ### FORECASTS : ARIMA(1,1,1)-GARCH(1,1) Model
# #################################################################################
import pandas as pd

df = pd.read_csv('models/ARIMA(1,1,1)-GARCH(1,1).csv')
import matplotlib.pyplot as plt 

dates = pd.to_datetime(df["t"])[1:]
p = df['p'].values[1:]
fittedValues = df['Forecast'].values[:-1] 
fittedResiduals = p - fittedValues

UpperBound = df['UpperBound'][1:]
LowerBound = df['LowerBound'][1:]

# Utilisez plt.subplots avec gridspec_kw pour définir les hauteurs relatives des sous-figures
fig, axs = plt.subplots(
    2, 1, figsize=(10, 6), gridspec_kw={"height_ratios": [3, 1]}
)

# Sous-figure 1
axs[0].fill_between(
    dates + pd.Timedelta(hours=1),
    UpperBound,
    LowerBound,
    color="blue",
    alpha=0.2,
    label="95% Confidence Interval",
)
axs[0].plot(dates, p, linewidth=0.7, label="Measured power", color="blue")
axs[0].plot(
    dates, fittedValues, linewidth=0.7, label="Fitted Values", color="red"
)
axs[0].set_title("ARIMA(1,1,1)-GARCH(1,1) 1-hour ahead forecast versus measured power")
axs[0].set_ylabel("Wind Power")
axs[0].legend()

# Ajouter des grilles verticales chaque jour
for day in pd.date_range(start=dates.min(), end=dates.max(), freq="D"):
    axs[0].axvline(day, linestyle="--", color="gray", linewidth=0.5)

# Sous-figure 2 (résidus)
axs[1].plot(
    dates, fittedResiduals, linewidth=0.5, label="Residuals", color="black"
)
axs[1].set_xlabel("Time")
axs[1].set_ylabel("Residuals")

# Ajouter des grilles verticales chaque jour
for day in pd.date_range(start=dates.min(), end=dates.max(), freq="D"):
    axs[1].axvline(day, linestyle="--", color="gray", linewidth=0.5)

# Ajuster l'espace entre les sous-figures
plt.tight_layout()

# Ajouter une légende commune au niveau de l'axe x
plt.legend(
    loc="upper left",
    bbox_to_anchor=(0, -0.2),
    fancybox=True,
    shadow=True,
    ncol=2,
)

plt.show()

from models.functions import *
compute_metrics(p, fittedValues, name_forecast='ARIMA(1,1)-GARCH(1,1)')