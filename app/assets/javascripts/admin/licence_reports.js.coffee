licences_table = undefined
editRow = ''

sendAJAXRequest = (settings) ->
  token = $('meta[name="csrf-token"]')
  if token.size() > 0
    headers =
      "X-CSRF-Token": token.attr("content")
    settings.headers = headers
  xhrRequestChangeMonth = jQuery.ajax(settings)

initializeDataTable = ->
  licences_table = $("#licences_datatables").DataTable
    fnRowCallback: ->
      cellDesign()
    drawCallback: ->
      cellDesign()
    aaSorting: [1, "asc"]
    aLengthMenu: [
      [25, 50, 100, 200, -1]
      [25, 50, 100, 200, "All"]
    ]
    columns: [
      {data: "0", width: "185px" },
      {data: "1", width: "120px" },
      {data: "2", width: "110px", "sClass": "center" },
      {data: "3", width: "245px" },
      {data: "4", width: "90px", "sClass": "center" },
      {data: "5", width: "80px", "sClass": "center" },
      {data: "6", width: "70px", "sClass": "center" },
      {data: "7", width: "95px" },
      {data: "8", width: "95px" },
      {data: "9", width: "95px", 'render': editColor },
      {data: "10", width: "80px", "sClass": "center" },
      {data: "11", width: "85px", "sClass": "center" },
      {data: "12", width: "110px", "sClass": "center" },
      {data: "13", width: "85px", "sClass": "center" },
      {data: "14", width: "50px", "sClass": "center" },
      {data: "15", width: "50px",  "sClass": "center" }
    ],
    iDisplayLength: 50
    columnDefs: [
      type: "date-uk"
      targets: 'datatable-date'
    ],
    "oLanguage": {
      "sSearch": "Filter:"
    },
    initComplete: ->
      $("#licences-list-row").removeClass('hide')
      $("#licences_datatables_length label").hide()
      $("#div-dropdown-checklist").css('visibility', 'visible')

columnsDropdown = ->
  $(".licences-column").on "click", ->
    column = licences_table.column($(this).attr("data-val"))
    column.visible !column.visible()

initChosen = ->
  $('.chose-select').chosen()
  $("#total-cameras").NumericUpDown()

onModelShow = ->
  $("#modal-add-licence").on "show.bs.modal", ->
    $(".chosen-container").width("100%")
    $("#vat-number").hide()
    clearForm()

twoDigitDecimal = ->
  $("#licence-amount").on "change", ->
    if $("#licence-amount").val() is "" || $("#licence-amount").val() is "0.00"
      return;
    num = parseFloat($("#licence-amount").val());
    if isNaN(num.toFixed(2))
      Notification.show("Please enter valid licence amount.")
      $("#licence-amount").focus();
      $("#"+msgId).show('');
      return;
    $("#licence-amount").val(num.toFixed(2));

initNotify = ->
  Notification.init(".bb-alert");

initDateTime = ->
  $('.licence-date').datetimepicker
    format: 'd/m/Y'
    timepicker: false

saveLicence = ->
  $("#save-licence").on "click", ->
    if $("#users-list").val() is ""
      Notification.show("Please select user.")
      return false

    if $("#licence-desc").val().length >= 200
      Notification.show("Description cannot exceed 200 characters.")
      return false
    else if $("#licence-desc").val().length is 0
      Notification.show("Please enter Description.")
      return false

    if $("#total-cameras").val() is ""
      Notification.show('Please enter number of cameras.')
      return false

    if $("#total-cameras").val() is 0
      Notification.show('Please enter at least one Camera.')
      return false
    else if isNaN($("#total-cameras").val())
      Notification.show('Only numbers are allowed in cameras.')
      return false

    if $("#storage-days").val() is "0"
      Notification.show('Please select days storage.')
      return false
    else if isNaN($("#storage-days").val())
      Notification.show('Only numeric data is allowed in days.')
      return false

    if $("#licence-amount").val() isnt "" && $("#licence-amount").val() isnt "0.00"
      if isNaN($("#licence-amount").val())
        Notification.show("Please enter valid licence amount.")
        return false

    if $("#from-date").val() is ""
      Notification.show('Please select From Date.')
      return false
    if $("#to-date").val() is ""
      Notification.show('Please select To Date.')
      return false

    if !($("#other-m").is(':checked')) && !($("#stripe-m").is(':checked'))
      Notification.show('Please select To Payment Method.')
      return false

    data = {}
    data.user_id = $("#users-list").val()
    data.licence_desc = $("#licence-desc").val()
    data.total_cameras = $("#total-cameras").val()
    data.storage = $("#storage-days").val()
    data.amount = $("#licence-amount").val()
    data.start_date = $("#from-date").val()
    data.end_date = $("#to-date").val()
    if $("#other-m").is(':checked')
      data.paid = true
    else
      data.paid = false

    onError = (jqXHR, status, error) ->
      Notification.show(jqXHR.responseText)
      false

    onSuccess = (result, status, jqXHR) ->
      $('#modal-add-licence').modal('hide')
      addNewRow(result)
      clearForm()
      true

    settings =
      cache: false
      data: data
      dataType: 'json'
      error: onError
      success: onSuccess
      contentType: "application/x-www-form-urlencoded"
      type: "POST"
      url: "/licences/new"

    sendAJAXRequest(settings)

editColor = (name, type, row) ->
  if row[10] is ""
    return "<span style='color:red;'>#{name}<span/>"
  else
    return name

addNewRow = (data) ->
  trClass = $("#licences_datatables > tbody > tr:first").attr("class")
  tr = "<tr role='row' class='#{returnClass(trClass)}'>"
  tr +=  "<td><a href='/users/#{data.user_id}'>#{data.user.email}</a></td>"
  tr +=  "<td>#{data.user.firstname} #{data.user.lastname}</td>"
  tr +=  "<td></td><td>#{data.description}</td>"
  tr +=  "<td class='right'>#{data.total_cameras}</td>"
  tr +=  "<td class='right'>#{data.storage}</td>"
  tr +=  "<td>Custom</td>"
  tr +=  "<td>#{formatDate(data.created_at)}</td>"
  tr +=  "<td>#{formatDate(data.start_date)}</td>"
  tr +=  "<td id='ending'>#{formatDate(data.end_date)}</td>"
  tr +=  "<td class='right exp'>#{getExpDate(data.end_date)}</td>"
  tr +=  "<td class='right'>€ #{data.amount / 100}.00</td>"
  tr +=  "<td class='center'>No</td>"
  tr +=  "<td>#{paidStatus()}</td>"
  tr +=  "<td><i licence-type='custom' subscription-id='#{data.id}' class='fa fa-trash-o delete-licence'></i></td>"
  tr +=  "<td><i id='update-id' update-id='#{data.id}' class='fa fa-pencil-square-o edit-licence'></i></td>"
  tr += "</tr>"
  row = $("#licences_datatables > tbody > tr:first")
  row.before tr
  colorExp()

getExpDate = (end_date) ->
  second = new Date(end_date)
  first = new Date()
  expdate = Math.round (second - first) / (1000 * 60 * 60 * 24)
  if expdate <= 0
    return ""
  else
    return expdate

formatDate = (data) ->
  date = new Date(data)
  return addDdigit(date.getDate()) + "/" + addDdigit((date.getMonth() + 1)) + "/" + date.getFullYear()

addDdigit = (n) ->
  if n < 10 then '0' + n else '' + n

returnClass = (value) ->
  if value is "odd"
    "even"
  else if value is "even"
    "odd"

colorExp = ->
  if $(".exp").text() is ""
    $("#ending").css({"color": "red"})

paidStatus = ->
  if $("#other-m").is(':checked')
    "<span style='color:green;'>Paid</span>"
  else
    "<span style='color:red;'>Pending</span>"

clearForm = ->
  $("#users-list ~ .chosen-container > .chosen-single span").text "Select User"
  $("#licence-desc").val("")
  $("#total-cameras").val(1)
  $("#storage-days ~ .chosen-container > .chosen-single span").text "Select Storage"
  $("#licence-amount").val("0.00")
  $("#from-date").val("")
  $("#to-date").val("")
  $(".checked").removeClass("checked")
  $("#vat-number").hide()
  $("#save-licence").show()
  $("#update-licence").addClass("hide")
  $(".modal-header > .caption > strong").text("Add Licence")

autoRenewal = ->
  $(".auto-renewal").on "click", ->
    auto_renew = false
    if $(this).val() is "on"
      $(this).parent("span").removeClass("checked")
      $(this).val("off")
      auto_renew = true
    else
      $(this).parent("span").addClass("checked")
      $(this).val("on")
      auto_renew = false

    data = {}
    data.customer_id = $(this).attr("customer-id")
    data.subscription_id = $(this).attr("subscription-id")
    data.auto_renew = auto_renew

    onError = (jqXHR, status, error) ->
      Notification.show(jqXHR.responseText)

    onSuccess = (result, status, jqXHR) ->
      Notification.show("Trurned off")

    settings =
      cache: false
      data: data
      dataType: 'json'
      error: onError
      success: onSuccess
      contentType: "application/x-www-form-urlencoded"
      type: "POST"
      url: "/licences/auto-renewal"

    sendAJAXRequest(settings)

deleteLicence = ->
  $("#licences_datatables").on "click", ".delete-licence", ->
    result = confirm("Are you sure to cancel this licence?")
    if result is false
      return
    licence_row = $(this).parents('tr')
    licence_type = $(this).attr("licence-type")

    data = {}
    data.licence_type = licence_type
    if licence_type is "custom"
      data.subscription_id = $(this).attr("subscription-id")
    else
      data.customer_id = $(this).attr("customer-id")
      data.subscription_id = $(this).attr("subscription-id")

    onError = (jqXHR, status, error) ->
      Notification.show(jqXHR.responseText)

    onSuccess = (result, status, jqXHR) ->
      licence_row.remove()
      Notification.show("Licence canceled successfully.")

    settings =
      cache: false
      data: data
      dataType: 'json'
      error: onError
      success: onSuccess
      contentType: "application/x-www-form-urlencoded"
      type: "delete"
      url: "/licences/delete"

    sendAJAXRequest(settings)

appendMe = ->
  options = $(".lic-col-box")
  row = $("#licences_datatables_wrapper").children().first()
  row.append options
  row.css("margin-bottom", "-11px")
  $(".dropdown-checklist").css({"width": "20px", "top": "34px"})
  cellDesign()

getVat = ->
  $("#users-list").on "change", ->
    vat = $('option:selected', this).attr('vat-number')
    if vat is ""
      $("#vat-number").show()
      $("#vat > span").text("User doesn't have a vat number.")
    else
      $("#vat-number").show()
      $("#vat > span").text(vat)

onEditLicence = ->
  $("#licences_datatables").on "click", ".edit-licence", ->
    $("#modal-add-licence").modal("show")
    editRow = $(this).parents('tr')
    setModelUpdate(licences_table.row( editRow ).data())

setModelUpdate = (values) ->
  $("#save-licence").hide()
  $("#update-licence").removeClass("hide")
  $(".modal-header > .caption > strong").text("Edit Licence")
  $("#users-list ~ .chosen-container > .chosen-single span").text values[1]
  $("#licence-desc").val(values[3])
  $("#total-cameras").val(values[4])
  $("#storage-days ~ .chosen-container > .chosen-single span").text(setStorageText(values[5]))
  $("#users-list").val(getUserId(values[0])).trigger("chosen:updated")
  $("#storage-days").val(values[5]).trigger("chosen:updated")
  $("#licence-amount").val(values[11].slice(2))
  $("#from-date").val(values[8])
  $("#to-date").val(values[9])
  getPaidStatus(values[13])

getUserId = (id) ->
  return id.match(/\d+/)[0]

getPaidStatus = (status) ->
  if $(status).text() is "Paid"
    $("#uniform-other-m > span").addClass("checked")
    $("#uniform-stripe-m > span").removeClass("checked")
  else if $(status).text() is "Pending"
    $("#uniform-stripe-m > span").addClass("checked")
    $("#uniform-other-m > span").removeClass("checked")

onModelUpdate = ->
  $("#update-licence").on "click", ->
    data = {}
    data.user_id = $("#users-list").val()
    data.licence_desc = $("#licence-desc").val()
    data.total_cameras = $("#total-cameras").val()
    data.storage = $("#storage-days").val()
    data.amount = $("#licence-amount").val()
    data.start_date = $("#from-date").val()
    data.end_date = $("#to-date").val()
    data.licence_id = editRow.find("#update-id").attr('update-id')
    if $("#uniform-other-m > span").hasClass("checked")
      data.paid = true
    else
      data.paid = false

    onError = (jqXHR, status, error) ->
      Notification.show(jqXHR.text)

    onSuccess = (result, status, jqXHR) ->
      $("#modal-add-licence").modal("hide")
      updateRow(result)

    settings =
      cache: false
      data: data
      dataType: 'json'
      error: onError
      success: onSuccess
      contentType: "application/x-www-form-urlencoded"
      type: "patch"
      url: "/licences/update"

    sendAJAXRequest(settings)

updateRow = (data) ->
  licences_table
    .cell(editRow.find('td:nth-child(4)')).data(data.description)
    .cell(editRow.find('td:nth-child(5)')).data(data.total_cameras)
    .cell(editRow.find('td:nth-child(6)')).data(data.storage)
    .cell(editRow.find('td:nth-child(9)')).data(formatDate(data.start_date))
    .cell(editRow.find('td:nth-child(10)')).data(formatDate(data.end_date))
    .cell(editRow.find('td:nth-child(11)')).data(getExpDate(data.end_date))
    .cell(editRow.find('td:nth-child(12)')).data("€ #{data.amount / 100}.00")
    .cell(editRow.find('td:nth-child(14)')).data(setPaidStatus(data.paid))

setPaidStatus = (value) ->
  if value is true
    "<span style='color:green;'>Paid</span>"
  else
    "<span style='color:red;'>Pending</span>"

setStorageText = (storage) ->
  if storage is "1"
    return "24 hours recording"
  else if storage is "7"
    return "7 days recording"
  else if storage is "30"
    return "30 days recording"
  else if storage is "90"
    return "90 days recording"
  else if storage is "-1"
    return "infinity"

cellDesign = ->
  $("#licences_datatables > thead > tr > th").css("padding": "2px 4px")
  $("#licences_datatables > tbody > tr > th").css("padding": "2px 4px")
  $("#licences_datatables > thead > tr > td").css("padding": "2px 4px")
  $("#licences_datatables > tbody > tr > td").css("padding": "2px 4px")

window.initializeLicences = ->
  initChosen()
  onModelShow()
  columnsDropdown()
  initializeDataTable()
  initNotify()
  twoDigitDecimal()
  initDateTime()
  saveLicence()
  autoRenewal()
  deleteLicence()
  appendMe()
  getVat()
  onEditLicence()
  onModelUpdate()
