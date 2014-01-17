#story object.....

class story
  constructor: (@story_string,@story_price,@story_count,@story_averageprice) ->
  current: ->
    c = 
        story_indicator : @story_indicator
        story_price : @story_price
        story_count: @story_count
        story_averageprice : @story_averageprice
    return c
  run: (@story_price) ->
    this.story_count = this.story_count + 1
    this.story_averageprice = (this.story_averageprice + @storyprice) / 2