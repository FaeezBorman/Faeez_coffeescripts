    #new highs and lows
    ihigh = instrument.high[instrument.high.length-1]
    ilow = instrument.low[instrument.low.length-1]

    if ihigh >= H 
        context.high = ihigh
        #debug " Price over resistance #{context.high} - set new high"
    
    if ilow <= L 
        context.low = ilow