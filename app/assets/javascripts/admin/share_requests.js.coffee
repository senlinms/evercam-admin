shares_table = undefined

initializeDataTable = ->
  shares_table = $("#shares_datatables").DataTable
    'fnDrawCallback': ->
      Metronic.init()
    aaSorting: [2, "asc"]
    aLengthMenu: [
      [25, 50, 100, 200, -1]
      [25, 50, 100, 200, "All"]
    ]
    columns: [
      {data: "7", "width": "20px", "sClass": "center", "render": addCheckbox},
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
    "search": {
      "regex": true
    },
    initComplete: ->
      Metronic.init()
      $("#shares-list-row").removeClass('hide')
      $("#shares_datatables_length").hide()
      $("#shares_datatables_filter").css({"margin-right": "45px", "margin-top": "-37px"})

columnsDropdown = ->
  $(".share-requests-column").on "click", ->
    column = shares_table.column($(this).attr("data-val"))
    column.visible !column.visible()

addCheckbox = (id, type, row) ->
  return "<input type='checkbox' data-val-id='#{row[7]}'/>"

appendMe = ->
  $("#div-dropdown-checklist").css({'visibility': 'visible', "width": "20px", "margin-left": "1603px", "top": "0px"})
  row = $("#shares_datatables_wrapper").children().first()
  row.css("margin-bottom", "-11px")
  $("#shares-list-row").css("margin-top","-34px")

statusFilter = ->
  $(".share-requests-status-used, .share-requests-status-pending, .share-requests-status-cancelled").change ->
    if !@checked
      status = ""
    else
      status = $(this).attr("data-val")
    shares_table
      .column(6)
      .search( status )
      .draw()

statusCheckBox = ->
  $("input[name=status-used], input[name=status-cancelled], input[name=status-pending]").on "click", ->
    whatsSelected = []
    $.each $(".form-merge-report input[type='checkbox']:checked"), ->
      if $(this).is(':checked')
        whatsSelected.push '(?=.*' + $(this).attr('data-val') + ')'
    if whatsSelected.length > 0
      $('#shares_datatables').DataTable().search(whatsSelected.join('|'), true, false, true).draw()
    else
      $('#shares_datatables').DataTable().search(" ", false, true, false).draw()

loadPendingOnly = ->
  shares_table.column(6).search( "pending" ).draw()
  Metronic.init()

window.initializeShareRequests = ->
  initializeDataTable()
  columnsDropdown()
  statusCheckBox()
  statusFilter()
  appendMe()
  loadPendingOnly()
