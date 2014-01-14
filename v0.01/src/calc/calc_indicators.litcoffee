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