Spine = require('spine')


class VisualisationList extends Spine.Controller
  events:
    'click .item': 'click'

  elements:
    'ul.items': 'items'
    '#visualization-widget .visualization-content': 'widgetContent'

  template: require('views/visualisation')

  classList: [
    require('controllers/viz/map'),
    require('controllers/viz/bar'),
    require('controllers/viz/histo_combo'),
    require('controllers/viz/histo'),
    require('controllers/viz/pie'),
    require('controllers/viz/parallel')
    ]

  constructor: ->
    super

    # Create all the visualisations
    @viz = (new v(el: @widgetContent, state: @state) for v in @classList)

    # Quick visualisation lookup by id
    @vizById = {}
    for v in @viz
      @vizById[v.id] = v

    @render()
    @setResize()

  # Render the list
  render: ->
    @items.html @template(@viz)
    @items.find("li.item").tipsy(fade: true, gravity: "w")

  # When a *new* visualisation is selected, set it to 'active' and
  # render it.
  select: (current) =>
    # return if visualisation hasn't changed
    return if current.id == @current?.id

    # Set active item
    @current = current
    @items.children().removeClass('active')
    for child in @items.children()
      $(child).addClass("active") if $(child).data('item')?.id == @current.id

    # Render the visualisation in the widget area
    @current.render()

    # ..and set the id
    @widgetContent.attr("id", @current.id)
    
    

  click: (e) ->
    item = $(e.currentTarget).data('item')
    @select(item)
    @trigger("change", item)
    
    true
    


  setResize: () ->
    # setTimeout is to get this to work in Firefox
    resizeTimer = null
    go = =>
      # TODO: this is obviously a big mess!
      if @current?.has_resize
        @current?.change(true)
    $(window).resize( =>
      clearTimeout(resizeTimer)
      resizeTimer = setTimeout( ( => go('window') ), 200 )
    )
    $('#blowup,#close-snapshot').on( 'click', =>
      resizeTimer = setTimeout( ( => go() ), 200 )
    )
    Spine.bind 'svg:blow', => resizeTimer = setTimeout( ( => go() ), 100 )
      


module.exports = VisualisationList
