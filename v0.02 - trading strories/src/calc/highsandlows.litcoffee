    #Highs and lows Indicator
    # 
    
    hlmode = new indicator("","",false) 
    hlrange = new indicator("","",false)

    max = talib.MAX
        inReal: instrument.high
        startIdx: 0
        endIdx: instrument.high.length-13
        optInTimePeriod: 12
    
    min = talib.MIN
        inReal: instrument.low
        startIdx: 0
        endIdx: instrument.low.length-13
        optInTimePeriod: 12

    H = max[max.length-1]

    L = min[min.length-1]
    
    #new highs and lows
    
    ihigh = instrument.high[instrument.high.length-1]
    ilow = instrument.low[instrument.low.length-1]

    # hlmode tells if price has new highs, new lows, or in range high and low
    if ihigh >= H 
        context.high = ihigh
        hlmode = new indicator("HL","new highs: price above last resistance",false)   
    if context.last_high > context.high and ihigh >= H
        hlmode = new indicator("HL","price is dropping from testing new highs",true)
    else
      context.last_high = context.high
    if ilow <= L 
        context.low = ilow
        hlmode = new indicator("HL","new lows: price below last resistance",false)   
    if ihigh <= H and ilow >= L and ihigh <= context.high and ilow >= context.low
        hlmode = new indicator("HL","in range: price between H and L",false)
    
    # hlrange tells how big the gap between high and low is / i.e volatility
    if (context.high - context.low) > 30 
        hlrange = new indicator("HLRH","big range",true,(context.high - context.low))
    if (context.high - context.low) > 20 
        hlrange = new indicator("HLRM","medium range",true,context.high - context.low)
    if (context.high - context.low) < 20 
        hlrange = new indicator("HLRL","low range",false,context.high - context.low)
    
