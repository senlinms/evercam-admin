shares_table = undefined
sendAJAXRequest = (settings) ->
  token = $('meta[name="csrf-token"]')
  if token.size() > 0
    headers =
      "X-CSRF-Token": token.attr("content")
    settings.headers = headers
  xhrRequestChangeMonth = jQuery.ajax(settings)
  true

initializeDataTable = ->
  shares_table = $("#shares_datatables").DataTable
    'fnDrawCallback': ->
      Metronic.init()
    aaSorting: [2, "asc"]
    aLengthMenu: [
      [50, 100, 500, -1]
      [50, 100, 500, "All"]
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
    initComplete: ->
      Metronic.init()
      $("#shares-list-row").removeClass('hide')
      $("#shares_datatables_length").css("margin-top", "-36px")
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
  $('#shares_datatables').DataTable().search("(?=.*pending)", true, false, true).draw()
  Metronic.init()

onDeleteShareRequest = ->
  $("#chk_select_all").on "click", ->
    if $(this).is(':checked')
      $("#shares_datatables tbody div.checker span").addClass("checked")
      $("#shares_datatables tbody input[type='checkbox']").prop("checked", true)
    else
      $("#shares_datatables tbody div.checker span").removeClass("checked")
      $("#shares_datatables tbody input[type='checkbox']").prop("checked", false)

  $("#btn-delete").on "click", ->
    if $("#shares_datatables tbody input[type='checkbox']:checked").length is 0
      $(".bb-alert").removeClass("alert-success").addClass("alert-danger")
      Notification.show("Please select share requests you want to delete.")
    else
      total_requests = $("#shares_datatables tbody input[type='checkbox']:checked").length
      $("#total_requests").text(total_requests)
      $("#deleteModal").modal('show')

  $("#delete-share-requests").on "click", ->
    share_ids = ""
    $("#shares_datatables tbody input[type='checkbox']:checked").each (index, control) ->
      # $(control).parents('tr').remove()
      shares_table
          .row( $(this).parents('tr') )
          .remove()
          .draw()
      if share_ids is ""
        share_ids += "#{$(control).attr("data-val-id")}"
      else
        share_ids += ",#{$(control).attr("data-val-id")}"

    data = {}
    data.ids = share_ids

    onError = (jqXHR, status, error) ->
      $(".bb-alert").removeClass("alert-success").addClass("alert-danger")
      Notification.show(jqXHR.text)

    onSuccess = (result, status, jqXHR) ->
      $(".bb-alert").removeClass("alert-danger").addClass("alert-success")
      Notification.show("Share requests Deleted.")
      $("#chk_select_all").prop("checked", false)
      $("#uniform-chk_select_all span").removeClass("checked")
      $("#deleteModal").modal('hide')

    settings =
      cache: false
      data: data
      dataType: 'json'
      error: onError
      success: onSuccess
      contentType: "application/x-www-form-urlencoded"
      type: "DELETE"
      url: "/multiple_share_requests/delete"

    sendAJAXRequest(settings)

window.initializeShareRequests = ->
  initializeDataTable()
  columnsDropdown()
  statusCheckBox()
  statusFilter()
  appendMe()
  loadPendingOnly()
  onDeleteShareRequest()
