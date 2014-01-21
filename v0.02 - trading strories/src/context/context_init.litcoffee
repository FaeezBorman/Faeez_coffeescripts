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
    context.trade = []
    context.lastshorter = 999999
    context.enable_ha
    context.config_bear = new Config(0.1, 0.3, 0.3, 2.4, 0.025, 0.2, 10, 20, 14, 22, 9, 0, 1, 20, 52, 48)