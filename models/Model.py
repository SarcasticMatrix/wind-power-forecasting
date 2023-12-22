from typing import Optional

import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
from datetime import datetime


class Model:
    def __init__(self, model_name: Optional[str] = "Not defined"):

        self.model_name = model_name

    def get_data(
        self,
        first_date: Optional[datetime] = datetime(year=1999, month=1, day=1),
        last_date: Optional[datetime] = datetime(year=2003, month=4, day=1),
        path="./data/cex4WindDataInterpolated.csv",
    ):

        self.data = pd.read_csv(path)
        self.data["t"] = pd.to_datetime(self.data["t"])

        mask = (first_date <= self.data["t"]) & (self.data["t"] <= last_date)
        self.data = self.data.loc[
            mask,
        ]

        self.first_date = first_date
        self.last_date = last_date
        self.path = path

    def plot_data(self, year=1999):

        self.get_data(
            first_date=datetime(year=year, month=1, day=1),
            last_date=datetime(year=year, month=12, day=31),
        )

        self.data["year"] = self.data["t"].dt.strftime("%Y")
        dataYear = self.data[self.data["year"] == str(year)]

        if str(year) in dataYear["year"].unique():
            gridSeq = pd.date_range(start=min(dataYear["t"]), periods=12, freq="M")

            # Personnalisation des paramètres graphiques
            fig, axs = plt.subplots(
                4,
                1,
                figsize=(10, 10),
                gridspec_kw={"hspace": 0.5, "top": 0.9, "bottom": 0.1},
            )

            # Plot measured average wind power
            axs[0].plot(dataYear["t"], dataYear["p"], color="black", linewidth=0.7)
            axs[0].set_ylabel("measured wind power")
            axs[0].set_xticks([])
            for grid_value in gridSeq:
                axs[0].axvline(grid_value, linestyle="--", linewidth=0.7, color="gray")

            # Plot 1,2,3-hour ahead forecasted wind speed.
            axs[1].plot(
                dataYear["t"], dataYear["Ws1"], linewidth=0.7, label="1-hour ahead"
            )
            axs[1].plot(
                dataYear["t"], dataYear["Ws2"], linewidth=0.7, label="2-hour ahead"
            )
            axs[1].plot(
                dataYear["t"], dataYear["Ws3"], linewidth=0.7, label="3-hour ahead"
            )
            axs[1].set_ylabel("wind speed")
            axs[1].set_xticks([])
            for grid_value in gridSeq:
                axs[1].axvline(grid_value, linestyle="--", linewidth=0.5, color="gray")

            # Plot 1,2,3-hour ahead forecasted wind direction
            axs[2].plot(
                dataYear["t"], dataYear["Wd1"], linewidth=0.7, label="1-hour ahead"
            )
            axs[2].plot(
                dataYear["t"], dataYear["Wd2"], linewidth=0.7, label="2-hour ahead"
            )
            axs[2].plot(
                dataYear["t"], dataYear["Wd3"], linewidth=0.7, label="3-hour ahead"
            )
            axs[2].set_ylabel("wind direction")
            axs[2].set_xticks([])
            for grid_value in gridSeq:
                axs[2].axvline(grid_value, linestyle="--", linewidth=0.5, color="gray")

            # Plot 1,2,3-hour ahead forecasted temperature
            axs[3].plot(
                dataYear["t"], dataYear["T1"], linewidth=0.7, label="1-hour ahead"
            )
            axs[3].plot(
                dataYear["t"], dataYear["T2"], linewidth=0.7, label="2-hour ahead"
            )
            axs[3].plot(
                dataYear["t"], dataYear["T3"], linewidth=0.7, label="3-hour ahead"
            )
            axs[3].set_ylabel("temperature")
            for grid_value in gridSeq:
                axs[3].axvline(grid_value, linestyle="--", linewidth=0.5, color="gray")

            handles, labels = axs[3].get_legend_handles_labels()
            fig.legend(handles, labels, loc="upper right")

            fig.suptitle(f"Data over year {year}", fontsize=16, fontweight="bold")
            plt.show()
        else:
            print(f"The year {year} is not part of the dataset")

    def plot_model(
        self,
        nbr_hours: Optional[int] = 0,
        nbr_days: Optional[int] = 0,
        nbr_weeks: Optional[int] = 1,
    ):

        if hasattr(self, "model") and hasattr(self, "data"):

            mask = self.data["t"] < self.first_date + pd.Timedelta(
                hours=nbr_hours, days=nbr_days, weeks=nbr_weeks
            )

            dates = self.data.loc[mask, "t"]
            p = self.data.loc[mask, "p"]
            fittedValues = self.data.loc[mask, "fittedValues"]
            fittedResiduals = self.data.loc[mask, "fittedResiduals"]

            # Utilisez plt.subplots avec gridspec_kw pour définir les hauteurs relatives des sous-figures
            fig, axs = plt.subplots(
                2, 1, figsize=(10, 6), gridspec_kw={"height_ratios": [3, 1]}
            )

            # Sous-figure 1
            axs[0].plot(dates, p, linewidth=0.7, label="Measured power", color="blue")
            axs[0].plot(
                dates, fittedValues, linewidth=0.7, label="Fitted Values", color="red"
            )
            axs[0].set_title(f"{self.model_name} fitted versus measured power")
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

        else:
            print("self.model or self.data do not exist")

    def export_residuals(self, path: Optional["str"] = None):

        if hasattr(self, "model") and hasattr(self, "data"):
            print(f"Model {self.model_name} - Residuals are getting exported")

            path = (
                f"./residuals/residuals-{self.model_name}.csv" if path is None else None
            )
            residuals = self.model.resid
            residuals = self.data["fittedResiduals"]
            residuals = residuals.dropna()

            pd.DataFrame(residuals, columns=["residuals"]).to_csv(path)
        else:
            print("self.model and/or self.data do not exist")
