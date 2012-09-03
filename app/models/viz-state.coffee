Spine = require('spine')

# The current state of the visualisation. There should only ever be
# one of these for the app.
#
# The properties should be things users can change, and are shared
# between all visualisations.

class VisualisationState extends Spine.Model
  @configure "VisualisationState",
    "name",
    "controllerId",  # Current visualisation controller
    "indicator",  # Current indicator id

    "upperStop",  # Upper percentage map stop
    "lowerStop",  # Lower percentage map stop
    "upperStopColour",
    "lowerStopColour",

    "labelledCountries"  # An array of country codes
    "parallelData"  # data useed in the parallel visualization
    "parallelDimensions"
    "dataSortOrder"  # used in the bar visualization
    "annotation"

  @defaults:
      name: 'Untitled'
      controllerId: 'vis-map'
      indicator: 'AG.LND.AGRI.ZS'

      lowerStop: 0.0
      upperStop: 100.0
      lowerStopColour: d3.rgb(167,205,101).toString()
      upperStopColour: d3.rgb(14,105,75).toString()

      labelledCountries: []
      annotation: ""

  clampedUpperStop: -> Math.min(100, Math.max(0, @upperStop))
  clampedLowerStop: -> Math.min(100, Math.max(0, @lowerStop))

  # Replace all attributes whilst preserving id. Uses default value if
  # none exists.  Fixes id bug with 'updateAttributes'
  replace: (atts) ->
    for key in @constructor.attributes
      @[key] = atts?[key] or @constructor.defaults[key]
    @save()


module.exports = VisualisationState
