vendor_table = null
method = 'POST'

sendAJAXRequest = (settings) ->
  token = $('meta[name="csrf-token"]')
  if token.size() > 0
    headers =
      "X-CSRF-Token": token.attr("content")
    settings.headers = headers
  xhrRequestChangeMonth = jQuery.ajax(settings)

initializeDataTable = ->
  headers = undefined
  token = $('meta[name="csrf-token"]')
  if token.size() > 0
    headers = 'X-CSRF-Token': token.attr('content')

  vendor_table = $('#datatable_vendors').DataTable({
    ajax: {
      url: "vendors",
      'headers': headers
      dataSrc: '',
      error: (xhr, error, thrown) ->
        console.log(xhr.responseJSON.message)
    },
    fnRowCallback: ->
      cellDesign()
    drawCallback: ->
      cellDesign()
    columns: [
      {data: "exid", visible: false, width: '20%', 'render': showLogo },
      {data: "exid", width: '20%', 'render': editVendor },
      {data: "name", width: '20%'},
      {data: "known_macs", width: '40%', 'render': showMacs }
    ],
    "oLanguage": {
      "sSearch": "Filter:"
    },
    iDisplayLength: 200
    aLengthMenu: [
      [25, 50, 100, 200, -1]
      [25, 50, 100, 200, "All"]
    ]
    aaSorting: [1, "asc"],
    initComplete: ->
      $("#vendor-list-row").removeClass('hide')
      $("#datatable_vendors_length label").hide()
      $("#div-dropdown-checklist").css('visibility', 'visible')
      cellDesign()
  })

columnsDropdown = ->
  $(".vendors-column").on "click", ->
    column = vendor_table.column($(this).attr("data-val"))
    column.visible !column.visible()

editVendor = (id, type, row) ->
  return "<a style='cursor:pointer;' class='edit-vandor' val-id='#{row.exid}' val-name='#{row.name}' val-macs='#{row.known_macs}'>#{row.exid}</a>"

showLogo = (id, type, row) ->
  img = new Image()
  image_url = "http://evercam-public-assets.s3.amazonaws.com/#{id}/logo.jpg"
  img.onload = ->

  img.onerror = ->
    $("#image-#{row.exid}").remove()
  img.src = image_url
  return "<img id='image-#{row.exid}' style='width:100%;' src='#{image_url}'/>"

showMacs = (macs, type, row) ->
  known_macs = "#{macs}"
  return "<span style='word-wrap: break-word;'>#{known_macs.replace(RegExp(",", "g"), ", ")}</span>"

clearForm = ->
  $("#exid").val('')
  $("#exid").removeAttr("disabled")
  $("#name").val('')
  $("#known_macs").val('')
  $(".thumbnail-img").hide()
  $(".thumbnail-img").attr("src","camera.svg")
  $(".center-thumbnail").css("min-height", "160px")
  $(".vendor-alert").slideUp()
  $("#add-vendor div.caption").text("Add a Vendor");
  method = 'POST'

handleAddNewModel = ->
  $("#save-vendor").on 'click', ->
    $(".vendor-alert").slideUp()
    data = {}
    data.exid = $("#exid").val()
    data.name = $("#name").val()
    data.known_macs = $("#known_macs").val() unless $("#known_macs").val() is ''

    onError = (jqXHR, status, error) ->
      $(".vendor-alert").html(jqXHR.responseJSON[0])
      $(".vendor-alert").slideDown()
      false

    onSuccess = (result, status, jqXHR) ->
      vendor_table.ajax.reload()
      cellDesign()
      $('#add-vendor').modal('hide')
      method = 'POST'
      clearForm()
      true

    settings =
      cache: false
      data: data
      dataType: 'json'
      error: onError
      success: onSuccess
      contentType: "application/x-www-form-urlencoded"
      type: method
      url: "vendors"

    sendAJAXRequest(settings)

onModelClose = ->
  $(".modal").on "hide.bs.modal", ->
    clearForm()

onEditVendor = ->
  $("#datatable_vendors").on 'click', '.edit-vandor', ->
    $("#exid").val($(this).attr("val-id"))
    $("#exid").attr("disabled", true)
    $("#name").val($(this).attr("val-name"))
    $("#known_macs").val($(this).attr("val-macs"))
    $(".thumbnail-img").attr("src", "http://evercam-public-assets.s3.amazonaws.com/#{$(this).attr("val-id")}/logo.jpg")
    $(".center-thumbnail").css("min-height", "30px")
    $(".thumbnail-img").show()
    method = 'PATCH'
    $('#add-vendor').modal('show')
    $("#add-vendor div.caption").text("Edit Vendor");

appendMe = ->
  options = $(".lic-col-box")
  row = $("#datatable_vendors_wrapper").children().first()
  row.append options
  row.css("margin-bottom", "-11px")
  $(".dropdown-checklist").css({"width": "20px", "top": "34px"})

cellDesign = ->
  $("#datatable_vendors > thead > tr > th").css("padding": "2px 4px")
  $("#datatable_vendors > tbody > tr > th").css("padding": "2px 4px")
  $("#datatable_vendors > thead > tr > td").css("padding": "2px 4px")
  $("#datatable_vendors > tbody > tr > td").css("padding": "2px 4px")

window.initializeVendors = ->
  initializeDataTable()
  columnsDropdown()
  handleAddNewModel()
  onModelClose()
  onEditVendor()
  appendMe()
  cellDesign()
