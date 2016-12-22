admin_table = undefined

initializeDataTable = ->
  admin_table = $("#admin_datatables").DataTable
    aaSorting: [1, "asc"]
    aLengthMenu: [
      [25, 50, 100, 200, -1]
      [25, 50, 100, 200, "All"]
    ]
    columns: [
      {data: "0", sWidth: "100px" },
      {data: "1", sWidth: "100px" },
      {data: "2", sWidth: "100px" },
      {data: "3", sWidth: "150px" },
      {data: "4", sWidth: "150px" },
      {data: "5", sWidth: "150px" },
      {data: "6", sWidth: "150px" },
      {data: "7", sWidth: "65px", sClass: "center" },
      {data: "8", sWidth: "100px" }
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
      $("#admin_datatables_length").hide()
      $("#div-dropdown-checklist").css({"visibility": "visible", "width": "57px", "top": "0px", "left": "6px" })

columnsDropdown = ->
  $(".admin-column").on "click", ->
    column = admin_table.column($(this).attr("data-val"))
    column.visible !column.visible()

setMargin = ->
  row = $("#admin_datatables_wrapper").children().first()
  row.css("margin-bottom", "-11px")

window.initializeAdmins = ->
  initializeDataTable()
  columnsDropdown()
  setMargin()
