    # Close trades at target stoploss / takeprofit

    for i of context.trade
        l = context.trade[i].current()
        if instrument.price <= l.tp
            debug "Sell: #{l.v} @ #{l.p} | Buy : #{instrument.price.toFixed(2)}"
            buy instrument, l.tpv
            context.trade.splice(i,1)
        if instrument.price >= l.sl
            debug "!STOP! Sell: #{l.v} @ #{l.p} | Buy : #{instrument.price.toFixed(2)}"
            buy instrument, l.slv
            context.trade.splice(i,1)