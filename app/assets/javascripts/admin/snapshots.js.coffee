snapshots_table = undefined
mouseOverCtrl = undefined
editRowReference = undefined
window.fullWeekSchedule =
  "Monday": ["00:00-23:59"]
  "Tuesday": ["00:00-23:59"]
  "Wednesday": ["00:00-23:59"]
  "Thursday": ["00:00-23:59"]
  "Friday": ["00:00-23:59"]
  "Saturday": ["00:00-23:59"]
  "Sunday": ["00:00-23:59"]

sendAJAXRequest = (settings) ->
  token = $('meta[name="csrf-token"]')
  if token.size() > 0
    headers =
      "X-CSRF-Token": token.attr("content")
    settings.headers = headers
  xhrRequestChangeMonth = jQuery.ajax(settings)
  true

initializeDataTable = ->
  snapshots_table = $("#snapshots_datatables").DataTable
    bSortCellsTop: true
    aaSorting: [1, "asc"]
    aLengthMenu: [
      [25, 50, 100, 200, -1]
      [25, 50, 100, 200, "All"]
    ]
    columns: [
      {data: "0", sWidth: "110px" },
      {data: "1", sWidth: "150px" },
      {data: "2", visible: false, sClass: "center", sWidth: "60px" },
      {data: "3", visible: false, sWidth: "105px" },
      {data: "4", sClass: "center", sWidth: "65px" },
      {data: "5", sClass: "center", sWidth: "60px" },
      {data: "6", sClass: "center", sWidth: "95px" },
      {data: "7", sClass: "center", sWidth: "100px" },
      {data: "8", visible: false, sWidth: "115px" },
      {data: "9", "render": colorStatus, sClass: "center", sWidth: "50px" },
      {data: "10", visible: false, sWidth: "105px" },
      {data: "11", visible: false, sClass: "center", sWidth: "55px" },
      {data: "12", visible: false, sClass: "center", sWidth: "75px"},
      {data: "13", sClass: "center", sWidth: "65px", "render": colorStatus },
      {data: "14", sClass: "center", sWidth: "110px", "render": paymentMethod },
      {data: "15", sClass: "center", sWidth: "50px" },
    ],
    iDisplayLength: 60
    columnDefs: [
      {type: "date-uk", targets: 'datatable-date'},
      {type: "natural", targets: 5}
    ],
    "oLanguage": {
      "sSearch": "Filter:"
    },
    drawCallback: ->
      adjustHorizontalScroll()
    initComplete: ->
      $("#snapshots-list-row").removeClass('hide')
      $("#snapshots_datatables_filter").addClass("hide")
      $("#snapshots_datatables_length label").hide()
      $("#div-dropdown-checklist").css({"visibility": "visible", "width": "59px", "top": "1px", "float": "right" })

columnsDropdown = ->
  $(".cameras-column").on "click", ->
    column = snapshots_table.column($(this).attr("data-val"))
    column.visible !column.visible()
    adjustHorizontalScroll()

paymentMethod = (name) ->
  if name is "0"
    "Stripe"
  else
    "Custom"

colorStatus = (name) ->
  if name is "t"
    return "<span style='color: green;'>True</span>"
  else if name is "f"
    return "<span style='color: red;'>False</span>"

onIntercomClick = ->
  $("#snapshots_datatables").on "click", ".open-intercom", ->
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

onSearch = ->
  $("#camera-name").on 'keyup change', ->
    snapshots_table
      .column(0)
      .search( @value )
      .draw()
  $("#owner").on 'keyup change', ->
    snapshots_table
      .column(1)
      .search( @value )
      .draw()
  $("#status").on 'keyup change', ->
    snapshots_table
      .column(4)
      .search( @value )
      .draw()
  $("#duration").on 'keyup change', ->
    snapshots_table
      .column(5)
      .search( @value )
      .draw()
  $("#online").on 'keyup change', ->
    snapshots_table
      .column(9)
      .search( @value )
      .draw()
  $("#licenced").on 'keyup change', ->
    snapshots_table
      .column(13)
      .search( @value )
      .draw()

initNotify = ->
  Notification.init(".bb-alert")

onImageHover = ->
  $("#snapshots_datatables").on "mouseover", ".thumbnails", ->
    mouseOverCtrl = this
    $(".full-image").attr("src", @src)
    $(".div-elms").show()

  $("#snapshots_datatables").on "mouseout", mouseOverCtrl, ->
    $(".div-elms").hide()

onEditCR = ->
  $("#snapshots_datatables").on "click", ".edit-cr", ->
    editRowReference = $(this).parents('tr')
    $('#modal-add-cr').modal('show')
    status = $(this).parents('tr').find('td:nth-child(3)').text()
    frequency = $(this).parents('tr').find('td:nth-child(5)').text()
    if $(this).parents('tr').find('td:nth-child(4)').text() == "Infinity"
      duration = -1
    else
      duration = $(this).parents('tr').find('td:nth-child(4)').text()
    camera_exid = $(this).attr("camera-exid")
    camera_api_id = $(this).attr("camera-api-id")
    camera_api_key = $(this).attr("camera-api-key")
    evercam_server = $(this).attr("evercam-server")

    $("#cloud-recording-status").val(status.toLowerCase())
    $("#cloud-recording-duration").val(duration)
    $("#cloud-recording-frequency").val(frequency)
    $("#camera-exid").val(camera_exid)
    $("#camera-api-id").val(camera_api_id)
    $("#camera-api-key").val(camera_api_key)
    $("#evercam-server").val(evercam_server)

onSaveCR = ->
  $("#modal-add-cr").on "click", "#save-cr", ->
    $('#modal-add-cr').modal('hide')
    $("#cloud-recording-status").val()
    $("#cloud-recording-duration").val()
    $("#cloud-recording-frequency").val()
    camera_exid = $("#camera-exid").val()
    evercam_server = $("#evercam-server").val()

    $('#api-wait').show()
    data = {}
    data.status = $("#cloud-recording-status").val()
    data.storage_duration = $("#cloud-recording-duration").val()
    data.frequency = $("#cloud-recording-frequency").val()
    data.schedule = JSON.stringify(fullWeekSchedule)
    data.api_id = $("#camera-api-id").val()
    data.api_key = $("#camera-api-key").val()

    onError = (jqXHR, status, error) ->
      Notification.show(jqXHR.text)

    onSuccess = (response, status, jqXHR) ->
      $('#api-wait').hide()
      editRowReference.find('td:nth-child(3)').text(capitalizeFirstLetter(response.cloud_recordings[0].status))
      editRowReference.find('td:nth-child(4)').text(setDuration(response.cloud_recordings[0].storage_duration))
      editRowReference.find('td:nth-child(5)').text(response.cloud_recordings[0].frequency)
      Notification.show("Cloud Recordings have been updated.")

    settings =
      cache: false
      data: data
      dataType: 'json'
      error: onError
      success: onSuccess
      contentType: "application/x-www-form-urlencoded"
      type: "POST"
      url: "#{evercam_server}/v1/cameras/#{camera_exid}/apps/cloud-recording"

    $.ajax(settings)

capitalizeFirstLetter = (string) ->
  string.charAt(0).toUpperCase() + string.slice(1)

setDuration = (value) ->
  if value == -1
    "Infinity"
  else
    value

window.initializSnapshots = ->
  initNotify()
  columnsDropdown()
  initializeDataTable()
  onIntercomClick()
  onSearch()
  onImageHover()
  onEditCR()
  onSaveCR()
  $(window).resize ->
    adjustHorizontalScroll()
