Spine = require('spine')


class Config extends Spine.Controller
  template: require('views/config')

  constructor: ->
    super
    @state.bind 'change', @change

  render: ->
    @el.html @template()

    @control =
      slider: @$("#stop-slider")
      lower: @$('#lower-colour')
      upper: @$('#upper-colour')

    @control.slider.slider
      range: true
      min: 0
      max: 100
      values: [0, 100]
      slide: (e, ui) =>
        @state.updateAttributes
          lowerStop: ui.values[0]
          upperStop: ui.values[1]

    @el.accordion()

    @createColorPicker(@control.lower, @state, 'lowerStopColour')
    @createColorPicker(@control.upper, @state, 'upperStopColour')

  createColorPicker: (inp, state, attr) ->
    inp.ColorPicker
    	onSubmit: (hsb, hex, rgb, el) ->
            state.updateAttribute(attr, "#" + hex)
            $(el).ColorPickerHide()
        onBeforeShow: ->
            $(this).ColorPickerSetColor(this.value);

  change: =>
    @control.slider.slider("values", 0, @state.lowerStop)
    @control.slider.slider("values", 1, @state.upperStop)

    @control.lower.val(@state.lowerStopColour)
    @control.upper.val(@state.upperStopColour)


module.exports = Config
