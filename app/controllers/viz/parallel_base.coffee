Spine = require('spine')
API = require('lib/api')
VizBase = require('controllers/viz/viz_base')
Indicator = require('models/indicator')

class ParallelBase extends VizBase
  
  constructor: (conf) ->
    super
    @state = conf.state
    #@indicators = Indicator.all()
    @data_structure = []
    @data = false
    
    
#  setDimensions: (conf) ->
#    super
#    @x = d3.scale.ordinal().rangePoints([0, @outer_width], 1)
#    @y = {}
  
  
  buildDataBlock: (indicator, data) =>
    # example:
    # Object:
    #  Forest area (% of land area): 53.9401736892892
    #  Forest area (sq. km): 33540
    x = {}
    xx = {}
    for k, d of data
      x[k] = d.value
    xx[indicator] = x
    return xx
    
    
  validateDataBlock: (block, code, val) ->
    for obj in @data_structure[1...@data_structure.length]
      for comp_ind, comp_vals of obj
        if comp_vals[code]
          name = @indicator.find(comp_ind).id #@truncText(
          block[name] = comp_vals[code]
        else
          return
    return block
      
    
  filterData: =>
    # for every selected indicator part of the parallel viz
    # we pick only those countries with data across all indicators
    parallel_data = []
    for ref_ind, country_vals of @data_structure[0]
      for code, val of country_vals
        block = {}
        block[@indicator.find(ref_ind).id] = val
        block = @validateDataBlock(block, code, val)
        if block then parallel_data.push(block)
    parallel_data
    
  
  getDataDimensions: ->
    dimensions = []
    for ind in @selected
      dimensions.push(@indicator.find(ind).id) #@truncText
    dimensions
  
  
  updateState: ->
    data = @filterData()
    @state.updateAttribute("parallelData", data)
    
#    if @data
#      data = @data
#    else
#      data = @filterData()
#      # updating the viz state with data information
#      @state.updateAttribute("parallelData", data)
#      #@data = data
  
  
  buildData: (selector) ->
    self = @
    s = $(selector).multiselect("getChecked")
    @selected = s.map( -> @value).get()
    @dimensions = @getDataDimensions()
    @state.updateAttribute("parallelDimensions", self.dimensions)    
    counter = 0
    buildDataStructure = =>
      indicator = @selected[counter]
      API.loadIndicator indicator, (data) =>
        d = @buildDataBlock(indicator, data)
        @data_structure.push(d)
        if counter == @selected.length - 1
          #@startViz()
          @updateState()
        else
          counter += 1
          buildDataStructure()
    buildDataStructure()
       
  
  setIndicatorSelector: () ->
    self = @
    ind_selector = $('#ind_selector')#.html('')
    # initializing jquery multiselect
    if ind_selector.siblings().length == 0
    
      ind_selector.multiselect(
        header: "Select indicators"
        selectedText: "# of # selected"
        noneSelectedText: "Select indicators"
        position: 
          my: 'left bottom'
          at: 'left top'
        click: (e) -> 
          #limitCountrySelections(@) TODO?
        close: (e) ->
          $('.parallel_tip').hide()
          # removing existing visualization
          self.svg.selectAll('g').remove()
          $('#parallel_loader').show()
          # building new visualization. TODO: this takes some time!
          self.buildData(@)
          $('.parallel').show()
      ).multiselectfilter()
  
  
  change: (state) =>
    API.loadIndicator state.indicator, (data) =>
      
      if state.parallelData
        $('#parallel-svg').show()
        @data = state.parallelData
        # removing existing visualization
        @svg?.selectAll('g').remove()
        $('.parallel_tip').hide()
        @startViz()
       
       
  startViz: ->
    self = @
    @setDimensions()
    line = d3.svg.line()
    axis = d3.svg.axis().orient("left")
    
    master_label = $('#parallell_main_label')
    
    data = @state.parallelData
    dimensions = @dimensions or @state.parallelDimensions
  
    path = (d) ->
      # Returns the path for a given data point.
      return line(dimensions.map((p) -> return [self.x(p), self.y[p](d[p])] ))
      
    brush = ->
      # Handles a brush event, toggling the display of foreground lines.
      actives = dimensions.filter( (p) -> 
        return not self.y[p].brush.empty() )
      extents = actives.map((p) -> return self.y[p].brush.extent() )
      self.foreground.style("display", (d) -> 
        return if actives.every( (p, i) ->
          condition = if ( (extents[i][0] <= d[p]) and (d[p] <= extents[i][1]) ) then null else "none"
          return condition
        ) then "none" else null
      )
    
    # we have the data, here starts the viz
    @x.domain(dimensions)
    for d in dimensions
      @y[d] = d3.scale.linear()
        .domain(d3.extent(data, (p) -> return +p[d] ))
        .range([@outer_height - 100, 100])
          
    # Add grey background lines for context.
    background = @svg.append("g")
      .attr("class", "background")
    .selectAll("path")
      .data(data)
    .enter().append("path")
      .attr("d", path)

    # Add blue foreground lines for focus.
    @foreground = @svg.append("g")
      .attr("class", "foreground")
    .selectAll("path")
      .data(data)
    .enter().append("path")
      .attr("d", path)

    # Add a group element for each dimension.
    g = @svg.selectAll(".dimension")
      .data(dimensions)
    .enter().append("g")
      .attr("class", "dimension")
      .attr("transform", (d) -> return "translate(" + self.x(d) + ")" )

    # Add an axis and title.
    g.append("g")
      .attr("class", "axis")
      .each( (d) -> d3.select(@).call(axis.scale(self.y[d])) )
    .append("text")
      .attr("id", (d, i) -> 
        "parallell_#{d}"
      )
      .attr("text-anchor", "middle")
      .attr("fill", "#555")
      .attr("y", (d, i) -> 
        if i%2 == 0 and dimensions.length > 2
          70
        else
          85
      )
      .on("mouseover", (d, i) ->
        name = Indicator.find(d).name
        master_label.html(name)
        d3.selectAll('.active_parallell')
          .attr('stroke', '')
          .classed('active_parallell', false)
        d3.select(@)
          .attr('stroke', '#00B3D8')
          .attr('stroke-width', .6)
          .attr('class', 'active_parallell')
      )
      
      .text(String) #???

    # Add and store a brush for each axis.
    g.append("g")
      .attr("class", "brush")
      .each( (d) -> d3.select(@).call(self.y[d].brush = d3.svg.brush().y(self.y[d])
        .on("brush", brush)) )
    .selectAll("rect")
      .attr("x", -8)
      .attr("width", 16)
      
    $('#parallel_loader').hide()
    
    
  setDimensions: () ->
    # all set setDimensions logic should be re-written. 
    # For now histo-combo calls setDimensions and histo calls setDimensions2
    
    @H = $(window).height()
    canvas_y = if @H > 260 then @H - 260 else 220
    canvas_x = $('#vis-paralells').width() * .8
    @outer_width = canvas_x
    @outer_height = canvas_y
    @offset = @outer_width * .31
    @inner_width = @outer_width - @offset
    ih = @outer_height - @offset
    @inner_height = if ih > 60 then ih else 60
    @is_initialized = true
    @svg
      .attr("width", @outer_width)
      .attr("height", @outer_height)
    @x = d3.scale.ordinal().rangePoints([0, @outer_width], 1)
    @y = {}
    


module.exports = ParallelBase