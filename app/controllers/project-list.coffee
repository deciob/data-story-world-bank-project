Spine = require('spine')
LocalProject = require('models/project').LocalProject
AccountProject = require('models/project').AccountProject

class ProjectEdit extends Spine.Controller
  dialogTemplate: require('views/project-edit')

  render: ->
    @dialog = $(@dialogTemplate(@project))
    @dialog.find("input[type=submit]").click @save
    @dialog.dialog
      width: 600
      height: 420
      title: @project.name
      resizable: false

  save: (e) =>
    e.preventDefault()
    @dialog.dialog("close")
    @project.name = @dialog.find("#project-title").val()
    @project.description = @dialog.find("#project-desc").val()
    @project.save()


class ProjectList extends Spine.Controller
  elements:
    '#local-projects ul.items': 'localItems'
    '#account-projects ul.items': 'accountItems'
    '#new-local-project': 'newLocalProject'
    '#new-account-project': 'newAccountProject'

    '#pages ul.items': 'snapshots'
    '#pages .editable': 'projectEditSection'
    '#share-buttons': 'projectShareButtons'
    '.project-name': 'projectName'
    '#edit-project': 'editProject'
    '#delete-project': 'deleteProject'

  projectTemplate: require('views/project')
  snapshotTemplate: require('views/snapshot')

  constructor: ->
    super
    LocalProject.bind('change refresh', @render)
    LocalProject.fetch()
    AccountProject.bind('change refresh', @render)
    AccountProject.fetch()

    @newLocalProject.click @newLocal
    @newAccountProject.click @newAccount
    @editProject.click @edit
    @deleteProject.click @delete

  render: =>
    @localItems.html @projectTemplate(LocalProject.all())
    @localItems.find("li.item").tipsy(fade: true, gravity: "e")
    @accountItems.html @projectTemplate(AccountProject.all())
    @accountItems.find("li.item").tipsy(fade: true, gravity: "e")

    @select(@selected) if @selected

  select: (@selected) =>
    @project = @selected.project

    # Remove edit controls if project is not editable
    @projectEditSection.toggle(@project?.editable)

    # Remove share buttons if project is not shareable
    @projectShareButtons.toggle(@project?.shareable)

    # clear active
    @localItems.children().removeClass("active")
    @accountItems.children().removeClass("active")

    return unless @project

    @projectName.text(@project.name)

    # Share urls
    name = encodeURIComponent("Data-Story Project: #{@project.name}")
    url = encodeURIComponent(@project.shareURL())
    @projectShareButtons.children('.facebook').attr("href", "http://www.facebook.com/sharer.php?u=#{url}&t=#{name}")
    @projectShareButtons.children('.twitter').attr("href", "https://twitter.com/intent/tweet?text=#{name}&url=#{url}")

    # Set active item
    for items in [@localItems, @accountItems]
      for child in items.children()
        item = $(child).data('item')
        $(child).addClass("active") if item?.id == @project?.id and item?.type == @project?.type

    # Update snapshots list
    tpl = @snapshotTemplate
      project: @project
      page: @selected.page
    @snapshots.html tpl

    # Fire resize event on svg
    Spine.trigger 'svg:blow'

  newLocal: =>
    project = LocalProject.create
      name: "Untitled Project"
      snapshots: []
    @navigate "local", project.id

  newAccount: =>
    project = AccountProject.create
      name: "Untitled Project"
      snapshots: []
    @navigate "account", project.id

  edit: =>
    return unless @project
    edit = new ProjectEdit(project: @project)
    edit.render()

  delete: =>
    return unless @project
    if confirm("Delete project?")
      project = @project
      @navigate ""
      project.destroy()



module.exports = ProjectList
