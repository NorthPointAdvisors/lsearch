$ = jQuery

class LogEntry
  constructor: (object) ->
    for name, value of object
      @[name] = value
  extraLine:   (name, text) ->
    return "" if typeof(text) == 'function'
    label = ""
    switch name
      when 'time'
        icon = "time"
        text = text.substr(0, 19)
      when "box"
        icon = "list-alt"
      when "pid"
        icon = "cog"
      when "app"
        icon = "home"
      when "cls"
        icon = "th"
      when "spr"
        icon = "th-large"
      when "mth"
        icon = "map-marker"
      when "fil"
        icon = "file"
      when "lin"
        icon = "tint"

      when "line", "original"
        icon = ""
      when "tyr", "tmo", "tdy", "thr", "tmn", "tsc", "tsu"
        icon = ""

      else
        icon = "tag"
        label = name

    if icon == "" || text == ""
      res = ""
    else
      escaped_text = Handlebars.Utils.escapeExpression text
      if label == ""
        res = "<div class=\"lbl\"><span><i class=\"icon-#{icon}\"></i></span> #{escaped_text}</div>"
      else
        res = "<div class=\"lbl\"><span class=\"txt\"><i class=\"icon-#{icon}\"></i> #{label}</span> #{escaped_text}</div>"
    res
  extraHtml: ->
    html = ''
    for name, value of @
      html += @extraLine name, value
    html
  toHtml: ->
    Handlebars.templates.result @

class Summary

  constructor: (object) ->
    @reset()
    for name, value of object
      @[name] = value

  reset: ->
    @app_name = ''
    @date_str = ''
    @count = 0
    @limit = null
    @offset = 0
    @size = null
    @searchCount = 0

  canDoMore: ->
    if @size && @offset > 0
      @offset < @size
    else
      false

  percent: ->
    if @size && @offset >= 0
      @offset / @size * 100
    else
      false

  percentStr: ->
    if @percent()
      @percent().toFixed(2) + " %"
    else
      "N/A"

  percentInt: ->
    if @percent()
      @percent().toFixed(0)
    else
      "0"

  render: ->
    $('#summary').html @toHtml()

  update:      (data) ->
    @app_name = data.app_name
    @date_str = data.date_str
    @count += data.count
    @limit = data.limit
    @offset = data.offset
    @size = data.size
    @searchCount += 1
    @render()

  toHtml: ->
    Handlebars.templates.summary @

App =

  summary: new Summary

  getNames: ->
    $.getJSON "/app_names",
      ajax: "true", (data) ->
        options = ""
        options += "<option>#{option}</option>" for option in data
        $("#app-name").html options

  getDates: ->
    $.getJSON "/dates",
      ajax: "true", (data) ->
        options = ""
        options += "<option>#{option}</option>" for option in data
        $("#date-str").html options

  compileTemplates: ->
    Handlebars.templates ?= {}
    names = ['summary', 'results', 'result', 'searching', 'noresults', 'error']
    for name in names
      tplId = "##{name}-template"
      html   = $(tplId).html()
      template = Handlebars.compile html
      Handlebars.templates[name] = template
    Handlebars.templates

  searchButton: ->
    $('#search-btn')

  setButtons: ->
    @searchButton().button()

  spin: ->
    @searchButton().button('loading')

  stopSpin: ->
    @searchButton().button('reset')

  searchSuccess: (data, code, xhr) ->
    @summary.update data
    @stopSpin()
    if data.count > 0
      context =
        lines: for object in data.lines
          new LogEntry(object)
      $('#results').append Handlebars.templates.results(context)
      if @summary.canDoMore() && !@stopped
        @search false
      else
        @
    else
      $('#results').html Handlebars.templates.no_results({})

  searchError: (xhr, code, e) ->
    context =
      xhr: xhr
      code: code
      e: e
    $('#results').html Handlebars.templates.results(context)

  search: (reset = true) ->
    @spin()
    if reset
      @summary.reset()
      @summary.render()
      $('#results').html ''
    self = this
    $.ajax
      url: "/grep/#{$("#app-name").val()}"
      dataType: "json"
      context: this
      data:
        date:   $("#date-str").val()
        offset: @summary.offset
        main:   $("#q-main").val()
      success: @searchSuccess
      error: @searchError

  bindOptions: ->
    self = @
    $("#auto-scroll").bind "change", ->
      self.autoScroll @checked
    $("#auto-scroll").attr("checked", true).trigger "change"

    $("#auto-meta").bind "change", ->
      self.autoMetaData @checked
    $("#auto-meta").attr "checked", true

    $("#auto-continue").bind "change", ->
      self.autoContinue @checked
    $("#auto-continue").attr "checked", !@stopped

  autoScroll: (enabled) ->
    if enabled is true
      return  if @scroll_fnId
      window._currPos = 0
      @scroll_fnId = setInterval(->
        if window._currPos < document.height
          window.scrollTo 0, document.height
          window._currPos = document.height
      , 100)
    else
      return  unless @scroll_fnId
      if @scroll_fnId
        clearInterval @scroll_fnId
        window._currPost = 0
        @scroll_fnId = null

  autoMetaData: (enabled) ->
    if enabled is true
      $("#results div.line div.extra").show()
    else
      $("#results div.line div.extra").hide()

  autoContinue: (enabled) ->
    if enabled is true
      @stopped = false
      @search(false) if @summary.canDoMore()
    else
      @stopped = true

  stopped: true

  setup: ->
    @compileTemplates()
    @summary.reset()
    @bindOptions()
    @setButtons()


window.App = App
window.LogEntry = LogEntry

$ ->
  App.setup()
  App.getNames()
  App.getDates()

  $("#search-btn").click (event) ->
    event.preventDefault()
    App.search true
