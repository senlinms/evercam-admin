camera_cleanup_table = undefined
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
  camera_cleanup_table = new Datatable
  headers = undefined
  token = $('meta[name="csrf-token"]')

  if token.size() > 0
    headers = 'X-CSRF-Token': token.attr('content')

  camera_cleanup_table.init
    src: $('#camera_cleanup_datatables')
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
      'pageLength': 99
      "order": [[ 1, "desc" ]]
      'processing': true
      'language': 'processing': '<img src="/assets/evercam-loading-gif.gif">'
      'ajax':
        'method': 'GET'
        'headers': headers
        'url': '/cleanup_cameras'
      columns: [
        {data: "16", "width": "20px", "sClass": "center", "render": addCheckbox},
        {data: "0", "width": "175px", "orderable": true, "sType": "uk_datetime" },
        {data: "1", "width": "175px", "orderable": true, "sType": "uk_datetime" }, # new field
        {data: "2", "width": "117px", "orderable": true, "render": linkCamera },
        {data: "3", "width": "150px", "render": linkOwner },
        {data: "4", "width": "150px",}, # new field email
        {data: "5", "width": "125px" },
        {data: "6", "width": "70px", "sClass": "center" },
        {data: "7", "width": "90px" },
        {data: "8", "width": "70px" },
        {data: "9", "width": "75px", visible: false},
        {data: "10", "width": "100px" },
        {data: "11", "width": "100px" },
        {data: "12", "width": "60px", "render": colStatus, "sClass": "center" },
        {data: "13", "width": "60px", "render": colStatus, "sClass": "center" },
        {data: "14", "width": "65px" },
        {data: "15", "width": "65px" }
      ],
      drawCallback: ->
        adjustHorizontalScroll()
        Metronic.init()
      initComplete: ->
        Metronic.init()

addCheckbox = (id, type, row) ->
  return "<input type='checkbox' data-val-id='#{row[2]}' data-val-api-id='#{row[18]}' data-val-api_key='#{row[19]}'/>"

searchFilter = ->
  $("#select_months").on "change", ->
    do_filter()

  $("#camera-id, #owner, #camera-name, #camera-ip, #username, #password, #email").on "keyup", ->
    do_filter()

do_filter = ->
  camera_exid = $("#camera-id").val()
  camera_owner = $("#owner").val().replace("'","''")
  owner_email = $("#email").val()
  camera_name = $("#camera-name").val().replace("'","''")
  camera_ip = $("#camera-ip").val()
  username = $("#username").val()
  password = $("#password").val()
  months = $("#select_months").val()

  camera_cleanup_table.setAjaxParam 'camera_exid', camera_exid
  camera_cleanup_table.setAjaxParam 'camera_owner', camera_owner
  camera_cleanup_table.setAjaxParam 'camera_name', camera_name
  camera_cleanup_table.setAjaxParam 'camera_ip', camera_ip
  camera_cleanup_table.setAjaxParam 'username', username
  camera_cleanup_table.setAjaxParam 'password', password
  camera_cleanup_table.setAjaxParam 'months', months
  camera_cleanup_table.setAjaxParam 'email', owner_email
  camera_cleanup_table.getDataTable().ajax.reload()

columnsDropdown = ->
  $(".cameras-column").on "click", ->
    column = camera_cleanup_table.getDataTable().column($(this).attr("data-val"))
    column.visible !column.visible()
    adjustHorizontalScroll()

multipleSelect = ->
  $("#chk_select_all").on "click", ->
    if $(this).is(':checked')
      $("#camera_cleanup_datatables tbody div.checker span").addClass("checked")
      $("#camera_cleanup_datatables tbody input[type='checkbox']").prop("checked", true)
    else
      $("#camera_cleanup_datatables tbody div.checker span").removeClass("checked")
      $("#camera_cleanup_datatables tbody input[type='checkbox']").prop("checked", false)

  $("#camera_cleanup_datatables tbody").on "click", "input[type='checkbox']", ->
    if $("#camera_cleanup_datatables tbody input[type='checkbox']:checked").length is $("#camera_cleanup_datatables tbody tr").length
      $("#chk_select_all").prop("checked", true)
      $("#uniform-chk_select_all span").addClass("checked")
    else
      $("#chk_select_all").prop("checked", false)
      $("#uniform-chk_select_all span").removeClass("checked")

  $("#btn_delete_cameras").on "click", ->
    total_cameras = $("#camera_cleanup_datatables tbody input[type='checkbox']:checked").length
    if total_cameras is 0
      $(".bb-alert").removeClass("alert-success").addClass("alert-danger")
      Notification.show("Please select camera(s) you want to delete.")
    else
      $("#total_cameras").text(total_cameras)
      $("#deleteModal").modal('show')

  $("#delete-cameras").on "click", ->
    $("#camera_cleanup_datatables tbody input[type='checkbox']:checked").each (index, control) ->
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
  $(".dataTables_length > label").css("display", "none")
  $("#camera_cleanup_datatables_paginate > .pagination-panel").css("display", "none")
  $(".paging_bootstrap_extended").css("float","none")

recording_duration = (duration) ->
  if duration == -1
    return "Infinity"
  else if duration == 1
    return "24 hours recording"
  else if !duration
    return ""
  else
    "#{duration} days recording"

colStatus = (name) ->
  if name is "t" || name is true
    return "<span style='color: green;'>True</span>"
  else if name is "f" || name is false || name is null
    return "<span style='color: red;'>False</span>"

linkCamera = (name, type, row) ->
  return "<a href='/cameras/#{row[16]}'>#{row[2]}</a>"

linkOwner = (name, type, row) ->
  url = "#{row[20]}/v1/cameras/#{row[2]}?api_id=#{row[18]}&api_key=#{row[19]}"
  return "<div class='link-user'>" +
    "<a class='pull-left' href='/users/#{row[16]}'>#{name}</a>" +
    "<a class='pull-right' href= #{url} target='_blank'>" +
    "<i class='fa fa-external-link-alt'></i></a></div>"

showTable = ->
  $(window).load ->
    $('#cameras-list-row').removeClass 'hide'

window.initializeCleanupCameras = ->
  columnsDropdown()
  initializeDataTable()
  appendMe()
  showTable()
  searchFilter()
  multipleSelect()
  $(window).resize ->
    adjustHorizontalScroll()
