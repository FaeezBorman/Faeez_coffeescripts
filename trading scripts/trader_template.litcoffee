class sellTrade
  constructor: (@tn,@p,@v,@tf,@tp,@sl,@tpv,@slv) ->
  current: ->
    c = 
        tn: @tn
        p: @p
        v: @v
        tf: @tf
        tp: @tp
        sl: @sl
        tpv: @tpv
        slv: @slv
    return c
  ctpsl: (@up,@down) ->
    this.tp = this.p * (100 - @down)/100
    this.sl = this.p * (100 + @up)/100
    this.tpv = (this.p * this.v)/ this.tp
    this.slv = (this.p * this.v)/ this.sl
  csl: (@cp,@diff) ->
    this.sl = @cp + @diff
    this.slv = (this.p * this.v)/ this.sl
  ctp: (@cp,@diff) ->
    this.tp = @cp * (100 - @difF)/100
    this.tpv = (this.p * this.v)/ this.tpv
  log: ->
    d = "trade number :" + @tn + " at price " + @p + " v: " + @v + " tf: " + @tf + " tp: " + @tp + " sl: " + @sl

# Initialization method called before a simulation starts. 
# Context object holds script data and will be passed to 'handle' method. 
init: (context)->
    context.buy_treshold = 0.25
    context.sell_treshold = 0.25
    context.pair = 'btc_usd'
    context.init = false
    context.stoploss = 0.0
    context.close = 2
    context.trade_mini = 0.0
    context.tradeNo = 0.0
    context.price = 0.0
    context.vol = 0.0
    context.takeProfit = 0.0
    context.tf = 0.0
    context.trade = []
	#context.pos = false

# This method is called for each tick
handle: (context, data)->
    instrument = data[context.pair]
    fiat_have = portfolio.positions[instrument.curr()].amount
    btc_have = portfolio.positions[instrument.asset()].amount
    short = instrument.ema(10) # calculate EMA value using ta-lib function
    long = instrument.ema(21) 
    shorter = instrument.ema(3)
    context.tf = 0
	
	# adjust trade targets for current conditions
    #if shorter < short and trend = 'down' #reason to adjust targets
        for i of context.trade
            #debug "detected price drop, adjusted all trade stop loss to 0.5% above #{instrument.price}"  
            context.trade[i].csl(instrument.price,2) # price has started to dipping, pulling in the the stoploss to 1% above current price
            #debug context.trade[i].log()

        
    # Close trades at target stoploss / takeprofit

    for i of context.trade
        l = context.trade[i].current()
        if instrument.price <= l.tp
            debug "takeprofit #{l.v} @ #{l.p} bought @ #{instrument.price.toFixed(2)}"
            buy instrument, l.tpv
            context.trade.splice(i,1)
        if instrument.price >= l.sl
            debug "stoploss #{l.v} @ #{l.p} bought @ #{instrument.price.toFixed(2)}"
            buy instrument, l.slv
            context.trade.splice(i,1)
                
	# Find a reason to sell


	# Have a reason, Sell!
    if context.tf > 0
        #debug "trading factor: #{context.tf}"
        context.tradeNo = context.tradeNo + 1
        context.vol = (btc_have*(context.tf/10))
        context.price = instrument.price
        context.trade[context.tradeNo] = new sellTrade(context.tradeNo,context.price,context.vol,context.tf)
        context.trade[context.tradeNo].ctpsl(10,5)
        sell instrument,context.vol
###   
    #dump last trade
    if context.tradeNo > 0
        debug context.trade[context.tradeNo].log()
###