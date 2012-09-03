Spine = require('spine')
API = require('lib/api')

PieBase = require('controllers/viz/pie_base')


class Pie extends Spine.Controller
  id: "vis-pie"
  name: 'Piechart'
  icon: 'images/piechart-icon.png'
  ttitle: "Pie chart"
  template: require('views/viz/pie')
  events:
    'click button': 'click'
  elements:
    '.svg-title': 'title'
    
  constructor: ->
    super
    @pie = new PieBase('pie1-svg')
    
  click: (e) ->
    item = $(e.currentTarget).attr('value')
    @pie.drawPie(@pie.groups[item])

  render: ->
    @el.html @template(@)
    @pie.setDimensions()
    
  change: () =>
    @pie.change(@state)
    
    
    

module.exports = Pie