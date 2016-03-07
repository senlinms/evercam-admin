cameras_table = undefined
page_load = true

initializeDataTable = ->
  cameras_table = $("#cameras_datatables").dataTable
    aaSorting: []
    aLengthMenu: [
      [25, 50, 100, 200, -1]
      [25, 50, 100, 200, "All"]
    ]
    columns: [
      {data: "0", "render": linkCamera },
      {data: "1", "render": linkOwner },
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
      {data: "12", "render": colorStatus },
      {data: "13", "sType": "uk_datetime" },
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
    fnShowHide($(this).attr("data-val"), cameras_table)

fnShowHide = (iCol, oTable) ->
  bVis = oTable.fnSettings().aoColumns[iCol].bVisible
  oTable.fnSetColumnVis iCol, if bVis then false else true

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

colorStatus = (name) ->
  if name is "true" || name is true
    return "<span style='color: green;'>True</span>"
  else if name is "false" || name is false
    return "<span style='color: red;'>False</span>"

linkCamera = (name, type, row) ->
  if page_load
    return name
  else
    return "<a href='/cameras/#{row[15]}'>#{row[0]}</a>"

linkOwner = (name, type, row) ->
  if page_load
    return name
  else
    return "<a href='/users/#{row[16]}'>#{row[1]}</a>"

onPageLoad = ->
  $(window).load ->
    page_load = false
    data = {}
    data.true = true
    $.ajax
      url: 'cameras'
      data: data
      type: 'get'
      dataType: "json"
      success: (data) ->
        cameras_table.fnClearTable()
        cameras_table.fnAddData(data)
      error: (xhr, status, error) ->
        $(".bb-alert")
            .addClass("alert-danger")
            .text(xhr.responseText)
            .delay(200)
            .fadeIn()
            .delay(4000)
            .fadeOut()

window.initializeCameras = ->
  columnsDropdown()
  initializeDataTable()
  appendMe()
  onPageLoad()
