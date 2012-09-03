Spine = require('spine')
API = require('lib/api')

HistoBase = require('controllers/viz/histo_base')
PieBase = require('controllers/viz/pie_base')


class HistoCombo extends Spine.Controller
  id: "vis-histo-combo"
  name: 'Histogram and Piechart'
  icon: 'images/bar-pie-icon.png'
  ttitle: "Histogram with pie chart"
  template: require('views/viz/histo_combo')
  
  
  constructor: ->
    super
    histo_conf =
      state: @state
      old_style: true
    @histo = new HistoBase(histo_conf)
    @pie = new PieBase('pie-svg', font_size=4, label_font_size=6)

  render: ->
    dim_conf = 
      wrapper: "histo_wrapper"
      svg: "histo-svg-combo"
      x: 0
      y: 0
      par: .25
    @el.html @template(@)
    if not @histo.is_initialized 
      @histo.setDimensions(dim_conf) #histo.setDimensions()
      @pie.setDimensions()
    @histo.svg = d3.select("#histo-svg-combo")
      .attr("viewBox", "0 0 #{@histo.outer_width} #{@histo.outer_height}")
    
  change: () =>
    @histo.change(@state)
    @pie.change(@state)
      

module.exports = HistoCombo