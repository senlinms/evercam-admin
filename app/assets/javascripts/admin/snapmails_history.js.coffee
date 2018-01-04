snapmails_history = undefined

sendAJAXRequest = (settings) ->
  token = $('meta[name="csrf-token"]')
  if token.size() > 0
    headers =
      "X-CSRF-Token": token.attr("content")
    settings.headers = headers
  xhrRequestChangeMonth = jQuery.ajax(settings)

initializeDataTable = ->
  snapmails_history = $("#snapmails_history_datatables").dataTable
    aaSorting: [0, "desc"]
    aLengthMenu: [
      [25, 50, 100, 200, -1]
      [25, 50, 100, 200, "All"]
    ]
    columns: [
      {data: "0", sWidth: "150px" },
      {data: "1", sWidth: "150px" },
      {data: "2", sWidth: "100px", "render": attachCameraIds},
      {data: "3", sWidth: "100px", "render": attachCameraIdsFailed},
      {data: "4", sWidth: "150px" },
      {data: "5", sWidth: "75px", "render": linkEmail }
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
      $("#snapmails_history_datatables_length").hide()
      $("#div-dropdown-checklist").css({"visibility": "visible", "width": "57px", "top": "0px", "left": "6px" })

columnsDropdown = ->
  $(".snapmails-history-column").on "click", ->
    column = snapmails_history.column($(this).attr("data-val"))
    column.visible !column.visible()

attachCameraIds = (name, type, row) ->
  allCameraIds = []
  $div = $(name)
  $div.find(".last-snapmail-snapshot").map ->
    allCameraIds.push $(this).attr('id')
  $div.find(".failed-camera").map ->
    allCameraIds.push $(this).attr('id')
  return allCameraIds

attachCameraIdsFailed = (name, type, row) ->
  allCameraFailedIds = []
  $div = $(row[2])
  $div.find(".failed-camera").map ->
    allCameraFailedIds.push $(this).attr('id')
  return allCameraFailedIds

setMargin = ->
  row = $("#snapmails_history_datatables_wrapper").children().first()
  row.css("margin-bottom", "-11px")

initDatePicker = ->
  html = "<div class='col-md-6 col-sm-12'><label style='margin-left: 45px;'>From Date: <input type='text' id='datetimepicker' class='form-control
    input-small input-inline' placeholder='DateTime'></label><label style='margin-left: 10px;'>To Date: <input type='text' id='datetimepicker1' class='form-control
    input-small input-inline' placeholder='DateTime'></label></div>"
  $("#snapmails_history_datatables_wrapper > .row:first-child").prepend(html)
  $('#datetimepicker').datetimepicker
    timepicker: false
    format: 'Y/m/d'
  $('#datetimepicker1').datetimepicker
    timepicker: false
    format: 'Y/m/d'
    onSelectDate: ->
      ajaxCall($('#datetimepicker').val(), $('#datetimepicker1').val())

linkEmail = (name, type, row) ->
  return "<a id='show-email-template' data-id='#{name}'> Template </a>"

showEmailTemplate = ->
  $("#snapmails_history_datatables").on "click", "#show-email-template", ->
    getEmailTemplate($(this).data("id"))

getEmailTemplate = (id) ->
  data = {}
  data.id = id
  $.ajax
      url: '/get_email_temaplate'
      data: data
      dataType: 'json'
      type: 'get'
      success: (data) ->

        $div = $(data.body)
        timestamp = new Date(data.timestamp * 1000)

        year = moment.utc(timestamp).format("YYYY")
        month = moment.utc(timestamp).format("MM")
        day = moment.utc(timestamp).format("DD")
        hour = moment.utc(timestamp).format("HH")
        minutes = moment.utc(timestamp).format("mm")
        seconds = moment.utc(timestamp).format("ss")

        $div.find(".last-snapmail-snapshot").map ->
          $(this).attr('src', "#{data.filer_url}/#{$(this).attr('id')}/snapshots/snapmail/#{year}/#{month}/#{day}/#{hour}/#{minutes}_#{seconds}_000.jpg")

        $("#snapmail-template").html($div)
        $('#add-action').modal('show')
      error: (xhr, status, error) ->
        $(".bb-alert")
            .addClass("alert-danger")
            .text(xhr.responseText)
            .delay(200)
            .fadeIn()
            .delay(4000)
            .fadeOut()

closeModalSnapmail = ->
  $("#close-dialog-snapmail").on "click", ->
    $("#snapmail-template").html("")

getTodaysDate = ->
  date = new Date
  date.setDate (date.getDate())
  date.getFullYear() + '/' + (date.getMonth() + 1) + '/' + date.getDate()

getWeekDate = ->
  date = new Date
  date.setDate (date.getDate() - 7)
  date.getFullYear() + '/' + (date.getMonth() + 1) + '/' + date.getDate()

initNotify = ->
  Notification.init(".show-notifications")

ajaxCall = (fromDate, toDate) ->
  if fromDate > toDate
    Notification.show("From Date cannot be greater than To Date.")
  else
    data = {}
    data.fromDate = fromDate
    data.toDate = toDate
    $('#ajx-wait').show()
    $.ajax
      url: '/get_history_data'
      data: data
      type: 'get'
      success: (data) ->
        $('#ajx-wait').hide()
        if typeof data == "object"
          snapmails_history.fnClearTable()
          snapmails_history.fnAddData(data)
        else
          snapmails_history.fnClearTable()
          Notification.show("There are no records for that period.")
      error: (xhr, status, error) ->
        Notification.show(xhr.responseText)

onPageLoad = ->
  $(window).load ->
    $('#datetimepicker').val getWeekDate()
    $('#datetimepicker1').val getTodaysDate()
    ajaxCall(getWeekDate(), getTodaysDate())

window.initializeSnapmailHistory = ->
  initializeDataTable()
  initNotify()
  columnsDropdown()
  setMargin()
  initDatePicker()
  onPageLoad()
  showEmailTemplate()
  closeModalSnapmail()
