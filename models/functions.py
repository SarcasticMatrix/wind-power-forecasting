import numpy as np


def compute_metrics(p: np.array, forecast: np.array, name_forecast: str):

    mean_error = round(np.mean(p - forecast), 3)
    variance_error = round(np.var(p - forecast), 3)
    mean_absolute_error = round(np.mean(np.abs(p - forecast)), 3)
    mean_squared_error = round(np.mean((p - forecast) ** 2), 3)

    metrics = {
        "Mean error": mean_error,
        "Variance": variance_error,
        "Mean absolute error": mean_absolute_error,
        "Mean squared error": mean_squared_error,
    }

    print(
        f" \n Forecasting metrics of {name_forecast} model: \n \
        Biais of residuals: {mean_error} \n \
        Variance of residuas: {variance_error} \n \
        Mean absolute error (MAE): {mean_absolute_error} \n \
        Mean squared error (MSE): {mean_squared_error}"
    )

    return metrics
