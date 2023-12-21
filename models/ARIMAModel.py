from models.Model import Model
from typing import Optional

import pandas as pd
import statsmodels.tsa.arima.model as tsaModel

from statsmodels.tsa.arima.model import ARIMA


import warnings
warnings.filterwarnings("ignore")

class ARIMAModel(Model):
    def __init__(self):
        super().__init__(model_name="ARIMA(1,1,1)")

    def fit(self, 
            print_summary: Optional[bool] = False):

        if not hasattr(self, "data"):
            self.get_data()

        self.get_data(
            self.first_date,
            self.last_date + pd.Timedelta(hours=1),
            self.path)

        p = self.data['p']
        model = ARIMA(p, order=(1, 1, 1))
        self.model = model.fit()

        if print_summary:
            print(self.model.summary())
            print(self.model.resid.describe())
            
        df2 = pd.DataFrame({
            'fittedvalues': self.model.fittedvalues.values
        })
        df_estimation = pd.DataFrame({
            't': self.data['t'].values,
            'fittedValues': df2['fittedvalues'].shift(periods=-1),
        })

        self.data = pd.merge(self.data,df_estimation, on='t', how='outer')
        self.data['fittedResiduals'] = self.data['p'] - self.data['fittedValues']

        self.data.drop(self.data.tail(1).index,inplace=True) 
    
    def forecast(self, 
                 steps: Optional[int] = 1,
                 alpha=0.05
                ):

        if self.model is not None:
            forecast_result = self.model.get_forecast(steps=steps, alpha=alpha)
            forecast_values = forecast_result.predicted_mean
            conf_int = forecast_result.conf_int(alpha=alpha)
            return forecast_values,conf_int
        else:
            print("The ARIMA model has not been adjusted. Please adjust the model first.")




