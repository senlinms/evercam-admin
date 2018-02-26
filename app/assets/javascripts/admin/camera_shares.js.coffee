camera_shares_datatables = undefined

sendAJAXRequest = (settings) ->
  token = $('meta[name="csrf-token"]')
  if token.size() > 0
    headers =
      "X-CSRF-Token": token.attr("content")
    settings.headers = headers
  xhrRequestChangeMonth = jQuery.ajax(settings)
  true

initializeDataTable = ->
  camera_shares_datatables = new Datatable
  headers = undefined
  token = $('meta[name="csrf-token"]')

  if token.size() > 0
    headers = 'X-CSRF-Token': token.attr('content')

  camera_shares_datatables.init
    src: $('#camera_shares_datatables')
    onSuccess: (grid) ->
      # execute some code after table records loaded
      return
    onError: (grid) ->
      # execute some code on network or other general error
      return
    dataTable:
      'bStateSave': false
      'lengthMenu': [
        [ 25, 50, 100, 150 ]
        [ 25, 50, 100, 150 ]
      ]
      'pageLength': 200
      "order": [[ 0, "desc" ]]
      'processing': true
      'language': 'processing': '<img src="/assets/loading.gif">'
      'ajax':
        'method': 'GET'
        'headers': headers
        'url': '/load_camera_shares'
      columns: [
        {data: "0", "width": "125px", "orderable": true },
        {data: "1", "width": "117px", "orderable": true, "render": linkCamera },
        {data: "2", "width": "117px", "orderable": true, "render": linkSharer },
        {data: "3", "width": "117px", "orderable": true, "render": linkSharee },
        {data: "4", "width": "87px", "orderable": true },
      ],
      drawCallback: ->
        adjustHorizontalScroll()

searchFilter = ->
  $('#camera-exid, #sharer-fullname, #sharee-fullname').on "keyup", ->
    camera_exid = $("#camera-exid").val()
    sharer_fullname = $("#sharer-fullname").val().replace("'","''")
    sharee_fullname = $("#sharee-fullname").val().replace("'","''")
    camera_shares_datatables.setAjaxParam 'camera_exid', camera_exid
    camera_shares_datatables.setAjaxParam 'sharer_fullname', sharer_fullname
    camera_shares_datatables.setAjaxParam 'sharee_fullname', sharee_fullname
    camera_shares_datatables.getDataTable().ajax.reload()
    return

appendMe = ->
  $("#div-dropdown-checklist").css({"visibility": "visible", "width": "20px", "top": "1px", "float": "right", "right": "22px" })
  $(".dataTables_info").css("display", "none")
  $(".dataTables_length > label").css("display", "none")
  $("#camera_shares_datatables_paginate > .pagination-panel").css("display", "none")
  $(".paging_bootstrap_extended").css("float","none")

linkCamera = (name, type, row) ->
  if name is null
    return "Camera has been deleted."
  return "<a href='/cameras/#{row[9]}'>#{row[1]}</a>"

linkSharer = (name, type, row) ->
  if name is null
    return "Sharer has been deleted."
  url = "#{row[12]}/v1/cameras/#{row[1]}?api_id=#{row[6]}&api_key=#{row[5]}"
  return "<div class='link-user'>" +
    "<a class='pull-left' href='/users/#{row[10]}'>#{name}</a>" +
    "<a class='pull-right' href= #{url} target='_blank'>" +
    "<i class='fa fa-external-link-alt'></i></a></div>"

linkSharee = (name, type, row) ->
  if name is null
    return "Sharee has been deleted."
  url = "#{row[12]}/v1/cameras/#{row[1]}?api_id=#{row[8]}&api_key=#{row[7]}"
  return "<div class='link-user'>" +
    "<a class='pull-left' href='/users/#{row[11]}'>#{name}</a>" +
    "<a class='pull-right' href= #{url} target='_blank'>" +
    "<i class='fa fa-external-link-alt'></i></a></div>"

clearFilter = ->
  $("#filterClear").on "click", ->
    $("#camera-exid").val("")
    $("#sharer-fullname").val("")
    $("#sharee-fullname").val("")
    camera_shares_datatables.clearAjaxParams()
    camera_shares_datatables.getDataTable().ajax.reload()

window.initializeCameraShares = ->
  initializeDataTable()
  appendMe()
  searchFilter()
  clearFilter()
  $(window).resize ->
    adjustHorizontalScroll()
