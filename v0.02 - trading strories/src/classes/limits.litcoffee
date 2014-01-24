#limits object.....
class limits
  constructor: (@asset_have,@lvl1_tc,@lvl1_max,@lvl2_tc,@lvl2_max) ->
  set_levels: (@asset) ->
    this.lvl1_max = @asset / 5 #Level 1 trades limited to a 5th of portfoilio
    this.lvl2_max = @asset / 5 #Level 2 trades limited to a 5th of portfoilio
    this.lvl1_tc = 0
    this.lvl2_tc = 0
  get_asset_lvl1 : ->
    #debug "limits : lvl1_max = #{this.lvl1_max}"
    if (this.lvl1_tc * 0.1) <= this.lvl1_max # btc
    #if (this.lvl1_tc * 0.1) <= this.lvl1_max # ghs
    #if (this.lvl1_tc * 0.1) <= this.lvl1_max # ltc
       this.lvl1_tc = this.lvl1_tc + 1
       return 0.1
    else
       return 0
  get_asset_lvl2 : ->
    if (this.lvl2_tc * 0.2) <= this.lvl2_max
       this.lvl2_tc = this.lvl2_tc + 1
       return 0.2
    else
       return 0