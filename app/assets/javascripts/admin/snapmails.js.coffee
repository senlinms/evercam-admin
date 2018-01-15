snapmails = undefined

sendAJAXRequest = (settings) ->
  token = $('meta[name="csrf-token"]')
  if token.size() > 0
    headers =
      "X-CSRF-Token": token.attr("content")
    settings.headers = headers
  xhrRequestChangeMonth = jQuery.ajax(settings)

initializeDataTable = ->
  snapmails = $("#snapmails_datatables").DataTable
    aaSorting: [0, "desc"]
    aLengthMenu: [
      [25, 50, 100, 200, -1]
      [25, 50, 100, 200, "All"]
    ]
    columns: [
      {data: "0", sWidth: "100px" },
      {data: "1", sWidth: "150px", visible: false },
      {data: "2", sWidth: "100px" },
      {data: "3", sWidth: "100px" },
      {data: "4", sWidth: "200px" },
      {data: "5", sWidth: "150px" },
      {data: "6", sWidth: "75px", sClass: "center" },
      {data: "7", sWidth: "85px", sClass: "center" },
      {data: "8", sWidth: "75px", sClass: "center", "render": colorStatus }
    ],
    iDisplayLength: 60
    columnDefs: [
      type: "date-uk"
      targets: 'datatable-date'
    ],
    "oLanguage": {
      "sSearch": "Filter:"
    },
    initComplete: ->
      $("#snapmails_datatables_length").hide()
      $("#div-dropdown-checklist").css({"visibility": "visible", "width": "57px", "top": "0px", "left": "6px" })

colorStatus = (name) ->
  console.log name
  if name is "t" || name is true || name is "true"
    return "<span style='color: green;'>True</span>"
  else if name is "f" || name is false || name is null || name is "false"
    return "<span style='color: red;'>False</span>"

columnsDropdown = ->
  $(".snapmails-history-column").on "click", ->
    column = snapmails.column($(this).attr("data-val"))
    column.visible !column.visible()

setMargin = ->
  row = $("#snapmails_datatables_wrapper").children().first()
  row.css("margin-bottom", "-11px")

window.initializeSnapmails = ->
  initializeDataTable()
  columnsDropdown()
  setMargin()
