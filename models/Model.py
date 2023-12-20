from typing import Optional

import pandas as pd
import matplotlib.pyplot as plt

class Model:
    def __init__(
        self, 
        model_name: Optional[str] = "Not defined"
    ):

        self.model_name = model_name

    def get_data(
        self,
        path='./data/cex4WindDataInterpolated.csv'
    ):

        self.data = pd.read_csv(path)
        self.data['t'] = pd.to_datetime(self.data['t'])
    

    def plot_data(self, year=1999):
        self.data['year'] = self.data['t'].dt.strftime('%Y')
        dataYear = self.data[self.data['year'] == str(year)]

        if str(year) in dataYear['year'].unique():
            gridSeq = pd.date_range(start=min(dataYear['t']), periods=12, freq='M')

            # Personnalisation des paramètres graphiques
            fig, axs = plt.subplots(4, 1, figsize=(10, 10), gridspec_kw={'hspace': 0.5, 'top': 0.9, 'bottom': 0.1})

            # Plot measured average wind power
            axs[0].plot(dataYear['t'], dataYear['p'], color='black', linewidth=0.7)
            axs[0].set_ylabel('measured wind power')
            axs[0].set_xticks([])
            for grid_value in gridSeq:
                axs[0].axvline(grid_value, linestyle="--", linewidth=0.7, color="gray")

            # Plot 1,2,3-hour ahead forecasted wind speed.
            axs[1].plot(dataYear['t'], dataYear['Ws1'], linewidth=0.7, label='1-hour ahead')
            axs[1].plot(dataYear['t'], dataYear['Ws2'], linewidth=0.7, label='2-hour ahead')
            axs[1].plot(dataYear['t'], dataYear['Ws3'], linewidth=0.7, label='3-hour ahead')
            axs[1].set_ylabel('wind speed')
            axs[1].set_xticks([])
            for grid_value in gridSeq:
                axs[1].axvline(grid_value, linestyle="--", linewidth=0.5, color="gray")

            # Plot 1,2,3-hour ahead forecasted wind direction
            axs[2].plot(dataYear['t'], dataYear['Wd1'], linewidth=0.7, label='1-hour ahead')
            axs[2].plot(dataYear['t'], dataYear['Wd2'], linewidth=0.7, label='2-hour ahead')
            axs[2].plot(dataYear['t'], dataYear['Wd3'], linewidth=0.7, label='3-hour ahead')
            axs[2].set_ylabel('wind direction')
            axs[2].set_xticks([])
            for grid_value in gridSeq:
                axs[2].axvline(grid_value, linestyle="--", linewidth=0.5, color="gray")

            # Plot 1,2,3-hour ahead forecasted temperature
            axs[3].plot(dataYear['t'], dataYear['T1'], linewidth=0.7, label='1-hour ahead')
            axs[3].plot(dataYear['t'], dataYear['T2'], linewidth=0.7, label='2-hour ahead')
            axs[3].plot(dataYear['t'], dataYear['T3'], linewidth=0.7, label='3-hour ahead')
            axs[3].set_ylabel('temperature')
            for grid_value in gridSeq:
                axs[3].axvline(grid_value, linestyle="--", linewidth=0.5, color="gray")

            handles, labels = axs[3].get_legend_handles_labels()
            fig.legend(handles, labels, loc='upper right')

            fig.suptitle(f"Data over year {year}", fontsize=16, fontweight="bold")
            plt.show()
        else:
            print(f'The year {year} is not part of the dataset')

    # def plot_model(self):
        
    #     if hasattr(self,"model") and hasattr(self,"data"):
    #         plt.figure()

    #         # Plot actual values
    #         plt.plot(self.model., self.data['p'], linewidth=0.7, label='Actual Values', color='blue')

    #         # Plot fitted values
    #         plt.plot(series.index, self.model.fittedvalues, linewidth=0.7, label='Fitted Values', color='red')

    #         plt.title('Comparison of Actual vs. Fitted Values')
    #         plt.xlabel('Time')
    #         plt.ylabel('Wind Power')
    #         plt.legend()
    #         plt.show()
    #     else:
    #         print('self.model or self.data do not exist')

    
    def export_residuals(self,
                         path: Optional['str'] = None
        ):
        
        if hasattr(self, "model"):
            print(f'Model {self.model_name} - Residuals are getting exported')

            path = f"./residuals/residuals-{self.model_name}.csv" if path is None else None
            residuals = self.model.resid
            residuals = residuals.dropna()

            pd.DataFrame(residuals,columns=['residuals']).to_csv(path)
        else:
            print('Model does not exist - you must first fit it')



