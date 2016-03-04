users_table = undefined
page_load = true

initializeDataTable = ->
  users_table = $("#users_datatables").dataTable
    aaSorting: [7, "desc"]
    aLengthMenu: [
      [25, 50, 100, 200, -1]
      [25, 50, 100, 200, "All"]
    ]
    columns: [
      {data: "0" },
      {data: "1", "render": linkUser },
      {data: "2" },
      {data: "3" },
      {data: "4" },
      {data: "5", "render": cameraLink },
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
    fnShowHide($(this).attr("data-val"), users_table)

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

fnShowHide = (iCol, oTable) ->
  bVis = oTable.fnSettings().aoColumns[iCol].bVisible
  oTable.fnSetColumnVis iCol, if bVis then false else true

linkUser = (name, type, row)->
  if page_load
    return name
  else
    return "<a href='/users/#{row[10]}'>#{name}</a>"

cameraLink = (name, type, row) ->
  if page_load
    return name
  else
    return "<a href='/users/#{row[10]}#tab_1_12'>#{name}</>"

onPageLoad = ->
  $(window).load ->
    page_load = false
    data = {}
    data.true = true
    $.ajax
      url: 'users'
      data: data
      type: 'get'
      dataType: "json"
      success: (data) ->
        users_table.fnClearTable()
        users_table.fnAddData(data)
      error: (xhr, status, error) ->
        console.log xhr

window.initializeusers = ->
  columnsDropdown()
  initializeDataTable()
  appendMe()
  onPageLoad()
