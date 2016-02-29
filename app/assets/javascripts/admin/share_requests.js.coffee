shares_table = undefined

initializeDataTable = ->
  shares_table = $("#shares_datatables").DataTable
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
      {data: "6" }
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
      $("#div-dropdown-checklist").css('visibility', 'visible')

columnsDropdown = ->
  $(".share-requests-column").on "click", ->
    column = shares_table.column($(this).attr("data-val"))
    column.visible !column.visible()

appendMe = ->
  div = '<div class="dropdown-checklist" id="div-dropdown-checklist">'
  div += '<div href="#" class="btn btn-default grey" data-toggle="modal" data-target="#toggle-datatable-columns">'
  div +=  '<i class="fa fa-columns"></i>'
  div += '</div>'
  div +='</div>'
  $("#shares_datatables_wrapper").before(div)
  $("#div-dropdown-checklist").addClass("box-button")
  $("#shares_datatables_filter > label").addClass("filter-margin")
  $("#shares_datatables_filter > label > input").addClass("label-color")

window.initializeShareRequests = ->
  initializeDataTable()
  columnsDropdown()
  appendMe()
