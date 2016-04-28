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
      {data: "1", sWidth: "145px" },
      {data: "2", sWidth: "200px" },
      {data: "3", sWidth: "150px" },
      {data: "4", sWidth: "150px" },
      {data: "5", sWidth: "80px", sClass: "center", "render": archiveStatus },
      {data: "6", sWidth: "150px" },
      {data: "7", sWidth: "150px", "render": renderDuration }
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
      $("#archive_datatables_length").hide()
      $("#div-dropdown-checklist").css({"visibility": "visible", "width": "57px", "top": "0px", "left": "6px" })
      #do something here

columnsDropdown = ->
  $(".cameras-column").on "click", ->
    column = merge_table.column($(this).attr("data-val"))
    column.visible !column.visible()

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

renderDuration = (name, type, row) ->
  dateTimeFrom = new Date(moment.utc(row[3]*1000).format('MM DD YYYY, HH:mm:ss'))
  dateTimeTo = new Date(moment.utc(row[4]*1000).format('MM DD YYYY, HH:mm:ss'))
  diff = dateTimeTo - dateTimeFrom
  diffSeconds = diff / 1000
  HH = Math.floor(diffSeconds / 3600)
  hours = HH + ' ' + 'hr'
  hours = '' unless HH isnt 0
  MM = Math.floor(diffSeconds % 3600) / 60
  MM = Math.round(MM)
  minutes = MM + ' ' +'min'
  minutes = '' unless MM isnt 0
  formatted = hours + ' ' + minutes
  return formatted

window.initializeArchives = ->
  initializeDataTable()
  columnsDropdown()
  setMargin()
