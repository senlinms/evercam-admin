shares_table = undefined

initializeDataTable = ->
  shares_table = $("#shares_datatables").DataTable
    aaSorting: [2, "asc"]
    aLengthMenu: [
      [25, 50, 100, 200, -1]
      [25, 50, 100, 200, "All"]
    ]
    columns: [
      {data: "0", sWidth: "150px" },
      {data: "1", sWidth: "100px" },
      {data: "2", sWidth: "110px" },
      {data: "3", sWidth: "200px" },
      {data: "4", sWidth: "89px", sClass: "center" },
      {data: "5", sWidth: "85px", sClass: "center" },
      {data: "6", sWidth: "85px", sClass: "center" }
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
      $("#shares-list-row").removeClass('hide')
      $("#shares_datatables_length label").hide()

columnsDropdown = ->
  $(".share-requests-column").on "click", ->
    column = shares_table.column($(this).attr("data-val"))
    column.visible !column.visible()

appendMe = ->
  $("#div-dropdown-checklist").css({'visibility': 'visible', "width": "20px", "left": "-8px", "top": "0px"})
  row = $("#shares_datatables_wrapper").children().first()
  row.css("margin-bottom", "-11px")
  $("#shares-list-row").css("margin-top","-34px")

window.initializeShareRequests = ->
  initializeDataTable()
  columnsDropdown()
  appendMe()
