    # Trend calculations
    #
    # variables to be added to context
    # context.trend = ''
    #
    # calculate trend from last candle
    context.downfromlast = false
    context.upfromlast = false
   
    if (instrument.price - context.last_price ) < 0 
        trend = 'down'
        context.downfromlast = true
    else
        trend = 'up'
        context.upfromlast = true 
    context.last_price = instrument.price