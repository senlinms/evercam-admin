snapshots_table = undefined

initializeDataTable = ->
  snapshots_table = $("#snapshots_datatables").DataTable
    aaSorting: [1, "asc"]
    fnRowCallback: (nRow, aData, iDisplayIndex, iDisplayIndexFull) ->
      console.log(aData[9])
      if aData[9] is "true"
        $('td:eq(6)', nRow)
          .html "Y"
          .css { "color": "green", "text-align": "center" }
      else if aData[9] is "false"
        $('td:eq(6)', nRow)
          .html "N"
          .css { "color": "Red", "text-align": "center" }
      else
        $('td:eq(6)', nRow)
          .html ""
    aLengthMenu: [
      [25, 50, 100, 200, -1]
      [25, 50, 100, 200, "All"]
    ]
    columns: [
      {data: "0" },
      {data: "1" },
      {data: "2", visible: false },
      {data: "3", visible: false },
      {data: "4" },
      {data: "5" },
      {data: "6" },
      {data: "7" },
      {data: "8", visible: false },
      {data: "9" }
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
      $("#snapshots-list-row").removeClass('hide')
      $("#snapshots_datatables_length label").hide()
      $("#div-dropdown-checklist").css('visibility', 'visible')

columnsDropdown = ->
  $(".cameras-column").on "click", ->
    column = snapshots_table.column($(this).attr("data-val"))
    column.visible !column.visible()

window.initializSnapshots = ->
  columnsDropdown()
  initializeDataTable()