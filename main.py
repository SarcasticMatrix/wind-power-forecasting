from models.ARIMAModel import ARIMAModel

myModel = ARIMAModel()
myModel.get_data()

myModel.fit(
            first_date = "1999-01-01",
            last_date = "2003-04-30",
            print_summary=False)
#myModel.plot_model()

myModel.export_residuals()