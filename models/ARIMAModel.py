from models.Model import Model
from typing import Optional

import pandas as pd
import statsmodels.tsa.arima.model as tsaModel

from statsmodels.tsa.arima.model import ARIMA


import warnings
warnings.filterwarnings("ignore")

class ARIMAModel(Model):
    def __init__(self):
        super().__init__(model_name="ARIMA")

    def fit(self, 
            first_date: Optional[str] = "1999-01-01",
            last_date: Optional[str] = "2000-01-01",
            print_summary: Optional[bool] = False):

        if not hasattr(self, "data"):
            self.get_data()

        if first_date < last_date:
            self.first_date = first_date
            self.last_date = last_date

            mask = (first_date < self.data['t']) & (self.data['t'] < last_date)
            series = self.data.loc[mask, ['t', 'p']]
            series.set_index('t', inplace=True)
            self.series = series

            model = ARIMA(series, order=(1, 1, 1))
            self.model = model.fit()

            if print_summary:
                print(self.model.summary())
                print(self.model.resid.describe())
            
            dates = self.data.loc[mask,'t'].values
            df1 = pd.DataFrame({
                't': dates[:-1],
                'series': series[:-1].values.flatten()
            })
            
            df2 = pd.DataFrame({
                't':dates, 
                'fittedvalues': self.model.fittedvalues.values
            })

            self.df_estimation = pd.DataFrame({
                't': df1['t'],
                'fittedvalues': df2['fittedvalues'].shift(periods=-1),
                'series': df1['series']
            })


        else:
            print("the first_date must be < than last_date")


