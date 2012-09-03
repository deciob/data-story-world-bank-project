Spine = require('spine')

class Project extends Spine.Model
  shareable: false

  addSnapshot: (snap) ->
    @snapshots.push(snap)
    @save()

  hashURL: -> "#{@type}/#{@id}"
  shareURL: -> "http://data-story.org"


class LocalProject extends Project
  @configure "LocalProject", "name", "description", "snapshots"
  @extend Spine.Model.Local
  type: "local"
  editable: true


class AccountProject extends Project
  @configure "AccountProject", "name", "description", "snapshots"
  @extend Spine.Model.Ajax
  @url: "/config/"
  type: "account"
  editable: true
  shareable: true
  shareURL: -> 'http://data-story.org/v1/app#user/' + app.userid + '/' + @id + '/0'


class UserProject extends Project
  @configure "UserProject", "name", "description", "snapshots", "user_id"
  type: "user"
  editable: false
  shareable: true
  hashURL: -> "user/#{@user_id}/#{@id}"
  shareURL: -> 'http://data-story.org/v1/app#' + @hashURL() + '/0'


module.exports =
  LocalProject: LocalProject
  AccountProject: AccountProject
  UserProject: UserProject
