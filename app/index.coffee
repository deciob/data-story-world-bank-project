require('lib/setup')

API = require('lib/api')

Spine = require('spine')
IndicatorList = require('controllers/indicator-list')
VisualisationList = require('controllers/visualisation-list')
ProjectList = require('controllers/project-list')
Config = require('controllers/config')

VisualisationState = require('models/viz-state')
LocalProject = require('models/project').LocalProject
AccountProject = require('models/project').AccountProject
UserProject = require('models/project').UserProject
Indicator = require('models/indicator')

class App extends Spine.Controller
  elements:
    '#indicator-list-widget': 'indicatorSection'
    '#visualization-wrapper': 'vizSection'
    '#project-list-widget': 'projectSection'
    '#add-page-button': 'addPage'
    '#update-page-button': 'updatePage'
    '#project-pages': 'projectPages'
    '#config-accordion': 'configAccordion'
    '.metadata': 'metadata'

    '#snapshot-nav .prev-snapshot': 'navPrev'
    '#snapshot-nav .next-snapshot': 'navNext'

    '#visualization-name .name': 'snapTitle'

  constructor: ->
    super

    # The current state of the visualisation
    @state = new VisualisationState(VisualisationState.defaults)

    @visualisationList = new VisualisationList(el: @vizSection, state: @state)
    @indicatorList = new IndicatorList(el: @indicatorSection)
    @projectList = new ProjectList(el: @projectSection)

    # When an indicator is selected, change the visualisation state
    @indicatorList.bind 'change', (indicator) =>
      @state.updateAttribute('indicator', indicator)
      @indicatorList.updateVizMetadata()  #data source and title on viz

    # When a visualisation is selected, change the visualisation state
    @visualisationList.bind 'change', (vis) =>
      @state.updateAttribute('controllerId', vis.id)

    @config = new Config(el: @configAccordion, state: @state)
    @config.render()

    @state.bind 'change', =>

      # Update selected indicator
      @indicatorList.select(@state.indicator)
      @indicatorList.updateVizMetadata(@state.indicator)  #data source and title on viz

      # Update name
      @snapTitle.html "<span>#{ @state.name }</span>"

      # Update selected visualisation and trigger its 'change' method.
      viz = @visualisationList.vizById[@state.controllerId]
      @visualisationList.select(viz)
      viz.change()
      @metadata.toggle(viz?.id != 'vis-paralells')

      # Update annotation
      @vizSection.find("div.annotation").html(@state.annotation or "Click to edit annotation").removeClass("active")

    @routes
      "/v1/app": =>
        @update(null, null)
      "local/:projectid": (params) =>
        @update(LocalProject.find(params.projectid), null)
      "local/:projectid/:pagenum": (params) =>
        @update(LocalProject.find(params.projectid), params.pagenum)
      "account/:projectid": (params) =>
        @update(AccountProject.find(params.projectid), null)
      "account/:projectid/:pagenum": (params) =>
        @update(AccountProject.find(params.projectid), params.pagenum)
      "user/:userid/:projectid/:pagenum": (params) =>
        $.getJSON "/user/#{params.userid}/#{params.projectid}", (project) =>
          @update(new UserProject(project), params.pagenum)

    # Load indicators
    Indicator.fetch()

    # Trigger first update after indicators have loaded
    Indicator.one "refresh", -> Spine.Route.setup()

    # Take snapshot
    @addPage.click =>
      if @project
        @project.addSnapshot(@state.toJSON())
        @navigate @project.type, @project.id, @project.snapshots.length - 1

    # Update snapshot
    @updatePage.click =>
      if @page isnt null
        @project.snapshots[@page] = @state.toJSON()
        @project.save()
        active = $("#pages li.active").addClass('updated')
        rmclass = -> active.removeClass('updated')
        setTimeout rmclass, 200

    # Navigation
    @navPrev.click (e) =>
      e.preventDefault()
      return unless @project and @page > 0
      @navigate @project.hashURL(), @page - 1
    @navNext.click (e) =>
      e.preventDefault()
      return unless @project and @page < (@project.snapshots.length - 1)
      @navigate @project.hashURL(), @page + 1

    # Edit title
    @snapTitle.delegate "span", "click", =>
      input = $("<input type=\"text\" value=\"#{ @state.name }\" />")
      @snapTitle.html input
      input.focus()
      input.change => @state.updateAttribute('name', input.val())

    # Edit description
    @vizSection.delegate "div.annotation:not(.active)", "click", (e) =>
      annotation = $(e.target)
      input = $("<textarea>#{ @state.annotation }</textarea>")
      annotation.html(input).addClass('active')
      input.focus()
      input.change =>
        annotation.removeClass("active")
        @state.updateAttribute('annotation', input.val())

  update: (@project, page) ->
    @page = if page is null then null else parseInt(page)
    @projectList.select(project: @project, page: @page)
    @projectPages.toggle(@project isnt null)

    if @project isnt null and page isnt null
      # Update nav buttons
      $("#snapshot-nav .prev-snapshot").toggle(@page > 0)
      $("#snapshot-nav .next-snapshot").toggle(@page < @project.snapshots.length - 1)

      @state.replace(@project.snapshots[@page])
    else
      # Just trigger a state change
      @state.save()


module.exports = App
