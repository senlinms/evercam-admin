cameras_table = undefined
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
  cameras_table = new Datatable
  headers = undefined
  token = $('meta[name="csrf-token"]')

  if token.size() > 0
    headers = 'X-CSRF-Token': token.attr('content')

  cameras_table.init
    src: $('#cameras_datatables')
    onSuccess: (grid) ->
      # execute some code after table records loaded
      return
    onError: (grid) ->
      # execute some code on network or other general error
      return
    onDataLoad: (grid) ->
      #do something
    dataTable:
      'bStateSave': false
      'lengthMenu': [
        [ 25, 50, 100, 150 ]
        [ 25, 50, 100, 150 ]
      ]
      'pageLength': 50
      'processing': true
      'language': 'processing': '<img src="/assets/loading.gif">'
      'ajax':
        'method': 'GET'
        'headers': headers
        'url': '/load_cameras'
      columns: [
        {data: "0", "render": linkCamera },
        {data: "1", "render": linkOwner },
        {data: "2" },
        {data: "3" },
        {data: "4" },
        {data: "5" },
        {data: "6" },
        {data: "7" },
        {data: "8" },
        {data: "9" },
        {data: "10" },
        {data: "11" },
        {data: "12", "render": colorStatus },
        {data: "13", "sType": "uk_datetime" },
        {data: "14", visible: false }
      ],
      initComplete: ->
        # execute some code on network or other general error

searchFilter = ->
  $('.table-group-action-input').on "keyup", ->
    action = $('.table-group-action-input').val()
    cameras_table.setAjaxParam 'fquery', action
    cameras_table.getDataTable().ajax.reload()
    cameras_table.clearAjaxParams()
    return

columnsDropdown = ->
  $(".cameras-column").on "click", ->
    column = cameras_table.getDataTable().column($(this).attr("data-val"))
    column.visible !column.visible()

appendMe = ->
  div = '<div class="dropdown-checklist" id="div-dropdown-checklist">'
  div += '<div href="#" class="btn btn-default grey" data-toggle="modal" data-target="#toggle-datatable-columns">'
  div +=  '<i class="fa fa-columns"></i>'
  div += '</div>'
  div +='</div>'
  $("#cameras_datatables_wrapper").before(div)
  $("#div-dropdown-checklist").addClass("box-button").addClass("user-box-m")
  $(".users-f > input").addClass("label-color")
  $(".dataTables_info").css("display", "none")
  $(".dataTables_length > label").css("display", "none")
  $("#cameras_datatables_paginate > .pagination-panel").css("display", "none")
  $(".paging_bootstrap_extended").css("float","none")

colorStatus = (name) ->
  if name is "true" || name is true
    return "<span style='color: green;'>True</span>"
  else if name is "false" || name is false
    return "<span style='color: red;'>False</span>"

linkCamera = (name, type, row) ->
  if page_load
    return name
  else
    return "<a href='/cameras/#{row[15]}'>#{row[0]}</a>"

linkOwner = (name, type, row) ->
  if page_load
    return name
  else
    return "<a href='/users/#{row[16]}'>#{row[1]}</a>"

showTable = ->
  $(window).load ->
    $('#cameras-list-row').removeClass 'hide'

window.initializeCameras = ->
  columnsDropdown()
  initializeDataTable()
  appendMe()
  showTable()
  searchFilter()
