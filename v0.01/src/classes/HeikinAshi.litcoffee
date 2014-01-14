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