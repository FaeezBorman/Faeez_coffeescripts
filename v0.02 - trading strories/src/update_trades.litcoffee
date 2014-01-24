    # call to update all open trades 
    # trailing stop
    
    ave_price = 0
    total_price = 0
    tcount = 0
	inprofit = false
    for i of context.trade
        l = context.trade[i].current()
        if (l.p * 0.99) > instrument.price
           inprofit = true
        if context.downfromlast and inprofit
            context.trade[i].csl(instrument.price,l.tsl)
            #debug context.trade[i].log()
        # Profit target
        total_price = total_price + l.p   
        tcount = ++i
        #debug "total price : #{total_price} tcount : #{tcount}"
    if total_price > 0 
       ave_price = total_price/tcount
       #debug "ave_price #{ave_price}"
       context.profitline = ave_price * 0.99