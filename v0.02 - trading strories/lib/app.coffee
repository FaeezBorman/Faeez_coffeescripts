#sell trade object.....
# (trade number - counts to tatal number of sells executed
#  Price - Price at which sell was executed
#  Vol - Volume of asset thats been sold)
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

#indicator object.....
class indicator
  constructor: (@in_name,@in_desc,@in_act,@in_price,@in_low,@in_ave,@in_high,@in_last) ->

#story object.....
class story
  constructor: (@story_string,@story_price,@story_count,@story_averageprice) ->
  run: (@story_price) ->
    this.story_count = this.story_count + 1
    this.story_averageprice = (this.story_averageprice + @storyprice) / 2

class Functions
  @diff: (x, y) ->
    ((x - y) / ((x + y) / 2)) * 100

  @ema: (data, period) ->
    results = talib.EMA
      inReal: data
      startIdx: 0
      endIdx: data.length - 1
      optInTimePeriod: period
    _.last(results)

  @sar: (high, low, accel, max) ->
    results = talib.SAR
      high: high
      low: low
      startIdx: 0
      endIdx: high.length - 1
      optInAcceleration: accel
      optInMaximum: max
    _.last(results)

  @sar_ext: (high, low, start_value, offset_on_rev, accel_init_long, accel_long, accel_max_long, accel_init_short, accel_short, accel_max_short) ->
    results = talib.SAREXT
      high: high
      low: low
      startIdx: 0
      endIdx: high.length - 1
      optInStartValue: start_value
      optInOffsetOnReverse: offset_on_rev
      optInAccelerationInitLong: accel_init_long
      optInAccelerationLong: accel_long
      optInAccelerationMaxLong: accel_max_long
      optInAccelerationInitShort: accel_init_short
      optInAccelerationShort: accel_short
      optInAccelerationMaxShort: accel_max_short
    _.last(results)

  @aroon: (high, low, period) ->
    results = talib.AROON
      high: high
      low: low
      startIdx: 0
      endIdx: high.length - 1
      optInTimePeriod: period
    result =
      up: _.last(results.outAroonUp)
      down: _.last(results.outAroonDown)
    result

  @macd: (data, fast_period, slow_period, signal_period) ->
    results = talib.MACD
      inReal: data
      startIdx: 0
      endIdx: data.length - 1
      optInFastPeriod: fast_period
      optInSlowPeriod: slow_period
      optInSignalPeriod: signal_period
    result =
      macd: _.last(results.outMACD)
      signal: _.last(results.outMACDSignal)
      histogram: _.last(results.outMACDHist)
    result

  @rsi: (data, period) ->
    results = talib.RSI
      inReal: data
      startIdx: 0
      endIdx: data.length - 1
      optInTimePeriod: period
    _.last(results)

  @populate: (target, ins, step = 1) ->
    for i in [0...ins.close.length / step]
      t =
        open: ins.open[..i]
        close: ins.close[..i]
        high: ins.high[..i]
        low: ins.low[..i]
      target.put(t)

  @can_buy: (ins, min_btc, fee_percent) ->
    portfolio.positions[ins.curr()].amount >= ((ins.price * min_btc) * (1 + fee_percent / 100))

  @can_sell: (ins, min_btc) ->
    portfolio.positions[ins.asset()].amount >= min_btc

  @buy: (instrument, limit_percent, timeout) ->
    buy(instrument, null, instrument.price * (1 + limit_percent / 100), timeout)

  @sell: (instrument, limit_percent, timeout) ->
    sell(instrument, null, instrument.price * (1 - limit_percent / 100), timeout)

class Config
  constructor: (@long_open, @long_close, @short_open, @short_close, @sar_accel, @sar_max, @aroon_period, @aroon_threshold, @macd_fast_period, @macd_slow_period, @macd_signal_period, @macd_short, @macd_long, @rsi_period, @rsi_high, @rsi_low) ->

# Initialization method called before a simulation starts. 
# Context object holds script data and will be passed to 'handle' method. 
init: (context)->
    context.pair = 'btc_usd'
    # STORY VARIABLES
    # STORY INDICES
    context.trend = false
    
    context.sell_treshold = 0.25
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
    context.trade = []
    context.lastshorter = 999999
    context.enable_ha = false
    context.last_sar = 999
    context.config = new Config(0.1, 0.3, 0.3, 2.4, 0.025, 0.2, 10, 20, 14, 22, 9, 0, 1, 20, 52, 48)

# highs and lows
    context.high = 800
    context.low = 800
    context.last_high = 600

# This method is called for each tick
handle: (context, data)->
    instrument = data[context.pair]
    fiat_have = portfolio.positions[instrument.curr()].amount
    btc_have = portfolio.positions[instrument.asset()].amount
    context.tf = 0


    #Highs and lows Indicator
    # 
    
    hlmode = new indicator("","",false) 
    hlrange = new indicator("","",false)

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

    L = min[min.length-1]
    
    #new highs and lows
    
    ihigh = instrument.high[instrument.high.length-1]
    ilow = instrument.low[instrument.low.length-1]

    # hlmode tells if price has new highs, new lows, or in range high and low
    if ihigh >= H 
        context.high = ihigh
        hlmode = new indicator("HL","new highs: price above last resistance",false)   
    if context.last_high > context.high and ihigh >= H
        hlmode = new indicator("HL","price is dropping from testing new highs",true)
    else
      context.last_high = context.high
    if ilow <= L 
        context.low = ilow
        hlmode = new indicator("HL","new lows: price below last resistance",false)   
    if ihigh <= H and ilow >= L and ihigh <= context.high and ilow >= context.low
        hlmode = new indicator("HL","in range: price between H and L",false)
    
    # hlrange tells how big the gap between high and low is / i.e volatility
    if (context.high - context.low) > 30 
        hlrange = new indicator("HLRH","big range",true,(context.high - context.low))
    if (context.high - context.low) > 20 
        hlrange = new indicator("HLRM","medium range",true,context.high - context.low)
    if (context.high - context.low) < 20 
        hlrange = new indicator("HLRL","low range",false,context.high - context.low)
    


    # context variables
    # context.ha = new HeikinAshi()
    
    # calc ichi indicators
    #tk_diff = Math.abs(Functions.diff(c.tenkan, c.kijun))
    #tenkan_min = _.min([c.tenkan, c.kijun])
    #tenkan_max = _.max([c.tenkan, c.kijun])
    #kumo_min = _.min([c.senkou_a, c.senkou_b])
    #kumo_max = _.max([c.senkou_a, c.senkou_b])

    # calc sar indicator
    if context.enable_ha
      sar = Functions.sar(context.ha.ins.high, context.ha.ins.low, 0.025, 0.2)
    else
      sar = Functions.sar(instrument.high, instrument.low, 0.025, 0.2)
      if sar > instrument.price
         psar = new indicator("SAR","sar indicating start of down trend",true)
      else 
         psar = new indicator("SAR","sar indicating up trend",false)
      context.last_sar = sar

    # calc aroon indicator
    #if context.enable_ha
    #  aroon = Functions.aroon(context.ha.ins.high, context.ha.ins.low, config.aroon_period)
    #else
    #  aroon = Functions.aroon(instrument.high, instrument.low, config.aroon_period)

    # calc macd indicator
    #if context.enable_ha
    #  macd = Functions.macd(context.ha.ins.close, config.macd_fast_period, config.macd_slow_period,
    #  config.macd_signal_period)
    #else
    #  macd = Functions.macd(instrument.close, config.macd_fast_period, config.macd_slow_period,
    #  config.macd_signal_period)

    # calc rsi indicator
    #if context.enable_ha
    #  rsi = Functions.rsi(context.ha.ins.close, config.rsi_period)
    #else
    #  rsi = Functions.rsi(instrument.close, config.rsi_period)

    plot
        cH: context.high
        cL: context.low
        sar: sar
        lasthigh : context.last_high

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

