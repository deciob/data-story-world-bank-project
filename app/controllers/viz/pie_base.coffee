Spine = require('spine')
API = require('lib/api')
VizBase = require('controllers/viz/viz_base')
Indicator = require('models/indicator')

class PieBase extends VizBase
  
  constructor: (svg_id, font_size=10, label_font_size=12, no_text=false) ->
    super
    @transition_t = 1000
    @color = d3.scale.category20()
    @cutOutAngle = .7
    @fontSize = font_size
    @labelFontSize = label_font_size
    @no_text = no_text
    @svg_id = svg_id
    @groups = {'continents': @continents, 'income_groups': @income_groups}
    

  setDimensions: ->
    @w = $('#pie_wrapper').width() / 2 * .9
    @h = @w + 20
    @r = @w / 2
    @arc = d3.svg.arc().innerRadius(0).outerRadius(@r)
    @pie = d3.layout.pie().value( (d) -> d.value ).sort(null)
   
   
  tweenPie: (b) =>
    self = @
    b.innerRadius = 20;
    i = d3.interpolate({startAngle: 0, endAngle: 0}, b)
    return (t) ->
      return self.arc(i(t))
  
  
  drawText: (data) =>
    self = @
    @text = @pie_group.selectAll("text")
      .data(@pie(data))
    t = @text.enter()
      .append("svg:text")
      .attr("transform", (d) -> "translate(" + self.arc.centroid(d) + ")" )
      .attr('font-size', self.fontSize)
      .attr("dy", ".15em")
      .attr("text-anchor", "middle")
      .attr("display", (d) -> 
        if (d.endAngle - d.startAngle) > self.cutOutAngle
          return "true"
        else
          return "none"
      )
      .text( (d, i) -> self.truncText(d.data.name, 22) )
      #.attr("title", (d, i) -> d.data.name)
    @text.exit().remove()
    
    
  updateText: () ->
    self = @
    @text
      .attr("transform", (d) -> 
        d.innerRadius = 0
        d.outerRadius = self.r
        "translate(" + self.arc.centroid(d) + ")" )
      .attr('font-size', self.fontSize)
      .attr("dy", ".15em")
      .attr("text-anchor", "middle")
      .attr("display", (d) ->
        if (d.endAngle - d.startAngle) > self.cutOutAngle
          return "true"
        else
          return "none"
      )
      .text( (d, i) -> self.truncText(d.data.name, 22) )
      #.attr("title", (d, i) -> d.data.name)
      .attr("opacity", 0.1)
      .transition().duration(@transition_t).attr("opacity", 1)
    

  drawPie: (country_group) ->
    self = @
    data = @getCounGrData(@current_data, country_group)
    jsvg = $("##{@svg_id}") #@el.find('svg').eq(0) # TODO: sort this out!
    not_new = if jsvg.find('path').length > 0 then true else false
    arc = @arc
    
    # Store the currently-displayed angles in this._current.
    # Then, interpolate from this._current to the new angles.
    arcTween = (a) ->
      i = d3.interpolate(@_current, a)
      @_current = i(0) 
      return (t) ->
        return arc(i(t))
    
    svg = d3.select("##{jsvg.attr('id')}")
      .attr("viewBox", "0 0 #{@w} #{@h}")
      .attr("font-family", "'MuseoSlab-500', Arial, serif")
    
    if not not_new
      @pie_group = svg
        .append("svg:g")  #make a group to hold our pie chart
        #move the center of the pie chart from 0, 0 to radius, radius
        .attr("transform", "translate(" + self.r + "," + self.r + ")")
      # setting up the hover selection markup
      @pieSelection = svg
        .append("svg:g")
        .attr("id", "pie_info_gr")
        .append("text")
        .attr("text-anchor", "middle")
        .attr("transform", "translate(#{self.r},#{self.r*2+15})" )
        .attr('font-size', self.labelFontSize)
        .attr('opacity', 0)
      @pieSelection.append('tspan').attr('class', 's_label')
        .attr('fill', '#00B3D8')#.attr('stroke', '#00B3D8').attr('stroke-width', .6) 
      @pieSelection.append('tspan').attr('class', 's_value')
        .attr('fill', '#00B3D8')#.attr('stroke', '#00B3D8').attr('stroke-width', .6) 
        
    set_highligth_feature = (d=false, i=false) ->
      label = if d then "#{d.data.name}: " else ''
      value = if d then Math.round(d.value) else ''
      opacity_in = if d then 1 else 0
      opacity_out = if d then .5 else 1
      t = svg.select("#pie_info_gr")
        .select("text")
      t.select('.s_label').text(label)
      t.select('.s_value').text(value)
      t.transition().duration(self.transition_t/2).attr("opacity", opacity_in)
      #self.text.transition().duration(self.transition_t/2).attr("opacity", opacity_out)
      #self.text.selectAll().attr('opacity', 0)
      
    @arcs = @pie_group.selectAll("path")
      .data(@pie(data))

    g = @arcs.enter()    
      .append("svg:g")
    p = g.append("svg:path")
      .attr("fill", (d, i) -> 
        return self.color(i) )
      .attr("d", @arc)
      .on("mouseover", (d, i) -> set_highligth_feature(d, i) )
      .on("mouseout", (d, i) -> set_highligth_feature() )
      .each( (d) -> @_current = d )
#    t = g.append("title")
#      .text( (d) -> d.data.name )
      
    @drawText(data)
 
    @arcs.exit().remove()

    if not_new
      @arcs = @arcs.data(self.pie(data)) # update the data
      # the condition here is to fix the following problem:
      # I am storing the currently-displayed angles in @_current so they can
      # be interpolated with the new incoming angles in the transition.
      # But this only works if the number of old slices is the same or bigger 
      # than the old. If this is not the case, avoid the transition, 
      # because it will return an error!
      if @slices < data.length
        @arcs.attr("d", @arc) # redraw the arcs, without transition
      else
        @arcs.transition().duration(@transition_t).attrTween("d", arcTween)
      @updateText()
      
    # TODO: do this better!
    if data.length > 0
      $('.no_data_info').hide()
    else
      $('.no_data_info').show()
    @slices = data.length
    
    
  change: (state) =>
    API.loadIndicator state.indicator, (data) =>
      self = @
      @ind = Indicator.find(state.indicator)
      @current_data = data
      @drawPie(@continents)
      
      
module.exports = PieBase