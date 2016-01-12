sendAJAXRequest = (settings) ->
  token = $('meta[name="csrf-token"]')
  if token.size() > 0
    headers =
      "X-CSRF-Token": token.attr("content")
    settings.headers = headers
  xhrRequestChangeMonth = jQuery.ajax(settings)

loadkpiPage = ->
  data = {}
  data.kpi_result = true

  onError = (jqXHR, status, error) ->
    console.log(jqXHR)
    false

  onSuccess = (result, status, jqXHR) ->
    data = result[0]
    bindHtml(data.date, "heading")
    bindHtml(data.new_cameras, "new-cameras")
    bindHtml(data.total_cameras, "total-cameras")
    bindHtml(data.new_paid_cameras, "new-paid-cameras")
    bindHtml(data.total_paid_cameras, "total-paid-cameras")
    bindHtml(data.new_users, "new-users")
    bindHtml(data.total_users, "total-users")

  settings =
    cache: false
    data: data
    dataType: 'json'
    error: onError
    success: onSuccess
    type: "GET"
    url: "/kpi"

  sendAJAXRequest(settings)

bindHtml = (records, row) ->
  for rec in records
    cell = $('<td>')
    cell.append($(document.createTextNode(rec)))
    $("#tbl-kpi .#{row}").append(cell)

window.initializeDashboard = ->
  setTimeout(loadkpiPage, 1000)