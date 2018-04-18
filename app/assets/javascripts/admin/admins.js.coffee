admin_table = undefined
editRow = undefined
editRowReference = undefined

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
      {data: "8", sWidth: "100px" },
      {data: "9", sWidth: "80px", sClass: "center", "render": humanizeStatus },
      {data: "10", sWidth: "65px", sClass: "center" }
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

openModal = ->
  $("#add-an-admin").on "click", ->
    clearForm()
    $("#save-admin").show()
    $("#update-admin").addClass("hide")
    $(".modal-header > .caption > strong").text("Add Admin")
    $("#modal-add-admin").modal("show")

addAdmin = ->
  $("#save-admin").on "click", ->
    data = {}
    data.firstname = $("#first-name").val()
    data.lastname = $("#last-name").val()
    data.username = $("#username").val()
    data.email = $("#email").val()
    data.password = $("#password").val()
    data.is_admin = $("#is_admin").val()

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
  $("#is_admin").val("true")
  $("#user_email").val("")

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
    "",
    "#{admin.is_admin}",
    "<i admin-id='#{admin.id}' firstname='#{admin.firstname}' lastname='#{admin.lastname}' class='fa fa-edit edit-admin'></i>",
    "<i admin-id='#{admin.id}' class='far fa-trash-alt delete-admin'></i>"
  ]).draw()

formatDate = (date) ->
  date = new Date(date)
  date.toUTCString()

deleteAdmin = ->
  $("#admin_datatables").on "click", ".delete-admin", ->
    result = confirm("Are you sure to cancel this admin?")
    if result is false
      return
    admin_row = $(this).parents('tr')

    data = {}
    data.admin_id = $(this).attr("admin-id")

    onError = (jqXHR, status, error) ->
      Notification.show(jqXHR.responseText)

    onSuccess = (result, status, jqXHR) ->
      admin_row.remove()
      Notification.show("Admin deleted successfully.")

    settings =
      cache: false
      data: data
      dataType: 'json'
      error: onError
      success: onSuccess
      contentType: "application/x-www-form-urlencoded"
      type: "delete"
      url: "/admins/delete"

    sendAJAXRequest(settings)

editAdmin = ->
  $("#admin_datatables").on "click", ".edit-admin", ->
    $(".bb-alert").removeClass("alert-info").addClass("alert-danger")
    user_row = $(this).parents('tr')
    user_id = $(this).attr("admin-id")
    data = {}
    data.id = user_id
    data.is_admin = false

    onError = (jqXHR, status, error) ->
      Notification.show(jqXHR.responseText)

    onSuccess = (result, status, jqXHR) ->
      $(".bb-alert").removeClass("alert-danger").addClass("alert-info")
      user_row.remove()
      Notification.show("Admin's data has been udpated.")

    settings =
      cache: false
      data: data
      dataType: 'json'
      error: onError
      success: onSuccess
      contentType: "application/x-www-form-urlencoded"
      type: "patch"
      url: "/admins/update"

    sendAJAXRequest(settings)

make_admin = ->
  $("#make-admin").on "click", ->
    user_email = $("#user_email").val()
    $(".bb-alert").removeClass("alert-info").addClass("alert-danger")
    if user_email is ""
      Notification.show("Please enter user email.")
      return false

    data = {}
    data.email = user_email

    onError = (jqXHR, status, error) ->
      Notification.show(jqXHR.responseText)

    onSuccess = (result, status, jqXHR) ->
      $(".bb-alert").removeClass("alert-danger").addClass("alert-info")
      $("#modal-make-admin").modal("hide")
      Notification.show("Admin's data has been udpated.")
      addNewRow(result)

    settings =
      cache: false
      data: data
      dataType: 'json'
      error: onError
      success: onSuccess
      contentType: "application/x-www-form-urlencoded"
      type: "patch"
      url: "/admins/make_admin"

    sendAJAXRequest(settings)

closeForm = ->
  $('#modal-make-admin').on 'hidden.bs.modal', ->
    clearForm()

setModelUpdate = (values, firstname, lastname) ->
  $("#save-admin").hide()
  $("#update-admin").removeClass("hide")
  $(".modal-header > .caption > strong").text("Edit Admin")
  $("#first-name").val(firstname)
  $("#last-name").val(lastname)
  $("#username").val(values[0])
  $("#email").val(values[2])
  $("#is_admin").val(values[9])
  $("#password").val("")

updateAdmin = ->
  $("#update-admin").on "click", ->
    data = {}
    data.id = editRowReference.attr("admin-id")
    data.firstname = $("#first-name").val()
    data.lastname = $("#last-name").val()
    data.username = $("#username").val()
    data.email = $("#email").val()
    data.is_admin = $("#is_admin").val()
    if $("#password").val() != ""
      data.password = $("#password").val()

    onError = (jqXHR, status, error) ->
      Notification.show(jqXHR.responseText)

    onSuccess = (result, status, jqXHR) ->
      $("#modal-add-admin").modal("hide")
      updateRow(result)
      Notification.show("Admin's data has been udpated.")

    settings =
      cache: false
      data: data
      dataType: 'json'
      error: onError
      success: onSuccess
      contentType: "application/x-www-form-urlencoded"
      type: "patch"
      url: "/admins/update"

    sendAJAXRequest(settings)

updateRow = (data) ->
  admin_table
    .cell(editRow.find('td:nth-child(1)')).data(data.username)
    .cell(editRow.find('td:nth-child(2)')).data("#{data.firstname} #{data.lastname}")
    .cell(editRow.find('td:nth-child(3)')).data(data.email)
    .cell(editRow.find('td:nth-child(5)')).data(formatDate(data.updated_at))
    .cell(editRow.find('td:nth-child(10)')).data(data.is_admin)

humanizeStatus = (active) ->
  if active is "true" || active is true
    return "<span style='color: green;'>True</span>"
  else if active is "false" || active is false
    return "<span style='color: red;'>False</span>"

window.initializeAdmins = ->
  initializeDataTable()
  columnsDropdown()
  appendMe()
  initNotify()
  openModal()
  addAdmin()
  editAdmin()
  updateAdmin()
  deleteAdmin()
  make_admin()
  closeForm()
