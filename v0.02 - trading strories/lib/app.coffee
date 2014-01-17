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

class Config
  constructor: (@long_open, @long_close, @short_open, @short_close, @sar_accel, @sar_max, @aroon_period, @aroon_threshold, @macd_fast_period, @macd_slow_period, @macd_signal_period, @macd_short, @macd_long, @rsi_period, @rsi_high, @rsi_low) ->

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

class HeikinAshi
  constructor: () ->
    @ins =
      open: []
      close: []
      high: []
      low: []

  # update with latest instrument price data
  put: (ins) ->
    if @ins.open.length == 0
      # initial candle
      @ins.open.push(ins.open[ins.open.length - 1])
      @ins.close.push(ins.close[ins.close.length - 1])
      @ins.high.push(ins.high[ins.high.length - 1])
      @ins.low.push(ins.low[ins.low.length - 1])
    else
      # every other candle
      prev_open = ins.open[ins.open.length - 2]
      prev_close = ins.close[ins.close.length - 2]
      curr_open = ins.open[ins.open.length - 1]
      curr_close = ins.close[ins.close.length - 1]
      curr_high = ins.high[ins.high.length - 1]
      curr_low = ins.low[ins.low.length - 1]
      @ins.open.push((prev_open + prev_close) / 2)
      @ins.close.push((curr_open + curr_close + curr_high + curr_low) / 4)
      @ins.high.push(_.max([curr_high, curr_open, curr_close]))
      @ins.low.push(_.min([curr_low, curr_open, curr_close]))

#story object.....

class story
  constructor: (@story_string,@story_price,@story_count) ->
  current: ->
    c = 
        story_indicator : @story_indicator
        story_price : @story_price
        story_count: @story_count
    return c
  #log: ->
    #d = "trade number :" + @tn + " at price " + @p + " v: " + @v + " tf: " + @tf + " tp: " + @tp + " sl: " + @sl

# Initialization method called before a simulation starts. 
# Context object holds script data and will be passed to 'handle' method. 
init: (context)->
    context.pair = 'btc_usd'
    context.init = false
    context.buy_treshold = 0.25
    context.sell_treshold = 0.25
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

# Trend
    context.trend = ''

# highs and lows
    context.high = 0
    context.low = 0

# This method is called for each tick
handle: (context, data)->
    instrument = data[context.pair]
    fiat_have = portfolio.positions[instrument.curr()].amount
    btc_have = portfolio.positions[instrument.asset()].amount


    #new highs and lows
    ihigh = instrument.high[instrument.high.length-1]
    ilow = instrument.low[instrument.low.length-1]

    if ihigh >= H 
        context.high = ihigh
        #debug " Price over resistance #{context.high} - set new high"
    
    if ilow <= L 
        context.low = ilow

    # Trend calculations
    #
    # variables to be added to context
    #	context.trend = ''
    #
    # calculate trend for past 3 candles
    if (instrument.price - short ) < 0 
        trend = 'down'
    else
        trend = 'up'

    # calc ichi indicators
    tk_diff = Math.abs(Functions.diff(c.tenkan, c.kijun))
    tenkan_min = _.min([c.tenkan, c.kijun])
    tenkan_max = _.max([c.tenkan, c.kijun])
    kumo_min = _.min([c.senkou_a, c.senkou_b])
    kumo_max = _.max([c.senkou_a, c.senkou_b])

    # calc sar indicator
    if context.enable_ha
      sar = Functions.sar(context.ha.ins.high, context.ha.ins.low, config.sar_accel, config.sar_max)
    else
      sar = Functions.sar(instrument.high, instrument.low, config.sar_accel, config.sar_max)

    # calc aroon indicator
    if context.enable_ha
      aroon = Functions.aroon(context.ha.ins.high, context.ha.ins.low, config.aroon_period)
    else
      aroon = Functions.aroon(instrument.high, instrument.low, config.aroon_period)

    # calc macd indicator
    if context.enable_ha
      macd = Functions.macd(context.ha.ins.close, config.macd_fast_period, config.macd_slow_period,
      config.macd_signal_period)
    else
      macd = Functions.macd(instrument.close, config.macd_fast_period, config.macd_slow_period,
      config.macd_signal_period)

    # calc rsi indicator
    if context.enable_ha
      rsi = Functions.rsi(context.ha.ins.close, config.rsi_period)
    else
      rsi = Functions.rsi(instrument.close, config.rsi_period)

    plot
        cH: context.high
        cL: context.low
        h: H
        l: L

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