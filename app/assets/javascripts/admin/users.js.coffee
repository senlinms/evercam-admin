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
      #do something
    dataTable:
      'bStateSave': false
      'lengthMenu': [
        [ 25, 50, 100, 150 ]
        [ 25, 50, 100, 150 ]
      ]
      'pageLength': 50
      'processing': true
      'serverSide': true
      'language': 'processing': '<img src="/assets/loading.gif">'
      'ajax':
        'method': 'GET'
        'headers': headers
        'url': '/load_users'
      columns: [
        {data: "0" },
        {data: "1", "sClass": "center", "render": linkUser },
        {data: "2" },
        {data: "3" },
        {data: "4" },
        {data: "5", "render": cameraLink, "sClass": "center" },
        {data: "6" },
        {data: "7", "sType": "uk_datetime" },
        {data: "8", visible: false },
        {data: "9" },
        {data: "10", "sClass": "center" },
        {data: "11", "sClass": "center green" },
        {data: "12", "sClass": "center red", "render": removeMinus },
        {data: "13", "sClass": "center" }
      ],
      initComplete: ->
        # execute some code on network or other general error

columnsDropdown = ->
  $(".users-column").on "click", ->
    column = users_table.getDataTable().column($(this).attr("data-val"))
    column.visible !column.visible()

searchFilter = ->
  $('.table-group-action-input, .licence-count, .licence-required, .licence-valid').on "keyup", ->
    action = $('.table-group-action-input').val()
    def = $(".licence-count").val()
    lic_req = $(".licence-required").val()
    lic_valid = $(".licence-valid").val()
    users_table.setAjaxParam 'queryValue', action.replace("'","''")
    users_table.setAjaxParam 'def', def
    users_table.setAjaxParam 'licReq', lic_req 
    users_table.setAjaxParam 'licValid', lic_valid 
    users_table.getDataTable().ajax.reload()
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
  $(".paging_bootstrap_extended").css("float","none")

linkUser = (name, type, row) ->
  return "<div class='link-user'><a class='pull-left' href='/users/#{row[14]}'>#{name}</a><a class='pull-right' href='/users/#{row[14]}' target='_blank'><i class='fa fa-external-link'></i></a></div>"

cameraLink = (name, type, row) ->
  return "<a href='/users/#{row[14]}#tab_1_12'>#{name}</>"

showTable = ->
  $(window).load ->
    $('#user-list-row').removeClass 'hide'

openFilter = ->
  $("#filter-modal, .closing").on "click", ->
    $("#filter-modal-box")
      .toggle("slide", { direction: "right" }, 500)

validateDigit = ->
  intRegex = /^\d+$/
  $('.licence-count').on "keyup", ->
    value = $('.licence-count').val().replace(/^\s\s*/, '').replace(/\s\s*$/, '')
    if !intRegex.test(value)
      $(".licence-count").val("")
      return
  $('.licence-required').on "keyup", ->
    value1 = $('.licence-required').val().replace(/^\s\s*/, '').replace(/\s\s*$/, '')
    if !intRegex.test(value1)
      $('.licence-required').val("")
      return
   $('.licence-valid').on "keyup", ->
    value2 = $('.licence-valid').val().replace(/^\s\s*/, '').replace(/\s\s*$/, '')
    if !intRegex.test(value2)
      $('.licence-valid').val("")
      return

removeMinus = (deficient) ->
  if deficient > 0
    return deficient
  else
    ""

window.initializeusers = ->
  initializeDataTable()
  columnsDropdown()
  appendMe()
  validateDigit()
  searchFilter()
  showTable()
  openFilter()
