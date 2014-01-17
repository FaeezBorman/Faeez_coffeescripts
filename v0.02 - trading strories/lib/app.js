// Generated by CoffeeScript 1.6.1
(function() {
  var Config, Functions, HeikinAshi, sellTrade, story;

  sellTrade = (function() {

    function sellTrade(tn, p, v, tf, tp, sl, tpv, slv) {
      this.tn = tn;
      this.p = p;
      this.v = v;
      this.tf = tf;
      this.tp = tp;
      this.sl = sl;
      this.tpv = tpv;
      this.slv = slv;
    }

    sellTrade.prototype.current = function() {
      var c;
      c = {
        tn: this.tn,
        p: this.p,
        v: this.v,
        tf: this.tf,
        tp: this.tp,
        sl: this.sl,
        tpv: this.tpv,
        slv: this.slv
      };
      return c;
    };

    sellTrade.prototype.ctpsl = function(up, down) {
      this.up = up;
      this.down = down;
      this.tp = this.p - this.down;
      this.sl = this.p + this.up;
      this.tpv = (this.p * this.v) / this.tp;
      return this.slv = (this.p * this.v) / this.sl;
    };

    sellTrade.prototype.csl = function(cp, diff) {
      this.cp = cp;
      this.diff = diff;
      this.sl = this.cp + this.diff;
      return this.slv = (this.p * this.v) / this.sl;
    };

    sellTrade.prototype.ctp = function(cp, diff) {
      this.cp = cp;
      this.diff = diff;
      this.tp = this.cp * (100 - this.difF) / 100;
      return this.tpv = (this.p * this.v) / this.tpv;
    };

    sellTrade.prototype.log = function() {
      var d;
      return d = "trade number :" + this.tn + " at price " + this.p + " v: " + this.v + " tf: " + this.tf + " tp: " + this.tp + " sl: " + this.sl;
    };

    return sellTrade;

  })();

  Config = (function() {

    function Config(long_open, long_close, short_open, short_close, sar_accel, sar_max, aroon_period, aroon_threshold, macd_fast_period, macd_slow_period, macd_signal_period, macd_short, macd_long, rsi_period, rsi_high, rsi_low) {
      this.long_open = long_open;
      this.long_close = long_close;
      this.short_open = short_open;
      this.short_close = short_close;
      this.sar_accel = sar_accel;
      this.sar_max = sar_max;
      this.aroon_period = aroon_period;
      this.aroon_threshold = aroon_threshold;
      this.macd_fast_period = macd_fast_period;
      this.macd_slow_period = macd_slow_period;
      this.macd_signal_period = macd_signal_period;
      this.macd_short = macd_short;
      this.macd_long = macd_long;
      this.rsi_period = rsi_period;
      this.rsi_high = rsi_high;
      this.rsi_low = rsi_low;
    }

    return Config;

  })();

  Functions = (function() {

    function Functions() {}

    Functions.diff = function(x, y) {
      return ((x - y) / ((x + y) / 2)) * 100;
    };

    Functions.ema = function(data, period) {
      var results;
      results = talib.EMA({
        inReal: data,
        startIdx: 0,
        endIdx: data.length - 1,
        optInTimePeriod: period
      });
      return _.last(results);
    };

    Functions.sar = function(high, low, accel, max) {
      var results;
      results = talib.SAR({
        high: high,
        low: low,
        startIdx: 0,
        endIdx: high.length - 1,
        optInAcceleration: accel,
        optInMaximum: max
      });
      return _.last(results);
    };

    Functions.sar_ext = function(high, low, start_value, offset_on_rev, accel_init_long, accel_long, accel_max_long, accel_init_short, accel_short, accel_max_short) {
      var results;
      results = talib.SAREXT({
        high: high,
        low: low,
        startIdx: 0,
        endIdx: high.length - 1,
        optInStartValue: start_value,
        optInOffsetOnReverse: offset_on_rev,
        optInAccelerationInitLong: accel_init_long,
        optInAccelerationLong: accel_long,
        optInAccelerationMaxLong: accel_max_long,
        optInAccelerationInitShort: accel_init_short,
        optInAccelerationShort: accel_short,
        optInAccelerationMaxShort: accel_max_short
      });
      return _.last(results);
    };

    Functions.aroon = function(high, low, period) {
      var result, results;
      results = talib.AROON({
        high: high,
        low: low,
        startIdx: 0,
        endIdx: high.length - 1,
        optInTimePeriod: period
      });
      result = {
        up: _.last(results.outAroonUp),
        down: _.last(results.outAroonDown)
      };
      return result;
    };

    Functions.macd = function(data, fast_period, slow_period, signal_period) {
      var result, results;
      results = talib.MACD({
        inReal: data,
        startIdx: 0,
        endIdx: data.length - 1,
        optInFastPeriod: fast_period,
        optInSlowPeriod: slow_period,
        optInSignalPeriod: signal_period
      });
      result = {
        macd: _.last(results.outMACD),
        signal: _.last(results.outMACDSignal),
        histogram: _.last(results.outMACDHist)
      };
      return result;
    };

    Functions.rsi = function(data, period) {
      var results;
      results = talib.RSI({
        inReal: data,
        startIdx: 0,
        endIdx: data.length - 1,
        optInTimePeriod: period
      });
      return _.last(results);
    };

    Functions.populate = function(target, ins, step) {
      var i, t, _i, _ref, _results;
      if (step == null) {
        step = 1;
      }
      _results = [];
      for (i = _i = 0, _ref = ins.close.length / step; 0 <= _ref ? _i < _ref : _i > _ref; i = 0 <= _ref ? ++_i : --_i) {
        t = {
          open: ins.open.slice(0, +i + 1 || 9e9),
          close: ins.close.slice(0, +i + 1 || 9e9),
          high: ins.high.slice(0, +i + 1 || 9e9),
          low: ins.low.slice(0, +i + 1 || 9e9)
        };
        _results.push(target.put(t));
      }
      return _results;
    };

    Functions.can_buy = function(ins, min_btc, fee_percent) {
      return portfolio.positions[ins.curr()].amount >= ((ins.price * min_btc) * (1 + fee_percent / 100));
    };

    Functions.can_sell = function(ins, min_btc) {
      return portfolio.positions[ins.asset()].amount >= min_btc;
    };

    Functions.buy = function(instrument, limit_percent, timeout) {
      return buy(instrument, null, instrument.price * (1 + limit_percent / 100), timeout);
    };

    Functions.sell = function(instrument, limit_percent, timeout) {
      return sell(instrument, null, instrument.price * (1 - limit_percent / 100), timeout);
    };

    return Functions;

  })();

  HeikinAshi = (function() {

    function HeikinAshi() {
      this.ins = {
        open: [],
        close: [],
        high: [],
        low: []
      };
    }

    HeikinAshi.prototype.put = function(ins) {
      var curr_close, curr_high, curr_low, curr_open, prev_close, prev_open;
      if (this.ins.open.length === 0) {
        this.ins.open.push(ins.open[ins.open.length - 1]);
        this.ins.close.push(ins.close[ins.close.length - 1]);
        this.ins.high.push(ins.high[ins.high.length - 1]);
        return this.ins.low.push(ins.low[ins.low.length - 1]);
      } else {
        prev_open = ins.open[ins.open.length - 2];
        prev_close = ins.close[ins.close.length - 2];
        curr_open = ins.open[ins.open.length - 1];
        curr_close = ins.close[ins.close.length - 1];
        curr_high = ins.high[ins.high.length - 1];
        curr_low = ins.low[ins.low.length - 1];
        this.ins.open.push((prev_open + prev_close) / 2);
        this.ins.close.push((curr_open + curr_close + curr_high + curr_low) / 4);
        this.ins.high.push(_.max([curr_high, curr_open, curr_close]));
        return this.ins.low.push(_.min([curr_low, curr_open, curr_close]));
      }
    };

    return HeikinAshi;

  })();

  story = (function() {

    function story(story_string, story_price, story_count) {
      this.story_string = story_string;
      this.story_price = story_price;
      this.story_count = story_count;
    }

    story.prototype.current = function() {
      var c;
      c = {
        story_indicator: this.story_indicator,
        story_price: this.story_price,
        story_count: this.story_count
      };
      return c;
    };

    return story;

  })();

  ({
    init: function(context) {
      context.pair = 'btc_usd';
      context.init = false;
      context.buy_treshold = 0.25;
      context.sell_treshold = 0.25;
      context.stoploss = 0.0;
      context.close = 2;
      context.trade_mini = 0.0;
      context.tradeNo = 0.0;
      context.price = 0.0;
      context.vol = 0.0;
      context.takeProfit = 0.0;
      context.tf = 0.0;
      context.newhighmode = false;
      context.high = 800;
      context.low = 700;
      context.trade = [];
      context.lastshorter = 999999;
      context.trend = '';
      context.high = 0;
      return context.low = 0;
    },
    handle: function(context, data) {
      var aroon, btc_have, diff_h_l, fiat_have, i, ihigh, ilow, instrument, kumo_max, kumo_min, l, macd, rsi, sar, tenkan_max, tenkan_min, tk_diff, trend;
      instrument = data[context.pair];
      fiat_have = portfolio.positions[instrument.curr()].amount;
      btc_have = portfolio.positions[instrument.asset()].amount;
      ihigh = instrument.high[instrument.high.length - 1];
      ilow = instrument.low[instrument.low.length - 1];
      if (ihigh >= H) {
        context.high = ihigh;
      }
      if (ilow <= L) {
        context.low = ilow;
      }
      if ((instrument.price - short) < 0) {
        trend = 'down';
      } else {
        trend = 'up';
      }
      tk_diff = Math.abs(Functions.diff(c.tenkan, c.kijun));
      tenkan_min = _.min([c.tenkan, c.kijun]);
      tenkan_max = _.max([c.tenkan, c.kijun]);
      kumo_min = _.min([c.senkou_a, c.senkou_b]);
      kumo_max = _.max([c.senkou_a, c.senkou_b]);
      if (context.enable_ha) {
        sar = Functions.sar(context.ha.ins.high, context.ha.ins.low, config.sar_accel, config.sar_max);
      } else {
        sar = Functions.sar(instrument.high, instrument.low, config.sar_accel, config.sar_max);
      }
      if (context.enable_ha) {
        aroon = Functions.aroon(context.ha.ins.high, context.ha.ins.low, config.aroon_period);
      } else {
        aroon = Functions.aroon(instrument.high, instrument.low, config.aroon_period);
      }
      if (context.enable_ha) {
        macd = Functions.macd(context.ha.ins.close, config.macd_fast_period, config.macd_slow_period, config.macd_signal_period);
      } else {
        macd = Functions.macd(instrument.close, config.macd_fast_period, config.macd_slow_period, config.macd_signal_period);
      }
      if (context.enable_ha) {
        rsi = Functions.rsi(context.ha.ins.close, config.rsi_period);
      } else {
        rsi = Functions.rsi(instrument.close, config.rsi_period);
      }
      plot({
        cH: context.high,
        cL: context.low,
        h: H,
        l: L
      });
      for (i in context.trade) {
        if (H > context.high) {
          context.trade[i].csl(context.high, 1);
        }
        if (H < context.high && instrument.price < H) {
          context.trade[i].csl(H, 1);
        }
      }
      for (i in context.trade) {
        l = context.trade[i].current();
        if (instrument.price <= l.tp) {
          debug("Sell: " + l.v + " @ " + l.p + " | Buy : " + (instrument.price.toFixed(2)));
          buy(instrument, l.tpv);
          context.trade.splice(i, 1);
        }
        if (instrument.price >= l.sl) {
          debug("!STOP! Sell: " + l.v + " @ " + l.p + " | Buy : " + (instrument.price.toFixed(2)));
          buy(instrument, l.slv);
          context.trade.splice(i, 1);
        }
      }
      diff_h_l = H - L;
      if (instrument.price + 1 >= context.high && ilow >= H && diff_h_l > 20 && context.high >= H) {
        context.tf = 4;
      }
      if (context.tf > 0) {
        context.tradeNo = context.tradeNo + 1;
        context.vol = btc_have * (context.tf / 10);
        context.price = instrument.price;
        context.trade[context.tradeNo] = new sellTrade(context.tradeNo, context.price, context.vol, context.tf);
        context.trade[context.tradeNo].ctpsl(20, 200);
        return sell(instrument, context.vol);
      }
    }
  });

}).call(this);
