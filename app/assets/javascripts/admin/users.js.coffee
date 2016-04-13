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
      'bAutoWidth': false
      'bStateSave': false
      'lengthMenu': [
        [ 25, 50, 100, 150 ]
        [ 25, 50, 100, 150 ]
      ]
      "order": [[ 10, "desc" ]]
      'pageLength': 60
      'processing': true
      'serverSide': true
      'language': 'processing': '<img src="/assets/loading.gif">'
      'ajax':
        'method': 'GET'
        'headers': headers
        'url': '/load_users'
      columns: [
        {data: "0", "orderable": true, "width": "75px" },
        {data: "1", "render": linkUser, "width": "170px" },
        {data: "2", "width": "150px" },
        {data: "3", "width": "70px" },
        {data: "4", "width": "215px" },
        {data: "5", "width": "120px", "render": cameraLink, "sClass": "center" },
        {data: "6", "width": "120px", "sClass": "center", "render": removeMinus },
        {data: "7", "width": "120px", "sClass": "center", "render": removeMinus },
        {data: "8", "width": "110px" },
        {data: "9", "width": "100px", "sType": "uk_datetime" },
        {data: "10", visible: false },
        {data: "11", "width": "100px" },
        {data: "12", "width": "120px", "sClass": "center" },
        {data: "13", "width": "120px", "sClass": "center green" },
        {data: "14", "width": "120px", "sClass": "center red", "render": removeMinus }
      ],
      initComplete: ->
        # execute some code on network or other general error

columnsDropdown = ->
  $(".users-column").on "click", ->
    column = users_table.getDataTable().column($(this).attr("data-val"))
    column.visible !column.visible()

searchFilter = ->
  $('#username, #email, #fullname, #total_cameras, #licREQ1, #licREQ2, #licVALID1, #licVALID2, #licDEF1, #licDEF2').on "keyup", ->
    username = $("#username").val().replace("'","''")
    fullname = $("#fullname").val().replace("'","''")
    email = $("#email").val().replace("'","''")
    total_cameras = $("#total_cameras").val()
    licREQ1 = $("#licREQ1").val()
    licREQ2 = $("#licREQ2").val()
    licVALID1 = $("#licVALID1").val()
    licVALID2 = $("#licVALID2").val()
    licDEF1 = $("#licDEF1").val()
    licDEF2 = $("#licDEF2").val()
    users_table.setAjaxParam 'username', username
    users_table.setAjaxParam 'fullname', fullname
    users_table.setAjaxParam 'email', email
    users_table.setAjaxParam 'total_cameras', total_cameras
    users_table.setAjaxParam 'licREQ1', licREQ1
    users_table.setAjaxParam 'licREQ2', licREQ2
    users_table.setAjaxParam 'licVALID1', licVALID1
    users_table.setAjaxParam 'licVALID2', licVALID2
    users_table.setAjaxParam 'licDEF1', licDEF1
    users_table.setAjaxParam 'licDEF2', licDEF2
    users_table.getDataTable().ajax.reload()
    return

appendMe = ->
  $("#div-dropdown-checklist").css({"visibility": "visible", "width": "59px", "top": "-41px", "float": "right" })
  $(".dataTables_info").css("display", "none")
  $(".dataTables_length > label").css("display", "none")
  $("#users_datatables_paginate > .pagination-panel").css("display", "none")
  $(".paging_bootstrap_extended").css("float","none")

linkUser = (name, type, row) ->
  return "<div class='link-user'>
            <a class='pull-left u-name' href='/users/#{row[15]}'>#{name}</a>
            <a class='pull-left u-dash' href='#{row[16]}/v1/cameras?api_id=#{row[3]}&api_key=#{row[4]}' target='_blank'><i class='fa fa-external-link'></i></a>
            <div class='pull-left open-intercom' data-username=#{row[0]}><img src='/assets/intercom.png' width='15'></div>
          </div>"

cameraLink = (name, type, row) ->
  return "<a href='/users/#{row[15]}#tab_1_12'>#{name}</a>"

totalCameras = (name, type, row) ->
  return row[6] + row[5]

showTable = ->
  $(window).load ->
    $('#user-list-row').removeClass 'hide'

validateDigit = ->
  intRegex = /^\d+$/
  $('#licREQ1').on "keyup", ->
    value = $('#licREQ1').val().replace(/^\s\s*/, '').replace(/\s\s*$/, '')
    if !intRegex.test(value)
      $("#licREQ1").val("")
      return
  $('#licREQ2').on "keyup", ->
    value1 = $('#licREQ2').val().replace(/^\s\s*/, '').replace(/\s\s*$/, '')
    if !intRegex.test(value1)
      $('#licREQ2').val("")
      return
  $('#licVALID1').on "keyup", ->
    value2 = $('#licVALID1').val().replace(/^\s\s*/, '').replace(/\s\s*$/, '')
    if !intRegex.test(value2)
      $('#licVALID1').val("")
      return
  $('#licVALID2').on "keyup", ->
    value2 = $('#licVALID2').val().replace(/^\s\s*/, '').replace(/\s\s*$/, '')
    if !intRegex.test(value2)
      $('#licVALID2').val("")
      return
  $('#total_cameras').on "keyup", ->
    value2 = $('#total_cameras').val().replace(/^\s\s*/, '').replace(/\s\s*$/, '')
    if !intRegex.test(value2)
      $('#total_cameras').val("")
      return
  $('#licDEF1').on "keyup", ->
    value2 = $('#licDEF1').val().replace(/^\s\s*/, '').replace(/\s\s*$/, '')
    if !intRegex.test(value2)
      $('#licDEF1').val("")
      return
  $('#licDEF2').on "keyup", ->
    value2 = $('#licDEF2').val().replace(/^\s\s*/, '').replace(/\s\s*$/, '')
    if !intRegex.test(value2)
      $('#licDEF2').val("")
      return

removeMinus = (deficient) ->
  if deficient > 0
    return deficient
  else
    ""

clearFilter = ->
  $("#filterClear").on "click", ->
    $("#licREQ1").val("")
    $('#licREQ2').val("")
    $('#licVALID1').val("")
    $('#licVALID2').val("")
    $('#licDEF1').val("")
    $('#licDEF2').val("")
    $('#total_cameras').val("")
    $("#username").val("")
    $("#fullname").val("")
    $("#email").val("")
    users_table.clearAjaxParams()
    users_table.getDataTable().ajax.reload()

onIntercomClick = ->
  $("#users_datatables").on "click", ".open-intercom", ->
    $('#api-wait').show()
    data = {}
    data.username = $(this).data("username")
    onError = (jqXHR, status, error) ->
      Notification.show(jqXHR.text)

    onSuccess = (result, status, jqXHR) ->
      $('#api-wait').hide()
      if result is null
        $(".bb-alert")
          .addClass("alert-danger")
          .text("User doesn't exist on Intercom")
          .delay(200)
          .fadeIn()
          .delay(4000)
          .fadeOut()
      else
        appId = result.app_id
        id = result.id
        newWindow = window.open("","_blank")
        newWindow.location.href = "https://app.intercom.io/a/apps/#{appId}/users/#{id}/all-conversations"

    settings =
      cache: false
      data: data
      dataType: 'json'
      error: onError
      success: onSuccess
      contentType: "application/x-www-form-urlencoded"
      type: "get"
      url: "/intercom/user"

    sendAJAXRequest(settings)

window.initializeusers = ->
  initializeDataTable()
  columnsDropdown()
  appendMe()
  validateDigit()
  searchFilter()
  showTable()
  clearFilter()
  onIntercomClick()
