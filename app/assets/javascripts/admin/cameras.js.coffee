cameras_table = undefined

initializeDataTable = ->
  cameras_table = $("#cameras_datatables").DataTable
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
      {data: "8" },
      {data: "9" },
      {data: "10" },
      {data: "11" },
      {data: "12" },
      {data: "13" },
      {data: "14", visible: false }
    ],
    iDisplayLength: 50
    columnDefs: [
      type: "date-uk"
      targets: 'datatable-date'
    ]
  $("#cameras_datatables_length label").hide()
  $("#div-dropdown-checklist").css('visibility', 'visible')

toggleColumns = ->
  $('#cameras-report').on 'click', '.toggle-vis', (e) ->
    e.preventDefault()
    # Get the column API object
    column = cameras_table.column($(this).attr('data-column'))
    # Toggle the visibility
    column.visible !column.visible()

columnsDropdown = ->
  $('#ddl-camera-columns').dropdownchecklist
    icon: {}
    width: 230
    onItemClick: (checkbox, selector) ->
      column = cameras_table.column(checkbox.val())
      column.visible !column.visible()

window.initializeCameras = ->
  columnsDropdown()
  initializeDataTable()
  toggleColumns()