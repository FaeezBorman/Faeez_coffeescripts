    # Find a reason to sell

    diff_h_l = H - L

    if instrument.price + 1 >= context.high and 
       ilow >= H and 
       diff_h_l > 20 and
       context.high >= H
       #then
        context.tf = 4 # confidence medium - 10%

    # Have a reason, Sell!
    if context.tf > 0
        #debug "trading factor: #{context.tf}"
        context.tradeNo = context.tradeNo + 1
        context.vol = (btc_have*(context.tf/10))
        context.price = instrument.price
        context.trade[context.tradeNo] = new sellTrade(context.tradeNo,context.price,context.vol,context.tf)
        context.trade[context.tradeNo].ctpsl(20,200)
        sell instrument,context.vol