users_table = undefined

initializeDataTable = ->
  users_table = $("#users_datatables").DataTable
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
      {data: "4" },
      {data: "5" },
      {data: "6" },
      {data: "7" },
      {data: "8", visible: false },
    ],
    iDisplayLength: 50
    columnDefs: [
      type: "date-uk"
      targets: 'datatable-date'
    ],
    initComplete: ->
      $("#user-list-row").removeClass('hide')
      $("#users_datatables_length label").hide()
      $("#div-dropdown-checklist").css('visibility', 'visible')

columnsDropdown = ->
  $(".users-column").on "click", ->
    column = users_table.column($(this).attr("data-val"))
    column.visible !column.visible()

window.initializeusers = ->
  columnsDropdown()
  initializeDataTable()