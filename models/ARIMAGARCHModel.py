from models.Model import Model
from models.functions import *

from typing import Optional
from tqdm import tqdm

import pandas as pd
from statsmodels.tsa.arima.model import ARIMA
import arch

import pandas as pd
from datetime import datetime
import matplotlib.pyplot as plt
import numpy as np

import warnings
warnings.filterwarnings("ignore")


class ARIMAGARCHModel(Model):
    def __init__(self):
        super().__init__(model_name="ARIMA(1,1,1)-GARCH(1,1)")

    def fit(self, print_summary: Optional[bool] = False):

        if not hasattr(self, "data"):
            self.get_data()

        self.get_data(
            self.first_date, self.last_date + pd.Timedelta(hours=1), self.path
        )

        p = self.data["p"]

        # Fit ARIMA(1,1,1)
        model = ARIMA(p, order=(1, 1, 1))
        self.model = model.fit()

        if print_summary:
            print(self.model.summary())
            print(self.model.resid.describe())

        df2 = pd.DataFrame({"fittedvalues": self.model.fittedvalues.values})
        df_estimation = pd.DataFrame(
            {
                "t": self.data["t"].values,
                "fittedValues": df2["fittedvalues"].shift(periods=-1),
            }
        )

        self.data = pd.merge(self.data, df_estimation, on="t", how="outer")
        self.data["fittedResiduals"] = self.data["p"] - self.data["fittedValues"]

        self.data.drop(self.data.tail(1).index, inplace=True)

        # Fit GARCH(1,1)
        garch = arch.arch_model(self.data["fittedResiduals"].dropna(), p=1, q=1)
        self.garch = garch.fit(disp="off")

        self.data["fittedResiduals-GARCH"] = self.garch.resid

        if print_summary:
            print(self.garch.summary())

    def forecast(self, steps: Optional[int] = 1, alpha=0.05):

        if self.model is not None:

            # ARIMA(1,1,1) forecast
            forecast_result = self.model.get_forecast(steps=steps, alpha=alpha)
            arima_forecast = forecast_result.predicted_mean.iloc[-1]

            conf_int = forecast_result.conf_int(alpha=alpha)
            lower = conf_int["lower p"].iloc[-1]
            upper = conf_int["upper p"].iloc[-1]

            # GARCH(1,1) forecast
            garch_forecast = self.garch.forecast(horizon=steps).mean[f"h.{steps}"].iloc[-1]
            res = {
                "value ARIMA": arima_forecast,
                "value GARCH": garch_forecast,
                "confidence interval": {"lower p": lower, "upper p": upper},
            }

            return res
        else:
            print(
                "The ARIMA model has not been adjusted. Please adjust the model first."
            )


def run_ARIMAGARCHModel(
    fitting_start_date: Optional[datetime] = datetime(
        year=1999, month=1, day=1, hour=3
    ),
    forecasts_start_date: Optional[datetime] = datetime(year=2000, month=1, day=1),
    time_of_forecasting: Optional[pd.Timedelta] = pd.Timedelta(weeks=1),
):

    print("Let's run the ARIMA(1,1,1)-GARCH(1,1) forecast !")

    ###########################################################################
    ## Check the whole model
    ###########################################################################
    print("Checking the model on the whole dataset...")
    myModel = ARIMAGARCHModel()
    myModel.fit(print_summary=True)
    myModel.export_residuals()

    ###########################################################################
    ## FORECASTS
    ###########################################################################
    print(
        f"We start to forecast between {forecasts_start_date} and {forecasts_start_date + time_of_forecasting} ..."
    )

    temp = pd.read_csv("./data/cex4WindDataInterpolated.csv")
    temp["t"] = pd.to_datetime(temp["t"])

    mask = (temp["t"] > "2000") & (
        temp["t"] < forecasts_start_date + time_of_forecasting
    )
    dates = temp.loc[mask, "t"]

    list_1hourAhead_ARIMAforecastValues = []
    list_1hourAhead_GARCHforecastValues = []
    list_1hourAhead_forecastUpper = []
    list_1hourAhead_forecastLower = []

    list_2hourAhead_ARIMAforecastValues = []
    list_2hourAhead_GARCHforecastValues = []
    list_2hourAhead_forecastUpper = []
    list_2hourAhead_forecastLower = []

    list_3hourAhead_ARIMAforecastValues = []
    list_3hourAhead_GARCHforecastValues = []
    list_3hourAhead_forecastUpper = []
    list_3hourAhead_forecastLower = []

    for date in dates:

        #############################################################################
        ## INITIALISATION OF THE ARIMA(1,1,1)-GARCH(1,1)
        #############################################################################
        myModel = ARIMAGARCHModel()
        myModel.get_data(first_date=fitting_start_date, last_date=date)

        myModel.fit(print_summary=False)

        # Forecast 1-hour ahead
        res = myModel.forecast(steps=1, alpha=0.05)

        ARIMAforecast_values = res["value ARIMA"]
        GARCHforecast_values = res["value GARCH"]
        confidence_interval = res["confidence interval"]

        list_1hourAhead_ARIMAforecastValues.append(ARIMAforecast_values)
        list_1hourAhead_GARCHforecastValues.append(GARCHforecast_values)
        list_1hourAhead_forecastLower.append(confidence_interval["lower p"])
        list_1hourAhead_forecastUpper.append(confidence_interval["upper p"])

        # Forecast 2-hour ahead
        res = myModel.forecast(steps=2, alpha=0.05)

        ARIMAforecast_values = res["value ARIMA"]
        GARCHforecast_values = res["value GARCH"]
        confidence_interval = res["confidence interval"]

        list_2hourAhead_ARIMAforecastValues.append(ARIMAforecast_values)
        list_2hourAhead_GARCHforecastValues.append(GARCHforecast_values)
        list_2hourAhead_forecastLower.append(confidence_interval["lower p"])
        list_2hourAhead_forecastUpper.append(confidence_interval["upper p"])

        # Forecast 3-hour ahead
        res = myModel.forecast(steps=3, alpha=0.05)

        ARIMAforecast_values = res["value ARIMA"]
        GARCHforecast_values = res["value GARCH"]
        confidence_interval = res["confidence interval"]

        list_3hourAhead_ARIMAforecastValues.append(ARIMAforecast_values)
        list_3hourAhead_GARCHforecastValues.append(GARCHforecast_values)
        list_3hourAhead_forecastLower.append(confidence_interval["lower p"])
        list_3hourAhead_forecastUpper.append(confidence_interval["upper p"])

    print("Forecasts are done")

    ARIMAforecastValues_1hourAhead = np.array(list_1hourAhead_ARIMAforecastValues).flatten()
    GARCHforecastValues_1hourAhead = np.array(list_1hourAhead_GARCHforecastValues).flatten()
    forecastValues_1hourAhead = ARIMAforecastValues_1hourAhead + GARCHforecastValues_1hourAhead
    forecastUpper_1hourAhead = np.array(list_1hourAhead_forecastUpper).flatten()
    forecastLower_1hourAhead = np.array(list_1hourAhead_forecastLower).flatten()

    ARIMAforecastValues_2hourAhead = np.array(list_2hourAhead_ARIMAforecastValues).flatten()
    GARCHforecastValues_2hourAhead = np.array(list_2hourAhead_GARCHforecastValues).flatten()
    forecastValues_2hourAhead = ARIMAforecastValues_2hourAhead + GARCHforecastValues_2hourAhead
    forecastUpper_2hourAhead = np.array(list_2hourAhead_forecastUpper).flatten()
    forecastLower_2hourAhead = np.array(list_2hourAhead_forecastLower).flatten()

    ARIMAforecastValues_3hourAhead = np.array(list_3hourAhead_ARIMAforecastValues).flatten()
    GARCHforecastValues_3hourAhead = np.array(list_3hourAhead_GARCHforecastValues).flatten()
    forecastValues_3hourAhead = ARIMAforecastValues_3hourAhead + GARCHforecastValues_3hourAhead
    forecastUpper_3hourAhead = np.array(list_3hourAhead_forecastUpper).flatten()
    forecastLower_3hourAhead = np.array(list_3hourAhead_forecastLower).flatten()

    ###########################################################################
    ## SOME PLOTS
    ###########################################################################

    # 1-hour ahead Forecast
    plt.figure(figsize=(20, 10))
    plt.plot(
        dates + pd.Timedelta(hours=1),
        forecastValues_1hourAhead,
        label="Forecast Values",
        color="blue",
    )
    plt.fill_between(
        dates + pd.Timedelta(hours=1),
        forecastLower_1hourAhead,
        forecastUpper_1hourAhead,
        color="blue",
        alpha=0.2,
        label="95% Confidence Interval",
    )
    plt.plot(dates, temp.loc[mask, "p"], label="True Values", color="red")
    plt.title(
        "ARIMA(1,1,1)-GARCH(1,1) 1-hour ahead forecast with 95% Confidence Interval"
    )
    plt.xlabel("Time")
    plt.ylabel("Wind Power")
    plt.legend()
    plt.show()

    # 2-hour ahead Forecast
    plt.figure(figsize=(20, 10))
    plt.plot(
        dates + pd.Timedelta(hours=1),
        forecastValues_2hourAhead,
        label="Forecast Values",
        color="blue",
    )
    plt.fill_between(
        dates + pd.Timedelta(hours=1),
        forecastLower_2hourAhead,
        forecastUpper_2hourAhead,
        color="blue",
        alpha=0.2,
        label="95% Confidence Interval",
    )
    plt.plot(dates, temp.loc[mask, "p"], label="True Values", color="red")
    plt.title(
        "ARIMA(1,1,1)-GARCH(1,1) 2-hour ahead forecast with 95% Confidence Interval"
    )
    plt.xlabel("Time")
    plt.ylabel("Wind Power")
    plt.legend()
    plt.show()

    # 3-hour ahead Forecast
    plt.figure(figsize=(20, 10))
    plt.plot(
        dates + pd.Timedelta(hours=1),
        forecastValues_3hourAhead,
        label="Forecast Values",
        color="blue",
    )
    plt.fill_between(
        dates + pd.Timedelta(hours=1),
        forecastLower_3hourAhead,
        forecastUpper_3hourAhead,
        color="blue",
        alpha=0.2,
        label="95% Confidence Interval",
    )
    plt.plot(dates, temp.loc[mask, "p"], label="True Values", color="red")
    plt.title(
        "ARIMA(1,1,1)-GARCH(1,1) 3-hour ahead forecast with 95% Confidence Interval"
    )
    plt.xlabel("Time")
    plt.ylabel("Wind Power")
    plt.legend()
    plt.show()

    ###########################################################################
    ## SOME OTHERS PLOTS
    ###########################################################################

    # 1-hour ahead Forecast and residuals
    fig, axs = plt.subplots(
        2, 1, figsize=(20, 10), gridspec_kw={"height_ratios": [3, 1]}
    )

    axs[0].plot(
        dates, temp.loc[mask, "p"], linewidth=0.7, label="Measured power", color="blue"
    )
    axs[0].plot(
        dates + pd.Timedelta(hours=1),
        forecastValues_1hourAhead,
        linewidth=0.7,
        label="Forecast",
        color="red",
    )
    axs[0].fill_between(
        dates + pd.Timedelta(hours=1),
        forecastLower_1hourAhead,
        forecastUpper_1hourAhead,
        color="blue",
        alpha=0.2,
        label="95% Confidence Interval",
    )
    axs[0].set_title(
        "ARIMA(1,1,1)-GARCH(1,1) 1-hour ahead forecast versus measured power"
    )
    axs[0].set_ylabel("Wind Power")
    axs[0].legend()
    for day in pd.date_range(start=dates.min(), end=dates.max(), freq="D"):
        axs[0].axvline(day, linestyle="--", color="gray", linewidth=0.5)

    residual_dates = dates + pd.Timedelta(hours=1)
    axs[1].plot(
        residual_dates[1:],
        temp.loc[mask, "p"].values[1:] - forecastValues_1hourAhead[:-1],
        linewidth=0.5,
        label="Residuals",
        color="black",
    )
    axs[1].plot(
        residual_dates[1:],
        GARCHforecastValues_1hourAhead[:-1],
        linewidth=0.5,
        label="GARCH(1,1) 1-hour ahead forecast",
        color="blue",
    )
    axs[1].set_xlabel("Time")
    axs[1].set_ylabel("Residuals")
    for day in pd.date_range(start=dates.min(), end=dates.max(), freq="D"):
        axs[1].axvline(day, linestyle="--", color="gray", linewidth=0.5)

    plt.tight_layout()
    plt.legend(
        loc="upper left", bbox_to_anchor=(0, -0.2), fancybox=True, shadow=True, ncol=2
    )
    plt.show()

    # 2-hour ahead Forecast and residuals
    fig, axs = plt.subplots(
        2, 1, figsize=(20, 10), gridspec_kw={"height_ratios": [3, 1]}
    )

    axs[0].plot(
        dates, temp.loc[mask, "p"], linewidth=0.7, label="Measured power", color="blue"
    )
    axs[0].plot(
        dates + pd.Timedelta(hours=1),
        forecastValues_2hourAhead,
        linewidth=0.7,
        label="Forecast",
        color="red",
    )
    axs[0].fill_between(
        dates + pd.Timedelta(hours=1),
        forecastLower_2hourAhead,
        forecastUpper_2hourAhead,
        color="blue",
        alpha=0.2,
        label="95% Confidence Interval",
    )
    axs[0].set_title(
        "ARIMA(1,1,1)-GARCH(1,1) 2-hour ahead forecast versus measured power"
    )
    axs[0].set_ylabel("Wind Power")
    axs[0].legend()
    for day in pd.date_range(start=dates.min(), end=dates.max(), freq="D"):
        axs[0].axvline(day, linestyle="--", color="gray", linewidth=0.5)

    residual_dates = dates + pd.Timedelta(hours=1)
    axs[1].plot(
        residual_dates[1:],
        temp.loc[mask, "p"].values[1:] - forecastValues_2hourAhead[:-1],
        linewidth=0.5,
        label="Residuals",
        color="black",
    )
    axs[1].plot(
        residual_dates[1:],
        GARCHforecastValues_2hourAhead[:-1],
        linewidth=0.5,
        label="GARCH(1,1) 2-hour ahead forecast",
        color="blue",
    )
    axs[1].set_xlabel("Time")
    axs[1].set_ylabel("Residuals")
    for day in pd.date_range(start=dates.min(), end=dates.max(), freq="D"):
        axs[1].axvline(day, linestyle="--", color="gray", linewidth=0.5)

    plt.tight_layout()
    plt.legend(
        loc="upper left", bbox_to_anchor=(0, -0.2), fancybox=True, shadow=True, ncol=2
    )
    plt.show()

    # 3-hour ahead Forecast and residuals
    fig, axs = plt.subplots(
        2, 1, figsize=(20, 10), gridspec_kw={"height_ratios": [3, 1]}
    )

    axs[0].plot(
        dates, temp.loc[mask, "p"], linewidth=0.7, label="Measured power", color="blue"
    )
    axs[0].plot(
        dates + pd.Timedelta(hours=1),
        forecastValues_3hourAhead,
        linewidth=0.7,
        label="Forecast",
        color="red",
    )
    axs[0].fill_between(
        dates + pd.Timedelta(hours=1),
        forecastLower_3hourAhead,
        forecastUpper_3hourAhead,
        color="blue",
        alpha=0.2,
        label="95% Confidence Interval",
    )
    axs[0].set_title(
        "ARIMA(1,1,1)-GARCH(1,1) 3-hour ahead forecast versus measured power"
    )
    axs[0].set_ylabel("Wind Power")
    axs[0].legend()
    for day in pd.date_range(start=dates.min(), end=dates.max(), freq="D"):
        axs[0].axvline(day, linestyle="--", color="gray", linewidth=0.5)

    residual_dates = dates + pd.Timedelta(hours=1)
    axs[1].plot(
        residual_dates[1:],
        temp.loc[mask, "p"].values[1:] - forecastValues_3hourAhead[:-1],
        linewidth=0.5,
        label="Residuals",
        color="black",
    )
    axs[1].plot(
        residual_dates[1:],
        GARCHforecastValues_3hourAhead[:-1],
        linewidth=0.5,
        label="GARCH(1,1) 3-hour ahead forecast",
        color="blue",
    )
    axs[1].set_xlabel("Time")
    axs[1].set_ylabel("Residuals")
    for day in pd.date_range(start=dates.min(), end=dates.max(), freq="D"):
        axs[1].axvline(day, linestyle="--", color="gray", linewidth=0.5)

    plt.tight_layout()
    plt.legend(
        loc="upper left", bbox_to_anchor=(0, -0.2), fancybox=True, shadow=True, ncol=2
    )
    plt.show()

    ###########################################################################
    ## SOME OTHERS PLOTS
    ###########################################################################

    compute_metrics(
        temp.loc[mask, "p"].values[1:],
        forecastValues_1hourAhead[:-1],
        "ARIMA(1,1,1)-GARCH(1,1) 1-hour ahead",
    )
    compute_metrics(
        temp.loc[mask, "p"].values[1:],
        forecastValues_2hourAhead[:-1],
        "ARIMA(1,1,1)-GARCH(1,1) 2-hour ahead",
    )
    compute_metrics(
        temp.loc[mask, "p"].values[1:],
        forecastValues_3hourAhead[:-1],
        "ARIMA(1,1,1)-GARCH(1,1) 3-hour ahead",
    )
