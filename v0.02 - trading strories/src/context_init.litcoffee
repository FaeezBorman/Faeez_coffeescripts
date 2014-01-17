# Initialization method called before a simulation starts. 
# Context object holds script data and will be passed to 'handle' method. 
init: (context)->
    context.pair = 'btc_usd'
    # STORY VARIABLES
    context.stories[] = new story()
    # STORY INDICES
    context.trend = false

