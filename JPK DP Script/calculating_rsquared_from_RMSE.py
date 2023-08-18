# Python code for OperationJythonSeries
def requiredVersion():
    """Required: declare script version"""
    return VersionNumber(1, 4)


def registerResults():
    """Required: Declare this operation's results"""
    return [
        ('rsquare', "Rsquare")
    ]


def registerParameters():
    """Required: Declare input parameters"""
    return []


def process(data):
    """
    Required: Analyze and/or manipulate data
    """

    # Calculating the total square sum
    ydata = data.segments["Extend"]["Vertical Deflection"]
    RMSE = data.results[5].residual_rms # [Number] of operation. Here Hertz Fit
    
    # SStot for R squared RMSE
    SStotRMSE = sum(subtract(ydata, mean(ydata))**2) # Total Square Sum

    # R squared from RMSE
    R2 = 1 - (len(ydata) * RMSE**2) / SStotRMSE # 1-SSres/SStot with SSres = n * RMSE**2 with n being the number of measurements

    results = {'rsquare': (R2,'')}

    return data.create(results=results)
