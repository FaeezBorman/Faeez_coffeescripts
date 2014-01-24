# This is Cexio GHS bot. It holds GHS and reinvest mined bitcoins 
# into buying more GHS.
# Also, it sells GHS when price goes down and rebuy them when
# price goes up. Also buys when price suddenly drops a sells right
# after.

# It uses limit orders so backtesting wont tell you a lot. I
# suggest to start with something like 0.1 BTC and see if it works
# for you in live trading.

# If you like it, and dont have account on CEXio yet, you can
# sign in through my referral link https://cex.io/r/0/fronema/0/
# you will lose nothing and i will get a little bonus

# Happy trading! Fronema


init: (context) ->
    context.pair = 'ghs_btc'
    context.diffptc = 0.01
    context.maxlast = 30;
    context.emaperiod = 120;
    context.buycounter = 0
    context.sellcounter = 0
    context.sellslope = -0.000003
    context.amountthreshold =  0.0001
    
    
    context.init = true

handle: (context, data)->
# data object provides access to the current candle
    instrument = data.instruments[0]

    ema = instrument.ema(context.emaperiod) 
    results = talib.EMA
        inReal: instrument.close
        startIdx: 0
        endIdx: instrument.close.length - 2
        optInTimePeriod: context.emaperiod
        
    lastema = _.last(results)
    highestLastX = _.max(instrument.high[-context.maxlast..])
    low = Number(instrument.low[-1..])
    high = Number(instrument.high[-1..])
    slope = ema - lastema
    
    if slope > 0 and  portfolio.positions[instrument.curr()].amount > context.amountthreshold
        context.sellcounter = 0
        if buy instrument, null, low, 60
            context.buycounter = 0
        else 
            context.buycounter = context.buycounter + 1
         #   debug "buycounter " + context.buycounter
            if context.buycounter > 10
                if buy instrument
                    context.buycounter = 0

            
    if slope < context.sellslope and portfolio.positions[instrument.asset()].amount > context.amountthreshold
        context.buycounter = 0
        if sell instrument, null, ema, 60
            debug 'balance ' + portfolio.positions[instrument.curr()].amount.toFixed(5)
            context.sellcounter = 0
        else
            context.sellcounter = context.sellcounter + 1
         #   debug "sellcounter " + context.sellcounter
            if context.sellcounter > 10
                if sell instrument
                    context.sellcounter = 0

    if portfolio.positions[instrument.curr()].amount > context.amountthreshold
        if (ema - low) > low * context.diffptc
            if highestLastX > ema
                buy instrument, null, low, 60
    
    plot
        ema: ema
        edge: (ema - (low * context.diffptc))
        highestLastX: highestLastX