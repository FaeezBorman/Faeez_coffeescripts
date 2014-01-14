
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
    this.tp = this.p - @down
    this.sl = this.p + @up
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
    context.newhighmode = false
    context.high = 800
    context.low = 700
    context.trade = []
    context.lastshorter = 999999
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

    C = instrument.close[instrument.close.length-1]
	
	# calculate trend for past 3 candles
    if (instrument.price - short ) < 0 
        trend = 'down'
    else
        trend = 'up'
        
    #new highs and lows
    
    ihigh = instrument.high[instrument.high.length-1]
    ilow = instrument.low[instrument.low.length-1]
    
    if ihigh >= H 
        context.high = ihigh
        #debug " Price over resistance #{context.high} - set new high"
     
    if ilow <= L 
        context.low = ilow

    plot
        cH: context.high
        cL: context.low
        h: H
        l: L	
	# adjust trade targets for current conditions
	
    if H > context.high
        for i of context.trade
            #debug "detected price drop, adjusted all trade stop loss to 0.5% above #{instrument.price}"  
            context.trade[i].csl(context.high,1) # price has started to dipping, pulling in the the stoploss to 1$ above current price
            #debug context.trade[i].log()

    if H < context.high and instrument.price < H
        for i of context.trade
            #debug "detected price drop, adjusted all trade stop loss to 0.5% above #{instrument.price}"  
            context.trade[i].csl(H,1) # price has started to dipping, pulling in the the stoploss to 1$ above current price
            #debug context.trade[i].log()
	
	# set lastshorter
    context.lastshorter = shorter
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
   
