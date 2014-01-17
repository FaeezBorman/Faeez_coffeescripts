#sell trade object.....
# (trade number - counts to tatal number of sells executed
#  Price - Price at which sell was executed
#  Vol - Volume of asset thats been sold)
class sellTrade
  constructor: (@tn,@p,@v,@tf,@tp,@sl,@tpv,@slv) ->
  current: ->
    c = 
        tn: @tn
        p: @p
        v: @v
        tf: @tf
        tp: @tp
        sl: @sl
        tpv: @tpv
        slv: @slv
    return c
  ctpsl: (@up,@down) ->
    this.tp = this.p - @down
    this.sl = this.p + @up
    this.tpv = (this.p * this.v)/ this.tp
    this.slv = (this.p * this.v)/ this.sl
  csl: (@cp,@diff) ->
    this.sl = @cp + @diff
    this.slv = (this.p * this.v)/ this.sl
  ctp: (@cp,@diff) ->
    this.tp = @cp * (100 - @difF)/100
    this.tpv = (this.p * this.v)/ this.tpv
  log: ->
    d = "trade number :" + @tn + " at price " + @p + " v: " + @v + " tf: " + @tf + " tp: " + @tp + " sl: " + @sl