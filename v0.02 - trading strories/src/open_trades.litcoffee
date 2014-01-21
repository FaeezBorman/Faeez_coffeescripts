    # Find a reason to sell

    if hlmode.in_act and hlrange.in_act and psar.in_act
       #then
        debug "#{hlmode.in_desc} and #{hlrange.in_desc} and #{psar.in_desc}"
        context.tf = 4 

    # Have a reason, Sell!
    if context.tf > 0
        #debug "trading factor: #{context.tf}"
        context.tradeNo = context.tradeNo + 1
        context.vol = (btc_have*(context.tf/10))
        context.price = instrument.price
        #context.trade[context.tradeNo] = new sellTrade(context.tradeNo,context.price,context.vol,context.tf)
        sell instrument,context.vol
    # fork 1 sell order into seperate trades with dif target range
        if hlrange.in_price > 20
           #split into 3
           for x in [1..3]
              context.trade.push new sellTrade(context.tradeNo,context.price,context.vol / 3, context.tf) 

