Spine = require('spine')
API = require('lib/api')
VizBase = require('controllers/viz/viz_base')
Indicator = require('models/indicator')

class HistoBase extends VizBase
  selected_countries: []  # country codes list
  selected_colours: []  # colours for labels background
  

  constructor: (conf) ->
    super
    self = @
    @factor = .8
    @transition_time = 1000
    @state = conf.state
    @old_style = conf.old_style
    @colourized = false
    Spine.bind "on_reset_country_selector", @resetCountrySelector
    
  
  cleanCountryInfoSticks: () ->
    d3.selectAll('g.country_info').remove()
  
  
  updateCountryInfoSticks: (selector, transition=false) ->
    self = @
    if not transition and selector  # it comes from a multiselect selection...
      @cleanCountryInfoSticks()
      @selected_countries = $(selector).multiselect("getChecked").map( ->
         {country_id: @value, colour: '#000'}
      ).get()
      # updating the viz state with label (country codes) information
      @state.updateAttribute("labelledCountries", self.selected_countries)
      #@recalcTxtBackground()
    else if not transition and not selector  # it comes from a saved snapshot
      @selected_countries = @state.labelledCountries
      @cleanCountryInfoSticks()
    stick_offset = 15
    for obj in @selected_countries
      country = obj.country_id
      c = @current_data[country]
      if c
        conf =
          axis: @x_linear_axis(c.value)
          label: c.name
          value: d3.round(c.value, 0)
          id: "#{country}_info"
          group: "country_info"
          offset: stick_offset
          colour: obj.colour
          country_id: country
        if transition
          @updateInfoStick(conf)
        else
          @setInfoStick(conf)
          stick_offset += 15  
          
          
  limitCountrySelections = (selector) ->
    warning = $('.message')
    if $(selector).multiselect("widget").find("input:checked").length > 10
       warning.addClass("error").removeClass("success")
        .html("You can only check six checkboxes!")
       false
    else
       warning.addClass("success").removeClass("error")
        .html("Check up to six boxes.")
  
  
  updateCountrySelector: (country_ids, country_names, data) ->
    self = @
    country_selector = $('#country_selector').html('')
    for i in [0...country_ids.length]
      option = "<option value=\"#{country_ids[i]}\">#{country_names[i]}</option>"
      country_selector.append(option)
    if country_selector.siblings().length == 0
      country_selector.multiselect(
        noneSelectedText: "Choose up to ten countries"
        selectedText: "# of # selected"
        header: "Choose up to ten countries"
        position: 
          my: 'left bottom'
          at: 'left top'
        click: (e) -> 
          limitCountrySelections(@)
        close: (e) ->
          self.updateCountryInfoSticks(@)
      ).multiselectfilter()
      @country_selector = country_selector
      
      
  resetCountrySelector: (e) =>
    if @country_selector then @country_selector.multiselect('refresh')


  updateTxtBackFromConfig: =>
    self = @
    rects = @svg.selectAll('.country_info > rect')
    labels = {}
    for obj in @state.labelledCountries
      labels[obj.country_id] = obj.colour
    rects
      .each( (d, i) -> 
        rect = d3.select(@)
        rect.style("fill", labels[rect.attr('title')])
      )
      
      
  recalcTxtBackground: (key='black') ->
    self = @
    colours = 
      seq: [d3.rgb(255,145,49), d3.rgb(92,0,0)]
      diverge: [d3.rgb(0,104,55), d3.rgb(165,0,38)]
      black: [d3.rgb(0,0,0), d3.rgb(0,0,0)]
    vals = []
    vals.push(@data[c.country_id].value) for c in @selected_countries
    min = d3.min(vals)
    max = d3.max(vals)
    col = colours[key]
    scale = d3.scale.linear().domain([min, max]).range(col)
    for c in @selected_countries
      c.colour = scale(@data[c.country_id].value)
    @state.updateAttribute("labelledCountries", self.selected_countries)
    @updateTxtBackFromConfig()
   
   
  setTxtBackground: (conf) ->
    # subtractions and additions are used to set the panning around the text
    bbox = conf.label.getBBox()
    width = bbox.width 
    height = bbox.height
    if conf.updateWidth
      conf.rect.transition().delay( @transition_time ).duration(500)
        .attr("width", width + 4)
    else
      conf.rect
        .attr("x", conf.x - 3)
        .attr("y", conf.y - height + 1)
        .attr("width", width + 4)
        .attr("height", height + 3)
        .attr("opacity", .8)
        .attr("title", conf.title or "")
      if conf.country then conf.rect.style("fill", conf.colour)
        

  setInfoStick: (conf) ->
    stick_offset = conf.offset or 0
    x = conf.axis + 5
    y = stick_offset + (@offset / 2) * .8
    info_group = @svg.append("g")
      .attr("id", conf.id)
      .attr("class", conf.group or "")
    info_group.append("line")
      .attr("class", "stick")
      .attr("x1", conf.axis)
      .attr("x2", conf.axis)
      .attr("y1", stick_offset + (@offset / 2) * .8 )
      .attr("y2", @outer_height - (@offset / 2) )
      .attr("stroke-width", 1)
    # setting a rectangle as label background 
    # (to be styled after inserting the label)
    rect = info_group.append("rect")
      .attr("class", "back")
    label = info_group.append("text")
      .attr("x", x)
      .attr("y", y)
      #.attr('font-size', 12 * @factor)
      .text("#{conf.label}: " + conf.value)
    conf = 
      country: if conf.group == 'country_info' then true else false
      rect: rect
      label: label[0][0]
      x: x
      y: y
      colour: conf.colour
      title: conf.country_id
    @setTxtBackground(conf)
      
      
  getInfoTransaltion: (new_median, selector) ->
    median = d3.select("##{selector}")
    current_x = median.select('line').attr('x1')
    new_median_x = new_median - current_x
    new_median_x
  
  
  updateInfoStick: (conf) ->
    # this function does 2 things
    # hasndles the transaltion of the stick with new data and 
    # hides sticks without values -- this last bit uses jquery, should maybe use d3
    self = @
    go = ->
      back_conf =
        rect: selection.select('rect')
        label: @
        updateWidth: true
        colour: conf.colour
      self.setTxtBackground(back_conf)
    selection = @t.select("##{conf.id}")
    # TODO: not sure about this for now... updating the config state through
    # adding labels triggers this function without necessity... and fails...
    if not selection[0][0]
      return
    if isNaN(conf.value)
      $(selection[0][0].node).hide()
    else
      $(selection[0][0].node).show().css('opacity', 1)
      selection
        .attr("transform", 
          "translate(" + @getInfoTransaltion(conf.axis, conf.id) + "," + 0 + ")")
      text = selection.select('text')
          .transition()
          .each('end', go)
          .delay( @transition_time / 2 )
          .duration( @transition_time / 2 )
          .attr("opacity", 1)
          .text("#{conf.label}: " + conf.value)
          
          
  # this is the label under the histo
  setUnitMeasure: (unit_measure) ->
    g = @svg.append("g")
    t = g.append('svg:text')
      .attr("class", "histo_unit")
      .attr("y", (@inner_height + @offset / 2) + 35)
      #.attr('font-size', 15 * @factor)
      .text(unit_measure)
    t_w = t.node().getBBox().width / 2
    t.attr("x", @outer_width / 2 - t_w)

  
  updateUnitMeasure: (unit_measure) ->
    t = @svg.select('.histo_unit')
      .text(unit_measure)
    t_w = t.node().getBBox().width / 2
    t.attr("x", @outer_width / 2 - t_w)
      
  
  setYLabel: ->
    x = 9
    y = (@inner_height + @offset / 2) * 1
    g = @svg.append("g")
    t = g.append('svg:text')
      .attr("class", "histo_ylabel")
      .attr("x", x)
      .attr("y", y)
      #.attr('font-size', 15 * @factor)
      .text('Number of Countries')
      # rotates 90 degrees counter-clockwise with the center of rotation at x,y
      .attr("transform", "rotate(-90 #{x},#{y})")
    t_w = t.node().getBBox().width / 2
    t.attr("x", @inner_height / 2 - t_w)
 
   
  change: (state, resize=false) =>
    API.loadIndicator state.indicator, (data) =>
      if not @old_style
        @setDimensions2()
      @data = data

      if resize  # currently not used
        $('#histo-svg').children().remove()

      self = @
      @current_data = data

      data_split = @getDataVals(data, countries=true)
      data_vals = data_split[0]
      country_ids = data_split[1]
      country_names = data_split[2]
      
      @updateCountrySelector(country_ids, country_names, data)
      
      max_data = d3.max(data_vals)
      @max_data = max_data
      x_tiks = if max_data > 10000 then 3 else 5

      histogram = d3.layout.histogram().bins(10).range([0, max_data])(data_vals)

      x_ordinal = d3.scale.ordinal()
        .domain(histogram.map( (d) -> d.x ))
        # rounding up @inner_width so it is consistent with rangeRoundBands 
        .rangeRoundBands([0, Math.ceil(@inner_width)], 0)

      y_linear = d3.scale.linear()
        .domain([0, d3.max(histogram.map( (d) -> d.y ))])
        .range([0, @inner_height])

      y_linear_axis = d3.scale.linear()
        .domain([0, d3.max(histogram.map( (d) -> d.y ))])
        .range([@inner_height, 0])

      x_linear_axis = d3.scale.linear()
        #.domain([0, (d3.max(histogram.map( (d) -> d.x )) )]) # this was a bug!!!!!
        .domain([0, max_data])
        .range([(@offset / 2), @inner_width + (@offset / 2)])
      @x_linear_axis = x_linear_axis


      xAxisMajor = d3.svg.axis().scale(x_linear_axis).ticks(x_tiks)
      yAxis = d3.svg.axis().scale(y_linear_axis)
        .tickSize((@inner_width * 1.05), 3, 0).ticks(5).orient("left")

      median = x_linear_axis(@getMedian(data_vals))
      # for "access to electricity %" this fails: d3.round(@getMedian(data_vals), 2)
      # possible d3 bug?
      median_value = @getMedian(data_vals).toFixed(2) 

      median_conf = 
        axis: median
        label: 'median'
        value: median_value
        id: 'median_info'
        
      ind = Indicator.find(state.indicator)
      @ind = ind
      unit_measure = ind.getUnitMesure()
      #$('.histo_unit').html(unit_measure)

      
      # first check if there is no histogram around...
      if @svg.selectAll('path')[0].length == 0

        @svg.append("g")
          .attr("class", "x axis")
          .attr("transform", "translate(0," + ((@inner_height + (@offset / 1.9)) ) + ")")
          .call(xAxisMajor)

        @svg.append("g")
          .attr("class", "left axis")
          .attr("transform", "translate(" + ( (@offset / 2 + @inner_width) ) + "," + (@offset / 2) + ")")
          .call(yAxis)  

        @svg.selectAll("rect")
          .data(histogram)
        .enter().append("rect")
          .attr("width", x_ordinal.rangeBand())
          .attr("x", (d) -> x_ordinal(d.x) + (self.offset / 2) )
          .attr("y", (d) ->  (self.inner_height + (self.offset / 2)) - y_linear(d.y) )
          .attr("height", (d) ->  y_linear(d.y) )
          
        @setInfoStick(median_conf)
        @setUnitMeasure(unit_measure)
        @setYLabel()
        
        # if there is some saved config for the country labels then update viz
        if @state.labelledCountries.length > 0
          @updateCountryInfoSticks(selector=false, transition=false)
        
      # if a histogram is already there...
      else

        t = @svg.transition().duration(@transition_time)
        t.select(".left.axis").call(yAxis)
        t.select(".x.axis").call(xAxisMajor)
        
        @t = t
        #median_conf['t'] = t
        @updateInfoStick(median_conf)
        @updateCountryInfoSticks(selector=false, transition=true)
        @updateUnitMeasure(unit_measure)

        @svg.selectAll("rect")
          .data(histogram)
        .transition()
          .duration(@transition_time)
          .attr("width", x_ordinal.rangeBand())
          .attr("x", (d) -> x_ordinal(d.x) + (self.offset / 2) )
          .attr("y", (d) ->  (self.inner_height + (self.offset / 2)) - y_linear(d.y) )
          .attr("height", (d) ->  y_linear(d.y) )
          
      # if label colouring in viz-state, use it!
      if @state?.labelledCountriesColours?.length > 0
        @updateTxtBackFromConfig()


  setCountriesInBuckets: (histogram, data, ids) ->
    # Creates a multidimentional array with country ids that match the bucket entries,
    # to be used with the slider when interacting with other visualizations
    #
    # data and ids are sorted,
    # bug: last country id missing !?!
    # improvement: should not loop through the whole of data for every bucket!
    countries_in_buckets = []
    start_val = 0
    lower_right = 0
    for bucket in histogram
      upper_right = bucket.x + bucket.dx  # exclusive
      country_bucket = []
      tmp = 0
      for i in [0..data.length]
        if data[i] < upper_right and data[i] >= lower_right
          country_bucket.push(ids[i])
          tmp += 1
      start_val += tmp
      lower_right = upper_right
      countries_in_buckets.push(country_bucket)
      
      
  setDimensions2: () ->
    # all set setDimensions logic should be re-written. 
    # For now histo-combo calls setDimensions and histo calls setDimensions2
  
    @H = $(window).height()
    canvas_y = if @H > 420 then @H - 330 else 90
    canvas_x = $('#vis-histo').width() * .8
    @outer_width = canvas_x
    @outer_height = canvas_y
    @offset = @outer_width * .21
    @inner_width = @outer_width - @offset
    ih = @outer_height - @offset
    @inner_height = if ih > 60 then ih else 60
    @is_initialized = true
    @svg
      .attr("width", @outer_width)
      .attr("height", @outer_height)



module.exports = HistoBase