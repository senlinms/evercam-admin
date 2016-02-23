licences_table = undefined

sendAJAXRequest = (settings) ->
  token = $('meta[name="csrf-token"]')
  if token.size() > 0
    headers =
      "X-CSRF-Token": token.attr("content")
    settings.headers = headers
  xhrRequestChangeMonth = jQuery.ajax(settings)

initializeDataTable = ->
  licences_table = $("#licences_datatables").DataTable
    aaSorting: [1, "asc"]
    aLengthMenu: [
      [25, 50, 100, 200, -1]
      [25, 50, 100, 200, "All"]
    ]
    columns: [
      {data: "0" },
      {data: "1" },
      {data: "2" },
      {data: "3" },
      {data: "4", "sClass": "right" },
      {data: "5", "sClass": "right" },
      {data: "6" },
      {data: "7" },
      {data: "8" },
      {data: "9" },
      {data: "10", "sClass": "right" },
      {data: "11", "sClass": "right" },
      {data: "12", "sClass": "center"},
      {data: "13" }
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
    $(".chosen-container").width("100%");

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
    format: 'Y/m/d'
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

    data = {}
    data.user_id = $("#users-list").val()
    data.licence_desc = $("#licence-desc").val()
    data.total_cameras = $("#total-cameras").val()
    data.storage = $("#storage-days").val()
    data.amount = $("#licence-amount").val()
    data.start_date = $("#from-date").val()
    data.end_date = $("#to-date").val()

    onError = (jqXHR, status, error) ->
      Notification.show(jqXHR.responseText)
      false

    onSuccess = (result, status, jqXHR) ->
      $('#modal-add-licence').modal('hide')
      #licences_table.row.add( [
      #  '.1',
      #  '.2',
      #  '.3',
      #  '.4',
      #  '.5',
      #  '.6',
      #  '.7',
      #  '.8',
      #  '.9',
      #  '.10',
      #  '11'
      #]).draw( false );*/
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

clearForm = ->
  $("#users-list").val("")
  $("#licence-desc").val("")
  $("#total-cameras").val(1)
  $("#storage-days").val("0")
  $("#licence-amount").val("0.00")
  $("#from-date").val("")
  $("#to-date").val("")

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
  $(".delete-licence").on "click", ->
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
