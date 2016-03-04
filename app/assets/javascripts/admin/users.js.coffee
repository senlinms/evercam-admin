users_table = undefined

initializeDataTable = ->
  users_table = $("#users_datatables").dataTable
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
    initComplete: (data) ->
      $("#user-list-row").removeClass('hide')
      $("#users_datatables_length label").hide()
      $("#div-dropdown-checklist").css('visibility', 'visible')

columnsDropdown = ->
  $(".users-column").on "click", ->
    column = users_table.column($(this).attr("data-val"))
    column.visible !column.visible()

appendMe = ->
  div = '<div class="dropdown-checklist" id="div-dropdown-checklist">'
  div += '<div href="#" class="btn btn-default grey" data-toggle="modal" data-target="#toggle-datatable-columns">'
  div +=  '<i class="fa fa-columns"></i>'
  div += '</div>'
  div +='</div>'
  $("#users_datatables_filter").before(div)
  $("#div-dropdown-checklist").addClass("box-button")
  $("#users_datatables_filter > label").addClass("filter-margin")
  $("#users_datatables_filter > label > input").addClass("label-color")

onPageLoad = ->
  $(window).load ->
    data = {}
    data.true = true
    $.ajax
      url: 'users'
      data: data
      type: 'get'
      dataType: "json"
      success: (data) ->
        console.log data
        # if typeof data == "object"
        # users_table.fnClearTable()
        users_table.fnAddData(data)
        # users_table.fnDrawCallback(data)

window.initializeusers = ->
  columnsDropdown()
  initializeDataTable()
  appendMe()
  onPageLoad()
