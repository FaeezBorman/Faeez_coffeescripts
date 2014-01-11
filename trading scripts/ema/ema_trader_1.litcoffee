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
    context.stoploss = 800
    context.close = 2
    context.trade_mini = 0.0
    context.tradeNo = 0.0
    context.price = 0.0
    context.vol = 0.0
    context.takeProfit = 800
    context.tf = 0.0
    context.trade = []
    context.lastshorter = 99999
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
    # draw moving averages on chart
    plot
        short: short
        long: long
        shorter : shorter
        tp : context.takeProfit
        sl : context.stoploss
    ema_diff = 100 * (short - long) / ((short + long) / 2)
    ema2_diff = 100 * (shorter - short) / ((shorter + short) / 2)
    
    # calculate trend for past 3 candles
    if (instrument.price - short ) < 0 
        trend = 'down'
    else
        trend = 'up'
        
    # cross-overs
    if shorter < short
        shorter_short = true
    if shorter < long
        shorter_long = true
        
    # adjust trade targets for current conditions
    if shorter < short and trend = 'down' and context.lastshorter > shorter
        for i of context.trade
            #debug "detected price drop, adjusted all trade stop loss to 0.5% above #{instrument.price}"  
            context.trade[i].csl(instrument.price,1) # price has started to dipping, pulling in the the stoploss to 1% above current price
            #debug context.trade[i].log()
    
    # Close trades at target
    if context.tradeNo > 0
        for i of context.trade
            l = context.trade[i].current()
            if instrument.price <= l.tp
                debug "took profit sold #{l.v} @ #{l.p} bought @ #{instrument.price.toFixed(2)}"
                buy instrument, l.tpv
                context.trade.splice(i,1)
            if instrument.price >= l.sl
                debug "took loss sold #{l.v} @ #{l.p} bought @ #{instrument.price.toFixed(2)}"
                buy instrument, l.slv
                context.trade.splice(i,1)
            context.takeProfit = l.tp
            context.stoploss = l.sl
            
    # set lastshorter
    context.lastshorter = shorter
	# Find a reason to sell
	# EMA short and long %diff and shorter and short %diff
    if ema_diff > 2  and ema2_diff > 2  and shorter < instrument.price - 1      
        #debug "STRONG EMA Price: #{instrument.price.toFixed(2)} ema_diff: #{ema_diff.toFixed(2)}"
        context.tf = context.tf + 5
        context.init = true
      
    else if ema_diff > 0.7 and ema2_diff > 0.7 and shorter < instrument.price - 0.5
            #debug "MEDIUM EMA Price: #{instrument.price.toFixed(2)} ema_diff: #{ema_diff.toFixed(2)}"
            context.tf = context.tf + 2
            context.init = true

	# Have a reason, Sell!
    if context.tf > 0
        #debug "trading factor: #{context.tf}"
        context.tradeNo = context.tradeNo + 1
        context.vol = (btc_have*(context.tf/10))
        context.price = instrument.price
        context.trade[context.tradeNo] = new sellTrade(context.tradeNo,context.price,context.vol,context.tf)
        context.trade[context.tradeNo].ctpsl(5,5)
        sell instrument,context.vol
###   
    #dump last trade
    if context.tradeNo > 0
        debug context.trade[context.tradeNo].log()
###