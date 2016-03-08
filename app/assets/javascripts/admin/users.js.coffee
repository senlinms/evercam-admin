users_table = undefined
page_load = true

sendAJAXRequest = (settings) ->
  token = $('meta[name="csrf-token"]')
  if token.size() > 0
    headers =
      "X-CSRF-Token": token.attr("content")
    settings.headers = headers
  xhrRequestChangeMonth = jQuery.ajax(settings)
  true

initializeDataTable = ->
  users_table = new Datatable
  headers = undefined
  token = $('meta[name="csrf-token"]')

  if token.size() > 0
    headers = 'X-CSRF-Token': token.attr('content')

  users_table.init
    src: $('#users_datatables')
    onSuccess: (grid) ->
      # execute some code after table records loaded
      return
    onError: (grid) ->
      # execute some code on network or other general error
      return
    onDataLoad: (grid) ->
      # do something
      return
    loadingMessage: 'Loading...'
    dataTable:
      'bStateSave': false
      'lengthMenu': [
        [ 25, 50, 100, 150 ]
        [ 25, 50, 100, 150 ]
      ]
      'pageLength': 50
      'ajax':
        'method': 'GET'
        'headers': headers
        'url': '/load_users'
      columns: [
        {data: "0" },
        {data: "1", "render": linkUser },
        {data: "2" },
        {data: "3" },
        {data: "4" },
        {data: "5", "render": cameraLink },
        {data: "6" },
        {data: "7", "sType": "uk_datetime" },
        {data: "8", visible: false },
        {data: "9" }
      ],
      'order': [ ],
      initComplete: ->
        $('#user-list-row').removeClass 'hide'

columnsDropdown = ->
  $(".users-column").on "click", ->
    column = users_table.getDataTable().column($(this).attr("data-val"))
    column.visible !column.visible()

searchFilter = ->
  $('.table-group-action-input').on "keyup", ->
    console.log "hi"
    action = $('.table-group-action-input').val()
    users_table.setAjaxParam 'username', action
    users_table.setAjaxParam 'email', action
    users_table.getDataTable().ajax.reload()
    users_table.clearAjaxParams()
    return

appendMe = ->
  div = '<div class="dropdown-checklist" id="div-dropdown-checklist">'
  div += '<div href="#" class="btn btn-default grey" data-toggle="modal" data-target="#toggle-datatable-columns">'
  div +=  '<i class="fa fa-columns"></i>'
  div += '</div>'
  div +='</div>'
  $("#users_datatables_wrapper").before(div)
  $("#div-dropdown-checklist").addClass("box-button").addClass("user-box-m")
  $(".users-f > input").addClass("label-color")
  $(".dataTables_info").css("display", "none")
  $(".dataTables_length > label").css("display", "none")
  $("#users_datatables_paginate > .pagination-panel").css("display", "none")

fnShowHide = (iCol, oTable) ->
  bVis = oTable.fnSettings().aoColumns[iCol].bVisible
  oTable.fnSetColumnVis iCol, if bVis then false else true

linkUser = (name, type, row) ->
  return "<a href='/users/#{row[10]}'>#{name}</a>"

cameraLink = (name, type, row) ->
  return "<a href='/users/#{row[10]}#tab_1_12'>#{name}</>"

window.initializeusers = ->
  initializeDataTable()
  columnsDropdown()
  appendMe()
  searchFilter()
