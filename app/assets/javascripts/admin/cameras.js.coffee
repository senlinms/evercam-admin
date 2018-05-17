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
        [ 50, 100, 500, 1000 ]
        [ 50, 100, 500, 1000 ]
      ]
      'pageLength': 50
      "order": [[ 0, "desc" ]]
      'processing': true
      'language': 'processing': '<img src="/assets/loading.gif">'
      'ajax':
        'method': 'GET'
        'headers': headers
        'url': '/load_cameras'
      columns: [
        {data: "18", "width": "20px", "sClass": "center", "render": addCheckbox},
        {data: "0", "width": "175px", "orderable": true, "sType": "uk_datetime" },
        {data: "23", "width": "175px", "orderable": true, "sType": "uk_datetime" },
        {data: "1", "width": "117px", "orderable": true, "render": linkCamera },
        {data: "2", "width": "150px", "render": linkOwner },
        {data: "24", "width": "150px",},
        {data: "3", "width": "125px" },
        {data: "4", "width": "70px", "sClass": "center" },
        {data: "5", "width": "90px" },
        {data: "6", "width": "70px" },
        {data: "7", "width": "75px" },
        {data: "8", "width": "135px" },
        {data: "9", "width": "100px" },
        {data: "10", "width": "110px" },
        {data: "11", "width": "100px" },
        {data: "12", "width": "130px" },
        {data: "13", "width": "130px" },
        {data: "14", "width": "60px", "render": colStatus, "sClass": "center" },
        {data: "15", "width": "60px", "render": colStatus, "sClass": "center" },
        {data: "25", "width": "65px" },
        {data: "16", "width": "110px", "sClass": "center" },
        {data: "17", visible: false, "width": "75px" }
      ],
      drawCallback: ->
        adjustHorizontalScroll()
        attachCheckBoxRange()
      initComplete: ->
        attachCheckBoxRange()

attachCheckBoxRange = ->
  $chkboxes = $('.chkbox')
  lastChecked = null
  $chkboxes.click (e) ->
    if !lastChecked
      lastChecked = this
      return
    if e.shiftKey
      start = $chkboxes.index(this)
      end = $chkboxes.index(lastChecked)
      $chkboxes.slice(Math.min(start, end), Math.max(start, end) + 1).prop 'checked', lastChecked.checked
    lastChecked = this
    return

searchFilter = ->
  $("#camera-id, #owner, #camera-name, #camera-ip, #username, #password, #model, #vendor, #cr_status").on "keyup", ->
    camera_exid = $("#camera-id").val()
    camera_owner = $("#owner").val().replace("'","''")
    camera_name = $("#camera-name").val().replace("'","''")
    camera_ip = $("#camera-ip").val()
    username = $("#username").val()
    password = $("#password").val()
    model = $("#model").val()
    vendor = $("#vendor").val()
    cr_status = $("#cr_status").val()

    cameras_table.setAjaxParam 'camera_exid', camera_exid
    cameras_table.setAjaxParam 'camera_owner', camera_owner
    cameras_table.setAjaxParam 'camera_name', camera_name
    cameras_table.setAjaxParam 'camera_ip', camera_ip
    cameras_table.setAjaxParam 'username', username
    cameras_table.setAjaxParam 'password', password
    cameras_table.setAjaxParam 'model', model
    cameras_table.setAjaxParam 'vendor', vendor
    cameras_table.setAjaxParam 'is_recording', cr_status
    cameras_table.getDataTable().ajax.reload()
    return

addCheckbox = (id, type, row) ->
  return "<input class='chkbox' type='checkbox' data-val-id='#{row[1]}' data-val-api-id='#{row[20]}' data-val-api_key='#{row[21]}'/>"

columnsDropdown = ->
  $(".cameras-column").on "click", ->
    column = cameras_table.getDataTable().column($(this).attr("data-val"))
    column.visible !column.visible()
    adjustHorizontalScroll()

multipleSelect = ->
  $("#chk_select_all").on "click", ->
    if $(this).is(':checked')
      $("#cameras_datatables tbody div.checker span").addClass("checked")
      $("#cameras_datatables tbody input[type='checkbox']").prop("checked", true)
    else
      $("#cameras_datatables tbody div.checker span").removeClass("checked")
      $("#cameras_datatables tbody input[type='checkbox']").prop("checked", false)

  $("#cameras_datatables tbody").on "click", "input[type='checkbox']", ->
    if $("#cameras_datatables tbody input[type='checkbox']:checked").length is $("#cameras_datatables tbody tr").length
      $("#chk_select_all").prop("checked", true)
      $("#uniform-chk_select_all span").addClass("checked")
    else
      $("#chk_select_all").prop("checked", false)
      $("#uniform-chk_select_all span").removeClass("checked")

  $("#btn_delete_cameras").on "click", ->
    total_cameras = $("#cameras_datatables tbody input[type='checkbox']:checked").length
    if total_cameras is 0
      $(".bb-alert").removeClass("alert-success").addClass("alert-danger")
      Notification.show("Please select camera(s) you want to delete.")
    else
      $("#total_cameras").text(total_cameras)
      $("#deleteModal").modal('show')

  $("#delete-cameras").on "click", ->
    $("#cameras_datatables tbody input[type='checkbox']:checked").each (index, control) ->
      camera_id = $(control).attr("data-val-id")
      api_id = $(control).attr("data-val-api-id")
      api_key = $(control).attr("data-val-api_key")
      row = $(this).parents('tr')

      onError = (jqXHR, status, error) ->
        $(".bb-alert").removeClass("alert-success").addClass("alert-danger")
        false

      onSuccess = (result, status, jqXHR) ->
        $(".bb-alert").removeClass("alert-danger").addClass("alert-success")
        row.remove()

      settings =
        cache: false
        data: {}
        dataType: 'json'
        error: onError
        success: onSuccess
        contentType: "application/x-www-form-urlencoded"
        type: "DELETE"
        url: "#{$('#txt_api_url').val()}/v1/cameras/#{camera_id}?api_id=#{api_id}&api_key=#{api_key}"

      jQuery.ajax(settings)

    $("#deleteModal").modal('hide')
    Notification.show("Camera(s) delete request sends to evercam server and will be complete soon.")
    # camera_cleanup_table.getDataTable().ajax.reload()

appendMe = ->
  $("#div-dropdown-checklist").css({"visibility": "visible", "width": "20px", "top": "1px", "float": "right", "right": "22px" })
  $(".dataTables_info").css("display", "none")
  $("#cameras_datatables_length").remove()
  $("#cameras_datatables_paginate > .pagination-panel").css("display", "none")
  $(".paging_bootstrap_extended").css({"float": "left", "margin": "0 5px"})

colStatus = (name) ->
  if name is "t" || name is true
    return "<span style='color: green;'>True</span>"
  else if name is "f" || name is false || name is null
    return "<span style='color: red;'>False</span>"

linkCamera = (name, type, row) ->
  return "<a href='/cameras/#{row[18]}'>#{row[1]}</a>"

linkOwner = (name, type, row) ->
  url = "#{row[22]}/v1/cameras/#{row[1]}?api_id=#{row[20]}&api_key=#{row[21]}"
  return "<div class='link-user'>" +
    "<a class='pull-left' href='/users/#{row[19]}'>#{name}</a>" +
    "<a class='pull-right' href= #{url} target='_blank'>" +
    "<i class='fa fa-external-link-alt'></i></a></div>"

showTable = ->
  $(window).load ->
    $('#cameras-list-row').removeClass 'hide'

window.initializeCameras = ->
  columnsDropdown()
  initializeDataTable()
  appendMe()
  showTable()
  multipleSelect()
  searchFilter()
  $(window).resize ->
    adjustHorizontalScroll()
