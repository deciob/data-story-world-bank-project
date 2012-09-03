Spine = require('spine')
API = require('lib/api')
HistoBase = require('controllers/viz/histo_base')


class Histo extends Spine.Controller
  id: "vis-histo"
  name: 'Histogram'
  icon: 'images/barchart-icon.png'
  ttitle: "Histogram"
  template: require('views/viz/histo')
  selected_countries: []
  
  
  constructor: ->
    super
    @id_viz = "histo-svg"
    histo_conf =
      state: @state
    @histo = new HistoBase(histo_conf)
    @has_resize = true
    
  
  render: ->
    self = @
    dim_conf = 
      wrapper: "histo_wrapper"
      svg: "histo-svg"
      x: 0
      y: 0
    @el.html @template(@)
#    if not @histo.is_initialized
#      @histo.setDimensions(dim_conf)
    @histo.svg = d3.select("#histo-svg")
      #.attr("viewBox", "0 0 #{@histo.outer_width} #{@histo.outer_height}")
    # TODO: cant this be done via spine events and elements?
    $('#colourize_country_labels').children('button').on('click', (e) -> 
      e.stopPropagation()
      self.histo.recalcTxtBackground($(@).attr('value'))
    )
    
  change: (resize=false) =>
    @histo.change(@state, resize)
    if @histo?.ind?.name
      $('h3.svg-title').html(@histo?.ind?.name)
        .attr("title", @histo?.ind?.sourceNote).tipsy()
    
  
  
    
    

module.exports = Histo