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