Spine = require('spine')
API = require('lib/api')

ParallelBase = require('controllers/viz/parallel_base')
Indicator = require('models/indicator')


class Parallel extends Spine.Controller

  #events:
  #  "click #blowup": "resetViewBox"

  id: "vis-paralells"
  name: 'Paralells'
  icon: 'images/paralells-icon.png'
  ttitle: "Parallel coordinates"
  template: require('views/viz/parallel')


  constructor: ->
    super
    self = @
    parallel_conf =
      state: @state
    @parallel = new ParallelBase(parallel_conf)
    @id_viz = "parallel-svg"
    @has_resize = true
    #$('#blowup').on( 'click', -> self.resetViewBox() )


  render: ->
    @dim_conf = 
      wrapper: "parallel_wrapper"
      svg: "parallel-svg"
      x: -15
      y: 15
    
    @indicators = Indicator.all()
    
    @el.html @template(@)
    if not @parallel.is_initialized 
      @parallel.indicator = Indicator
    @parallel.setIndicatorSelector()
    @parallel.svg = d3.select("#parallel-svg")
    @parallel.setDimensions()
    $('.parallel').hide()
      #.attr("viewBox", "-25 -15 #{@parallel.outer_width + 15} #{@parallel.outer_height + 15}")
    

  change: =>
    @parallel.change(@state)
    



module.exports = Parallel