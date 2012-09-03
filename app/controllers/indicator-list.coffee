Spine = require('spine')
Indicator = require('models/indicator')

# This controller loads the list of indicators.  When an indicator is
# selected, it loads its data and triggers the 'data-changed' event.
class IndicatorList extends Spine.Controller
  data_cache: {}

  events:
    'click .item': 'click'
    'keyup input[type=search]': 'searchFilter'
    'change input[type=search]': 'searchFilter'
    'search input[type=search]': 'searchFilter'

  elements:
    'ul.items': 'items'
    '#indicator-list-section': 'scrollpane'

  template: require('views/indicator')

  constructor: ->
    super
    Indicator.bind('refresh', @render)

  render: =>
    @indicators = Indicator.all()
    @items.html @template(@indicators)
    @select(@current_id) if @current_id
    @scrollpane.jScrollPane()
   
  # Set the current item to 'active'
  select: (@current_id) =>
    @items.children().removeClass('active')
    for child in @items.children()
      $(child).addClass("active") if $(child).data('item')?.id == @current_id

  click: (e) ->
    item = $(e.currentTarget).data('item')
    @select(item.id)
    @trigger("change", @current_id)
    # every time we change an indicator, we have a different set of countries
    # so updating the country selectors to reflect this
    Spine.trigger("on_reset_country_selector", e)
    true

  # Filter indicators
  searchFilter: (e) ->
    str = $(e.target).val().toLowerCase()
    for i in @items.children()
      $i = $(i)
      $i.toggle($i.data('item').name.toLowerCase().indexOf(str) >= 0)

    # Recalculate scrolling region
    @scrollpane.jScrollPane()
    
  updateVizMetadata: (indicator) ->
    indicator = indicator or @current_id
    @updateVizSource(indicator)
    @updateVizTitle(indicator)

  updateVizSource: (indicator) ->
    if indicator
      ind = Indicator.find(indicator)
      source_value = ind.sourceValue
      source_org = ind.sourceOrganization
      txt = "Source: #{source_value}.<br />Source organization: #{source_org}"
      $('#svg-source').html(txt)
      
  updateVizTitle: (indicator) ->
    if indicator
      ind = Indicator.find(indicator)
      title = ind.name
      description = ind.sourceNote
      $('#svg-title').html(title).attr('title', description).tipsy()
     

module.exports = IndicatorList
