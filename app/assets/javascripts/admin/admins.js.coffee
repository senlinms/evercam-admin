admin_table = undefined

sendAJAXRequest = (settings) ->
  token = $('meta[name="csrf-token"]')
  if token.size() > 0
    headers =
      "X-CSRF-Token": token.attr("content")
    settings.headers = headers
  xhrRequestChangeMonth = jQuery.ajax(settings)

initializeDataTable = ->
  admin_table = $("#admin_datatables").DataTable
    aaSorting: [1, "asc"]
    aLengthMenu: [
      [25, 50, 100, 200, -1]
      [25, 50, 100, 200, "All"]
    ]
    columns: [
      {data: "0", sWidth: "100px" },
      {data: "1", sWidth: "100px" },
      {data: "2", sWidth: "100px" },
      {data: "3", sWidth: "150px" },
      {data: "4", sWidth: "150px" },
      {data: "5", sWidth: "150px" },
      {data: "6", sWidth: "150px" },
      {data: "7", sWidth: "65px", sClass: "center" },
      {data: "8", sWidth: "100px" }
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
      $("#admin_datatables_length").hide()
      $("#div-dropdown-checklist").css({"visibility": "visible"})

columnsDropdown = ->
  $(".admin-column").on "click", ->
    column = admin_table.column($(this).attr("data-val"))
    column.visible !column.visible()

appendMe = ->
  options = $(".lic-col-box")
  row = $("#admin_datatables_wrapper").children().first()
  row.append options
  row.css("margin-bottom", "-11px")
  $(".dropdown-checklist").css({"width": "20px", "top": "34px"})

initNotify = ->
  Notification.init(".bb-alert")

addAdmin = ->
  $("#save-admin").on "click", ->
    data = {}
    data.firstname = $("#first-name").val()
    data.lastname = $("#last-name").val()
    data.username = $("#username").val()
    data.email = $("#email").val()
    data.password = $("#password").val()

    onError = (jqXHR, status, error) ->
      Notification.show(jqXHR.responseText)
      false

    onSuccess = (result, status, jqXHR) ->
      $('#modal-add-admin').modal('hide')
      Notification.show("Admin has been added!")
      clearForm()
      addNewRow(result)
      true

    settings =
      cache: false
      data: data
      dataType: 'json'
      error: onError
      success: onSuccess
      contentType: "application/x-www-form-urlencoded"
      type: "POST"
      url: "/admins/new"

    sendAJAXRequest(settings)

clearForm = ->
  $("#first-name").val("")
  $("#last-name").val("")
  $("#username").val("")
  $("#email").val("")
  $("#password").val("")

addNewRow = (admin) ->
  admin_table.row.add([
    "#{admin.username}",
    "#{admin.firstname} #{admin.lastname}",
    "#{admin.email}",
    "#{formatDate(admin.created_at)}",
    "",
    "",
    "",
    "0",
    ""
  ]).draw()

formatDate = (date) ->
  date = new Date(date)
  date.toUTCString()

window.initializeAdmins = ->
  initializeDataTable()
  columnsDropdown()
  appendMe()
  initNotify()
  addAdmin()
