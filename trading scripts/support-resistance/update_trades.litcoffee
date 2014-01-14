# call to update all open trades 
# adjust trade targets for current conditions

for i of context.trade
	
	if H > context.high
        #debug "detected price drop, adjusted all trade stop loss to 0.5% above #{instrument.price}"  
        context.trade[i].csl(context.high,1) # price has started to dipping, pulling in the the stoploss to 1$ above current price
        #debug context.trade[i].log()

	if H < context.high and instrument.price < H
        #debug "detected price drop, adjusted all trade stop loss to 0.5% above #{instrument.price}"  
        context.trade[i].csl(H,1) # price has started to dipping, pulling in the the stoploss to 1$ above current price
        #debug context.trade[i].log()