Spine = require('spine')
API = require('lib/api')
VizBase = require('controllers/viz/viz_base')
Indicator = require('models/indicator')

class BarBase extends VizBase


  constructor: (svg_id) ->
    super
    @svg_id = svg_id
    @factor = .8
    @transition_time = 1000
    @format = d3.format(",.0f")
    @dataSortOrder = 'asc'
    Spine.bind "bar_sort", @invertSelection
  
  
  setUnitMeasure: (unit_measure) ->
    g = @svg.append("g")
    t = g.append('svg:text')
      .attr("class", "bar_unit")
      .attr("y", -20 )
      #.attr('font-size', 14 * @factor)
      .text(unit_measure)
    t_w = t.node().getBBox().width / 2
    t.attr("x", @W / 2 - t_w - 120)
    
  
  updateUnitMeasure: (unit_measure) ->
    t = @svg.select('.bar_unit')
      .text(unit_measure)
    t_w = t.node().getBBox().width / 2
    t.attr("x", @H / 2 - t_w - 120)

  
  change: (state, resize=false) =>
    API.loadIndicator state.indicator, (json) =>
      self = @
      @setDimensions()
      @state = state
      @current_data = json
      data = @getCountryData(@current_data)
      # Sort by value and pick first 15
      data.sort( (a, b) -> return b.value - a.value)
      # if sort direction in state then use it!
      if state?.dataSortOrder then @dataSortOrder = state.dataSortOrder
      data = if @dataSortOrder == 'desc' then data.reverse()[0...15] else data[0...15]
      max_data = data[0].value
      x_tiks = if max_data > 10000 then 2 else 5
      @xAxis.ticks(x_tiks)
      # Set the scale domain.
      @x.domain([0, d3.max(data, (d) -> return d.value )])
      @y.domain(data.map((d) -> return self.truncText(d.name, 16) ))
      ind = Indicator.find(state.indicator)
      unit_measure = ind.name
      
      # first check if there is no histogram around...
      if @g.selectAll('path')[0].length == 0
      
        @bar = @g.selectAll("g.bar")
            .data(data)
          .enter().append("g")
            .attr("class", "bar")
            .attr("transform", (d) -> 
              return "translate(0," + self.y(self.truncText(d.name, 16)) + ")" )
        @bar.append("rect")
            .attr("width", (d) -> return self.x(d.value) )
            .attr("height", self.y.rangeBand())
        @bar.append("text")
          .attr("class", "value")
          .attr("x", (d) -> return self.x(d.value) )
          .attr("y", self.y.rangeBand() / 2)
          .attr("dx", -3)
          .attr("dy", ".35em")
          .attr("text-anchor", "end")
          .text((d) -> return self.format(d.value))
        @g.append("g")
            .attr("class", "x axis")
            .call(self.xAxis)
        @g.append("g")
            .attr("class", "y axis")
            .call(self.yAxis)

      else

        @g.selectAll("rect")
          .data(data)
        .transition()
          .duration(@transition_time)
          .attr("width", (d) -> return self.x(d.value) )
          .attr("height", (d) ->
            self.y.rangeBand()
            return self.y.rangeBand()
          )       
        @g.selectAll("text.value")
          .data(data) 
          .attr("x", (d) -> return self.x(d.value) )
          .attr("y", self.y.rangeBand() / 2)
          .text((d) -> return self.format(d.value))         
        @g.selectAll("g.bar")
          .data(data) 
          .attr("transform", (d) -> 
            return "translate(0," + self.y(self.truncText(d.name, 16)) + ")" )
        t = @svg.transition().duration(@transition_time)       
        t.select("g.x.axis")
            .call(self.xAxis)
        t.select("g.y.axis")
            .call(self.yAxis)
         
        
  invertSelection: =>
    if @dataSortOrder == 'desc'
      @dataSortOrder = 'asc'
      $('#bar-selection-info').html('First 15 countries')
      $('#bar-selection').addClass('btn-blue').removeClass('btn-green')
    else 
      @dataSortOrder = 'desc'
      $('#bar-selection-info').html('Last 15 countries')
      $('#bar-selection').addClass('btn-green').removeClass('btn-blue')
    @state.updateAttribute("dataSortOrder", @dataSortOrder)
    @change(@state)
    
    
  setDimensions: () ->
      @H = $(window).height()
      canvas_y = if @H > 420 then @H - 330 else 90 #@H - 300
      canvas_x = $('#vis-bar').width() * .8    
      m = [30, 10, 10, 100]
      w = canvas_x - m[1] - m[3]
      h = canvas_y - m[0] - m[2]
      @x = d3.scale.linear().range([0, w])
      @y = d3.scale.ordinal().rangeRoundBands([0, h], .1)
      @xAxis = d3.svg.axis().scale(@x).orient("top").tickSize(-h)
      @yAxis = d3.svg.axis().scale(@y).orient("left").tickSize(0)    
      @svg
        .attr("width", w + m[1] + m[3])
        .attr("height", h + m[0] + m[2])
      @g
        .attr("transform", "translate(" + m[3] + "," + m[0] + ")")
      
    

module.exports = BarBase