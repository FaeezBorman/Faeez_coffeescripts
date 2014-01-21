#story object.....
class story
  constructor: (@story_string,@story_price,@story_count,@story_averageprice) ->
  run: (@story_price) ->
    this.story_count = this.story_count + 1
    this.story_averageprice = (this.story_averageprice + @storyprice) / 2