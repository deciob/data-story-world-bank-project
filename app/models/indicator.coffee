Spine = require('spine')
API = require('lib/api')

mapAttrs = (ind) ->
  attrs =
    'id': ind.id
    'name': ind.name
    'sourceNote': ind.sourceNote
    'sourceId': ind.source.id
    'sourceValue': ind.source.value
    'sourceOrganization': ind.sourceOrganization
  return attrs


IndicatorLoader =
  extended: ->
    @fetch @loadAPI

  loadAPI: ->
    API.loadIndicators (indicators) =>
      result = (mapAttrs(ind) for ind in indicators)
      @refresh(result or [], clear: true)


class Indicator extends Spine.Model
  @configure "Indicator", "id", "name", "sourceNote", "sourceOrganization", "sourceId", "sourceValue"
  @extend IndicatorLoader

  getUnitMesure: () ->
    begin = @name.indexOf('(') + 1
    end = @name.indexOf(')')
    if begin != -1 and end != -1
      return @name.slice(begin, end)
    else
      return "not found"

  getData: (callback) ->
    API.loadIndicator @id, callback

  getCountriesData: (callback) ->
    API.loadIndicatorCountries @id, callback


module.exports = Indicator
