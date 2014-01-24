    # Find a reason to sell

    if hlmode.in_act and hlrange.in_act and psar.in_act
       #then
        debug "#{hlmode.in_desc} and #{hlrange.in_desc} and #{psar.in_desc}"
        open_trade = true 

    # Have a reason, Sell!
    if open_trade and context.limits.get_asset_lvl1() > 0
        context.tradeNo = context.tradeNo + 1
        context.vol = context.limits.get_asset_lvl1()
        context.price = instrument.price
        #context.trade[context.tradeNo] = new sellTrade(context.tradeNo,context.price,context.vol,context.tf)
        sell instrument,context.vol
    # fork 1 sell order into seperate trades with dif target range
        if hlrange.in_price > 20 # ghs:0.001 ltc:1
           #split into 3
           for x in [1..3]
              context.trade.push new sellTrade(context.tradeNo,context.price,context.vol / 3, context.tf,x + 2) # btc 
              #context.trade.push new sellTrade(context.tradeNo,context.price,context.vol / 3, context.tf,x/10000 + 0.0002) # ghs 
              #context.trade.push new sellTrade(context.tradeNo,context.price,context.vol / 3, context.tf,x/10 + 0.2) # ltc
