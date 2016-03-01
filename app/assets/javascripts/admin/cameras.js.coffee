cameras_table = undefined

initializeDataTable = ->
  cameras_table = $("#cameras_datatables").DataTable
    aaSorting: [1, "asc"]
    fnRowCallback: (nRow, aData, iDisplayIndex, iDisplayIndexFull) ->
      if aData[12] is "true"
        $('td:eq(12)', nRow)
          .html "True"
          .css { "color": "green", "text-align": "center" }
      else
        $('td:eq(12)', nRow)
          .html "False"
          .css { "color": "Red", "text-align": "center" }
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
    ],
    "oLanguage": {
      "sSearch": "Filter:"
    },
    initComplete: ->
      $("#cameras-list-row").removeClass('hide')
      $("#cameras_datatables_length label").hide()
      $("#div-dropdown-checklist").css('visibility', 'visible')

columnsDropdown = ->
  $(".cameras-column").on "click", ->
    column = cameras_table.column($(this).attr("data-val"))
    column.visible !column.visible()

appendMe = ->
  div = '<div class="dropdown-checklist" id="div-dropdown-checklist">'
  div += '<div href="#" class="btn btn-default grey" data-toggle="modal" data-target="#toggle-datatable-columns">'
  div +=  '<i class="fa fa-columns"></i>'
  div += '</div>'
  div +='</div>'
  $("#cameras_datatables_wrapper").before(div)
  $("#div-dropdown-checklist").addClass("box-button")
  $("#cameras_datatables_filter > label").addClass("filter-margin")
  $("#cameras_datatables_filter > label > input").addClass("label-color")

window.initializeCameras = ->
  columnsDropdown()
  initializeDataTable()
  appendMe()
