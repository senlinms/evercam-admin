snap_extractor = undefined

initializeDataTable = ->
  snap_extractor = $("#extractor_datatables").DataTable
    aaSorting: [0, "desc"]
    aLengthMenu: [
      [25, 50, 100, 200, -1]
      [25, 50, 100, 200, "All"]
    ]
    columns: [
      {data: "0", sWidth: "40px", sClass: "center" },
      {data: "1", sWidth: "150px" },
      {data: "2", sWidth: "90px" },
      {data: "3", sWidth: "90px" },
      {data: "4", sWidth: "50px", sClass: "center" },
      {data: "5", sWidth: "50px", sClass: "center", "render": extractorStatus },
      {data: "6", sWidth: "200px" },
      {data: "7", sWidth: "40px", "render": extractor_location },
      {data: "8", sWidth: "150px" },
      {data: "9", sWidth: "100px" }
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
      $("#extractor_datatables_length").hide()
      $("#div-dropdown-checklist").css({"visibility": "visible", "width": "57px", "top": "0px", "left": "6px"})

columnsDropdown = ->
  $(".extractor-column").on "click", ->
    column = snap_extractor.column($(this).attr("data-val"))
    column.visible !column.visible()

setMargin = ->
  row = $("#extractor_datatables_wrapper").children().first()
  row.css("margin-bottom", "-11px")

extractor_location = (status) ->
  if parseInt(status) < 9
    "Cloud"
  else
    "Local"

extractorStatus = (status) ->
  if status is "0"
    "Pending"
  else if status is "1"
    "Processing"
  else if status is "2"
    "Completed"
  else if status is "3"
    "Failed"
  else if status is "11"
    "Processing"
  else if status is "12"
    "Completed"


window.initializeExtractors = ->
  initializeDataTable()
  columnsDropdown()
  setMargin()
