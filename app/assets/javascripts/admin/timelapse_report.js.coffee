timelapse_table = undefined

initializeDataTable = ->
  timelapse_table = $("#timelapse_datatables").DataTable
    aaSorting: [1, "asc"]
    aLengthMenu: [
      [25, 50, 100, 200, -1]
      [25, 50, 100, 200, "All"]
    ]
    columns: [
      {data: "0", visible: false },
      {data: "1", visible: false },
      {data: "2", visible: false },
      {data: "3" },
      {data: "4" },
      {data: "5" },
      {data: "6" },
      {data: "7" },
      {data: "8" },
      {data: "9" },
      {data: "10" },
      {data: "11", visible: false },
      {data: "12", visible: false },
      {data: "13" },
      {data: "14" }
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
      $("#timelapse-list-row").removeClass('hide')
      $("#timelapse_datatables_length label").hide()
      $("#div-dropdown-checklist").css('visibility', 'visible')
      $("#div-dropdown-checklist").css({"visibility": "visible", "width": "57px", "top": "-59px", "float": "right" })
      $("#timelapse_datatables_filter").css({"margin-top": "-34px", "margin-right": "49px"})

columnsDropdown = ->
  $(".timelapse-column").on "click", ->
    column = timelapse_table.column($(this).attr("data-val"))
    column.visible !column.visible()

window.initializeMerges = ->
  initializeDataTable()
  columnsDropdown()
