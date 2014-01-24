# This method is called for each tick
handle: (context, data)->
    instrument = data[context.pair]
    fiat_have = portfolio.positions[instrument.curr()].amount
    btc_have = portfolio.positions[instrument.asset()].amount
    context.limits.set_levels(btc_have)
    context.tf = 0
