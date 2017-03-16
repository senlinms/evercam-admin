companies_data_table = undefined

sendAJAXRequest = (settings) ->
  token = $('meta[name="csrf-token"]')
  if token.size() > 0
    headers =
      "X-CSRF-Token": token.attr("content")
    settings.headers = headers
  xhrRequestChangeMonth = jQuery.ajax(settings)

initializeDataTable = ->
  companies_data_table = $("#companies_datatables").DataTable
    aaSorting: [5, "desc"]
    aLengthMenu: [
      [25, 50, 100, 200, -1]
      [25, 50, 100, 200, "All"]
    ]
    columns: [
      {data: "0", sWidth: "150px" },
      {data: "1", sWidth: "200px" },
      {data: "2", sWidth: "50px", sClass: "center" },
      {data: "3", sWidth: "50px", sClass: "center" },
      {data: "4", sWidth: "100px" },
      {data: "5", sWidth: "100px" },
      {data: "6", sWidth: "50px", visible: false, sClass: "center" }
    ],
    iDisplayLength: 500
    columnDefs: [
      type: "date-uk"
      targets: 'datatable-date'
    ],
    "oLanguage": {
      "sSearch": "Filter:"
    },
    initComplete: ->
      $("#companies_datatables_length").html($("#btn_add_company"))

onEditCompany = ->
  $("#companies_datatables").on "click", ".edit-company", ->
    company_row = $(this).parents('tr')
    $('#modal-add').modal('show')
    company_id = company_row.find('td:nth-child(3)').text()
    company_name = company_row.find('td:nth-child(5)').text()

onSaveCompany = ->
  $("#save-company").on "click", ->
    $(".bb-alert").removeClass("alert-info").addClass("alert-danger")
    if $("#txtCompanyId").val() is "" && $("#txtCompanyName").val() is ""
      Notification.show("Please add company-id and company name.")
      return false
    if $("#txtCompanyId").val() is ""
      Notification.show("Please add company-id.")
      return false
    if $("#txtCompanyName").val() is ""
      Notification.show("Please add company name.")
      return false

    data = {}
    data.company_id = $("#txtCompanyId").val()
    data.company_name = $("#txtCompanyName").val()
    
    onError = (jqXHR, status, error) ->
      Notification.show(jqXHR.text)

    onSuccess = (response, status, jqXHR) ->
      if response.success
        $(".bb-alert").removeClass("alert-danger").addClass("alert-info")
        $("#txtCompanyId").val("")
        $("#txtCompanyName").val("")
        $('#add_edit_company_modal').modal('hide')
        companies_data_table.row.add([
          response.company["company_id"],
          response.company["name"],
          response.company["session_count"],
          response.company["user_count"],
          getDateTime(response.company["updated_at"]),
          getDateTime(response.company["created_at"]),
          ""]).draw(false)
        Notification.show("Company created successfully.")
      else
        Notification.show(response.message)

    settings =
      data: data
      dataType: 'json'
      error: onError
      success: onSuccess
      contentType: "application/x-www-form-urlencoded"
      type: "POST"
      url: "/intercom/companies"

    sendAJAXRequest(settings)

getDateTime = (timestamp) ->
  moment(timestamp*1000).format('ddd, DD MMM YYYY HH:mm:ss')

initNotify = ->
  Notification.init(".bb-alert")

window.initializeIntercom = ->
  initializeDataTable()
  initNotify()
  onSaveCompany()