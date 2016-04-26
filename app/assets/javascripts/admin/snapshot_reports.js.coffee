snapshots_table = undefined
initializeDataTable = ->
  snapshots_table = $("#snapshots_datatables").dataTable
    aaSorting: [0, "asc"]
    fnRowCallback: (nRow, aData, iDisplayIndex, iDisplayIndexFull) ->
      cellAndPage()
      if aData[3] && aData[3].storage_duration == -1
        $('td:eq(3)', nRow)
          .html "Infinity"
      else if aData[3] && aData[3].storage_duration == 1
        $('td:eq(3)', nRow)
          .html "24 hours recording"
      else if !aData[3]
        $('td:eq(3)', nRow)
          .html ""
      else
        $('td:eq(3)', nRow)
          .html aData[3].storage_duration + " days recording"

      if aData[4] == true
        $('td:eq(4)', nRow)
          .html "True"
          .css { "color": "green", "text-align": "center" }
      else
        $('td:eq(4)', nRow)
          .html "False"
          .css { "color": "Red", "text-align": "center" }
    aLengthMenu: [
      [25, 50, 100, 200, -1]
      [25, 50, 100, 200, "All"]
    ]
    columns: [
      {data: "0", "render": linkMode1, width: "200px" },
      {data: "1", width: "200px" },
      {data: "2", "render": linkMode2, width: "200px" },
      {data: "3", width: "200px" },
      {data: "4", width: "75px", sClass: "center" },
      {data: "5", width: "130px", sClass: "center"}
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
      $("#snapshots_datatables_length label").hide()

columnsDropdown = ->
  $(".cameras-column").on "click", ->
    column = snapshots_table.column($(this).attr("data-val"))
    column.visible !column.visible()

linkMode1 = (name, type, row) ->
  return "<a href=/cameras/#{row[6]}>#{name}</a>"

linkMode2 = (name, type, row) ->
  return "<a href=/users/#{row[7]}>#{name} #{row[8]}</a>"

initDatePicker = ->
  html = "<div class='col-md-6 col-sm-12'><label>Date:<input type='text' id='datetimepicker' class='form-control 
    input-small input-inline'></label></div>"
  $("#snapshots_datatables_wrapper > .row:first-child").prepend(html)
  $('#datetimepicker').datetimepicker
    timepicker: false
    format: 'Y/m/d'
    onSelectDate: ->
      ajaxCall($('#datetimepicker').val())

getYesterdaysDate = ->
  date = new Date
  date.setDate (date.getDate() - 1)
  date.getFullYear() + '/' + (date.getMonth() + 1) + '/' + date.getDate()

ajaxCall = (date) ->
  data = {}
  data.date = date
  $('#ajx-wait').show()
  $.ajax
      url: 'snapshot_reports'
      data: data
      type: 'get'
      success: (data) ->
        $('#ajx-wait').hide()
        if typeof data == "object"
          snapshots_table.fnClearTable()
          snapshots_table.fnAddData(data)
          cellAndPage()
        else
          snapshots_table.fnClearTable()
          cellAndPage()
          $(".bb-alert")
            .addClass("alert-danger")
            .text("There are no records for that date!")
            .delay(200)
            .fadeIn()
            .delay(4000)
            .fadeOut()
      error: (xhr, status, error) ->
        $(".bb-alert")
            .addClass("alert-danger")
            .text(xhr.responseText)
            .delay(200)
            .fadeIn()
            .delay(4000)
            .fadeOut()

onPageLoad = ->
  $(window).load ->
    $('#datetimepicker').val getYesterdaysDate()
    ajaxCall(getYesterdaysDate())

pageAndCell = ->
  row = $("#snapshots_datatables_wrapper").children().first()
  row.css("margin-bottom", "-11px")
  cellAndPage()

cellAndPage = ->
  $("#snapshots_datatables > thead > tr > th").css("padding": "2px 4px")
  $("#snapshots_datatables > tbody > tr > th").css("padding": "2px 4px")
  $("#snapshots_datatables > thead > tr > td").css("padding": "2px 4px")
  $("#snapshots_datatables > tbody > tr > td").css("padding": "2px 4px")

window.initializSnapshotReport = ->
  columnsDropdown()
  initializeDataTable()
  initDatePicker()
  onPageLoad()
  pageAndCell()
