archive_table = undefined

initializeDataTable = ->
  archive_table = $("#archive_datatables").DataTable
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
      {data: "4", sClass: "center" },
      {data: "5", sClass: "center" },
      {data: "6", sClass: "center" }
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
      #do something here

columnsDropdown = ->
  $(".cameras-column").on "click", ->
    column = merge_table.column($(this).attr("data-val"))
    column.visible !column.visible()

setMargin = ->
  row = $("#archive_datatables_wrapper").children().first()
  row.css("margin-bottom", "-11px")

window.initializeArchives = ->
  initializeDataTable()
  columnsDropdown()
  setMargin()
