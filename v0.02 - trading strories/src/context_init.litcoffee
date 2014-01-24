# Initialization method called before a simulation starts. 
# Context object holds script data and will be passed to 'handle' method. 
init: (context)->
    context.pair = 'btc_usd' 
    #context.pair = 'ghs_btc' # ghs
    #context.pair = 'ltc_usd' # ltc

    # STORY VARIABLES
    # STORY INDICES
    context.trend = ''
    context.downfromlast = false
    context.upfromlast = false
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
    context.profitline = 800 # ghs: 0.044 ltc: 23
    context.enable_ha = false
    context.last_sar = 999 # ghs: 0.045 ltc : 25
    context.last_price = 0
    context.config = new Config(0.1, 0.3, 0.3, 2.4, 0.025, 0.2, 10, 20, 14, 22, 9, 0, 1, 20, 52, 48)
    context.limits = new limits