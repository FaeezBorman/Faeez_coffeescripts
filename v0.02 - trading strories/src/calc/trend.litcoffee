    # Trend calculations
    #
    # variables to be added to context
    #	context.trend = ''
    #
    # calculate trend for past 3 candles
    if (instrument.price - short ) < 0 
        trend = 'down'
    else
        trend = 'up'