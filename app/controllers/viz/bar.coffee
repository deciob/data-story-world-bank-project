Spine = require('spine')
API = require('lib/api')

BarBase = require('controllers/viz/bar_base')


class Bar extends Spine.Controller
  id: "vis-bar"
  name: 'Barchart'
  icon: 'images/hbarchart-icon.png'
  ttitle: "Bar chart"
  template: require('views/viz/bar')
  
  
  constructor: ->
    super
    self = @
    @id_viz = "bar-svg"
    @bar = new BarBase(@id_viz)
    @has_resize = true
    
    
  render: ->
    self = @
    @el.html @template(@)
    if not @bar.is_initialized
      @bar.svg = d3.select("#bar-svg")
      @bar.g = @bar.svg.append("g")
    $('#bar-selection').on('click', (e) -> 
      e.stopPropagation()
      Spine.trigger "bar_sort")
 

  change: () =>
    if @bar.g
      @bar.change(@state)
    
    

module.exports = Bar