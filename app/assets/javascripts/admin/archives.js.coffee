archive_table = undefined

initializeDataTable = ->
  archive_table = $("#archive_datatables").DataTable
    aaSorting: [1, "asc"]
    aLengthMenu: [
      [25, 50, 100, 200, -1]
      [25, 50, 100, 200, "All"]
    ]
    columns: [
      {data: "0", sWidth: "145px" },
      {data: "1", sWidth: "150px" },
      {data: "2", sWidth: "200px" },
      {data: "3", sWidth: "150px" },
      {data: "4", sWidth: "150px" },
      {data: "5", sWidth: "80px", sClass: "center", "render": archiveStatus },
      {data: "6", sWidth: "150px" },
      {data: "7", sWidth: "85px", "render": secondsTimeSpanToHMS, sClass: "center" },
      {data: "8", sWidth: "100px", "render": publicStatus, sClass: "center", visible: false },
      {data: "9", sWidth: "85px", sClass: "center", "render": publicStatus },
      {data: "10", sWidth: "80px", sClass: "center", visible: false }
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
      $("#archive_datatables_length").hide()
      $("#div-dropdown-checklist").css({"visibility": "visible", "width": "57px", "top": "0px", "left": "6px" })
      #do something here

columnsDropdown = ->
  $(".archive-column").on "click", ->
    column = archive_table.column($(this).attr("data-val"))
    column.visible !column.visible()

publicStatus = (name) ->
  if name is "true"
    "<span style='color:green'>Yes</span>"
  else if name is "" || name is "false"
    "<span style='color:red'>No</span>"

archiveStatus = (name) ->
  if name is "0"
    "Pending"
  else if name is "1"
    "Processing"
  else if name is "2"
    "Completed"
  else if name is "3"
    "Failed"

setMargin = ->
  row = $("#archive_datatables_wrapper").children().first()
  row.css("margin-bottom", "-11px")

secondsTimeSpanToHMS = (s) ->
  h = Math.floor(s / 3600)
  #Get whole hours
  s -= h * 3600
  m = Math.floor(s / 60)
  #Get remaining minutes
  s -= m * 60
  h + ':' + (if m < 10 then '0' + m else m) + ':' + (if s < 10 then '0' + s else s)

window.initializeArchives = ->
  initializeDataTable()
  columnsDropdown()
  setMargin()
