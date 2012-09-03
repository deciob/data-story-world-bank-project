Spine = require('spine')
API = require('lib/api')


class Map extends Spine.Controller
  id: "vis-map"
  name: 'Map'
  icon: 'images/map-icon.png'
  template: require('views/viz/map')
  ttitle: "Choropleth map"
  projection: d3.geo.tristanEdwards()

  # These colours will be interpolated between the min and max
  # indicator values on the map.

  # Blue
  #colours: [d3.rgb(136,198,219), d3.rgb(0,81,89)]

  #Green
  colours: [d3.rgb(167,205,101), d3.rgb(14,105,75)]

  #Pink
  #colours: [d3.rgb(245,204,213), d3.rgb(126,60,91)]

  #GeyBlue-Yellow
  #colours: [d3.rgb(88,108,119), d3.rgb(229,189,46)]

  #Blue-Yellow
  #colours: [d3.rgb(0,83,95), d3.rgb(229,189,46)]

  noData: d3.rgb(206,206,206)

  # cache the world GeoJSON
  getWorld: (callback) ->
    if @world
      callback(@world)
    else
      $.getJSON "/static/data/world.json", (@world) => callback(@world)

  # render() is called when the visualisation is switched to. It
  # should overwrite the previous visualisation.
  render: ->
    @el.html @template(@)
    @getWorld (world) =>
      @drawMap(world)

      # 'render' calls 'change' as it requires the map to be loaded.
      @change()

  drawMap: (world) ->
      # Project the corners so we can scale the map to the viewport
      topleft = @projection([-180, 90])
      bottomright = @projection([180, -70])  # -70 cuts off antartica
      size =
        x: topleft[0]
        y: topleft[1]
        w: (bottomright[0] - topleft[0])
        h: (bottomright[1] - topleft[1])

      path = d3.geo.path().projection(@projection)

      @map = d3.select("#map-layer")
        .attr("viewBox", "#{size.x} #{size.y} #{size.w} #{size.h}")
        .selectAll("path")
        .data(world.features)


      # Ugly hover implmentation
      # TODO: cleanup

      popup =
        container: d3.select("#popup-container")
        name: d3.select("#popup-countryname")
        border: d3.select("#popup-border")

      @map.enter().append("path")
        .attr("d", path)
        .attr("stroke", "black")
        .on "mouseover", (f) =>
            return unless @data
            clearTimeout(popup.timeout) if popup.timeout

            bbox = document.getElementById("map-svg").getBBox()
            xscale = d3.scale.linear().domain([topleft[0], bottomright[0]]).range([bbox.x, bbox.width])
            yscale = d3.scale.linear().domain([topleft[1], bottomright[1]]).range([bbox.y, bbox.height])

            xy = path.centroid(f)
            x = xscale(xy[0])
            y = yscale(xy[1])

            value =   d3.round(@data[f.properties.ISO_A2]?.value, 2)
            @markLegend(value)

            popup.container.attr("display", "inline").attr("opacity", 1.0)
            popup.container.attr("transform", "translate(#{x}, #{y})")

            popup.name.text("#{f.properties.NAME}: #{value}")
            textbbox = popup.name.node().getBBox()
            popup.name.attr("y", textbbox.height+10)
            popup.border.attr("width", textbbox.width+20).attr("height", textbbox.height+20)
        .on "mouseout", ->
            fadeOut = ->
                d3.select("#legend-mark").transition().attr("opacity", 0.0).delay(1000)
                popup.container.transition().attr("opacity", 0.0).delay(1000).attr("display", "none")
            clearTimeout(popup.timeout) if popup.timeout
            popup.timeout = setTimeout(fadeOut, 500)


  # change() is called whenever the configuration changes. For
  # example, when an indicator is selected.
  change: =>

    # Return if map hasn't loaded
    return unless @map

    API.loadIndicatorCountries @state.indicator, (data) =>
      max = d3.max(d3.values(data), (d) -> d.value)
      min = d3.min(d3.values(data), (d) -> d.value)

      scale = d3.scale.linear().domain([min, max]).nice()
      @legendScale = scale.copy().range([0, 200])
      percentage = scale.copy().range([0, 100])


      # Map the stops to the domain
      upper = percentage.invert(@state.clampedUpperStop())
      lower = percentage.invert(@state.clampedLowerStop())

      colours = [d3.rgb(@state.lowerStopColour), d3.rgb(@state.upperStopColour)]
      colour = scale.copy().domain([lower, upper]).range(colours).clamp(true)

      @updateLegend(percentage, colour)
      @updateTicks(scale)
      @updateFills(data, colour)

  updateLegend: (percentage, colour) ->
    # Set the stops in the legend gradient
    stops = d3.select("#legend-gradient")
      .selectAll("stop")
      .data(colour.domain())

    stops.enter().append("stop")

    stops
      .attr("offset", (v) -> percentage(v) + "%")
      .attr("style", (x) -> "stop-color: #{colour(x)}")

  markLegend: (value) ->
    x = @legendScale(value)
    mark = d3.select("#legend-mark")
    mark.transition()
        .attr("transform", "translate(#{x}, 0)")
        .attr("opacity", 1.0)
        .delay(200)

  updateTicks: (scale) ->
    xpos = scale.copy().range([0, 200])

    ticks = d3.select("#legend-ticks")
      .selectAll("text")
      .data(xpos.ticks(3))

    ticks.exit().remove()

    ticks.enter()
      .append("text")
      .attr("y", 20)
      .attr("font-size", 10)

    ticks
      .text(xpos.tickFormat())
      .attr("x", xpos)
      .attr("transform", (v) -> "rotate(70 #{xpos(v)} 20)")

  updateFills: (@data, colour) ->
    @map.attr "fill", (f) =>
      value = @data[f.properties.ISO_A2]?.value
      return @noData unless value
      colour(value)


module.exports = Map
