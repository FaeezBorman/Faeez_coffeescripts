#sell trade object.....
# (trade number - counts to tatal number of sells executed
#  Price - Price at which sell was executed
#  Vol - Volume of asset thats been sold)

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
    context.pair = 'btc_usd'
    context.init = false


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

#new highs and lows

ihigh = instrument.high[instrument.high.length-1]
ilow = instrument.low[instrument.low.length-1]

if ihigh >= H 
    context.high = ihigh
    #debug " Price over resistance #{context.high} - set new high"
 
if ilow <= L 
    context.low = ilow

# calculate trend for past 3 candles
if (instrument.price - short ) < 0 
    trend = 'down'
else
    trend = 'up'

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