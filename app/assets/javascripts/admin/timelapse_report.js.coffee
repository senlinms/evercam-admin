timelapse_table = undefined

sendAJAXRequest = (settings) ->
  token = $('meta[name="csrf-token"]')
  if token.size() > 0
    headers =
      "X-CSRF-Token": token.attr("content")
    settings.headers = headers
  xhrRequestChangeMonth = jQuery.ajax(settings)
  true

initializeDataTable = ->
  timelapse_table = $("#timelapse_datatables").DataTable
    aaSorting: [4, "asc"]
    aLengthMenu: [
      [25, 50, 100, 200, -1]
      [25, 50, 100, 200, "All"]
    ]
    columns: [
      {data: "0", visible: false, width: "30px" },
      {data: "1", visible: false, width: "220px" },
      {data: "2", visible: false, width: "65px" },
      {data: "3", width: "170px" },
      {data: "4", width: "165px" },
      {data: "5", width: "200px" },
      {data: "6", width: "80px", sClass: "center" },
      {data: "7", width: "145px", sClass: "center" },
      {data: "8", width: "80px", sClass: "center" },
      {data: "9", visible: false, width: "60px", sClass: "center" },
      {data: "10", width: "125px", "render": setInterval },
      {data: "11", visible: false, width: "100px", sClass: "center" },
      {data: "12", visible: false, width: "100px", sClass: "center" },
      {data: "13", width: "110px", sClass: "center" },
      {data: "14", width: "80px", sClass: "center", "render": setStatus }
      {data: "15", width: "160px", sClass: "center" }
    ],
    iDisplayLength: 500
    columnDefs: [
      type: "date-uk"
      targets: 'datatable-date'
    ],
    "oLanguage": {
      "sSearch": "Filter:"
    },
    initComplete: ->
      $("#timelapse-list-row").removeClass('hide')
      $("#timelapse_datatables_length label").hide()
      $("#div-dropdown-checklist").css('visibility', 'visible')
      $("#div-dropdown-checklist").css({"visibility": "visible", "width": "57px", "top": "1px", "float": "right" })
      $("#timelapse_datatables_filter").hide()

columnsDropdown = ->
  $(".timelapse-column").on "click", ->
    column = timelapse_table.column($(this).attr("data-val"))
    column.visible !column.visible()

setStatus = (name, id, row) ->
  if name is "1"
    return "Processing"
  else if name is "2"
    return "Failed"
  else if name is "3"
    return "Scheduled"
  else if name is "4"
    return "Stopped"
  else if name is "5"
    return "NotFound"
  else if name is "6"
    return "Expired"
  else if name is "7"
    return "Paused"

setInterval = (name, id, row) ->
  if name is "1"
    return "1 Frame Every 1 min"
  else if name is "5"
    return "1 Frame Every 5 min"
  else if name is "15"
    return "1 Frame Every 15 min"
  else if name is "30"
    return "1 Frame Every 30 min"
  else if name is "60"
    return "1 Frame Every 1 hour"
  else if name is "360"
    return "1 Frame Every 6 hours"
  else if name is "720"
    return "1 Frame Every 12 hours"
  else if name is "1440"
    return "1 Frame Every 24 hours"

onSearch = ->
  $("#camera-name").on 'keyup change', ->
    timelapse_table
      .column(3)
      .search( @value )
      .draw()
  $("#owner").on 'keyup change', ->
    timelapse_table
      .column(4)
      .search( @value )
      .draw()
  $("#title").on 'keyup change', ->
    timelapse_table
      .column(5)
      .search( @value )
      .draw()
  $("#sp-count").on 'keyup change', ->
    timelapse_table
      .column(13)
      .search( @value )
      .draw()
  $("#status").on 'keyup change', ->
    timelapse_table
      .column(14)
      .search( @value )
      .draw()

onIntercomClick = ->
  $("#timelapse_datatables").on "click", ".open-intercom", ->
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

window.initializeTimelapse = ->
  initializeDataTable()
  columnsDropdown()
  onSearch()
  onIntercomClick()
