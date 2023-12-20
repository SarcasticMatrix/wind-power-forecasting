from models.ARIMAModel import ARIMAModel

myModel = ARIMAModel()
myModel.get_data()

myModel.fit(print_summary=False)
#myModel.plot_model()
myModel.export_residuals()