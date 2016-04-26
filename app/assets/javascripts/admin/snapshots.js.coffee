snapshots_table = undefined
mouseOverCtrl = undefined

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
      {data: "13", sClass: "center", sWidth: "65px", "render": colorStatus }
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
      $("#snapshots-list-row").removeClass('hide')
      $("#snapshots_datatables_filter").addClass("hide")
      $("#snapshots_datatables_length label").hide()
      $("#div-dropdown-checklist").css({"visibility": "visible", "width": "59px", "top": "1px", "float": "right" })

columnsDropdown = ->
  $(".cameras-column").on "click", ->
    column = snapshots_table.column($(this).attr("data-val"))
    column.visible !column.visible()

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


onImageHover = ->
  $("#snapshots_datatables").on "mouseover", ".thumbnails", ->
    mouseOverCtrl = this
    $(".full-image").attr("src", @src)
    $(".div-elms").show()

  $("#snapshots_datatables").on "mouseout", mouseOverCtrl, ->
    $(".div-elms").hide()

window.initializSnapshots = ->
  columnsDropdown()
  initializeDataTable()
  onIntercomClick()
  onSearch()
  onImageHover()
